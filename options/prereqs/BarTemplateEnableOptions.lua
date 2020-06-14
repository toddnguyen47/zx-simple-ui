local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local BarTemplateEnableOptions = {}
BarTemplateEnableOptions.__index = BarTemplateEnableOptions
BarTemplateEnableOptions.OPTION_NAME = "BarTemplateEnableOptions"
ZxSimpleUI.optionTables[BarTemplateEnableOptions.OPTION_NAME] = BarTemplateEnableOptions

---@param barTemplateOptions table
function BarTemplateEnableOptions:__init__(barTemplateOptions)
  self.options = {}
  self._barTemplateOptions = barTemplateOptions
  self._currentModule = self._barTemplateOptions:getCurrentModule()
  self._curDbProfile = self._currentModule.db.profile
end

---@param barTemplateOptions table
function BarTemplateEnableOptions:new(barTemplateOptions)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(barTemplateOptions)
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
