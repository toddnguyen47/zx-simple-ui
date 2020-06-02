local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]

local PlayerHealth47 = ZxSimpleUI:GetModule("PlayerHealth47")
local PlayerName47 = ZxSimpleUI:GetModule("PlayerName47")
local PlayerPower47 = ZxSimpleUI:GetModule("PlayerPower47")
local Runes47 = ZxSimpleUI:GetModule("Runes47")
local Totems47 = ZxSimpleUI:GetModule("Totems47")

local Power47Options = ZxSimpleUI.optionTables["Power47Options"]
local Runes47Options = ZxSimpleUI.optionTables["Runes47Options"]
local Totems47Options = ZxSimpleUI.optionTables["Totems47Options"]

local NUM_MODULES = 5

local _MODULE_NAME = "Player47"
local _DECORATIVE_NAME = "Player Factory"
local Player47 = ZxSimpleUI:NewModule(_MODULE_NAME)

Player47.MODULE_NAME = _MODULE_NAME
Player47.unit = "player"

function Player47:__init__()
  self._barList = {
    [PlayerHealth47.MODULE_NAME] = {
      module = PlayerHealth47,
      options = BarTemplateOptions:new(PlayerHealth47)
    },
    [PlayerName47.MODULE_NAME] = {
      module = PlayerName47,
      options = BarTemplateOptions:new(PlayerName47)
    },
    [PlayerPower47.MODULE_NAME] = {
      module = PlayerPower47,
      options = Power47Options:new(PlayerPower47)
    }
  }

  self._extraBarList = {
    [Runes47.MODULE_NAME] = {parentFrame = nil, module = Runes47, options = Runes47Options},
    [Totems47.MODULE_NAME] = {parentFrame = nil, module = Totems47, options = Totems47Options}
  }
end

function Player47:OnInitialize()
  self:__init__()
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
end

function Player47:OnEnable()
  self:_createBars()
  self:_setEnableState()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
function Player47:_createBars()
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

function Player47:_createAdditionalBars()
  local playerPowerFrame = self._barList[PlayerPower47.MODULE_NAME]["module"].mainFrame
  self._extraBarList[Runes47.MODULE_NAME]["parentFrame"] = playerPowerFrame
  self._extraBarList[Totems47.MODULE_NAME]["parentFrame"] = playerPowerFrame

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

function Player47:_setEnableState()
  local count = 0
  for moduleName, t1 in pairs(self._barList) do
    local module = t1["module"]
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
