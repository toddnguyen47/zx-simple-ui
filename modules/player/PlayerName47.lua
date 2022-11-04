-- #region
--- upvalues to prevent warnings
local LibStub = LibStub
local UnitName, UnitLevel = UnitName, UnitLevel

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)

local Utils47 = ZxSimpleUI.Utils47
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local RegisterWatchHandler47 = ZxSimpleUI.prereqTables["RegisterWatchHandler47"]

local MODULE_NAME = "PlayerName47"
local DECORATIVE_NAME = Locale["module.decName.playerName"]
local PlayerName47 = ZxSimpleUI:NewModule(MODULE_NAME)

PlayerName47.MODULE_NAME = MODULE_NAME
PlayerName47.DECORATIVE_NAME = DECORATIVE_NAME
PlayerName47.bars = nil
PlayerName47.unit = "player"
-- #endregion

local _PLAYER_LEVEL_UP = "PLAYER_LEVEL_UP"

function PlayerName47:__init__()
  self._defaults = {
    profile = {
      width = 200,
      height = 26,
      xoffset = 0,
      yoffset = 2,
      relativePoint = "TOPLEFT",
      fontsize = 14,
      font = "Lato Bold",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "GrayVertGradient",
      color = {0.0, 0.0, 0.0, 1.0},
      border = "None",
      enabledToggle = true,
      framePool = "PlayerHealth47"
    }
  }

  self.mainFrame = nil

  self._timeSinceLastUpdate = 0
  self._prevName = UnitName(self.unit)
  self._prevLevel = UnitLevel(self.unit)

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function PlayerName47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(self.MODULE_NAME, self._newDefaults)

  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(self.MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function PlayerName47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PlayerName47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  RegisterWatchHandler47:setUnregisterForWatch(self.mainFrame, self.unit)
  self.mainFrame:Hide()
end

---@return table
function PlayerName47:createBar()
  local percentage = 1.0
  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = ZxSimpleUI:getFrameListFrame("PlayerHealth47")
  self.bars:setTextOnly(self:_getFormattedName())
  self:_registerEvents()
  self:_handleEvents()

  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function PlayerName47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self.bars:refreshConfig() end
end

function PlayerName47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(self.MODULE_NAME, self.db.profile.enabledToggle)
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@return string formattedName
function PlayerName47:_getFormattedName(level)
  local name = UnitName(self.unit)
  name = Utils47:getInitialsExceptFirstWord(name)
  level = level or UnitLevel(self.unit)
  if tonumber(self._prevLevel) < 0 then self._prevLevel = "??" end
  return string.format("%s (%s)", name, tostring(self._prevLevel))
end

function PlayerName47:_registerEvents()
  self.mainFrame:RegisterEvent(_PLAYER_LEVEL_UP)
end

function PlayerName47:_handleEvents()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, ...)
    if (event == _PLAYER_LEVEL_UP) then
      self:_updateLevelingUp()
    end
  end)
end

function PlayerName47:_updateLevelingUp()
  if not self.mainFrame:IsVisible() then return end
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
    if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
      local level = UnitLevel(self.unit)
      if level > self._prevLevel then
        self._prevLevel = level
        self.bars:setTextOnly(self:_getFormattedName(self._prevLevel))
        -- Disable OnUpdate
        self.mainFrame:SetScript("OnUpdate", nil)
      end
    end
  end)
end
