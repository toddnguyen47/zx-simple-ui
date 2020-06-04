local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local media = LibStub("LibSharedMedia-3.0")

local Totems47Options = {}
Totems47Options.__index = Totems47Options
Totems47Options.OPTION_NAME = "Totems47Options"
ZxSimpleUI.optionTables[Totems47Options.OPTION_NAME] = Totems47Options

---@param currentModule table
function Totems47Options:__init__(currentModule)
  self.options = {}
  self._currentModule = currentModule
  self._curDbProfile = currentModule.db.profile
  self._coreOptions47 = CoreOptions47:new(self._currentModule)
end

---@param currentModule table
function Totems47Options:new(currentModule)
  assert(currentModule ~= nil)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(currentModule)
  return newInstance
end

function Totems47Options:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@return table
function Totems47Options:getOptionTable()
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = self._currentModule.DECORATIVE_NAME,
      --- "Parent" get/set
      get = function(info) return self._coreOptions47:getOption(info) end,
      set = function(info, value) self._coreOptions47:setOption(info, value) end,
      args = {
        header = {
          type = "header",
          name = self._currentModule.DECORATIVE_NAME,
          order = ZxSimpleUI.HEADER_ORDER_INDEX
        },
        enabledToggle = {
          type = "toggle",
          name = "Enable",
          desc = "Enable / Disable this module",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 1,
          width = "full"
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
        setpoint = {
          name = "Setpoints",
          type = "group",
          inline = true,
          order = self._coreOptions47:incrementOrderIndex(),
          args = {
            frameToAnchorTo = {
              type = "description",
              name = string.format("FRAME TO ANCHOR TO:\n%s", self._currentModule.mainFrame
                .frameToAnchorTo.DECORATIVE_NAME),
              order = 10,
              fontSize = "medium"
            },
            yoffset = {
              name = "Y Offset",
              desc = "Y Offset",
              type = "range",
              min = -30,
              max = 30,
              step = 1,
              order = 11
            }
          }
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

