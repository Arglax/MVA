(function () {
    "use strict";

    const base = location.href.replace(/[?#].*$/, "").replace(/[^/]*$/, "");
    const app = window.MvaAndroid || null;
    const statusEl = () => document.getElementById("status");
    let player = null;

    function log(message) {
        try { if (app) app.log(String(message)); else console.log("[mva]", message); } catch (e) { }
    }

    const stats = { loaded: false, fpsSum: 0, fpsN: 0, fpsMin: 0, heat: 0 };
    let minuteFps = [];
    function statFps(fps) {
        if (!stats.loaded || document.hidden || window.__mvaNoDraw || !(fps > 0)) return;
        stats.fpsSum += fps;
        stats.fpsN++;
        stats.fpsMin = stats.fpsMin > 0 ? Math.min(stats.fpsMin, fps) : fps;
        if (minuteFps.length < 90) minuteFps.push(Math.min(fps, 240));
    }

    const ctx = { feature: "", map: "" };
    function tally(id) {
        try { if (app && app.count) app.count(String(id)); } catch (e) { }
    }

    function stat(id, on) {
        const full = on === undefined ? String(id) : id + (on ? ".on" : ".off");
        ctx.feature = full;
        tally(full);
    }
    window.MvaStat = stat;
    function health(key, n) {
        try { if (app && app.health) app.health(key, n); } catch (e) { }
    }
    function screenName() {
        try {
            const up = sel => { const el = document.querySelector(sel); return !!el && el.style.display !== "none"; };
            if (window.MvaHeadless && window.MvaHeadless.active()) return "headless";
            const sheet = document.getElementById("mva-sheet");
            if (sheet && sheet.style.display === "flex") {
                let tab = "settings";
                try { tab = JSON.parse(localStorage.getItem("mva.sheetTab")) || tab; } catch (e) { }
                return "sheet:" + tab;
            }
            if (up(".gopt")) return "gameOptions";
            if (up(".qk")) return "quick";
            if (up("#mva-drops")) return "drops";
            if (up("#mva-menu")) return "menu";
        } catch (e) { }
        return stats.loaded ? "game" : "loading";
    }
    function context() { return { screen: screenName(), feature: ctx.feature, map: ctx.map }; }

    let wasmMemory = null;
    try {
        const W = window.WebAssembly;
        const grab = r => {
            try {
                const inst = r && (r.instance || r);
                const m = inst && inst.exports && inst.exports.memory;
                if (m instanceof W.Memory) wasmMemory = m;
            } catch (e) { }
            return r;
        };
        for (const name of ["instantiate", "instantiateStreaming"]) {
            const original = W && W[name];
            if (typeof original !== "function") continue;
            W[name] = function () { return original.apply(this, arguments).then(grab); };
        }
    } catch (e) { }
    function pageMb() {
        let bytes = 0;
        try { if (wasmMemory) bytes += wasmMemory.buffer.byteLength; } catch (e) { }
        try { if (performance.memory) bytes += performance.memory.usedJSHeapSize; } catch (e) { }
        return Math.round(bytes / 1048576);
    }

    let knownNames = [];
    function readNames() {
        if (!stats.loaded) return;
        const out = [];
        for (const path of ["world.myAvatar.objData.strUsername", "loginInfo.strUsername"]) {
            try {
                const v = JSON.parse(swf("getGameObject", path));
                if (typeof v === "string" && v.length >= 3 && !out.includes(v)) out.push(v);
            } catch (e) { }
        }
        if (out.length) knownNames = out;
    }

    function settingsSnapshot() {
        const s = {};
        try {
            for (const k of Object.keys(window.__mvaOpts)) s[k] = !!window.__mvaOpts[k];
            s.gfxDpr = gfx.dpr; s.gfxQuality = gfx.quality || "game"; s.gfxFilter = gfx.filter; s.gfxFps = gfx.fps;
            s.gfxAuto = gfx.auto; s.gfxHeat = gfx.heat; s.gfxSmooth = gfx.smooth;
            s.govLevel = gov.level; s.gameRate = gov.gameRate; s.heat = gov.heat; s.headless = headless;
            const a = JSON.parse(localStorage.getItem("mva.app") || "{}");
            s.keepOn = a.keepOn !== false;
        } catch (e) { }
        return s;
    }

    setInterval(() => {
        try {
            readNames();
            const msg = { loaded: stats.loaded, fpsAvg: stats.fpsN ? stats.fpsSum / stats.fpsN : 0, fpsMin: stats.fpsMin, heat: stats.heat,
                settings: settingsSnapshot(), context: context(), names: knownNames, pageMb: pageMb(), fps: gov.lastFps };

            if (minuteFps.length >= 20)
                msg.minute = { fps: minuteFps.reduce((a, b) => a + b, 0) / minuteFps.length, lo: Math.min(...minuteFps), hi: Math.max(...minuteFps) };
            minuteFps = [];
            if (app && app.stats) app.stats(JSON.stringify(msg));
        } catch (e) { }
    }, 60000);

    setInterval(() => {
        if (!stats.loaded || document.hidden) return;
        try {
            const m = JSON.parse(swf("getGameObject", "world.strMapName"));
            if (typeof m !== "string" || !m || m === ctx.map) return;
            ctx.map = m.slice(0, 40);
            health("mapLoads", 1);
            readNames();
        } catch (e) { }
    }, 5000);

    const reported = new Set();
    let lastPanic = "";
    function report(kind, message, stack) {
        const key = kind + ":" + message;
        if (reported.has(key) || reported.size >= 8) return;
        reported.add(key);
        try {
            if (app && app.problem) app.problem(JSON.stringify({ kind, error: String(message).slice(0, 1000),
                stack: String(stack || "").slice(0, 8000), context: context(), settings: settingsSnapshot(),
                names: knownNames, pageMb: pageMb(), fps: gov.lastFps }));
        } catch (e) { }
    }
    function failed(what, e) {
        log(what + ": " + e);
        report("problem", what + ": " + e, e && e.stack);
    }

    try {
        const nativeError = console.error.bind(console);
        console.error = function (...args) {
            try {
                const text = args.map(String).join(" ");
                if (/panicked at/.test(text)) lastPanic = text.slice(0, 3000);
            } catch (e) { }
            return nativeError(...args);
        };
    } catch (e) { }

    const nativeFetch = window.fetch.bind(window);
    function proxied(url) {
        let u;
        try { u = new URL(url, location.href); } catch (e) { return null; }
        if (u.origin === location.origin) return null;
        if (u.protocol !== "http:" && u.protocol !== "https:") return null;
        return base + "p/" + u.protocol.slice(0, -1) + "/" + u.host + u.pathname + u.search;
    }
    window.fetch = async function (input, init) {
        if (typeof input === "string" || input instanceof URL) {
            return nativeFetch(proxied(String(input)) || input, init);
        }
        if (input instanceof Request) {
            const target = proxied(input.url);
            if (target) {
                const opts = { method: input.method, headers: input.headers, credentials: "omit", cache: input.cache, redirect: "follow" };
                if (input.method !== "GET" && input.method !== "HEAD") opts.body = await input.arrayBuffer();
                return nativeFetch(target, Object.assign(opts, init || {}));
            }
        }
        return nativeFetch(input, init);
    };

    function ruffle() { return player && player.ruffle(); }
    function swf(name, ...args) {
        const r = ruffle();
        if (!r) return null;
        try { return r.callExternalInterface(name, ...args); } catch (e) { return null; }
    }

    const nativeDpr = window.devicePixelRatio || 1;
    let gfx = { dpr: 0, quality: "", filter: "natural", fps: false, auto: true, heat: true, smooth: 0 };
    let screenRatioCap = 0;
    const colourFilters = {
        natural: "",
        vivid: "saturate(1.3) contrast(1.08)",
        cinematic: "contrast(1.15) saturate(1.12) brightness(0.95)",
        bright: "brightness(1.12) contrast(1.05)"
    };

    function setPixelRatio(ratio, scale) {

        let want = ratio > 0 ? ratio : ratio < 0 ? Math.min(nativeDpr * -ratio, 3.5) : nativeDpr;
        if (ratio === 0 && screenRatioCap > 0) want = Math.min(want, screenRatioCap);
        if (scale && scale < 1) want = Math.max(1, want * scale);
        want = Math.round(want * 100) / 100;
        if (window.devicePixelRatio === want) return;
        Object.defineProperty(window, "devicePixelRatio", { get: () => want, configurable: true });

        const el = player;
        if (!el) return;
        el.style.width = "calc(100% - 1px)";
        requestAnimationFrame(() => requestAnimationFrame(() => { el.style.width = ""; }));
    }

    let touchRowH = 0;
    function applyTouchUi() {
        if (touchRowH <= 0) return;
        swf("mvaTouchUi", true);
    }

    function applyQuality() {
        const q = governedQuality();
        if (!player) return;

        holdGameQuality(gfx.quality || (gfx.auto && gov.level > 0) ? q : "");
        if (!q) return;
        swf("setGameObject", "stage.quality", q);
    }

    let heldPref = null;
    function holdGameQuality(q) {
        try {
            if (q) {
                if (heldPref === null) {
                    let cur = null;
                    try { cur = JSON.parse(swf("getGameObject", "userPreference.data.quality")); } catch (e) { cur = null; }
                    if (cur !== "AUTO") return;
                    heldPref = cur;
                }
                swf("setGameObject", "userPreference.data.quality", ["LOW", "MEDIUM", "HIGH"].indexOf(q) >= 0 ? q : "HIGH");
            } else if (heldPref !== null) {
                swf("setGameObject", "userPreference.data.quality", heldPref);
                heldPref = null;
            }
        } catch (e) { }
    }
    window.addEventListener("pagehide", () => holdGameQuality(""));

    const OPT_KEYS = ["mvaUi", "mvaImproveFps", "mvaSidebar", "mvaBigUi", "mvaLongDash", "mvaSwipe", "mvaAuras", "mvaDrops"];
    function optStored(key) {
        try { return localStorage.getItem("mva.opt." + key) !== "off"; } catch (e) { return true; }
    }
    window.__mvaOpts = {};
    for (const k of OPT_KEYS) window.__mvaOpts[k] = optStored(k);
    window.__mvaSwipeScroll = window.__mvaOpts.mvaSwipe;

    function onOption(key, value) {
        const on = String(value) !== "off";

        try {
            const before = localStorage.getItem("mva.opt." + key);
            if (before !== null && (before !== "off") !== on && /^mva[A-Z]\w*$/.test(key)) stat("opt" + key.slice(3), on);
        } catch (e) { }
        try { localStorage.setItem("mva.opt." + key, on ? "on" : "off"); } catch (e) { }
        const was = window.__mvaOpts[key];
        window.__mvaOpts[key] = on;
        if (key === "mvaSwipe") window.__mvaSwipeScroll = on;
        if (key === "mvaImproveFps") {
            window.__mvaFreezeOrphans = on;
            if (!on && gov.level !== 0) setLevel(0, "Improve FPS off");
            applySmooth();
        }
        if ((key === "mvaLongDash" || key === "mvaBigUi") && was !== undefined && was !== on) log(key + " " + (on ? "on" : "off") + ": from the next game start");
        try { window.dispatchEvent(new CustomEvent("mvaoption", { detail: { key, on } })); } catch (e) { }
    }

    const aaLadder = ["8X8", "HIGH", "MEDIUM", "LOW"];
    const govLevels = [

        { smooth: true, crowd: false, aa: 0, res: 1 }, { smooth: true, crowd: true, aa: 0, res: 1 },
        { smooth: false, crowd: true, aa: 0, res: 1 }, { smooth: false, crowd: true, aa: 1, res: 1 },
        { smooth: false, crowd: true, aa: 2, res: 1 }, { smooth: false, crowd: true, aa: 2, res: 0.8 },
        { smooth: false, crowd: true, aa: 3, res: 0.8 }, { smooth: false, crowd: true, aa: 3, res: 0.65 }
    ];

    window.__mvaFreezeOrphans = window.__mvaOpts.mvaImproveFps;
    const gov = {
        level: 0, floor: 0, low: 0, good: 0, settle: 0, gameRate: 30, rateAt: 0,
        upWait: 30, failedUpAt: 0, heat: "ok", lastFps: 0, gameQuality: "",
        trial: null, gpuBlockUntil: 0, recent: [], throttled: false, smoothPoor: 0, smoothPausedUntil: 0
    };

    function governedQuality() {
        const own = gfx.quality || gov.gameQuality;
        if (!gfx.auto || gov.level === 0) return own;
        let b = aaLadder.indexOf(own || "HIGH");
        if (b < 0) b = 1;
        return aaLadder[Math.min(aaLadder.length - 1, b + govLevels[gov.level].aa)];
    }
    function governedScale() { return gfx.auto ? govLevels[gov.level].res : 1; }
    function governedSmooth() {
        if (!(gfx.smooth > 0) || window.__mvaNoDraw || !window.__mvaOpts.mvaImproveFps) return 0;
        if (!gfx.auto) return gfx.smooth;
        if (!govLevels[gov.level].smooth || gov.throttled || Date.now() < gov.smoothPausedUntil) return 0;
        return gfx.smooth;
    }
    function applySmooth() { window.__mvaInterp = governedSmooth(); }

    function checkSmooth(fps, drawn) {
        if (!gfx.auto || !(gfx.smooth > 0)) return;
        if (Number(window.__mvaInterp) > 0 && drawn >= 0) {
            gov.smoothPoor = drawn - fps < 15 ? gov.smoothPoor + 1 : 0;
            if (gov.smoothPoor >= 5) {
                gov.smoothPoor = 0;
                gov.smoothPausedUntil = Date.now() + 60000;
                log("governor: in-betweening paused for a minute (" + drawn + " pictures for " + fps + " frames)");
            }
        } else gov.smoothPoor = 0;
        applySmooth();
    }

    let heldCrowd = null;
    function governedCrowd() {
        return !!(gfx.auto && govLevels[gov.level] && govLevels[gov.level].crowd);
    }
    function readCrowd() {
        try {
            const raw = swf("getGameObject", "litePreference.data.sCrowd");
            return raw == null || raw === "null" ? null : JSON.parse(raw);
        } catch (e) { return null; }
    }
    function applyCrowd() {
        try {
            if (!player) return;
            if (governedCrowd()) {
                if (heldCrowd === null) heldCrowd = readCrowd() || "auto";
                swf("setGameObject", "litePreference.data.sCrowd", "on");
            } else if (heldCrowd !== null) {
                swf("setGameObject", "litePreference.data.sCrowd", heldCrowd);
                heldCrowd = null;
            }
        } catch (e) { }
    }
    function defaultCrowd() {
        try {
            if (player && readCrowd() === null) swf("setGameObject", "litePreference.data.sCrowd", "auto");
        } catch (e) { }
    }
    window.addEventListener("pagehide", () => { gov.level = 0; applyCrowd(); });

    function defaultUntargetSelf() {
        try {
            if (!player || localStorage.getItem("mva.untargetSelfSet")) return;
            swf("setGameObject", "litePreference.data.bUntargetSelf", true);
            swf("callGameFunction", "litePreference.flush");
            localStorage.setItem("mva.untargetSelfSet", "1");
        } catch (e) { }
    }

    function levelKey(level) {
        const saved = gov.level;
        gov.level = level;
        const key = governedSmooth() + "|" + governedQuality() + "|" + governedScale() + "|" + governedCrowd();
        gov.level = saved;
        return key;
    }

    function setLevel(level, why) {
        level = Math.max(gov.floor, Math.min(govLevels.length - 1, level));
        if (level === gov.level) return;
        const now = levelKey(gov.level), step = level > gov.level ? 1 : -1;
        while (level > gov.floor && level < govLevels.length - 1 && levelKey(level) === now) level += step;
        const up = level < gov.level;
        if (gov.level === 0 && !gfx.quality) {
            try { gov.gameQuality = String(JSON.parse(swf("getGameObject", "stage.quality"))).toUpperCase(); }
            catch (e) { gov.gameQuality = ""; }
        }
        gov.level = level;
        gov.low = 0; gov.good = 0; gov.settle = 3;
        setPixelRatio(gfx.dpr, governedScale());
        applyQuality();
        applySmooth();
        applyCrowd();
        log("governor: level " + level + " (" + why + "; " + gov.lastFps + " fps of " + gov.gameRate + ")");
        if (stats.loaded) tally(up ? "govUp" : "govDown");
        if (up) gov.failedUpAt = Date.now();
    }

    function isGpuStep(level) { return level >= 3; }
    function recentFps() {
        const r = gov.recent;
        return r.length ? r.reduce((a, b) => a + b, 0) / r.length : gov.lastFps;
    }
    function readGameRate() {
        try {
            const v = Number(JSON.parse(swf("getGameObject", "stage.frameRate")));
            if (v >= 10 && v <= 120) gov.gameRate = v;
        } catch (e) { }
    }

    function governorTick(fps) {
        gov.lastFps = fps;
        if (!gfx.auto || !player || document.hidden || window.__mvaNoDraw) return;
        if (!window.__mvaOpts.mvaImproveFps) return;

        if (!gov.rateAt || fps > gov.gameRate + 5 || Date.now() - gov.rateAt > 60000) { gov.rateAt = Date.now(); readGameRate(); }
        if (gov.settle > 0) { gov.settle--; return; }
        gov.recent.push(fps);
        if (gov.recent.length > 4) gov.recent.shift();

        if (gov.trial) {
            gov.trial.samples.push(fps);
            if (gov.trial.samples.length >= 4) {
                const t = gov.trial, avg = t.samples.reduce((a, b) => a + b, 0) / t.samples.length;
                gov.trial = null;
                if (t.gpu && avg < t.before + 2 && t.from >= gov.floor) {
                    gov.gpuBlockUntil = Date.now() + 120000;
                    setLevel(t.from, "lower graphics gained nothing");
                    return;
                }
            }
        }

        const want = Math.min(gov.gameRate, 30);
        if (fps < want * 0.85) {
            gov.good = 0;
            if (++gov.low >= 3) {
                if (Date.now() - gov.failedUpAt < 20000) gov.upWait = Math.min(gov.upWait * 2, 600);
                const from = gov.level;
                if (isGpuStep(from + 1) && Date.now() < gov.gpuBlockUntil) { gov.low = 0; return; }
                const before = recentFps();
                setLevel(from + 1, "slow");
                if (gov.level !== from) gov.trial = { from, before, gpu: isGpuStep(gov.level), samples: [] };
            }
        } else {
            gov.low = 0;
            if (fps >= want * 0.95 && gov.level > gov.floor && ++gov.good >= gov.upWait) setLevel(gov.level - 1, "room to spare");
        }
    }

    let lastThermal = null;
    function setThermal(msg) {
        lastThermal = msg;
        const status = Number(msg.status), headroom = Number(msg.headroom), battery = Number(msg.battery);
        const was = gov.heat;
        const hot = status >= 3 || battery >= 47 || (was === "hot" && battery >= 45);
        const warm = status >= 2 || battery >= 45 || (was !== "ok" && battery >= 43.5);
        const heat = hot ? "hot" : warm ? "warm" : "ok";
        if (heat !== gov.heat) {
            log("thermal: " + heat + " (status " + status + ", battery " + battery + " C)");
            if (heat !== "ok") tally(heat === "hot" ? "heatHot" : "heatWarm");
        }
        gov.heat = heat;
        stats.heat = Math.max(stats.heat, heat === "hot" ? 2 : heat === "warm" ? 1 : 0);
        if (headroom >= 0) {
            const t = gov.throttled;
            gov.throttled = t ? headroom >= 0.9 : headroom >= 1;
            if (t !== gov.throttled) applySmooth();
        }
        gov.floor = gfx.auto && heat === "hot" ? 5 : 0;
        if (gov.floor > 0) gov.trial = null;
        if (gov.level < gov.floor) setLevel(gov.floor, "phone " + heat);
        if (window.MvaOverlays && window.MvaOverlays.heat)
            window.MvaOverlays.heat(gfx.heat ? { heat, battery, status, headroom, lowered: gfx.auto && gov.floor > 0 } : { heat: "ok" });
    }

    let fpsHooked = false, drawCalls = 0, framesDrawn = 0, fpsEl = null, fpsInterval = 0;
    function hookDraws() {
        if (fpsHooked) return;
        fpsHooked = true;
        for (const ctx of [window.WebGLRenderingContext, window.WebGL2RenderingContext]) {
            if (!ctx) continue;
            for (const name of ["drawElements", "drawArrays"]) {
                const original = ctx.prototype[name];
                ctx.prototype[name] = function () { drawCalls++; return original.apply(this, arguments); };
            }
        }
    }

    function startFrameCounter() {
        if (fpsInterval) return;
        if (!(Number(window.__mvaFrames) >= 0)) hookDraws();
        const tick = () => {
            if (drawCalls > 0) { framesDrawn++; drawCalls = 0; }
            requestAnimationFrame(tick);
        };
        requestAnimationFrame(tick);
        let lastGameFrames = -1, lastDrawn = -1;
        fpsInterval = setInterval(() => {
            let drawn = framesDrawn;
            framesDrawn = 0;
            const pictures = Number(window.__mvaDrawn);
            if (pictures >= 0) {
                if (lastDrawn >= 0) drawn = pictures - lastDrawn;
                lastDrawn = pictures;
            }
            const total = Number(window.__mvaFrames);
            const fps = total >= 0 && lastGameFrames >= 0 ? total - lastGameFrames : drawn;
            if (total >= 0) lastGameFrames = total;
            if (fpsEl && !window.__mvaNoDraw) {
                fpsEl.textContent = fps + " fps";
                fpsEl.style.color = fps >= gov.gameRate * 0.95 ? "#7CFC7C" : fps >= gov.gameRate * 0.7 ? "#FFD34D" : "#FF6B6B";
            }
            statFps(fps);
            try { governorTick(fps); } catch (e) { failed("governor", e); }
            try { if (!document.hidden) checkSmooth(fps, drawn); } catch (e) { }
        }, 1000);
    }

    function setFpsMeter(on) {
        startFrameCounter();
        if (on) hookDraws();
        if (!on) {
            if (fpsEl) { fpsEl.remove(); fpsEl = null; }
            return;
        }
        if (fpsEl) return;
        fpsEl = document.createElement("div");
        fpsEl.style.cssText = "position:fixed;left:6px;top:6px;z-index:25;padding:2px 6px;border-radius:4px;" +
            "font:bold 13px monospace;color:#7CFC7C;background:rgba(0,0,0,0.55);pointer-events:none";
        fpsEl.textContent = "-- fps";
        document.body.appendChild(fpsEl);
    }

    function applyGraphics() {
        if (!gfx.auto) { gov.level = 0; gov.floor = 0; }
        setPixelRatio(gfx.dpr, governedScale());
        applySmooth();
        if (player) player.style.filter = colourFilters[gfx.filter] || "";
        applyQuality();
        setFpsMeter(!!gfx.fps);
    }

    function setGraphics(g) {
        gfx = {
            dpr: Number(g.dpr) || 0,
            quality: String(g.quality || ""),
            filter: String(g.filter || "natural"),
            fps: !!g.fps,
            auto: g.auto !== false,
            smooth: Math.max(0, Number(g.smooth) || 0),
            heat: g.heat !== false
        };
        try { applyGraphics(); } catch (e) { failed("graphics", e); }
        if (lastThermal) { try { setThermal(lastThermal); } catch (e) { } }
    }

    function setStatus(text) {
        const el = statusEl();
        if (!el) return;
        el.textContent = text || "";
        el.style.display = text ? "block" : "none";
    }

    let ratings = null;
    function pushRatings() {
        if (!ratings) return;
        swf("mvaClassRatings", JSON.stringify(ratings));
        swf("mvaRatingFocus", "A-Z");
    }

    function firstArg(args) {
        let raw = args;
        while (Array.isArray(raw)) raw = raw[0];
        return raw;
    }

    window.__mvaExt = function (name, args) {
        switch (name) {
            case "requestLoadGame":

                setTimeout(() => swf("loadClient"), 0);
                break;
            case "loaded":
                stats.loaded = true;
                health("gameLoads", 1);
                health("gameLoadMsSum", Math.round(performance.now() - bootAt));
                setStatus("");
                setTimeout(applyQuality, 0);
                setTimeout(applyTouchUi, 0);
                setTimeout(pushRatings, 0);
                setTimeout(defaultCrowd, 0);
                setTimeout(defaultUntargetSelf, 0);
                if (window.__mvaOpts.mvaDrops) setTimeout(() => swf("mvaDropsOn", true), 0);
                try { if (app) app.playing(true); } catch (e) { }
                try { window.dispatchEvent(new Event("mvaloaded")); } catch (e) { }
                break;
            case "mvaMenu":
                try { window.MvaOverlays.menu(args); } catch (e) { failed("menu", e); }
                break;
            case "mvaDrops":
                try { window.MvaOverlays.dropsList(args); } catch (e) { failed("drops", e); }
                try { window.dispatchEvent(new CustomEvent("mvadrops", { detail: args })); } catch (e) { }
                break;
            case "mvaOption": {
                const m = /^(\w+):(on|off)$/.exec(String(firstArg(args)));
                if (m) onOption(m[1], m[2]);
                break;
            }
        }
        return undefined;
    };

    let keyboardWanted = false;
    function focusKeyboard(p) {
        setTimeout(() => {
            if (!keyboardWanted) return;
            if (!p.isVirtualKeyboardFocused()) p.virtualKeyboard.focus({ preventScroll: true });
            try { if (app) app.keyboard(); } catch (e) { }
        }, 0);
    }
    window.__mvaKeyboard = {
        openVirtualKeyboard(p) {
            keyboardWanted = true;
            if (!p.__mvaKeyboard) {
                p.__mvaKeyboard = true;
                p.container.addEventListener("mousedown", e => {
                    if (keyboardWanted && p.isVirtualKeyboardFocused()) e.preventDefault();
                });
                p.container.addEventListener("focus", () => focusKeyboard(p));
            }
            focusKeyboard(p);
        },
        closeVirtualKeyboard(p) {
            keyboardWanted = false;
            if (p.isVirtualKeyboardFocused()) p.container.focus({ preventScroll: true });
        }
    };

    const muteReasons = new Set();
    let mutedVolume = null;
    function setMuted(reason, on) {
        try {
            if (on) muteReasons.add(reason); else muteReasons.delete(reason);
            const r = ruffle();
            if (!r) return;
            if (muteReasons.size > 0) {
                if (mutedVolume === null) { mutedVolume = r.volume; r.volume = 0; }
            } else if (mutedVolume !== null) {
                r.volume = mutedVolume;
                mutedVolume = null;
            }
        } catch (e) { log("mute: " + e); }
    }

    let appBackground = false, headless = false;
    function applyNoDraw() {
        const on = appBackground || headless;
        window.__mvaNoDraw = on;
        applySmooth();
        setMuted("app", appBackground);
        if (!!window.__mvaBackground !== on) {
            window.__mvaBackground = on;
            try { document.dispatchEvent(new Event("visibilitychange")); } catch (e) { }
        }
    }
    function setBackground(on) {
        appBackground = !!on;
        applyNoDraw();
    }
    function setHeadless(on) {
        headless = !!on;
        stat("headless", headless);
        applyNoDraw();
        log("headless " + (headless ? "on" : "off"));
    }

    function handle(msg) {
        if (!msg || typeof msg !== "object") return;
        switch (msg.t) {
            case "background": setBackground(msg.v); break;
            case "thermal": try { setThermal(msg); } catch (e) { failed("thermal", e); } break;
            case "reload": location.reload(); break;
            case "back": return backPressed();
        }
        return false;
    }

    function backPressed() {
        try { if (window.MvaRails && window.MvaRails.back()) return true; } catch (e) { }
        return false;
    }

    let bootAt = 0;
    async function boot() {
        bootAt = performance.now();
        if (window.MvaOverlays) window.MvaOverlays.init(() => player);
        let cfg = { socketProxy: [], quality: "high", frameRate: 0 };
        try {
            cfg = await (await nativeFetch(base + "config.json")).json();
        } catch (e) {
            failed("config load", e);
        }
        try { ratings = await (await nativeFetch(base + "classratings.json")).json(); ratings = compactRatings(ratings); }
        catch (e) { ratings = null; }
        touchRowH = window.__mvaOpts.mvaBigUi ? Number(cfg.touchRowH) || 0 : 0;
        const consts = {};
        if (window.__mvaOpts.mvaLongDash) consts["MoveInput.DASH_PX"] = 540;
        if (touchRowH > 0) consts["LPFFrameInvAQ.ROW_H"] = touchRowH;
        window.__mvaAs3Consts = consts;

        window.__arglaxNoBatch = true;

        window.addEventListener("error", e => {
            const message = String(e.message || "");
            log("page error: " + message);
            const engine = /RuntimeError|panicked/.test(message);

            if (!/ResizeObserver loop/.test(message) && message !== "Script error.") {
                const where = e.filename ? " (" + String(e.filename).replace(/^.*\//, "").replace(/[?#].*$/, "") + ":" + e.lineno + ")" : "";
                report(engine ? "engine" : "problem", message + where,
                    (engine && lastPanic ? lastPanic + String.fromCharCode(10) : "") + (e.error && e.error.stack || ""));
            }

            if (engine) {
                let last = 0;
                try { last = Number(sessionStorage.getItem("mvaCrashReload")) || 0; } catch (err) { }
                if (Date.now() - last > 180000) {
                    try { sessionStorage.setItem("mvaCrashReload", String(Date.now())); } catch (err) { }
                    health("engineReloads", 1);
                    setTimeout(() => location.reload(), 1500);
                }
            }
        });
        window.addEventListener("unhandledrejection", e => log("unhandled rejection: " + (e.reason && e.reason.message || e.reason)));
        document.addEventListener("visibilitychange", () => setMuted("page", document.hidden));

        screenRatioCap = cfg.maxPixelRatio > 0 ? cfg.maxPixelRatio : 0;
        if (cfg.maxPixelRatio > 0 && window.devicePixelRatio > cfg.maxPixelRatio) {
            const cap = cfg.maxPixelRatio;
            Object.defineProperty(window, "devicePixelRatio", { get: () => cap, configurable: true });
        }

        setStatus("Loading game...");
        const rf = window.RufflePlayer.newest();
        player = rf.createPlayer();
        document.getElementById("player").appendChild(player);
        try { if (window.MvaRails) setGraphics(window.MvaRails.graphics()); else applyGraphics(); } catch (e) { failed("graphics", e); }

        const options = {
            url: base + "mva.swf",
            autoplay: "on",
            unmuteOverlay: "hidden",
            splashScreen: false,
            contextMenu: "off",
            letterbox: "on",
            scale: "showAll",
            logLevel: "warn",
            allowScriptAccess: true,
            allowNetworking: "all",
            openUrlMode: "deny",
            warnOnUnsupportedContent: false,
            showSwfDownload: false,
            maxExecutionDuration: 30,
            backgroundExecutionMode: "mainThread",
            quality: cfg.quality || "high",
            socketProxy: cfg.socketProxy || []
        };
        if (cfg.frameRate > 0) options.frameRate = cfg.frameRate;
        if (cfg.preferredRenderer) options.preferredRenderer = cfg.preferredRenderer;
        try {
            await ruffle().load(options);
        } catch (e) {
            failed("game start", e);
            setStatus("The game couldn't start. Close MVA and open it again.");
        }
    }

    function compactRatings(file) {
        const out = {};
        const classes = file && file.classes || {};
        for (const name of Object.keys(classes)) {
            const r = classes[name] || {};
            out[name.toLowerCase()] = [r.pve | 0, r.pvp | 0, r.farm | 0, r.solo | 0, r.boss | 0, r.ultra | 0, r.ultraRole || ""];
        }
        return out;
    }

    window.MvaBridge = { boot, log, handle, swf, setGraphics, setHeadless, player: () => player };
})();
