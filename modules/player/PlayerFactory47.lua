-- #region
-- include files
---@type ZxSimpleUI
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)
---@type FramePool47
local FramePool47 = ZxSimpleUI.FramePool47
local CoreFactory47 = ZxSimpleUI.CoreFactory47
---@type OptionsFactory47
local OptionsFactory47 = ZxSimpleUI.optionTables["OptionsFactory47"]

local PlayerHealth47 = ZxSimpleUI:GetModule("PlayerHealth47")
local PlayerPower47 = ZxSimpleUI:GetModule("PlayerPower47")
local PlayerName47 = ZxSimpleUI:GetModule("PlayerName47")
local Runes47 = ZxSimpleUI:GetModule("Runes47")
local Totems47 = ZxSimpleUI:GetModule("Totems47")
local PetHealth47 = ZxSimpleUI:GetModule("PetHealth47")
local PetPower47 = ZxSimpleUI:GetModule("PetPower47")
---@type PlayerDebuffs47
local PlayerDebuffs47 = ZxSimpleUI:GetModule("PlayerDebuffs47")

local MODULE_NAME = "PlayerFactory47"
local DECORATIVE_NAME = Locale["module.decName.playerFactory"]
local PlayerFactory47 = ZxSimpleUI:NewModule(MODULE_NAME)
PlayerFactory47.MODULE_NAME = MODULE_NAME
PlayerFactory47.DECORATIVE_NAME = DECORATIVE_NAME
-- #endregion

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function PlayerFactory47:OnInitialize()
  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function PlayerFactory47:OnEnable()
  self:createPlayerHealthOptions()
  self:createPlayerPowerOptions()
  self:createPlayerNameOptions()
  self:createRuneOptions()
  self:createTotemOptions()
  self:createPetHealthOptions()
  self:createPetPowerOptions()
  self:createPlayerDebuffOptions()

  CoreFactory47:initModuleEnableState(PlayerHealth47)
  CoreFactory47:initModuleEnableState(PlayerPower47)
  CoreFactory47:initModuleEnableState(PlayerName47)
  CoreFactory47:initModuleEnableState(Runes47)
  CoreFactory47:initModuleEnableState(Totems47)
  CoreFactory47:initModuleEnableState(PetHealth47)
  CoreFactory47:initModuleEnableState(PetPower47)
  CoreFactory47:initModuleEnableState(PlayerDebuffs47)
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PlayerFactory47:OnDisable() end

-- ####################################
-- # FACTORY METHODS
-- ####################################

---@return table
function PlayerFactory47:createPlayerHealthOptions()
  local curModule = PlayerHealth47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createBarTemplateOptions(curModule)
  optionInstance = self:_addBarTextDisplayOption(optionInstance)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

---@return table
function PlayerFactory47:createPlayerPowerOptions()
  local curModule = PlayerPower47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createPower47Options(curModule)
  optionInstance = self:_addBarTextDisplayOption(optionInstance)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

---@return table
function PlayerFactory47:createPlayerNameOptions()
  local curModule = PlayerName47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createBarTemplateEnableOptions(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

---@return table
function PlayerFactory47:createRuneOptions()
  local curModule = Runes47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createRunes47Options(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

---@return table
function PlayerFactory47:createTotemOptions()
  local curModule = Totems47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createTotems47Options(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

---@return table
function PlayerFactory47:createPetHealthOptions()
  local curModule = PetHealth47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createBarTemplateEnableOptions(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

---@return table
function PlayerFactory47:createPetPowerOptions()
  local curModule = PetPower47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createBarTemplateEnableOptions(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

---@return table
function PlayerFactory47:createPlayerDebuffOptions()
  local curModule = PlayerDebuffs47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = OptionsFactory47:createAura47Options(curModule)
  return CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
---@param t1 table
---@param t2 table
function PlayerFactory47:_addAllFromT2ToT1(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

---@param optionInstance table
---@return table
function PlayerFactory47:_addBarTextDisplayOption(optionInstance)
  local options = optionInstance:getOptionTable()
  local bartextdisplay = OptionsFactory47:getBarTextDisplay()
  options.args["bartextdisplay"] = bartextdisplay
  optionInstance.options = options
  return optionInstance
end
