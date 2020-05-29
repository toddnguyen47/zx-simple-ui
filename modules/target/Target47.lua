local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local TargetHealth47 = ZxSimpleUI:GetModule("TargetHealth47")
local TargetName47 = ZxSimpleUI:GetModule("TargetName47")
local TargetPower47 = ZxSimpleUI:GetModule("TargetPower47")
local Combo47 = ZxSimpleUI:GetModule("Combo47")
local Combo47Options = ZxSimpleUI.optionTables["Combo47Options"]

local NUM_MODULES = 4

local _MODULE_NAME = "Target47"
local _DECORATIVE_NAME = "Target Factory"
local Target47 = ZxSimpleUI:NewModule(_MODULE_NAME)

Target47.MODULE_NAME = _MODULE_NAME
Target47.unit = "target"

function Target47:OnInitialize()
  self:__init__()
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
end

function Target47:OnEnable()
  self:_createBars()
  self:_setEnableState()
end

function Target47:__init__()
  self._barList = {
    [TargetHealth47.MODULE_NAME] = TargetHealth47,
    [TargetName47.MODULE_NAME] = TargetName47,
    [TargetPower47.MODULE_NAME] = TargetPower47
  }
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
function Target47:_createBars()
  for moduleName, module in pairs(self._barList) do module:createBar() end
  self:_createAdditionalBars()
end

function Target47:_createAdditionalBars()
  self._barList[Combo47.MODULE_NAME] = Combo47
  local parentFrame = self._barList[TargetPower47.MODULE_NAME].mainFrame
  self._barList[Combo47.MODULE_NAME]:createBar(parentFrame)
  local combo47Options = Combo47Options:new(self._barList[Combo47.MODULE_NAME])
  combo47Options:registerModuleOptionsTable()
end

function Target47:_setEnableState()
  local count = 0
  for _, module in pairs(self._barList) do
    module:handleEnableToggle()
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
