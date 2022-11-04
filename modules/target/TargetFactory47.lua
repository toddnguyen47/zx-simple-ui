-- #region
--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)
local CoreFactory47 = ZxSimpleUI.CoreFactory47
local OptionsFactory47 = ZxSimpleUI.optionTables["OptionsFactory47"]

local TargetHealth47 = ZxSimpleUI:GetModule("TargetHealth47")
local TargetName47 = ZxSimpleUI:GetModule("TargetName47")
local TargetPower47 = ZxSimpleUI:GetModule("TargetPower47")
local Combo47 = ZxSimpleUI:GetModule("Combo47")
local TargetDebuffs47 = ZxSimpleUI:GetModule("TargetDebuffs47")

local MODULE_NAME = "TargetFactory47"
local DECORATIVE_NAME = Locale["module.decName.targetFactory"]
local TargetFactory47 = ZxSimpleUI:NewModule(MODULE_NAME)
TargetFactory47.MODULE_NAME = MODULE_NAME
TargetFactory47.DECORATIVE_NAME = DECORATIVE_NAME
-- #endregion

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function TargetFactory47:OnInitialize()
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function TargetFactory47:OnEnable()
  self:createHealthOptions()
  self:createPowerOptions()
  self:createNameOptions()
  self:createComboOptions()
  self:createTargetDebuffOptions()

  CoreFactory47:initModuleEnableState(TargetHealth47)
  CoreFactory47:initModuleEnableState(TargetPower47)
  CoreFactory47:initModuleEnableState(TargetName47)
  CoreFactory47:initModuleEnableState(Combo47)
  CoreFactory47:initModuleEnableState(TargetDebuffs47)
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function TargetFactory47:OnDisable() end

-- ####################################
-- # FACTORY METHODS
-- ####################################
function TargetFactory47:createHealthOptions()
  local curModule = TargetHealth47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createBarTemplateOptions(curModule)
  optionInstance = OptionsFactory47:addBarTextDisplayOption(optionInstance)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

function TargetFactory47:createPowerOptions()
  local curModule = TargetPower47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createPower47Options(curModule)
  optionInstance = OptionsFactory47:addBarTextDisplayOption(optionInstance)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

function TargetFactory47:createNameOptions()
  local curModule = TargetName47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createTargetName47Options(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

function TargetFactory47:createComboOptions()
  local curModule = Combo47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createCombo47Options(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

---@return table
function TargetFactory47:createTargetDebuffOptions()
  local curModule = TargetDebuffs47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createAura47Options(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
---@param t1 table
---@param t2 table
function TargetFactory47:_addAllFromT2ToT1(t1, t2) for k, v in pairs(t2) do t1[k] = v end end
