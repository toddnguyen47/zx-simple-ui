local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local media = LibStub("LibSharedMedia-3.0")

local BarTemplateEnableOptions = {}
BarTemplateEnableOptions.__index = BarTemplateEnableOptions
BarTemplateEnableOptions.OPTION_NAME = "BarTemplateEnableOptions"
ZxSimpleUI.optionTables[BarTemplateEnableOptions.OPTION_NAME] = BarTemplateEnableOptions

---@param currentModule table
function BarTemplateEnableOptions:__init__(currentModule)
  self.options = {}
  self._currentModule = currentModule
  self._curDbProfile = currentModule.db.profile
  self._barTemplateOptions = BarTemplateOptions:new(currentModule)
end

---@param currentModule table
function BarTemplateEnableOptions:new(currentModule)
  assert(currentModule ~= nil)
  assert(currentModule.bars ~= nil, "Remember to initialize a bar template object first!")
  local newInstance = setmetatable({}, self)
  newInstance:__init__(currentModule)
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
