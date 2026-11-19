# Contributing

Thanks for helping improve PolylineTools. Bug reports, test results from other CAD products and pull requests are all welcome.

## Reporting a bug

Open an issue with the bug template. Please include the CAD product and version, the command you ran, what you expected and what happened (the command-line text helps a lot). A tiny DWG that reproduces the problem is ideal.

## Development setup

1. Fork and clone the repository.
2. Install PowerShell 7 (`pwsh`) or use Windows PowerShell 5.1.
3. Edit the modules in `src/lisp/` - never edit `dist/polyline-tools.lsp` by hand.
4. Run both scripts before you commit:

   ```powershell
   ./scripts/lint.ps1
   ./scripts/build.ps1
   ```

5. Commit the regenerated `dist/polyline-tools.lsp` together with your source change. CI fails if it is out of date.
6. Run the relevant steps of [docs/testing.md](docs/testing.md) in AutoCAD (or BricsCAD) and mention the results in the pull request.

## Code conventions

- **Prefix everything.** Functions are `plx:name`, globals are `*plx-name*`. Only commands (`c:name`) are unprefixed because the command name is the public interface.
- **ASCII only.** Source files must be pure ASCII with LF line endings. Write non-ASCII characters in strings as `\U+XXXX` escapes. The lint script enforces this.
- **User-visible text goes through `plx:msg` / `plx:say`.** Add the key to `*plx-messages*` in `00-core.lsp` with both an `"en"` and a `"tr"` entry.
- **Declare local variables.** List every variable you assign after the `/` in the `defun`; leaking globals is the most common AutoLISP bug.
- **Commands follow one pattern:** `(plx:begin ...)`, do the work, `(plx:end)`. This gives undo grouping, variable restoration and error cleanup.
- **Prefer entity data over `command`.** Use `entget`/`entmake`/`entmod` for geometry; use `command` only where AutoCAD has no data-level equivalent (`SPLINE`, `PEDIT`).
- **Keep functions small and pure where possible.** Geometry in `10-polyline.lsp` and `20-geometry.lsp` works on plain lists, which keeps it easy to reason about.
- **Comments explain why**, not what. Do not leave commented-out code.

## Adding a command

1. Put the implementation in the module that fits (or add a new `NN-name.lsp`; modules are loaded in file-name order).
2. Add its help text (`help-<command>`) to `*plx-messages*` and the command to `*plx-commands*` in `90-help.lsp`.
3. Document it in `README.md` and `README.tr.md`, add a test step to `docs/testing.md` and an entry under *Unreleased* in `CHANGELOG.md`.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `ci:`.

## Releases

1. Move the *Unreleased* entries in `CHANGELOG.md` under a new version heading.
2. Update `*plx-version*` in `src/lisp/00-core.lsp`, then run `./scripts/build.ps1`.
3. Commit, tag `vX.Y.Z` and push the tag. The release workflow publishes `polyline-tools.lsp` as a release asset.

## License

By contributing you agree that your contributions are licensed under the GNU GPL v3.0, like the rest of the project.
