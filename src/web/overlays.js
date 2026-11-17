(function () {
    "use strict";

    let getPlayer = () => null;

    const stat = (id, on) => { try { if (window.MvaStat) window.MvaStat(id, on); } catch (e) { } };
    const store = {
        get(k, d) { try { const v = localStorage.getItem("mva." + k); return v === null ? d : JSON.parse(v); } catch (e) { return d; } },
        set(k, v) { try { localStorage.setItem("mva." + k, JSON.stringify(v)); } catch (e) { } }
    };

    function css() {
        if (document.getElementById("mva-style")) return;
        const s = document.createElement("style");
        s.id = "mva-style";
        s.textContent = `
#mva-menu { position: fixed; inset: 0; z-index: 40; display: flex; align-items: center; justify-content: center;
  background: rgba(0,0,0,.35); }
#mva-menu .pn { min-width: 230px; max-width: 80vw; max-height: 92vh; overflow-y: auto; padding: 10px;
  background: rgba(22, 17, 12, 0.96); border: 1px solid #8A6A2E; border-radius: 12px; box-shadow: 0 4px 18px rgba(0,0,0,.6); }
#mva-menu .tt { color: #E8C15A; font: 700 14px Inter, system-ui, sans-serif; margin: 0 4px 8px; letter-spacing: .3px; text-align: center; }
#mva-menu .gr { display: grid; grid-template-columns: 1fr; gap: 7px; }
#mva-menu .gr.two { grid-template-columns: 1fr 1fr; }
#mva-menu button { min-height: 44px; padding: 0 16px; border-radius: 9px; border: 1px solid #8A6A2E;
  background: linear-gradient(#3A2D1E, #2A2016); color: #F2E8D2; font: 600 16px Inter, system-ui, sans-serif; text-align: center; }
#mva-menu button:active { background: #5A4528; }
#mva-menu button:disabled { opacity: .38; }
#mva-menu button.close { color: #C8B89A; font-weight: 500; }
#mva-menu button.mva-add { border-color: #C9A447; }
.mva-tag { display: inline-block; margin-left: 5px; padding: 1px 4px 0; border-radius: 4px; vertical-align: super;
  font: 800 9px/1.1 Inter, system-ui, sans-serif; letter-spacing: .4px; color: #1A140E;
  background: linear-gradient(#F3D27A, #C9963A); border: 1px solid #FFE9A8; box-shadow: 0 0 4px rgba(232,193,90,.6); }
#mva-heat { position: fixed; z-index: 35; top: 8px; left: 50%; transform: translateX(-50%); max-width: min(560px, 86vw);
  display: flex; gap: 9px; align-items: flex-start; padding: 8px 12px; border-radius: 10px; color: #F2E8D2;
  font: 13px/1.35 Inter, system-ui, sans-serif; box-shadow: 0 3px 12px rgba(0,0,0,.55); user-select: none; -webkit-user-select: none;
  background: rgba(60, 38, 8, 0.94); border: 1px solid #D89A2B; transition: opacity .4s; }
#mva-heat.hot { background: rgba(70, 14, 10, 0.95); border-color: #FF6B4A; }
#mva-heat.ok { background: rgba(14, 44, 22, 0.94); border-color: #5FBF6A; }
#mva-heat .ic { font-size: 18px; line-height: 1; flex: none; margin-top: 1px; }
#mva-heat b { color: #FFD27A; }
#mva-heat.hot b { color: #FF9C80; }
#mva-heat.ok b { color: #9BE59F; }
#mva-heat .x { flex: none; margin-left: 4px; color: #C8B89A; font-weight: 700; }
#mva-drops { position: fixed; z-index: 38; left: 50%; top: 50%; transform: translate(-50%, -50%); width: min(760px, 96vw);
  height: min(520px, 92vh); display: flex; flex-direction: column; background: rgba(22,17,12,.96); border: 1px solid #8A6A2E;
  border-radius: 14px; box-shadow: 0 4px 18px rgba(0,0,0,.6); color: #F2E8D2; font: 14px Inter, system-ui, sans-serif;
  user-select: none; -webkit-user-select: none; }
#mva-drops .hd, #mva-drops .ft { display: flex; align-items: center; gap: 8px; padding: 8px 10px 8px 14px; flex-wrap: wrap; }
#mva-drops .hd { border-bottom: 1px solid rgba(138,106,46,.5); }
#mva-drops .ft { border-top: 1px solid rgba(138,106,46,.5); }
#mva-drops .tt { font: 700 18px system-ui; color: #E8C15A; flex: 1; min-width: 120px; }
#mva-drops .tt small { font: 500 12px system-ui; color: #C8B89A; margin-left: 6px; }
#mva-drops .grow { flex: 1; color: #C8B89A; font-size: 13px; }
#mva-drops button { min-height: 42px; padding: 0 12px; border-radius: 9px; border: 1px solid #8A6A2E;
  background: linear-gradient(#3A2D1E, #2A2016); color: #F2E8D2; font: 600 14px system-ui; }
#mva-drops button:active { filter: brightness(1.3); }
#mva-drops button:disabled { opacity: .38; }
#mva-drops button.ok { border-color: #4E9A4A; background: linear-gradient(#2F5A2A, #22421F); }
#mva-drops button.no { border-color: #A0432E; background: linear-gradient(#5E2418, #43190F); }
#mva-drops button.on { background: #5A4528; }
#mva-drops button.sq { width: 42px; padding: 0; font-size: 18px; }
#mva-drops .list { flex: 1; overflow-y: auto; padding: 8px 10px; display: grid; gap: 8px; align-content: start;
  grid-template-columns: 1fr; -webkit-overflow-scrolling: touch; }
#mva-drops .row { min-width: 0; display: flex; align-items: center; gap: 9px; padding: 7px 7px 7px 9px; border-radius: 10px;
  background: rgba(255,255,255,.04); border: 1px solid rgba(138,106,46,.35); }
#mva-drops .row.picked { border-color: #E8C15A; background: rgba(232,193,90,.12); }
#mva-drops .ck { width: 26px; height: 26px; border-radius: 7px; border: 2px solid #8A6A2E; flex: none; display: flex;
  align-items: center; justify-content: center; color: #2A2016; font: 900 16px system-ui; }
#mva-drops .picked .ck { background: #E8C15A; border-color: #E8C15A; }
#mva-drops .ic { width: 40px; height: 40px; border-radius: 8px; flex: none; display: flex; align-items: center;
  justify-content: center; font-size: 20px; background: #2A2016; border: 2px solid #8A6A2E; }
#mva-drops .ic.ac { border-color: #E8C15A; } #mva-drops .ic.mem { border-color: #8E6BE0; }
#mva-drops .nm { flex: 1; min-width: 0; }
#mva-drops .nm .l1 { display: flex; align-items: center; min-width: 0; }
#mva-drops .nm b { font: 600 15px system-ui; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; min-width: 0; }
#mva-drops .tag { flex: none; }
#mva-drops .nm span { font-size: 12px; color: #C8B89A; }
#mva-drops .nm .q { font: 700 13px monospace; color: #E8C15A; }
#mva-drops .tag { font: 700 10px system-ui; padding: 1px 5px; border-radius: 4px; margin-left: 5px; vertical-align: 2px; }
#mva-drops .tag.ac { background: #E8C15A; color: #2A2016; } #mva-drops .tag.mem { background: #6B4BB0; color: #fff; }
#mva-drops .ic.art { background: #2A2016 center/86% no-repeat; border: 2px solid #C9A447; }
#mva-drops .acmark { font: italic 800 13px Georgia, serif; color: #E8C15A; margin-right: 5px; flex: none; }
#mva-drops button.aqw { min-height: 38px; padding: 0 14px; border-radius: 7px; border: 2px solid #E8B04A; color: #fff;
  font: 700 14px system-ui; background: linear-gradient(#D8392A, #8E1A10); box-shadow: inset 0 1px 0 rgba(255,255,255,.25); }
#mva-drops button.aqw.arm { background: linear-gradient(#FF7A3A, #B8400E); }
#mva-drops button.blk { width: 40px; min-height: 38px; padding: 0; border-radius: 7px; border: 2px solid #E8B04A;
  background: linear-gradient(#D8392A, #8E1A10); color: #fff; font: 700 20px system-ui; }
#mva-drops button.blk.arm { background: linear-gradient(#FF7A3A, #B8400E); font-size: 12px; }
#mva-drops .warn { margin: 8px 10px 0; padding: 7px 10px; border-radius: 8px; background: rgba(70,38,8,.92);
  border: 1px solid #D89A2B; color: #FFD27A; font: 600 13px system-ui; }
#mva-drops .empty { grid-column: 1 / -1; text-align: center; color: #9A8F7A; padding: 40px 10px; font-size: 15px; }
#mva-drops .sw { display: inline-flex; align-items: center; gap: 8px; font: 600 13px system-ui; }
#mva-drops .sw i { width: 38px; height: 22px; border-radius: 11px; background: #554836; position: relative; display: inline-block; }
#mva-drops .sw i::after { content: ""; position: absolute; left: 3px; top: 3px; width: 16px; height: 16px; border-radius: 50%; background: #C8B89A; }
#mva-drops .sw.yes i { background: #4E9A4A; } #mva-drops .sw.yes i::after { left: auto; right: 3px; background: #fff; }
#mva-drops .toast { position: absolute; left: 50%; bottom: 70px; transform: translateX(-50%); background: #5E2418;
  border: 1px solid #A0432E; padding: 8px 14px; border-radius: 9px; font-weight: 600; }
`;
        document.head.appendChild(s);
    }

    function esc(t) { return String(t || "").replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c])); }

    let menuEl = null;

    function ruffle() { const p = getPlayer(); return p && p.ruffle(); }

    function closeMenu(tellGame) {
        if (menuEl) { menuEl.remove(); menuEl = null; }
        if (tellGame) { try { ruffle().callExternalInterface("mvaMenuClose"); } catch (e) { } }
    }

    function openCharPage(title) {
        const read = path => { try { const v = ruffle().callExternalInterface("getGameObject", path); return v ? JSON.parse(v) : null; } catch (e) { return null; } };

        const name = title === "You" || title === "Your Hero" ? read("world.myAvatar.objData.strUsername")
            : read("world.myAvatar.target.objData.strUsername") || read("world.myAvatar.target.pnm");
        if (!name) return false;
        location.assign("https://account.aq.com/CharPage?id=" + encodeURIComponent(String(name)));
        return true;
    }

    function menu(args) {
        let v = args;
        while (Array.isArray(v)) v = v[0];

        let items = [], given = "";
        try {
            const parsed = v ? JSON.parse(String(v)) : [];
            if (Array.isArray(parsed)) items = parsed;
            else if (parsed && Array.isArray(parsed.items)) { items = parsed.items; given = String(parsed.title || ""); }
        } catch (e) { items = []; }
        if (!items.length) { closeMenu(false); return; }
        css();
        closeMenu(false);
        stat("bigMenu");
        const labels = items.map(i => String(i.t));
        const title = given ? given
            : labels.includes("Char Page") && labels.includes("Reputation") ? "You"
            : labels.includes("View Drops") ? "Monster"
            : labels.some(t => /whisper|friend|party|go ?to/i.test(t)) ? "Player" : "Menu";
        menuEl = document.createElement("div");
        menuEl.id = "mva-menu";
        const pn = document.createElement("div");
        pn.className = "pn";
        pn.innerHTML = `<div class="tt">${esc(title)}</div>`;
        const grid = document.createElement("div");
        grid.className = "gr" + (items.length > 6 ? " two" : "");
        for (const it of items) {
            const b = document.createElement("button");
            b.textContent = it.t;
            b.disabled = !it.on;
            if (/^close$/i.test(it.t)) b.className = "close";
            b.addEventListener("click", e => {
                e.stopPropagation();
                stat("bigMenuClick");

                if (/^char(acter)? ?page$/i.test(it.t) && openCharPage(title)) { closeMenu(true); return; }
                try { ruffle().callExternalInterface("mvaMenuClick", it.i); } catch (err) { }
                closeMenu(false);
            });
            grid.appendChild(b);
        }

        if (!given && (title === "You" || title === "Monster" || title === "Player") && window.MvaAuras &&
            !(window.__mvaOpts && window.__mvaOpts.mvaAuras === false)) {
            const b = document.createElement("button");
            b.className = "mva-add";
            b.innerHTML = `Show Auras<sup class="mva-tag">MVA</sup>`;
            b.addEventListener("click", e => {
                e.stopPropagation();
                closeMenu(true);
                stat("menuShowAuras");
                window.MvaAuras.show(title === "You" ? "me" : "t");
            });
            const close = grid.querySelector("button.close");
            grid.insertBefore(b, close || null);
        }
        pn.appendChild(grid);
        pn.addEventListener("click", e => e.stopPropagation());
        menuEl.appendChild(pn);

        menuEl.addEventListener("click", () => closeMenu(true));
        document.body.appendChild(menuEl);
    }

    let heatEl = null, heatShown = "ok", heatDismissed = "ok", heatTimer = 0;
    const heatRank = { ok: 0, warm: 1, hot: 2 };

    function hideHeat() {
        clearTimeout(heatTimer);
        if (heatEl) { heatEl.remove(); heatEl = null; }
    }

    function showHeat(kind, html, autoHideMs) {
        css();
        hideHeat();
        heatEl = document.createElement("div");
        heatEl.id = "mva-heat";
        heatEl.className = kind;
        heatEl.innerHTML = `<span class="ic">${kind === "ok" ? "\u2714" : "\u{1F321}"}</span><span>${html}</span><span class="x">\u2715</span>`;
        heatEl.addEventListener("click", () => { stat("heatDismiss"); heatDismissed = heatShown; hideHeat(); });
        document.body.appendChild(heatEl);
        if (autoHideMs) heatTimer = setTimeout(hideHeat, autoHideMs);
    }

    function heat(m) {
        const kind = m.heat || "ok";
        const temp = Number(m.battery) > 0 ? ` (${Number(m.battery).toFixed(1)}\u00B0C)` : "";
        if (kind === "ok") {
            if (heatShown !== "ok" && m.battery !== undefined)
                showHeat("ok", "<b>Phone cooled down.</b> Graphics are back to your settings.", 5000);
            else if (m.battery === undefined) hideHeat();
            heatShown = "ok"; heatDismissed = "ok";
            return;
        }

        const warmLabel = Number(m.battery) >= 40.5 ? `Phone is warm${temp}.` : "Phone is heating up.";
        if (kind === heatShown && heatEl) {
            heatEl.querySelector("b").textContent = kind === "hot" ? `Phone is hot${temp}.` : warmLabel;
            return;
        }
        const worse = heatRank[kind] > heatRank[heatShown];
        heatShown = kind;
        if (!worse && heatRank[heatDismissed] >= heatRank[kind]) return;
        if (kind === "hot")
            showHeat("hot", `<b>Phone is hot${temp}.</b> ` + (m.lowered ? "Cooler mode is on: lighter graphics and steadier clocks until it is back under 45\u00B0C. " : "") +
                "Expect a lower frame rate. A short break, unplugging the charger or taking off the case helps.");
        else
            showHeat("warm", `<b>${warmLabel}</b> Still full speed; at 47\u00B0C MVA switches to a cooler mode and the frame rate may drop.`, 12000);
    }

    let drops = [], dropsEl = null, dropsSelect = false, dropsPicked = new Set(), dropsView = "list", declineArm = 0;
    const blocked = new Set(store.get("dropsBlocked", []));
    let keepAC = store.get("dropsKeepAC", false);
    let askDecline = store.get("dropsAskDecline", false);
    let armed = "";
    let armTimer = 0;
    const dropArt = {};

    function artUrl(name) {
        if (!name) return "";
        if (name in dropArt) return dropArt[name];
        let url = "";
        try {
            const v = String(ruffle().callExternalInterface("mvaAuraIcon", name, 64) || "");
            const i = v.indexOf(":");
            if (i > 0) {
                const size = +v.slice(0, i), bin = atob(v.slice(i + 1));
                const c = document.createElement("canvas");
                c.width = c.height = size;
                const ctx = c.getContext("2d"), img = ctx.createImageData(size, size);
                for (let p = 0; p + 3 < bin.length; p += 4) {
                    img.data[p] = bin.charCodeAt(p + 1); img.data[p + 1] = bin.charCodeAt(p + 2);
                    img.data[p + 2] = bin.charCodeAt(p + 3); img.data[p + 3] = bin.charCodeAt(p);
                }
                ctx.putImageData(img, 0, 0);
                url = c.toDataURL();
            }
        } catch (e) { url = ""; }
        dropArt[name] = url;
        return url;
    }

    function arm(key) {
        clearTimeout(armTimer);
        armed = key;
        armTimer = setTimeout(() => { armed = ""; if (dropsEl) drawDrops(); }, 3000);
    }
    const typeGlyph = t => /sword|axe|dagger|mace|polearm|staff|wand|gun|bow|whip|gauntlet/i.test(t) ? "\u2694"
        : /armor|class/i.test(t) ? "\u{1F6E1}" : /helm/i.test(t) ? "\u{1FA96}" : /cape/i.test(t) ? "\u{1F9E3}"
        : /pet/i.test(t) ? "\u{1F43E}" : /house|floor|wall/i.test(t) ? "\u{1F3E0}" : "\u25C6";

    function dropsCall(fn, id) {
        try { return ruffle().callExternalInterface(fn, id); } catch (e) { return ""; }
    }

    function gameGet(path) {
        try {
            const v = ruffle().callExternalInterface("getGameObject", path);
            return v == null || v === "null" ? null : JSON.parse(v);
        } catch (e) { return null; }
    }
    function gameSet(path, v) {
        try { ruffle().callExternalInterface("setGameObject", path, v); return true; } catch (e) { return false; }
    }
    function gameFlush() {
        try { ruffle().callExternalInterface("callGameFunction", "litePreference.flush"); } catch (e) { }
    }

    function nativeBlockList() {
        const l = gameGet("litePreference.data.blackList");
        return Array.isArray(l) ? l : [];
    }
    function blockNative(d) {
        const list = nativeBlockList();
        if (list.some(b => Number(b && b.value) === d.id)) return;
        list.push({ label: String(d.n).toUpperCase(), value: d.id });
        if (gameSet("litePreference.data.blackList", list)) gameFlush();
    }
    function unblockNative(name) {
        const up = String(name).toUpperCase(), list = nativeBlockList();
        const left = list.filter(b => String(b && b.label).toUpperCase() !== up);
        if (left.length !== list.length && gameSet("litePreference.data.blackList", left)) gameFlush();
    }
    function blockedNames() {
        const names = new Set(blocked);
        for (const b of nativeBlockList()) if (b && b.label) names.add(String(b.label).toLowerCase());
        return [...names];
    }

    function readWarnDecline() {
        const w = gameGet("litePreference.data.dOptions.warnDecline");
        if (w === true || w === false) askDecline = w;
    }
    function setWarnDecline(on) {
        askDecline = on;
        if (gameSet("litePreference.data.dOptions.warnDecline", on)) gameFlush();
        saveRules();
    }

    function declineAll() {
        try {
            if (ruffle().callExternalInterface("callGameFunction", "cDropsUI.onUpdate") !== "null") return;
        } catch (e) { }
        decline(drops.map(d => d.id));
    }

    function keep(ids) {
        let full = false;
        for (const id of ids) if (dropsCall("mvaDropAccept", id) === "full") full = true;

        if (full) setTimeout(() => dropsToast("Your bag is full: make room, then tap Keep again."), 0);
    }

    function decline(ids) {
        for (const id of ids) dropsCall("mvaDropDecline", id);
    }

    function saveRules() {
        store.set("dropsBlocked", [...blocked]);
        store.set("dropsKeepAC", keepAC);
        store.set("dropsAskDecline", askDecline);
    }

    function dropsList(args) {
        let v = args;
        while (Array.isArray(v)) v = v[0];
        try { drops = JSON.parse(String(v || "[]")); } catch (e) { drops = []; }
        const auto = [], autoKeep = [];
        for (const d of drops) {
            if (blocked.has(d.n.toLowerCase())) { auto.push(d.id); blockNative(d); }
            else if (keepAC && d.ac) autoKeep.push(d.id);
        }
        if (auto.length) decline(auto);
        if (autoKeep.length) keep(autoKeep);
        const ids = new Set(drops.map(d => d.id));
        for (const id of [...dropsPicked]) if (!ids.has(id)) dropsPicked.delete(id);
        if (dropsEl) drawDrops();
    }

    function dropsToast(text) {
        if (!dropsEl) return;
        const old = dropsEl.querySelector(".toast");
        if (old) old.remove();
        const t = document.createElement("div");
        t.className = "toast";
        t.textContent = text;
        dropsEl.appendChild(t);
        setTimeout(() => t.remove(), 3500);
    }

    function closeDrops() {
        if (dropsEl) { dropsEl.remove(); dropsEl = null; }
        dropsSelect = false; dropsPicked.clear(); dropsView = "list";
    }

    function toggleDrops() {
        if (dropsEl) { closeDrops(); return; }
        css();
        stat("dropsOpen");
        if (menuEl) closeMenu(true);
        dropsEl = document.createElement("div");
        dropsEl.id = "mva-drops";
        dropsEl.addEventListener("click", onDropsClick);
        readWarnDecline();
        document.body.appendChild(dropsEl);
        drawDrops();
    }

    function drawDrops() {
        const n = drops.length, picked = dropsPicked.size;
        if (dropsView === "blocked") {
            const names = blockedNames().sort();
            dropsEl.innerHTML = `<div class="hd"><div class="tt">Auto-decline list<small>${names.length} name${names.length === 1 ? "" : "s"}, declined as soon as they drop</small></div>
                <button data-a="back">\u2190 Back</button><button class="sq" data-a="close">\u2715</button></div>
                <div class="list">${names.length ? names.map(nm => `<div class="row"><div class="nm"><b>${esc(nm)}</b></div>
                <button class="no" data-a="unblock" data-n="${esc(nm)}">Remove</button></div>`).join("")
                : `<div class="empty">Nothing here yet. In Select mode, pick drops and tap \u201CAlways decline\u201D.</div>`}</div>`;
            return;
        }

        const rows = drops.map(d => {
            const art = artUrl(d.i);
            const icon = art ? `<div class="ic art" style="background-image:url(${art})"></div>`
                : `<div class="ic${d.ac ? " ac" : d.mem ? " mem" : ""}">${typeGlyph(d.t)}</div>`;
            const dArm = armed === "decline:" + d.id, bArm = armed === "block:" + d.id;
            return `<div class="row${dropsPicked.has(d.id) ? " picked" : ""}" data-id="${d.id}">
            ${dropsSelect ? `<div class="ck">${dropsPicked.has(d.id) ? "\u2713" : ""}</div>` : ""}
            ${icon}
            <div class="nm"><div class="l1">${d.ac ? '<span class="acmark">AC</span>' : ""}<b>${esc(d.n)}</b>${d.mem ? '<span class="tag mem">MEMBER</span>' : ""}</div>
            <span>${esc(d.t)} \u00B7 <span class="q">\u00D7${d.q}</span></span></div>
            ${dropsSelect ? "" : `<button class="aqw" data-a="keep" data-id="${d.id}">Accept</button>
            <button class="aqw${dArm ? " arm" : ""}" data-a="decline" data-id="${d.id}">${dArm ? "Sure?" : "Decline"}</button>
            <button class="aqw" data-a="preview" data-id="${d.id}">Preview</button>
            <button class="blk${bArm ? " arm" : ""}" data-a="block" data-id="${d.id}" title="Always decline this item">${bArm ? "Sure?" : "\u2298"}</button>`}
            </div>`;
        }).join("");
        const over = drops.filter(d => d.q > 100).length;
        const warn = over ? `<div class="warn">\u26A0 ${over} drop${over === 1 ? " is" : "s are"} over the game\u2019s 100\u00D7 limit: keep or decline ${over === 1 ? "it" : "them"} before the game bugs out.</div>` : "";
        dropsEl.innerHTML = `<div class="hd"><div class="tt">Drops<small>${n} waiting \u00B7 kept here instead of popping up</small></div>
            <button class="${dropsSelect ? "on" : ""}" data-a="select" ${n ? "" : "disabled"}>\u2611 Select</button>
            <button class="ok" data-a="keepall" ${n ? "" : "disabled"}>\u2714 Keep all</button>
            <button class="no" data-a="declineall" ${n ? "" : "disabled"}>${declineArm ? "Tap again to decline " + n : "\u2716 Decline all"}</button>
            <button class="sq" data-a="close">\u2715</button></div>
            ${warn}<div class="list">${rows || '<div class="empty">No drops waiting. New ones land here instead of covering the game.</div>'}</div>
            <div class="ft"><span class="grow">${dropsSelect ? picked + " selected" : "Tip: Select lets you keep or decline several at once."}</span>
            ${dropsSelect ? "" : `<span class="sw${askDecline ? " yes" : ""}" data-a="askdecline"><i></i>Ask before declining</span>
            <span class="sw${keepAC ? " yes" : ""}" data-a="keepac"><i></i>Always keep AC items</span>
            <button data-a="blocked">\u26D4 Auto-decline list (${blockedNames().length})</button>`}
            ${dropsSelect ? `<button data-a="blocksel" ${picked ? "" : "disabled"}>\u26D4 Always decline</button>
            <button class="ok" data-a="keepsel" ${picked ? "" : "disabled"}>\u2714 Keep ${picked}</button>
            <button class="no" data-a="declinesel" ${picked ? "" : "disabled"}>\u2716 Decline ${picked}</button>` : ""}</div>`;
    }

    function onDropsClick(e) {
        e.stopPropagation();
        const el = e.target.closest("[data-a], .row[data-id]");
        if (!el) return;
        const a = el.dataset.a, id = Number(el.dataset.id);
        if (a !== "declineall") declineArm = 0;
        const DROP_IDS = { keep: "dropKeep", decline: "dropDecline", preview: "dropPreview", block: "dropBlock", select: "dropsSelect",
            keepall: "dropsKeepAll", declineall: "dropsDeclineAll", keepsel: "dropsKeepSel", declinesel: "dropsDeclineSel",
            blocksel: "dropsBlockSel", blocked: "dropsBlockedView", unblock: "dropsUnblock" };
        if (DROP_IDS[a]) stat(DROP_IDS[a]);
        switch (a) {
            case "close": closeDrops(); return;
            case "keep": keep([id]); break;
            case "decline":
                if (askDecline && armed !== "decline:" + id) { arm("decline:" + id); break; }
                armed = ""; decline([id]);
                break;
            case "preview":

                dropsCall("mvaDropPreview", id);
                closeDrops();
                return;
            case "block": {
                if (askDecline && armed !== "block:" + id) { arm("block:" + id); break; }
                armed = "";
                const d = drops.find(x => x.id === id);
                if (d) { blocked.add(d.n.toLowerCase()); saveRules(); blockNative(d); }
                decline([id]);
                break;
            }
            case "askdecline": setWarnDecline(!askDecline); stat("dropsAskDecline", askDecline); break;
            case "select": dropsSelect = !dropsSelect; dropsPicked.clear(); break;
            case "keepall": keep(drops.map(d => d.id)); break;
            case "declineall":

                if (!declineArm) { declineArm = setTimeout(() => { declineArm = 0; if (dropsEl) drawDrops(); }, 3000); break; }
                clearTimeout(declineArm); declineArm = 0;
                declineAll();
                break;
            case "keepsel": keep([...dropsPicked]); dropsPicked.clear(); break;
            case "declinesel": decline([...dropsPicked]); dropsPicked.clear(); break;
            case "blocksel":
                for (const d of drops) if (dropsPicked.has(d.id)) { blocked.add(d.n.toLowerCase()); blockNative(d); }
                saveRules();
                decline([...dropsPicked]); dropsPicked.clear();
                break;
            case "keepac":
                keepAC = !keepAC; saveRules();
                stat("dropsKeepAC", keepAC);
                if (keepAC) keep(drops.filter(d => d.ac).map(d => d.id));
                break;
            case "blocked": dropsView = "blocked"; break;
            case "back": dropsView = "list"; break;
            case "unblock": blocked.delete(el.dataset.n); saveRules(); unblockNative(el.dataset.n); break;
            default:

                if (dropsSelect && el.classList.contains("row")) {
                    if (dropsPicked.has(id)) dropsPicked.delete(id); else dropsPicked.add(id);
                } else return;
        }
        if (dropsEl) drawDrops();
    }

    window.MvaOverlays = {
        init(playerGetter) { getPlayer = playerGetter; },
        menu,
        heat,
        dropsList,
        toggleDrops,
    };
})();
