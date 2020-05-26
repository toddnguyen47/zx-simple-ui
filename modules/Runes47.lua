--- Upvalues
local LibStub = LibStub
local GetRuneType = GetRuneType

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "Runes47"
local _DECORATIVE_NAME = "Runes Display"
local Runes47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

local CreateFrame = CreateFrame

Runes47.MODULE_NAME = _MODULE_NAME
Runes47.EVENT_TABLE = {"RUNE_POWER_UPDATE", "RUNE_TYPE_UPDATE"}
Runes47.unit = "player"
Runes47.PLAYER_ENGLISH_CLASS = select(2, UnitClass("player"))
Runes47.MAX_RUNE_NUMBER = 6

---On Blizzard's display, Frost (3 & 4) and Unholy (5 & 6) are switched.
local RUNE_MAP = {[1] = 1, [2] = 2, [3] = 5, [4] = 6, [5] = 3, [6] = 4}

local RUNE_TYPE_TABLE = {[1] = "BLOOD", [2] = "UNHOLY_CHROMATIC", [3] = "FROST", [4] = "DEATH"}

local _defaults = {
  profile = {
    showbar = false,
    enabledToggle = Runes47.PLAYER_ENGLISH_CLASS == "DEATHKNIGHT",
    texture = "Blizzard",
    height = 6,
    horizGap = 2,
    yoffset = 0,
    bloodColor = {1.0, 0.0, 0.4, 1.0},
    unholyChromaticColor = {0.0, 1.0, 0.4, 1.0},
    frostColor = {0.0, 0.4, 1.0, 1.0},
    deathColor = {0.7, 0.5, 1.0, 1.0}
  }
}

function Runes47:OnInitialize()
  self:__init__()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  -- Always set the showbar option to false on initialize
  self._curDbProfile.showbar = _defaults.profile.showbar

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getOptionTable(), _DECORATIVE_NAME)
end

function Runes47:OnEnable() self:handleOnEnable() end

function Runes47:OnDisable() self:handleOnDisable() end

function Runes47:__init__()
  self.options = {}
  self.mainFrame = nil

  self._frameToAttachTo = nil
  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX
  self._runeColors = {}
  self._runeBarList = {}
end

function Runes47:createBar(frameToAttachTo)
  assert(frameToAttachTo ~= nil)
  self._frameToAttachTo = frameToAttachTo

  self.mainFrame = CreateFrame("Frame", nil, self._frameToAttachTo)
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)

  self.mainFrame.bgTexture = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgTexture:SetTexture(0, 0, 0, 0.5)
  self.mainFrame.bgTexture:SetAllPoints()

  self:_createRuneFrames()

  self.mainFrame:Show()
  return self.mainFrame
end

function Runes47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then
    self:_refreshBarFrame()
    self:_refreshRuneColors()
    self:_refreshRuneFrames()
  end
end

function Runes47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, self._curDbProfile.enabledToggle)
end

function Runes47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:_registerAllEvents()
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function Runes47:handleOnDisable()
  if self.mainFrame ~= nil then
    self:_unregisterAllEvents()
    self.mainFrame:Hide()
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Runes47:_refreshBarFrame()
  self.mainFrame:SetWidth(self._frameToAttachTo:GetWidth())
  self.mainFrame:SetHeight(self._curDbProfile.height)
  self.mainFrame:SetPoint("TOPLEFT", self._frameToAttachTo, "BOTTOMLEFT", 0,
    self._curDbProfile.yoffset)
end

function Runes47:_refreshRuneColors()
  self._runeColors = {
    [RUNE_TYPE_TABLE[1]] = self._curDbProfile.bloodColor,
    [RUNE_TYPE_TABLE[2]] = self._curDbProfile.unholyChromaticColor,
    [RUNE_TYPE_TABLE[3]] = self._curDbProfile.frostColor,
    [RUNE_TYPE_TABLE[4]] = self._curDbProfile.deathColor
  }
end

