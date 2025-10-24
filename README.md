# `Masonry.js` Extension for Quarto

This extension provides support for [`Masonry.js`](https://masonry.desandro.com/).

> [!CAUTION]
> _**This is a work in progress repository, thus the content is highly experimental.**_

## Installing

```sh
quarto add mcanouil/quarto-masonry
```

This will install the extension under the `_extensions` subdirectory.  
If you're using version control, you will want to check in this directory.

## Using

Activate `Masonry.js` in HTML/Markdown using `data-masonry='{ "itemSelector": ".grid-item"}'` in fenced divs with proper item selector to only rearrange a subset of elements.  
See [`Masonry.js` options](https://masonry.desandro.com/options.html) page for details.

```markdown
:::: {.grid data-masonry='{ "itemSelector": ".grid-item" }'}
::: {.grid-item}
:::
::: {.grid-item .grid-item--width2 .grid-item--height2}
:::
::: {.grid-item .grid-item--height3}
:::
::: {.grid-item .grid-item--height2}
:::
::: {.grid-item .grid-item--width3}
:::
::: {.grid-item}
:::
::: {.grid-item}
:::
::::
```

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

Output of `example.qmd`:

- [HTML](https://m.canouil.dev/quarto-masonry/)
