---Upvalues
local LibStub, ChatFrame1 = LibStub, ChatFrame1
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local UIParent = UIParent

UIParent.DECORATIVE_NAME = "UIParent"

-- AddOn Declaration
local ADDON_NAME = "ZxSimpleUI"
---@class ZxSimpleUI
local ZxSimpleUI = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0")

---LibSharedMedia registers
local media = LibStub("LibSharedMedia-3.0")
-- #region
local basePath = "Interface\\AddOns\\ZxSimpleUI\\media\\"
media:Register("font", "Lato", basePath .. "fonts\\Lato\\Lato-Regular.ttf")
media:Register("font", "Lato Bold", basePath .. "fonts\\Lato\\Lato-Bold.ttf")
media:Register("font", "PT Sans", basePath .. "fonts\\PT_Sans\\PTSans-Regular.ttf")
media:Register("font", "PT Sans Bold", basePath .. "fonts\\PT_Sans\\PTSans-Bold.ttf")

media:Register("statusbar", "Skewed", basePath .. "textures\\Skewed.tga")
media:Register("statusbar", "Smooth", basePath .. "textures\\Smooth.tga")
media:Register("statusbar", "White", basePath .. "textures\\White.tga")
media:Register("statusbar", "Gray", basePath .. "textures\\Gray.tga")
media:Register("statusbar", "GrayVertGradient", basePath .. "textures\\GrayVertGradient.tga")
media:Register("statusbar", "GrayDiagonals", basePath .. "textures\\GrayDiagonals.tga")
-- #endregion

--- All this below is needed!
ZxSimpleUI.ADDON_NAME = ADDON_NAME
ZxSimpleUI.DECORATIVE_NAME = "Zx Simple UI"
ZxSimpleUI.SLASH_COMMANDS = {"zxsimpleui", "zxsui"}
ZxSimpleUI.moduleOptionsTable = {}
ZxSimpleUI.moduleKeySorted = {}
ZxSimpleUI.blizOptionTable = {}
ZxSimpleUI.optionTables = {}
ZxSimpleUI.prereqTables = {}
ZxSimpleUI.frameList = {["UIParent"] = {frame = UIParent, name = "UIParent"}}
ZxSimpleUI.db = nil
ZxSimpleUI.DEFAULT_FRAME_LEVEL = 15 -- maximum number with 4 bits
ZxSimpleUI.DEFAULT_ORDER_INDEX = 7
ZxSimpleUI.HEADER_ORDER_INDEX = 1
local _defaults = {profile = {["modules"] = {["*"] = {["enabled"] = true}}}}
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

---@param module string
function ZxSimpleUI:getModuleEnabledState(module)
  ---return statement
  return self.db.profile["modules"][module]["enabled"]
end

---@param moduleName string
---@param isEnabled boolean
function ZxSimpleUI:setModuleEnabledState(moduleName, isEnabled)
  local oldEnabledValue = self.db.profile["modules"][moduleName]["enabled"]
  self.db.profile["modules"][moduleName]["enabled"] = isEnabled

  if oldEnabledValue ~= isEnabled then
    if isEnabled then
      self:EnableModule(moduleName)
    else
      self:DisableModule(moduleName)
    end
  end
end

---@param currentValue number
---@param maxValue number
---@return number
function ZxSimpleUI:calcPercentSafely(currentValue, maxValue)
  if (maxValue == 0.0) then return 0.0 end
  return currentValue / maxValue
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

---@param moduleName string
---@param tableValues table
function ZxSimpleUI:addToFrameList(moduleName, tableValues)
  for k, v in pairs(tableValues) do
    if self.frameList[moduleName] == nil then self.frameList[moduleName] = {} end
    self.frameList[moduleName][k] = v
  end
end

---@param moduleName string
---@return table
function ZxSimpleUI:getFrameListFrame(moduleName)
  if self.frameList[moduleName] == nil or self.frameList[moduleName]["frame"] == nil then
    return self.frameList["UIParent"]["frame"]
  end
  return self.frameList[moduleName]["frame"]
end