function Runes47:_refreshRuneFrames()
  local totalNumberOfGaps = self._curDbProfile.horizGap * (self.MAX_RUNE_NUMBER - 1)
  local runeWidth = (self._frameToAttachTo:GetWidth() - totalNumberOfGaps) /
                      self.MAX_RUNE_NUMBER

  -- This `id` has already been mapped in _createRuneFrames()
  for id, runeStatusBar in pairs(self._runeBarList) do
    runeStatusBar:SetWidth(runeWidth)
    runeStatusBar:SetHeight(self._curDbProfile.height)
    runeStatusBar:SetStatusBarTexture(media:Fetch("statusbar", self._curDbProfile.texture),
      "BORDER")
    self:_setRuneColor(runeStatusBar)
    if id == 1 then
      runeStatusBar:SetPoint("TOPLEFT", self._frameToAttachTo, "BOTTOMLEFT", 0,
        self._curDbProfile.yoffset)
    else
      runeStatusBar:SetPoint("TOPLEFT", self._runeBarList[id - 1], "TOPRIGHT",
        self._curDbProfile.horizGap, 0)
    end
  end
end

function Runes47:_registerAllEvents()
  for _, event in pairs(self.EVENT_TABLE) do self.mainFrame:RegisterEvent(event) end
end

function Runes47:_unregisterAllEvents()
  for _, event in pairs(self.EVENT_TABLE) do self.mainFrame:UnregisterEvent(event) end
end

function Runes47:_createRuneFrames()
  for id = 1, self.MAX_RUNE_NUMBER do
    local runeStatusBar = CreateFrame("StatusBar", nil, self.mainFrame)
    runeStatusBar.parent = self.mainFrame
    runeStatusBar:SetFrameLevel(self.mainFrame:GetFrameLevel() + 1)
    runeStatusBar:SetMinMaxValues(0, 1)
    runeStatusBar.runeType = RUNE_TYPE_TABLE[GetRuneType(id)]

    runeStatusBar:Show()
    self._runeBarList[RUNE_MAP[id]] = runeStatusBar
  end
end

---@param runeStatusBar table
function Runes47:_setRuneColor(runeStatusBar)
  local curColor = self._runeColors[runeStatusBar.runeType]
  runeStatusBar:SetStatusBarColor(unpack(curColor))
end

-- ####################################
-- # OPTION TABLE FUNCTIONS
-- ####################################

---@param info table
---Ref: https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function Runes47:_getOption(info)
  local keyLeafNode = info[#info]
  return self._curDbProfile[keyLeafNode]
end

---@param info table
---@param value any
---Ref: https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function Runes47:_setOption(info, value)
  local keyLeafNode = info[#info]
  self._curDbProfile[keyLeafNode] = value
  self:refreshConfig()
end

---@param info table
function Runes47:_getOptionColor(info) return unpack(self:_getOption(info)) end

---@param info table
function Runes47:_setOptionColor(info, r, g, b, a) self:_setOption(info, {r, g, b, a}) end

function Runes47:_getShownOption(info) return self:_getOption(info) end

---@param info table
---@param value boolean
function Runes47:_setShownOption(info, value) self:_setOption(info, value) end

function Runes47:_incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end

---@return table
function Runes47:_getOptionTable()
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
          desc = "Show/Hide the Runes Display",
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
          name = "Rune Height",
          desc = "Rune display height",
          type = "range",
          min = 2,
          max = 20,
          step = 1,
          order = self:_incrementOrderIndex()
        },
        horizGap = {
          name = "Horizontal Gap",
          desc = "Horizontal Gap between each rune",
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
        bloodColor = {
          name = "Blood Color",
          desc = "Color for Blood Runes",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        unholyChromaticColor = {
          name = "Unholy Color",
          desc = "Color for Unholy (Chromatic) Runes",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        frostColor = {
          name = "Frost Color",
          desc = "Color for Frost Runes",
          type = "color",
          get = function(info) return self:_getOptionColor(info) end,
          set = function(info, r, g, b, a) self:_setOptionColor(info, r, g, b, a) end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        deathColor = {
          name = "Death Color",
          desc = "Color for Death Runes",
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
