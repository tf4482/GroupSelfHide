# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/).

## [0.5.1] - 2026-11-24

### Added

- Releases are published on CurseForge

## [0.5.0] - 2026-11-24

### Added

- Settings page (Esc > Options > AddOns) and addon compartment entry
- `/gsh config` opens the settings page, `/gsh help` lists all commands
- "Per character" checkbox and `/gsh character on|off`: settings per character or per
  account (saved in the new `GroupSelfHideCharDB`; the account mode stays as it was)
- `/gsh test` applies the mode once now, `/gsh reset` restores the defaults,
  `/gsh debug on|off` shows what the addon does

### Changed

- `/gsh` shows the current mode; `/gsh fill`, `/gsh hide`, and `/gsh off` set it
- Release zips are built on GitHub and named `GroupSelfHide-vX.Y.Z.zip`
- WoW Forever only: the TOC no longer lists the Retail interface number

### Fixed

- Stutter and flicker from updates of unrelated compact frames such as raid frames and
  nameplates; party frame updates in quick succession now apply once

## [0.4.2] - 2026-11-18

### Changed

- README: detail license terms

## [0.4.1] - 2026-11-18

### Changed

- README: add license section

## [0.4.0] - 2026-11-07

### Changed

- `/gsh` is now the fill mode, `/gsh hide` the hide mode
- Calling a command while a mode is active switches back to normal
- Default is off

### Added

- Addon stays inactive in raids and with a vertical party layout

### Removed

- `/gsh fill` and `/gsh help`

## [0.3.1] - 2026-11-07

### Changed

- README: add screenshots, simplify description

## [0.3.0] - 2026-11-07

### Added

- Fill mode (`/gsh fill`) widens the other party frames to keep the group width
- `/gsh hide` selects the plain hide mode
- `/gsh help` prints a short usage text in the client language (German, otherwise English)

## [0.2.0] - 2026-11-07

### Added

- Hide the "Party" label while the own frame is hidden

## [0.1.0] - 2026-11-07

### Added

- Hide the player's own frame in raid-style group frames
- `/gsh` command to toggle, persisted across sessions
