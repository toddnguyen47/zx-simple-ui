-- #region
--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreFactory47 = ZxSimpleUI.CoreFactory47

local PlayerHealth47 = ZxSimpleUI:GetModule("PlayerHealth47")
local PlayerPower47 = ZxSimpleUI:GetModule("PlayerPower47")
local PlayerName47 = ZxSimpleUI:GetModule("PlayerName47")
local Runes47 = ZxSimpleUI:GetModule("Runes47")
local Totems47 = ZxSimpleUI:GetModule("Totems47")
local PetHealth47 = ZxSimpleUI:GetModule("PetHealth47")
local PetPower47 = ZxSimpleUI:GetModule("PetPower47")

local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local BarTemplateEnableOptions = ZxSimpleUI.optionTables["BarTemplateEnableOptions"]
local Power47Options = ZxSimpleUI.optionTables["Power47Options"]
local Runes47Options = ZxSimpleUI.optionTables["Runes47Options"]
local Totems47Options = ZxSimpleUI.optionTables["Totems47Options"]

local MODULE_NAME = "PlayerFactory47"
local DECORATIVE_NAME = "Player Factory"
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

  CoreFactory47:initModuleEnableState(PlayerHealth47)
  CoreFactory47:initModuleEnableState(PlayerPower47)
  CoreFactory47:initModuleEnableState(PlayerName47)
  CoreFactory47:initModuleEnableState(Runes47)
  CoreFactory47:initModuleEnableState(Totems47)
  CoreFactory47:initModuleEnableState(PetHealth47)
  CoreFactory47:initModuleEnableState(PetPower47)
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
  local optionInstance = BarTemplateOptions:new(CoreOptions47:new(curModule))
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

---@return table
function PlayerFactory47:createPlayerPowerOptions()
  local curModule = PlayerPower47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = Power47Options:new(
                           BarTemplateOptions:new(CoreOptions47:new(curModule)))
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

---@return table
function PlayerFactory47:createPlayerNameOptions()
  local curModule = PlayerName47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = BarTemplateEnableOptions:new(
                           BarTemplateOptions:new(CoreOptions47:new(curModule)))
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

---@return table
function PlayerFactory47:createRuneOptions()
  local curModule = Runes47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = Runes47Options:new(CoreOptions47:new(curModule))
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

---@return table
function PlayerFactory47:createTotemOptions()
  local curModule = Totems47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = Totems47Options:new(curModule, CoreOptions47:new(curModule))
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

---@return table
function PlayerFactory47:createPetHealthOptions()
  local curModule = PetHealth47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = BarTemplateEnableOptions:new(
                           BarTemplateOptions:new(CoreOptions47:new(curModule)))
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

function PlayerFactory47:createPetPowerOptions()
  local curModule = PetPower47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = BarTemplateEnableOptions:new(
                           BarTemplateOptions:new(CoreOptions47:new(curModule)))
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
---@param t1 table
---@param t2 table
function PlayerFactory47:_addAllFromT2ToT1(t1, t2) for k, v in pairs(t2) do t1[k] = v end end
