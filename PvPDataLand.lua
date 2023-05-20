-- Define the addon name and version
local addonName = "PvPDataLand"
local addonVersion = "1.0"

-- Create a GUI frame using AceGUI
local AceGUI = LibStub("AceGUI-3.0")
local frame = AceGUI:Create("Frame")
frame:SetTitle(addonName .. " v" .. addonVersion)
frame:SetStatusText("")
frame:SetLayout("Flow")
frame:Hide() -- hide the frame by default

-- Create a dropdown menu to select the game mode
local modeDropdown = AceGUI:Create("Dropdown")
modeDropdown:SetLabel("Select game mode:")
modeDropdown:SetList({"2v2", "3v3", "SS", "RBG"})
modeDropdown:SetValue(1) -- default to 2v2
modeDropdown:SetCallback("OnValueChanged", function(widget, event, key) -- update the data when the mode changes
  local mode = widget:GetList()[key] -- get the mode name from the key
  local data = {} -- replace this with your data source for PvP data
  updateGUI(data) -- update the GUI with the new data
end)
frame:AddChild(modeDropdown)

-- Create a label to display the data
local dataLabel = AceGUI:Create("Label")
dataLabel:SetFullWidth(true)
dataLabel:SetText("")
frame:AddChild(dataLabel)

-- Define a function to update the GUI with the data
local function updateGUI(data)
  -- Format the data as a string
  local text = string.format(
    "Wins: %d\nLosses: %d\nWin rate: %.2f%%\nRating: %d\nHighest rating: %d\n",
    data.wins,
    data.losses,
    data.winRate,
    data.rating,
    data.highestRating
  )
  -- Set the text of the label
  dataLabel:SetText(text)
end

-- Load the AceConfig library
local AceConfig = LibStub("AceConfig-3.0")

-- Define a table for slash command options using AceConfig syntax
local options = {
  name = addonName,
  handler = PvPDataLand,
  type = "group",
  args = {
    toggle = {
      type = "execute",
      name = "Toggle",
      desc = "Toggle the GUI frame",
      func = function()
        if frame:IsVisible() then
          frame:Hide()
        else
          frame:Show()
        end
      end,
    },
  },
}

-- Register the slash command options with AceConfig
AceConfig:RegisterOptionsTable(addonName, options)

-- Register a chat command to toggle the GUI frame using AceConfig slash command handler
SLASH_PVPDATALAND1 = "/pvpdataland"
SLASH_PVPDATALAND2 = "/pdl"
SlashCmdList["PVPDATALAND"] = AceConfig.slashCommandHandler

-- Define a function to initialize the addon
local function initialize()
  -- Register the addon name and version with DataStore
  -- DataStore:RegisterModule(addonName, addonVersion) -- Uncomment this if required
  
  -- Print a welcome message in chat
  print(addonName .. " v" .. addonVersion .. " loaded. Type /pvpdataland or /pdl to toggle the GUI.")
end

-- Define an event handler function for loading events
local function eventHandler(self, event, ...)
  if event == "ADDON_LOADED" then -- when an addon is loaded
    local name = ... -- get the addon name
    if name == addonName then -- if it is this addon
      initialize() -- initialize it
      self:UnregisterEvent(event) -- unregister this event handler
    end
  -- elseif event == "PLAYER_LOGIN" or event == "REFLEX_LOADED" then -- Uncomment this if required
  --   local thisChar = UnitName("player") .. " - " .. GetRealmName() -- get the current character key
  --   local pvpData = REFlexDataExtractor:GetPvPData(thisChar) -- get the data from REFlex for this character
  --   updateGUI(pvpData) -- update the GUI with the data
  end
end

-- Create an event frame to handle loading events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED") -- register for loading events
-- eventFrame:RegisterEvent("PLAYER_LOGIN") -- Uncomment this if required
-- eventFrame:RegisterEvent("REFLEX_LOADED") -- Uncomment this if required
eventFrame:SetScript("OnEvent", eventHandler) -- set the event handler function
