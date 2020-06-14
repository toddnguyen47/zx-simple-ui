local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")

local CoreOptions47 = {}
CoreOptions47.__index = CoreOptions47
CoreOptions47.OPTION_NAME = "CoreOptions47"
ZxSimpleUI.optionTables[CoreOptions47.OPTION_NAME] = CoreOptions47

---@param curModule table
function CoreOptions47:__init__(curModule)
  self._curModule = curModule
  self._curDbProfile = self._curModule.db.profile
  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX
end

---@param curModule table
function CoreOptions47:new(curModule)
  assert(curModule ~= nil)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(curModule)
  return newInstance
end

---@param info table
---Ref: https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function CoreOptions47:getOption(info)
  local keyLeafNode = info[#info]
  return self._curDbProfile[keyLeafNode]
end

---@param info table
---@param value any
---Ref: https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function CoreOptions47:setOption(info, value)
  local keyLeafNode = info[#info]
  self._curDbProfile[keyLeafNode] = value
  self._curModule:refreshConfig()
end

function CoreOptions47:getShownOption(info) return self:getOption(info) end

---@param info table
---@param value boolean
---Set the shown option.
function CoreOptions47:setShownOption(info, value)
  self:setOption(info, value)
  if (value == true) then
    self._curModule:handleShownOption()
  else
    self._curModule:handleShownHideOption()
  end
end

---@param info table
function CoreOptions47:getOptionColor(info) return unpack(self:getOption(info)) end

---@param info table
function CoreOptions47:setOptionColor(info, r, g, b, a) self:setOption(info, {r, g, b, a}) end

function CoreOptions47:incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end

---@return table
function CoreOptions47:getCurrentModule() return self._curModule end
