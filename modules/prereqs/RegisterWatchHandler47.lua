local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local UnitIsUnit, UnitPopupMenus = UnitIsUnit, UnitPopupMenus
local ToggleDropDownMenu, PlayerFrameDropDown = ToggleDropDownMenu, PlayerFrameDropDown
local TargetFrameDropDown, PetFrameDropDown = TargetFrameDropDown, PetFrameDropDown
local RegisterUnitWatch, UnregisterUnitWatch = RegisterUnitWatch, UnregisterUnitWatch

---@class RegisterWatchHandler47
local RegisterWatchHandler47 = {}
RegisterWatchHandler47.__index = RegisterWatchHandler47
ZxSimpleUI.prereqTables["RegisterWatchHandler47"] = RegisterWatchHandler47

RegisterWatchHandler47._areFocusOptionsRemoved = false
RegisterWatchHandler47._popupMenuList = {}

---@param curFrame table
---@param unit string
function RegisterWatchHandler47:setRegisterForWatch(curFrame, unit)
  curFrame = self:_setCurFrameUnit(curFrame, unit)
  self:_removeSetFocusFromPopups()
  -- Handle right click
  curFrame.openRightClickMenu = function() self:_handleToggleDropdownMenu(unit) end

  ZxSimpleUI:enableTooltip(curFrame)
  RegisterUnitWatch(curFrame, self:getUnitWatchState(curFrame.unit))
end

---@param curFrame table
---@param unit string
function RegisterWatchHandler47:setUnregisterForWatch(curFrame, unit)
  curFrame = self:_setCurFrameUnit(curFrame, unit)
  self:_addSetFocusFromPopups()
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

---@param unit string
function RegisterWatchHandler47:_handleToggleDropdownMenu(unit)
  if UnitIsUnit(unit, "player") then
    ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
  elseif unit == "pet" then
    ToggleDropDownMenu(1, nil, PetFrameDropDown, "cursor")
  elseif unit == "target" then
    ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
  end
end

---Remove "Set Focus", "Clear Focus", etc, so that our AddOn will not get tainted
function RegisterWatchHandler47:_removeSetFocusFromPopups()
  if not self._areFocusOptionsRemoved then
    self._areFocusOptionsRemoved = true
    ZxSimpleUI:Print(
      "If you want to focus a target, please make macros and use `/focus` or " ..
        "`/clearfocus`")
    for key, inputList in pairs(UnitPopupMenus) do
      if key ~= "RAID" and key ~= "FOCUS" then
        for index, value in ipairs(inputList) do
          if value:find("FOCUS") or value:find("focus") then
            table.remove(inputList, index)
          end
        end
      end
    end
  end
end

function RegisterWatchHandler47:_addSetFocusFromPopups() end
