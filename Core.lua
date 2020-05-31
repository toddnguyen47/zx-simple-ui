---Upvalues
local LibStub, ChatFrame1 = LibStub, ChatFrame1
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave

--- AddOn Declaration
local ADDON_NAME = "ZxSimpleUI"
local ZxSimpleUI = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0")

---LibSharedMedia registers
local media = LibStub("LibSharedMedia-3.0")
media:Register("font", "PT Sans Bold", "Interface\\AddOns\\ZxSimpleUI\\fonts\\PTSansBold.ttf")

--- All this below is needed!
ZxSimpleUI.ADDON_NAME = ADDON_NAME
ZxSimpleUI.DECORATIVE_NAME = "Zx Simple UI"
ZxSimpleUI.SLASH_COMMANDS = {"zxsimpleui", "zxsui"}
ZxSimpleUI.moduleOptionsTable = {}
ZxSimpleUI.moduleKeySorted = {}
ZxSimpleUI.blizOptionTable = {}
ZxSimpleUI.optionTables = {}
ZxSimpleUI.db = nil
ZxSimpleUI.DEFAULT_FRAME_LEVEL = 15 -- maximum number with 4 bits
ZxSimpleUI.DEFAULT_ORDER_INDEX = 7
ZxSimpleUI.HEADER_ORDER_INDEX = 1
local _defaults = {
  profile = {
    ["modules"] = {
      ["*"] = {["enabled"] = true}
    }
  }
}
--- End

--- Extra CONSTANTS
ZxSimpleUI.SCREEN_WIDTH = math.floor(GetScreenWidth())
ZxSimpleUI.SCREEN_HEIGHT = math.floor(GetScreenHeight())

-- if 60 FPS, then 1 frame will be refreshed in 16.67 milliseconds.
local refreshEveryNFrame = 10
ZxSimpleUI.UPDATE_INTERVAL_SECONDS = 16 * refreshEveryNFrame / 1000.0

function ZxSimpleUI:OnInitialize()
  ---Must initialize db AFTER SavedVariables is loaded!
  local dbName = self.ADDON_NAME .. "_DB" -- defined in .toc file, in ## SavedVariables
  self.db = LibStub("AceDB-3.0"):New(dbName, _defaults, true)

  self:Print(ChatFrame1, "YO")
end

function ZxSimpleUI:OnEnable()
  self.db.RegisterCallback(self, "OnProfileChanged", "refreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "refreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "refreshConfig")
end

---Refresh the configuration for this AddOn as well as any modules
---that are added to this AddOn
function ZxSimpleUI:refreshConfig()
  for k, curModule in ZxSimpleUI:IterateModules() do
    if ZxSimpleUI:getModuleEnabledState(k) and not curModule:IsEnabled() then
      ZxSimpleUI:EnableModule(k)
    elseif not ZxSimpleUI:getModuleEnabledState(k) and curModule:IsEnabled() then
      ZxSimpleUI:DisableModule(k)
    end

    --- Refresh every module connected to this AddOn
    if type(curModule.refreshConfig) == "function" then curModule:refreshConfig() end
  end
end

---@param name string
---@param optTable table
---@param displayName string
function ZxSimpleUI:registerModuleOptions(name, optTable, displayName)
  self.moduleOptionsTable[name] = optTable
  table.insert(self.moduleKeySorted, name)
end

---@param currentValue number
---@param maxValue number
---@return number
function ZxSimpleUI:calcPercentSafely(currentValue, maxValue)
  if (maxValue == 0.0) then return 0.0 end
  return currentValue / maxValue
end

---@param module string
function ZxSimpleUI:getModuleEnabledState(module)
  ---return statement
  return self.db.profile["modules"][module]["enabled"]
end

---@param module string
---@param isEnabled boolean
function ZxSimpleUI:setModuleEnabledState(module, isEnabled)
  local oldEnabledValue = self.db.profile["modules"][module]["enabled"]
  self.db.profile["modules"][module]["enabled"] = isEnabled
  if oldEnabledValue ~= isEnabled then
    if isEnabled then
      self:EnableModule(module)
    else
      self:DisableModule(module)
    end
  end
end

---@param currentFrame table
function ZxSimpleUI:enableTooltip(currentFrame)
  currentFrame:SetScript("OnEnter", UnitFrame_OnEnter)
  currentFrame:SetScript("OnLeave", UnitFrame_OnLeave)
end

---@param unit string
---@return boolean
---Ref: https://wowwiki.fandom.com/wiki/SecureStateDriver
function ZxSimpleUI:getUnitWatchState(unit) return string.lower(unit) == "pet" end
