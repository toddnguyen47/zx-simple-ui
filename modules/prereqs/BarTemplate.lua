---References:
---https://wowwiki.fandom.com/wiki/SecureActionButtonTemplate
--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local unpack, next = unpack, next

--- Includes
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")

local BarTemplate = {}
BarTemplate.__index = BarTemplate
ZxSimpleUI.prereqTables["BarTemplate"] = BarTemplate

---@param db table
function BarTemplate:__init__(db)
  assert(db ~= nil)
  self.db = db
  self.mainFrame = nil
  self.frameToAnchorTo = UIParent
  -- Start order index at DEFAULT_ORDER_INDEX so other modules can easily put options in front
  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX

  self.frameBackdropTable = {
    bgFile = "Interface\\DialogFrame\\UI-Tooltip-Background",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  }

  self.options = {}
end

function BarTemplate:new(db)
  local newInstance = setmetatable({}, BarTemplate)
  newInstance:__init__(db)
  return newInstance
end

---@param percentValue number 0 to 1
---@return table
function BarTemplate:createBar(percentValue)
  -- self.mainFrame = CreateFrame("Frame", nil, UIParent)
  self.mainFrame = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate")
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL)
  self.mainFrame:SetBackdrop(self.frameBackdropTable)
  self.mainFrame:SetBackdropColor(1, 0, 0, 1)
  self.mainFrame:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details

  -- self.mainFrame:SetPoint(self.db.profile.selfCurrentPoint, self.frameToAnchorTo,
  --   self.db.profile.relativePoint, self.db.profile.xoffset, self.db.profile.yoffset)
  self.mainFrame:SetPoint(self.db.profile.selfCurrentPoint,
    ZxSimpleUI:getFrameListFrame(self.db.profile.framePool), self.db.profile.relativePoint,
    self.db.profile.xoffset, self.db.profile.yoffset)

  self:_setMouseClicks()

  self.mainFrame.bgFrame = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgFrame:SetTexture(0, 0, 0, 0.8)
  self.mainFrame.bgFrame:SetAllPoints(self.mainFrame)

  self.mainFrame.statusBar = CreateFrame("StatusBar", nil, self.mainFrame)
  self.mainFrame.statusBar:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
  self.mainFrame.statusBar:SetPoint("CENTER", self.mainFrame, "CENTER")
  local texture = media:Fetch("statusbar", self.db.profile.texture)
  self.mainFrame.statusBar:SetStatusBarTexture(texture, "BORDER")
  self.mainFrame.statusBar:GetStatusBarTexture():SetHorizTile(false)
  self.mainFrame.statusBar:GetStatusBarTexture():SetVertTile(false)
  self.mainFrame.statusBar:SetStatusBarColor(unpack(self.db.profile.color))
  self.mainFrame.statusBar:SetMinMaxValues(0, 1)
  self:_setFrameWidthHeight()

  self.mainFrame.mainText = self.mainFrame.statusBar:CreateFontString(nil, "BORDER")
  self.mainFrame.mainText:SetFont(media:Fetch("font", self.db.profile.font),
    self.db.profile.fontsize, "OUTLINE")
  self.mainFrame.mainText:SetTextColor(unpack(self.db.profile.fontcolor))
  self.mainFrame.mainText:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
  self.mainFrame.mainText:SetPoint("CENTER", self.mainFrame.statusBar, "CENTER", 0, 0)

  self:setStatusBarValue(percentValue)

  self.mainFrame:Show()
  return self.mainFrame
end

function BarTemplate:refreshConfig()
  self:_setFrameWidthHeight()
  self:_refreshBarFrame()
  self:_refreshStatusBar()
end

---@param percentValue number from 0.0 to 1.0
function BarTemplate:setStatusBarValue(percentValue)
  -- self.mainFrame.mainText:SetText(string.format("%.1f%%", percentValue * 100.0))
  local val = percentValue * 100.0
  val = val + 0.5
  val = math.floor(val)
  self.mainFrame.mainText:SetText(string.format("%d%%", val))
  self.mainFrame.statusBar:SetValue(percentValue)
end

-- Options
local _optionCurBarTextPercent = "PERCENT"
local _optionCurBarTextValue = "VALUE"
local _optionCurBarTextValuePercent = "VALUEPERCENT"

