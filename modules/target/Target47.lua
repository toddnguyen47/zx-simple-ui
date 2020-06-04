local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]

local TargetHealth47 = ZxSimpleUI:GetModule("TargetHealth47")
local TargetName47 = ZxSimpleUI:GetModule("TargetName47")
local TargetPower47 = ZxSimpleUI:GetModule("TargetPower47")
local Combo47 = ZxSimpleUI:GetModule("Combo47")

local Combo47Options = ZxSimpleUI.optionTables["Combo47Options"]
local Power47Options = ZxSimpleUI.optionTables["Power47Options"]

local NUM_MODULES = 4

local MODULE_NAME = "Target47"
local DECORATIVE_NAME = "Target Factory"
local Target47 = ZxSimpleUI:NewModule(MODULE_NAME)

Target47.MODULE_NAME = MODULE_NAME
Target47.unit = "target"

function Target47:OnInitialize()
  self:__init__()
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

function Target47:OnEnable()
  -- self:_createBars()
  -- self:_setEnableState()
end

function Target47:__init__()
  self._barList = {
    [TargetHealth47.MODULE_NAME] = {
      module = TargetHealth47,
      options = BarTemplateOptions:new(TargetHealth47)
    },
    [TargetName47.MODULE_NAME] = {
      module = TargetName47,
      options = BarTemplateOptions:new(TargetName47)
    },
    [TargetPower47.MODULE_NAME] = {
      module = TargetPower47,
      options = Power47Options:new(TargetPower47)
    }
  }

  self._extraBarList = {
    [Combo47.MODULE_NAME] = {parentFrame = nil, module = Combo47, options = Combo47Options}
  }
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
function Target47:_createBars()
  for moduleName, t1 in pairs(self._barList) do
    local module1 = t1["module"]
    local options1 = t1["options"]
    module1:createBar()
    if type(module1.getExtraOptions) == "function" then
      local extraOptionTable = module1:getExtraOptions()
      options1:addOption(extraOptionTable)
    end
    options1:registerModuleOptionsTable()
  end
  self:_createAdditionalBars()
end

function Target47:_createAdditionalBars()
  local targetPowerFrame = self._barList[TargetPower47.MODULE_NAME]["module"].mainFrame
  self._extraBarList[Combo47.MODULE_NAME]["parentFrame"] = targetPowerFrame

  for moduleName, t1 in pairs(self._extraBarList) do
    local module = t1["module"]
    local options = t1["options"]
    module:createBar(t1["parentFrame"])
    local optionObject = options:new(module)
    optionObject:registerModuleOptionsTable()
    -- Add to barList so we can call its handleOnEnable() function
    self._barList[moduleName] = {module = module, options = optionObject}
  end
end

function Target47:_setEnableState()
  local count = 0
  for moduleName, t1 in pairs(self._barList) do
    local module = t1["module"]
    if module:IsEnabled() then
      module:handleOnEnable()
    else
      module:handleOnDisable()
    end
    count = count + 1
  end
  assert(count == NUM_MODULES,
    string.format("Number of modules was not met! Num Modules: %d", NUM_MODULES))
end
