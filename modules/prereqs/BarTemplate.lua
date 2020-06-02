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
ZxSimpleUI.BarTemplate = BarTemplate

---@param db table
function BarTemplate:__init__(db)
  assert(db ~= nil)
  self.db = db
  self.mainFrame = nil
  self.frameToAnchorTo = UIParent
  -- Start order index at DEFAULT_ORDER_INDEX so other modules can easily put options in front
  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX
  self._curDbProfile = self.db.profile

  self.defaults = {
    profile = {
      width = 200,
      height = 26,
      positionx = 400,
      positiony = 280,
      fontsize = 14,
      font = "Friz Quadrata TT",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "Blizzard",
      color = {0.0, 1.0, 0.0, 1.0},
      border = "None"
    }
  }

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
  self.mainFrame:SetPoint("BOTTOMLEFT", self.frameToAnchorTo, "BOTTOMLEFT",
    self._curDbProfile.positionx, self._curDbProfile.positiony)

  self:_setMouseClicks()

  self.mainFrame.bgFrame = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgFrame:SetTexture(0, 0, 0, 0.8)
  self.mainFrame.bgFrame:SetAllPoints()

  self.mainFrame.statusBar = CreateFrame("StatusBar", nil, self.mainFrame)
  self.mainFrame.statusBar:ClearAllPoints()
  self.mainFrame.statusBar:SetPoint("CENTER", self.mainFrame, "CENTER")
  local texture = media:Fetch("statusbar", self._curDbProfile.texture)
  self.mainFrame.statusBar:SetStatusBarTexture(texture, "BORDER")
  self.mainFrame.statusBar:GetStatusBarTexture():SetHorizTile(false)
  self.mainFrame.statusBar:GetStatusBarTexture():SetVertTile(false)
  self.mainFrame.statusBar:SetStatusBarColor(unpack(self._curDbProfile.color))
  self.mainFrame.statusBar:SetMinMaxValues(0, 1)
  self.mainFrame.statusBar:SetValue(percentValue)
  self:_setFrameWidthHeight()

  self.mainFrame.mainText = self.mainFrame.statusBar:CreateFontString(nil, "BORDER")
  self.mainFrame.mainText:SetFont(media:Fetch("font", self._curDbProfile.font),
    self._curDbProfile.fontsize, "OUTLINE")
  self.mainFrame.mainText:SetTextColor(unpack(self._curDbProfile.fontcolor))
  self.mainFrame.mainText:SetPoint("CENTER", self.mainFrame.statusBar, "CENTER", 0, 0)
  self.mainFrame.mainText:SetText(string.format("%.1f%%", percentValue * 100.0))

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
  self.mainFrame.mainText:SetText(string.format("%.1f%%", percentValue * 100.0))
  self.mainFrame.statusBar:SetValue(percentValue)
end

---@param strInput string
function BarTemplate:setTextOnly(strInput) self.mainFrame.mainText:SetText(strInput) end

function BarTemplate:handlePositionXCenter()
  local width = self._curDbProfile.width

  local centerXPos = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2 - width / 2)
  self._curDbProfile.positionx = centerXPos
  self:refreshConfig()
end

function BarTemplate:handlePositionYCenter()
  local height = self._curDbProfile.height

  local centerYPos = math.floor(ZxSimpleUI.SCREEN_HEIGHT / 2 - height / 2)
  self._curDbProfile.positiony = centerYPos
  self:refreshConfig()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function BarTemplate:_setFrameWidthHeight()
  self.mainFrame:SetWidth(self._curDbProfile.width)
  self.mainFrame:SetHeight(self._curDbProfile.height)
  self.mainFrame.bgFrame:SetWidth(self.mainFrame:GetWidth())
  self.mainFrame.bgFrame:SetHeight(self.mainFrame:GetHeight())
  self.mainFrame.statusBar:SetWidth(self.mainFrame:GetWidth())
  self.mainFrame.statusBar:SetHeight(self.mainFrame:GetHeight())
end

function BarTemplate:_refreshBarFrame()
  self.mainFrame:SetPoint("BOTTOMLEFT", self.frameToAnchorTo, "BOTTOMLEFT",
    self._curDbProfile.positionx, self._curDbProfile.positiony)
  self.mainFrame:SetBackdrop(self.frameBackdropTable)

  self.frameBackdropTable.edgeFile = media:Fetch("border", self._curDbProfile.border)

  self.mainFrame.mainText:SetFont(media:Fetch("font", self._curDbProfile.font),
    self._curDbProfile.fontsize, "OUTLINE")
  self.mainFrame.mainText:SetTextColor(unpack(self._curDbProfile.fontcolor))
end

function BarTemplate:_refreshStatusBar()
  local texture = media:Fetch("statusbar", self._curDbProfile.texture)
  self.mainFrame.statusBar:SetStatusBarTexture(texture, "BORDER")
  self.mainFrame.statusBar:SetStatusBarColor(unpack(self._curDbProfile.color))
end

function BarTemplate:_setMouseClicks()
  self.mainFrame:RegisterForClicks("AnyUp")
  -- Set left click
  self.mainFrame:SetAttribute("*type1", "target")
  -- Set right click
  self.mainFrame:SetAttribute("*type2", "menu")
end
