local media = LibStub("LibSharedMedia-3.0")
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate

local _MODULE_NAME = "PlayerHealth47"
local _DECORATIVE_NAME = "Player Health"
local PlayerHealth47 = ZxSimpleUI:NewModule(_MODULE_NAME)

--- upvalues to prevent warnings
local LibStub = LibStub
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitName = UnitName

PlayerHealth47.MODULE_NAME = _MODULE_NAME
PlayerHealth47.bars = nil
PlayerHealth47.unit = "player"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 400,
    positiony = 270,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0},
    border = "None"
  }
}

function PlayerHealth47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self.bars:getOptionTable(_DECORATIVE_NAME),
                                   _DECORATIVE_NAME)

  self:__init__()
end

function PlayerHealth47:OnEnable()
end

function PlayerHealth47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevHealth = UnitHealthMax(self.unit)
  self.mainFrame = nil
end

function PlayerHealth47:refreshConfig()
  if self:IsEnabled() then self.bars:refreshConfig() end
end

---@return table
function PlayerHealth47:createBar()
  local curUnitHealth = UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)

  self.mainFrame = self.bars:createBar(percentage)
  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  self.mainFrame:Show()
  return self.mainFrame
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param argsTable table
---@param elapsed number
function PlayerHealth47:_onUpdateHandler(argsTable, elapsed)
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

function PlayerHealth47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
  self.bars:setStatusBarValue(healthPercent)
end

function PlayerHealth47:_registerEvents()
  self.mainFrame:RegisterEvent("UNIT_HEALTH")
end

function PlayerHealth47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(argsTable, ...)
    if self:IsEnabled() then
      self:_enableAllScriptHandlers()
    else
      self.mainFrame:Hide()
    end
  end)

  self.mainFrame:SetScript("OnHide", function(argsTable, ...)
    self:_disableAllScriptHandlers()
  end)
end

function PlayerHealth47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)
end

function PlayerHealth47:_disableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", nil)
end
