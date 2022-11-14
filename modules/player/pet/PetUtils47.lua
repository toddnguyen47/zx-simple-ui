local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
---@class PetUtils47
local PetUtils47 = {}
PetUtils47.__index = PetUtils47
ZxSimpleUI.PetUtils47 = PetUtils47

function PetUtils47:DoesUnitExist(unit)
  local exist = UnitExists(unit)
  return tonumber(exist) == 1
end
