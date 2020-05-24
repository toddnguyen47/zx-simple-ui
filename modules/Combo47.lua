local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "Combo47"
local _DECORATIVE_NAME = "Combo Points Display"
local Combo47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local MAX_COMBO_POINTS, GetComboPoints = MAX_COMBO_POINTS, GetComboPoints
local UnitName, UnitClass = UnitName, UnitClass
local UnitHealth, UnitPowerType = UnitHealth, UnitPowerType
local ToggleDropDownMenu, TargetFrameDropDown = ToggleDropDownMenu, TargetFrameDropDown
local unpack = unpack

Combo47.MODULE_NAME = _MODULE_NAME
Combo47.bars = nil
Combo47.unit = "target"
Combo47.playerEnglishClass = select(2, UnitClass("player"))

local _defaults = {
  profile = {
    texture = "Blizzard",
    mediumComboPoints = 3,
    lowComboColor = {1.0, 1.0, 0.0, 1.0},
    medComboColor = {1.0, 0.65, 0.0, 1.0},
    maxComboColor = {1.0, 0.0, 0.0, 1.0},
    height = 8,
    showbar = false,
    enabledToggle = Combo47.playerEnglishClass == "ROGUE" or Combo47.playerEnglishClass ==
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

function Combo47:OnEnable()
end

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
  local horizGap = 15
  local totalNumberOfGaps = horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (self._frameToAttachTo:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS

  self.mainFrame = CreateFrame("Frame", nil, self._frameToAttachTo)
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)
  self.mainFrame:SetWidth(self._frameToAttachTo:GetWidth())
  self.mainFrame:SetHeight(self._curDbProfile.height)
  self.mainFrame:SetPoint("BOTTOMLEFT", self._frameToAttachTo, "BOTTOMLEFT", 0, 0)

  self:_createIndividualComboPointsDisplay()
  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  return self.mainFrame
end

function Combo47:refreshConfig()
  self:_handleEnableOption()
  self:_handleShownOption()
  if self:IsEnabled() then
    self:_refreshBarFrame()
    self:_refreshStatusBar()
    self:_handleComboPoints()
    if self._curDbProfile.showbar then self:_showAllComboPoints() end
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Combo47:_createIndividualComboPointsDisplay()
  local totalNumberOfGaps = self._curDbProfile.horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (self._frameToAttachTo:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS

  -- Create all MAX_COMBO_POINTS frames
  -- Ref: https://wow.gamepedia.com/API_Region_SetPoint
  for i = 1, MAX_COMBO_POINTS do
    local parentFrame, relativePoint = nil, nil
    local xoffset, yoffset = 0, 0
    if i == 1 then
      parentFrame = self.mainFrame
      relativePoint = "BOTTOMLEFT"
      yoffset = self._curDbProfile.yoffset
    else
      parentFrame = self._comboPointsTable[i - 1]
      relativePoint = "TOPRIGHT"
      xoffset = self._curDbProfile.horizGap
    end
    local comboTexture = self.mainFrame:CreateTexture(nil, "OVERLAY")
    comboTexture:ClearAllPoints()
    comboTexture:SetWidth(comboWidth)
    comboTexture:SetHeight(self.mainFrame:GetHeight())
    comboTexture:SetPoint("TOPLEFT", parentFrame, relativePoint, xoffset, yoffset)
    comboTexture:SetTexture(media:Fetch("statusbar", self._curDbProfile.texture))
    comboTexture:SetVertexColor(unpack(self._curDbProfile.lowComboColor))
    comboTexture:Hide()
    self._comboPointsTable[i] = comboTexture
  end
end

function Combo47:_registerEvents()
  self.mainFrame:RegisterEvent("UNIT_COMBO_POINTS")
  self.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function Combo47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(argsTable, ...)
    if self:IsEnabled() then
      self:_enableAllScriptHandlers()
      self.mainFrame:Show()
    else
      self.mainFrame:Hide()
    end
  end)

  self.mainFrame:SetScript("OnHide", function(argsTable, ...)
    self:_disableAllScriptHandlers()
  end)
end

function Combo47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
end

function Combo47:_disableAllScriptHandlers()
  -- Do not disable OnEvent in Combo Points since we are not using RegisterUnitWatch to display
  -- self.mainFrame:SetScript("OnEvent", nil)
end

function Combo47:_onEventHandler(argsTable, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(event, "UNIT_COMBO_POINTS") then
    self:_handleComboPoints()
  end
end

---@param infoTable table
function Combo47:_getOption(infoTable)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  return self._curDbProfile[key]
end

---@param infoTable table
---@param value any
function Combo47:_setOption(infoTable, value)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  self._curDbProfile[key] = value
  self:refreshConfig()
end

---@param infoTable table
function Combo47:_getOptionColor(infoTable)
  return unpack(self:_getOption(infoTable))
end

---@param infoTable table
function Combo47:_setOptionColor(infoTable, r, g, b, a)
  self:_setOption(infoTable, {r, g, b, a})
end

function Combo47:_incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end

function Combo47:_hideAllComboPoints()
  for i = 1, MAX_COMBO_POINTS do self._comboPointsTable[i]:Hide() end
end

function Combo47:_showAllComboPoints()
  for i = 1, MAX_COMBO_POINTS do
    local currentTexture = self._comboPointsTable[i]
    currentTexture:Show()
    self:_setComboPointsColor(i, currentTexture)
  end
end

---@param comboPoints integer
---@param currentTexture table
function Combo47:_setComboPointsColor(comboPoints, currentTexture)
  if comboPoints >= MAX_COMBO_POINTS then
    currentTexture:SetVertexColor(unpack(self._curDbProfile.maxComboColor))
  elseif self._curDbProfile.mediumComboPoints > 0 and comboPoints >=
    self._curDbProfile.mediumComboPoints then
    currentTexture:SetVertexColor(unpack(self._curDbProfile.medComboColor))
  else
    currentTexture:SetVertexColor(unpack(self._curDbProfile.lowComboColor))
  end
end

function Combo47:_handleComboPoints()
  local comboPoints = GetComboPoints("player", self.unit)
  if not self._allComboPointsHidden and comboPoints == 0 then
    self:_hideAllComboPoints()
    self._allComboPointsHidden = true
  else
    for i = 1, comboPoints do
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

function Combo47:_refreshBarFrame()
  self.mainFrame:SetHeight(self._curDbProfile.height)
  for _, texture in pairs(self._comboPointsTable) do
    texture:SetHeight(self.mainFrame:GetHeight())
  end
end

function Combo47:_refreshStatusBar()
  local totalNumberOfGaps = self._curDbProfile.horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (self._frameToAttachTo:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS

  for i, texture in ipairs(self._comboPointsTable) do
    texture:SetTexture(media:Fetch("statusbar", self._curDbProfile.texture), "BORDER")
    texture:SetWidth(comboWidth)
    if i == 1 then
      texture:SetPoint("TOPLEFT", self._frameToAttachTo, "BOTTOMLEFT", 0,
        self._curDbProfile.yoffset)
    else
      texture:SetPoint("TOPLEFT", self._comboPointsTable[i - 1], "TOPRIGHT",
        self._curDbProfile.horizGap, 0)
    end
  end
end

function Combo47:_handleEnableOption()
  self.options.enabledToggle = self._curDbProfile.enabledToggle
  ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, self._curDbProfile.enabledToggle)
end

function Combo47:_handleShownOption()
  self.options.showbar = self._curDbProfile.showbar
  if self._curDbProfile.showbar then
    self:_showAllComboPoints()
    self.options.args.enabledToggle.disabled = true
  else
    self:_hideAllComboPoints()
    self.options.args.enabledToggle.disabled = false
  end
end

---@return table
function Combo47:_getOptionTable()
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = _DECORATIVE_NAME,
      get = function(infoTable)
        return self:_getOption(infoTable)
      end,
      set = function(infoTable, value)
        self:_setOption(infoTable, value)
      end,
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
          disabled = false,
          get = function(infoTable, ...)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, isSelected, ...)
            self:_setOption(infoTable, isSelected)
          end
        },
        showbar = {
          type = "toggle",
          name = "Show Display",
          desc = "Show/Hide the Combo Points Display",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 2,
          get = function(infoTable, ...)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, isSelected, ...)
            self:_setOption(infoTable, isSelected)
          end
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self:_incrementOrderIndex()
        },
        mediumComboPoints = {
          name = "Medium Combo Points",
          desc = "For combo points > 0 and < " .. MAX_COMBO_POINTS .. ". Set to 0 to disable.",
          type = "range",
          min = 0,
          max = MAX_COMBO_POINTS - 1,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        },
        lowComboColor = {
          name = "Low Combo Color",
          desc = "Color for low (below medium setpoint) combo points",
          type = "color",
          get = function(infoTable)
            return self:_getOptionColor(infoTable)
          end,
          set = function(infoTable, r, g, b, a)
            self:_setOptionColor(infoTable, r, g, b, a)
          end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        medComboColor = {
          name = "Medium Combo Color",
          desc = "Color for medium combo points (greater than or equal to " ..
            "Medium Combo Points, but less than MAX)",
          type = "color",
          get = function(infoTable)
            return self:_getOptionColor(infoTable)
          end,
          set = function(infoTable, r, g, b, a)
            self:_setOptionColor(infoTable, r, g, b, a)
          end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        maxComboColor = {
          name = "Max Combo Color",
          desc = "Color for MAX combo points",
          type = "color",
          get = function(infoTable)
            return self:_getOptionColor(infoTable)
          end,
          set = function(infoTable, r, g, b, a)
            self:_setOptionColor(infoTable, r, g, b, a)
          end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        height = {
          name = "Combo Height",
          desc = "Combo display height",
          type = "range",
          min = 2,
          max = 20,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        },
        horizGap = {
          name = "Horizontal Gap",
          desc = "Horizontal Gap between each combo point bar",
          type = "range",
          min = 0,
          max = 30,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        },
        yoffset = {
          name = "Y Offset",
          desc = "Y Offset",
          type = "range",
          min = -30,
          max = 30,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end
