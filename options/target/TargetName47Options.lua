local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local TargetName47Options = {}
TargetName47Options.__index = TargetName47Options
TargetName47Options.OPTION_NAME = "TargetName47Options"
ZxSimpleUI.optionTables[TargetName47Options.OPTION_NAME] = TargetName47Options

function TargetName47Options:__init__()
  self.options = {}
  local barTemplateOptions = self._barTemplateEnableOptions:getBarTemplateOptions()
  self._coreOptions47 = barTemplateOptions:getCoreOptions47()
  self._currentModule = barTemplateOptions:getCurrentModule()
end

---@param barTemplateEnableOptions table
function TargetName47Options:new(barTemplateEnableOptions)
  local newInstance = setmetatable({}, self)
  newInstance._barTemplateEnableOptions = barTemplateEnableOptions
  newInstance:__init__()
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
    self.options.args["nameInitials"] = {
      type = "select",
      name = "Name Initials",
      values = {allButFirst = "All words but the First", allButLast = "All words but the Last"}
    }
  end
  return self.options
end
