local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47
local TargetPower47 = ZxSimpleUI:GetModule("TargetPower47")

local _MODULE_NAME = "Combo47"
local _DECORATIVE_NAME = "Combo Points Display"
local Combo47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local CreateFrame = CreateFrame
local MAX_COMBO_POINTS, GetComboPoints = MAX_COMBO_POINTS, GetComboPoints
local UnitName, UnitClass = UnitName, UnitClass
local unpack = unpack

Combo47.MODULE_NAME = _MODULE_NAME
Combo47.PLAYER_ENGLISH_CLASS = select(2, UnitClass("player"))
Combo47.EVENT_TABLE = {"PLAYER_TARGET_CHANGED", "UNIT_COMBO_POINTS"}
Combo47.bars = nil
Combo47.unit = "target"

local _defaults = {
  profile = {
    texture = "Blizzard",
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
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getOptionTable(), _DECORATIVE_NAME)
end

function Combo47:OnEnable() self:handleOnEnable() end

function Combo47:OnDisable() self:handleOnDisable() end

function Combo47:__init__()
  self.options = {}
  self.mainFrame = nil

  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX
  self._comboPointsTable = {}
  self._allComboPointsHidden = true
  self._playerEnglishClass = UnitClass("player")
  self._frameToAttachTo = nil
end

---@param frameToAttachTo table
function Combo47:createBar(frameToAttachTo)
  assert(frameToAttachTo ~= nil)
  self._frameToAttachTo = frameToAttachTo

  self.mainFrame = CreateFrame("Frame", nil, self._frameToAttachTo)
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)

  self.mainFrame.bgTexture = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgTexture:SetTexture(0, 0, 0, 0.5)
  self.mainFrame.bgTexture:SetAllPoints()

  self:_createIndividualComboPointsDisplay()
  self:_setOnEventScript()

  self.mainFrame:Hide()
  return self.mainFrame
end

function Combo47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then
    self:_refreshBarFrame()
    self:_refreshComboPointsDisplay()
  end
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

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Combo47:_refreshBarFrame()
  self.mainFrame:SetWidth(self._frameToAttachTo:GetWidth())
  self.mainFrame:SetHeight(self._curDbProfile.height)
  self.mainFrame:SetPoint("TOPLEFT", self._frameToAttachTo, "BOTTOMLEFT", 0,
    self._curDbProfile.yoffset)
end

function Combo47:_refreshComboPointsDisplay()
  local totalNumberOfGaps = self._curDbProfile.horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (self._frameToAttachTo:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS
  for i, comboTexture in ipairs(self._comboPointsTable) do
    comboTexture:SetWidth(comboWidth)
    comboTexture:SetHeight(self.mainFrame:GetHeight())
    comboTexture:SetTexture(media:Fetch("statusbar", self._curDbProfile.texture), "BORDER")
    self:_setComboPointsColor(i, comboTexture)
    if i == 1 then
      comboTexture:SetPoint("TOPLEFT", self._frameToAttachTo, "BOTTOMLEFT", 0,
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

---@param info table
---Ref: https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function Combo47:_getOption(info)
  local keyLeafNode = info[#info]
  return self._curDbProfile[keyLeafNode]
end

---@param info table
---@param value any
---Ref: https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function Combo47:_setOption(info, value)
  local keyLeafNode = info[#info]
  self._curDbProfile[keyLeafNode] = value
  self:refreshConfig()
end

---@param info table
function Combo47:_getOptionColor(info) return unpack(self:_getOption(info)) end

---@param info table
function Combo47:_setOptionColor(info, r, g, b, a) self:_setOption(info, {r, g, b, a}) end

function Combo47:_getShownOption(info) return self:_getOption(info) end

---@param info table
---@param value boolean
function Combo47:_setShownOption(info, value)
  self:_setOption(info, value)
  if (value == true) then
    self.mainFrame:Show()
    for i, comboTexture in ipairs(self._comboPointsTable) do
      self:_setComboPointsColor(i, comboTexture)
      comboTexture:Show()
    end
  else
    self:_hideAllComboPoints()
    self.mainFrame:Hide()
  end
end

function Combo47:_incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end

---@return table
function Combo47:_getOptionTable()
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = _DECORATIVE_NAME,
      --- "Parent" get/set
      get = function(info) return self:_getOption(info) end,
      set = function(info, value) self:_setOption(info, value) end,
      args = {
        header = {
          type = "header",
          name = _DECORATIVE_NAME,
          order = ZxSimpleUI.HEADER_ORDER_INDEX
        },
        enabledToggle = {
          type = "toggle",
          name = "Enable",
          desc = "Enable / Disable this module",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 1,
          disabled = function(info) return self._curDbProfile.showbar end
        },
        showbar = {
          type = "toggle",
          name = "Show Display",
          desc = "Show/Hide the Combo Points Display",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 2,
          get = function(info) return self:_getShownOption(info) end,
          set = function(info, value) self:_setShownOption(info, value) end
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self:_incrementOrderIndex()
        },
        height = {
          name = "Combo Height",
          desc = "Combo display height",
          type = "range",
          min = 2,
          max = 20,
          step = 1,
          order = self:_incrementOrderIndex()
        },
        horizGap = {
          name = "Horizontal Gap",
          desc = "Horizontal Gap between each combo point bar",
          type = "range",
          min = 0,
          max = 30,
          step = 1,
          order = self:_incrementOrderIndex()
        },
        yoffset = {
          name = "Y Offset",
          desc = "Y Offset",
          type = "range",
          min = -30,
          max = 30,
          step = 1,
          order = self:_incrementOrderIndex()
        },
        colorHeader = {name = "Colors", type = "header", order = self:_incrementOrderIndex()},
        mediumComboPoints = {
          name = "Medium Combo Points",
          desc = "For combo points > 0 and < " .. MAX_COMBO_POINTS .. ". Set to 0 to disable.",
          type = "range",
          min = 0,
          max = MAX_COMBO_POINTS - 1,
          step = 1,
          order = self:_incrementOrderIndex()
        },
        lowComboColor = {
          name = "Low Combo Color",
          desc = "Color for low (below medium setpoint) combo points",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        medComboColor = {
          name = "Medium Combo Color",
          desc = "Color for medium combo points (greater than or equal to " ..
            "Medium Combo Points, but less than MAX)",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        maxComboColor = {
          name = "Max Combo Color",
          desc = "Color for MAX combo points",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end
