-- PvPDataLand.lua
local PvPDataLand = LibStub("AceAddon-3.0"):NewAddon("PvPDataLand", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local db

local defaults = {
    global = {
        history = {},
        twovtwo = {},
        threethree = {},
        soloshuffle = {},
        ratedbg = {},
    }
}

function PvPDataLand:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PvPDataLandDB", defaults, true)
    db = self.db.global
    self:RegisterChatCommand("pvpdata", "ChatCommand")
    self:Print("PvPDataLand loaded!")

    -- Load REFlex data
    if REFlexDatabase then
        for characterName, characterData in pairs(REFlexDatabase) do
            -- Assuming characterData is a table with keys 'twovtwo', 'threethree', 'soloshuffle', 'ratedbg'
            db.twovtwo[characterName] = characterData.twovtwo
            db.threethree[characterName] = characterData.threethree
            db.soloshuffle[characterName] = characterData.soloshuffle
            db.ratedbg[characterName] = characterData.ratedbg
        end
    else
        self:Print("REFlex addon data is not available.")
    end
end

function PvPDataLand:ChatCommand(input)
    if not input or input:trim() == "" then
        self:CreateGUI()
    else
        -- Display the requested data
        local data = db[input]
        if data then
            -- Create a new GUI window to display the data
            local dataFrame = AceGUI:Create("Frame")
            dataFrame:SetTitle(input .. " Data")
            dataFrame:SetStatusText("Data for " .. input)
            dataFrame:SetLayout("Flow")
            for key, value in pairs(data) do
                local label = AceGUI:Create("Label")
                label:SetText(key .. ": " .. tostring(value))
                label:SetFullWidth(true)
                dataFrame:AddChild(label)
            end
            -- Register the frame as a special frame so that it is closed when escape is pressed
            _G["PvPDataLand" .. input .. "Frame"] = dataFrame.frame
            tinsert(UISpecialFrames, "PvPDataLand" .. input .. "Frame")
            -- Show the data frame
            dataFrame:Show()
        else
            self:Print("Invalid command. Type /pvpdata for a list of commands.")
        end
    end
end

function PvPDataLand:CreateGUI()
    -- Check if AceGUI library is loaded
    if not AceGUI then
        self:Print("AceGUI library not loaded.")
        return
    end

    -- Create a container frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("PvP Data Land")
    frame:SetStatusText("Select a game mode")
    frame:SetLayout("Flow")

    -- Create four buttons for each game mode
    local button2v2 = AceGUI:Create("Button")
    button2v2:SetText("2v2")
    button2v2:SetWidth(100)
    button2v2:SetCallback("OnClick", function()
        self:ChatCommand("twovtwo")
    end)
    frame:AddChild(button2v2)

    local button3v3 = AceGUI:Create("Button")
    button3v3:SetText("3v3")
    button3v3:SetWidth(100)
    button3v3:SetCallback("OnClick", function()
        -- Display the data for 3v3 when the button is clicked
        self:ChatCommand("threethree")
    end)
    frame:AddChild(button3v3)

    local buttonRBG = AceGUI:Create("Button")
    buttonRBG:SetText("RBG")
    buttonRBG:SetWidth(100)
    buttonRBG:SetCallback("OnClick", function()
        -- Display the data for RBG when the button is clicked
        self:ChatCommand("ratedbg")
    end)
    frame:AddChild(buttonRBG)

    local buttonSS = AceGUI:Create("Button")
    buttonSS:SetText("SS")
    buttonSS:SetWidth(100)
    buttonSS:SetCallback("OnClick", function()
        -- Display the data for SS when the button is clicked
        self:ChatCommand("soloshuffle")
    end)
    frame:AddChild(buttonSS)

    -- Register the frame as a special frame so that it is closed when escape is pressed
    _G["PvPDataLandFrame"] = frame.frame
    tinsert(UISpecialFrames, "PvPDataLandFrame")

    -- Show the frame
    frame:Show()
end
