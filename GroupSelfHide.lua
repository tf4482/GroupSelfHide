-- GroupSelfHide: hide the player's own compact raid/party frame

local PREFIX = "|cff33ff99GroupSelfHide|r "

-- Apply state to one compact frame (out of combat only, frames are protected)
local function Apply(frame)
  if not frame or frame:IsForbidden() or InCombatLockdown() then return end
  if frame.unit == "player" or frame.displayedUnit == "player" then
    if GroupSelfHideDB.hide then frame:Hide() else frame:Show() end
  end
end

-- Walk all known compact frames
local function ApplyAll()
  for i = 1, 5 do Apply(_G["CompactPartyFrameMember" .. i]) end
  for i = 1, 40 do Apply(_G["CompactRaidFrameMember" .. i]) end
  for i = 1, 40 do Apply(_G["CompactRaidFrame" .. i]) end
end

-- Hide again whenever Blizzard refreshes a frame
local function OnUpdate(frame)
  if GroupSelfHideDB.hide then Apply(frame) end
end
hooksecurefunc("CompactUnitFrame_UpdateVisible", OnUpdate)
hooksecurefunc("CompactUnitFrame_UpdateAll", OnUpdate)

-- Load saved state and re-apply on roster changes and after combat
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("GROUP_ROSTER_UPDATE")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:SetScript("OnEvent", function(_, event, name)
  if event == "ADDON_LOADED" then
    if name ~= "GroupSelfHide" then return end
    GroupSelfHideDB = GroupSelfHideDB or { hide = true }
  elseif GroupSelfHideDB and GroupSelfHideDB.hide then
    ApplyAll()
  end
end)

-- /gsh toggles hiding, persisted via SavedVariables
SLASH_GROUPSELFHIDE1 = "/gsh"
SlashCmdList.GROUPSELFHIDE = function()
  GroupSelfHideDB.hide = not GroupSelfHideDB.hide
  ApplyAll()
  print(PREFIX .. (GroupSelfHideDB.hide and "own frame hidden" or "own frame shown"))
end
