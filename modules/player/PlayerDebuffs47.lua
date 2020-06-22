-- upvalues
local LibStub = LibStub

-- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
---@type Aura47
local Aura47 = ZxSimpleUI.prereqTables["Aura47"]
local playerAura = Aura47:new()

-- #region
local MODULE_NAME = "PlayerDebuffs47"
local DECORATIVE_NAME = "Player Debuffs"
---@class PlayerDebuffs47 : Aura47
local PlayerDebuffs47 = ZxSimpleUI:NewModule(MODULE_NAME, playerAura)

PlayerDebuffs47.MODULE_NAME = MODULE_NAME
PlayerDebuffs47.DECORATIVE_NAME = DECORATIVE_NAME
-- #endregion

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function PlayerDebuffs47:OnInitialize()
  playerAura.OnInitialize(self)
  self:setUnit("player")
  self:addFilter(playerAura.FILTERS.HARMFUL)
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function PlayerDebuffs47:OnEnable()
  playerAura.OnEnable(self)
  self:handleUnitAura(self.unit)
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function PlayerDebuffs47:OnDisable() playerAura.OnDisable(self) end
