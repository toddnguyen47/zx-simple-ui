local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local media = LibStub("LibSharedMedia-3.0")

local BarTemplateOptions = {}
BarTemplateOptions.__index = BarTemplateOptions
BarTemplateOptions.OPTION_NAME = "BarTemplateOptions"
ZxSimpleUI.optionTables[BarTemplateOptions.OPTION_NAME] = BarTemplateOptions

---@param currentModule table
function BarTemplateOptions:new(currentModule)
  assert(currentModule ~= nil)
  assert(currentModule.bars ~= nil, "Remember to initialize a bar template object first!")
  local newInstance = setmetatable({}, self)
  newInstance:__init__(currentModule)
  return newInstance
end

function BarTemplateOptions:__init__(currentModule)
  self.options = {}
  self._currentModule = currentModule
  self._curDbProfile = currentModule.db.profile
  self._coreOptions47 = CoreOptions47:new(self._currentModule)
end

function BarTemplateOptions:registerModuleOptionsTable() error("Not implemented error") end

---@param decorativeName string
---@return table
function BarTemplateOptions:getOptionTable(decorativeName)
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = decorativeName,
      --- "Parent" get/set
      get = function(info) return self._coreOptions47:getOption(info) end,
      set = function(info, value) self._coreOptions47:setOption(info, value) end,
      args = {
        header = {
          type = "header",
          name = decorativeName,
          order = ZxSimpleUI.HEADER_ORDER_INDEX
        },
        width = {
          name = "Bar Width",
          desc = "Bar Width Size",
          type = "range",
          min = 0,
          max = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          order = self._coreOptions47:incrementOrderIndex()
        },
        height = {
          name = "Bar Height",
          desc = "Bar Height Size",
          type = "range",
          min = 0,
          max = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          order = self._coreOptions47:incrementOrderIndex()
        },
        positionx = {
          name = "Bar X",
          desc = "Bar X Position",
          type = "range",
          min = 0,
          max = ZxSimpleUI.SCREEN_WIDTH,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        positionx_center = {
          name = "Center Bar X",
          desc = "Center Bar X Position",
          type = "execute",
          func = function(...) self._currentModule.bars:handlePositionXCenter() end,
          order = self._coreOptions47:incrementOrderIndex()
        },
        positiony = {
          name = "Bar Y",
          desc = "Bar Y Position",
          type = "range",
          min = 0,
          max = ZxSimpleUI.SCREEN_HEIGHT,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        positiony_center = {
          name = "Center Bar Y",
          desc = "Center Bar Y Position",
          type = "execute",
          func = function(...) self._currentModule.bars:handlePositionYCenter() end,
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontsize = {
          name = "Bar Font Size",
          desc = "Bar Font Size",
          type = "range",
          min = 10,
          max = 36,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Bar Font",
          desc = "Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontcolor = {
          name = "Bar Font Color",
          desc = "Bar Font Color",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        border = {
          name = "Bar Border",
          desc = "Bar Border",
          type = "select",
          dialogControl = "LSM30_Border",
          values = media:HashTable("border"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        color = {
          name = "Bar Color",
          desc = "Bar Color",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = true,
          order = self._coreOptions47:incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end
