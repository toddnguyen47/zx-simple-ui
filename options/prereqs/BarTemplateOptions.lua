local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47
local CoreOptions47 = ZxSimpleUI.optionTables["CoreOptions47"]
local media = LibStub("LibSharedMedia-3.0")

local BarTemplateOptions = {}
BarTemplateOptions.__index = BarTemplateOptions
BarTemplateOptions.OPTION_NAME = "BarTemplateOptions"
ZxSimpleUI.optionTables[BarTemplateOptions.OPTION_NAME] = BarTemplateOptions

---@param currentModule table
function BarTemplateOptions:__init__(currentModule)
  self.options = {}
  self._currentModule = currentModule
  self._curDbProfile = currentModule.db.profile
  self._coreOptions47 = CoreOptions47:new(self._currentModule)
end

---@param currentModule table
function BarTemplateOptions:new(currentModule)
  assert(currentModule ~= nil)
  assert(currentModule.bars ~= nil, "Remember to initialize a bar template object first!")
  local newInstance = setmetatable({}, self)
  newInstance:__init__(currentModule)
  return newInstance
end

function BarTemplateOptions:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@param optionTable table
function BarTemplateOptions:addOption(optionTable)
  if next(self.options) == nil then self.options = self:getOptionTable() end
  for k, v in pairs(optionTable) do self.options.args[k] = v end
end

---@return table
function BarTemplateOptions:getOptionTable()
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
        width = {
          name = "Bar Width",
          desc = "Bar Width Size",
          type = "range",
          min = 0,
          max = Utils47:floorToEven(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          order = self._coreOptions47:incrementOrderIndex()
        },
        height = {
          name = "Bar Height",
          desc = "Bar Height Size",
          type = "range",
          min = 0,
          max = Utils47:floorToEven(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          order = self._coreOptions47:incrementOrderIndex()
        },
        selfCurrentPoint = {
          name = "Point",
          desc = "Frame's Anchor Point",
          type = "select",
          order = self._coreOptions47:incrementOrderIndex(),
          values = {
            ["TOP"] = "TOP",
            ["RIGHT"] = "RIGHT",
            ["BOTTOM"] = "BOTTOM",
            ["LEFT"] = "LEFT",
            ["TOPRIGHT"] = "TOPRIGHT",
            ["TOPLEFT"] = "TOPLEFT",
            ["BOTTOMLEFT"] = "BOTTOMLEFT",
            ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
            ["CENTER"] = "CENTER"
          }
        },
        relativePoint = {
          name = "Relative Point",
          desc = "Relative Point: Frame to anchor to",
          type = "select",
          order = self._coreOptions47:incrementOrderIndex(),
          values = {
            ["TOP"] = "TOP",
            ["RIGHT"] = "RIGHT",
            ["BOTTOM"] = "BOTTOM",
            ["LEFT"] = "LEFT",
            ["TOPRIGHT"] = "TOPRIGHT",
            ["TOPLEFT"] = "TOPLEFT",
            ["BOTTOMLEFT"] = "BOTTOMLEFT",
            ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
            ["CENTER"] = "CENTER"
          }
        },
        xoffset = {
          name = "Bar X Offset",
          desc = "Bar X Offset",
          type = "range",
          min = -Utils47:floorToEven(ZxSimpleUI.SCREEN_WIDTH / 2),
          max = Utils47:floorToEven(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          order = self._coreOptions47:incrementOrderIndex()
        },
        zeroXOffset = {
          name = "Zero X Offset",
          type = "execute",
          func = function(...)
            self._curDbProfile.xoffset = 0
            self._currentModule:refreshConfig()
          end,
          order = self._coreOptions47:incrementOrderIndex()
        },
        yoffset = {
          name = "Bar Y Offset",
          desc = "Bar Y Offset",
          type = "range",
          min = -Utils47:floorToEven(ZxSimpleUI.SCREEN_HEIGHT / 2),
          max = Utils47:floorToEven(ZxSimpleUI.SCREEN_HEIGHT / 2),
          step = 2,
          order = self._coreOptions47:incrementOrderIndex()
        },
        zeroYOffset = {
          name = "Zero Y Offset",
          type = "execute",
          func = function(...)
            self._curDbProfile.yoffset = 0
            self._currentModule:refreshConfig()
          end,
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
