(function () {
    "use strict";

    const CSS = `
#mva-sheet .gd .go { display: block; width: 100%; min-height: 46px; margin: 2px 0 6px; border-radius: 10px; border: 1px solid #C9A447;
  background: linear-gradient(#7A1717, #3F0A0A); color: #FFF4C0; font: 700 15px Inter, system-ui, sans-serif; }
#mva-sheet .gd .lk { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 6px; margin: 0 0 6px; }
#mva-sheet .gd .lk a { display: flex; align-items: center; justify-content: center; min-height: 42px; padding: 4px 8px; border-radius: 9px;
  border: 1px solid #8C6A2B; background: #2A1D10; color: #F7C948; font: 600 13px Inter, system-ui, sans-serif; text-decoration: none; }
#mva-sheet .gd .lk a:active { background: linear-gradient(#7A1717, #3F0A0A); color: #FFF4C0; border-color: #C9A447; }
#mva-sheet .gd .back { min-height: 40px; padding: 0 14px; margin: 0 0 4px; border-radius: 9px; border: 1px solid #8C6A2B;
  background: #2A1D10; color: #F7C948; font: 600 13px Inter, system-ui, sans-serif; }
#mva-sheet .gd .sum { margin: 0 0 10px; padding: 9px 12px; border-radius: 10px; border: 1px solid; }
#mva-sheet .gd .sum strong { display: block; margin-bottom: 3px; font: 800 16px Inter, system-ui, sans-serif; }
#mva-sheet .gd .sum p, #mva-sheet .gd .sum ol { margin-bottom: 3px; color: #EAD9A8; }
#mva-sheet .gd .sum.v0 { border-color: #FF7A6B; background: rgba(255,122,107,.10); }
#mva-sheet .gd .sum.v1 { border-color: #FFAE57; background: rgba(255,174,87,.10); }
#mva-sheet .gd .sum.v2 { border-color: #8BE28B; background: rgba(139,226,139,.10); }
#mva-sheet .gd .v0, #mva-sheet .gd .sum.v0 strong { color: #FF7A6B; }
#mva-sheet .gd .v1, #mva-sheet .gd .sum.v1 strong { color: #FFAE57; }
#mva-sheet .gd .v2, #mva-sheet .gd .sum.v2 strong { color: #8BE28B; }
#mva-sheet .gd table.ck { width: 100%; border-collapse: collapse; margin: 0 0 8px; font-size: 13px; }
#mva-sheet .gd .ck th { padding: 5px 6px; text-align: left; color: #F7C948; font-weight: 700; border-bottom: 2px solid #C9A447; }
#mva-sheet .gd .ck td { padding: 6px; vertical-align: top; border-bottom: 1px solid rgba(140,106,43,.3); }
#mva-sheet .gd .ck td:first-child { color: #FFD866; font-weight: 700; }
#mva-sheet .gd .ck td.me { color: #FFF4C0; }
#mva-sheet .gd .ck td.res { font-weight: 700; white-space: nowrap; }
#mva-sheet .gd .ck small { display: block; color: #A8987A; font-weight: 400; font-size: 11px; white-space: normal; }`;

    const HELP_URL = "https://discord.gg/Dwb7XMkpSh";

    const TIPS = {
        game: ["The game itself", "MVA loads AdventureQuest Worlds straight from game.aq.com, the same game you play on a computer. MVA only changes how it looks and runs on this phone."],
        ruffle: ["Ruffle", "The open-source player that runs the game's Flash content. It is made by the Ruffle contributors and used under the MIT and Apache-2.0 licenses."],
        art: ["Side-button art", "The pictures on the side buttons (Quests, Map, Bag and the rest) come from AdventureQuest Worlds and belong to Artix Entertainment."],
        tips: ["Tips", "A tip is a thank-you, nothing more. MVA is free and stays free, and tipping unlocks nothing: everyone gets the same app."],
        chip: ["Processor", "Chip names cannot be compared fairly, so MVA measures instead: 64-bit, the number of cores and the top speed in GHz. 8 cores at 2.8 GHz or more stands in for an upper mid-range or flagship chip from 2022 or newer."],
        webview: ["Android System WebView", "The part of Android that draws MVA. Its age is estimated from its version number. To update it, open the Play Store and search for Android System WebView."],
        ram: ["RAM", "Phones report a little less memory than the box says, so MVA rounds up to the nearest size sold, such as 4, 6 or 8 GB."],
        pct: ["Percent of recommended", "This phone's number divided by the recommended number. 100% means exactly the recommended; more is spare room. It compares with MVA's requirements, not with other phones."]
    };

    const ABOUT = `<div class="gd">
<h3>What MVA is</h3>
<p><b>MVA</b> (MobileVibeAQW) plays <b>AdventureQuest Worlds</b> on Android, with big touch buttons and smoother play.</p>
<ul>
<li>It runs <u data-tip="game">the game itself</u>, unchanged.</li>
<li>No bots, no cheats.</li>
</ul>

<h3>Will it run well?</h3>
<button class="go">Check my phone</button>

<h3>Disclaimers</h3>
<ul>
<li>Not affiliated with or endorsed by <b>Artix Entertainment</b>.</li>
<li><b>AdventureQuest Worlds</b> is a trademark of Artix Entertainment, LLC.</li>
<li>The <u data-tip="art">side-button art</u> belongs to Artix Entertainment.</li>
</ul>

<h3>Credits</h3>
<p>MVA stands on other people's work. Thank you to:</p>
<p><b>Class star ratings</b></p>
<ul>
<li>r/AQW Simplified Bosses Guide, for the Ultra stars</li>
<li>AQW Hub, Basic Class Guide</li>
<li>AQWG, Ultra Bosses guide</li>
<li>AQWX Community Wiki, class setups</li>
<li>Artix's official PvP guide</li>
<li>AQW World, best farming classes</li>
<li>A class video on YouTube</li>
</ul>
<p class="note"><b class="n">Note:</b> Where no guide rates a class, the stars are an estimate.</p>
<p><b>Aura descriptions</b></p>
<ul>
<li>AQW Wiki (CC BY-SA 3.0), also used for class names</li>
</ul>
<p><b>Software</b></p>
<ul>
<li><u data-tip="ruffle">Ruffle</u>, which runs the game (MIT / Apache-2.0)</li>
<li>Inter, the text font (SIL Open Font License)</li>
</ul>

<h3>Made by</h3>
<p>Built by <b>Arglax</b>. Need help? Join the Discord.</p>
<div class="lk"><a class="help" href="${HELP_URL}">Discord: help and community</a></div>

<h3>Support</h3>
<p>MVA is free and stays free. <u data-tip="tips">Tips</u> are optional and unlock nothing.</p>
<div class="lk">
<a class="help" data-stat="supportCoffee" href="https://buymeacoffee.com/arglaxaqwv">Buy Me a Coffee</a>
<a class="help" data-stat="supportKofi" href="https://ko-fi.com/arglaxgaming">Ko-fi</a>
</div>
</div>`;

    const MIN_SDK = 28, REC_SDK = 31;
    const MIN_RAM_GB = 4, REC_RAM_GB = 8;
    const REC_CORES = 8, REC_GHZ = 2.8;
    const MIN_FREE_MB = 200, REC_FREE_MB = 500;
    const WEBVIEW_OLD_MONTHS = 36, WEBVIEW_FRESH_MONTHS = 12;
    const RAM_SIZES = [1, 2, 3, 4, 6, 8, 12, 16, 18, 24, 32];
    const WORD = ["Below minimum", "Meets minimum", "Recommended"];
    const show = { pct: true, headroom: true };

    let styled = false;
    function style() {
        if (styled) return;
        styled = true;
        const s = document.createElement("style");
        s.textContent = CSS;
        document.head.appendChild(s);
    }

    function stat(id) {
        try { if (window.MvaStat) window.MvaStat(id); } catch (err) { }
    }

    function esc(s) {
        return String(s).replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));
    }

    function facts() {
        try {
            if (window.MvaAndroid && window.MvaAndroid.deviceFacts) return JSON.parse(window.MvaAndroid.deviceFacts()) || {};
        } catch (err) { }
        return {};
    }

    function size(mb) {
        return mb >= 1024 ? (mb / 1024).toFixed(mb >= 10240 ? 0 : 1) + " GB" : Math.round(mb) + " MB";
    }

    function webviewMonths(major) {
        const now = new Date();
        return Math.max(0, (now.getFullYear() - 2024) * 12 + (now.getMonth() - 9) - (major - 130));
    }

    function rows(f) {
        const out = [];
        const unknown = "";

        const sdk = +f.sdk || 0;
        out.push({ name: "Android", me: f.android ? "Android " + esc(f.android) : unknown, min: "9.0", rec: "12 or newer",
            v: !sdk ? -1 : sdk < MIN_SDK ? 0 : sdk < REC_SDK ? 1 : 2 });

        const ramMb = +f.ramMb || 0;
        const gb = RAM_SIZES.find(s => s * 1024 >= ramMb) || Math.ceil(ramMb / 1024);
        out.push({ name: '<u data-tip="ram">RAM</u>', me: ramMb ? gb + " GB" : unknown, min: MIN_RAM_GB + " GB", rec: REC_RAM_GB + " GB",
            v: !ramMb ? -1 : gb < MIN_RAM_GB ? 0 : gb < REC_RAM_GB ? 1 : 2, pct: ramMb ? gb / REC_RAM_GB : 0, short: "RAM" });

        const cores = +f.cores || 0, ghz = (+f.maxKhz || 0) / 1e6;
        const bits = f.is64 === true ? "64-bit" : f.is64 === false ? "32-bit" : "";
        const cpu = [bits, cores ? cores + " cores" : "", ghz ? ghz.toFixed(2) + " GHz" : ""].filter(Boolean).join(", ");
        const cv = f.is64 === false ? 0 : f.is64 === true ? (cores >= REC_CORES && ghz >= REC_GHZ ? 2 : 1) : -1;
        out.push({ name: '<u data-tip="chip">Processor</u>', me: (cpu || unknown) + (f.soc ? `<small>Chip: ${esc(f.soc)}</small>` : ""),
            min: "Any 64-bit", rec: `${REC_CORES} cores, ${REC_GHZ} GHz or more<small>Upper mid-range or flagship, 2022 or newer</small>`,
            v: cv, pct: f.is64 === true && ghz ? ghz / REC_GHZ : 0, short: "processor speed" });

        const free = +f.freeMb;
        const hasFree = f.freeMb != null && free >= 0;
        out.push({ name: "Free storage", me: hasFree ? size(free) : unknown, min: MIN_FREE_MB + " MB", rec: REC_FREE_MB + " MB",
            v: !hasFree ? -1 : free < MIN_FREE_MB ? 0 : free < REC_FREE_MB ? 1 : 2, pct: hasFree ? free / REC_FREE_MB : 0, short: "free storage" });

        const major = parseInt(f.webview, 10) || 0;
        const months = webviewMonths(major);
        const age = months < 1 ? "this month" : months < 24 ? "about " + months + (months === 1 ? " month old" : " months old") : "about " + Math.floor(months / 12) + " years old";
        out.push({ name: '<u data-tip="webview">System WebView</u>', me: major ? `Version ${major}<small>${age}</small>` : unknown,
            min: "From the last 3 years", rec: "Up to date (last 12 months)",
            v: !major ? -1 : months > WEBVIEW_OLD_MONTHS ? 0 : months > WEBVIEW_FRESH_MONTHS ? 1 : 2 });
        return out;
    }

    function percent(p) {
        const n = Math.round(p * 100);
        return n > 999 ? "over 999%" : n + "%";
    }

    function summary(list) {
        const read = list;
        const worst = read.length ? Math.min(...read.map(r => r.v)) : -1;
        let html;
        if (worst < 0) return `<div class="sum v1"><strong>Could not check this phone</strong><p>MVA could not read this phone's details.</p></div>`;
        if (worst === 0) {
            html = `<strong>Below the minimum</strong>
<p>MVA may run slowly or close by itself on this phone. To get the most out of it:</p>
<ol>
<li>Tap <b>Graphics</b>, then pick <b>Battery</b>.</li>
<li>Tap <b>Settings</b>, then switch on <b>Auto quality</b>.</li>
</ol>`;
        } else if (worst === 1) {
            html = `<strong>Meets the minimum</strong>
<p>MVA is playable on this phone. Busy maps may slow down: pick <b>Balanced</b> in <b>Graphics</b> and keep <b>Auto quality</b> on.</p>`;
        } else {
            html = `<strong>Recommended or better</strong>
<p>MVA should run smoothly on this phone, even on the <b>Quality</b> preset.</p>`;
        }
        if (show.headroom) {
            const scored = read.filter(r => r.pct > 0).sort((a, b) => a.pct - b.pct)[0];
            if (scored) html += `<p>Tightest spot: <b>${scored.short}</b>, at <b class="v${scored.v}">${percent(scored.pct)}</b> of <u data-tip="pct">recommended</u>.</p>`;
        }
        return `<div class="sum v${worst}">${html}</div>`;
    }

    function drawCheck(body, back) {
        style();
        const f = facts();
        const list = rows(f).filter(r => r.v >= 0);
        const lines = list.map(r => {
            const res = `<span class="v${r.v}">${WORD[r.v]}</span>`;
            const pct = show.pct && r.v >= 0 && r.pct > 0 && r.pct < 10 ? `<small>${percent(r.pct)} of recommended</small>` : "";
            return `<tr><td>${r.name}</td><td class="me">${r.me}</td><td>${r.min}</td><td>${r.rec}</td><td class="res">${res}${pct}</td></tr>`;
        }).join("");
        body.innerHTML = `<div class="gd">
<button class="back">‹ Back to About</button>
<h3>Check my phone</h3>
${summary(list)}
<table class="ck">
<tr><th></th><th>This phone${f.model ? `<small>${esc(f.model)}</small>` : ""}</th><th>Minimum</th><th>Recommended</th><th>Result</th></tr>
${lines}
</table>
</div>`;
        body.scrollTop = 0;
        if (body.parentElement) body.parentElement.scrollTop = 0;
        body.querySelector(".back").addEventListener("click", back);
        if (window.MvaGuide) window.MvaGuide.wire(body, TIPS);
    }

    function draw(body, links) {
        style();
        body.innerHTML = ABOUT;
        if (window.MvaGuide) window.MvaGuide.wire(body, TIPS);
        if (links) links(body);
        body.querySelector(".go").addEventListener("click", e => {
            e.preventDefault();
            stat("aboutCheck");
            drawCheck(body, () => draw(body, links));
        });
    }

    window.MvaAbout = { draw, show };
})();
