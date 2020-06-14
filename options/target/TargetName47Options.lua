local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local BarTemplateEnableOptions = ZxSimpleUI.optionTables["BarTemplateEnableOptions"]
local media = LibStub("LibSharedMedia-3.0")

local TargetName47Options = {}
TargetName47Options.__index = TargetName47Options
TargetName47Options.OPTION_NAME = "TargetName47Options"
ZxSimpleUI.optionTables[TargetName47Options.OPTION_NAME] = TargetName47Options

---@param currentModule table
function TargetName47Options:__init__(currentModule)
  self.options = {}
  self._currentModule = currentModule
  self._curDbProfile = currentModule.db.profile
  self._coreOptions47 = CoreOptions47:new(self._currentModule)
  self._barTemplateEnableOptions = BarTemplateEnableOptions:new(self._currentModule)
end

---@param currentModule table
function TargetName47Options:new(currentModule)
  assert(currentModule ~= nil)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(currentModule)
  return newInstance
end

function TargetName47Options:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@return table
function TargetName47Options:getOptionTable()
  if next(self.options) == nil then
    self.options = self._barTemplateEnableOptions:getOptionTable()
    self.options.args["unitReactionColors"] = {
      type = "group",
      inline = true,
      name = "Unit Reaction Colors",
      order = self._coreOptions47:incrementOrderIndex(),
      get = function(info) return self._coreOptions47:getOptionColor(info) end,
      set = function(info, r, g, b, a)
        self._coreOptions47:setOptionColor(info, r, g, b, a)
      end,
      args = {
        hostileColor = {name = "Hostile Color", type = "color", hasAlpha = true, order = 1},
        neutralColor = {name = "Neutral Color", type = "color", hasAlpha = true, order = 2},
        friendlyColor = {name = "Neutral Color", type = "color", hasAlpha = true, order = 3}
      }
    }
  end
  return self.options
end
