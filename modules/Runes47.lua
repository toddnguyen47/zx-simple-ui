--- Upvalues
local LibStub = LibStub
local GetRuneType, GetRuneCooldown, GetTime = GetRuneType, GetRuneCooldown, GetTime
local CreateFrame = CreateFrame

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local _MODULE_NAME = "Runes47"
local _DECORATIVE_NAME = "Runes Display"
local Runes47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

Runes47.MODULE_NAME = _MODULE_NAME
Runes47.DECORATIVE_NAME = _DECORATIVE_NAME
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
    deathColor = {0.7, 0.5, 1.0, 1.0},
    runeCooldownAlpha = 0.3
  }
}

function Runes47:OnInitialize()
  self:__init__()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  -- Always set the showbar option to false on initialize
  self._curDbProfile.showbar = _defaults.profile.showbar

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
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
  return self.mainFrame
end

function Runes47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self:_refreshAll() end
end

function Runes47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, self._curDbProfile.enabledToggle)
end

function Runes47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:_registerAllEvents()
    self:_enableAllScriptHandlers()
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function Runes47:handleOnDisable()
  if self.mainFrame ~= nil then
    self:_unregisterAllEvents()
    self:_disableAllScriptHandlers()
    self.mainFrame:Hide()
  end
end

function Runes47:handleShownOption()
  self:_refreshAll()
  self.mainFrame:Show()
end

function Runes47:handleShownHideOption() self.mainFrame:Hide() end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Runes47:_refreshAll()
  self:_refreshBarFrame()
  self:_refreshRuneColors()
  self:_refreshRuneFrames()
end

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

  -- Important! Do a regular for loop so we can use RUNE_MAP
  for id = 1, self.MAX_RUNE_NUMBER do
    local runeStatusBar = self._runeBarList[RUNE_MAP[id]]
    runeStatusBar:SetWidth(runeWidth)
    runeStatusBar:SetHeight(self._curDbProfile.height)
    runeStatusBar:SetStatusBarTexture(media:Fetch("statusbar", self._curDbProfile.texture),
      "BORDER")
    runeStatusBar:GetStatusBarTexture():SetHorizTile(false)
    self:_setRuneColor(runeStatusBar)

    if id == 1 then
      runeStatusBar:SetPoint("TOPLEFT", self._frameToAttachTo, "BOTTOMLEFT", 0,
        self._curDbProfile.yoffset)
    else
      runeStatusBar:SetPoint("TOPLEFT", self._runeBarList[RUNE_MAP[id - 1]], "TOPRIGHT",
        self._curDbProfile.horizGap, 0)
    end
  end
end

function Runes47:_createRuneFrames()
  for id = 1, self.MAX_RUNE_NUMBER do
    local runeStatusBar = CreateFrame("StatusBar", nil, self.mainFrame)
    runeStatusBar.parent = self.mainFrame
    runeStatusBar:SetFrameLevel(self.mainFrame:GetFrameLevel() + 1)
    runeStatusBar:SetMinMaxValues(0, 10)
    runeStatusBar.runeType = RUNE_TYPE_TABLE[GetRuneType(id)]
    self._runeBarList[id] = runeStatusBar
  end
end

---@param runeStatusBar table
function Runes47:_setRuneColor(runeStatusBar)
  local curColor = self._runeColors[runeStatusBar.runeType]
  runeStatusBar:SetStatusBarColor(unpack(curColor))
end

function Runes47:_registerAllEvents()
  for _, event in pairs(self.EVENT_TABLE) do self.mainFrame:RegisterEvent(event) end
end

function Runes47:_unregisterAllEvents()
  for _, event in pairs(self.EVENT_TABLE) do self.mainFrame:UnregisterEvent(event) end
end

function Runes47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, id, usable, ...)
    self:_onEventHandler(curFrame, event, id, usable, ...)
  end)
end

function Runes47:_disableAllScriptHandlers() self.mainFrame:SetScript("OnEvent", nil) end

function Runes47:_onEventHandler(curFrame, event, id, usable, ...)
  if event == "RUNE_TYPE_UPDATE" then
    self:_handleRuneTypeUpdate(curFrame, event, id, usable, ...)
  elseif event == "RUNE_POWER_UPDATE" then
    self:_handleRunePowerUpdate(curFrame, event, id, usable, ...)
  end
end

function Runes47:_handleRuneTypeUpdate(curFrame, event, unit, usable, ...)
  -- WIP: Need to level a death knight to high enough levels to test this out
end

function Runes47:_handleRunePowerUpdate(curFrame, event, id, usable)
  if not id then
    self:_refreshRuneColors()
    return
  elseif not self._runeBarList[id] then
    return
  end

  local runeFrame = self._runeBarList[id]
  local startTime, duration, isRuneReady = GetRuneCooldown(id)
  if isRuneReady then
    self:_handleRuneCooldownComplete(runeFrame)
  else
    runeFrame.startTime = startTime
    runeFrame.duration = duration
    local currentTime = GetTime()

    runeFrame:SetMinMaxValues(0, runeFrame.duration)
    runeFrame:SetValue(currentTime - startTime)
    runeFrame:SetAlpha(self._curDbProfile.runeCooldownAlpha)
    runeFrame:SetScript("OnUpdate", function(curFrame, elapsedTime)
      self:_monitorCurrentRune(curFrame, elapsedTime)
    end)
  end

end

function Runes47:_monitorCurrentRune(runeFrame, elapsedTime)
  local curTime = GetTime() - runeFrame.startTime
  runeFrame:SetValue(curTime)

  if (curTime >= runeFrame.duration) then self:_handleRuneCooldownComplete(runeFrame) end
end

function Runes47:_handleRuneCooldownComplete(runeFrame)
  runeFrame:SetMinMaxValues(0, 10)
  runeFrame:SetValue(10)
  runeFrame:SetAlpha(1.0)
  runeFrame:SetScript("OnUpdate", nil)
end

-- ####################################
-- # OPTION TABLE FUNCTIONS
-- ####################################

