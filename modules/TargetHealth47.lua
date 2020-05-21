-- Target appears when
-- 1. Selected
-- 2. Being attacked
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "TargetHealth47"
local _DECORATIVE_NAME = "Target Health"
local TargetHealth47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local CreateFrame, UnitHealth, UnitHealthMax = CreateFrame, UnitHealth, UnitHealthMax
local UnitName = UnitName
local unpack = unpack

TargetHealth47.MODULE_NAME = _MODULE_NAME
TargetHealth47.bars = nil
TargetHealth47.unit = "target"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 270,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0},
    border = "None"
  }
}

function TargetHealth47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  local optionsTable = self.bars:getOptionTable(_DECORATIVE_NAME)
  optionsTable = self:_addShowOption(optionsTable)
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, optionsTable, _DECORATIVE_NAME)

  self:__init__()
end

function TargetHealth47:OnEnable()
end

function TargetHealth47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevTargetHealth47 = UnitHealthMax(self.unit)
  self.mainFrame = nil
end

function TargetHealth47:createBar()
  local targetUnitHealth = UnitHealth(self.unit)
  local targetUnitMaxHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitHealth, targetUnitMaxHealth)

  self.mainFrame = self.bars:createBar(percentage)

  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  self.mainFrame:Hide()
  return self.mainFrame
end

function TargetHealth47:refreshConfig()
  if self:IsEnabled() and self.mainFrame:IsVisible() then self.bars:refreshConfig() end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetHealth47:_registerEvents()
  self.mainFrame:RegisterEvent("UNIT_HEALTH")
  self.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function TargetHealth47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(argsTable, ...)
    if self:IsEnabled() then
      self:_enableAllScriptHandlers()
    else
      self.mainFrame:Hide()
    end
  end)

  self.mainFrame:SetScript("OnHide", function(argsTable, ...)
    self:_disableAllScriptHandlers()
  end)
end

function TargetHealth47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
end

function TargetHealth47:_disableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:SetScript("OnEvent", nil)
end

function TargetHealth47:_onEventHandler(argsTable, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(event, "UNIT_HEALTH") and
    Utils47:stringEqualsIgnoreCase(unit, self.unit) then
    self:_handleUnitHealthEvent()
  end
end

function TargetHealth47:_handlePlayerTargetChanged()
  local targetName = UnitName(self.unit)
  if targetName ~= nil and targetName ~= "" then self:_setHealthValue() end
end

function TargetHealth47:_onUpdateHandler(argsTable, elapsed)
  if not self.mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitHealth = UnitHealth(self.unit)
    if (curUnitHealth ~= self._prevTargetHealth47) then
      self:_handleUnitHealthEvent(curUnitHealth)
      self._prevTargetHealth47 = curUnitHealth
      self._timeSinceLastUpdate = 0
    end
  end
end

function TargetHealth47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  self:_setHealthValue(curUnitHealth)
end

function TargetHealth47:_addShowOption(optionsTable)
  optionsTable.args["show"] = {
    type = "execute",
    name = "Show Bar",
    desc = "Show/Hide the Target Health",
    func = function()
      if self.mainFrame:IsVisible() then
        self.mainFrame:Hide()
      else
        self.mainFrame:Show()
        self.bars:_setStatusBarValue(0.8)
      end
    end
  }
  return optionsTable
end

function TargetHealth47:_setHealthValue(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
  self.bars:_setStatusBarValue(healthPercent)
end
