local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local CoreOptionsInterface = ZxSimpleUI:NewModule("Options", nil)

-- PRIVATE functions and variables
---@param key string
local _curDbProfile, _openOptionFrame, _getSlashCommandsString
local _getOpenOptionTable, _getOptionTable, _addModuleOptionTables
local _OPEN_OPTION_APPNAME = "ZxSimpleGUI_OpenOption"

function CoreOptionsInterface:OnInitialize()
  _curDbProfile = ZxSimpleUI.db.profile
  self:SetupOptions()
end

function CoreOptionsInterface:SetupOptions()
  ZxSimpleUI.blizOptionTable = {}
  AceConfigRegistry:RegisterOptionsTable(_OPEN_OPTION_APPNAME, _getOpenOptionTable)
  AceConfigRegistry:RegisterOptionsTable(ZxSimpleUI.ADDON_NAME, _getOptionTable)

  local frameRef = AceConfigDialog:AddToBlizOptions(_OPEN_OPTION_APPNAME,
                     ZxSimpleUI.DECORATIVE_NAME)
  ZxSimpleUI.blizOptionTable[ZxSimpleUI.ADDON_NAME] = frameRef
  -- Register slash commands as well
  for _, command in pairs(ZxSimpleUI.SLASH_COMMANDS) do
    ZxSimpleUI:RegisterChatCommand(command, _openOptionFrame)
  end

  -- Set profile options
  ZxSimpleUI:registerModuleOptions("Profiles", AceDBOptions:GetOptionsTable(ZxSimpleUI.db),
    "Profiles")
end

-- ########################################
-- # "PRIVATE" functions
-- ########################################

local _openOptionTable = {}
local _frame = nil

---@return table
function _getOpenOptionTable()
  if next(_openOptionTable) == nil then
    _openOptionTable = {
      type = "group",
      args = {
        openoptions = {name = "Open Options", type = "execute", func = _openOptionFrame},
        descriptionParagraph = {
          name = _getSlashCommandsString(),
          type = "description",
          fontSize = "medium"
        }
      }
    }
  end

  return _openOptionTable
end

function _getSlashCommandsString()
  local s1 = "You can also open the options frame with one of these commands:\n"
  for _, command in pairs(ZxSimpleUI.SLASH_COMMANDS) do s1 = s1 .. "    /" .. command .. "\n" end
  s1 = string.sub(s1, 0, string.len(s1) - 1)
  return s1
end

function _openOptionFrame(info, value, ...)
  if not _frame then
    _frame = AceGUI:Create("Frame")
    _frame:SetCallback("OnClose", function(widget)
      AceGUI:Release(widget)
    end)
    _frame:SetTitle(ZxSimpleUI.DECORATIVE_NAME)
  end
  AceConfigDialog:Open(ZxSimpleUI.ADDON_NAME, _frame)
end

local option = {}
function _getOptionTable()
  if next(option) == nil then
    option = {type = "group", args = {}}
    _addModuleOptionTables()
  end
  return option
end

function _addModuleOptionTables()
  local defaultOrderIndex = 7
  for moduleAppName, optionTableOrFunc in pairs(ZxSimpleUI.moduleOptionsTable) do
    if type(optionTableOrFunc) == "function" then
      option.args[moduleAppName] = optionTableOrFunc()
    else
      option.args[moduleAppName] = optionTableOrFunc
    end
    -- Make sure "Profiles" is the first option
    if moduleAppName == "Profiles" then
      option.args[moduleAppName]["order"] = 1
    else
      option.args[moduleAppName]["order"] = defaultOrderIndex
      defaultOrderIndex = defaultOrderIndex + 1
    end
  end
end
