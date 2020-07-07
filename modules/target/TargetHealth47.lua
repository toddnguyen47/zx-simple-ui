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
local RegisterWatchHandler47 = ZxSimpleUI.prereqTables["RegisterWatchHandler47"]
local SetOnShowOnHide = ZxSimpleUI.prereqTables["SetOnShowOnHide"]

-- #region
local MODULE_NAME = "TargetHealth47"
local DECORATIVE_NAME = "Target Health"
local TargetHealth47 = ZxSimpleUI:NewModule(MODULE_NAME)

TargetHealth47.MODULE_NAME = MODULE_NAME
TargetHealth47.DECORATIVE_NAME = DECORATIVE_NAME
TargetHealth47.bars = nil
TargetHealth47.unit = "target"
-- #endregion

function TargetHealth47:__init__()
  self._defaults = {
    profile = {
      width = 200,
      height = 26,
      xoffset = 180,
      yoffset = -100,
      fontsize = 16,
      font = "Lato Bold",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "GrayVertGradient",
      color = {0.0, 1.0, 0.0, 1.0},
      border = "None",
      framePool = "UIParent",
      selfCurrentPoint = "CENTER",
      relativePoint = "CENTER"
    }
  }
  self._eventTable = {"UNIT_HEALTH", "PLAYER_TARGET_CHANGED"}

  self._timeSinceLastUpdate = 0
  self._prevTargetHealth47 = UnitHealthMax(self.unit)
  self._unitClassification = ""
  self.mainFrame = nil

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function TargetHealth47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._newDefaults)

  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function TargetHealth47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_registerEvents()
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function TargetHealth47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_unregisterEvents()
end

---@param curFrame table
---Handle Blizzard's OnShow event
function TargetHealth47:OnShowBlizz(curFrame, ...)
  if self:IsEnabled() then
    self:_enableAllScriptHandlers()
  else
    self.mainFrame:Hide()
  end
end

---@param curFrame table
---Handle Blizzard's OnHide event
function TargetHealth47:OnHideBlizz(curFrame, ...) self.mainFrame:SetScript("OnUpdate", nil) end

function TargetHealth47:createBar()
  local targetUnitHealth = UnitHealth(self.unit)
  local targetUnitMaxHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitHealth, targetUnitMaxHealth)

  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME

  SetOnShowOnHide:setHandlerScripts(self)

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})

  self.mainFrame:Hide()
  return self.mainFrame
end

function TargetHealth47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() and self.mainFrame:IsVisible() then self.bars:refreshConfig() end
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function TargetHealth47:handleEnableToggle() end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetHealth47:_registerEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:RegisterEvent(event) end
end

function TargetHealth47:_unregisterEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:UnregisterEvent(event) end
end

function TargetHealth47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit)
    self:_onEventHandler(curFrame, event, unit)
  end)
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
