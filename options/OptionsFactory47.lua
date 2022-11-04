local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
---@class OptionsFactory47
local OptionsFactory47 = {}
OptionsFactory47.__index = OptionsFactory47
ZxSimpleUI.optionTables["OptionsFactory47"] = OptionsFactory47

local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local BarTemplateEnableOptions = ZxSimpleUI.optionTables["BarTemplateEnableOptions"]
local Power47Options = ZxSimpleUI.optionTables["Power47Options"]
local Runes47Options = ZxSimpleUI.optionTables["Runes47Options"]
local Totems47Options = ZxSimpleUI.optionTables["Totems47Options"]
local Combo47Options = ZxSimpleUI.optionTables["Combo47Options"]
local TargetName47Options = ZxSimpleUI.optionTables["TargetName47Options"]
---@type Aura47Options
local Aura47Options = ZxSimpleUI.optionTables["Aura47Options"]

---@param curModule table
---@return CoreOptions47
function OptionsFactory47:createCoreOptions(curModule)
  local coreOptions47 = CoreOptions47:new(curModule)
  return coreOptions47
end

---@param curModule table
---@return table BarTemplateOptions
function OptionsFactory47:createBarTemplateOptions(curModule)
  local coreOptions47 = self:createCoreOptions(curModule)
  return BarTemplateOptions:new(coreOptions47)
end

---@param curModule table
---@return table BarTemplateEnableOptions
function OptionsFactory47:createBarTemplateEnableOptions(curModule)
  local barTemplateOptions = self:createBarTemplateOptions(curModule)
  return BarTemplateEnableOptions:new(barTemplateOptions)
end

---@param curModule table
---@return table Power47Options
function OptionsFactory47:createPower47Options(curModule)
  local barTemplateOptions = self:createBarTemplateOptions(curModule)
  return Power47Options:new(barTemplateOptions)
end

---@param curModule table
---@return table Runes47Options
function OptionsFactory47:createRunes47Options(curModule)
  local coreOptions47 = self:createCoreOptions(curModule)
  return Runes47Options:new(coreOptions47)
end

---@param curModule table
---@return table Totems47Options
function OptionsFactory47:createTotems47Options(curModule)
  local coreOptions47 = self:createCoreOptions(curModule)
  return Totems47Options:new(coreOptions47)
end

---@param curModule table
---@return table Combo47Options
function OptionsFactory47:createCombo47Options(curModule)
  local coreOptions47 = self:createCoreOptions(curModule)
  return Combo47Options:new(coreOptions47)
end

---@param curModule table
---@return table TargetName47Options
function OptionsFactory47:createTargetName47Options(curModule)
  local barTemplateOptions = self:createBarTemplateEnableOptions(curModule)
  return TargetName47Options:new(barTemplateOptions)
end

---@param curModule table
---@return Aura47Options
function OptionsFactory47:createAura47Options(curModule)
  local core47Options = self:createCoreOptions(curModule)
  return Aura47Options:new(core47Options)
end

function OptionsFactory47:getBarTextDisplay()
  bartextdisplay = {
    name = "Bar Text Display",
    desc = "Display either percent, value, or both",
    type = "select",
    values = {
      ["Percent"] = "Percent",
      ["Value"] = "Value",
      ["ValuePercent"] = "Value and Percent"
    },
    -- order = self._coreOptions47:incrementOrderIndex()
  }
  return bartextdisplay
end