---@param curValue number current value
---@param maxValue number maxValue
function BarTemplate:setStatusBarValueCurrMax(curValue, maxValue, option)
  local percentValue = 0.0
  if maxValue ~= 0 then
    percentValue = curValue / maxValue
  end
  local val = percentValue * 100.0
  val = val + 0.5
  val = math.floor(val)
  local formattedCurValue = self:_getFormattedNumber(curValue)
  local formattedMaxValue = self:_getFormattedNumber(maxValue)

  local textValue = ""

  local upperCaseOption = string.upper(option)
  if upperCaseOption == _optionCurBarTextPercent then
    textValue = string.format("%d%%", val)
  elseif upperCaseOption == _optionCurBarTextValue then
    textValue = string.format("%s/%s", formattedCurValue, formattedMaxValue)
  elseif upperCaseOption == _optionCurBarTextValuePercent then
    textValue = string.format("%s/%s (%d%%)", formattedCurValue, formattedMaxValue, val)
  end

  self.mainFrame.mainText:SetText(textValue)
  self.mainFrame.statusBar:SetValue(percentValue)
end

---@param strInput string
function BarTemplate:setTextOnly(strInput) self.mainFrame.mainText:SetText(strInput) end

function BarTemplate:handlePositionXCenter()
  local width = self.db.profile.width

  local centerXPos = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2 - width / 2)
  self.db.profile.xoffset = centerXPos
  self:refreshConfig()
end

function BarTemplate:handlePositionYCenter()
  local height = self.db.profile.height

  local centerYPos = math.floor(ZxSimpleUI.SCREEN_HEIGHT / 2 - height / 2)
  self.db.profile.yoffset = centerYPos
  self:refreshConfig()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function BarTemplate:_setFrameWidthHeight()
  self.mainFrame:SetWidth(self.db.profile.width)
  self.mainFrame:SetHeight(self.db.profile.height)
  self.mainFrame.bgFrame:SetWidth(self.mainFrame:GetWidth())
  self.mainFrame.bgFrame:SetHeight(self.mainFrame:GetHeight())
  self.mainFrame.statusBar:SetWidth(self.mainFrame:GetWidth())
  self.mainFrame.statusBar:SetHeight(self.mainFrame:GetHeight())
end

function BarTemplate:_refreshBarFrame()
  self.mainFrame:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
  -- self.mainFrame:SetPoint(self.db.profile.selfCurrentPoint, self.frameToAnchorTo,
  --   self.db.profile.relativePoint, self.db.profile.xoffset, self.db.profile.yoffset)
  self.mainFrame:SetPoint(self.db.profile.selfCurrentPoint,
    ZxSimpleUI:getFrameListFrame(self.db.profile.framePool), self.db.profile.relativePoint,
    self.db.profile.xoffset, self.db.profile.yoffset)
  self.mainFrame:SetBackdrop(self.frameBackdropTable)

  self.frameBackdropTable.edgeFile = media:Fetch("border", self.db.profile.border)

  self.mainFrame.mainText:SetFont(media:Fetch("font", self.db.profile.font),
    self.db.profile.fontsize, "OUTLINE")
  self.mainFrame.mainText:SetTextColor(unpack(self.db.profile.fontcolor))
end

function BarTemplate:_refreshStatusBar()
  local texture = media:Fetch("statusbar", self.db.profile.texture)
  self.mainFrame.statusBar:SetStatusBarTexture(texture, "BORDER")
  self.mainFrame.statusBar:SetStatusBarColor(unpack(self.db.profile.color))
end

function BarTemplate:_setMouseClicks()
  self.mainFrame:RegisterForClicks("AnyUp")
  -- Set left click
  self.mainFrame:SetAttribute("*type1", "target")
  -- Set right click
  self.mainFrame:SetAttribute("*type2", "openRightClickMenu")
end

local _ONE_BILLION = 10^9
local _ONE_MILLION = 10^6
local _ONE_THOUSAND = 10^3

---@return string
function BarTemplate:_getFormattedNumber(number)
  local formatString = "%.1f"
  local strVal = string.format(formatString, number)
  if number >= _ONE_BILLION then
    local val = self:_roundToOneDigit(number / _ONE_BILLION)
    strVal = string.format(formatString .. "B", val)
  elseif number >= _ONE_MILLION then
    local val = self:_roundToOneDigit(number / _ONE_MILLION)
    strVal = string.format(formatString .. "M", val)
  elseif number >= _ONE_THOUSAND then
    local val = self:_roundToOneDigit(number / _ONE_THOUSAND)
    strVal = string.format(formatString .. "K", val)
  else
    strVal = string.format("%d", number)
  end
  return strVal
end

function BarTemplate:_roundToOneDigit(number)
  number = number * 10.0 + 0.5
  number = math.floor(number)
  return number / 10.0
end
