-- Target appears when
-- 1. Selected
-- 2. Being attacked
--- upvalues to prevent warnings
local LibStub = LibStub
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitName, UnitPowerType = UnitName, UnitPowerType
local unpack = unpack

---Include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplate = ZxSimpleUI.BarTemplate
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local _MODULE_NAME = "TargetPower47"
local _DECORATIVE_NAME = "Target Power"
local TargetPower47 = ZxSimpleUI:NewModule(_MODULE_NAME)

TargetPower47.MODULE_NAME = _MODULE_NAME
TargetPower47.bars = nil
TargetPower47.unit = "target"

local _powerEventColorTable = {
  ["UNIT_MANA"] = {0.0, 0.0, 1.0, 1.0},
  ["UNIT_RAGE"] = {1.0, 0.0, 0.0, 1.0},
  ["UNIT_FOCUS"] = {1.0, 0.65, 0.0, 1.0},
  ["UNIT_ENERGY"] = {1.0, 1.0, 0.0, 1.0},
  ["UNIT_RUNIC_POWER"] = {0.0, 1.0, 1.0, 1.0}
}

local _unitPowerTypeTable = {
  ["MANA"] = 0,
  ["RAGE"] = 1,
  ["FOCUS"] = 2,
  ["ENERGY"] = 3,
  ["COMBOPOINTS"] = 4,
  ["RUNES"] = 5,
  ["RUNICPOWER"] = 6
}

local _defaults = {
  profile = {
    enabledToggle = true,
    showbar = false,
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 240,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = _powerEventColorTable["UNIT_MANA"], -- need this option for createBar() to work 
    colorMana = _powerEventColorTable["UNIT_MANA"],
    colorRage = _powerEventColorTable["UNIT_RAGE"],
    colorFocus = _powerEventColorTable["UNIT_FOCUS"],
    colorEnergy = _powerEventColorTable["UNIT_ENERGY"],
    colorRunicPower = _powerEventColorTable["UNIT_RUNIC_POWER"],
    border = "None"
  }
}

function TargetPower47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  -- Always set the showbar option to false on initialize
  self._curDbProfile.showbar = _defaults.profile.showbar

  self.bars = BarTemplate:new(self.db)
  self.bars.defaults = _defaults
  self._barTemplateOptions = BarTemplateOptions:new(self)
  local options = self._barTemplateOptions:getOptionTable(_DECORATIVE_NAME)
  options = self:_appendColorOptions(options)
  -- Don't allow user to change target power color since the color should be determined
  -- by the Target's power type
  options.args.color = nil

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, options, _DECORATIVE_NAME)
end

function TargetPower47:OnEnable() self:handleOnEnable() end

function TargetPower47:OnDisable() self:handleOnDisable() end

function TargetPower47:__init__()
  self.mainFrame = nil

  self._timeSinceLastUpdate = 0
  self._prevTargetPower47 = UnitPowerMax(self.unit)
  self._powerType, self._powerTypeString = nil, nil
  self._currentPowerColorEdited = _powerEventColorTable["UNIT_MANA"]
end

function TargetPower47:createBar()
  self:_setUnitPowerType()
  local targetUnitPower = UnitPower(self.unit)
  local targetUnitMaxPower = UnitPowerMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitPower, targetUnitMaxPower)
  self.mainFrame = self.bars:createBar(percentage)

  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)

  self.mainFrame:Hide()
  return self.mainFrame
end

function TargetPower47:refreshConfig()
  if self:IsEnabled() and self.mainFrame:IsVisible() then
    --- if we are currently in shown mode
    if self._curDbProfile.showbar == true then
      self.mainFrame.statusBar:SetStatusBarColor(unpack(self._currentPowerColorEdited))
    else
      self.bars:refreshConfig()
      self:_setRefreshColor()
    end
  end
end

---Don't have to do anything here. Maybe in the future I'll add an option to disable this bar.
function TargetPower47:handleEnableToggle() end

function TargetPower47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function TargetPower47:handleOnDisable() if self.mainFrame ~= nil then self.mainFrame:Hide() end end

function TargetPower47:handleShownOption() self.mainFrame:Show() end

