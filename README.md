# GroupSelfHide

WoW addon (WoW Forever) that hides **your own frame** in raid-style party frames.

## Features

- Hides your own frame and the "Party" label
- Mode `hide`: only hide your frame, the gap stays
- Mode `fill`: also widen the other frames to keep the group width (2-5 players)
- Choice persists across sessions
- Applies out of combat only

## Screenshots

Before (own frame shown) and after (`/gsh fill`):

![Before](docs/before.png)
![After](docs/after.png)

## Install

Copy this folder to `World of Warcraft/<version>/Interface/AddOns/GroupSelfHide`, then start the game or `/reload`.

## Usage

```text
/gsh        toggle hiding on / off (default: on)
/gsh hide   hide only
/gsh fill   hide and widen the others
/gsh help   short usage (German or English)
```

Examples:

- Party shown as raid: your frame disappears automatically.
- `/gsh fill` closes the gap; the other four frames grow to the old total width.
- `/gsh` shows your frame again.
