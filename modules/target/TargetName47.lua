---upvalues to prevent warnings
local UnitName, UnitHealth, UnitReaction = UnitName, UnitHealth, UnitReaction
local UnitClassification, UnitLevel = UnitClassification, UnitLevel

---include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

-- #region
local MODULE_NAME = "TargetName47"
local DECORATIVE_NAME = "Target Name"
local TargetName47 = ZxSimpleUI:NewModule(MODULE_NAME)

TargetName47.MODULE_NAME = MODULE_NAME
TargetName47.DECORATIVE_NAME = DECORATIVE_NAME
TargetName47.bars = nil
-- #endregion

function TargetName47:__init__()
  self._UNIT_REACTIONS = {
    HATED = 1,
    HOSTILE = 2,
    UNFRIENDLY = 3,
    NEUTRAL = 4,
    FRIENDLY = 5,
    HONORED = 6,
    REVERED = 7,
    EXALTED = 8
  }

  self._defaults = {
    profile = {
      width = 200,
      height = 26,
      xoffset = 0,
      yoffset = 2,
      fontsize = 14,
      font = "Lato Bold",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "GrayVertGradient",
      color = {0.0, 0.0, 0.0, 1.0},
      border = "None",
      enabledToggle = true,
      framePool = "TargetHealth47",
      selfCurrentPoint = "BOTTOMLEFT",
      relativePoint = "TOPLEFT",
      hostileColor = {1.0, 0.2, 0.2, 1.0},
      neutralColor = {1.0, 1.0, 0.0, 1.0},
      friendlyColor = {1.0, 1.0, 1.0, 1.0}
    }
  }
  self._eventTable = {"UNIT_HEALTH", "PLAYER_TARGET_CHANGED"}
  self.unit = "target"

  self._timeSinceLastUpdate = 0
  self._prevName = UnitName(self.unit)
  self.mainFrame = nil

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function TargetName47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile

  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function TargetName47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_registerEvents()
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function TargetName47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_unregisterEvents()
  self.mainFrame:Hide()
end

-- For Frames that gets hidden often (e.g. Target frames)
---@param curFrame table
---Handle Blizzard's OnShow event
function TargetName47:OnShowBlizz(curFrame, ...)
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
function TargetName47:OnHideBlizz(curFrame, ...) self:_disableAllScriptHandlers() end

function TargetName47:createBar()
  local percentage = 1.0
  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME

  self:_refreshName()

  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()
  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})

  self.mainFrame:Hide()
  return self.mainFrame
end

function TargetName47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() and self.mainFrame:IsVisible() then
    self.bars:refreshConfig()
    self:_refreshName()
  end
end

function TargetName47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(MODULE_NAME, self._curDbProfile.enabledToggle)
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetName47:_registerEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:RegisterEvent(event) end
end

function TargetName47:_unregisterEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:UnregisterEvent(event) end
end

function TargetName47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow",
    function(curFrame, ...) self:OnShowBlizz(curFrame, ...) end)

  self.mainFrame:SetScript("OnHide",
    function(curFrame, ...) self:OnHideBlizz(curFrame, ...) end)
end

function TargetName47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit, ...)
    self:_onEventHandler(curFrame, event, unit)
  end)
end

function TargetName47:_disableAllScriptHandlers() self.mainFrame:SetScript("OnEvent", nil) end

function TargetName47:_onEventHandler(curFrame, event, unit, ...)
  local isUnitHealthEvent = Utils47:stringEqualsIgnoreCase(event, "UNIT_HEALTH")
  local isSameUnit = Utils47:stringEqualsIgnoreCase(unit, self.unit)
  if isUnitHealthEvent and isSameUnit then
    self:_handleUnitHealthEvent()
  elseif Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  end
end

function TargetName47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  if curUnitHealth > 0 then self:_refreshName() end
end

function TargetName47:_handlePlayerTargetChanged()
  local curUnitName = UnitName(self.unit)
  if curUnitName ~= nil and curUnitName ~= "" then self:_refreshName() end
end

function TargetName47:_refreshName()
  self.mainFrame.mainText:SetText(self:_getFormattedName())
  self.mainFrame.mainText:SetTextColor(unpack(self:_getReactionColor()))
end

---@return string formattedName
function TargetName47:_getFormattedName()
  local name = UnitName(self.unit) or ""
  local level = UnitLevel(self.unit) or ""
  if tonumber(level) < 0 then level = "??" end
  local formattedName = Utils47:getInitials(name)
  formattedName = string.format("%s (%s)", formattedName, level)
  local unitClassification = UnitClassification(self.unit)
  if not Utils47:isNormalEnemy(unitClassification) then
    local s1 = Utils47.UnitClassificationElitesTable[unitClassification]
    formattedName = string.format("(%s) %s", s1, formattedName)
  end
  return formattedName
end

---@return table
function TargetName47:_getReactionColor()
  local reaction = UnitReaction("player", self.unit)
  local color = {}
  if reaction == self._UNIT_REACTIONS.HOSTILE then
    color = self._curDbProfile.hostileColor
  elseif reaction == self._UNIT_REACTIONS.NEUTRAL then
    color = self._curDbProfile.neutralColor
  else
    color = self._curDbProfile.friendlyColor
  end
  return color
end
