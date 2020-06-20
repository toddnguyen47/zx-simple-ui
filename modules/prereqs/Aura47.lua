local LibStub = LibStub
local CreateFrame, UnitBuff, UnitDebuff = CreateFrame, UnitBuff, UnitDebuff
local GetTime = GetTime
local unpack = unpack

-- Include files
---@type ZxSimpleUI
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local Utils47 = ZxSimpleUI.Utils47
local media = LibStub("LibSharedMedia-3.0")

-- #region
local MODULE_NAME = ""
local DECORATIVE_NAME = ""
---@class Aura47
local Aura47 = {} -- Register Module in PlayerFactory / TargetFactory
Aura47.__index = Aura47
ZxSimpleUI.prereqTables["Aura47"] = Aura47

Aura47.MODULE_NAME = MODULE_NAME
Aura47.DECORATIVE_NAME = DECORATIVE_NAME
Aura47.unit = ""
-- #endregion

function Aura47:__init__()
  self.mainFrame = nil
  -- Ref: https://wow.gamepedia.com/API_UnitDebuff
  self.FILTERS = {
    HELPFUL = "HELPFUL",
    HARMFUL = "HARMFUL",
    PLAYER = "PLAYER",
    RAID = "RAID",
    CANCELABLE = "CANCELABLE",
    NOT_CANCELABLE = "NOT_CANCELABLE"
  }

  self._eventTable = {"UNIT_AURA"}
  self._defaults = {
    profile = {
      enabledToggle = true,
      texture = "GrayVertGradient",
      height = 30,
      yoffset = 2,
      font = "Lato Bold",
      fontsize = 14,
      fontcolor = {1.0, 1.0, 1.0},
      outline = true,
      thickoutline = false,
      monochrome = false,
      framePool = "PlayerName47", -- Can be changed with setUnit()
      buffsPerRow = 8
    }
  }
  self._frameToAnchorTo = nil
  self._MAX_BUFF_INDEX = 40
  self._buffFilters = {}
  self._auraFrameList = {}
  self._casterSource = ""
  self._frameDisplayList = {}
end

---@return Aura47
function Aura47:new()
  ---@type Aura47
  local newInstance = setmetatable({}, self)
  newInstance:__init__()
  return newInstance
end

---@param self Aura47
---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function Aura47.OnInitialize(self)
  self.db = ZxSimpleUI.db:RegisterNamespace(self.MODULE_NAME, self._defaults)
  self._curDbProfile = self.db.profile

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(self.MODULE_NAME))
end

---@param self Aura47
---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function Aura47.OnEnable(self)
  if self.mainFrame == nil then self:createBar() end
  self:_registerEvents()
  self:_setOnEventHandlers()
  self.mainFrame:Show()
end

---@param self Aura47
---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function Aura47.OnDisable(self)
  if self.mainFrame == nil then self:createBar() end
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:Hide()
end

function Aura47:createBar()
  self._frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self._curDbProfile.framePool)

  self.mainFrame = CreateFrame("Frame", nil, self._frameToAnchorTo)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = self._frameToAnchorTo
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)

  self:_createAuraFrames()

  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function Aura47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self:_refreshBarFrame() end
end

function Aura47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(self.MODULE_NAME, self._curDbProfile.enabledToggle)
end

-- ####################################
-- # GETTERS/SETTERS FUNCTIONS
-- ####################################
---@param unit string
function Aura47:setUnit(unit)
  self.unit = unit
  if string.lower(self.unit) == "target" then
    self._curDbProfile.framePool = "TargetName47"
  else
    self._curDbProfile.framePool = "PlayerName47"
  end
end

---@param unit string
function Aura47:setCasterSource(unit) self._casterSource = unit end

---@param filterString string
function Aura47:addFilter(filterString)
  if self.FILTERS[filterString] == nil then
    error(string.format("'%s' is not a proper filter!", filterString))
  end

  if self._buffFilters[filterString] == nil then
    self._buffFilters[filterString] = filterString
  end
end

function Aura47.handleOnEvent(self, curFrame, event, arg1, arg2, ...)
  if string.upper(event) == "UNIT_AURA" then self:handleUnitAura(arg1) end
end

---@param unitTarget string
---Ref: https://wow.gamepedia.com/API_UnitDebuff
function Aura47:handleUnitAura(unitTarget)
  if string.lower(unitTarget) == self.unit then
    local mainFrameHeight = self.mainFrame:GetHeight()
    self._frameDisplayList = {}

    for i = 1, self._MAX_BUFF_INDEX do
      local filterString = self:_getFilterString()
      local name, rank, icon, count, dispelType, duration, expireTime, casterSource,
            isStealable = UnitDebuff(self.unit, i, filterString)
      local auraFrame = self._auraFrameList[i]
      local isNameNil = name == nil
      local isSameCaster = self._casterSource == "" or self._casterSource == casterSource

      if not isNameNil and isSameCaster then
        self:_handleAuraFound(auraFrame, icon, mainFrameHeight)
        self:_handleAuraFrameOnUpdate(auraFrame, duration, expireTime)
        table.insert(self._frameDisplayList, auraFrame)
      else
        self:_handleAuraNameNotFound(auraFrame)
        auraFrame:Hide()
      end
    end
    self:_showFrameDisplayList()
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
function Aura47:_refreshBarFrame()
  self._frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self._curDbProfile.framePool)

  self.mainFrame:SetWidth(self._frameToAnchorTo:GetWidth())
  self.mainFrame:SetHeight(self._curDbProfile.height)
  self.mainFrame:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
  self.mainFrame:SetPoint("BOTTOMLEFT", self._frameToAnchorTo, "TOPLEFT", 0,
    self._curDbProfile.yoffset)
