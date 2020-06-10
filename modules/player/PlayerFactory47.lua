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
local PetPower47 = ZxSimpleUI:GetModule("PetPower47")

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

  self:_initModuleEnableState(PlayerHealth47)
  self:_initModuleEnableState(PlayerPower47)
  self:_initModuleEnableState(PlayerName47)
  self:_initModuleEnableState(Runes47)
  self:_initModuleEnableState(Totems47)
  self:_initModuleEnableState(PetHealth47)
  self:_initModuleEnableState(PetPower47)
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
  return self:_createOptionsHelper(PlayerHealth47, BarTemplateOptions)
end

---@return table
function PlayerFactory47:createPlayerPowerOptions()
  return self:_createOptionsHelper(PlayerPower47, Power47Options)
end

---@return table
function PlayerFactory47:createPlayerNameOptions()
  return self:_createOptionsHelper(PlayerName47, BarTemplateEnableOptions)
end

---@return table
function PlayerFactory47:createRuneOptions()
  return self:_createOptionsHelper(Runes47, Runes47Options)
end

---@return table
function PlayerFactory47:createTotemOptions()
  return self:_createOptionsHelper(Totems47, Totems47Options)
end

---@return table
function PlayerFactory47:createPetHealthOptions()
  return self:_createOptionsHelper(PetHealth47, BarTemplateEnableOptions)
end

function PlayerFactory47:createPetPowerOptions()
  return self:_createOptionsHelper(PetPower47, BarTemplateEnableOptions)
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
---@param t1 table
---@param t2 table
function PlayerFactory47:_addAllFromT2ToT1(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

---@param curModule table
---@param optionObject table
---@return table
function PlayerFactory47:_createOptionsHelper(curModule, optionObject)
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = optionObject:new(curModule)
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

---@param curModule table
---Explicitly call OnEnable() and OnDisable() depending on the module's IsEnabled()
---This function is exactly like refreshConfig(), except it is called only during initialization.
function PlayerFactory47:_initModuleEnableState(curModule)
  if type(curModule.handleEnableToggle) == "function" then curModule:handleEnableToggle() end
  if curModule:IsEnabled() then
    curModule:OnEnable()
  else
    curModule:OnDisable()
  end
  curModule:refreshConfig()
end
