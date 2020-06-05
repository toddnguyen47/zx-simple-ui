-- #region
--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local TargetHealth47 = ZxSimpleUI:GetModule("TargetHealth47")
local TargetName47 = ZxSimpleUI:GetModule("TargetName47")
local TargetPower47 = ZxSimpleUI:GetModule("TargetPower47")
local Combo47 = ZxSimpleUI:GetModule("Combo47")

local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local BarTemplateEnableOptions = ZxSimpleUI.optionTables["BarTemplateEnableOptions"]
local Power47Options = ZxSimpleUI.optionTables["Power47Options"]
local Runes47Options = ZxSimpleUI.optionTables["Runes47Options"]
local Totems47Options = ZxSimpleUI.optionTables["Totems47Options"]

local MODULE_NAME = "TargetFactory47"
local DECORATIVE_NAME = "Target Factory"
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

  TargetHealth47:initModuleEnableState()
  TargetPower47:initModuleEnableState()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function TargetFactory47:OnDisable() end

-- ####################################
-- # FACTORY METHODS
-- ####################################
function TargetFactory47:createHealthOptions()
  self:_createOptionsHelper(TargetHealth47, BarTemplateOptions)
end

function TargetFactory47:createPowerOptions()
  self:_createOptionsHelper(TargetPower47, Power47Options)
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
---@param t1 table
---@param t2 table
function TargetFactory47:_addAllFromT2ToT1(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

---@param curModule table
---@param optionObject table
---@return table
function TargetFactory47:_createOptionsHelper(curModule, optionObject)
  if curModule.mainFrame == nil then curModule:createBar() end
  local optionInstance = optionObject:new(curModule)
  optionInstance:registerModuleOptionsTable()
  return optionInstance.options
end

