-- Shared component: Blizzard settings page and addon compartment entry with account or
-- per-character settings; copied unchanged from wow-lua-house-style
-- component version: 3 (2026-11)

local ADDON, ns = ...

-- localized fixed string from Locale.lua, else English
local function T(text)
  return ns.L and ns.L[text] or text
end

-- settings category of this addon and its vertical layout
local category, layout
-- settings bound to the active profile, refreshed when it switches
local bound = {}
-- default of each bound key, for reset
local boundDefaults = {}

-- per-character state: profile switch and the character's own setting values
ns.Store(ADDON .. "CharDB", { perCharacter = false }, nil, "char")

-- TOC field of this addon
local function Meta(field)
  return C_AddOns.GetAddOnMetadata(ADDON, field)
end

-- table holding the setting values now: character or account
local function Profile()
  if ns.char.perCharacter then
    return ns.char
  end
  return ns.db
end

-- whether a key belongs to a "char" store only, so it ignores the profile switch
local function CharOnly(key)
  return ns.defaults.db[key] == nil
end

-- current value of a setting; unset character values fall back to the account
function ns.Get(key)
  if CharOnly(key) then
    return ns.char[key]
  end
  local value = Profile()[key]
  if value == nil then
    value = ns.db[key]
  end
  return value
end

-- open the settings page
function ns.OpenSettings()
  Settings.OpenToCategory(category:GetID())
end

-- change a setting from chat; updates the active profile and the page, runs onChange
function ns.Set(key, value)
  Settings.SetValue(ADDON .. "_" .. key, value)
end

-- reset every bound setting of the active profile to its default; other data stays
function ns.ResetSettings()
  for key, default in pairs(boundDefaults) do
    ns.Set(key, default)
  end
end

-- create the settings page with the per-character checkbox and the compartment entry;
-- call once ns.db is loaded
function ns.Settings()
  local title = Meta("Title") or ADDON
  category, layout = Settings.RegisterVerticalLayoutCategory(title)
  Settings.RegisterAddOnCategory(category)
  ns.Category = category
  local profile = Settings.RegisterAddOnSetting(category, ADDON .. "_perCharacter",
    "perCharacter", ns.char, "boolean", T("Per character"), false)
  -- show and apply the values of the new profile
  profile:SetValueChangedCallback(function()
    for _, setting in ipairs(bound) do
      setting:NotifyUpdate()
    end
  end)
  Settings.CreateCheckbox(category, profile,
    T("Save the settings below for this character only instead of the whole account"))
  if AddonCompartmentFrame then
    AddonCompartmentFrame:RegisterAddon({
      text = title,
      icon = Meta("IconTexture"),
      notCheckable = true,
      func = ns.OpenSettings,
    })
  end
end

-- bind a setting key of the active profile (or of ns.char for char-only keys) with its
-- Store default; onChange(value) runs after each change and profile switch
local function Bind(key, label, onChange)
  local charOnly = CharOnly(key)
  local default = charOnly and ns.defaults.char[key] or ns.defaults.db[key]
  local setting = Settings.RegisterProxySetting(category, ADDON .. "_" .. key, type(default),
    label, default,
    function() return ns.Get(key) end,
    function(value) (charOnly and ns.char or Profile())[key] = value end)
  if onChange then
    setting:SetValueChangedCallback(function(_, value)
      onChange(value)
    end)
  end
  table.insert(bound, setting)
  boundDefaults[key] = default
  return setting
end

-- checkbox for a boolean key
function ns.Checkbox(key, label, tooltip, onChange)
  Settings.CreateCheckbox(category, Bind(key, label, onChange), tooltip)
end

-- slider for a number key
function ns.Slider(key, label, min, max, step, tooltip, onChange)
  local options = Settings.CreateSliderOptions(min, max, step)
  options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
  Settings.CreateSlider(category, Bind(key, label, onChange), options, tooltip)
end

-- dropdown for a key; choices is a list of { value, label }
function ns.Dropdown(key, label, choices, tooltip, onChange)
  local function Options()
    local container = Settings.CreateControlTextContainer()
    for _, choice in ipairs(choices) do
      container:Add(choice[1], choice[2])
    end
    return container:GetData()
  end
  Settings.CreateDropdown(category, Bind(key, label, onChange), Options, tooltip)
end

-- section header above the following controls
function ns.Header(text)
  layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
end

-- keybinding row for a binding from Bindings.xml; label is also a search tag
function ns.Keybinding(bindingName, label)
  local index = C_KeyBindings.GetBindingIndex(bindingName)
  if index then
    local initializer = CreateKeybindingEntryInitializer(index, true)
    initializer:AddSearchTags(label)
    layout:AddInitializer(initializer)
  end
end
