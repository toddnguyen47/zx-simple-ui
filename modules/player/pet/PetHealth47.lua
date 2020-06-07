--- upvalues to prevent warnings
local LibStub = LibStub
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitName = UnitName

-- #region
--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local MODULE_NAME = "PetHealth47"
local DECORATIVE_NAME = "Pet Health"
local PetHealth47 = ZxSimpleUI:NewModule(MODULE_NAME)

PetHealth47.MODULE_NAME = MODULE_NAME
PetHealth47.DECORATIVE_NAME = DECORATIVE_NAME
PetHealth47.bars = nil
PetHealth47.unit = "pet"
-- #endregion

function PetHealth47:__init__()
  self.PLAYER_ENGLISH_CLASS = string.upper(select(2, UnitClass("player")))
  self._defaults = {
    profile = {
      enabledToggle = self.PLAYER_ENGLISH_CLASS == "HUNTER" or self.PLAYER_ENGLISH_CLASS ==
        "WARLOCK",
      width = 150,
      height = 20,
      xoffset = 0,
      yoffset = -2,
      fontsize = 14,
      font = "Lato Bold",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "GrayVertGradient",
      color = {0.0, 1.0, 0.0, 1.0},
      border = "None",
      selfCurrentPoint = "TOPRIGHT",
      relativePoint = "BOTTOMRIGHT",
      framePool = "PlayerPower47"
    }
  }

  self._eventTable = {"UNIT_HEALTH"}

  self.mainFrame = nil
  self._timeSinceLastUpdate = 0
  self._prevHealth = UnitHealthMax(self.unit)

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function PetHealth47:OnInitialize()
  self:__init__()
  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile
  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function PetHealth47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PetHealth47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_disableAllScriptHandlers()
  self:_unregisterEvents()
  self.mainFrame:Hide()
end

function PetHealth47:createBar()
  local curUnitHealth = UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)

  local anchorFrame = ZxSimpleUI:getFrameListFrame("PlayerPower47")
  self.bars.frameToAnchorTo = anchorFrame
  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = anchorFrame

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function PetHealth47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self.bars:refreshConfig() end
end

function PetHealth47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(MODULE_NAME, self._curDbProfile.enabledToggle)
end

---Explicitly call OnEnable() and OnDisable() depending on the module's IsEnabled()
---This function is exactly like refreshConfig(), except it is called only during initialization.
function PetHealth47:initModuleEnableState()
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
function PetHealth47:_onUpdateHandler(curFrame, elapsed)
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

function PetHealth47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
  self.bars:setStatusBarValue(healthPercent)
end

function PetHealth47:_registerEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:RegisterEvent(event) end
end

function PetHealth47:_unregisterEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:UnregisterEvent(event) end
end

function PetHealth47:_setOnShowOnHideHandlers()
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

function PetHealth47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
end

function PetHealth47:_disableAllScriptHandlers() self.mainFrame:SetScript("OnUpdate", nil) end
