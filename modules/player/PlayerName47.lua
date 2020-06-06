-- #region
--- upvalues to prevent warnings
local LibStub = LibStub
local UnitName, UnitLevel = UnitName, UnitLevel

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local Utils47 = ZxSimpleUI.Utils47
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local MODULE_NAME = "PlayerName47"
local DECORATIVE_NAME = "Player Name"
local PlayerName47 = ZxSimpleUI:NewModule(MODULE_NAME)

PlayerName47.MODULE_NAME = MODULE_NAME
PlayerName47.DECORATIVE_NAME = DECORATIVE_NAME
PlayerName47.bars = nil
PlayerName47.unit = "player"
-- #endregion

function PlayerName47:__init__()
  self._defaults = {
    profile = {
      width = 200,
      height = 26,
      xoffset = 0,
      yoffset = 2,
      relativePoint = "TOPLEFT",
      fontsize = 14,
      font = "PT Sans Bold",
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

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function PlayerName47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(self.MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile

  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(self.MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function PlayerName47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PlayerName47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self.mainFrame:Hide()
end

---@return table
function PlayerName47:createBar()
  local percentage = 1.0
  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = ZxSimpleUI:getFrameListFrame("PlayerHealth47")
  self.bars:setTextOnly(self:_getFormattedName())

  self:_setOnShowOnHideHandlers()
  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function PlayerName47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self.bars:refreshConfig() end
end

function PlayerName47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(self.MODULE_NAME, self._curDbProfile.enabledToggle)
end

---Explicitly call OnEnable() and OnDisable() depending on the module's IsEnabled()
---This function is exactly like refreshConfig(), except it is called only during initialization.
function PlayerName47:initModuleEnableState()
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

---@return string formattedName
function PlayerName47:_getFormattedName()
  local name = UnitName(self.unit)
  name = Utils47:getInitials(name)
  local level = UnitLevel(self.unit)
  return string.format("%s (%s)", name, level)
end

function PlayerName47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(curFrame, ...)
    -- Even if shown, if the module is disabled, hide the frame!
    if not self:IsEnabled() then self.mainFrame:Hide() end
  end)
end