end

function Aura47:_registerEvents()
  for _, event in ipairs(self._eventTable) do self.mainFrame:RegisterEvent(event) end
end

function Aura47:_setOnEventHandlers()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, arg1, arg2, ...)
    self:handleOnEvent(curFrame, event, arg1, arg2, ...)
  end)
end

---@param auraFrame table
function Aura47:_handleAuraNameNotFound(auraFrame)
  local auraTexture = auraFrame.texture
  auraTexture:SetTexture(nil)
  auraFrame:ClearAllPoints()
end

---@param auraFrame table
---@param icon string
---@param mainFrameHeight integer
function Aura47:_handleAuraFound(auraFrame, icon, mainFrameHeight)
  auraFrame:SetWidth(mainFrameHeight)
  auraFrame:SetHeight(mainFrameHeight)
  auraFrame.texture:SetTexture(icon)
  auraFrame:SetAlpha(1.0)
  auraFrame:ClearAllPoints()
end

---@param auraFrame table
function Aura47:_handleAuraFrameOnUpdate(auraFrame, duration, expireTime)
  ---@param remaining integer
  local function setUpdateTime(remaining)
    local updateTimeSeconds = 0.1
    if remaining > 60 then
      updateTimeSeconds = 5.0
    elseif remaining > 20 then
      updateTimeSeconds = 1.0
    end
    return updateTimeSeconds
  end

  local curTime = GetTime()
  local remaining = expireTime - curTime
  local updateTimeSeconds = 0.1
  local currentElapsedTime = 0

  auraFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    currentElapsedTime = currentElapsedTime + elapsed
    if currentElapsedTime > updateTimeSeconds then
      currentElapsedTime = 0
      curTime = GetTime()
      remaining = expireTime - curTime
      updateTimeSeconds = setUpdateTime(remaining)
      if remaining < 2 and remaining > 0 then
        auraFrame:SetAlpha(0.4)
      elseif remaining <= 0 then
        auraFrame:SetScript("OnUpdate", nil)
      end
    end
  end)
end

function Aura47:_showFrameDisplayList()
  for index, auraFrame in ipairs(self._frameDisplayList) do
    self:_setPointAuraFrame(index)
    auraFrame:Show()
  end
end

---@param index integer
function Aura47:_setPointAuraFrame(index)
  local auraFrame = self._frameDisplayList[index]
  if index == 1 then
    auraFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 0, 0)
  else
    local tempMod = index % self._curDbProfile.buffsPerRow
    if tempMod == 1 then
      -- Put it above the current left-most aura
      local indexBelow = index - self._curDbProfile.buffsPerRow
      auraFrame:SetPoint("BOTTOMLEFT", self._frameDisplayList[indexBelow], "TOPLEFT", 0, 0)
    else
      auraFrame:SetPoint("TOPLEFT", self._frameDisplayList[index - 1], "TOPRIGHT", 2, 0)
    end
  end
end

---@return string
function Aura47:_getFilterString()
  local filterString = ""
  for _, filter in pairs(self._buffFilters) do filterString = filterString .. filter .. "|" end
  -- Remove last pipe
  filterString = string.sub(filterString, 1, string.len(filterString) - 1)
  return filterString
end

function Aura47:_createAuraFrames()
  for i = 1, self._MAX_BUFF_INDEX do
    local auraFrame = CreateFrame("Frame", nil, self.mainFrame)
    auraFrame.lastUpdatedTime = 0
    auraFrame.parent = self.mainFrame
    auraFrame:SetFrameLevel(self.mainFrame:GetFrameLevel() + 1)

    auraFrame.texture = auraFrame:CreateTexture(nil, "OVERLAY")
    auraFrame.texture:SetAllPoints(auraFrame)

    auraFrame:Hide()
    self._auraFrameList[i] = auraFrame
  end
end

---@return string
function Aura47:_getFontFlags()
  local s = ""
  if self._curDbProfile.outline then s = s .. "OUTLINE, " end
  if self._curDbProfile.thickoutline then s = s .. "THICKOUTLINE, " end
  if self._curDbProfile.monochrome then s = s .. "MONOCHROME, " end
  if s ~= "" then s = string.sub(s, 0, (string.len(s) - 2)) end
  return s
end
