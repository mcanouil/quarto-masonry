--- @module masonry
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

--- Process document metadata to add Masonry.js HTML dependencies.
--- Adds the Masonry layout library for HTML-based outputs to enable
--- masonry-style grid layouts in the document.
---
--- @param _m table Document metadata (unused)
--- @return nil
local function Meta(_m)
  if quarto.doc.is_format('html:js') then
    quarto.doc.add_html_dependency({
      name = 'masonry',
      version = '4.2.2',
      scripts = { 'masonry.pkgd.min.js' }
    })
    -- Alternative: Auto-initialise Masonry in header (currently disabled to allow manual initialisation)
    -- quarto.doc.include_text('in-header', '<script>var msnry = new Masonry(\'.grid\', {itemSelector: {\'.grid-item\', \'.quarto-grid-item\'}, columnWidth: 200});</script>')
  end
end

return {
  { Meta = Meta }
}
