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
      positionx = 400,
      positiony = 280,
      fontsize = 14,
      font = "Friz Quadrata TT",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "Blizzard",
      color = {0.0, 1.0, 0.0, 1.0},
      border = "None",
      selfCurrentPoint = "BOTTOMLEFT",
      relativePoint = "BOTTOMLEFT"
    }
  }
end

function BarTemplateDefaults:new()
  local newInstance = setmetatable({}, self)
  newInstance:__init__()
  return newInstance
end
