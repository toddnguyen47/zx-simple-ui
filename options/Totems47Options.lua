local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local media = LibStub("LibSharedMedia-3.0")

local Totems47Options = {}
Totems47Options.__index = Totems47Options
Totems47Options.OPTION_NAME = "Totems47Options"
ZxSimpleUI.optionTables[Totems47Options.OPTION_NAME] = Totems47Options

---@param totemModule table
function Totems47Options:new(totemModule)
  assert(totemModule ~= nil)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(totemModule)
  return newInstance
end

function Totems47Options:__init__(totemModule)
  self.options = {}
  self._totemModule = totemModule
  self._curDbProfile = totemModule.db.profile
  self._coreOptions47 = CoreOptions47:new(self._totemModule)
end

function Totems47Options:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._totemModule.MODULE_NAME, self:getOptionTable(),
    self._totemModule.DECORATIVE_NAME)
end

---@return table
function Totems47Options:getOptionTable()
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = self._totemModule.DECORATIVE_NAME,
      --- "Parent" get/set
      get = function(info) return self._coreOptions47:getOption(info) end,
      set = function(info, value) self._coreOptions47:setOption(info, value) end,
      args = {
        header = {
          type = "header",
          name = self._totemModule.DECORATIVE_NAME,
          order = ZxSimpleUI.HEADER_ORDER_INDEX
        },
        enabledToggle = {
          type = "toggle",
          name = "Enable",
          desc = "Enable / Disable this module",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 1
        },
        height = {
          name = "Totem Height",
          desc = "Totem display height",
          type = "range",
          min = 2,
          max = 50,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        yoffset = {
          name = "Y Offset",
          desc = "Y Offset",
          type = "range",
          min = -30,
          max = 30,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Totem Duration Font",
          desc = "Totem Duration Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontsize = {
          name = "Totem Duration Font Size",
          desc = "Totem Duration Font Size",
          type = "range",
          min = 10,
          max = 36,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontflags = {
          name = "Font Flags",
          type = "group",
          inline = true,
          order = self._coreOptions47:incrementOrderIndex(),
          args = {
            outline = {name = "Outline", type = "toggle", order = 1},
            thickoutline = {name = "Thick Outline", type = "toggle", order = 2},
            monochrome = {name = "Monochrome", type = "toggle", order = 3}
          }
        },
        fontcolor = {
          name = "Totem Duration Color",
          desc = "Totem Duration Color",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end

