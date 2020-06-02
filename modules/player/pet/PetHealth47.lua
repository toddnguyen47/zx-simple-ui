--- upvalues to prevent warnings
local LibStub = LibStub
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitName = UnitName

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local _MODULE_NAME = "PetHealth47"
local _DECORATIVE_NAME = "Pet Health"
local PetHealth47 = ZxSimpleUI:NewModule(_MODULE_NAME)

PetHealth47.MODULE_NAME = _MODULE_NAME
PetHealth47.DECORATIVE_NAME = _DECORATIVE_NAME
PetHealth47.bars = nil
PetHealth47.unit = "pet"

local _defaults = {
  profile = {
    width = 150,
    height = 20,
    xoffset = 0,
    yoffset = -2,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0},
    border = "None",
    selfCurrentPoint = "TOPRIGHT",
    relativePoint = "BOTTOMRIGHT"
  }
}

function PetHealth47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevHealth = UnitHealthMax(self.unit)
  self.mainFrame = nil

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, _defaults.profile)
end

function PetHealth47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile

  self.bars = BarTemplate:new(self.db)

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
end

function PetHealth47:OnEnable() self:handleOnEnable() end

function PetHealth47:OnDisable() self:handleOnDisable() end

function PetHealth47:refreshConfig() if self:IsEnabled() then self.bars:refreshConfig() end end

---@param frameToAnchorTo table
---@return table
function PetHealth47:createBar(frameToAnchorTo)
  assert(frameToAnchorTo ~= nil)
  local curUnitHealth = UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)

  self.bars.frameToAnchorTo = frameToAnchorTo
  self.mainFrame = self.bars:createBar(percentage)
  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)

  self.mainFrame:Show()
  return self.mainFrame
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function PetHealth47:handleEnableToggle() end

function PetHealth47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function PetHealth47:handleOnDisable() if self.mainFrame ~= nil then self.mainFrame:Hide() end end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param curFrame table
---@param elapsed number
function PetHealth47:_onUpdateHandler(curFrame, elapsed)
  if not self.mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitHealth = UnitHealth(self.unit)
    if (curUnitHealth ~= self._prevHealth) then
      self:_handleUnitHealthEvent(curUnitHealth)
      self._prevHealth = curUnitHealth
      self._timeSinceLastUpdate = 0
    end
  end
end

function PetHealth47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
  self.bars:setStatusBarValue(healthPercent)
end

function PetHealth47:_registerEvents() self.mainFrame:RegisterEvent("UNIT_HEALTH") end

function PetHealth47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(curFrame, ...)
    if self:IsEnabled() then
      self:_enableAllScriptHandlers()
    else
      self.mainFrame:Hide()
    end
  end)

  self.mainFrame:SetScript("OnHide",
    function(curFrame, ...) self:_disableAllScriptHandlers() end)
end

function PetHealth47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
end

function PetHealth47:_disableAllScriptHandlers() self.mainFrame:SetScript("OnUpdate", nil) end
