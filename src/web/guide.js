(function () {
    "use strict";

    const CSS = `
#mva-sheet .gd h3 { margin: 18px 0 8px; padding: 7px 12px 6px; text-align: center; color: #F7C948;
  font: 800 16px Inter, system-ui, sans-serif; letter-spacing: .6px; text-transform: uppercase;
  background: linear-gradient(90deg, rgba(122,23,23,0), rgba(122,23,23,.85) 30%, rgba(122,23,23,.85) 70%, rgba(122,23,23,0));
  border-bottom: 2px solid #C9A447; text-shadow: 0 1px 0 #3F0A0A; scroll-margin-top: 6px; }
#mva-sheet .gd h3:first-child { margin-top: 2px; }
#mva-sheet .gd .qj { display: grid; grid-template-columns: repeat(auto-fill, minmax(132px, 1fr)); gap: 6px; margin: 0 0 4px; }
#mva-sheet .gd .qj button { min-height: 42px; padding: 4px 8px; border-radius: 9px; border: 1px solid #8C6A2B;
  background: #2A1D10; color: #F7C948; font: 600 13px Inter, system-ui, sans-serif; }
#mva-sheet .gd .qj button:active { background: linear-gradient(#7A1717, #3F0A0A); color: #FFF4C0; border-color: #C9A447; }
#mva-sheet .gd p { margin: 0 0 6px; }
#mva-sheet .gd ol, #mva-sheet .gd ul { margin: 0 0 6px; padding-left: 22px; }
#mva-sheet .gd li { margin: 0 0 4px; }
#mva-sheet .gd ol > li::marker { color: #F7C948; font-weight: 700; }
#mva-sheet .gd ul > li::marker { color: #C9A447; }
#mva-sheet .gd b { color: #FFD866; font-weight: 700; }
#mva-sheet .gd b.on { color: #8BE28B; }
#mva-sheet .gd b.red { color: #FF7A6B; }
#mva-sheet .gd b.org { color: #FFAE57; }
#mva-sheet .gd b.blu { color: #7FC8FF; }
#mva-sheet .gd .note { margin: 2px 0 6px; padding: 5px 8px; border-left: 3px solid #C9A447; border-radius: 0 6px 6px 0;
  background: rgba(201,164,71,.10); color: #D9C690; font-size: 13px; }
#mva-sheet .gd .note b.n { color: #FFAE57; }
#mva-sheet .gd u { color: #7FD4FF; font-weight: 600; text-decoration: underline dotted #7FD4FF; text-underline-offset: 3px; cursor: pointer; }
#mva-tip { position: fixed; inset: 0; z-index: 60; display: flex; align-items: center; justify-content: center;
  background: rgba(0,0,0,.55); }
#mva-tip .card { width: min(420px, 86vw); padding: 14px 16px; box-sizing: border-box; border-radius: 12px;
  background: linear-gradient(#24190F, #150E08); border: 1px solid #7FD4FF; color: #EAD9A8;
  font: 14px/1.45 Inter, system-ui, sans-serif; box-shadow: 0 8px 28px rgba(0,0,0,.7); }
#mva-tip .card h4 { margin: 0 0 8px; color: #7FD4FF; font: 700 16px Inter, system-ui, sans-serif; }
#mva-tip .card p { margin: 0 0 12px; }
#mva-tip .card button { display: block; width: 100%; min-height: 42px; border-radius: 9px; border: 1px solid #C9A447;
  background: linear-gradient(#7A1717, #3F0A0A); color: #FFF4C0; font: 600 14px Inter, system-ui, sans-serif; }`;

    const TIPS = {
        tag: ["The gold MVA tag", "Options that MVA added carry a small gold tag that says MVA. Anything without the tag is the game's own option."],
        mobile: ["Mobile Controls", "The game's own touch controls: a joystick on the left and skill buttons on the right. You find it in the game's Options, under Controls."],
        stars: ["Star rating", "0 to 5 stars per class, gathered from community guides for farming, solo play, bosses and PvP. Where no guide rates a class, the stars are an estimate. Use them as a starting point, not a rule."],
        stacks: ["Stacks", "Some auras build up. Each use adds one stack, and more stacks make the effect stronger. 3/5 means 3 stacks out of a maximum of 5."],
        decay: ["Decay", "A debuff that blocks healing. While it is on you, heals and potions do nothing."],
        taunt: ["Taunt and enrage", "A taunt makes the monster attack one player. Enrage powers the monster up, so it hits harder."],
        log: ["Travel log", "A list of the maps you visited, newest first. It is kept on this phone only. Tap a map to go back there, or × to remove it."],
        room: ["Private room", "A copy of a map with its own number, like battleon-1234. Only players who type the same number end up with you."],
        auto: ["Auto quality", "MVA watches how smoothly the game runs. When the game struggles, graphics go down one step. When it runs well again, they go back up."],
        fps: ["FPS", "Frames per second: how many pictures the game draws each second. The game is made for 30. Below 20 it feels choppy."],
        headless: ["Headless mode", "The screen goes black and nothing is drawn, but the game keeps running and you stay logged in. It saves battery and keeps the phone cool. Tap anywhere to bring the picture back."],
        stats: ["Anonymous usage numbers", "Things like phone model, frame rate, how warm the phone got and which buttons get used. They help MVA's maker see what works. Never your name, login, character or chat."],
        report: ["Crash report", "Yes sends the error together with your phone's model and country. No sends only the error itself, with nothing about you or your phone."]
    };

    const HTML = `<div class="gd">
<h3>QuickJump</h3>
<div class="qj"></div>

<h3 data-jump="The Sidebar">The Sidebar</h3>
<p>These are the game's own menus, made big enough to tap: Quests, Map, Bag, Bank and the rest.</p>
<ol>
<li><b>Drops</b> holds the loot waiting for you, and shows a red number when something dropped.</li>
<li><b>Quick</b> opens shortcuts and travel.</li>
<li><b>MVA crest</b> in the corner opens MVA's own Settings, Graphics, this guide and About.</li>
</ol>

<h3 data-jump="On and off switches">Turning MVA's changes on and off</h3>
<p>Open the game's <b>Options</b>, then <b>Controls</b>. Every row with a <u data-tip="tag">gold MVA tag</u> is one of ours. Tap a row to switch it, or tap <b>(?)</b> to see what it does.</p>
<ol>
<li><b>MVA UI</b> is the main switch: turn it off and you get the game exactly as it normally looks.</li>
</ol>
<p>Most of these switches are also in the crest's <b>Settings</b>.</p>
<p class="note"><b class="n">Note:</b> <b>Bigger UI</b> and <b>Long Dash</b> need a restart to take effect.</p>

<h3 data-jump="Touch (MFUI)">Playing with touch (MFUI)</h3>
<ol>
<li>Set AQW's <u data-tip="mobile">Mobile Controls</u> option to <b class="on">On</b>.</li>
<li>Set MVA's <b>Mobile Layout</b> to <b class="on">On</b> to put the skill buttons around the attack button.</li>
</ol>
<ul>
<li><b>Dynamic Joystick</b> lets you put your thumb anywhere on the left side to walk.</li>
<li><b>Long Dash</b> makes the dash go three times as far.</li>
<li><b>Scrolling</b> lets you swipe through lists, shops, quests and the chat.</li>
</ul>

<h3 data-jump="Bag">Bag</h3>
<p>Taller rows that are easier to tap.</p>
<ul>
<li>Classes show their <b>rank</b> and a <u data-tip="stars">star rating</u>.</li>
<li>Gear shows its <b>enhancement</b> and <b>boosts</b>.</li>
</ul>
<p>To sort your gear:</p>
<ol>
<li>Open the <b>Bag</b>.</li>
<li>Tap <b>Sort</b> next to the title.</li>
<li>Pick a damage type or a boost.</li>
</ol>

<h3 data-jump="Auras">Auras (buffs and debuffs)</h3>
<p>Two small windows: <b>yours</b> on the left, your <b>target's</b> at the top right. Each line shows the aura, its <u data-tip="stacks">stacks</u>, the time left and who applied it.</p>
<ul>
<li><b class="red">Red</b> blocks healing, like <u data-tip="decay">Decay</u>.</li>
<li><b class="org">Orange</b> is a <u data-tip="taunt">taunt or enrage</u>.</li>
<li><b class="blu">Blue glow</b> means it is at its maximum.</li>
</ul>
<p>Tap a line to see more. Drag a window by its title to move it.</p>
<ul>
<li><b>–</b> shrinks the window, <b>×</b> hides it.</li>
<li><b>⇆</b> joins the two windows, or splits them again.</li>
<li><b>A</b> changes the text size, <b>⚙</b> has pins and filters.</li>
</ul>
<p class="note"><b class="n">Note:</b> To bring back a hidden window, tap a portrait, then <b>Show Auras</b>.</p>

<h3 data-jump="Quick">Quick: shortcuts and travel</h3>
<ol>
<li>Tap <b>Quick</b> on the right side.</li>
<li>Pick a tab: <b>Actions</b> or <b>Travel</b>.</li>
</ol>
<ul>
<li><b>Actions</b>: one-tap shortcuts. See who is in the room, show HP bars, hide other players, rest, open the chat.</li>
<li><b>Travel</b>: go to a map without typing /join. Pick a place, type a map name, or tap one in your <u data-tip="log">travel log</u>.</li>
<li>Add a number for a <u data-tip="room">private room</u>, like battleon-1234.</li>
</ul>
<p class="note"><b class="n">Note:</b> The game makes you wait 5 seconds between maps.</p>

<h3 data-jump="Drops">Drops</h3>
<p>Loot waits in the Drops panel instead of popping up in the middle of a fight.</p>
<ol>
<li>Tap <b>Drops</b> on the right side.</li>
<li>Tap <b>Accept</b> or <b>Decline</b> on each item.</li>
</ol>

<h3 data-jump="Performance">Performance Issues</h3>
<ol>
<li>Tap the <b>MVA crest</b>, then <b>Graphics</b>.</li>
<li>Pick <b>Battery</b> or <b>Balanced</b>.</li>
</ol>
<p>Also useful, in the crest's <b>Settings</b>:</p>
<ul>
<li><u data-tip="auto">Auto quality</u> lowers the graphics only while the game struggles.</li>
<li><b>Show FPS</b> shows how smoothly the game runs. An <u data-tip="fps">FPS</u> of 30 or more is good.</li>
<li><u data-tip="headless">Headless mode</u> turns the picture off but keeps you logged in.</li>
</ul>

<h3 data-jump="Back button">Back button</h3>
<ul>
<li>A window is open: <b>Back</b> closes it.</li>
<li>Nothing is open: <b>Back</b> sends the game to the background. You stay connected.</li>
</ul>

<h3 data-jump="Privacy">Privacy</h3>
<p>MVA sends <u data-tip="stats">anonymous usage numbers</u>. Never your name, login or chat.</p>
<p>To turn that off:</p>
<ol>
<li>Tap the <b>MVA crest</b>, then <b>Settings</b>.</li>
<li>Switch off <b>Send anonymous usage stats</b>.</li>
</ol>
<p class="note"><b class="n">Note:</b> If MVA crashes, it asks before sending a <u data-tip="report">crash report</u>.</p>
</div>`;

    let styled = false;
    function style() {
        if (styled) return;
        styled = true;
        const s = document.createElement("style");
        s.textContent = CSS;
        document.head.appendChild(s);
    }

    function closeTip() {
        const t = document.getElementById("mva-tip");
        if (t) t.remove();
    }

    function openTip(title, text) {
        closeTip();
        const wrap = document.createElement("div");
        wrap.id = "mva-tip";
        const card = document.createElement("div");
        card.className = "card";
        const h = document.createElement("h4");
        h.textContent = title;
        const p = document.createElement("p");
        p.textContent = text;
        const ok = document.createElement("button");
        ok.textContent = "Got it";
        ok.addEventListener("click", closeTip);
        card.append(h, p, ok);
        wrap.appendChild(card);
        wrap.addEventListener("click", e => { if (e.target === wrap) closeTip(); });
        document.body.appendChild(wrap);
        try { if (window.MvaStat) window.MvaStat("guideTip"); } catch (err) { }
    }

    function wire(body, tips) {
        style();
        body.querySelectorAll(".gd u[data-tip]").forEach(u => u.addEventListener("click", e => {
            e.preventDefault();
            e.stopPropagation();
            const tip = tips[u.dataset.tip];
            if (tip) openTip(tip[0], tip[1]);
        }));
    }

    function draw(body, after) {
        style();
        body.innerHTML = HTML + (after || "");

        const jump = body.querySelector(".gd .qj");
        body.querySelectorAll(".gd h3[data-jump]").forEach(h => {
            const b = document.createElement("button");
            b.textContent = h.dataset.jump;
            b.addEventListener("click", () => {
                try { if (window.MvaStat) window.MvaStat("guideJump"); } catch (err) { }
                h.scrollIntoView({ block: "start", behavior: "smooth" });
            });
            jump.appendChild(b);
        });
        wire(body, TIPS);
    }

    window.MvaGuide = { draw, closeTip, wire };
})();
