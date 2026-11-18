-- GroupSelfHide: hide the player's own frame in raid-style party frames

local _, ns = ...

-- compact frame name prefixes and how many of each exist
local FRAMES = { CompactPartyFrameMember = 5, CompactRaidFrameMember = 40, CompactRaidFrame = 40 }
-- modes for the settings page and the status line
local MODES = {
  { "off", "Off" },
  { "hide", "Hide own frame" },
  { "fill", "Hide own frame, widen the others" },
}

-- frames this addon hid, for a clean undo
local hidden = {}
-- party label hidden by this addon
local titleHidden = false
-- party frames resized by this addon, and the width to restore
local resized, baseWidth = false, nil
-- guard against hooks re-triggered by our own changes
local busy = false

-- raid-style, horizontal party frames outside of raids (Edit Mode settings)
local function Supported()
  if IsInRaid() or not IsInGroup() or not EditModeManagerFrame then
    return false
  end
  local party = Enum.EditModeUnitFrameSystemIndices.Party
  local raidStyle = EditModeManagerFrame:GetSettingValueBool(
    Enum.EditModeSystem.UnitFrame, party, Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames)
  return raidStyle and EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(party)
end

-- whether the feature should act now
local function Active()
  return ns.db ~= nil and ns.db.mode ~= "off" and Supported()
end

-- usable compact frame showing the player
local function IsOwn(frame)
  return frame and not frame:IsForbidden() and (frame.unit == "player" or frame.displayedUnit == "player")
end

-- usable party member frames: own one and the others
local function PartyFrames()
  local own, others = nil, {}
  for i = 1, FRAMES.CompactPartyFrameMember do
    local frame = _G["CompactPartyFrameMember" .. i]
    if IsOwn(frame) then
      own = frame
    elseif frame and not frame:IsForbidden() then
      others[#others + 1] = frame
    end
  end
  return own, others
end

-- undo only what this addon changed
local function Restore()
  for frame in pairs(hidden) do
    frame:Show()
    hidden[frame] = nil
  end
  if titleHidden then
    CompactPartyFrame.title:Show()
    titleHidden = false
  end
  if resized then
    local own, others = PartyFrames()
    if own then
      own:SetWidth(baseWidth)
    end
    for _, frame in ipairs(others) do
      frame:SetWidth(baseWidth)
    end
    resized = false
  end
end

-- hide the own frame and the "Party" label
local function Hide()
  for prefix, count in pairs(FRAMES) do
    for i = 1, count do
      local frame = _G[prefix .. i]
      if IsOwn(frame) then
        frame:Hide()
        hidden[frame] = true
      end
    end
  end
  local title = CompactPartyFrame and CompactPartyFrame.title
  if title then
    title:Hide()
    titleHidden = true
  end
end

-- shrink the own frame, widen the others so the group keeps its width (2-5 players)
local function Fill()
  local count = GetNumGroupMembers()
  local own, others = PartyFrames()
  if not own or count < 2 or count > 5 then
    return
  end
  baseWidth = own:GetWidth()
  own:SetWidth(1)
  for _, frame in ipairs(others) do
    frame:SetWidth(baseWidth * count / (count - 1))
  end
  resized = true
end

-- apply or undo the feature; only called out of combat
local function Apply()
  busy = true
  Restore()
  if Active() then
    Hide()
    if ns.db.mode == "fill" then
      Fill()
    end
  end
  busy = false
end

-- apply now, or right after combat
local function Refresh()
  ns.AfterCombat(Apply)
end

-- label of a mode
local function Label(mode)
  for _, choice in ipairs(MODES) do
    if choice[1] == mode then
      return choice[2]
    end
  end
end

-- current mode, with hints when it does not take effect yet
local function Status()
  local hint = ""
  if ns.db.mode ~= "off" and not Supported() then
    hint = ns.Color("warning", " (inactive: party with raid-style, horizontal frames only)")
  elseif InCombatLockdown() then
    hint = ns.Color("warning", " (applies after combat)")
  end
  ns.Print("mode: " .. ns.Color("value", Label(ns.db.mode)) .. hint)
end

-- set the mode and report it
local function Switch(mode)
  ns.Set("mode", mode)
  Status()
end

-- re-apply after Blizzard refreshes a compact frame
local function OnFrameUpdate(frame)
  if not busy and ns.db ~= nil and ns.db.mode ~= "off" and not frame:IsForbidden() then
    Refresh()
  end
end
hooksecurefunc("CompactUnitFrame_UpdateVisible", OnFrameUpdate)
hooksecurefunc("CompactUnitFrame_UpdateAll", OnFrameUpdate)

-- event handlers by event name
local events = {}

-- roster changed: party, raid, or member count may differ
function events.GROUP_ROSTER_UPDATE()
  Refresh()
end

-- Edit Mode layout may switch raid-style or horizontal frames
function events.EDIT_MODE_LAYOUTS_UPDATED()
  Refresh()
end

-- one frame dispatching all events above
local frame = CreateFrame("Frame")
for event in pairs(events) do
  frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event, ...)
  events[event](...)
end)

-- saved state; settings page and first apply once loaded
ns.Store("GroupSelfHideDB", { mode = "off" }, function()
  ns.Settings()
  ns.Dropdown("mode", "Mode", MODES,
    "Hide your own frame in raid-style party frames; fill also widens the other frames", Refresh)
  Refresh()
end)

-- chat commands
ns.Command({ name = "fill", help = "hide your frame and widen the others", run = function() Switch("fill") end })
ns.Command({ name = "hide", help = "hide your frame, keep the gap", run = function() Switch("hide") end })
ns.Command({ name = "off", help = "show your frame again", run = function() Switch("off") end })
ns.Command({ name = "config", help = "open the settings page", run = ns.OpenSettings })
ns.Slash("/gsh", Status)
