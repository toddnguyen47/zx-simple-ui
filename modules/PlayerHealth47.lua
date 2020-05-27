--- upvalues to prevent warnings
local LibStub = LibStub
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitName = UnitName

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplate = ZxSimpleUI.BarTemplate
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local _MODULE_NAME = "PlayerHealth47"
local _DECORATIVE_NAME = "Player Health"
local PlayerHealth47 = ZxSimpleUI:NewModule(_MODULE_NAME)

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
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile

  self.bars = BarTemplate:new(self.db)
  self.bars.defaults = _defaults
  local barTemplateOptions = BarTemplateOptions:new(self)

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME,
    barTemplateOptions:getOptionTable(_DECORATIVE_NAME), _DECORATIVE_NAME)
end

function PlayerHealth47:OnEnable() self:handleOnEnable() end

function PlayerHealth47:OnDisable() self:handleOnDisable() end

function PlayerHealth47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevHealth = UnitHealthMax(self.unit)
  self.mainFrame = nil
end

function PlayerHealth47:refreshConfig() if self:IsEnabled() then self.bars:refreshConfig() end end

---@return table
function PlayerHealth47:createBar()
  local curUnitHealth = UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)

  self.mainFrame = self.bars:createBar(percentage)
  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)

  self.mainFrame:Show()
  return self.mainFrame
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function PlayerHealth47:handleEnableToggle() end

function PlayerHealth47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function PlayerHealth47:handleOnDisable()
  if self.mainFrame ~= nil then self.mainFrame:Hide() end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param curFrame table
---@param elapsed number
function PlayerHealth47:_onUpdateHandler(curFrame, elapsed)
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

function PlayerHealth47:_registerEvents() self.mainFrame:RegisterEvent("UNIT_HEALTH") end

function PlayerHealth47:_setOnShowOnHideHandlers()
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

function PlayerHealth47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
end

function PlayerHealth47:_disableAllScriptHandlers() self.mainFrame:SetScript("OnUpdate", nil) end
