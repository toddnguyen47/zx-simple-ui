---Interface class. All modules should have the following functions:
local InterfaceModule = {}

function InterfaceModule:OnInitialization() end
function InterfaceModule:OnEnable() end
function InterfaceModule:OnDisable() end
function InterfaceModule:createBar() end
function InterfaceModule:refreshConfig() end
function InterfaceModule:handleOnEnable() end
function InterfaceModule:handleOnDisable() end
