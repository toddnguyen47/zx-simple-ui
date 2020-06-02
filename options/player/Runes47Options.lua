local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local media = LibStub("LibSharedMedia-3.0")

local Runes47Options = {}
Runes47Options.__index = Runes47Options
Runes47Options.OPTION_NAME = "Runes47Options"
ZxSimpleUI.optionTables[Runes47Options.OPTION_NAME] = Runes47Options

---@param runesModule table
function Runes47Options:__init__(runesModule)
  self.options = {}
  self._runesModule = runesModule
  self._curDbProfile = self._runesModule.db.profile
  self._coreOptions47 = CoreOptions47:new(self._runesModule)
end

---@param runesModule table
function Runes47Options:new(runesModule)
  assert(runesModule ~= nil)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(runesModule)
  return newInstance
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
      get = function(info) return self._coreOptions47:getOption(info) end,
      set = function(info, value) self._coreOptions47:setOption(info, value) end,
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
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 1
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        height = {
          name = "Rune Height",
          desc = "Rune display height",
          type = "range",
          min = 2,
          max = 20,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        horizGap = {
          name = "Horizontal Gap",
          desc = "Horizontal Gap between each rune",
          type = "range",
          min = 0,
          max = 30,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        yoffset = {
          name = "Y Offset",
          desc = "Y Offset",
          type = "range",
          min = -30,
          max = 30,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        runeCooldownAlpha = {
          name = "Rune Cooldown Alpha",
          desc = "Rune Cooldown Alpha Level",
          type = "range",
          min = 0,
          max = 0.9,
          step = 0.05,
          order = self._coreOptions47:incrementOrderIndex()
        },
        colorHeader = {
          name = "Colors",
          type = "header",
          order = self._coreOptions47:incrementOrderIndex()
        },
        bloodColor = {
          name = "Blood Color",
          desc = "Color for Blood Runes",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        },
        unholyChromaticColor = {
          name = "Unholy Color",
          desc = "Color for Unholy (Chromatic) Runes",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        },
        frostColor = {
          name = "Frost Color",
          desc = "Color for Frost Runes",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        },
        deathColor = {
          name = "Death Color",
          desc = "Color for Death Runes",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end
