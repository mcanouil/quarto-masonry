# Changelog

## Unreleased

## 0.4.0 (2026-05-28)

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
