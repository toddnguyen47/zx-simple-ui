--- upvalues to prevent warnings
local LibStub = LibStub
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitExists = UnitExists

-- #region
--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local FramePool47 = ZxSimpleUI.FramePool47
local Utils47 = ZxSimpleUI.Utils47
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local RegisterWatchHandler47 = ZxSimpleUI.prereqTables["RegisterWatchHandler47"]
local SetOnShowOnHide = ZxSimpleUI.prereqTables["SetOnShowOnHide"]

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
  self:_setOnEventHandler()
  SetOnShowOnHide:setHandlerScripts(self)
  self:_handlePetExists()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PetHealth47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_unregisterEvents()
  self.mainFrame:Hide() -- Trigger OnHide() event
end

-- For Frames that gets hidden often (e.g. Target frames)
---@param curFrame table
---Handle Blizzard's OnShow event
function PetHealth47:OnShowBlizz(curFrame, ...)
  if self:IsEnabled() then
    self:_setOnUpdateHandler()
  else
    self.mainFrame:Hide()
  end
end

---@param curFrame table
---Handle Blizzard's OnHide event
function PetHealth47:OnHideBlizz(curFrame, ...) self.mainFrame:SetScript("OnUpdate", nil) end

function PetHealth47:createBar()
  local curUnitHealth = UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)

  local anchorFrame = ZxSimpleUI:getFrameListFrame("PlayerPower47")
  self.bars.frameToAnchorTo = anchorFrame
  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = anchorFrame

  self:_setInitialVisibilityAndColor()
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
  -- Do NOT unregister UNIT_PET!
  self.mainFrame:RegisterEvent("UNIT_PET")
end

function PetHealth47:_unregisterEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:UnregisterEvent(event) end
end

function PetHealth47:_setOnUpdateHandler()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
end

function PetHealth47:_setOnEventHandler()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit, ...)
    self:_onEventHandler(curFrame, event, unit, ...)
  end)
end

---@param curFrame table
---@param event string
---@param unit string
function PetHealth47:_onEventHandler(curFrame, event, unit, ...)
  if event == "UNIT_PET" then
    if Utils47:stringEqualsIgnoreCase(unit, "player") then self:_handlePetExists() end
  end
end

function PetHealth47:_setInitialVisibilityAndColor()
  local function cleanUpFrame(frame)
    frame:SetScript("OnUpdate", nil)
    FramePool47:releaseFrame(frame)
  end

  self.mainFrame:Hide()

  local tempFrame = FramePool47:getFrame()
  local tempTimeSinceLastUpdate = 0
  local maxTimeSeconds = 0.4
  local totalElapsedTime = 0
  tempFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    totalElapsedTime = totalElapsedTime + elapsed
    tempTimeSinceLastUpdate = tempTimeSinceLastUpdate + elapsed
    if (tempTimeSinceLastUpdate > 0.1) then
      tempTimeSinceLastUpdate = 0
      if UnitExists(self.unit) then
        self.mainFrame:Show()
        cleanUpFrame(tempFrame)
      end

      -- We ran out of time
      if totalElapsedTime > maxTimeSeconds then cleanUpFrame(tempFrame) end
    end
  end)
end

function PetHealth47:_handlePetExists()
  local exists = UnitExists(self.unit)
  local shown = self.mainFrame:IsShown()
  if exists and not shown then
    self.mainFrame:Show()
  elseif not exists and shown then
    self.mainFrame:Hide()
  end
end
