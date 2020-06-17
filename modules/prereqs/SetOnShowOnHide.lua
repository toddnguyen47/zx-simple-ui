local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local SetOnShowOnHide = {}
ZxSimpleUI.prereqTables["SetOnShowOnHide"] = SetOnShowOnHide

---@param curModule table
function SetOnShowOnHide:setHandlerScripts(curModule)
  curModule.mainFrame:SetScript("OnShow", function(curFrame, ...)
    if type(curModule.OnShowBlizz == "function") then curModule:OnShowBlizz(curFrame, ...) end
  end)

  curModule.mainFrame:SetScript("OnHide", function(curFrame, ...)
    if type(curModule.OnHideBlizz) == "function" then curModule:OnHideBlizz(curFrame, ...) end
  end)
end
