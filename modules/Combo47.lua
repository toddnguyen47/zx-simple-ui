local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "Combo47"
local _DECORATIVE_NAME = "Combo Points Display"
local Combo47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitName = UnitName
local UnitHealth, UnitPowerType = UnitHealth, UnitPowerType
local ToggleDropDownMenu, TargetFrameDropDown = ToggleDropDownMenu, TargetFrameDropDown
local unpack = unpack

Combo47.MODULE_NAME = _MODULE_NAME
Combo47.bars = nil
Combo47.unit = "target"

local _defaults = {}

function Combo47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile

  self:__init__()

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getOptionTable(), _DECORATIVE_NAME)
end

function Combo47:OnEnable()
end

function Combo47:__init__()
  self.options = {}
  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX
end

function Combo47:incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@return table
function Combo47:_getOptionTable()
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = _DECORATIVE_NAME,
      get = function(infoTable)
        return self:getOption(infoTable)
      end,
      set = function(infoTable, value)
        self:setOption(infoTable, value)
      end,
      args = {
        header = {type = "header", name = _DECORATIVE_NAME, order = self:incrementOrderIndex()}
      }
    }
  end
  return self.options
end
