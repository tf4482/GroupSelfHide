-- Shared component: slash command with subcommands, arguments, options, and help;
-- copied unchanged from wow-lua-house-style

local ADDON, ns = ...

-- registered subcommands, in help order
local commands = {}

-- split input into words, keeping "quoted text" together
local function Words(text)
  local words, position = {}, 1
  while true do
    local start = text:find("%S", position)
    if not start then
      return words
    end
    local finish
    if text:sub(start, start) == '"' then
      finish = text:find('"', start + 1) or #text + 1
      words[#words + 1] = text:sub(start + 1, finish - 1)
    else
      finish = (text:find("%s", start) or #text + 1) - 1
      words[#words + 1] = text:sub(start, finish)
    end
    position = finish + 1
  end
end

-- one-line usage of a subcommand
local function Usage(command)
  local parts = { ns.slash, command.name }
  for _, arg in ipairs(command.args or {}) do
    -- "||" shows as one pipe in chat
    local label = arg.choices and table.concat(arg.choices, "||") or arg.name
    parts[#parts + 1] = arg.optional and "[" .. label .. "]" or "<" .. label .. ">"
  end
  for _, option in ipairs(command.options or {}) do
    parts[#parts + 1] = "[--" .. option.name .. (option.value and "=" .. option.value or "") .. "]"
  end
  return table.concat(parts, " ")
end

-- option spec by name
local function FindOption(command, name)
  for _, option in ipairs(command.options or {}) do
    if option.name == name then
      return option
    end
  end
end

-- one argument checked against its spec; returns value or nil, problem
local function Check(spec, word)
  if spec.type == "number" then
    local number = tonumber(word)
    if not number or (spec.min and number < spec.min) or (spec.max and number > spec.max) then
      local range = spec.min and spec.max and " from " .. spec.min .. " to " .. spec.max or ""
      return nil, spec.name .. " must be a number" .. range
    end
    return number
  elseif spec.choices then
    for _, choice in ipairs(spec.choices) do
      if choice == word:lower() then
        return choice
      end
    end
    return nil, spec.name .. " must be one of " .. table.concat(spec.choices, ", ")
  end
  return word
end

-- words checked against the subcommand spec; returns args, options or nil, nil, problem
local function Parse(command, words)
  local args, options, positionals = {}, {}, {}
  for _, word in ipairs(words) do
    local name, value = word:match("^%-%-([%w%-]+)=?(.*)$")
    if not name then
      positionals[#positionals + 1] = word
    elseif not FindOption(command, name) then
      return nil, nil, "unknown option --" .. name
    else
      options[name] = value ~= "" and value or true
    end
  end
  local specs = command.args or {}
  if #positionals > #specs then
    return nil, nil, "too many arguments"
  end
  for index, spec in ipairs(specs) do
    local word = positionals[index]
    if word ~= nil then
      local value, problem = Check(spec, word)
      if value == nil then
        return nil, nil, problem
      end
      args[spec.name] = value
    elseif not spec.optional then
      return nil, nil, "missing " .. spec.name
    end
  end
  return args, options
end

-- list all subcommands with their options
local function Help()
  ns.Print("commands:")
  for _, command in ipairs(commands) do
    ns.Detail(ns.Color("command", Usage(command)) .. " - " .. command.help)
    for _, option in ipairs(command.options or {}) do
      ns.Detail("  " .. ns.Color("muted", "--" .. option.name .. " - " .. option.help))
    end
  end
  ns.Detail(ns.Color("command", ns.slash .. " help") .. " - show this help")
end

-- register a subcommand: { name, help, args, options, run(args, options) }
function ns.Command(command)
  commands[#commands + 1] = command
end

-- register the slash command (string or list of aliases); status() runs without arguments
function ns.Slash(slashes, status)
  if type(slashes) == "string" then
    slashes = { slashes }
  end
  ns.slash = slashes[1]
  local key = ADDON:upper()
  for index, slash in ipairs(slashes) do
    _G["SLASH_" .. key .. index] = slash
  end
  SlashCmdList[key] = function(msg)
    local words = Words(msg or "")
    local name = table.remove(words, 1)
    if not name then
      return status()
    end
    name = name:lower()
    if ns.Answer and ns.Answer(name) then
      return
    elseif name == "help" then
      return Help()
    end
    for _, command in ipairs(commands) do
      if command.name == name then
        local args, options, problem = Parse(command, words)
        if not args then
          return ns.Error(problem .. " - usage: " .. Usage(command))
        end
        return command.run(args, options)
      end
    end
    ns.Error("unknown command: " .. name .. " - see " .. ns.slash .. " help")
  end
end
