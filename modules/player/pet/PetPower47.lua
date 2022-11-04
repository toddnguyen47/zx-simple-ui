--- upvalues to prevent warnings
local LibStub = LibStub
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitClass, UnitPowerType = UnitClass, UnitPowerType
local UnitExists = UnitExists

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)
local FramePool47 = ZxSimpleUI.FramePool47

-- #region
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.prereqTables["RegisterWatchHandler47"]
local SetOnShowOnHide = ZxSimpleUI.prereqTables["SetOnShowOnHide"]

local MODULE_NAME = "PetPower47"
local DECORATIVE_NAME = Locale["module.decName.petPower"]
local PetPower47 = ZxSimpleUI:NewModule(MODULE_NAME)

PetPower47.MODULE_NAME = MODULE_NAME
PetPower47.DECORATIVE_NAME = DECORATIVE_NAME
PetPower47.unit = "pet"
-- #endregion

function PetPower47:__init__()
  self.PLAYER_ENGLISH_CLASS = string.upper(select(2, UnitClass("player")))
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
      enabledToggle = PetPower47.PLAYER_ENGLISH_CLASS == "HUNTER" or
        PetPower47.PLAYER_ENGLISH_CLASS == "WARLOCK",
      showbar = false,
      width = 150,
      height = 20,
      xoffset = 0,
      yoffset = -2,
      fontsize = 14,
      font = "Lato Bold",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "GrayVertGradient",
      color = self:_getDefaultClassPowerColor(),
      border = "None",
      selfCurrentPoint = "TOPRIGHT",
      relativePoint = "BOTTOMRIGHT",
      framePool = "PetHealth47",
      bartextdisplay = "Percent",
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

function PetPower47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._newDefaults)

  -- Always set the showbar option to false on initialize
  self.db.profile.showbar = self._defaults.profile.showbar

  self.bars = BarTemplate:new(self.db)
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

function PetPower47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_registerEvents()
  self:_setOnEventHandler()
  SetOnShowOnHide:setHandlerScripts(self)
  self:_handlePetExists()
end

function PetPower47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_unregisterEvents()
  self.mainFrame:Hide() -- Trigger OnHide()
end

-- For Frames that gets hidden often (e.g. Target frames)
---@param curFrame table
---Handle Blizzard's OnShow event
function PetPower47:OnShowBlizz(curFrame, ...)
  if self:IsEnabled() then
    self:_setOnUpdateHandler()
  else
    self.mainFrame:Hide()
  end
end

---@param curFrame table
---Handle Blizzard's OnHide event
function PetPower47:OnHideBlizz(curFrame, ...) self.mainFrame:SetScript("OnUpdate", nil) end

---@return table
function PetPower47:createBar()
  local curUnitPower = UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)

  local anchorFrame = ZxSimpleUI:getFrameListFrame(self.db.profile.framePool)
  self.bars.frameToAnchorTo = anchorFrame
  self.mainFrame = self.bars:createBar(percentage)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = anchorFrame

  self:_setInitialVisibilityAndColor()
  self:_refreshAll()
  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function PetPower47:refreshConfig()
  self:handleEnableToggle()
  self:_refreshAll()
  if self:IsEnabled() then
    -- If the show option is currently selected
    if self.db.profile.showbar == true then
      self.mainFrame.statusBar:SetStatusBarColor(unpack(self.currentPowerColorEdited))
    else
      self.bars:refreshConfig()
    end
  end
end

function PetPower47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(MODULE_NAME, self.db.profile.enabledToggle)
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param curFrame table
---@param elapsed number
function PetPower47:_onUpdateHandler(curFrame, elapsed)
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
function PetPower47:_onEventHandler(curFrame, event, unit, ...)
  if event == "UNIT_DISPLAYPOWER" then
    local isSameUnit = Utils47:stringEqualsIgnoreCase(unit, self.unit)
    if isSameUnit then self:_handlePowerChanged() end
  elseif event == "UNIT_PET" then
    if Utils47:stringEqualsIgnoreCase(unit, "player") then
      self:_handlePetExists(curFrame, event, unit, ...)
    end
  end
end

---@param curUnitPower number
function PetPower47:_setPowerValue(curUnitPower)
  curUnitPower = curUnitPower or UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  self.bars:setStatusBarValueCurrMax(curUnitPower, maxUnitPower, self.db.profile.bartextdisplay)
end

function PetPower47:_handlePowerChanged() self:refreshConfig() end

function PetPower47:_registerEvents()
  for powerEvent, _ in pairs(self._powerEventColorTable) do
    self.mainFrame:RegisterEvent(powerEvent)
  end
  self.mainFrame:RegisterEvent("UNIT_DISPLAYPOWER")
  -- Do NOT unregister UNIT_PET!
  self.mainFrame:RegisterEvent("UNIT_PET")
end

function PetPower47:_unregisterEvents()
  for powerEvent, _ in pairs(self._powerEventColorTable) do
    self.mainFrame:UnregisterEvent(powerEvent)
  end
  self.mainFrame:UnregisterEvent("UNIT_DISPLAYPOWER")
end

function PetPower47:_setOnUpdateHandler()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
end

function PetPower47:_setOnEventHandler()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit, ...)
    self:_onEventHandler(curFrame, event, unit, ...)
  end)
end

function PetPower47:_setUnitPowerType()
  self._powerType, self._powerTypeString = UnitPowerType(self.unit)
end

function PetPower47:_setInitialColor()
  self:_setUnitPowerType()
  local upperType = string.upper(self._powerTypeString)
  local t1 = self._powerEventColorTable["UNIT_" .. upperType]
  t1 = t1 or self._powerEventColorTable["UNIT_MANA"]

  self._newDefaults.profile.color = t1
  self.db.profile.color = t1
  self.mainFrame.statusBar:SetStatusBarColor(unpack(t1))
end

function PetPower47:_setInitialVisibilityAndColor()
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
      -- Only update color if there is a pet
      if UnitExists(self.unit) then
        self:_setUnitPowerType()
        if self._powerTypeString ~= "" then
          self:_setInitialColor()
          self.mainFrame:Show()
          cleanUpFrame(tempFrame)
        end
      end

      -- We ran out of time
      if totalElapsedTime > maxTimeSeconds then cleanUpFrame(tempFrame) end
    end
  end)
end

function PetPower47:_handlePetExists()
  local exists = UnitExists(self.unit)
  local shown = self.mainFrame:IsShown()
  if exists and not shown then
    self:_setUnitPowerType()
    self:_setInitialColor()
    self.mainFrame:Show()
  elseif not exists and shown then
    self.mainFrame:Hide()
  end
end

---@return table
function PetPower47:_getDefaultClassPowerColor()
  local t1 = self._powerEventColorTable["UNIT_MANA"]
  if self.PLAYER_ENGLISH_CLASS == "HUNTER" then
    t1 = self._powerEventColorTable["UNIT_FOCUS"]
  elseif self.PLAYER_ENGLISH_CLASS == "WARLOCK" then
    t1 = self._powerEventColorTable["UNIT_MANA"]
  end
  return t1
end

function PetPower47:_refreshAll()
  self:_setPowerValue()
end
