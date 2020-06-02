--- upvalues to prevent warnings
local LibStub = LibStub
local CreateFrame = CreateFrame
local MAX_COMBO_POINTS, GetComboPoints = MAX_COMBO_POINTS, GetComboPoints
local UnitName, UnitClass = UnitName, UnitClass
local unpack = unpack

---include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "Combo47"
local _DECORATIVE_NAME = "Combo Points Display"
local Combo47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

Combo47.MODULE_NAME = _MODULE_NAME
Combo47.DECORATIVE_NAME = _DECORATIVE_NAME
Combo47.PLAYER_ENGLISH_CLASS = select(2, UnitClass("player"))
Combo47.EVENT_TABLE = {"PLAYER_TARGET_CHANGED", "UNIT_COMBO_POINTS"}
Combo47.bars = nil
Combo47.unit = "target"

local _defaults = {
  profile = {
    texture = "Skewed",
    mediumComboPoints = 3,
    lowComboColor = {1.0, 1.0, 0.0, 1.0},
    medComboColor = {1.0, 0.65, 0.0, 1.0},
    maxComboColor = {1.0, 0.0, 0.0, 1.0},
    height = 8,
    showbar = false,
    enabledToggle = Combo47.PLAYER_ENGLISH_CLASS == "ROGUE" or Combo47.PLAYER_ENGLISH_CLASS ==
      "DRUID",
    horizGap = 15,
    yoffset = 0
  }
}

function Combo47:OnInitialize()
  self:__init__()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  -- Always set the showbar option to false on initialize
  self._curDbProfile.showbar = _defaults.profile.showbar

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
end

function Combo47:OnEnable() self:handleOnEnable() end

function Combo47:OnDisable() self:handleOnDisable() end

function Combo47:__init__()
  self.mainFrame = nil

  self._comboPointsTable = {}
  self._allComboPointsHidden = true
  self._playerEnglishClass = UnitClass("player")
  self._frameToAnchorTo = nil
end

---@param frameToAnchorTo table
function Combo47:createBar(frameToAnchorTo)
  assert(frameToAnchorTo ~= nil)
  self._frameToAnchorTo = frameToAnchorTo

  self.mainFrame = CreateFrame("Frame", nil, self._frameToAnchorTo)
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)

  self.mainFrame.bgTexture = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgTexture:SetTexture(0, 0, 0, 0.5)
  self.mainFrame.bgTexture:SetAllPoints(self.mainFrame)

  self:_createIndividualComboPointsDisplay()
  self:_setOnEventScript()

  self.mainFrame:Hide()
  return self.mainFrame
end

function Combo47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self:_refreshAll() end
end

function Combo47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, self._curDbProfile.enabledToggle)
end

function Combo47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:_registerAllEvents()
    self:refreshConfig()
    self:_handleComboPoints()
  end
end

function Combo47:handleOnDisable()
  if self.mainFrame ~= nil then
    self:_unregisterAllEvents()
    self.mainFrame:Hide()
    self:_hideAllComboPoints()
  end
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
  self.mainFrame:Hide()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Combo47:_refreshAll()
  self:_refreshBarFrame()
  self:_refreshComboPointsDisplay()
end

function Combo47:_refreshBarFrame()
  self.mainFrame:SetWidth(self._frameToAnchorTo:GetWidth())
  self.mainFrame:SetHeight(self._curDbProfile.height)
  self.mainFrame:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
  self.mainFrame:SetPoint("TOPLEFT", self._frameToAnchorTo, "BOTTOMLEFT", 0,
    self._curDbProfile.yoffset)
end

function Combo47:_refreshComboPointsDisplay()
  local totalNumberOfGaps = self._curDbProfile.horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (self._frameToAnchorTo:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS
  for i, comboTexture in ipairs(self._comboPointsTable) do
    comboTexture:SetWidth(comboWidth)
    comboTexture:SetHeight(self.mainFrame:GetHeight())
    comboTexture:SetTexture(media:Fetch("statusbar", self._curDbProfile.texture), "BORDER")
    self:_setComboPointsColor(i, comboTexture)
    comboTexture:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details

    if i == 1 then
      comboTexture:SetPoint("TOPLEFT", self._frameToAnchorTo, "BOTTOMLEFT", 0,
        self._curDbProfile.yoffset)
    else
      comboTexture:SetPoint("TOPLEFT", self._comboPointsTable[i - 1], "TOPRIGHT",
        self._curDbProfile.horizGap, 0)
    end
  end
end

function Combo47:_registerAllEvents()
  for _, event in pairs(self.EVENT_TABLE) do self.mainFrame:RegisterEvent(event) end
end

function Combo47:_unregisterAllEvents()
  for _, event in pairs(self.EVENT_TABLE) do self.mainFrame:UnregisterEvent(event) end
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
  if not self._allComboPointsHidden and comboPoints == 0 then
    self.mainFrame:Hide()
    self:_hideAllComboPoints()
    self._allComboPointsHidden = true
  else
    for i = 1, comboPoints do
      if i == 1 then self.mainFrame:Show() end
      local currentTexture = self._comboPointsTable[i]
      self:_setComboPointsColor(comboPoints, currentTexture)
      currentTexture:Show()
      self._allComboPointsHidden = false
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
    comboTexture:SetVertexColor(unpack(self._curDbProfile.maxComboColor))
  elseif self._curDbProfile.mediumComboPoints > 0 and comboPoints >=
    self._curDbProfile.mediumComboPoints then
    comboTexture:SetVertexColor(unpack(self._curDbProfile.medComboColor))
  else
    comboTexture:SetVertexColor(unpack(self._curDbProfile.lowComboColor))
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
