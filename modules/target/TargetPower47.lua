-- Target appears when
-- 1. Selected
-- 2. Being attacked
--- upvalues to prevent warnings
local LibStub = LibStub
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitName, UnitPowerType = UnitName, UnitPowerType
local unpack = unpack

---Include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

-- #region
local MODULE_NAME = "TargetPower47"
local DECORATIVE_NAME = "Target Power"
local TargetPower47 = ZxSimpleUI:NewModule(MODULE_NAME)

TargetPower47.MODULE_NAME = MODULE_NAME
TargetPower47.DECORATIVE_NAME = DECORATIVE_NAME
TargetPower47.bars = nil
TargetPower47.unit = "target"
-- #endregion

function TargetPower47:__init__()
  self._powerEventColorTable = {
    ["UNIT_MANA"] = {0.0, 0.0, 1.0, 1.0},
    ["UNIT_RAGE"] = {1.0, 0.0, 0.0, 1.0},
    ["UNIT_FOCUS"] = {1.0, 0.65, 0.0, 1.0},
    ["UNIT_ENERGY"] = {1.0, 1.0, 0.0, 1.0},
    ["UNIT_RUNIC_POWER"] = {0.0, 1.0, 1.0, 1.0}
  }

  self._eventTable = {"PLAYER_TARGET_CHANGED", "UNIT_DISPLAYPOWER"}

  self._unitPowerTypeTable = {
    ["MANA"] = 0,
    ["RAGE"] = 1,
    ["FOCUS"] = 2,
    ["ENERGY"] = 3,
    ["COMBOPOINTS"] = 4,
    ["RUNES"] = 5,
    ["RUNICPOWER"] = 6
  }

  self._defaults = {
    profile = {
      enabledToggle = true,
      showbar = false,
      width = 200,
      height = 26,
      xoffset = 700,
      yoffset = 240,
      fontsize = 16,
      font = "PT Sans Bold",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "Skewed",
      color = self._powerEventColorTable["UNIT_MANA"], -- need this option for createBar() to work
      colorMana = self._powerEventColorTable["UNIT_MANA"],
      colorRage = self._powerEventColorTable["UNIT_RAGE"],
      colorFocus = self._powerEventColorTable["UNIT_FOCUS"],
      colorEnergy = self._powerEventColorTable["UNIT_ENERGY"],
      colorRunicPower = self._powerEventColorTable["UNIT_RUNIC_POWER"],
      border = "None"
    }
  }

  self.mainFrame = nil
  self.currentPowerColorEdited = self._powerEventColorTable["UNIT_MANA"]

  self._timeSinceLastUpdate = 0
  self._prevTargetPower47 = UnitPowerMax(self.unit)
  self._powerType, self._powerTypeString = nil, nil

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function TargetPower47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile
  -- Always set the showbar option to false on initialize
  self._curDbProfile.showbar = self._defaults.profile.showbar

  self.bars = BarTemplate:new(self.db)

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function TargetPower47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_registerEvents()
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function TargetPower47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_unregisterEvents()
  self.mainFrame:Hide()
end

-- For Frames that gets hidden often (e.g. Target frames)
---@param curFrame table
---Handle Blizzard's OnShow event
function TargetPower47:OnShowBlizz(curFrame, ...)
  if self:IsEnabled() then
    self:_enableAllScriptHandlers()
    -- Act as if target was just changed
    self:_handlePlayerTargetChanged()
  else
    self.mainFrame:Hide()
  end
end

---@param curFrame table
---Handle Blizzard's OnHide event
function TargetPower47:OnHideBlizz(curFrame, ...) self:_disableAllScriptHandlers() end

function TargetPower47:createBar()
  self:_setUnitPowerType()
  local targetUnitPower = UnitPower(self.unit)
  local targetUnitMaxPower = UnitPowerMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitPower, targetUnitMaxPower)
  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self._curDbProfile.framePool)

  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})

  self.mainFrame:Hide()
  return self.mainFrame
end

function TargetPower47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() and self.mainFrame:IsVisible() then
    --- if we are currently in shown mode
    if self._curDbProfile.showbar == true then
      self.mainFrame.statusBar:SetStatusBarColor(unpack(self.currentPowerColorEdited))
    else
      self.bars:refreshConfig()
      self:_setRefreshColor()
    end
  end
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function TargetPower47:handleEnableToggle() end

function TargetPower47:handleShownOption() self.mainFrame:Show() end

function TargetPower47:handleShownHideOption() self.mainFrame:Hide() end

---Explicitly call OnEnable() and OnDisable() depending on the module's IsEnabled()
---This function is exactly like refreshConfig(), except it is called only during initialization.
function TargetPower47:initModuleEnableState()
  self:refreshConfig()
  if self:IsEnabled() then
    self:OnEnable()
  else
    self:OnDisable()
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetPower47:_registerEvents()
  for powerEvent, _ in pairs(self._powerEventColorTable) do
    self.mainFrame:RegisterEvent(powerEvent)
  end
  for _, event in pairs(self._eventTable) do self.mainFrame:RegisterEvent(event) end
end

function TargetPower47:_unregisterEvents()
  for powerEvent, _ in pairs(self._powerEventColorTable) do
    self.mainFrame:UnregisterEvent(powerEvent)
  end
  for _, event in pairs(self._eventTable) do self.mainFrame:UnregisterEvent(event) end
end

function TargetPower47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow",
    function(curFrame, ...) self:OnShowBlizz(curFrame, ...) end)

  self.mainFrame:SetScript("OnHide",
    function(curFrame, ...) self:OnHideBlizz(curFrame, ...) end)
end

function TargetPower47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit)
    self:_onEventHandler(curFrame, event, unit)
  end)
end

function TargetPower47:_disableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:SetScript("OnEvent", nil)
end

function TargetPower47:_onEventHandler(curFrame, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(unit, self.unit) then
    if Utils47:stringEqualsIgnoreCase(event, "UNIT_DISPLAYPOWER") then
      self:_handlePowerChanged()
    elseif self._powerEventColorTable[event] ~= nil then
      self:_handleUnitPowerEvent()
    end
  end
end

function TargetPower47:_handlePlayerTargetChanged()
  local targetName = UnitName(self.unit)
  if targetName ~= nil and targetName ~= "" then self:_setRefreshColor() end
end

function TargetPower47:_handlePowerChanged()
  self:_setUnitPowerType()
  self:refreshConfig()
  self:_setRefreshColor()
end

function TargetPower47:_handleUnitPowerEvent(curUnitPower)
  curUnitPower = curUnitPower or UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
  self.bars:setStatusBarValue(powerPercent)
end

function TargetPower47:_onUpdateHandler(curFrame, elapsed)
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

function TargetPower47:_setRefreshColor()
  local colorOptionTable = self:_getColorsInOptions()
  self:_setUnitPowerType()
  local upperType = string.upper(self._powerTypeString)

  local t1 = colorOptionTable["UNIT_" .. upperType]
  t1 = t1 or colorOptionTable["UNIT_MANA"]
  self.mainFrame.statusBar:SetStatusBarColor(unpack(t1))
end

---@return table
function TargetPower47:_getColorsInOptions()
  local t1 = {
    ["UNIT_MANA"] = self._curDbProfile.colorMana,
    ["UNIT_RAGE"] = self._curDbProfile.colorRage,
    ["UNIT_FOCUS"] = self._curDbProfile.colorFocus,
    ["UNIT_ENERGY"] = self._curDbProfile.colorEnergy,
    ["UNIT_RUNIC_POWER"] = self._curDbProfile.colorRunicPower
  }
  return t1
end
