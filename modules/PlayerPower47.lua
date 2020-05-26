local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

--- upvalues to prevent warnings
local LibStub = LibStub
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitClass, UnitPowerType = UnitClass, UnitPowerType

local _MODULE_NAME = "PlayerPower47"
local _DECORATIVE_NAME = "Player Power"
local PlayerPower47 = ZxSimpleUI:NewModule(_MODULE_NAME)

PlayerPower47.MODULE_NAME = _MODULE_NAME
PlayerPower47.unit = "player"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 400,
    positiony = 240,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 0.0, 1.0, 1.0},
    border = "None"
  }
}

local _powerEventColorTable = {
  ["UNIT_MANA"] = {0.0, 0.0, 1.0, 1.0},
  ["UNIT_RAGE"] = {1.0, 0.0, 0.0, 1.0},
  ["UNIT_FOCUS"] = {1.0, 0.65, 0.0, 1.0},
  ["UNIT_ENERGY"] = {1.0, 1.0, 0.0, 1.0},
  ["UNIT_RUNIC_POWER"] = {0.0, 1.0, 1.0, 1.0}
}

local _unitPowerTypeTable = {
  ["MANA"] = 0,
  ["RAGE"] = 1,
  ["FOCUS"] = 2,
  ["ENERGY"] = 3,
  ["COMBOPOINTS"] = 4,
  ["RUNES"] = 5,
  ["RUNICPOWER"] = 6
}

function PlayerPower47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self.bars:getOptionTable(_DECORATIVE_NAME),
    _DECORATIVE_NAME)
end

function PlayerPower47:OnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function PlayerPower47:OnEnable() self:handleOnEnable() end

function PlayerPower47:OnDisable() self:handleOnDisable() end

function PlayerPower47:__init__()
  self.mainFrame = nil
  self._timeSinceLastUpdate = 0
  self._prevPowerValue = UnitPowerMax(self.unit)
  self._playerClass = UnitClass(self.unit)
  self._powerType = 0
  self._powerTypeString = ""
end

function PlayerPower47:refreshConfig() if self:IsEnabled() then self.bars:refreshConfig() end end

---@return table
function PlayerPower47:createBar()
  self:_setUnitPowerType()
  self:_setDefaultColor()

  local curUnitPower = UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
  self.mainFrame = self.bars:createBar(percentage)

  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)

  self.mainFrame:Show()
  return self.mainFrame
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function PlayerPower47:handleEnableToggle() end

function PlayerPower47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function PlayerPower47:handleOnDisable() if self.mainFrame ~= nil then self.mainFrame:Hide() end end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param curFrame table
---@param elapsed number
function PlayerPower47:_onUpdateHandler(curFrame, elapsed)
  if not self.mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitPower = UnitPower(self.unit)
    if (curUnitPower ~= self._prevPowerValue) then
      self:_setPowerValue(curUnitPower)
      self._prevPowerValue = curUnitPower
      self._timeSinceLastUpdate = 0
    end
  end
end

---@param curFrame table
---@param event string
---@param unit string
function PlayerPower47:_onEventHandler(curFrame, event, unit)
  local isSameEvent = Utils47:stringEqualsIgnoreCase(event, "UNIT_DISPLAYPOWER")
  local isSameUnit = Utils47:stringEqualsIgnoreCase(unit, self.unit)
  if isSameEvent and isSameUnit then self:_handlePowerChanged() end
end

---@param curUnitPower number
function PlayerPower47:_setPowerValue(curUnitPower)
  curUnitPower = curUnitPower or UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
  self.bars:setStatusBarValue(powerPercent)
end

function PlayerPower47:_handlePowerChanged()
  self:_setUnitPowerType()
  self:_setDefaultColor()
  self:refreshConfig()
end

function PlayerPower47:_registerEvents()
  for powerEvent, _ in pairs(_powerEventColorTable) do
    self.mainFrame:RegisterEvent(powerEvent)
  end
  -- Register Druid's shapeshift form
  self.mainFrame:RegisterEvent("UNIT_DISPLAYPOWER")
end

function PlayerPower47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(curFrame, ...)
    if self:IsEnabled() then
      self:_enableAllScriptHandlers()
    else
      self.mainFrame:Hide()
    end
  end)

  self.mainFrame:SetScript("OnHide",
    function(curFrame, ...) self:_disableAllScriptHandlers() end)
end

function PlayerPower47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit)
    self:_onEventHandler(curFrame, event, unit)
  end)
end

function PlayerPower47:_disableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:SetScript("OnEvent", nil)
end

function PlayerPower47:_setUnitPowerType()
  self._powerType, self._powerTypeString = UnitPowerType(self.unit)
end

function PlayerPower47:_setDefaultColor()
  local powerTypeUpper = string.upper(self._powerTypeString)
  local colorTable = _powerEventColorTable["UNIT_" .. powerTypeUpper]
  if colorTable == nil then colorTable = _powerEventColorTable["UNIT_MANA"] end
  _defaults.profile.color = colorTable
  self._curDbProfile.color = colorTable
end
