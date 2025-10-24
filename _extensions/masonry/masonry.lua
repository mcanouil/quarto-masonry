--[[
# MIT License
#
# Copyright (c) 2025 Mickaël Canouil
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
]]

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
