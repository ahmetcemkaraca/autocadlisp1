# Manual test plan

CI can only check the sources statically (`scripts/lint.ps1`). Run this checklist in AutoCAD (or BricsCAD) before a release and after changing geometry or command code. Start from a new drawing, load `dist/polyline-tools.lsp` with `APPLOAD` and confirm the banner appears.

## Test drawing

Draw these with `PLINE` (use the `Arc` option for curved segments):

| Id | Object |
| --- | --- |
| A | Open polyline with 4 straight segments |
| B | Open polyline with two straight segments and one arc in the middle |
| C | Closed polyline (rectangle) |
| D | Closed polyline with one arc segment |
| E, F | Two polylines on different layers/colors whose ends touch (E ends where F starts) |
| G, H | Two polylines whose *start* points touch (start-to-start) |
| I | Old-style polyline: set `PLINETYPE` to 0, draw a polyline (or use `CONVERTPLINE`) |
| J | Three polylines forming a closed triangle that touch end to end |

## Checks

| # | Steps | Expected |
| --- | --- | --- |
| 1 | `PL2CURVE`, select A | Replaced by a spline through all vertices; layer and color unchanged. Message reports 1 converted. |
| 2 | `PL2CURVE`, select B | Spline follows the arc without flattening or bulging the wrong way (test with a negative bulge too). |
| 3 | `PL2CURVE`, select C and D | Closed splines. `U` restores both polylines. |
| 4 | `PL2CURVE`, select I | Old-style polyline is converted. |
| 5 | `PL2CURVE` with `ESC` at the selection prompt | No error text; `OSMODE` and `CMDECHO` unchanged. |
| 6 | `SMOOTHPL` and `FITCURVE` on A | Polyline stays a polyline and is curve fitted. |
| 7 | `JOINPL`, pick E then F | One polyline; layer/color of E; no gap. |
| 8 | `JOINPL`, pick G then H | One polyline with correct direction (no self-crossing). Repeat with end-to-end touching pair. |
| 9 | `JOINPL` with a polyline that contains an arc | Arc segment is preserved (and keeps its direction when the polyline had to be reversed). |
| 10 | `JOINPL`, pick two polylines that do not touch | Message about the tolerance; nothing deleted. |
| 11 | `JOINPL`, pick the same polyline twice / a closed polyline / a line | Descriptive message, drawing unchanged. |
| 12 | `SETTOL`, set `0.5`, then join polylines with a 0.3 gap | They join. Set back to `0.001` and the same gap is refused. |
| 13 | `AUTOJOINPL`, select J | One closed polyline; message "3 polyline(s) merged into 1 new polyline(s)". |
| 14 | `AUTOJOINPL` on a mixed selection (A-J) | Only touching ones merge; the rest remain; one `U` undoes everything. |
| 15 | `NUMBER`, start 1, end 5, height 3.5, click 5 times | Texts 1..5, centered on the clicks, current text style. |
| 16 | `NUMBER`, press `Enter` after two clicks | Command ends; message "2 number(s) placed". |
| 17 | Rotate the UCS (`UCS Z 30`), run `NUMBER` | Text is aligned with the UCS axes. |
| 18 | `PLXLANG` Turkish, then `PLXHELP` | Turkish messages with correct characters; switch back to English. |

## Regression tips

- After any change, grep the generated `dist/polyline-tools.lsp` for variables that are assigned but not declared local.
- When changing `plx:reverse-verts` or `plx:concat-verts`, re-run checks 8 and 9 - bulge direction errors only show on curved polylines.
