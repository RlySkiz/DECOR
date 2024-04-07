
-- Loaded from additional mods
function getAddedSpells()
    return PersistentVars['addedSpells']
end


function OnSessionLoaded()

    print("[DECOR] Initialize Spellcheck")

    -- initiate addedSpells
    if not PersistentVars['addedSpells'] then
        PersistentVars['addedSpells'] = {}
    end

    -- Print the content of PersistentVars 
    print("[DECOR] Content of PersistentVars:")
    for _, entry in ipairs(PersistentVars['addedSpells']) do
        print("[DECOR] Name:", entry.name, "MapKey:", entry.mapKey)
    end
     
    print("[DECOR] Current Spells within 'DECOR_OBJECTS'-SpellContainer:")
    if Ext.Stats.Get("DECOR_OBJECTS").ContainerSpells ~= "" then
        print("[DECOR]", Ext.Stats.Get("DECOR_OBJECTS").ContainerSpells)
    else
        print("[DECOR] DECOR_OBJECTS is empty.")
    end


    for i,spell in pairs(Ext.Stats.GetStats("SpellData"))do 

        local name = Ext.Stats.Get(spell).Name
        local mapKey = Ext.Stats.Get(spell).ExtraDescription
        local containerID = Ext.Stats.Get(spell).SpellContainerID

        if mapKey and containerID and getPrefix(containerID) == "DECOR" then
            
                local container = Ext.Stats.Get(containerID)
                local spellsInContainer = container.ContainerSpells

                -- only add spell if it isn't already in container
                if string.find(spellsInContainer, name, 1, true) == nil then   
                    print("[DECOR] Adding", name, "with MapKey:", mapKey, " to chosen container.")
                    container.ContainerSpells = spellsInContainer..";" .. name
                    container:Sync()

                    -- Adding spell information to PersVars
                    local spellEntry = {name = name, mapKey = mapKey}
                    table.insert(PersistentVars['addedSpells'], spellEntry)

                    -- print("Content of persistentVars[addedSpells]")
                    -- for _, item in pairs(getAddedSpells()) do
                    --     print(item)
                    -- end

                    -- -- Print the content of PersistentVars['addedSpells']
                    -- print("Content of PersistentVars['addedSpells']")
                    -- for _, entry in ipairs(PersistentVars['addedSpells']) do
                    --     print("Name:", entry.name, "MapKey:", entry.mapKey)
                    -- end


                    print("[DECOR] Content of PersistentVars after loading new objects:")
                    for _, entry in ipairs(PersistentVars['addedSpells']) do
                        print("[DECOR] Name:", entry.name, "MapKey:", entry.mapKey)
                    end

                else
                    -- print("Content of persistentVars[addedSpells]")
                    -- for _, item in pairs(getAddedSpells()) do
                    --     print(item)
                    -- end

                    -- Print the content of PersistentVars['addedSpells']

                end

        end
        
    end

end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)