function TargetPower47:handleShownHideOption() self.mainFrame:Hide() end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param optionTables table
---@return table
function TargetPower47:_appendColorOptions(optionTables)
  optionTables.args["colorgroup"] = {
    name = "Power Colors",
    type = "group",
    inline = true,
    get = function(info) return self._barTemplateOptions:getOptionColor(info) end,
    set = function(info, r, g, b, a)
      self._currentPowerColorEdited = {r, g, b, a}
      self._barTemplateOptions:setOptionColor(info, r, g, b, a)
    end,
    order = self._barTemplateOptions:incrementOrderIndex(),
    args = {
      showbar = {
        name = "Show Color",
        desc = "Show the currently edited power color",
        type = "toggle",
        order = 1,
        disabled = function(info) return not self._curDbProfile.enabledToggle end,
        get = function(info) return self._barTemplateOptions:getOption(info) end,
        set = function(info, value) self._barTemplateOptions:setOption(info, value) end
      },
      colorMana = {
        name = "Mana",
        desc = "UNIT_MANA",
        type = "color",
        hasAlpha = true,
        order = 5
      },
      colorRage = {
        name = "Rage",
        desc = "UNIT_RAGE",
        type = "color",
        hasAlpha = true,
        order = 6
      },
      colorFocus = {
        name = "Focus",
        desc = "UNIT_FOCUS",
        type = "color",
        hasAlpha = true,
        order = 7
      },
      colorEnergy = {
        name = "Energy",
        desc = "UNIT_ENERGY",
        type = "color",
        hasAlpha = true,
        order = 8
      },
      colorRunicPower = {
        name = "Runic Power",
        desc = "UNIT_RUNIC_POWER",
        type = "color",
        hasAlpha = true,
        order = 9
      }
    }
  }

  return optionTables
end

function TargetPower47:_registerEvents()
  for powerEvent, _ in pairs(_powerEventColorTable) do
    self.mainFrame:RegisterEvent(powerEvent)
  end
  self.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  self.mainFrame:RegisterEvent("UNIT_DISPLAYPOWER")
end

function TargetPower47:_setOnShowOnHideHandlers()
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

function TargetPower47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit)
    self:_onEventHandler(curFrame, event, unit)
  end)
end

function TargetPower47:_disableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:SetScript("OnEvent", nil)
end

function TargetPower47:_onEventHandler(curFrame, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(unit, self.unit) then
    if Utils47:stringEqualsIgnoreCase(event, "UNIT_DISPLAYPOWER") then
      self:_handlePowerChanged()
    elseif _powerEventColorTable[event] ~= nil then
      self:_handleUnitPowerEvent()
    end
  end
end

function TargetPower47:_handlePlayerTargetChanged()
  local targetName = UnitName(self.unit)
  if targetName ~= nil and targetName ~= "" then self:_setRefreshColor() end
end

function TargetPower47:_handlePowerChanged()
  self:_setUnitPowerType()
  self:refreshConfig()
  self:_setRefreshColor()
end

function TargetPower47:_handleUnitPowerEvent(curUnitPower)
  curUnitPower = curUnitPower or UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
  self.bars:setStatusBarValue(powerPercent)
end

function TargetPower47:_onUpdateHandler(curFrame, elapsed)
  if not self.mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitPower = UnitPower(self.unit)
    if (curUnitPower ~= self._prevTargetPower47) then
      self:_handleUnitPowerEvent(curUnitPower)
      self._prevTargetPower47 = curUnitPower
      self._timeSinceLastUpdate = 0
    end
  end
end

function TargetPower47:_setUnitPowerType()
  self._powerType, self._powerTypeString = UnitPowerType(self.unit)
end

function TargetPower47:_setRefreshColor()
  local colorOptionTable = self:_getColorsInOptions()
  self:_setUnitPowerType()
  local upperType = string.upper(self._powerTypeString)

  local t1 = colorOptionTable["UNIT_" .. upperType]
  t1 = t1 or colorOptionTable["UNIT_MANA"]
  self.mainFrame.statusBar:SetStatusBarColor(unpack(t1))
end

---@return table
function TargetPower47:_getColorsInOptions()
  local t1 = {
    ["UNIT_MANA"] = self._curDbProfile.colorMana,
    ["UNIT_RAGE"] = self._curDbProfile.colorRage,
    ["UNIT_FOCUS"] = self._curDbProfile.colorFocus,
    ["UNIT_ENERGY"] = self._curDbProfile.colorEnergy,
    ["UNIT_RUNIC_POWER"] = self._curDbProfile.colorRunicPower
  }
  return t1
end
