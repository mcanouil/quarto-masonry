# `Masonry.js` Extension for Quarto

This extension provides support for [`Masonry.js`](https://masonry.desandro.com/): a fenced div with the `.grid` class becomes a cascading grid, and its options are written as ordinary attributes rather than as a JSON blob.

> [!CAUTION]
> _**This is a work in progress repository, thus the content is highly experimental.**_

## Installation

```sh
quarto add mcanouil/quarto-masonry@0.4.1
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Documentation

The full documentation lives at <https://m.canouil.dev/quarto-masonry/>: every attribute and the Masonry.js option it maps to, document-level defaults, the precedence between them, waiting for images, and working grids you can resize the window against.

[`example.qmd`](example.qmd) is a short, standalone starting point you can copy.

## Licence

[MIT](https://github.com/mcanouil/quarto-masonry?tab=MIT-1-ov-file#readme).
