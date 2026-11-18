-- Shared component: colored chat output; copied unchanged from wow-lua-house-style

local ADDON, ns = ...

-- chat colors by meaning
local COLORS = {
  name = "33ff99",
  command = "00ccff",
  value = "ffffff",
  success = "40ff40",
  muted = "999999",
  warning = "ffd100",
  error = "ff4040",
}

-- text wrapped in a named color
function ns.Color(color, text)
  return "|cff" .. COLORS[color] .. tostring(text) .. "|r"
end

-- colored on/off for a boolean state
function ns.OnOff(enabled)
  return enabled and ns.Color("success", "on") or ns.Color("muted", "off")
end

-- one chat line behind the colored addon name
function ns.Print(text)
  print(ns.Color("name", ADDON) .. " " .. text)
end

-- indented follow-up line without prefix, for lists and help
function ns.Detail(text)
  print("  " .. text)
end

-- label and highlighted value
function ns.Status(label, value)
  ns.Print(label .. ": " .. ns.Color("value", value))
end

-- green result line
function ns.Success(text)
  ns.Print(ns.Color("success", text))
end

-- yellow warning line
function ns.Warn(text)
  ns.Print(ns.Color("warning", text))
end

-- red error line
function ns.Error(text)
  ns.Print(ns.Color("error", text))
end
