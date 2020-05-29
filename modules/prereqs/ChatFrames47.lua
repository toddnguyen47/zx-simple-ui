local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreOptions47 = ZxSimpleUI["optionTables"]["CoreOptions47"]
local media = LibStub("LibSharedMedia-3.0")

local _MODULE_NAME = "ChatFrames47"
local _DECORATIVE_NAME = "Chat Frame"
local ChatFrames47 = ZxSimpleUI:NewModule(_MODULE_NAME)
ChatFrames47.MODULE_NAME = _MODULE_NAME
ChatFrames47.DECORATIVE_NAME = _DECORATIVE_NAME
ChatFrames47.MAX_CHATFRAMES = 10
ChatFrames47.FACTORY_DEFAULT_FONT = "Arial Narrow"
ChatFrames47.KEY_SUFFIXES = {"", "EditBox", "EditBoxHeader"}

local _defaults = {profile = {enabledToggle = true, font = "Friz Quadrata TT"}}

function ChatFrames47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile

  self:__init__()

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(self.MODULE_NAME, self:getOptionTable(),
    self.DECORATIVE_NAME)
end

function ChatFrames47:__init__()
  self.option = {}

  self._coreOptions47 = CoreOptions47:new(self)
end

function ChatFrames47:OnEnable() self:handleOnEnable() end
function ChatFrames47:OnDisable() self:handleOnDisable() end

function ChatFrames47:handleOnEnable() self:refreshConfig() end

function ChatFrames47:handleOnDisable() self:_resetFactoryDefaultFonts() end

function ChatFrames47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self:_refreshAll() end
end

function ChatFrames47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, self._curDbProfile.enabledToggle)
end

function ChatFrames47:printGlobalChatFrameKeys()
  local sortedTable = {}
  for k, v in pairs(_G) do
    if k:find("ChatFrame%d+") then
      if type(v.GetFont) == "function" then
        local index = tonumber(k:match("%d+"))
        if sortedTable[index] == nil then sortedTable[index] = {} end
        table.insert(sortedTable[index], k)
      end
    end
  end

  for _, tableOfKeys in pairs(sortedTable) do
    table.sort(tableOfKeys)
    for _, globalKey in pairs(tableOfKeys) do
      local globalValue = _G[globalKey]:GetFont()
      globalValue = globalValue:gsub("\\", "/")
      globalValue = globalValue:match(".*/(%S+)")
      ZxSimpleUI:Print(string.format("Key: [%s], Value: [%s]", globalKey, globalValue))
    end
  end
end

---@return table
function ChatFrames47:getOptionTable()
  if next(self.option) == nil then
    self.option = {
      type = "group",
      name = self.DECORATIVE_NAME,
      --- "Parent" get/set
      get = function(info) return self._coreOptions47:getOption(info) end,
      set = function(info, value) self._coreOptions47:setOption(info, value) end,
      args = {
        header = {
          type = "header",
          name = self.DECORATIVE_NAME,
          order = ZxSimpleUI.HEADER_ORDER_INDEX
        },
        enabledToggle = {
          type = "toggle",
          name = "Enable",
          desc = "Enable / Disable this module",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 1
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Bar Font",
          desc = "Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        printButton = {
          name = "Print Keys",
          desc = "Print the ChatFrame keys in the _G global table",
          type = "execute",
          func = function(info) self:printGlobalChatFrameKeys() end
        }
      }
    }
  end
  return self.option
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function ChatFrames47:_refreshAll() self:_setChatFrameFonts() end

function ChatFrames47:_setChatFrameFonts()
  for i = 1, self.MAX_CHATFRAMES do
    local str1 = "ChatFrame" .. i
    for _, key in ipairs(self.KEY_SUFFIXES) do
      local k1 = str1 .. key
      _G[k1]:SetFont(media:Fetch("font", self._curDbProfile.font), 14, "")
    end
  end
end

function ChatFrames47:_resetFactoryDefaultFonts()
  for i = 1, self.MAX_CHATFRAMES do
    local str1 = "ChatFrame" .. i
    for _, key in ipairs(self.KEY_SUFFIXES) do
      local k1 = str1 .. key
      _G[key]:SetFont(media:Fetch("font", self.FACTORY_DEFAULT_FONT), 14, "")
    end
  end
end
