-- Luacheck settings: catch accidental globals, unknown API names, and unused variables
std = "lua51"
max_line_length = false
exclude_files = { "Libs/", ".release/" }
-- globals the addon writes; append its BINDING_* names
globals = {
  "SlashCmdList",
}
-- WoW API read by the shared components and template; append every global the addon reads
read_globals = {
  "AddonCompartmentFrame",
  "C_AddOns",
  "C_EventUtils",
  "C_KeyBindings",
  "CreateFrame",
  "CreateKeybindingEntryInitializer",
  "CreateSettingsListSectionHeaderInitializer",
  "GetLocale",
  "GetTime",
  "hooksecurefunc",
  "InCombatLockdown",
  "IsInGroup",
  "IsInInstance",
  "IsInRaid",
  "MinimalSliderWithSteppersMixin",
  "Settings",
  "SettingsDropdownControlMixin",
  "C_Timer",
  "CompactPartyFrame",
  "EditModeManagerFrame",
  "Enum",
  "GetNumGroupMembers",
}
