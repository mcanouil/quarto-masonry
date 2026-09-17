# Changelog

## Unreleased

### New Features

- feat: Read the document-level defaults from `extensions.masonry` rather than from a top-level `masonry` key. An extension keeps its options at `extensions.<name>.<option>`, and the old key is removed rather than deprecated, so a document that used it must be updated. (#31)
- feat: Check the document configuration against the schema during a render, so an unrecognised option or a value of the wrong type is reported instead of ignored. `wait-for-images: yes` turned the feature off in silence, and now says so. (#31)

### Bug Fixes

- fix: Check the grid's horizontal-order, percent-position, wait-for-images and wait-for-images-timeout attributes against the schema, so a value such as a non-numeric or negative timeout is now named once instead of being silently ignored or duplicated. (#31)
- fix: Honour a case-insensitive masonry-wait-for-images attribute, so "TRUE" now switches the layout on like "true" always has. (#31)
- fix: Report a key nested inside an option as a warning rather than an error, so one nested typo does not invalidate the whole configuration. This matches how the extension already reports an unknown key at the top of its own block. (#31)

### Documentation

- docs: Serve the extension's social card as the Open Graph image, so a shared link shows the card rather than the first image on the page. (#29)

### Refactoring

- build: Update the vendored Lua modules to 2.3.0. A module no longer carries a version line in its header, so its checksum changes only when its code changes. (#30)
- build: Update the vendored Lua modules to 2.5.0, which adds the accessors that read what the schema resolves an option, an element's attributes and a format's options to. The schema validator moves to its own release train and is pinned at `schema-v2.2.0`, which accepts only `true` and `false` as a boolean. (#31)

## 0.4.1 (2026-08-01)

### Bug Fixes

- fix: Merge the friendly attributes and document defaults into a grid that already carries raw `data-masonry` JSON. The merged object was computed and then discarded whenever raw JSON was present, so `itemSelector` and every other default was silently dropped for those grids. Keys written in the raw JSON are still never overwritten.

### Documentation

- docs: Add a documentation website under `docs/`, built on the `atelier` project type and published to <https://m.canouil.dev/quarto-masonry/>.
- docs: Trim `README.md` to a landing page pointing at the website, and `example.qmd` to a short starting point to copy.
- docs: Add the Pages workflow, which renders `docs/` on pull requests and deploys it from the release tag.
- docs: Add the Quarto Extensions Updates workflow, scanning `docs` for the website's own dependencies.

## 0.4.0 (2026-05-31)

### New Features

- feat: Add `masonry-wait-for-images-timeout` attribute and matching metadata key with an automatic layout fallback when imagesLoaded never fires.

### Bug Fixes

- fix: Reset module-level state at the start of each Pandoc pass so batch renders do not leak metadata defaults, wait-for-images settings, or the imagesLoaded dependency flag between documents.
- fix: Escape control characters (newline, tab, carriage return, and the full C0 range) in `data-masonry` JSON strings; previously a value containing a literal newline produced invalid JSON.

### Enhancements

- enh: Warn via `quarto.log.warning` when a numeric option (`column-width`, `gutter`, `stagger`) is negative, and when `wait-for-images-timeout` is non-numeric or negative.

### Documentation

- docs: Document the `data-masonry` JSON > friendly attribute > metadata default > built-in default precedence in the README.
- docs: Add friendly `masonry-*` attributes and the new timeout option to `_schema.yml` for IDE autocompletion.
- docs: Extend `example.qmd` to cover the precedence rules and the wait-for-images-timeout option.

## 0.3.0 (2026-05-24)

### New Features

- feat: Add friendly `masonry-*` attributes on `.grid` divs that generate the `data-masonry` JSON automatically.
- feat: Add a document-level `masonry` metadata block providing defaults for every grid.
- feat: Auto-initialise Masonry on every grid via a bundled `masonry-init.js`, so a manual init script is no longer required.
- feat: Add opt-in `wait-for-images` support that defers layout until images load, bundling imagesLoaded 5.0.0.

## 0.2.0 (2026-02-21)

### New Features

- feat: Add _schema.yml for configuration validation and IDE support (#13).

## 0.1.1 (2026-02-11)

### Bug Fixes

- fix: Update copyright year.

## 0.1.0 (2025-11-30)

### New Features

- feat: Add author information and enhance format settings.
- feat: Add CITATION file for project citation.

### Bug Fixes

- fix: Enhance masonry extension with meta function and update example.
- fix: Example.
- fix: Switch to deploy from GitHub Actions (#6).
- fix: Rm gutter option.

### Documentation

- docs: Correct section headings in README.
- docs: Clarify output description in README.
- docs: Update function documentation for Meta.
- docs: Use caution markdown syntax.
- docs: Update quarto command.
- docs: Add prefix.
- docs: Add note about this being WIP.
- docs: Show w/o masonry.js activated.
- docs: Add example.

### Style

- style: Standardise string quotes in masonry.lua.
- style: Format code and improve readability.
- style: Add italics.
