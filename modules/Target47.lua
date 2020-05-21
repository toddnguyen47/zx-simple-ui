local media = LibStub("LibSharedMedia-3.0")
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47
local TargetHealth47 = ZxSimpleUI:GetModule("TargetHealth47")
local TargetPower47 = ZxSimpleUI:GetModule("TargetPower47")
local TargetName47 = ZxSimpleUI:GetModule("TargetName47")
local Combo47 = ZxSimpleUI:GetModule("Combo47")

-- Upvalues
local ToggleDropDownMenu, TargetFrameDropDown = ToggleDropDownMenu, TargetFrameDropDown
local RegisterUnitWatch, UnitName = RegisterUnitWatch, UnitName

local _MODULE_NAME = "Target47"
local _DECORATIVE_NAME = "Target"
local Target47 = ZxSimpleUI:NewModule(_MODULE_NAME)
Target47.unit = "target"

function Target47:OnInitialize()
  self:__init__()
end

function Target47:OnEnable()
  self:_createBars()
  self:_setRegisterForWatch()
end

function Target47:__init__()
  self._barLists = {}
  self._ignoreSet = {}
end

function Target47:refreshConfig()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
function Target47:_createBars()
  self._barLists["TargetHealth47"] = TargetHealth47:createBar()
  self._barLists["TargetPower47"] = TargetPower47:createBar()
  self._barLists["TargetName47"] = TargetName47:createBar()
  self._barLists["Combo47"] = Combo47:createBar(self._barLists["TargetHealth47"])

  self._ignoreSet["Combo47"] = true
end

function Target47:_setRegisterForWatch()
  for key, targetFrame in pairs(self._barLists) do
    if not Utils47:setContains(self._ignoreSet, key) then
      -- Set this so Blizzard's internal engine can find `unit`
      -- Also help RegisterUnitWatch
      targetFrame.unit = self.unit
      targetFrame:SetAttribute("unit", targetFrame.unit)
      -- Handle right click
      targetFrame.menu = function()
        ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
      end

      ZxSimpleUI:enableTooltip(targetFrame)
      -- Use UnitWatch instead of SetScript("OnClick", func)
      RegisterUnitWatch(targetFrame, ZxSimpleUI:getUnitWatchState(targetFrame.unit))
    end
  end
end
