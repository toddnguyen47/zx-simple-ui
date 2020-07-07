--- upvalues to prevent warnings
local LibStub = LibStub
local CreateFrame = CreateFrame
local MAX_COMBO_POINTS, GetComboPoints = MAX_COMBO_POINTS, GetComboPoints
local UnitName, UnitClass = UnitName, UnitClass
local unpack = unpack

---include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]

-- #region
local MODULE_NAME = "Combo47"
local DECORATIVE_NAME = "Combo Points Display"
local Combo47 = ZxSimpleUI:NewModule(MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

Combo47.MODULE_NAME = MODULE_NAME
Combo47.DECORATIVE_NAME = DECORATIVE_NAME
Combo47.bars = nil
Combo47.unit = "target"
-- #endregion

function Combo47:__init__()
  self.PLAYER_ENGLISH_CLASS = select(2, UnitClass("player"))
  self._eventTable = {"PLAYER_TARGET_CHANGED", "UNIT_COMBO_POINTS"}
  self._defaults = {
    profile = {
      texture = "GrayVertGradient",
      mediumComboPoints = 3,
      lowComboColor = {1.0, 1.0, 0.0, 1.0},
      medComboColor = {1.0, 0.65, 0.0, 1.0},
      maxComboColor = {1.0, 0.0, 0.0, 1.0},
      height = 8,
      showbar = false,
      enabledToggle = self.PLAYER_ENGLISH_CLASS == "ROGUE" or self.PLAYER_ENGLISH_CLASS ==
        "DRUID",
      horizGap = 15,
      yoffset = 0,
      framePool = "TargetPower47",
      selfCurrentPoint = "TOPLEFT",
      relativePoint = "BOTTOMLEFT",
      backgroundColor = {0, 0, 0, 0.4}
    }
  }

  self.mainFrame = nil

  self._comboPointsTable = {}
  self._playerEnglishClass = UnitClass("player")
  self._frameToAnchorTo = nil
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function Combo47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._defaults)

  -- Always set the showbar option to false on initialize
  self.db.profile.showbar = self._defaults.profile.showbar

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, self._defaults.profile)
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function Combo47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_registerAllEvents()

  -- Don't show until combo points appear
  -- self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function Combo47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_unregisterAllEvents()
  self.mainFrame:Hide()
end

function Combo47:createBar()
  self._frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self.db.profile.framePool)

  self.mainFrame = CreateFrame("Frame", nil, self._frameToAnchorTo)
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME

  self.mainFrame.bgTexture = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgTexture:SetTexture(unpack(self.db.profile.backgroundColor))
  self.mainFrame.bgTexture:SetAllPoints(self.mainFrame)

  self:_createIndividualComboPointsDisplay()
  self:_setOnEventScript()
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})

  self.mainFrame:Hide()
  return self.mainFrame
end

function Combo47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then
    self:_refreshAll()
    -- If we are currently seeing the showbar option, do not need to handle combo points
    if not self.db.profile.showbar then self:_handleComboPoints() end
  end
end

function Combo47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(MODULE_NAME, self.db.profile.enabledToggle)
end

function Combo47:handleShownOption()
  self.mainFrame:Show()
  for i, comboTexture in ipairs(self._comboPointsTable) do
    self:_setComboPointsColor(i, comboTexture)
    comboTexture:Show()
  end
end

function Combo47:handleShownHideOption()
  self:_hideAllComboPoints()
  self:_handleComboPoints()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Combo47:_refreshAll()
  self:_refreshBarFrame()
  self:_refreshComboPointsDisplay()
end

function Combo47:_refreshBarFrame()
  self._frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self.db.profile.framePool)

  self.mainFrame:SetWidth(self._frameToAnchorTo:GetWidth())
  self.mainFrame:SetHeight(self.db.profile.height)
  self.mainFrame:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
  self.mainFrame:SetPoint(self.db.profile.selfCurrentPoint, self._frameToAnchorTo,
    self.db.profile.relativePoint, 0, self.db.profile.yoffset)

  self.mainFrame.bgTexture:SetTexture(unpack(self.db.profile.backgroundColor))
end

function Combo47:_refreshComboPointsDisplay()
  local totalNumberOfGaps = self.db.profile.horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (self._frameToAnchorTo:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS
  for i, comboTexture in ipairs(self._comboPointsTable) do
    comboTexture:SetWidth(comboWidth)
    comboTexture:SetHeight(self.mainFrame:GetHeight())
    comboTexture:SetTexture(media:Fetch("statusbar", self.db.profile.texture), "BORDER")
    self:_setComboPointsColor(i, comboTexture)
    comboTexture:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details

    if i == 1 then
      comboTexture:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 0, 0)
    else
      comboTexture:SetPoint("TOPLEFT", self._comboPointsTable[i - 1], "TOPRIGHT",
        self.db.profile.horizGap, 0)
    end
  end
end

function Combo47:_registerAllEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:RegisterEvent(event) end
end

function Combo47:_unregisterAllEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:UnregisterEvent(event) end
end

function Combo47:_setOnEventScript()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit)
    self:_onEventHandler(curFrame, event, unit)
  end)
end

function Combo47:_onEventHandler(curFrame, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(event, "UNIT_COMBO_POINTS") then
    self:_handleComboPoints()
  end
end

function Combo47:_handleComboPoints()
  local comboPoints = GetComboPoints("player", self.unit)
  if comboPoints == 0 and self.mainFrame:IsVisible() then
    self.mainFrame:Hide()
    self:_hideAllComboPoints()
  else
    for i = 1, comboPoints do
      if i == 1 then self.mainFrame:Show() end
      local currentTexture = self._comboPointsTable[i]
      self:_setComboPointsColor(comboPoints, currentTexture)
      currentTexture:Show()
    end
  end
end

function Combo47:_handlePlayerTargetChanged()
  local targetName = UnitName(self.unit)
  if targetName ~= nil and targetName ~= "" then self:_handleComboPoints() end
end

function Combo47:_hideAllComboPoints()
  for i = 1, MAX_COMBO_POINTS do self._comboPointsTable[i]:Hide() end
end

---@param comboPoints integer
---@param comboTexture table
function Combo47:_setComboPointsColor(comboPoints, comboTexture)
  if comboPoints >= MAX_COMBO_POINTS then
    comboTexture:SetVertexColor(unpack(self.db.profile.maxComboColor))
  elseif self.db.profile.mediumComboPoints > 0 and comboPoints >=
    self.db.profile.mediumComboPoints then
    comboTexture:SetVertexColor(unpack(self.db.profile.medComboColor))
  else
    comboTexture:SetVertexColor(unpack(self.db.profile.lowComboColor))
  end
end

function Combo47:_createIndividualComboPointsDisplay()
  -- Create all MAX_COMBO_POINTS frames
  -- Ref: https://wow.gamepedia.com/API_Region_SetPoint
  for i = 1, MAX_COMBO_POINTS do
    local comboTexture = self.mainFrame:CreateTexture(nil, "OVERLAY")
    comboTexture:ClearAllPoints()
    comboTexture:Hide()
    self._comboPointsTable[i] = comboTexture
  end
end
