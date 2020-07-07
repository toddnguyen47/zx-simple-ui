local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")

local Combo47Options = {}
Combo47Options.__index = Combo47Options
Combo47Options.OPTION_NAME = "Combo47Options"
ZxSimpleUI.optionTables[Combo47Options.OPTION_NAME] = Combo47Options

---@param coreOptions47 table
function Combo47Options:__init__(coreOptions47)
  self.options = {}
  self._coreOptions47 = coreOptions47
  self._currentModule = self._coreOptions47:getCurrentModule()
end

function Combo47Options:new(...)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(...)
  return newInstance
end

function Combo47Options:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@return table
function Combo47Options:getOptionTable()
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
          disabled = function(info) return self._currentModule.db.profile.showbar end,
          width = "full"
        },
        showbar = {
          type = "toggle",
          name = "Show Display",
          desc = "Show/Hide the Combo Points Display",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 2,
          disabled = function(info)
            return not self._currentModule.db.profile.enabledToggle
          end,
          get = function(info) return self._coreOptions47:getShownOption(info) end,
          set = function(info, value) self._coreOptions47:setShownOption(info, value) end
        },
        backgroundColor = {
          name = "Background Color",
          desc = "Background Color for the Combo Frame",
          order = self._coreOptions47:incrementOrderIndex(),
          type = "color",
          hasAlpha = true,
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        height = {
          name = "Combo Height",
          desc = "Combo display height",
          type = "range",
          min = 2,
          max = 20,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        horizGap = {
          name = "Horizontal Gap",
          desc = "Horizontal Gap between each combo point bar",
          type = "range",
          min = 0,
          max = 30,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        setpoint = {
          name = "Setpoints",
          type = "group",
          inline = true,
          order = self._coreOptions47:incrementOrderIndex(),
          args = {
            framePool = {
              type = "select",
              name = "Frame Pool",
              values = function(info)
                local t1 = {}
                for k, v in pairs(ZxSimpleUI.frameList) do
                  if k ~= self._currentModule.MODULE_NAME then
                    t1[k] = v["name"]
                  end
                end
                return t1
              end,
              order = 10
            },
            selfCurrentPoint = {
              name = "Point",
              desc = "Frame's Anchor Point",
              type = "select",
              order = 11,
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
              order = 12,
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
            }
          }
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
        colorHeader = {
          name = "Colors",
          type = "header",
          order = self._coreOptions47:incrementOrderIndex()
        },
        mediumComboPoints = {
          name = "Medium Combo Points",
          desc = "For combo points > 0 and < " .. MAX_COMBO_POINTS .. ". Set to 0 to disable.",
          type = "range",
          min = 0,
          max = MAX_COMBO_POINTS - 1,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        lowComboColor = {
          name = "Low Combo Color",
          desc = "Color for low (below medium setpoint) combo points",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        },
        medComboColor = {
          name = "Medium Combo Color",
          desc = "Color for medium combo points (greater than or equal to " ..
            "Medium Combo Points, but less than MAX)",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        },
        maxComboColor = {
          name = "Max Combo Color",
          desc = "Color for MAX combo points",
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
