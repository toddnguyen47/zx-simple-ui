--- upvalues to prevent warnings
local LibStub = LibStub
local GetRuneType, GetRuneCooldown, GetTime = GetRuneType, GetRuneCooldown, GetTime
local CreateFrame, UnitClass = CreateFrame, UnitClass

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Animations47 = ZxSimpleUI.Animations47
local media = LibStub("LibSharedMedia-3.0")

-- #region
local Utils47 = ZxSimpleUI.Utils47

local MODULE_NAME = "Runes47"
local DECORATIVE_NAME = "Runes Display"
local Runes47 = ZxSimpleUI:NewModule(MODULE_NAME)

Runes47.MODULE_NAME = MODULE_NAME
Runes47.DECORATIVE_NAME = DECORATIVE_NAME
Runes47.bars = nil
Runes47.unit = "player"
-- #endregion

function Runes47:__init__()
  self.PLAYER_ENGLISH_CLASS = select(2, UnitClass("player"))
  self._eventTable = {"RUNE_POWER_UPDATE", "RUNE_TYPE_UPDATE"}
  self._defaults = {
    profile = {
      enabledToggle = Runes47.PLAYER_ENGLISH_CLASS == "DEATHKNIGHT",
      texture = "GrayVertGradient",
      height = 6,
      horizGap = 2,
      yoffset = 0,
      bloodColor = {1.0, 0.0, 0.4, 1.0},
      unholyChromaticColor = {0.0, 1.0, 0.4, 1.0},
      frostColor = {0.0, 0.4, 1.0, 1.0},
      deathColor = {0.7, 0.5, 1.0, 1.0},
      runeCooldownAlpha = 0.3,
      framePool = "PlayerPower47"
    }
  }

  -- Boring declarations
  self.mainFrame = nil
  self.MAX_RUNE_NUMBER = 6
  ---On Blizzard's display, Frost (3 & 4) and Unholy (5 & 6) are switched.
  self.RUNE_MAP = {[1] = 1, [2] = 2, [3] = 5, [4] = 6, [5] = 3, [6] = 4}
  self.RUNE_TYPE_TABLE = {
    [1] = "BLOOD",
    [2] = "UNHOLY_CHROMATIC",
    [3] = "FROST",
    [4] = "DEATH"
  }
  self._frameToAnchorTo = nil
  self._runeColors = {}
  self._runeBarList = {}
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function Runes47:OnInitialize()
  self:__init__()
  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._defaults)
  self._curDbProfile = self.db.profile

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function Runes47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_registerAllEvents()
  self:_enableAllScriptHandlers()
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function Runes47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_unregisterAllEvents()
  self:_disableAllScriptHandlers()
  self.mainFrame:Hide()
end

function Runes47:createBar()
  self._frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self._curDbProfile.framePool)

  self.mainFrame = CreateFrame("Frame", nil, self._frameToAnchorTo)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = self._frameToAnchorTo
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)

  self.mainFrame.bgTexture = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgTexture:SetTexture(0, 0, 0, 0.5)
  self.mainFrame.bgTexture:SetAllPoints(self.mainFrame)

  self:_createRuneFrames()
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function Runes47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self:_refreshAll() end
end

function Runes47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(self.MODULE_NAME, self._curDbProfile.enabledToggle)
end

function Runes47:handleShownOption()
  self:_refreshAll()
  self.mainFrame:Show()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Runes47:_refreshAll()
  self:_refreshBarFrame()
  self:_refreshRuneColors()
  self:_refreshRuneFrames()
end

function Runes47:_refreshBarFrame()
  self._frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self._curDbProfile.framePool)

  self.mainFrame:SetWidth(self._frameToAnchorTo:GetWidth())
  self.mainFrame:SetHeight(self._curDbProfile.height)
  self.mainFrame:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
  self.mainFrame:SetPoint("TOPLEFT", self._frameToAnchorTo, "BOTTOMLEFT", 0,
    self._curDbProfile.yoffset)
end

