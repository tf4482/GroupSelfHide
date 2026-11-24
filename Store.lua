-- Shared component: saved addon state with defaults; copied unchanged from wow-lua-house-style
-- component version: 2 (2026-11)

local ADDON, ns = ...

-- defaults per bound field, for reset and settings
ns.defaults = {}
-- stores to bind on load, in declaration order
local stores = {}

-- copy missing default keys into target, recursively
local function Fill(target, defaults)
  for key, value in pairs(defaults) do
    if type(value) == "table" then
      if type(target[key]) ~= "table" then
        target[key] = {}
      end
      Fill(target[key], value)
    elseif target[key] == nil then
      target[key] = value
    end
  end
end

-- bind every store first, then run the onLoad callbacks, so each sees all stores
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addon)
  if addon ~= ADDON then
    return
  end
  frame:UnregisterEvent("ADDON_LOADED")
  for _, store in ipairs(stores) do
    if type(_G[store.name]) ~= "table" then
      _G[store.name] = {}
    end
    Fill(_G[store.name], ns.defaults[store.field])
    ns[store.field] = _G[store.name]
  end
  for _, store in ipairs(stores) do
    if store.onLoad then
      store.onLoad(ns[store.field])
    end
  end
end)

-- bind the SavedVariables global `name` as ns[field] (default "db"); onLoad runs once loaded;
-- a second call for the same field adds its defaults
function ns.Store(name, defaults, onLoad, field)
  field = field or "db"
  local known = ns.defaults[field] or {}
  for key, value in pairs(defaults) do
    known[key] = value
  end
  ns.defaults[field] = known
  table.insert(stores, { name = name, field = field, onLoad = onLoad })
end

-- restore the defaults of ns[field] in place, so references stay valid
function ns.ResetStore(field)
  field = field or "db"
  local db = ns[field]
  for key in pairs(db) do
    db[key] = nil
  end
  Fill(db, ns.defaults[field])
end
