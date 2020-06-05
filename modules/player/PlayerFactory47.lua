-- #region
--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local FramePool47 = ZxSimpleUI.FramePool47
local PlayerHealth47 = ZxSimpleUI:GetModule("PlayerHealth47")
local PlayerPower47 = ZxSimpleUI:GetModule("PlayerPower47")
local PlayerName47 = ZxSimpleUI:GetModule("PlayerName47")
local Runes47 = ZxSimpleUI:GetModule("Runes47")
local Totems47 = ZxSimpleUI:GetModule("Totems47")
local PetHealth47 = ZxSimpleUI:GetModule("PetHealth47")
-- local PetPower47 = ZxSimpleUI:GetModule("PetPower47")

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

  PlayerHealth47:initModuleEnableState()
  PlayerPower47:initModuleEnableState()
  PlayerName47:initModuleEnableState()
  Runes47:initModuleEnableState()
  Totems47:initModuleEnableState()
  PetHealth47:initModuleEnableState()
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
  local optionsObj = BarTemplateOptions:new(curModule)
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

---@return table
function PlayerFactory47:createPlayerPowerOptions()
  local curModule = PlayerPower47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionsObj = Power47Options:new(curModule)
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

---@return table
function PlayerFactory47:createPlayerNameOptions()
  local curModule = PlayerName47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionsObj = BarTemplateEnableOptions:new(curModule)
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

---@return table
function PlayerFactory47:createRuneOptions()
  local curModule = Runes47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionsObj = Runes47Options:new(curModule)
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

---@return table
function PlayerFactory47:createTotemOptions()
  local curModule = Totems47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionsObj = Totems47Options:new(curModule)
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

---@return table
function PlayerFactory47:createPetHealthOptions()
  local curModule = PetHealth47
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionsObj = BarTemplateEnableOptions:new(curModule)
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
---@param t1 table
---@param t2 table
function PlayerFactory47:_addAllFromT2ToT1(t1, t2) for k, v in pairs(t2) do t1[k] = v end end
