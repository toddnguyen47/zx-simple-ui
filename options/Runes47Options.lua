local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")

local Runes47Options = {}
Runes47Options.__index = Runes47Options
Runes47Options.OPTION_NAME = "Runes47Options"
ZxSimpleUI.optionTables[Runes47Options.OPTION_NAME] = Runes47Options

---@param runesModule table
function Runes47Options:new(runesModule)
  assert(runesModule ~= nil)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(runesModule)
  return newInstance
end

function Runes47Options:__init__(runesModule)
  self.options = {}
  self._runesModule = runesModule
  self._curDbProfile = self._runesModule.db.profile
  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX
end

function Runes47Options:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._runesModule.MODULE_NAME, self:getOptionTable(),
    self._runesModule.DECORATIVE_NAME)
end

---@return table
function Runes47Options:getOptionTable()
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = self._runesModule.DECORATIVE_NAME,
      --- "Parent" get/set
      get = function(info) return self:_getOption(info) end,
      set = function(info, value) self:_setOption(info, value) end,
      args = {
        header = {
          type = "header",
          name = self._runesModule.DECORATIVE_NAME,
          order = ZxSimpleUI.HEADER_ORDER_INDEX
        },
        enabledToggle = {
          type = "toggle",
          name = "Enable",
          desc = "Enable / Disable this module",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 1,
          disabled = function(info) return self._curDbProfile.showbar end
        },
        showbar = {
          type = "toggle",
          name = "Show Display",
          desc = "Show/Hide the Runes Display",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 2,
          get = function(info) return self:_getShownOption(info) end,
          set = function(info, value) self:_setShownOption(info, value) end
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self:_incrementOrderIndex()
        },
        height = {
          name = "Rune Height",
          desc = "Rune display height",
          type = "range",
          min = 2,
          max = 20,
          step = 1,
          order = self:_incrementOrderIndex()
        },
        horizGap = {
          name = "Horizontal Gap",
          desc = "Horizontal Gap between each rune",
          type = "range",
          min = 0,
          max = 30,
          step = 1,
          order = self:_incrementOrderIndex()
        },
        yoffset = {
          name = "Y Offset",
          desc = "Y Offset",
          type = "range",
          min = -30,
          max = 30,
          step = 1,
          order = self:_incrementOrderIndex()
        },
        runeCooldownAlpha = {
          name = "Rune Cooldown Alpha",
          desc = "Rune Cooldown Alpha Level",
          type = "range",
          min = 0,
          max = 0.9,
          step = 0.05,
          order = self:_incrementOrderIndex()
        },
        colorHeader = {name = "Colors", type = "header", order = self:_incrementOrderIndex()},
        bloodColor = {
          name = "Blood Color",
          desc = "Color for Blood Runes",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        unholyChromaticColor = {
          name = "Unholy Color",
          desc = "Color for Unholy (Chromatic) Runes",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        frostColor = {
          name = "Frost Color",
          desc = "Color for Frost Runes",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        deathColor = {
          name = "Death Color",
          desc = "Color for Death Runes",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param info table
---Ref: https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function Runes47Options:_getOption(info)
  local keyLeafNode = info[#info]
  return self._curDbProfile[keyLeafNode]
end

---@param info table
---@param value any
---Ref: https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function Runes47Options:_setOption(info, value)
  local keyLeafNode = info[#info]
  self._curDbProfile[keyLeafNode] = value
  self._runesModule:refreshConfig()
end

---@param info table
function Runes47Options:_getOptionColor(info) return unpack(self:_getOption(info)) end

---@param info table
function Runes47Options:_setOptionColor(info, r, g, b, a) self:_setOption(info, {r, g, b, a}) end

function Runes47Options:_getShownOption(info) return self:_getOption(info) end

---@param info table
---@param value boolean
---Set the shown option.
function Runes47Options:_setShownOption(info, value)
  self:_setOption(info, value)
  if (value == true) then
    self._runesModule:handleShownOption()
  else
    self._runesModule:handleShownHideOption()
  end
end

function Runes47Options:_incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end
