-- GroupSelfHide: hide the player's own compact raid/party frame

local PREFIX = "|cff33ff99GroupSelfHide|r "

-- Apply state to one compact frame (out of combat only, frames are protected)
local function Apply(frame)
  if not frame or frame:IsForbidden() or InCombatLockdown() then return end
  if frame.unit == "player" or frame.displayedUnit == "player" then
    if GroupSelfHideDB.hide then frame:Hide() else frame:Show() end
  end
end

-- Show or hide the "Party" label with the own frame
local function ApplyTitle()
  local title = CompactPartyFrame and CompactPartyFrame.title
  if title then title:SetShown(not GroupSelfHideDB.hide) end
end

-- Fill mode: shrink own frame, widen the others so the group keeps its width
local baseWidth, busy
local function ApplySizes()
  if busy or InCombatLockdown() then return end
  local me, others = nil, {}
  for i = 1, 5 do
    local f = _G["CompactPartyFrameMember" .. i]
    if f and not f:IsForbidden() then
      if f.unit == "player" or f.displayedUnit == "player" then me = f else others[#others + 1] = f end
    end
  end
  if not me then return end
  local w = me:GetWidth()
  if w > 2 then baseWidth = w end -- real width, not our shrunk one
  if not baseWidth then return end
  local n = GetNumGroupMembers()
  local fill = GroupSelfHideDB.hide and GroupSelfHideDB.fill and n > 1 and n <= 5
  busy = true -- SetWidth may re-trigger Blizzard updates
  me:SetWidth(fill and 1 or baseWidth)
  for _, f in ipairs(others) do f:SetWidth(fill and baseWidth * n / (n - 1) or baseWidth) end
  busy = false
end

-- Walk all known compact frames
local function ApplyAll()
  ApplyTitle()
  ApplySizes()
  for i = 1, 5 do Apply(_G["CompactPartyFrameMember" .. i]) end
  for i = 1, 40 do Apply(_G["CompactRaidFrameMember" .. i]) end
  for i = 1, 40 do Apply(_G["CompactRaidFrame" .. i]) end
end

-- Hide again whenever Blizzard refreshes a frame
local function OnUpdate(frame)
  if GroupSelfHideDB.hide then Apply(frame) ApplyTitle() ApplySizes() end
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
    GroupSelfHideDB = GroupSelfHideDB or { hide = true, fill = false }
  elseif GroupSelfHideDB and GroupSelfHideDB.hide then
    ApplyAll()
  end
end)

-- Short usage text in the client language (German, else English)
local function PrintHelp()
  if GetLocale() == "deDE" then
    print(PREFIX .. "/gsh - umschalten | hide - nur eigenen Frame ausblenden | fill - ausblenden und andere verbreitern")
  else
    print(PREFIX .. "/gsh - toggle | hide - only hide own frame | fill - hide and widen others")
  end
end

-- /gsh toggles, /gsh hide and /gsh fill set the mode, persisted via SavedVariables
SLASH_GROUPSELFHIDE1 = "/gsh"
SlashCmdList.GROUPSELFHIDE = function(msg)
  msg = strlower(strtrim(msg or ""))
  if msg == "help" then return PrintHelp() end
  if msg == "hide" then
    GroupSelfHideDB.hide, GroupSelfHideDB.fill = true, false
  elseif msg == "fill" then
    GroupSelfHideDB.hide, GroupSelfHideDB.fill = true, true
  else
    GroupSelfHideDB.hide = not GroupSelfHideDB.hide
  end
  ApplyAll()
  print(PREFIX .. (not GroupSelfHideDB.hide and "own frame shown"
    or GroupSelfHideDB.fill and "own frame hidden, others widened (fill)" or "own frame hidden (hide)"))
end
