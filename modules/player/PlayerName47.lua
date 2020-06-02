--- upvalues to prevent warnings
local LibStub = LibStub
local UnitName = UnitName

--- include
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47
local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local _MODULE_NAME = "PlayerName47"
local _DECORATIVE_NAME = "Player Name"
local PlayerName47 = ZxSimpleUI:NewModule(_MODULE_NAME)

PlayerName47.MODULE_NAME = _MODULE_NAME
PlayerName47.DECORATIVE_NAME = _DECORATIVE_NAME
PlayerName47.bars = nil
PlayerName47.unit = "player"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    xoffset = 400,
    yoffset = 296,
    fontsize = 12,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 0.0, 0.0, 1.0},
    border = "None",
    enabledToggle = true
  }
}

function PlayerName47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevName = UnitName(self.unit)
  self.mainFrame = nil

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, _defaults.profile)
end

function PlayerName47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile

  self.bars = BarTemplate:new(self.db)

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
end

function PlayerName47:OnEnable() self:handleOnEnable() end

function PlayerName47:OnDisable() self:handleOnDisable() end

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

---@return table
function PlayerName47:getExtraOptions()
  local optionsTable = {
    enabledToggle = {
      -- Use parent's get/set functions
      type = "toggle",
      name = "Enable",
      desc = "Enable / Disable Module `" .. _DECORATIVE_NAME .. "`",
      order = 1
    }
  }
  return optionsTable
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

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
