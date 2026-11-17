(function () {
    "use strict";

    const store = {
        get(k, d) { try { const v = localStorage.getItem("mva." + k); return v === null ? d : JSON.parse(v); } catch (e) { return d; } },
        set(k, v) { try { localStorage.setItem("mva." + k, JSON.stringify(v)); } catch (e) { } }
    };
    const GAME_W = 958, GAME_H = 550, MIN_RAIL = 64, MAX_RAIL = 112;

    const stat = (id, on) => { try { if (window.MvaStat) window.MvaStat(id, on); } catch (e) { } };
    const cap = s => s.charAt(0).toUpperCase() + s.slice(1);

    const LEFT = [
        { k: "quests", label: "Quests", act: () => call("callGameFunction", "world.toggleQuestLog") },
        { k: "tempinv", label: "Temp Inv", act: () => call("mvaGameButton", "temp") },
        { k: "map", label: "Map", act: () => call("mvaGameButton", "btnMap") },
        { k: "lore", label: "Lore", act: () => call("mvaGameButton", "btnBook") },
        { k: "menu", label: "Menu", act: () => call("mvaGameButton", "btnMenu") },
        { k: "house", label: "House", act: () => call("mvaGameButton", "btnHouse") },
        { k: "settings", label: "Settings", act: () => call("mvaGameButton", "btnOption") }
    ];
    const RIGHT = [
        { k: "bag", label: "Bag", act: () => call("mvaGameButton", "btnBag") },
        { k: "drops", label: "Drops", act: () => { try { window.MvaOverlays.toggleDrops(); } catch (e) { } } },
        { k: "bank", label: "Bank", act: () => call("callGameFunction", "world.toggleBank") },
        { k: "rest", label: "Rest", act: () => call("mvaGameButton", "btnRest") },
        { k: "char", label: "Char", act: () => call("mvaGameButton", "btnChar") },

        { k: "quick", label: "Quick", glyph: "⚡", act: () => { try { window.__quick.open(); } catch (e) { } } }
    ];

    const ICON_DIR = "img/rail/";

    let ruffleCall = null;
    function call(name, ...args) {
        try { if (ruffleCall) return ruffleCall(name, ...args); } catch (e) { }
        return null;
    }

    function css() {
        const s = document.createElement("style");
        s.textContent = `
.mva-rail { position: fixed; top: 0; bottom: 0; z-index: 20; display: flex; flex-direction: column; align-items: stretch;
  justify-content: center; gap: 6px; padding: 8px 6px; box-sizing: border-box;
  background: linear-gradient(#1E150D, #0E0905); user-select: none; -webkit-user-select: none; touch-action: manipulation; }
.mva-rail { overflow: hidden; flex-shrink: 0; }
.mva-rail.l { left: 0; border-right: 1px solid #8C6A2B; }
.mva-rail.r { right: 0; border-left: 1px solid #8C6A2B; }
.mva-rail button { flex: 1 1 0; max-height: 72px; min-height: 40px; display: flex; flex-direction: column; align-items: center;
  justify-content: center; gap: 2px; border: 1px solid transparent; border-radius: 10px; padding: 3px 2px;
  background: transparent; color: #EAD9A8; font: 400 11px Inter, system-ui, sans-serif; }
.mva-rail button:active { background: rgba(247,201,72,.18); border-color: #8C6A2B; }
.mva-rail button img { width: 30px; height: 30px; object-fit: contain; pointer-events: none; }
.mva-rail button span { max-width: 100%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.mva-rail button .g { height: 30px; font: 400 24px/30px Inter, system-ui, sans-serif; color: #F7C948; }
.mva-rail button .n { position: absolute; margin: -26px 0 0 30px; min-width: 16px; padding: 0 4px; border-radius: 8px;
  background: #C0352A; color: #FFF; font: 700 10px/16px Inter, system-ui, sans-serif; }
.mva-rail .crest { flex: 0 0 auto; height: 56px; font: 800 15px Georgia, serif; letter-spacing: 1px; color: #F7C948;
  background: radial-gradient(circle at 50% 35%, #7A1717, #2A0808); border-color: #C9A447; }
#mva-sheet { position: fixed; inset: 0; z-index: 45; display: none; align-items: center; justify-content: center; background: rgba(0,0,0,.45); }
#mva-sheet .pn { width: min(620px, 94vw); max-height: 92vh; overflow-y: auto; padding: 12px 14px; box-sizing: border-box;
  background: linear-gradient(#1E150D, #120C07); border: 1px solid #8C6A2B; border-radius: 14px; color: #EAD9A8;
  font: 14px/1.4 Inter, system-ui, sans-serif; box-shadow: 0 6px 24px rgba(0,0,0,.6); }
#mva-sheet h2 { position: relative; margin: 0 0 10px; min-height: 42px; display: flex; align-items: center; justify-content: center;
  color: #F7C948; font: 800 24px Georgia, serif; letter-spacing: 5px; text-indent: 5px;
  text-shadow: 0 1px 0 #5A3A08, 0 0 12px rgba(247,201,72,.45); }
#mva-sheet h2::before, #mva-sheet h2::after { content: ""; flex: 0 1 46px; height: 2px; margin: 0 12px;
  background: linear-gradient(90deg, rgba(201,164,71,0), #C9A447); }
#mva-sheet h2::after { transform: scaleX(-1); }
#mva-sheet h2 .x { position: absolute; right: 0; top: 50%; transform: translateY(-50%); letter-spacing: 0; text-indent: 0; text-shadow: none; }
#mva-sheet .tabs { display: flex; gap: 6px; margin-bottom: 10px; }
#mva-sheet .tabs button, #mva-sheet .x, #mva-sheet .chips button { min-height: 40px; padding: 0 14px; border-radius: 9px;
  border: 1px solid #8C6A2B; background: linear-gradient(#2A1E13, #170F09); color: #EAD9A8; font: 600 14px Inter, system-ui, sans-serif; }
#mva-sheet .tabs button.on, #mva-sheet .chips button.on { background: linear-gradient(#7A1717, #3F0A0A); color: #FFF4C0; border-color: #C9A447; }
#mva-sheet .row { margin: 0 0 12px; }
#mva-sheet .row > b { display: block; margin-bottom: 5px; color: #FFF4C0; }
#mva-sheet .row > i { display: block; margin-top: 4px; color: #A8987A; font-style: normal; font-size: 12px; }
#mva-sheet .chips { display: flex; flex-wrap: wrap; gap: 6px; }
#mva-sheet .sw { display: flex; align-items: center; gap: 12px; min-height: 48px; padding: 4px 2px; border-bottom: 1px solid rgba(140,106,43,.3); }
#mva-sheet .sw input { flex: none; width: 26px; height: 26px; accent-color: #C9A447; }
#mva-sheet .sw span b { display: block; color: #FFF4C0; font-weight: 600; }
#mva-sheet .sw span i { display: block; color: #A8987A; font-style: normal; font-size: 12px; }
#mva-sheet .sw.dim { opacity: .55; }
#mva-sheet p { margin: 0 0 8px; }`;
        document.head.appendChild(s);
        const defs = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        defs.setAttribute("width", "0");
        defs.setAttribute("height", "0");
        defs.style.position = "absolute";
        defs.innerHTML = '<defs><linearGradient id="mvaGold" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFF4C0"/>' +
            '<stop offset=".45" stop-color="#F7C948"/><stop offset="1" stop-color="#C8861A"/></linearGradient></defs>';
        document.body.appendChild(defs);
    }

    function button(item) {
        const b = document.createElement("button");
        b.innerHTML = (item.glyph ? `<span class="g">${item.glyph}</span>` : `<img src="${ICON_DIR}${item.k}.png" alt="">`) + `<span>${item.label}</span>`;
        b.addEventListener("click", e => { e.preventDefault(); closeSheet(); stat("rail" + cap(item.k)); item.act(); });
        if (item.k === "drops") dropsBtn = b;
        return b;
    }

    let left = null, right = null, dropsBtn = null;
    function build() {
        css();
        left = document.createElement("div");
        left.className = "mva-rail l";
        right = document.createElement("div");
        right.className = "mva-rail r";
        LEFT.forEach(i => left.appendChild(button(i)));
        RIGHT.forEach(i => right.appendChild(button(i)));
        const crest = document.createElement("button");
        crest.className = "crest";
        crest.textContent = "MVA";
        crest.addEventListener("click", () => { stat("crest"); openSheet(store.get("sheetTab", "settings")); });
        right.appendChild(crest);
        document.body.appendChild(left);
        document.body.appendChild(right);
        layout();

        store.set("app", appSettings());

        try {
            const ro = new ResizeObserver(() => requestAnimationFrame(checkLayout));
            ro.observe(document.documentElement);
            ro.observe(left);
            ro.observe(right);
            const p = document.getElementById("player");
            if (p) ro.observe(p);
        } catch (e) {
            setInterval(checkLayout, 2000);
        }
    }

    let railPx = 0;
    function checkLayout() {
        if (!left || !right) return;
        const on = window.__mvaOpts ? window.__mvaOpts.mvaSidebar !== false : true;
        const p = document.getElementById("player");
        const lw = left.getBoundingClientRect().width, rw = right.getBoundingClientRect().width;
        const pl = p ? p.getBoundingClientRect().left : 0;
        const bad = on && (Math.abs(lw - railPx) > 1 || Math.abs(rw - railPx) > 1 || Math.abs(pl - railPx) > 1)
            || !on && Math.abs(pl) > 1;
        if (bad) {
            const msg = `[layout] rails ${lw.toFixed(0)}/${rw.toFixed(0)} px, game at ${pl.toFixed(0)} px, expected ${on ? railPx : 0}: fixed`;
            console.warn(msg);
            try { if (window.MvaBridge) window.MvaBridge.log(msg); } catch (e) { }
            layout();
        }
    }

    let floatCrest = null;
    function layout() {
        const on = window.__mvaOpts ? window.__mvaOpts.mvaSidebar !== false : true;
        const W = window.innerWidth, H = window.innerHeight;
        const band = (W - H * GAME_W / GAME_H) / 2;
        const rail = Math.round(Math.max(MIN_RAIL, Math.min(MAX_RAIL, band)));
        railPx = rail;
        const p = document.getElementById("player");
        if (left) { left.style.display = on ? "flex" : "none"; left.style.width = rail + "px"; }
        if (right) { right.style.display = on ? "flex" : "none"; right.style.width = rail + "px"; }
        if (p) { p.style.left = on ? rail + "px" : "0"; p.style.right = on ? rail + "px" : "0"; }
        if (!on && !floatCrest) {
            floatCrest = document.createElement("button");
            floatCrest.style.cssText = "position:fixed;right:6px;bottom:6px;z-index:21;width:40px;height:40px;border-radius:50%;" +
                "border:1px solid #C9A447;background:radial-gradient(circle at 50% 35%,#7A1717,#2A0808);color:#F7C948;font:800 11px Georgia,serif";
            floatCrest.textContent = "MVA";
            floatCrest.addEventListener("click", () => { stat("crest"); openSheet(store.get("sheetTab", "settings")); });
            document.body.appendChild(floatCrest);
        }
        if (floatCrest) floatCrest.style.display = on ? "none" : "block";
    }

    const DEFAULT_GFX = { dpr: "0", quality: "HIGH", filter: "natural", fps: false, auto: true, heat: true, smooth: true };
    const CHOICES = {
        dpr: [["Battery (1x)", "1"], ["Balanced (1.5x)", "1.5"], ["Sharp (2x)", "2"], ["Native screen", "0"], ["Ultra (supersampled)", "-1.2"]],
        quality: [["Game setting", ""], ["Off (fastest)", "LOW"], ["2x", "MEDIUM"], ["4x", "HIGH"], ["8x (best)", "8X8"]],
        filter: [["Natural", "natural"], ["Vivid", "vivid"], ["Cinematic", "cinematic"], ["Bright", "bright"]]
    };
    const PRESETS = [["Battery", { dpr: "1", quality: "LOW", filter: "natural" }], ["Balanced", { dpr: "1.5", quality: "MEDIUM", filter: "natural" }],
        ["Quality", { dpr: "0", quality: "HIGH", filter: "natural" }], ["Ultra", { dpr: "-1.2", quality: "8X8", filter: "vivid" }]];

    function gfxSettings() { return Object.assign({}, DEFAULT_GFX, store.get("gfx", {})); }
    function gfxForBridge(g) {
        return { dpr: parseFloat(g.dpr) || 0, quality: g.quality, filter: g.filter, fps: g.fps, auto: g.auto, heat: g.heat, smooth: g.smooth ? 60 : 0 };
    }
    function saveGfx(g) {
        store.set("gfx", g);
        try { window.MvaBridge.setGraphics(gfxForBridge(g)); } catch (e) { }
    }

    let sheet = null;
    function openSheet(tab) {
        if (!sheet) {
            sheet = document.createElement("div");
            sheet.id = "mva-sheet";
            sheet.addEventListener("click", e => { if (e.target === sheet) closeSheet(); });
            document.body.appendChild(sheet);
        }
        store.set("sheetTab", tab);
        stat("sheet" + cap(tab));
        sheet.innerHTML = `<div class="pn"><h2>MVA<button class="x">Close</button></h2>
<div class="tabs"><button data-tab="settings">Settings</button><button data-tab="gfx">Graphics</button><button data-tab="guide">Guide</button><button data-tab="about">About</button></div>
<div class="body"></div></div>`;
        sheet.querySelector(".x").addEventListener("click", closeSheet);
        sheet.querySelectorAll(".tabs button").forEach(b => {
            b.classList.toggle("on", b.dataset.tab === tab);
            b.addEventListener("click", () => openSheet(b.dataset.tab));
        });
        const body = sheet.querySelector(".body");
        if (tab === "settings") drawSettings(body);
        else if (tab === "gfx") drawGfx(body);
        else if (tab === "guide") drawGuide(body);
        else drawAbout(body);
        sheet.style.display = "flex";
    }

    function closeSheet() {
        if (!sheet || sheet.style.display === "none") return false;
        sheet.style.display = "none";
        return true;
    }

    const CHIP_IDS = {
        dpr: { "1": "gfxDpr1", "1.5": "gfxDpr1_5", "2": "gfxDpr2", "0": "gfxDprNative", "-1.2": "gfxDprUltra" },
        quality: { "": "gfxAaGame", LOW: "gfxAaOff", MEDIUM: "gfxAa2x", HIGH: "gfxAa4x", "8X8": "gfxAa8x" },
        filter: { natural: "gfxColourNatural", vivid: "gfxColourVivid", cinematic: "gfxColourCinematic", bright: "gfxColourBright" }
    };
    function chips(key, list, g, body, after) {
        const row = document.createElement("div");
        row.className = "chips";
        for (const [label, value] of list) {
            const b = document.createElement("button");
            b.textContent = label;
            b.classList.toggle("on", String(g[key]) === value);
            b.addEventListener("click", () => {
                if (CHIP_IDS[key] && CHIP_IDS[key][value]) stat(CHIP_IDS[key][value]);
                g[key] = value; saveGfx(g); drawGfx(body); if (after) after();
            });
            row.appendChild(b);
        }
        return row;
    }

    function drawGfx(body) {
        const g = gfxSettings();
        body.innerHTML = "";
        const section = (title, hint, el) => {
            const r = document.createElement("div");
            r.className = "row";
            r.innerHTML = `<b>${title}</b>`;
            r.appendChild(el);
            if (hint) { const i = document.createElement("i"); i.textContent = hint; r.appendChild(i); }
            body.appendChild(r);
        };
        const presets = document.createElement("div");
        presets.className = "chips";
        for (const [label, p] of PRESETS) {
            const b = document.createElement("button");
            b.textContent = label;
            b.classList.toggle("on", g.dpr === p.dpr && g.quality === p.quality && g.filter === p.filter);
            b.addEventListener("click", () => { stat("gfxPreset" + label); Object.assign(g, p); saveGfx(g); drawGfx(body); });
            presets.appendChild(b);
        }
        section("Preset", "", presets);
        section("Resolution", "How many pixels the game is drawn with. Lower saves battery and heat.", chips("dpr", CHOICES.dpr, g, body));
        section("Anti-aliasing", "Smooth edges. The game's own Quality option can also change it, and Auto quality (Settings) lowers it when the game slows down.", chips("quality", CHOICES.quality, g, body));
        section("Colour", "", chips("filter", CHOICES.filter, g, body));
        const switches = document.createElement("div");
        for (const [key, label] of [["smooth", "Smooth motion: in-between pictures between the game's frames"]]) {
            const l = document.createElement("label");
            l.className = "sw";
            l.innerHTML = `<input type="checkbox"${g[key] ? " checked" : ""}><span>${label}</span>`;
            l.querySelector("input").addEventListener("change", e => { g[key] = e.target.checked; stat("gfxSmooth", g[key]); saveGfx(g); });
            switches.appendChild(l);
        }
        section("Performance", "Works only while Improve FPS (Settings) is on, and pauses itself while the phone is hot. Heat warnings, FPS meter and Auto quality are in Settings.", switches);
    }

    const DEFAULT_APP = { keepOn: true, stats: true };

    function appSettings() {
        let a = null;
        try { if (window.MvaAndroid && window.MvaAndroid.appSettings) a = JSON.parse(window.MvaAndroid.appSettings()); } catch (e) { }
        return Object.assign({}, DEFAULT_APP, a || store.get("app", {}));
    }
    function sendApp(a) {
        try { if (window.MvaAndroid && window.MvaAndroid.settings) window.MvaAndroid.settings(JSON.stringify(a)); } catch (e) { }
    }
    const GAME_ROWS = [["mvaUi", "MVA UI", "Every MVA change to the game's screens. Off = the game's own UI (the rows below keep their values)."],
        ["mvaSidebar", "Sidebar", "Big menu buttons beside the game."],
        ["mvaBigUi", "Bigger UI", "Taller rows in lists. Restart MVA to see it."],
        ["mvaSwipe", "Scrolling", "Swipe lists, shops, quests and the chat."],
        ["mvaInvUI", "Inventory", "Bigger rows, class ranks, enhancement names. Reopen the bag to see it."],
        ["mvaClassRating", "Star Rating", "Community ratings on classes. Reopen the bag to see it."],
        ["mvaAuras", "Improved Auras", "Aura windows for you and your target (shown while auras are up)."],
        ["mvaDrops", "Drops", "Drops wait in the Drops panel instead of popping up (shown when loot drops)."],
        ["mvaImproveFps", "Improve FPS", "Smoother, steadier frames (not part of MVA UI)."]];

    function swRow(label, hint, on, onChange, dim) {
        const l = document.createElement("label");
        l.className = "sw" + (dim ? " dim" : "");
        l.innerHTML = `<input type="checkbox"${on ? " checked" : ""}><span><b>${label}</b>${hint ? `<i>${hint}</i>` : ""}</span>`;
        l.querySelector("input").addEventListener("change", e => onChange(e.target.checked));
        return l;
    }

    let headlessEl = null;
    function enterHeadless() {
        if (headlessEl) return;
        closeSheet();
        headlessEl = document.createElement("div");
        headlessEl.id = "mva-headless";
        headlessEl.style.cssText = "position:fixed;inset:0;z-index:2147483000;background:#000;display:flex;" +
            "align-items:center;justify-content:center;touch-action:none;user-select:none;-webkit-user-select:none";
        const hint = document.createElement("div");
        hint.textContent = "Headless mode · tap anywhere to show the game";
        hint.style.cssText = "color:rgba(200,184,154,.6);font:14px Inter,system-ui,sans-serif;transition:opacity .6s";
        headlessEl.appendChild(hint);
        setTimeout(() => { hint.style.opacity = "0"; }, 3000);
        const wake = e => { e.preventDefault(); e.stopPropagation(); exitHeadless(); };
        headlessEl.addEventListener("pointerdown", wake, true);
        headlessEl.addEventListener("click", e => { e.preventDefault(); e.stopPropagation(); }, true);
        document.body.appendChild(headlessEl);
        try { window.MvaBridge.setHeadless(true); } catch (e) { }
    }
    function exitHeadless() {
        if (!headlessEl) return;
        const el = headlessEl;
        headlessEl = null;

        setTimeout(() => el.remove(), 350);
        try { window.MvaBridge.setHeadless(false); } catch (e) { }
    }
    window.MvaHeadless = { enter: enterHeadless, exit: exitHeadless, active: () => !!headlessEl };

    function drawSettings(body) {
        body.innerHTML = "";
        const hb = document.createElement("button");
        hb.className = "headless";
        hb.textContent = "Headless mode — black screen, tap anywhere to wake";
        hb.style.cssText = "display:block;width:100%;min-height:48px;margin:0 0 12px;border-radius:10px;border:1px solid #C9A447;" +
            "background:linear-gradient(#7A1717,#3F0A0A);color:#FFF4C0;font:700 15px Inter,system-ui,sans-serif";
        hb.addEventListener("click", e => { e.preventDefault(); stat("headlessButton"); enterHeadless(); });
        body.appendChild(hb);

        const gb = document.createElement("button");
        gb.className = "gameopts";
        gb.textContent = "Game options — controls, smoother game, screen";
        gb.style.cssText = "display:block;width:100%;min-height:48px;margin:0 0 12px;border-radius:10px;border:1px solid #C9A447;" +
            "background:linear-gradient(#5C3C12,#2A1A06);color:#FFF4C0;font:700 15px Inter,system-ui,sans-serif";
        gb.addEventListener("click", e => { e.preventDefault(); closeSheet(); stat("setGameOptions"); try { window.__gameOpts.open(); } catch (err) { } });
        body.appendChild(gb);

        const qb = gb.cloneNode(false);
        qb.className = "quick";
        qb.textContent = "Quick actions & travel";
        qb.addEventListener("click", e => { e.preventDefault(); closeSheet(); stat("setQuick"); try { window.__quick.open(); } catch (err) { } });
        body.appendChild(qb);
        const section = (title, hint) => {
            const r = document.createElement("div");
            r.className = "row";
            r.innerHTML = `<b>${title}</b>`;
            if (hint) { const i = document.createElement("i"); i.textContent = hint; r.appendChild(i); }
            body.appendChild(r);
            return r;
        };
        const g = gfxSettings();
        const phone = section("This phone", "");
        phone.appendChild(swRow("Heat warnings", "A small pill over the game when the phone runs warm or hot.", g.heat, v => { g.heat = v; stat("setHeat", v); saveGfx(g); }));
        phone.appendChild(swRow("Show FPS", "The game's frame rate in the corner.", g.fps, v => { g.fps = v; stat("setFps", v); saveGfx(g); }));
        phone.appendChild(swRow("Auto quality", "Lower graphics only while the game can't hold its frame rate.", g.auto, v => { g.auto = v; stat("setAuto", v); saveGfx(g); }));
        const a = appSettings();
        phone.appendChild(swRow("Keep screen on", "The screen stays on while MVA is open.", a.keepOn, v => { a.keepOn = v; stat("setKeepOn", v); store.set("app", a); sendApp({ keepOn: v }); }));
        phone.appendChild(swRow("Send anonymous usage stats", "App version, phone model, memory and chip, country, play time, frame rate, memory use, heat, and which buttons and switches are used. No names, logins or chat.",
            a.stats, v => {
                a.stats = v; store.set("app", a); sendApp({ stats: v });

                if (v) stat("setStats", true);
            }));

        const game = section("Game screens", "The same switches as the MVA rows in the game's Options (Controls).");
        let opts = null;
        try { opts = JSON.parse(call("mvaOptions") || "null"); } catch (e) { opts = null; }
        if (!opts || !opts.ready) {
            const n = document.createElement("i");
            n.textContent = "Start the game (log in) to change these; the game keeps them in its own settings.";
            game.appendChild(n);
            return;
        }
        for (const [key, label, hint] of GAME_ROWS) {
            const dim = key !== "mvaUi" && key !== "mvaImproveFps" && opts.mvaUi === false;
            game.appendChild(swRow(label, hint + (dim ? " (MVA UI is off)" : ""), opts[key] !== false, v => {
                call("mvaSetOption", key, v);
                setTimeout(() => { if (sheet && sheet.style.display !== "none") drawSettings(body); }, 150);
            }, dim));
        }
    }

    function drawGuide(body) {
        if (window.MvaGuide) window.MvaGuide.draw(body, HELP_LINE);
        else body.innerHTML = HELP_LINE;
        helpLinks(body);
    }

    function drawAbout(body) {
        if (window.MvaAbout) window.MvaAbout.draw(body, helpLinks);
        else { body.innerHTML = HELP_LINE; helpLinks(body); }
    }

    const HELP_URL = "https://discord.gg/Dwb7XMkpSh";
    const HELP_LINE = `<p><b>Help and community</b>: <a class="help" href="${HELP_URL}" style="color:#F7C948;text-decoration:underline">discord.gg/Dwb7XMkpSh</a></p>`;
    function helpLinks(body) {
        body.querySelectorAll("a.help").forEach(a => a.addEventListener("click", e => {
            e.preventDefault();
            const url = a.getAttribute("href");
            try { if (window.MvaStat) window.MvaStat(a.dataset.stat || "helpDiscord"); } catch (err) { }
            try {
                if (window.MvaAndroid && window.MvaAndroid.openLink) window.MvaAndroid.openLink(url);
                else window.open(url, "_blank", "noopener");
            } catch (err) { }
        }));
    }

    function updateDrops(e) {
        if (!dropsBtn) return;
        let n = 0;
        try {
            let list = e && e.detail;
            while (Array.isArray(list) && list.length === 1 && Array.isArray(list[0])) list = list[0];
            if (typeof list === "string") list = JSON.parse(list);
            n = Array.isArray(list) ? list.length : 0;
        } catch (err) { n = 0; }
        let badge = dropsBtn.querySelector(".n");
        if (n > 0) {
            if (!badge) { badge = document.createElement("span"); badge.className = "n"; dropsBtn.appendChild(badge); }
            badge.textContent = n;
        } else if (badge) badge.remove();
    }

    window.MvaRails = {
        init(caller) { ruffleCall = caller; build(); },
        graphics: () => gfxForBridge(gfxSettings()),
        back: () => closeSheet() || !!(window.__quick && window.__quick.back()) || (window.MvaOverlays && window.MvaOverlays.back ? window.MvaOverlays.back() : false),
        layout
    };
    window.addEventListener("resize", layout);
    window.addEventListener("mvaoption", e => { if (e.detail && (e.detail.key === "mvaSidebar" || e.detail.key === "mvaUi")) layout(); });
    window.addEventListener("mvadrops", updateDrops);
})();
