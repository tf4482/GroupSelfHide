-- GroupSelfHide: hide the player's own compact party frame

local PREFIX = "|cff33ff99GroupSelfHide|r "
local hiddenByUs = {} -- frames we hid, to undo later
local titleHidden, resized, baseWidth, busy

-- Mode is nil (off), "hide" or "fill"
local function Active()
  return GroupSelfHideDB and GroupSelfHideDB.mode ~= nil
end

-- Hide or restore one compact frame (out of combat only, frames are protected)
local function Apply(frame)
  if not frame or frame:IsForbidden() or InCombatLockdown() then return end
  if frame.unit ~= "player" and frame.displayedUnit ~= "player" then return end
  if Active() then
    hiddenByUs[frame] = true
    frame:Hide()
  elseif hiddenByUs[frame] then
    hiddenByUs[frame] = nil
    frame:Show()
  end
end

-- Hide the "Party" label with the own frame, restore it afterwards
local function ApplyTitle()
  local title = CompactPartyFrame and CompactPartyFrame.title
  if not title then return end
  if Active() then
    titleHidden = true
    title:Hide()
  elseif titleHidden then
    titleHidden = false
    title:Show()
  end
end

-- Fill mode: shrink own frame, widen the others so the group keeps its width
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
  local fill = Active() and GroupSelfHideDB.mode == "fill" and n > 1 and n <= 5
  if not fill and not resized then return end
  resized = fill
  busy = true -- SetWidth may re-trigger Blizzard updates
  me:SetWidth(fill and 1 or baseWidth)
  for _, f in ipairs(others) do f:SetWidth(fill and baseWidth * n / (n - 1) or baseWidth) end
  busy = false
end

-- Apply state to all known frames
local function ApplyAll()
  ApplyTitle()
  ApplySizes()
  for i = 1, 5 do Apply(_G["CompactPartyFrameMember" .. i]) end
  for i = 1, 40 do Apply(_G["CompactRaidFrameMember" .. i]) end
  for i = 1, 40 do Apply(_G["CompactRaidFrame" .. i]) end
end

-- Re-apply whenever Blizzard refreshes a frame
local function OnUpdate(frame)
  if Active() then Apply(frame) ApplyTitle() ApplySizes() end
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
    GroupSelfHideDB = GroupSelfHideDB or {}
  else
    ApplyAll()
  end
end)

-- /gsh = fill mode, /gsh hide = hide mode; any command while a mode is on turns it off
SLASH_GROUPSELFHIDE1 = "/gsh"
SlashCmdList.GROUPSELFHIDE = function(msg)
  local want = strlower(strtrim(msg or "")) == "hide" and "hide" or "fill"
  GroupSelfHideDB.mode = (not GroupSelfHideDB.mode) and want or nil
  ApplyAll()
  local mode = GroupSelfHideDB.mode
  print(PREFIX .. (mode == "fill" and "own frame hidden, others widened (fill)"
    or mode == "hide" and "own frame hidden (hide)" or "own frame shown"))
end
