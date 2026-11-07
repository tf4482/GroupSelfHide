# GroupSelfHide

Tiny WoW addon (WoW Forever / Retail API) that hides **your own frame** in the raid-style group frames, handy when a 5-man group is shown as a raid.

## Features

- Hides the player's own compact frame (party and raid style)
- Hides the "Party" label above the party frames while hidden
- Toggle with `/gsh`
- State persists across sessions (`GroupSelfHideDB`)

## Install

Copy this folder to `World of Warcraft/<version>/Interface/AddOns/GroupSelfHide`, then start the game or `/reload`.

## Usage

```text
/gsh    -> toggle: hide / show your own frame (default: hidden)
```

Examples:

- Group of 5 with raid frames on: your frame disappears automatically.
- Type `/gsh` again to show it; the choice is kept after relogging.
- Changes apply out of combat only (Blizzard frames are protected).
