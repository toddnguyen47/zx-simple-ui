local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local media = LibStub("LibSharedMedia-3.0")

local Power47Options = {}
Power47Options.__index = Power47Options
Power47Options.OPTION_NAME = "Power47Options"
ZxSimpleUI.optionTables[Power47Options.OPTION_NAME] = Power47Options

---@param currentModule table
function Power47Options:new(currentModule)
  assert(currentModule ~= nil)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(currentModule)
  return newInstance
end

function Power47Options:__init__(currentModule)
  self.options = {}
  self._currentModule = currentModule
  self._curDbProfile = currentModule.db.profile
  self._coreOptions47 = CoreOptions47:new(self._currentModule)
  self._barTemplateOptions = BarTemplateOptions:new(self._currentModule)
end

function Power47Options:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@return table
function Power47Options:getOptionTable()
  if next(self.options) == nil then
    self.options = self._barTemplateOptions:getOptionTable()
    self.options.args.color = nil
    local extraOptions = self:_getExtraOptionTable()
    for k, v in pairs(extraOptions) do self.options.args[k] = v end
  end
  return self.options
end

function Power47Options:_getExtraOptionTable()
  local t1 = {
    colorgroup = {
      name = "Power Colors",
      type = "group",
      inline = true,
      get = function(info) return self._coreOptions47:getOptionColor(info) end,
      set = function(info, r, g, b, a)
        self._currentModule.currentPowerColorEdited = {r, g, b, a}
        self._coreOptions47:setOptionColor(info, r, g, b, a)
      end,
      order = -1,
      args = {
        showbar = {
          name = "Show Color",
          desc = "Show the currently edited power color",
          type = "toggle",
          order = 1,
          disabled = function(info) return not self._curDbProfile.enabledToggle end,
          get = function(info) return self._coreOptions47:getOption(info) end,
          set = function(info, value) self._coreOptions47:setOption(info, value) end
        },
        colorMana = {
          name = "Mana",
          desc = "UNIT_MANA",
          type = "color",
          hasAlpha = true,
          order = 5
        },
        colorRage = {
          name = "Rage",
          desc = "UNIT_RAGE",
          type = "color",
          hasAlpha = true,
          order = 6
        },
        colorFocus = {
          name = "Focus",
          desc = "UNIT_FOCUS",
          type = "color",
          hasAlpha = true,
          order = 7
        },
        colorEnergy = {
          name = "Energy",
          desc = "UNIT_ENERGY",
          type = "color",
          hasAlpha = true,
          order = 8
        },
        colorRunicPower = {
          name = "Runic Power",
          desc = "UNIT_RUNIC_POWER",
          type = "color",
          hasAlpha = true,
          order = 9
        }
      }
    }
  }
  return t1
end