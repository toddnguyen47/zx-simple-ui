---upvalues to prevent warnings
local UnitName, UnitHealth = UnitName, UnitHealth
local UnitClassification = UnitClassification

---include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local _MODULE_NAME = "TargetName47"
local _DECORATIVE_NAME = "Target Name"
local TargetName47 = ZxSimpleUI:NewModule(_MODULE_NAME)

TargetName47.MODULE_NAME = _MODULE_NAME
TargetName47.DECORATIVE_NAME = _DECORATIVE_NAME
TargetName47.bars = nil

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 300,
    fontsize = 12,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 0.0, 0.0, 1.0},
    border = "None",
    enabledToggle = true
  }
}

function TargetName47:__init__()
  self.unit = "target"

  self._timeSinceLastUpdate = 0
  self._prevName = UnitName(self.unit)
  self.mainFrame = nil

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, _defaults.profile)
end

function TargetName47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile

  self.bars = BarTemplate:new(self.db)

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
end

function TargetName47:OnEnable() self:handleOnEnable() end

function TargetName47:OnDisable() self:handleOnDisable() end

function TargetName47:createBar()
  local percentage = 1.0
  self.mainFrame = self.bars:createBar(percentage)

  self:_setFormattedName()

  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()
  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)

  self.mainFrame:Hide()
  return self.mainFrame
end

function TargetName47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then
    self:_handlePlayerTargetChanged()
    self.bars:refreshConfig()
  end
end

function TargetName47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, self._curDbProfile.enabledToggle)
end

function TargetName47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function TargetName47:handleOnDisable() if self.mainFrame ~= nil then self.mainFrame:Hide() end end

---@return table
function TargetName47:getExtraOptions()
  local optionTable = {
    enabledToggle = {
      type = "toggle",
      name = "Enable",
      desc = "Enable / Disable Module `" .. _DECORATIVE_NAME .. "`",
      order = 1
    }
  }
  return optionTable
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetName47:_registerEvents()
  self.mainFrame:RegisterEvent("UNIT_HEALTH")
  self.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function TargetName47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(curFrame, ...)
    if self:IsEnabled() then
      self:_enableAllScriptHandlers()
      -- Act as if target was just changed
      self:_handlePlayerTargetChanged()
    else
      self.mainFrame:Hide()
    end
  end)

  self.mainFrame:SetScript("OnHide",
    function(curFrame, ...) self:_disableAllScriptHandlers() end)
end

function TargetName47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit, ...)
    self:_onEventHandler(curFrame, event, unit)
  end)
end

function TargetName47:_disableAllScriptHandlers() self.mainFrame:SetScript("OnEvent", nil) end

function TargetName47:_onEventHandler(curFrame, event, unit, ...)
  local isUnitHealthEvent = Utils47:stringEqualsIgnoreCase(event, "UNIT_HEALTH")
  local isSameUnit = Utils47:stringEqualsIgnoreCase(unit, self.unit)
  if isUnitHealthEvent and isSameUnit then
    self:_handleUnitHealthEvent()
  elseif Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  end
end

function TargetName47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  if curUnitHealth > 0 then self:_setFormattedName() end
end

function TargetName47:_handlePlayerTargetChanged()
  local curUnitName = UnitName(self.unit)
  if curUnitName ~= nil and curUnitName ~= "" then self:_setFormattedName() end
end

function TargetName47:_setFormattedName()
  self.mainFrame.mainText:SetText(self:_getFormattedName())
end

---@return string formattedName
function TargetName47:_getFormattedName()
  local name = UnitName(self.unit) or ""
  local formattedName = Utils47:getInitials(name)
  local unitClassification = UnitClassification(self.unit)
  if not Utils47:isNormalEnemy(unitClassification) then
    local s1 = Utils47.UnitClassificationElitesTable[unitClassification]
    formattedName = string.format("(%s) %s", s1, formattedName)
  end
  return formattedName
end
