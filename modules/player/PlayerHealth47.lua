-- #region
--- upvalues to prevent warnings
local LibStub = LibStub
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitName = UnitName

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)
local Utils47 = ZxSimpleUI.Utils47
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local RegisterWatchHandler47 = ZxSimpleUI.prereqTables["RegisterWatchHandler47"]

local MODULE_NAME = "PlayerHealth47"
local DECORATIVE_NAME = Locale["module.decName.playerHealth"]

local PlayerHealth47 = ZxSimpleUI:NewModule(MODULE_NAME)
PlayerHealth47.MODULE_NAME = MODULE_NAME
PlayerHealth47.DECORATIVE_NAME = DECORATIVE_NAME
PlayerHealth47.bars = nil
PlayerHealth47.unit = "player"
-- #endregion

function PlayerHealth47:__init__()
  self._defaults = {
    profile = {
      width = 200,
      height = 26,
      xoffset = -180,
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
  self.mainFrame = nil
  self.bars = nil
  self.db = nil

  self._timeSinceLastUpdate = 0
  self._prevHealth = UnitHealthMax(self.unit)

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function PlayerHealth47:OnInitialize()
  self:__init__()
  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._newDefaults)
  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function PlayerHealth47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_enableAllScriptHandlers()
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PlayerHealth47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:Hide()
end

function PlayerHealth47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self.bars:refreshConfig() end
end

function PlayerHealth47:handleEnableToggle() end

---@return table
function PlayerHealth47:createBar()
  local curUnitHealth = UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)

  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME

  self:_registerEvents()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param curFrame table
---@param elapsed number
function PlayerHealth47:_onUpdateHandler(curFrame, elapsed)
  if not self.mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitHealth = UnitHealth(self.unit)
    if (curUnitHealth ~= self._prevHealth) then
      self:_handleUnitHealthEvent(curUnitHealth)
      self._prevHealth = curUnitHealth
      self._timeSinceLastUpdate = 0
    end
  end
end

function PlayerHealth47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
  self.bars:setStatusBarValue(healthPercent)
end

function PlayerHealth47:_registerEvents() self.mainFrame:RegisterEvent("UNIT_HEALTH") end

function PlayerHealth47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
end