function Runes47:_refreshRuneColors()
  self._runeColors = {
    [self.RUNE_TYPE_TABLE[1]] = self._curDbProfile.bloodColor,
    [self.RUNE_TYPE_TABLE[2]] = self._curDbProfile.unholyChromaticColor,
    [self.RUNE_TYPE_TABLE[3]] = self._curDbProfile.frostColor,
    [self.RUNE_TYPE_TABLE[4]] = self._curDbProfile.deathColor
  }
end

function Runes47:_refreshRuneFrames()
  local totalNumberOfGaps = self._curDbProfile.horizGap * (self.MAX_RUNE_NUMBER - 1)
  local runeWidth = (self._frameToAnchorTo:GetWidth() - totalNumberOfGaps) /
                      self.MAX_RUNE_NUMBER

  -- Important! Do a regular for loop so we can use self.RUNE_MAP
  for id = 1, self.MAX_RUNE_NUMBER do
    local mappedId = self:_getMappedId(id)
    local runeStatusBar = self._runeBarList[mappedId]
    runeStatusBar.runeType = self.RUNE_TYPE_TABLE[GetRuneType(mappedId)]
    runeStatusBar:SetWidth(runeWidth)
    runeStatusBar:SetHeight(self._curDbProfile.height)
    runeStatusBar:SetStatusBarTexture(media:Fetch("statusbar", self._curDbProfile.texture),
      "BORDER")
    runeStatusBar:GetStatusBarTexture():SetHorizTile(false)
    self:_setRuneColor(runeStatusBar)
    runeStatusBar:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details

    if id == 1 then
      runeStatusBar:SetPoint("TOPLEFT", self._frameToAnchorTo, "BOTTOMLEFT", 0,
        self._curDbProfile.yoffset)
    else
      local leftId = self:_getMappedId(id - 1)
      runeStatusBar:SetPoint("TOPLEFT", self._runeBarList[leftId], "TOPRIGHT",
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
    self._runeBarList[id] = runeStatusBar
  end
end

---@param runeStatusBar table
function Runes47:_setRuneColor(runeStatusBar)
  local curColor = self._runeColors[runeStatusBar.runeType]
  runeStatusBar:SetStatusBarColor(unpack(curColor))
end

function Runes47:_registerAllEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:RegisterEvent(event) end
end

function Runes47:_unregisterAllEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:UnregisterEvent(event) end
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

  local runeStatusBar = self._runeBarList[id]
  local startTime, duration, isRuneReady = GetRuneCooldown(id)
  if isRuneReady then
    self:_handleRuneCooldownComplete(runeStatusBar, id)
  else
    runeStatusBar.startTime = startTime
    runeStatusBar.duration = duration
    local currentTime = GetTime()

    runeStatusBar:SetMinMaxValues(0, runeStatusBar.duration)
    runeStatusBar:SetValue(currentTime - startTime)
    runeStatusBar:SetAlpha(self._curDbProfile.runeCooldownAlpha)
    runeStatusBar:SetScript("OnUpdate", function(curFrame, elapsedTime)
      self:_monitorCurrentRune(curFrame, elapsedTime, id)
    end)
  end
end

---@param runeStatusBar table
---@param elapsedTime integer
---@param id integer
function Runes47:_monitorCurrentRune(runeStatusBar, elapsedTime, id)
  local curTime = GetTime() - runeStatusBar.startTime
  runeStatusBar:SetValue(curTime)

  if (curTime >= runeStatusBar.duration) then
    self:_handleRuneCooldownComplete(runeStatusBar, id)
  end
end

---@param runeStatusBar table
---@param id integer
function Runes47:_handleRuneCooldownComplete(runeStatusBar, id)
  runeStatusBar:SetMinMaxValues(0, 10)
  runeStatusBar:SetValue(10)
  runeStatusBar:SetAlpha(1.0)
  runeStatusBar:SetScript("OnUpdate", nil)

  local animDurationSec = 0.5
  Animations47:animateHeight(runeStatusBar, self._curDbProfile.height, animDurationSec)
end

---@param id integer
---@return integer
---Use RUNE_MAP to get the actual rune that's currently being displayed.
---Blizzard displays runes as
---`[1 2 5 6 3 4]`
function Runes47:_getMappedId(id) return self.RUNE_MAP[id] end
