local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local PlayerHealth47 = ZxSimpleUI:GetModule("PlayerHealth47")
local PlayerName47 = ZxSimpleUI:GetModule("PlayerName47")
local PlayerPower47 = ZxSimpleUI:GetModule("PlayerPower47")
local Runes47 = ZxSimpleUI:GetModule("Runes47")
local Runes47Options = ZxSimpleUI.optionTables["Runes47Options"]
local Totems47 = ZxSimpleUI:GetModule("Totems47")
local Totems47Options = ZxSimpleUI.optionTables["Totems47Options"]

local NUM_MODULES = 5

local _MODULE_NAME = "Player47"
local _DECORATIVE_NAME = "Player Factory"
local Player47 = ZxSimpleUI:NewModule(_MODULE_NAME)

Player47.MODULE_NAME = _MODULE_NAME
Player47.unit = "player"

function Player47:OnInitialize()
  self:__init__()
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
end

function Player47:OnEnable()
  self:_createBars()
  self:_setEnableState()
end

function Player47:__init__()
  self._barList = {
    [PlayerHealth47.MODULE_NAME] = PlayerHealth47,
    [PlayerName47.MODULE_NAME] = PlayerName47,
    [PlayerPower47.MODULE_NAME] = PlayerPower47
  }
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
function Player47:_createBars()
  for moduleName, module in pairs(self._barList) do module:createBar() end
  self:_createAdditionalBars()
end

function Player47:_createAdditionalBars()
  self._barList[Runes47.MODULE_NAME] = Runes47
  local parentFrame = self._barList[PlayerPower47.MODULE_NAME].mainFrame
  self._barList[Runes47.MODULE_NAME]:createBar(parentFrame)
  local runes47Options = Runes47Options:new(self._barList[Runes47.MODULE_NAME])
  runes47Options:registerModuleOptionsTable()

  self._barList[Totems47.MODULE_NAME] = Totems47
  parentFrame = self._barList[PlayerPower47.MODULE_NAME].mainFrame
  self._barList[Totems47.MODULE_NAME]:createBar(parentFrame)
  local totems47Options = Totems47Options:new(self._barList[Totems47.MODULE_NAME])
  totems47Options:registerModuleOptionsTable()
end

function Player47:_setEnableState()
  local count = 0
  for moduleName, module in pairs(self._barList) do
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
