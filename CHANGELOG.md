# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [2.1.0] - 2026-11-19

### Added
- `SIMPLIFYPL` command: Douglas-Peucker vertex reduction that keeps arc segments, closed state and object properties.
- `CTILE70` command: cut contours into clipped tile blocks laid out in a grid.
  Both were recovered from the old `feature/contour-tiler` branch and rewritten on top of the shared polyline model.

### Changed
- `CTILE70` fixes over the original prototype: the invalid `-BLOCK ... R` retain option is replaced by `OOPS`, tiles are inserted with `ENTMAKE` instead of `-INSERT` prompts, empty tiles are skipped, the layout no longer overlaps the source drawing, and the UCS is switched to World and restored.
- `SIMPLIFYPL` fixes over the original prototype: arcs are no longer flattened to chords, the reserved symbol `T` is no longer used as a variable, and 3D polylines are skipped.
- `SETSIMP` was folded into the `SIMPLIFYPL` tolerance prompt.
- The auto-numbered text prototype is superseded by `NUMBER`.

## [2.0.0] - 2026-11-19

Complete restructure of the code base and the repository.

### Added
- Single-file distribution `dist/polyline-tools.lsp`, generated from `src/lisp/` by `scripts/build.ps1`.
- `PLXHELP` (command list) and `PLXLANG` (English / Turkish messages).
- Every command now runs in one undo group and restores `CMDECHO`, `OSMODE` and `SPLMETHOD`, also after `ESC` or an error.
- `scripts/lint.ps1` static checks (balanced parentheses, ASCII-only, undefined functions) and a GitHub Actions workflow running them.
- Contribution guide, architecture notes, manual test plan, issue and pull request templates, release workflow.

### Changed
- Source split into focused modules; all helper functions and globals use the `plx:` / `*plx-...*` prefix.
  The global `*JOIN-TOLERANCE*` is now `*plx-tolerance*`.
- Messages are pure ASCII with `\U+XXXX` escapes, so the file loads correctly regardless of AutoCAD's code page.
- `PL2CURVE` creates the spline directly from sampled arc points, keeps layer, color, linetype and lineweight, supports closed polylines and reports failed conversions.
- `AUTOJOINPL` merges chains in memory and creates each result once (previously it kept using entities it had already deleted).
- `JOINPL` / `AUTOJOINPL` preserve arc segments, close rings and refuse polylines that lie in different planes.
- `NUMBER` places text in the current UCS plane using the current text style, centered on the picked point; the text height is remembered.

### Fixed
- Heavy `POLYLINE` vertices were never read, so old-style polylines could not be converted or joined.
- Arc center for bulge segments was computed with the wrong formula, distorting converted arcs.
- Joining with the `end1 -> end2` case kept the second polyline in the wrong direction.
- Bulges were lost when polylines were joined.
- `NUMBER` could terminate with an error through `(exit)` and ignored non-WCS user coordinate systems.

### Removed
- Unrelated project-template material: Copilot/Cursor instruction files for Flutter, Go, Swift, Prisma, ..., prompt files, registry JSON files, context scripts and placeholder CODEOWNERS entries.
- `version.md` (merged into this changelog).

## [1.2.0] - 2026-02-28

### Added
- `NUMBER` command: place consecutive numbers as text at picked points, with configurable text height.

## [1.1.1] - 2025-09-26

### Added
- `SETTOL` command and the global join tolerance.
- Confirmation prompt when more than 50 polylines are selected for `AUTOJOINPL`.

### Fixed
- Invalid color number error when joining polylines; properties are now set through `ENTMOD`.

## [1.1.0] - 2025-09-26

### Added
- `JOINPL` and `AUTOJOINPL` commands.

## [1.0.0] - 2025-09-26

### Added
- `PL2CURVE`, `SMOOTHPL` and `FITCURVE` commands.

[Unreleased]: https://github.com/ahmetcemkaraca/autocadlisp/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/ahmetcemkaraca/autocadlisp/releases/tag/v2.1.0
[2.0.0]: https://github.com/ahmetcemkaraca/autocadlisp/releases/tag/v2.0.0
