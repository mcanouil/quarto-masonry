function Meta(m)
  if quarto.doc.is_format("html:js") then
    quarto.doc.add_html_dependency({
      name = 'masonry',
      version = '4.2.2',
      scripts = {"masonry.pkgd.min.js"}
    })
    -- quarto.doc.include_text("in-header", "<script>var msnry = new Masonry('.grid', {itemSelector: {'.grid-item', '.quarto-grid-item'}, columnWidth: 200});</script>")
  end
end
