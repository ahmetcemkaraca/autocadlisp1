# Architecture

PolylineTools is plain AutoLISP organised into small modules. `scripts/build.ps1` concatenates `src/lisp/*.lsp` in file-name order into `dist/polyline-tools.lsp`, so later modules may use anything defined in earlier ones.

## Modules

| Module | Responsibility |
| --- | --- |
| `00-core.lsp` | Version, settings, the EN/TR message table (`plx:msg`, `plx:fmt`, `plx:say`), the environment guard (`plx:begin` / `plx:end` / `plx:error`) and tiny list helpers. |
| `10-polyline.lsp` | Polyline model: classification predicates, reading vertices from `LWPOLYLINE` and `POLYLINE`, writing an `LWPOLYLINE`, copying properties, reversing and joining vertex lists. |
| `20-geometry.lsp` | Bulge arc math and conversion of a vertex list into a flat list of points. |
| `30-curve.lsp` | `PL2CURVE`, `SMOOTHPL`, `FITCURVE`. |
| `40-join.lsp` | `JOINPL`, `AUTOJOINPL`, `SETTOL`. |
| `50-number.lsp` | `NUMBER`. |
| `90-help.lsp` | `PLXHELP`, `PLXLANG`, the load banner. |

## Data model

A polyline is a list of vertices `(POINT . BULGE)`:

```lisp
(((0.0 0.0 0.0) . 0.0)        ; straight segment to the next vertex
 ((5.0 0.0 0.0) . 0.5)        ; arc segment (bulge 0.5) to the next vertex
 ((5.0 5.0 0.0) . 0.0))       ; last vertex of an open polyline
```

- The bulge of a vertex belongs to the segment *starting* at that vertex - the same convention DXF uses.
- Points are 3D and in the polyline's OCS (`plx:space` returns the coordinate system to hand to `trans`).
- Reversing a polyline reverses the vertices, negates the bulges and shifts them to the vertex that now starts each segment (`plx:reverse-verts`).

Joining operates purely on these lists (`plx:join-verts`, `plx:merge-chains`); only the final result touches the drawing database (`plx:make-lwpolyline`).

## Arc sampling

For a segment from `P1` to `P2` with bulge `b`:

- sweep angle = `4 * atan(b)` (signed; positive = counter-clockwise)
- the centre lies on the perpendicular bisector of the chord at the signed distance `chord * (1 - b^2) / (4 * b)` to the left of `P1 -> P2`
- interior points are placed at equal angular steps of at most 10 degrees (`*plx-arc-step*`)

## Command lifecycle

```text
(plx:begin snap-off)   save CMDECHO/OSMODE/SPLMETHOD, start UNDO group, install *error*
        ... work ...
(plx:end)              end UNDO group, restore variables and the previous *error*
```

If the user presses `ESC` or an error occurs, `plx:error` cancels any running command, prints the message (except for plain cancellation) and calls `plx:end`, so the drawing is never left with an open undo group or changed system variables.

## Messages and encoding

All text shown to the user lives in `*plx-messages*`, keyed by symbol, with an `"en"` and a `"tr"` entry. `plx:fmt` substitutes `%1`, `%2`, ... with arguments. Source files are ASCII only; Turkish characters are written as `\U+XXXX` escapes, which AutoCAD expands when the string is read.

## Known limitations

- `JOINPL` / `AUTOJOINPL` handle only open, flat polylines and always produce an `LWPOLYLINE`.
- Width information of polylines is not carried over when joining.
- `PL2CURVE` builds the spline through the `SPLINE` command, so it depends on the command's prompt sequence of the CAD product (the sequence used here matches AutoCAD 2013 and newer).
- No automated tests run inside a CAD product; `docs/testing.md` is the manual test plan.
