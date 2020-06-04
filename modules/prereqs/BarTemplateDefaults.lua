local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47

local BarTemplateDefaults = {}
BarTemplateDefaults.__index = BarTemplateDefaults
ZxSimpleUI.BarTemplateDefaults = BarTemplateDefaults
ZxSimpleUI.prereqTables["BarTemplateDefaults"] = BarTemplateDefaults

function BarTemplateDefaults:__init__()
  self.defaults = {
    profile = {
      width = 200,
      height = 26,
      xoffset = 400,
      yoffset = 280,
      fontsize = 16,
      font = "PT Sans Bold",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "Skewed",
      color = {0.0, 1.0, 0.0, 1.0},
      border = "None",
      selfCurrentPoint = "BOTTOMLEFT",
      relativePoint = "BOTTOMLEFT",
      framePool = "UIParent"
    }
  }
end

function BarTemplateDefaults:new()
  local newInstance = setmetatable({}, self)
  newInstance:__init__()
  return newInstance
end
