-- Target appears when
-- 1. Selected
-- 2. Being attacked
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local _MODULE_NAME = "TargetPower47"
local _DECORATIVE_NAME = "Target Power"
local TargetPower47 = ZxSimpleUI:NewModule(_MODULE_NAME)

local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitName, UnitPowerType = UnitName, UnitPowerType
local unpack = unpack

TargetPower47.MODULE_NAME = _MODULE_NAME
TargetPower47.bars = nil
TargetPower47.unit = "target"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 240,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 0.0, 1.0, 1.0},
    border = "None"
  }
}

local _powerEventColorTable = {}
_powerEventColorTable["UNIT_MANA"] = {0.0, 0.0, 1.0, 1.0}
_powerEventColorTable["UNIT_RAGE"] = {1.0, 0.0, 0.0, 1.0}
_powerEventColorTable["UNIT_FOCUS"] = {1.0, 0.65, 0.0, 1.0}
_powerEventColorTable["UNIT_ENERGY"] = {1.0, 1.0, 0.0, 1.0}
_powerEventColorTable["UNIT_RUNIC_POWER"] = {0.0, 1.0, 1.0, 1.0}

local _unitPowerTypeTable = {}
_unitPowerTypeTable["MANA"] = 0
_unitPowerTypeTable["RAGE"] = 1
_unitPowerTypeTable["FOCUS"] = 2
_unitPowerTypeTable["ENERGY"] = 3
_unitPowerTypeTable["COMBOPOINTS"] = 4
_unitPowerTypeTable["RUNES"] = 5
_unitPowerTypeTable["RUNICPOWER"] = 6

function TargetPower47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  local optionsTable = self.bars:getOptionTable(_DECORATIVE_NAME)
  optionsTable.args.color = nil
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, optionsTable, _DECORATIVE_NAME)
end

function TargetPower47:OnEnable() self:handleOnEnable() end

function TargetPower47:OnDisable() self:handleOnDisable() end

function TargetPower47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevTargetPower47 = UnitPowerMax(self.unit)
  self.mainFrame = nil
  self._powerType, self._powerTypeString = nil, nil
end

function TargetPower47:createBar()
  self:_setUnitPowerType()
  local targetUnitPower = UnitPower(self.unit)
  local targetUnitMaxPower = UnitPowerMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitPower, targetUnitMaxPower)
  self.mainFrame = self.bars:createBar(percentage)

  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)

  self.mainFrame:Hide()
  return self.mainFrame
end

function TargetPower47:refreshConfig()
  if self:IsEnabled() and self.mainFrame:IsVisible() then
    self.bars:refreshConfig()
    self:_setColor()
  end
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function TargetPower47:handleEnableToggle() end

function TargetPower47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function TargetPower47:handleOnDisable() if self.mainFrame ~= nil then self.mainFrame:Hide() end end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetPower47:_registerEvents()
  for powerEvent, _ in pairs(_powerEventColorTable) do
    self.mainFrame:RegisterEvent(powerEvent)
  end
  self.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  self.mainFrame:RegisterEvent("UNIT_DISPLAYPOWER")
end

function TargetPower47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(argsTable, ...)
    if self:IsEnabled() then
      self:_enableAllScriptHandlers()
      -- Act as if target was just changed
      self:_handlePlayerTargetChanged()
    else
      self.mainFrame:Hide()
    end
  end)

  self.mainFrame:SetScript("OnHide",
    function(argsTable, ...) self:_disableAllScriptHandlers() end)
end

function TargetPower47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
end

function TargetPower47:_disableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:SetScript("OnEvent", nil)
end

function TargetPower47:_onEventHandler(argsTable, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(unit, self.unit) then
    if Utils47:stringEqualsIgnoreCase(event, "UNIT_DISPLAYPOWER") then
      self:_handlePowerChanged()
    elseif _powerEventColorTable[event] ~= nil then
      self:_handleUnitPowerEvent()
    end
  end
end

function TargetPower47:_handlePlayerTargetChanged()
  local targetName = UnitName(self.unit)
  if targetName ~= nil and targetName ~= "" then self:_setColor() end
end

function TargetPower47:_handlePowerChanged()
  self:_setUnitPowerType()
  self:refreshConfig()
  self:_setColor()
end

function TargetPower47:_handleUnitPowerEvent(curUnitPower)
  curUnitPower = curUnitPower or UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
  self.bars:setStatusBarValue(powerPercent)
end

function TargetPower47:_onUpdateHandler(argsTable, elapsed)
  if not self.mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitPower = UnitPower(self.unit)
    if (curUnitPower ~= self._prevTargetPower47) then
      self:_handleUnitPowerEvent(curUnitPower)
      self._prevTargetPower47 = curUnitPower
      self._timeSinceLastUpdate = 0
    end
  end
end

function TargetPower47:_setUnitPowerType()
  self._powerType, self._powerTypeString = UnitPowerType(self.unit)
end

function TargetPower47:_setColor()
  self:_setUnitPowerType()
  local upperType = string.upper(self._powerTypeString)
  local colorTable = _powerEventColorTable["UNIT_" .. upperType]
  colorTable = colorTable or _powerEventColorTable["UNIT_MANA"]

  _defaults.profile.color = colorTable
  self._curDbProfile.color = colorTable
  self.mainFrame.statusBar:SetStatusBarColor(unpack(colorTable))
end
