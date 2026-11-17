# MVA (MobileVibeAQW)

**AdventureQuest Worlds on Android, with a phone-friendly interface and performance improvements.**

MVA loads the game directly from `game.aq.com` and changes only how it is presented and how it performs on a phone. It contains no bots, trainers or cheats.

> [!IMPORTANT]
> **Download size:** `MVA_v1-0-0.apk`, about 5.8 MB (previously 7.8 MB).
>
> | | Minimum | Recommended |
> | :--- | :--- | :--- |
> | **Android** | 9.0 | 12 or newer |
> | **Memory (RAM)** | 4 GB | 8 GB |
> | **Processor** | Any 64-bit processor | Upper mid-range or flagship chipset from 2022 or newer |
> | **Free storage** | 200 MB (app and cached game files) | 500 MB |
> | **Other** | Up-to-date Android System WebView, internet connection | Stable Wi-Fi or mobile data |
>
> Reference device: Poco X6 Pro (Dimensity 8300-Ultra), where the game holds its 30 fps design target in busy maps.

## A message from Arglax

- This app is made for people who prefer some more QoLs from the original experimental launcher.
- Possible crash/problem data may be collected with your permission. If you don't want to share the data, just select No when there's a prompt.

## Download and installation

1. Download `MVA_v1-0-0.apk` from the [latest release](../../releases/latest).
2. Open the file on your phone and allow "Install unknown apps" when Android asks.
3. Launch **MVA** and log in as you would in the official client.

## Features

Every interface change has its own switch in the game's **Options > Controls** (rows with the gold MVA tag). A single **MVA UI** switch turns all of them off and restores the game's own interface.

<details>
<summary><b>Show the full feature list</b></summary>

<br>

<details>
<summary><b>Game screen and touch controls</b></summary>

