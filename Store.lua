-- Shared component: saved addon state with defaults; copied unchanged from wow-lua-house-style

local ADDON, ns = ...

-- defaults per bound field, for reset and settings
ns.defaults = {}

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

-- bind the SavedVariables global `name` as ns[field] (default "db"); onLoad runs once loaded
function ns.Store(name, defaults, onLoad, field)
  field = field or "db"
  ns.defaults[field] = defaults
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", function(_, _, addon)
    if addon ~= ADDON then
      return
    end
    frame:UnregisterEvent("ADDON_LOADED")
    if type(_G[name]) ~= "table" then
      _G[name] = {}
    end
    Fill(_G[name], defaults)
    ns[field] = _G[name]
    if onLoad then
      onLoad(ns[field])
    end
  end)
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
