local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local ToggleDropDownMenu, PlayerFrameDropDown = ToggleDropDownMenu, PlayerFrameDropDown
local TargetFrameDropDown, PetFrameDropDown = TargetFrameDropDown, PetFrameDropDown
local RegisterUnitWatch, UnregisterUnitWatch = RegisterUnitWatch, UnregisterUnitWatch

---@class RegisterWatchHandler47
local RegisterWatchHandler47 = {}
ZxSimpleUI.prereqTables["RegisterWatchHandler47"] = RegisterWatchHandler47

local FRAME_DROPDOWN_LIST = {
  player = PlayerFrameDropDown,
  target = TargetFrameDropDown,
  pet = PetFrameDropDown
}

---@param curFrame table
---@param unit string
function RegisterWatchHandler47:setRegisterForWatch(curFrame, unit)
  curFrame = self:_setCurFrameUnit(curFrame, unit)
  -- Handle right click
  curFrame.openRightClickMenu = function()
    if FRAME_DROPDOWN_LIST[unit] ~= nil then
      ToggleDropDownMenu(1, nil, FRAME_DROPDOWN_LIST[unit], "cursor")
    end
  end

  ZxSimpleUI:enableTooltip(curFrame)
  RegisterUnitWatch(curFrame, self:getUnitWatchState(curFrame.unit))
end

---@param curFrame table
---@param unit string
function RegisterWatchHandler47:setUnregisterForWatch(curFrame, unit)
  curFrame = self:_setCurFrameUnit(curFrame, unit)
  UnregisterUnitWatch(curFrame, self:getUnitWatchState(curFrame.unit))
end

---@return table
function RegisterWatchHandler47:getListOfFrameDropDowns()
  local sortedList = {}
  for k, _ in pairs(_G) do if k:find("FrameDropDown$") then table.insert(sortedList, k) end end
  table.sort(sortedList)
  return sortedList
end

---@param unit string
---@return boolean
---Ref: https://wowwiki.fandom.com/wiki/SecureStateDriver
function RegisterWatchHandler47:getUnitWatchState(unit) return string.lower(unit) == "pet" end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param curFrame table
---@param unit string
---@return table
---Set `unit` parameter so Blizzard's internal engine can find `unit`
---Also help RegisterUnitWatch
function RegisterWatchHandler47:_setCurFrameUnit(curFrame, unit)
  curFrame.unit = unit
  curFrame:SetAttribute("unit", curFrame.unit)
  return curFrame
end