<!-- SCREENSHOT OWED: game screen with both side button columns and the MVA crest (own character only, no other players' names). -->

- **Side buttons.** The game's menus (Quests, Temp Inventory, Map, Lore, Menu, House, Settings, Bag, Drops, Bank, Rest, Char and Quick) as large buttons beside the game. The **Sidebar** switch hides them and leaves a small MVA crest in the corner.
- **Mobile Layout.** Skill buttons arranged around auto attack, drops and potion in the bar, and larger portraits.
- **Dynamic Joystick.** Put a thumb down anywhere on the left 35% of the screen to steer.
- **Long Dash.** The mobile dash travels three times as far.
- **Swipe scrolling** for lists, shops, quests and the chat.
- **Bigger UI.** Taller list rows sized for fingers.
- **Drops panel.** Drops collect in a panel, with a count on the Drops button, instead of appearing over the fight.
- **Back button.** Closes MVA's windows first, otherwise sends the game to the background while staying connected.

</details>

<details>
<summary><b>Inventory and class ratings</b></summary>

<!-- SCREENSHOT OWED: inventory with class stars and the Sort chip (own character only). -->

- **Inventory.** Bigger rows and icons, class ranks, enhancement names and boost cards.
- **Inventory Filter.** A Sort chip orders weapons, armor, helms and capes by damage type or boost.
- **Star ratings.** Community ratings for classes, shown in the inventory.

</details>

<details>
<summary><b>Quick panel and travel</b></summary>

<!-- SCREENSHOT OWED: Quick panel, Actions tab and Travel tab. -->

- **Actions.** The game's own shortcut actions as buttons, with no keyboard needed: users in the area, HP bars, hide players, monsters or the interface, stats, the battle analyzer, friends, character, outfits, options, target, untarget, rest, jump, decline all drops, the world camera and the chat keyboard.
- **Travel.** Join a map without typing `/join`: common places (Battleon, Yulgar's Inn, the Forge and more), a box for any map name or room number, and a travel log of the maps visited, newest first.
- **Floating button.** An optional button over the game that opens the panel and can be dragged anywhere.
- The game's own travel rules apply: five seconds between maps, not while defeated.

</details>

<details>
<summary><b>Auras overlay</b></summary>

<!-- SCREENSHOT OWED: both aura windows during a fight (own character and a monster only). -->

- **Two windows.** Your auras on the left and your target's at the top right, with stacks, time left and short colored effect labels.
- **Warnings.** Heal blocks such as Decay in red, taunts and enrages in orange, auras at their stack limit glowing blue.
- **Stack limits.** `3/5` when the limit is known, and the count stops at the limit; an aura with no listed limit shows only its count.
- **Who applied it.** Tap an aura for everyone who applied it, its stacks, duration, and the skill it comes from.
- **Filters and pins.** All, Buffs, Debuffs, Scrolls & potions; pinned auras stay on top; the order of groups can be changed.
- **Window controls.** Drag, collapse, hide, join or split the two windows, and change their size. **Drag windows anywhere** lets them sit over the side buttons.

</details>

<details>
<summary><b>Graphics and performance</b></summary>

<!-- SCREENSHOT OWED: Graphics & Performance page and Settings page. -->

- **Presets.** Battery, Balanced, Quality and Ultra.
- **Resolution and anti-aliasing.** Lower resolution saves battery and heat.
- **Color styles.** Natural, Vivid, Cinematic and Bright.
- **Smooth motion.** In-between pictures drawn between the game's frames.
- **Improve FPS.** Smoother, steadier frames from the frame governor and in-between pictures.
- **Auto quality.** Lowers graphics only while the game cannot hold its frame rate, and raises them again when it can.
- **FPS meter** and **heat warnings** as small labels over the game.
- **Headless mode.** The screen goes black and nothing is drawn while the game keeps running; tap anywhere to return.
- **Game options as tiles.** The game's Advanced Options that matter on a phone (Mobile Controls, Mobile UI Size, Auto-Untarget, Max FPS, Crowd Mode, Hide Players and others) as large tiles.
- **Keep screen on** while MVA is open.
- **Engine improvements** in the bundled Ruffle build: lower memory use in busy maps and fewer wasted frames.

</details>

</details>

## Free of charge

MVA is completely free. It has no purchases, subscriptions, advertisements or paid features, and none are planned. Nobody is authorized to sell it; if you paid for it, ask for a refund.

Donations are optional and do not unlock anything: [BuyMeACoffee](https://buymeacoffee.com/arglaxaqwv) or [Ko-Fi](https://ko-fi.com/arglaxgaming).

## A note to Artix Entertainment

Artix Entertainment is welcome to adopt any of the quality-of-life ideas and interface designs shown in MVA in its own games and clients, free of charge and without asking. The only request is credit for the idea, for example a mention or a shout-out to Arglax. The exact terms are in section 5 of the [license](LICENSE).

## Privacy

MVA has no accounts of its own. Your login is sent only to Artix Entertainment's servers, exactly as in the official client. Game files are cached on the phone to shorten loading.

**Usage statistics.** MVA sends anonymous usage statistics so that its author can see what works: a random install identifier, app and Android version, phone model, processor, core count, memory, display refresh rate, WebView version, two-letter country (from the mobile network, SIM or phone region, never GPS or IP), play time, frame rate, the app's memory use, device temperature, session health and load times, and which buttons, panels and switches are used. To turn this off, open the **MVA crest > Settings > Send anonymous usage stats**.

**Crash and problem reports.** When MVA crashes or runs into a problem, it shows "MVA has crashed" (or "MVA ran into a problem") and asks: "Do you want to submit the crash report to Arglax?" Nothing is sent before you answer.

- **Yes** sends the full report: the error and stack trace, where in the app it happened, a recent log of MVA's own activity, memory, frame-rate and temperature readings, MVA's settings, the anonymous install identifier, and your phone's specifications and country.
- **No** sends only the error and where it happened, with no install identifier and nothing about you or your phone.

Both answers contain data from MVA only and are scrubbed before sending to remove account and character names, logins, passwords, tokens, e-mail addresses and user file paths.

## Support

Questions and problems: [MVA Discord](https://discord.gg/Dwb7XMkpSh), also linked from the crest's **Guide** and **About**.

## License

MVA is distributed under the [MVA Open Freeware License](LICENSE). In short: you may use, study, modify and share MVA free of charge, provided you credit Arglax with a link to this repository; MVA and every work based on it must stay free, and nobody may present it as their own or as the official MVA if changed. The full source code is in [`src`](src).

## Credits and legal notices

- Flash content runs on [Ruffle](https://ruffle.rs), licensed under MIT / Apache-2.0 (see [licenses](licenses)).
- Aura descriptions come from the [AQW Wiki](http://aqwwiki.wikidot.com) (CC BY-SA 3.0).
- **Class star ratings** are compiled from community guides: the [r/AQW Simplified Bosses Guide](https://docs.google.com/spreadsheets/d/1yytxo6x0XlvbTIYLLD6TCEF_v1EKV59e_N-gas9Fi8Y), [AQW Hub's class guide](https://www.aqwhub.com/other-guides/basic-class-guide/), [AQWG's ultra boss guides](https://sites.google.com/view/aqwg-net/ultra-bosses), the [AQWX community class setups](https://sites.google.com/view/aqwxcommunity-wiki-tutorial/class-setups), Artix's [PvP guide](https://www.aq.com/lore/guides/pvpguide) and [AQW World](https://www.aqwworld.com/2017/01/best-farming-class-on-aqw.html). Where no guide rates a class, the rating is the author's own estimate and is marked as such in the data. Treat the stars as a starting point, not a verdict.
- **Artwork.** The side-button pictures are AdventureQuest Worlds interface art, © Artix Entertainment, LLC. MVA claims no rights in them or in any other game art, and its license does not cover them.

MVA is an unofficial, fan-made application. It is not affiliated with, endorsed by or sponsored by Artix Entertainment, LLC. AdventureQuest Worlds is a trademark of Artix Entertainment, LLC. MVA is provided "as is", without warranty of any kind; you use it at your own risk.

Made by Arglax, assisted by Claude and Gemini.
