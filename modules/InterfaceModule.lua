---Interface class. All modules should have the following functions:
local InterfaceModule = {}

function InterfaceModule:__init__() end
function InterfaceModule:new() end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function InterfaceModule:OnInitialize() end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function InterfaceModule:OnEnable() end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function InterfaceModule:OnDisable() end

-- For Frames that gets hidden often (e.g. Target frames)
---@param curFrame table
---Handle Blizzard's OnShow event
function InterfaceModule:OnShowBlizz(curFrame, ...) end
---@param curFrame table
---Handle Blizzard's OnHide event
function InterfaceModule:OnHideBlizz(curFrame, ...) end

function InterfaceModule:createBar() end
function InterfaceModule:refreshConfig() end
function InterfaceModule:handleEnableToggle() end

function InterfaceModule:handleShownOption() end
function InterfaceModule:handleShownHideOption() end
function InterfaceModule:getExtraOptions() end

function InterfaceModule:_refreshAll() end
function InterfaceModule:_registerAllEvents() end
function InterfaceModule:_unregisterAllEvents() end
