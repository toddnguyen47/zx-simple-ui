-- #region
--- upvalues to prevent warnings
local LibStub = LibStub
local UnitPower, UnitPowerMax, UnitPowerType = UnitPower, UnitPowerMax, UnitPowerType
local UnitClass = UnitClass

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)

local Utils47 = ZxSimpleUI.Utils47
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local RegisterWatchHandler47 = ZxSimpleUI.prereqTables["RegisterWatchHandler47"]

local MODULE_NAME = "PlayerPower47"
local DECORATIVE_NAME = Locale["module.decName.playerPower"]
local PlayerPower47 = ZxSimpleUI:NewModule(MODULE_NAME)

PlayerPower47.MODULE_NAME = MODULE_NAME
PlayerPower47.DECORATIVE_NAME = DECORATIVE_NAME
PlayerPower47.bars = nil
PlayerPower47.unit = "player"
-- #endregion

function PlayerPower47:__init__()
  self.PLAYER_ENGLISH_CLASS = select(2, UnitClass("player"))

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
      xoffset = 0,
      yoffset = -2,
      fontsize = 16,
      font = "Lato Bold",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "GrayVertGradient",
      color = self:_getDefaultClassPowerColor(),
      colorMana = self._powerEventColorTable["UNIT_MANA"],
      colorRage = self._powerEventColorTable["UNIT_RAGE"],
      colorFocus = self._powerEventColorTable["UNIT_FOCUS"],
      colorEnergy = self._powerEventColorTable["UNIT_ENERGY"],
      colorRunicPower = self._powerEventColorTable["UNIT_RUNIC_POWER"],
      border = "None",
      framePool = "PlayerHealth47",
      selfCurrentPoint = "TOPLEFT",
      relativePoint = "BOTTOMLEFT",
      bartextdisplay = "Percent",
    }
  }

  self.mainFrame = nil
  self.currentPowerColorEdited = self._powerEventColorTable["UNIT_MANA"]

  self._timeSinceLastUpdate = 0
  self._prevPowerValue = UnitPowerMax(self.unit)
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

  -- Always set the showbar option to false on initialize
  self.db.profile.showbar = self._defaults.profile.showbar

  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(self.MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function PlayerPower47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_enableAllScriptHandlers()
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PlayerPower47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self.mainFrame:SetScript("OnUpdate", nil)
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
  self:_refreshAll()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function PlayerPower47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then
    -- If the show option is currently selected
    if self.db.profile.showbar == true then
      self.mainFrame.statusBar:SetStatusBarColor(unpack(self.currentPowerColorEdited))
    else
      self:_setRefreshColor()
      self.bars:refreshConfig()
    end
    self:_refreshAll()
  end
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function PlayerPower47:handleEnableToggle() end

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
  self.bars:setStatusBarValueCurrMax(curUnitPower, maxUnitPower, self.db.profile.bartextdisplay)
end

function PlayerPower47:_handlePowerChanged() self:refreshConfig() end

function PlayerPower47:_registerEvents()
  for powerEvent, _ in pairs(self._powerEventColorTable) do
    self.mainFrame:RegisterEvent(powerEvent)
  end
  -- Register Druid's shapeshift form
  self.mainFrame:RegisterEvent("UNIT_DISPLAYPOWER")
end

function PlayerPower47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit)
    self:_onEventHandler(curFrame, event, unit)
  end)
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

  self.db.profile.color = t1
  self.mainFrame.statusBar:SetStatusBarColor(unpack(t1))
end

---@return table
function PlayerPower47:_getColorsInOptions()
  local t1 = {
    ["UNIT_MANA"] = self.db.profile.colorMana or self._powerEventColorTable["UNIT_MANA"],
    ["UNIT_RAGE"] = self.db.profile.colorRage,
    ["UNIT_FOCUS"] = self.db.profile.colorFocus,
    ["UNIT_ENERGY"] = self.db.profile.colorEnergy,
    ["UNIT_RUNIC_POWER"] = self.db.profile.colorRunicPower
  }
  return t1
end

---@return table
function PlayerPower47:_getDefaultClassPowerColor()
  local t1 = self._powerEventColorTable["UNIT_MANA"]
  if self.PLAYER_ENGLISH_CLASS == "WARRIOR" then
    t1 = self._powerEventColorTable["UNIT_RAGE"]
  elseif self.PLAYER_ENGLISH_CLASS == "ROGUE" then
    t1 = self._powerEventColorTable["UNIT_ENERGY"]
  elseif self.PLAYER_ENGLISH_CLASS == "DEATHKNIGHT" then
    t1 = self._powerEventColorTable["UNIT_RUNIC_POWER"]
  end
  return t1
end

function PlayerPower47:_refreshAll()
  self:_setPowerValue()
end
