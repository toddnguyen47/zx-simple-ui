local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = {}
Utils47.__index = Utils47
ZxSimpleUI.Utils47 = Utils47

--- References:
--- Layers: https://wowwiki.fandom.com/wiki/XML/Layer
Utils47.LayerLevel = {"BACKGROUND", "BORDER", "ARTWORK", "OVERLAY", "HIGHLIGHT"}

---@param strInput string
---@param sep string
---@return table
function Utils47:splitString(strInput, sep)
  -- Any whitespace by default
  sep = sep or "%s"
  local pattern = "([^" .. sep .. "]+)"
  local t1 = {}
  for str1 in string.gmatch(strInput, pattern) do table.insert(t1, str1) end
  return t1
end

---@param str1 string
---@param str2 string
---@return boolean
function Utils47:stringEqualsIgnoreCase(str1, str2)
  if str1 == nil or str2 == nil then return false end
  return string.upper(str1) == string.upper(str2)
end

---@param name string
---@return string
function Utils47:getInitials(name)
  if name == "" then return name end
  local tableSeparated = self:splitString(name)
  local str1 = ""
  for i = 1, (#tableSeparated - 1) do str1 = str1 .. tableSeparated[i]:sub(1, 1) .. ". " end
  str1 = str1 .. tableSeparated[#tableSeparated]
  return str1
end

---@param list table
---Create a set from a list. The resulting set can be used like so:
---`if elem in Set then do_something() end`
function Utils47:Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

---@param list table
---@param key string
---@return table
function Utils47:setContains(list, key)
  return list[key] ~= nil
end
