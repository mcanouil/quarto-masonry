--- @module masonry
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

--- Mapping from friendly attribute/metadata names to Masonry.js option keys.
--- Keys are the friendly names (without the 'masonry-' attribute prefix);
--- values describe the camelCase Masonry.js option and how to encode it as JSON.
--- @type table<string, table>
local OPTION_MAP = {
  ['column-width'] = { key = 'columnWidth', kind = 'number-or-string' },
  ['gutter'] = { key = 'gutter', kind = 'number-or-string' },
  ['horizontal-order'] = { key = 'horizontalOrder', kind = 'boolean' },
  ['percent-position'] = { key = 'percentPosition', kind = 'boolean' },
  ['transition-duration'] = { key = 'transitionDuration', kind = 'string' },
  ['stagger'] = { key = 'stagger', kind = 'number-or-string' },
  ['item-selector'] = { key = 'itemSelector', kind = 'string' }
}

--- Default Masonry.js options applied when neither attribute nor metadata sets them.
--- @type table<string, string>
local OPTION_DEFAULTS = {
  ['item-selector'] = '.grid-item'
}

--- Document-level defaults gathered from the `masonry` metadata block.
--- @type table<string, string>
local meta_defaults = {}

--- Whether imagesLoaded support is requested by document metadata.
--- @type boolean
local meta_wait_for_images = false

--- Whether the imagesLoaded HTML dependency has already been injected.
--- @type boolean
local imagesloaded_added = false

--- Add the imagesLoaded library as an HTML dependency once per document.
--- @return nil
local function ensure_imagesloaded()
  if imagesloaded_added then
    return
  end
  quarto.doc.add_html_dependency({
    name = 'imagesloaded',
    version = '5.0.0',
    scripts = { 'imagesloaded.pkgd.min.js' }
  })
  imagesloaded_added = true
end

--- Escape a string for inclusion inside a double-quoted JSON value.
--- @param value string The raw string value
--- @return string The escaped string
local function escape_json_string(value)
  return value:gsub('\\', '\\\\'):gsub('"', '\\"')
end

--- Encode a value as a JSON fragment according to the Masonry.js option kind.
--- Numbers and booleans are emitted unquoted when they parse cleanly;
--- everything else falls back to a quoted string.
--- @param kind string The option kind ('number-or-string', 'boolean' or 'string')
--- @param value string The raw string value
--- @return string The JSON-encoded value
local function encode_value(kind, value)
  if kind == 'boolean' then
    if value == 'true' or value == 'false' then
      return value
    end
    return '"' .. escape_json_string(value) .. '"'
  end
  if kind == 'number-or-string' and tonumber(value) ~= nil then
    return value
  end
  return '"' .. escape_json_string(value) .. '"'
end

--- Extract the keys already present in a raw `data-masonry` JSON string.
--- Detection is intentionally lightweight: it looks for "key": tokens so that
--- explicit user-supplied options are never overwritten by friendly attributes.
--- @param raw string|nil The raw JSON string from the `data-masonry` attribute
--- @return table<string, boolean> Set of Masonry.js option keys already present
local function existing_json_keys(raw)
  local keys = {}
  if not raw then
    return keys
  end
  for key in raw:gmatch('"([%w_%-]+)"%s*:') do
    keys[key] = true
  end
  return keys
end

--- Build a `data-masonry` JSON object string from friendly options.
--- Merges, in order of decreasing priority: keys already present in the raw
--- JSON, per-element friendly attributes, document metadata defaults, and the
--- built-in defaults. Explicit raw JSON keys are never overwritten.
--- @param attributes table<string, string> Friendly attribute values (without prefix)
--- @param raw_json string|nil The raw `data-masonry` JSON already on the element
--- @return string|nil The merged JSON object string, or nil when nothing to add
local function build_data_masonry(attributes, raw_json)
  local present = existing_json_keys(raw_json)
  local fragments = {}
  for name, spec in pairs(OPTION_MAP) do
    if not present[spec.key] then
      local value = attributes[name]
      if value == nil then
        value = meta_defaults[name]
      end
      if value == nil then
        value = OPTION_DEFAULTS[name]
      end
      if value ~= nil then
        fragments[#fragments + 1] = '"' .. spec.key .. '": ' .. encode_value(spec.kind, value)
      end
    end
  end
  if #fragments == 0 then
    return nil
  end
  table.sort(fragments)
  return '{ ' .. table.concat(fragments, ', ') .. ' }'
end

--- Read the `masonry` metadata block into the document-level defaults.
--- @param meta pandoc.Meta Document metadata
--- @return nil
local function read_metadata(meta)
  local config = meta['masonry']
  if config and type(config) == 'table' then
    for name, _ in pairs(OPTION_MAP) do
      if config[name] ~= nil then
        meta_defaults[name] = pandoc.utils.stringify(config[name])
      end
    end
    if config['wait-for-images'] ~= nil then
      meta_wait_for_images = pandoc.utils.stringify(config['wait-for-images']) == 'true'
    end
  end
end

--- Convert friendly attributes on a `.grid` div into a `data-masonry` JSON
--- object and enable image loading support when requested. Explicit raw
--- `data-masonry` JSON is preserved as the source of truth, with friendly
--- attributes and metadata defaults merging in for any keys it does not set.
--- @param div pandoc.Div The candidate grid element
--- @return pandoc.Div The processed element
local function process_grid(div)
  if not div.classes:includes('grid') then
    return div
  end

  --- @type table<string, string> Friendly attribute values keyed without prefix
  local attributes = {}
  for name, _ in pairs(OPTION_MAP) do
    local value = div.attributes['masonry-' .. name]
    if value ~= nil then
      attributes[name] = value
      div.attributes['masonry-' .. name] = nil
    end
  end

  local raw_json = div.attributes['data-masonry']
  local data_masonry = build_data_masonry(attributes, raw_json)
  if raw_json == nil and data_masonry ~= nil then
    div.attributes['data-masonry'] = data_masonry
  end

  --- @type boolean Whether this grid should defer layout until images load
  local wait_for_images = meta_wait_for_images
  local attr_wait = div.attributes['masonry-wait-for-images']
  if attr_wait ~= nil then
    wait_for_images = attr_wait == 'true'
    div.attributes['masonry-wait-for-images'] = nil
  end
  if wait_for_images and div.attributes['data-masonry'] ~= nil then
    div.attributes['data-masonry-wait-for-images'] = 'true'
    ensure_imagesloaded()
  end

  return div
end

--- Process the whole document: gather metadata defaults, convert friendly
--- attributes on every `.grid` div, then inject the Masonry.js library, the
--- auto-initialisation script and, when image loading support is requested,
--- the imagesLoaded library as HTML dependencies for HTML-based outputs.
--- @param doc pandoc.Pandoc The document
--- @return pandoc.Pandoc The processed document
local function Pandoc(doc)
  if not quarto.doc.is_format('html:js') then
    return doc
  end

  read_metadata(doc.meta)
  doc.blocks = doc.blocks:walk({ Div = process_grid })

  quarto.doc.add_html_dependency({
    name = 'masonry',
    version = '4.2.2',
    scripts = { 'masonry.pkgd.min.js' }
  })
  quarto.doc.add_html_dependency({
    name = 'masonry-init',
    version = '4.2.2',
    scripts = { 'masonry-init.js' }
  })

  return doc
end

return {
  { Pandoc = Pandoc }
}
