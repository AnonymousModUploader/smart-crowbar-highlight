# Smart Crowbar Highlight

A quality-of-life mod for **PAYDAY 2** that outlines every crowbar on the map in a color of your choice — and, the smart part, stops highlighting them the moment you've picked one up, so your screen stays clean once you have what you need.

## Download & Install

1. **[Download the latest release](../../releases/download/master/Smart.Crowbar.Highlight.zip)** (or use the green *Code → Download ZIP* button).
2. Extract the **`Smart Crowbar Highlight`** folder into your `PAYDAY 2/mods/` directory.
3. That's it — the mod appears under *Options → Mod Options → Smart Crowbar Highlight*.

**Requires [SuperBLT](https://superblt.znix.xyz/).** If you can't see *Mod Options*, SuperBLT isn't installed yet.

The mod checks for updates automatically through SuperBLT's updater, so you only need to do this once.

## Features

- **Colored outline on every crowbar**, visible through walls, on any heist that has them.
- **Smart auto-unhighlight** — once you pick up a crowbar, all highlights turn off (you can toggle this behavior off if you'd rather keep them lit).
- **Fully custom color** — RGB sliders, hex code input, and a live preview panel in the options menu.
- **Proximity mode** (optional) — only highlight crowbars within a configurable range of you, instead of the whole map.
- **Toggle keybind** — flip highlights on/off mid-heist, with an optional on-screen notification (duration and color configurable).
- Settings persist between sessions.

## Options

*Options → Mod Options → Smart Crowbar Highlight*

| Setting | What it does |
|---|---|
| Enable Highlights | Master switch for the mod. |
| Highlight Color | RGB sliders + hex input, with live preview. Applies instantly, even mid-heist. |
| Proximity Mode | Only highlight crowbars near you. |
| Proximity Range | How near is "near" (used when Proximity Mode is on). |
| Auto-Unhighlight | Turn highlights off once you're carrying a crowbar. |
| Keybind Notifications | Show a short on-screen message when you use the toggle keybind, optionally in your highlight color, with adjustable duration. |

The toggle keybind is set under *Options → Mod Keybinds → Toggle Crowbar Highlights* (works in-heist).

## Compatibility

- Works on any heist that uses crowbars; does nothing (and breaks nothing) elsewhere.
- Plays nice with the other Smart Highlight mods.
- **64-bit engine update:** when PAYDAY 2's 64-bit engine upgrade and its SuperBLT port release, a compatibility update will follow.

## AI Disclosure

The Lua code in this mod was written by AI under my direction — I designed, specified, and play-tested everything by hand. Hosted here on GitHub, where AI-assisted projects are welcome.

## Permissions

Free to use, edit, and reupload — no credit required. Consider the code yours to learn from, fork, or build on.
