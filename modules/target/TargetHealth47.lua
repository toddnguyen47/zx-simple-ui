-- Target appears when
-- 1. Selected
-- 2. Being attacked
--- upvalues to prevent warnings
local LibStub = LibStub
local CreateFrame, UnitHealth, UnitHealthMax = CreateFrame, UnitHealth, UnitHealthMax
local UnitName, UnitClassification = UnitName, UnitClassification
local unpack = unpack

---Include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local _MODULE_NAME = "TargetHealth47"
local _DECORATIVE_NAME = "Target Health"
local TargetHealth47 = ZxSimpleUI:NewModule(_MODULE_NAME)

TargetHealth47.MODULE_NAME = _MODULE_NAME
TargetHealth47.DECORATIVE_NAME = _DECORATIVE_NAME
TargetHealth47.bars = nil
TargetHealth47.unit = "target"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    xoffset = 700,
    yoffset = 270,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0},
    border = "None"
  }
}

function TargetHealth47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevTargetHealth47 = UnitHealthMax(self.unit)
  self._unitClassification = ""
  self.mainFrame = nil

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, _defaults.profile)
end

function TargetHealth47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile

  self.bars = BarTemplate:new(self.db)

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
end

function TargetHealth47:OnEnable() self:handleOnEnable() end

function TargetHealth47:OnDisable() self:handleOnDisable() end

function TargetHealth47:createBar()
  local targetUnitHealth = UnitHealth(self.unit)
  local targetUnitMaxHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitHealth, targetUnitMaxHealth)

  self.mainFrame = self.bars:createBar(percentage)

  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)

  self.mainFrame:Hide()
  return self.mainFrame
end

function TargetHealth47:refreshConfig()
  if self:IsEnabled() and self.mainFrame:IsVisible() then self.bars:refreshConfig() end
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function TargetHealth47:handleEnableToggle() end

function TargetHealth47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function TargetHealth47:handleOnDisable()
  if self.mainFrame ~= nil then self.mainFrame:Hide() end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetHealth47:_registerEvents()
  self.mainFrame:RegisterEvent("UNIT_HEALTH")
  self.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function TargetHealth47:_setOnShowOnHideHandlers()
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

function TargetHealth47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit)
    self:_onEventHandler(curFrame, event, unit)
  end)
end

function TargetHealth47:_disableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:SetScript("OnEvent", nil)
end

function TargetHealth47:_onEventHandler(curFrame, event, unit)
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

function TargetHealth47:_onUpdateHandler(curFrame, elapsed)
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

function TargetHealth47:_setHealthValue(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
  self._unitClassification = UnitClassification(self.unit)
  if Utils47:isNormalEnemy(self._unitClassification) then
    self.bars:setStatusBarValue(healthPercent)
  else
    local s1 = Utils47.UnitClassificationElitesTable[self._unitClassification]
    self.mainFrame.statusBar:SetValue(healthPercent)
    self.mainFrame.mainText:SetText(string.format("(%s) %.1f%%", s1, healthPercent * 100.0))
  end
end
