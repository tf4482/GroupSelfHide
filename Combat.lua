-- Shared component: run protected work now or right after combat; copied unchanged from
-- wow-lua-house-style
-- component version: 1 (2026-11)

local _, ns = ...

-- work waiting for the end of combat, each function once
local queue = {}

-- run queued work after combat; anything blocked again stays queued
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function()
  local jobs = queue
  queue = {}
  for _, job in ipairs(jobs) do
    ns.AfterCombat(job)
  end
end)

-- run fn now, or once combat ends; queuing the same fn again is a no-op
function ns.AfterCombat(fn)
  if not InCombatLockdown() then
    return fn()
  end
  for _, job in ipairs(queue) do
    if job == fn then
      return
    end
  end
  queue[#queue + 1] = fn
end
