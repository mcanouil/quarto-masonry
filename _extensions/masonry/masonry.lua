--- @module masonry
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

local logging = require(quarto.utils.resolve_path('_modules/logging.lua'):gsub('%.lua$', ''))
local EXTENSION_NAME = 'masonry'

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

--- Numeric options that must be non-negative when parsed as numbers.
--- @type table<string, boolean>
local NON_NEGATIVE_NUMERIC = {
  ['column-width'] = true,
  ['gutter'] = true,
  ['stagger'] = true
}

--- Document-level state. Reset at the start of each Pandoc pass so batch
--- renders never leak state from a previous document.
--- @type table
local state = {
  meta_defaults = {},
  meta_wait_for_images = false,
  meta_wait_for_images_timeout = nil,
  imagesloaded_added = false
}

--- Reset all document-level state. Call once per document at the start of the
--- Pandoc pass.
--- @return nil
local function reset_state()
  state.meta_defaults = {}
  state.meta_wait_for_images = false
  state.meta_wait_for_images_timeout = nil
  state.imagesloaded_added = false
end

--- Add the imagesLoaded library as an HTML dependency once per document.
--- @return nil
local function ensure_imagesloaded()
  if state.imagesloaded_added then
    return
  end
  quarto.doc.add_html_dependency({
    name = 'imagesloaded',
    version = '5.0.0',
    scripts = { 'imagesloaded.pkgd.min.js' }
  })
  state.imagesloaded_added = true
end

--- Escape a string for inclusion inside a double-quoted JSON value.
--- Handles every character JSON requires escaped: backslash, double quote,
--- and all C0 control characters (U+0000 through U+001F). Anything outside
--- that range is passed through unchanged.
--- @param value string The raw string value
--- @return string The escaped string
local function escape_json_string(value)
  value = value:gsub('\\', '\\\\'):gsub('"', '\\"')
  value = value:gsub('[%z\1-\31]', function(c)
    local byte = string.byte(c)
    if byte == 8 then return '\\b' end
    if byte == 9 then return '\\t' end
    if byte == 10 then return '\\n' end
    if byte == 12 then return '\\f' end
    if byte == 13 then return '\\r' end
    return string.format('\\u%04x', byte)
  end)
  return value
end

--- Validate a numeric option value. Emits a warning when the value cannot be
--- parsed or is out of bounds; the original string is returned in either case
--- so the user retains visibility of what they supplied.
--- @param name string The friendly option name
--- @param value string The raw string value
--- @return string The original value
local function validate_numeric(name, value)
  if not NON_NEGATIVE_NUMERIC[name] then
    return value
  end
  local n = tonumber(value)
  if n == nil then
    return value
  end
  if n < 0 then
    logging.log_warning(EXTENSION_NAME,
      "Option '" .. name .. "' is negative (" .. value .. "); Masonry.js expects a non-negative value.")
  end
  return value
end

--- Validate the wait-for-images timeout. Returns nil when invalid so the
--- emitter falls back to the no-timeout behaviour. Emits a warning on every
--- invalid value with context.
--- @param raw string The raw timeout value
--- @return number|nil The validated timeout in milliseconds
local function validate_timeout(raw)
  local n = tonumber(raw)
  if n == nil then
    logging.log_warning(EXTENSION_NAME,
      "wait-for-images-timeout '" .. tostring(raw) .. "' is not a number; ignoring.")
    return nil
  end
  if n < 0 then
    logging.log_warning(EXTENSION_NAME,
      "wait-for-images-timeout (" .. tostring(n) .. ") is negative; ignoring.")
    return nil
  end
  return n
end

--- Encode a value as a JSON fragment according to the Masonry.js option kind.
--- Numbers and booleans are emitted unquoted when they parse cleanly;
--- everything else falls back to a quoted, properly escaped string.
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
        value = state.meta_defaults[name]
      end
      if value == nil then
        value = OPTION_DEFAULTS[name]
      end
      if value ~= nil then
        value = validate_numeric(name, value)
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
        state.meta_defaults[name] = pandoc.utils.stringify(config[name])
      end
    end
    if config['wait-for-images'] ~= nil then
      state.meta_wait_for_images = pandoc.utils.stringify(config['wait-for-images']) == 'true'
    end
    if config['wait-for-images-timeout'] ~= nil then
      state.meta_wait_for_images_timeout =
        validate_timeout(pandoc.utils.stringify(config['wait-for-images-timeout']))
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
  local wait_for_images = state.meta_wait_for_images
  local attr_wait = div.attributes['masonry-wait-for-images']
  if attr_wait ~= nil then
    wait_for_images = attr_wait == 'true'
    div.attributes['masonry-wait-for-images'] = nil
  end

  --- Resolve the per-grid timeout. Attribute wins over metadata.
  local timeout = state.meta_wait_for_images_timeout
  local attr_timeout = div.attributes['masonry-wait-for-images-timeout']
  if attr_timeout ~= nil then
    timeout = validate_timeout(attr_timeout)
    div.attributes['masonry-wait-for-images-timeout'] = nil
  end

  if wait_for_images and div.attributes['data-masonry'] ~= nil then
    div.attributes['data-masonry-wait-for-images'] = 'true'
    if timeout ~= nil then
      div.attributes['data-masonry-wait-for-images-timeout'] = tostring(timeout)
    end
    ensure_imagesloaded()
  end

  return div
end

--- Process the whole document: reset per-document state, gather metadata
--- defaults, convert friendly attributes on every `.grid` div, then inject
--- the Masonry.js library, the auto-initialisation script and, when image
--- loading support is requested, the imagesLoaded library as HTML dependencies
--- for HTML-based outputs.
--- @param doc pandoc.Pandoc The document
--- @return pandoc.Pandoc The processed document
local function Pandoc(doc)
  if not quarto.doc.is_format('html:js') then
    return doc
  end

  reset_state()
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
