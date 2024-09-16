if CLIENT then return end

Hook.Add("roundStart", "HideCrewList", function ()
    if Level.Loaded and Level.Loaded.IsLoadedFriendlyOutpost then
        return
    end
    
    for key, value in pairs(Character.CharacterList) do
        Networking.CreateEntityEvent(value, Character.RemoveFromCrewEventData.__new(value.TeamID, {}))
    end
end)