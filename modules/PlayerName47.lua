local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local BarTemplate = ZxSimpleUI.BarTemplate
local BarTemplateOptions = ZxSimpleUI.optionTables["BarTemplateOptions"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

--- upvalues to prevent warnings
local LibStub = LibStub
local UnitName = UnitName

local _MODULE_NAME = "PlayerName47"
local _DECORATIVE_NAME = "Player Name"
local PlayerName47 = ZxSimpleUI:NewModule(_MODULE_NAME)

PlayerName47.MODULE_NAME = _MODULE_NAME
PlayerName47.bars = nil
PlayerName47.unit = "player"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 400,
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

function PlayerName47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile

  self.bars = BarTemplate:new(self.db)
  self.bars.defaults = _defaults
  self._barTemplateOptions = BarTemplateOptions:new(self)
  local options = self._barTemplateOptions:getOptionTable(_DECORATIVE_NAME)
  options = self:_appendEnableOption(options)

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, options, _DECORATIVE_NAME)
end

function PlayerName47:OnEnable() self:handleOnEnable() end

function PlayerName47:OnDisable() self:handleOnDisable() end

function PlayerName47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevName = UnitName(self.unit)
  self.mainFrame = nil
end

---@return table
function PlayerName47:createBar()
  local percentage = 1.0
  self.mainFrame = self.bars:createBar(percentage)
  self.bars:setTextOnly(self:_getFormattedName())

  self:_setOnShowOnHideHandlers()
  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)
  return self.mainFrame
end

function PlayerName47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then
    self.bars:refreshConfig()
    self.mainFrame:Show()
  end
end

function PlayerName47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, self._curDbProfile.enabledToggle)
end

function PlayerName47:handleOnEnable()
  if self.mainFrame ~= nil then
    self:refreshConfig()
    self.mainFrame:Show()
  end
end

function PlayerName47:handleOnDisable() if self.mainFrame ~= nil then self.mainFrame:Hide() end end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param optionsTable table
---@return table
function PlayerName47:_appendEnableOption(optionsTable)
  -- Use parent's get/set functions
  optionsTable.args["enabledToggle"] = {
    type = "toggle",
    name = "Enable",
    desc = "Enable / Disable Module `" .. _DECORATIVE_NAME .. "`",
    order = 1
  }
  return optionsTable
end

---@return string formattedName
function PlayerName47:_getFormattedName()
  local name = UnitName(self.unit)
  return Utils47:getInitials(name)
end

function PlayerName47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(curFrame, ...)
    -- Even if shown, if the module is disabled, hide the frame!
    if not self:IsEnabled() then self.mainFrame:Hide() end
  end)
end
