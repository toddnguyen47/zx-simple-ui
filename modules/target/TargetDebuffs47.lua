-- upvalues
local LibStub = LibStub

-- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)
---@type Aura47
local Aura47 = ZxSimpleUI.prereqTables["Aura47"]
local playerAura = Aura47:new()

-- #region
local MODULE_NAME = "TargetDebuffs47"
local DECORATIVE_NAME = Locale["module.decName.targetDebuffs"]
---@class TargetDebuffs47 : Aura47
local TargetDebuffs47 = ZxSimpleUI:NewModule(MODULE_NAME, playerAura)

TargetDebuffs47.MODULE_NAME = MODULE_NAME
TargetDebuffs47.DECORATIVE_NAME = DECORATIVE_NAME
-- #endregion

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function TargetDebuffs47:OnInitialize()
  playerAura.OnInitialize(self)
  self:setUnit("target")
  self:setIsUnitDebuff(true)
  self:addFilter(playerAura.FILTERS.PLAYER)
  self:setCasterSource("player")
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function TargetDebuffs47:OnEnable()
  playerAura.OnEnable(self)
  self:handleUnitAura(self.unit)
  self.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function TargetDebuffs47:OnDisable() playerAura.OnDisable(self) end

function TargetDebuffs47:handleOnEvent(curFrame, event, arg1, arg2, ...)
  playerAura.handleOnEvent(self, curFrame, event, arg1, arg2, ...)
  if string.upper(event) == "PLAYER_TARGET_CHANGED" then self:handleUnitAura(self.unit) end
end
