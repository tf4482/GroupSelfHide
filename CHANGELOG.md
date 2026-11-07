# 📝 Changelog

All notable changes follow [Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
