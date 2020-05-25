local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local ToggleDropDownMenu, PlayerFrameDropDown = ToggleDropDownMenu, PlayerFrameDropDown
local RegisterUnitWatch = RegisterUnitWatch

local RegisterWatchHandler47 = {}
ZxSimpleUI.RegisterWatchHandler47 = RegisterWatchHandler47

---@param curFrame table
---@param unit string
function RegisterWatchHandler47:setRegisterForWatch(curFrame, unit)
  curFrame.unit = unit
  curFrame:SetAttribute("unit", curFrame.unit)
  -- Set this so Blizzard's internal engine can find `unit`
  -- Also help RegisterUnitWatch
  -- Handle right click
  curFrame.menu = function() ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor") end

  ZxSimpleUI:enableTooltip(curFrame)
  RegisterUnitWatch(curFrame, ZxSimpleUI:getUnitWatchState(curFrame.unit))
end
