# `Masonry.js` Extension for Quarto

This extension provides support for [`Masonry.js`](https://masonry.desandro.com/).

> [!CAUTION]
> _**This is a work in progress repository, thus the content is highly experimental.**_

## Installation

```sh
quarto add mcanouil/quarto-masonry@0.4.0
```

This will install the extension under the `_extensions` subdirectory.  
If you're using version control, you will want to check in this directory.

## Usage

Add the `.grid` class to a fenced div to turn it into a masonry layout, and `.grid-item` to each child you want laid out.
The extension bundles `Masonry.js`, initialises it automatically on every grid, so you no longer need to write an initialisation script yourself.

### Friendly attributes

Configure a grid with friendly `masonry-*` attributes; the extension converts them into the correct `data-masonry` JSON for you.

```markdown
:::: {.grid masonry-item-selector=".grid-item" masonry-gutter="10" masonry-percent-position="true"}
::: {.grid-item}
:::
::: {.grid-item .grid-item--width2 .grid-item--height2}
:::
::: {.grid-item .grid-item--height3}
:::
::::
```

The supported attributes map to the matching [`Masonry.js` options](https://masonry.desandro.com/options.html).

| Attribute | `Masonry.js` option | Notes |
| --- | --- | --- |
| `masonry-column-width` | `columnWidth` | Number of pixels or an item selector. |
| `masonry-gutter` | `gutter` | Number of pixels or a gutter element selector. |
| `masonry-horizontal-order` | `horizontalOrder` | `true` or `false`. |
| `masonry-percent-position` | `percentPosition` | `true` or `false`. |
| `masonry-transition-duration` | `transitionDuration` | CSS time, for example `0.4s`. |
| `masonry-stagger` | `stagger` | Number of milliseconds or a CSS time. |
| `masonry-item-selector` | `itemSelector` | Defaults to `.grid-item`. |

#### Option precedence

For each Masonry.js option, the value used at render is resolved in this order, highest priority first.

1. A key explicitly set in the raw `data-masonry` JSON on the grid (never overwritten).
2. The matching `masonry-*` attribute on the grid.
3. The matching key in the document-level `masonry` metadata block.
4. The extension's built-in default (currently only `itemSelector` defaults to `.grid-item`).

### Document-level defaults

Set defaults for every grid in the document with a `masonry` metadata block, using the same option names without the `masonry-` prefix.
A per-grid attribute always overrides the document default for that option.

```yaml
---
filters:
  - masonry
masonry:
  item-selector: ".grid-item"
  gutter: 10
  percent-position: true
---
```

### Waiting for images

Set `masonry-wait-for-images="true"` on a grid (or `wait-for-images: true` in the `masonry` metadata block) to defer the layout until the images inside that grid have loaded, which prevents layout shift.
This bundles and uses [imagesLoaded](https://imagesloaded.desandro.com/).

```markdown
:::: {.grid masonry-wait-for-images="true"}
::: {.grid-item}
![](image-1.jpg)
:::
::: {.grid-item}
![](image-2.jpg)
:::
::::
```

Add `masonry-wait-for-images-timeout="3000"` on a grid (or `wait-for-images-timeout: 3000` in the metadata block) to cap how long the extension waits before running the layout anyway.
The value is in milliseconds.
If imagesLoaded never fires, the layout still runs at the timeout instead of being silently skipped.

```markdown
:::: {.grid masonry-wait-for-images="true" masonry-wait-for-images-timeout="3000"}
::: {.grid-item}
![](image-1.jpg)
:::
::::
```

### Raw JSON (still supported)

Writing the `Masonry.js` options yourself as raw `data-masonry` JSON remains supported and takes precedence.
Friendly attributes and metadata defaults merge in only for keys the JSON does not set.
See the [`Masonry.js` options](https://masonry.desandro.com/options.html) page for details.

```markdown
:::: {.grid data-masonry='{ "itemSelector": ".grid-item", "gutter": 0 }'}
::: {.grid-item}
:::
::: {.grid-item .grid-item--width2 .grid-item--height2}
:::
::: {.grid-item .grid-item--height3}
:::
::::
```

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

Output of `example.qmd`:

- [HTML](https://m.canouil.dev/quarto-masonry/)
