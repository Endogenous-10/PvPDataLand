-- Create the addon frame
local frame = CreateFrame("Frame")

-- Initialize the database
local PvPDataLandDB = {}

-- Create a separate table for combat log data
local CombatLogData = {}

-- Register the events we want to track
frame:RegisterEvent("ARENA_MATCH_START")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ARENA_MATCH_END")
frame:RegisterEvent("PERSONAL_RATED_INFO")

-- This variable will store the current instance ID
local currentInstanceID

-- This function will handle events
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ARENA_MATCH_START" then
        local instanceID, _, matchType, teamId = ...
        currentInstanceID = instanceID

        -- Get the timestamp for the start of the arena match
        local startTimeStamp = GetServerTime()

        -- Initialize a new table to hold the data for this match
        PvPDataLandDB[instanceID] = {
            start = startTimeStamp,
            matchType = matchType,
            players = {},
        }

        -- Record the race, class, spec, and talent tree of all players in the arena
        for i = 1, GetNumGroupMembers() do
            local unit = "party"..i
            if i == GetNumGroupMembers() then unit = "player" end
            local name, realm = UnitName(unit)
            local raceName, _, raceID = UnitRace(unit)
            local className, _, classId = UnitClass(unit)
            local specId = GetInspectSpecialization(unit)
            local isEnemy = IsEnemy(name, realm)

            -- Get talent tree information
            local talentTree = {}
            for j = 1, GetMaxTalentTier() do
                local talentId, _, _, _, _, selected = GetTalentInfo(j, GetActiveSpecGroup())
                talentTree[j] = {
                    talentId = talentId,
                    selected = selected,
                }
            end

            PvPDataLandDB[instanceID].players[name.."-"..(realm or GetRealmName())] = {
                race = raceName,
                class = className,
                spec = specId,
                talentTree = talentTree,
                isEnemy = isEnemy,
            }
        end

        -- Store the start timestamp in the CombatLogData table
        CombatLogData[startTimeStamp] = {
            instanceID = instanceID,
            events = {},
        }

        -- Call GetPersonalRatedInfo to capture player's initial rating
        GetPersonalRatedInfo()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if currentInstanceID then
            local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = CombatLogGetCurrentEventInfo()

            -- Store the combat log event in CombatLogData table
            if CombatLogData[currentInstanceID] then
                table.insert(CombatLogData[currentInstanceID].events, {
                    timestamp = timestamp,
                    subevent = subevent,
                    sourceGUID = sourceGUID,
                    sourceName = sourceName,
                    spellId = spellId,
                    amount = amount,
                    spellName = spellName,
                })
            end
        end
    elseif event == "ARENA_MATCH_END" then
        if currentInstanceID and PvPDataLandDB[currentInstanceID] then
            local winningTeam, matchDuration, newRatingTeam1, newRatingTeam2 = ...

            -- Store the match end details
            PvPDataLandDB[currentInstanceID].end = GetServerTime()
            PvPDataLandDB[currentInstanceID].duration = matchDuration
            PvPDataLandDB[currentInstanceID].winningTeam = winningTeam
            PvPDataLandDB[currentInstanceID].newRatingTeam1 = newRatingTeam1
            PvPDataLandDB[currentInstanceID].newRatingTeam2 = newRatingTeam2

            -- Reset the current instance ID
            currentInstanceID = nil
        end
    elseif event == "PERSONAL_RATED_INFO" then
        if currentInstanceID and PvPDataLandDB[currentInstanceID] then
            local rating = ...
            PvPDataLandDB[currentInstanceID].startRating = rating
        end
    end
end)

-- This function will handle errors (optional)
frame:SetScript("OnError", function(self, error)
    -- Handle the error, e.g., by logging it or displaying a message to the user
    print(error)
end)

-- Function to retrieve combat log data for a specific instance ID
local function GetCombatLogData(instanceID)
    local combatLogs = {}
    for timeStamp, data in pairs(CombatLogData) do
        if data.instanceID == instanceID then
            combatLogs[timeStamp] = data.events
        end
    end
    return combatLogs
end
