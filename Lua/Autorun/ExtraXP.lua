if CLIENT then return end

-- Create a table to store DECIMALCOUNTER for each player
local playerDecimalCounters = {}

-- Function to get or initialize the DECIMALCOUNTER for a specific player
local function getDecimalCounter(instance)
    -- If this player doesn't have a counter yet, initialize it
    if playerDecimalCounters[instance] == nil then
        playerDecimalCounters[instance] = 0
    end
    return playerDecimalCounters[instance]
end

-- Function to set the DECIMALCOUNTER for a specific player
local function setDecimalCounter(instance, value)
    playerDecimalCounters[instance] = value
end

-- Patch to modify experience gain based on player's level
Hook.Patch("Barotrauma.CharacterInfo", "GiveExperience", function(instance, ptable)
    -- Modify experience gain based on player's level
    ptable["amount"] = Int32(ptable["amount"] * math.sqrt(instance.GetCurrentLevel() + 1))
end, Hook.HookMethodType.Before)

-- Patch to modify skill gain based on player's level and handle fractional experience
Hook.Patch("Barotrauma.CharacterInfo", "ApplySkillGain", function(instance, ptable)
    -- Modify skill gain based on player's level
    ptable["baseGain"] = Single(ptable["baseGain"] * math.sqrt(instance.GetCurrentLevel() + 1))

    -- Add experience to the player character
    local experienceGain = ptable["baseGain"].Value * 0.1

    -- Get the player's DECIMALCOUNTER
    local decimalCounter = getDecimalCounter(instance)
    
    -- Handle fractional experience gain
    if experienceGain < 1 then
        decimalCounter = decimalCounter + experienceGain
        if DECIMALCHECK(decimalCounter) then
            experienceGain = 1
            decimalCounter = decimalCounter - 1
        else
            -- Update the player's decimal counter and return without giving experience
            setDecimalCounter(instance, decimalCounter)
            return
        end
    end

    -- Update the player's decimal counter
    setDecimalCounter(instance, decimalCounter)

    -- Add the calculated experience to the player
    instance.GiveExperience(experienceGain)
end, Hook.HookMethodType.After)

-- Function to check and handle fractional experience overflow per player
function DECIMALCHECK(decimalCounter)
    if decimalCounter > 1 then
        return true
    end
    return false
end
