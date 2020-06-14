local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local ToggleDropDownMenu, PlayerFrameDropDown = ToggleDropDownMenu, PlayerFrameDropDown
local TargetFrameDropDown, PetFrameDropDown = TargetFrameDropDown, PetFrameDropDown
local RegisterUnitWatch = RegisterUnitWatch

local RegisterWatchHandler47 = {}
ZxSimpleUI.RegisterWatchHandler47 = RegisterWatchHandler47

local FRAME_DROPDOWN_LIST = {
  player = PlayerFrameDropDown,
  target = TargetFrameDropDown,
  pet = PetFrameDropDown
}

---@param curFrame table
---@param unit string
function RegisterWatchHandler47:setRegisterForWatch(curFrame, unit)
  curFrame.unit = unit
  curFrame:SetAttribute("unit", curFrame.unit)
  -- Set this so Blizzard's internal engine can find `unit`
  -- Also help RegisterUnitWatch
  -- Handle right click
  curFrame.menu =
    function() ToggleDropDownMenu(1, nil, FRAME_DROPDOWN_LIST[unit], "cursor") end

  ZxSimpleUI:enableTooltip(curFrame)
  RegisterUnitWatch(curFrame, ZxSimpleUI:getUnitWatchState(curFrame.unit))
end

function RegisterWatchHandler47:printFrames()
  local sortedList = {}
  for k, _ in pairs(_G) do if k:find("FrameDropDown$") then table.insert(sortedList, k) end end
  table.sort(sortedList)
  for _, key in ipairs(sortedList) do print(key) end
end
