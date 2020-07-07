local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

---@class BarTemplateEnableOptions
local BarTemplateEnableOptions = {}
BarTemplateEnableOptions.__index = BarTemplateEnableOptions
BarTemplateEnableOptions.OPTION_NAME = "BarTemplateEnableOptions"
ZxSimpleUI.optionTables[BarTemplateEnableOptions.OPTION_NAME] = BarTemplateEnableOptions

function BarTemplateEnableOptions:__init__()
  self.options = {}
  self._currentModule = self._barTemplateOptions:getCurrentModule()
end

function BarTemplateEnableOptions:new(barTemplateOptions)
  ---@type BarTemplateEnableOptions
  local newInstance = setmetatable({}, self)
  newInstance._barTemplateOptions = barTemplateOptions
  newInstance:__init__()
  return newInstance
end

function BarTemplateEnableOptions:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@return table
function BarTemplateEnableOptions:getOptionTable()
  if next(self.options) == nil then
    self.options = self._barTemplateOptions:getOptionTable()
    self.options.args["enabledToggle"] = {
      name = "Enable",
      desc = "Enable/Disable this module",
      type = "toggle",
      order = ZxSimpleUI.HEADER_ORDER_INDEX + 1,
      width = "full"
    }
  end
  return self.options
end

---@return table
function BarTemplateEnableOptions:getBarTemplateOptions() return self._barTemplateOptions end
