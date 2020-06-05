-- #region
--- upvalues to prevent warnings
local LibStub = LibStub
local UnitPower, UnitPowerMax, UnitPowerType = UnitPower, UnitPowerMax, UnitPowerType

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local MODULE_NAME = "PlayerPower47"
local DECORATIVE_NAME = "Player Power"
local PlayerPower47 = ZxSimpleUI:NewModule(MODULE_NAME)

PlayerPower47.MODULE_NAME = MODULE_NAME
PlayerPower47.DECORATIVE_NAME = DECORATIVE_NAME
PlayerPower47.bars = nil
PlayerPower47.unit = "player"
-- #endregion

function PlayerPower47:__init__()
  self._powerEventColorTable = {
    ["UNIT_MANA"] = {0.0, 0.0, 1.0, 1.0},
    ["UNIT_RAGE"] = {1.0, 0.0, 0.0, 1.0},
    ["UNIT_FOCUS"] = {1.0, 0.65, 0.0, 1.0},
    ["UNIT_ENERGY"] = {1.0, 1.0, 0.0, 1.0},
    ["UNIT_RUNIC_POWER"] = {0.0, 1.0, 1.0, 1.0}
  }

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
      xoffset = 400,
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
  self._prevPowerValue = UnitPowerMax(self.unit)
  self._playerClass = UnitClass(self.unit)
  self._powerType = 0
  self._powerTypeString = ""

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function PlayerPower47:OnInitialize()
  self:__init__()
  self.db = ZxSimpleUI.db:RegisterNamespace(self.MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile

  -- Always set the showbar option to false on initialize
  self._curDbProfile.showbar = self._defaults.profile.showbar

  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(self.MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function PlayerPower47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PlayerPower47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self.mainFrame:Hide()
end

---@return table
function PlayerPower47:createBar()
  local curUnitPower = UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME

  self:_setRefreshColor()
  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function PlayerPower47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then
    -- If the show option is currently selected
    if self._curDbProfile.showbar == true then
      self.mainFrame.statusBar:SetStatusBarColor(unpack(self.currentPowerColorEdited))
    else
      self:_setRefreshColor()
      self.bars:refreshConfig()
    end
  end
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function PlayerPower47:handleEnableToggle() end

---Explicitly call OnEnable() and OnDisable() depending on the module's IsEnabled()
---This function is exactly like refreshConfig(), except it is called only during initialization.
function PlayerPower47:initModuleEnableState()
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

function PlayerPower47:_handlePowerChanged() self:refreshConfig() end

function PlayerPower47:_registerEvents()
  for powerEvent, _ in pairs(self._powerEventColorTable) do
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

function PlayerPower47:_setRefreshColor()
  self:_setUnitPowerType()
  local upperType = string.upper(self._powerTypeString)
  local colorOptionTable = self:_getColorsInOptions()
  local t1 = colorOptionTable["UNIT_" .. upperType]
  t1 = t1 or colorOptionTable["UNIT_MANA"]

  self._curDbProfile.color = t1
  self.mainFrame.statusBar:SetStatusBarColor(unpack(t1))
end

---@return table
function PlayerPower47:_getColorsInOptions()
  local t1 = {
    ["UNIT_MANA"] = self._curDbProfile.colorMana,
    ["UNIT_RAGE"] = self._curDbProfile.colorRage,
    ["UNIT_FOCUS"] = self._curDbProfile.colorFocus,
    ["UNIT_ENERGY"] = self._curDbProfile.colorEnergy,
    ["UNIT_RUNIC_POWER"] = self._curDbProfile.colorRunicPower
  }
  return t1
end
