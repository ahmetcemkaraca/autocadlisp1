# PolylineTools for AutoCAD

[![CI](https://github.com/ahmetcemkaraca/autocadlisp/actions/workflows/ci.yml/badge.svg)](https://github.com/ahmetcemkaraca/autocadlisp/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

English | [Türkçe](README.tr.md)

A small AutoLISP toolkit that does four jobs AutoCAD makes tedious:

- turn polylines (including arc segments) into smooth splines,
- smooth or curve-fit polylines without leaving the polyline type,
- join polylines end to end - one pair or a whole selection - while keeping arc segments,
- number things: drop `1, 2, 3 ...` as text at the points you click.

Everything ships as **one file**: [`dist/polyline-tools.lsp`](dist/polyline-tools.lsp). No dependencies, no installer.
Works in AutoCAD and in other CAD programs that run Visual LISP (for example BricsCAD).

## Install

1. Download [`polyline-tools.lsp`](dist/polyline-tools.lsp) (or clone the repository).
2. In AutoCAD run `APPLOAD`, pick the file and press **Load**.
   To load it in every session, add it to the **Startup Suite** in the same dialog.
3. Type `PLXHELP` to list the commands.

You can also load it from the command line: `(load "C:/path/to/polyline-tools.lsp")`.

## Commands

| Command | What it does |
| --- | --- |
| `PL2CURVE` | Replaces each selected polyline with a fit-point spline through its vertices. Arc segments (bulges) are sampled every 10 degrees, so arcs stay arcs. Layer, color, linetype and lineweight are kept. Closed polylines become closed splines. |
| `SMOOTHPL` | Spline-fits the selected polylines with `PEDIT`. They remain polylines. |
| `FITCURVE` | Curve-fits the selected polylines with `PEDIT`. The curve passes through every vertex. |
| `JOINPL` | Joins two polylines whose endpoints touch. Either one is reversed when necessary; arc segments and layer/color of the first polyline are preserved. |
| `AUTOJOINPL` | Joins every chain of touching polylines inside a selection. Chains that end where they started become closed polylines. |
| `SETTOL` | Sets the distance (default `0.001`) within which two endpoints count as touching. |
| `NUMBER` | Asks for a start number, an end number and a text height, then places one number per click (centered, in the plane of the current UCS). `Enter` or `ESC` stops. |
| `PLXHELP` | Lists the commands. |
| `PLXLANG` | Switches messages between English and Turkish. |

Each command runs inside a single undo group: one `U` reverts the whole operation, and system variables are restored even if you press `ESC`.

### Example

```text
Command: PL2CURVE
Select polylines:  [select objects]
Converted 3 polyline(s) to splines.

Command: AUTOJOINPL
Select polylines:  [select objects]
7 polyline(s) merged into 2 new polyline(s).
```

### Good to know

- `JOINPL` and `AUTOJOINPL` handle open 2D polylines (`LWPOLYLINE` and 2D `POLYLINE`) that lie in the same plane. Joined results are written as `LWPOLYLINE`.
- `PL2CURVE` also accepts 3D polylines; 3D meshes and polyface meshes are skipped.
- `NUMBER` is a short, generic command name. If another routine of yours is called `NUMBER`, load the files in the order you prefer or rename `c:number` in `src/lisp/50-number.lsp`.
- `PL2CURVE` replaces the original objects. Use `U` to undo.

## Repository layout

```text
.
├── dist/polyline-tools.lsp   Generated single-file build - this is what users load
├── src/lisp/                 Source modules, concatenated in file-name order
│   ├── 00-core.lsp           Settings, messages (EN/TR), error handling, helpers
│   ├── 10-polyline.lsp       Reading, building and joining polylines
│   ├── 20-geometry.lsp       Bulge/arc math and point sampling
│   ├── 30-curve.lsp          PL2CURVE, SMOOTHPL, FITCURVE
│   ├── 40-join.lsp           JOINPL, AUTOJOINPL, SETTOL
│   ├── 50-number.lsp         NUMBER
│   └── 90-help.lsp           PLXHELP, PLXLANG, load banner
├── scripts/
│   ├── build.ps1             Bundles src/lisp into dist/
│   └── lint.ps1              Paren balance, ASCII, undefined-function checks
├── docs/                     Architecture notes and manual test plan
└── .github/                  CI, release workflow, issue and PR templates
```

## Development

You need PowerShell 7 (`pwsh`) or Windows PowerShell 5.1. AutoCAD is only needed for the manual tests.

```powershell
./scripts/lint.ps1      # static checks
./scripts/build.ps1     # regenerate dist/polyline-tools.lsp
```

CI runs the same two steps and fails when `dist/polyline-tools.lsp` is out of date.
See [CONTRIBUTING.md](CONTRIBUTING.md), [docs/architecture.md](docs/architecture.md) and [docs/testing.md](docs/testing.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[GNU GPL v3.0](LICENSE).
