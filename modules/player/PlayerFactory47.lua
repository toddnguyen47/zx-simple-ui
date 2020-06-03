local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local PlayerHealth47 = ZxSimpleUI:GetModule("PlayerHealth47")
local PlayerName47 = ZxSimpleUI:GetModule("PlayerName47")
local PlayerPower47 = ZxSimpleUI:GetModule("PlayerPower47")
local Runes47 = ZxSimpleUI:GetModule("Runes47")
local Totems47 = ZxSimpleUI:GetModule("Totems47")
local PetHealth47 = ZxSimpleUI:GetModule("PetHealth47")
local PetPower47 = ZxSimpleUI:GetModule("PetPower47")

local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local BarTemplateEnableOptions = ZxSimpleUI.optionTables["BarTemplateEnableOptions"]
local Power47Options = ZxSimpleUI.optionTables["Power47Options"]
local Runes47Options = ZxSimpleUI.optionTables["Runes47Options"]
local Totems47Options = ZxSimpleUI.optionTables["Totems47Options"]

local PlayerFactory47 = {}
PlayerFactory47.__index = PlayerFactory47
ZxSimpleUI.prereqTables["PlayerFactory47"] = PlayerFactory47

PlayerFactory47._framePool = {}

PlayerFactory47._playerHealth47 = {}
PlayerFactory47._playerName47 = {}
PlayerFactory47._playerPower47 = {}
PlayerFactory47._runes47 = {}
PlayerFactory47._totems47 = {}
PlayerFactory47._petHealth47 = {}
PlayerFactory47._petPower47 = {}

---@return table
function PlayerFactory47:createPlayerHealth47()
  self._playerHealth47["module"] = PlayerHealth47
  local curModule = self._playerHealth47["module"]
  curModule:createBar()
  self._framePool[curModule.MODULE_NAME] = curModule.mainFrame
  self:_handleModuleEnable(curModule)
  return curModule.mainFrame
end

---@return table
function PlayerFactory47:createPlayerName47()
  self._playerName47["module"] = PlayerName47
  local curModule = self._playerName47["module"]
  curModule:createBar()
  self._framePool[curModule.MODULE_NAME] = curModule.mainFrame
  self:_handleModuleEnable(curModule)
  return curModule.mainFrame
end

---@return table
function PlayerFactory47:createPlayerPower47()
  self._playerPower47["module"] = PlayerPower47
  local curModule = self._playerPower47["module"]
  curModule:createBar()
  self._framePool[curModule.MODULE_NAME] = curModule.mainFrame
  self:_handleModuleEnable(curModule)
  return curModule.mainFrame
end

---@return table
function PlayerFactory47:createRunes47()
  self._runes47["module"] = Runes47
  local curModule = self._runes47["module"]
  local moduleToAnchorTo = self._playerPower47["module"]
  if moduleToAnchorTo == nil then moduleToAnchorTo = self:createPlayerPower47() end

  curModule:createBar(self._framePool[moduleToAnchorTo.MODULE_NAME])
  self._framePool[curModule.MODULE_NAME] = curModule.mainFrame
  self:_handleModuleEnable(curModule)
  return curModule.mainFrame
end

---@return table
function PlayerFactory47:createTotems47()
  self._totems47["module"] = Totems47
  local curModule = self._totems47["module"]
  local moduleToAnchorTo = self._playerPower47["module"]
  if moduleToAnchorTo == nil then moduleToAnchorTo = self:createPlayerPower47() end

  curModule:createBar(self._framePool[moduleToAnchorTo.MODULE_NAME])
  self._framePool[curModule.MODULE_NAME] = curModule.mainFrame
  self:_handleModuleEnable(curModule)
  return curModule.mainFrame
end

---@return table
function PlayerFactory47:createPetHealth47()
  self._petHealth47["module"] = PetHealth47
  local curModule = self._petHealth47["module"]
  local moduleToAnchorTo = self._playerPower47["module"]
  if moduleToAnchorTo == nil then moduleToAnchorTo = self:createPlayerPower47() end

  curModule:createBar(self._framePool[moduleToAnchorTo.MODULE_NAME])
  self._framePool[curModule.MODULE_NAME] = curModule.mainFrame
  self:_handleModuleEnable(curModule)
  return curModule.mainFrame
end

---@return table
function PlayerFactory47:createPetPower47()
  self._petPower47["module"] = PetPower47
  local curModule = self._petPower47["module"]
  local moduleToAnchorTo = self._petHealth47["module"]
  if moduleToAnchorTo == nil then moduleToAnchorTo = self:createPetHealth47() end

  curModule:createBar(self._framePool[moduleToAnchorTo.MODULE_NAME])
  self._framePool[curModule.MODULE_NAME] = curModule.mainFrame
  self:_handleModuleEnable(curModule)
  return curModule.mainFrame
end

---@return table
function PlayerFactory47:createPlayerHealthOptions47()
  if self._playerHealth47["module"] == nil then self:createPlayerHealth47() end
  self._playerHealth47["options"] = BarTemplateOptions:new(self._playerHealth47["module"])
  local optionsObj = self._playerHealth47["options"]
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

function PlayerFactory47:createPlayerNameOptions47()
  if self._playerName47["module"] == nil then self:createPlayerName47() end
  self._playerName47["options"] = BarTemplateEnableOptions:new(self._playerName47["module"])
  local optionsObj = self._playerName47["options"]
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

---@return table
function PlayerFactory47:createPlayerPowerOptions47()
  if self._playerPower47["module"] == nil then self:createPlayerPower47() end
  self._playerPower47["options"] = Power47Options:new(self._playerPower47["module"])
  local optionsObj = self._playerPower47["options"]
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

---@return table
function PlayerFactory47:createRunesOptions47()
  if self._runes47["module"] == nil then self:createRunes47() end
  self._runes47["options"] = Runes47Options:new(self._runes47["module"])
  local optionsObj = self._runes47["options"]
  optionsObj:registerModuleOptionsTable()
  return optionsObj.options
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param moduleInput table
function PlayerFactory47:_handleModuleEnable(moduleInput)
  moduleInput:handleEnableToggle()
  if moduleInput:IsEnabled() then
    moduleInput:handleOnEnable()
  else
    moduleInput:handleOnDisable()
  end
end
