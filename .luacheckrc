-- Luacheck settings: catch accidental globals and unused variables
std = "lua51"
max_line_length = false
exclude_files = { "Libs/", ".release/" }
-- WoW API reads stay unlisted; writes to undeclared globals still fail
ignore = { "113" }
-- globals the addon may write
globals = { "SlashCmdList" }
