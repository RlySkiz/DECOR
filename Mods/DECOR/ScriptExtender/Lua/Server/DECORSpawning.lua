----------------------------------------------------------------------------------------
--                                                                                    --
--                                 DECORSpawning.lua                                  --
--                                                                                    --
--                   Spawning, Deletion and Saving of spawned objects                 --
--                                                                                    --
--                                                                                    --
----------------------------------------------------------------------------------------


function getSpawnedItems()
    return PersistentVars['spawnedItems']
end


function removeFromSpawnedItems(item)
    if contains(getSpawnedItems(), item) then
        Osi.RequestDelete(item)
        table.remove(getSpawnedItems(), getIndex(getSpawnedItems(),item))
    end
end


-- Cleans up all spawned items or prepares mod for uninstalls  
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(_,spell, _, _, _)

    if spell == "A_UNINSTALL_ALL" or spell == "Cleanup_ALL" then
        
        if getSpawnedItems() then
            for _, item in pairs(getSpawnedItems()) do
                Osi.RequestDelete(item)
            end
        end


        if spell == "A_UNINSTALL_ALL" then  
            PersistentVars['spawnedItems'] = nil
            deleteAllObjectSpells()

        end
    end
end)


-- Locks/unlocks movement or uninstall one object
Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)

    -- UsingSpellOnTarget returns unique mapkey
    -- unique mapkey is Name_ + UUID

    local targetID = getUUIDByUniqueMapkey(target)

    -- Remove one mod from spawnedItems and setAddedSpells
    if spell == "A_UNINSTALL_TARGET" then
    
        local mapKeyToBeRemoved =  getMapkeyFromUniqueMapkey(target)

        local spawnedItems = getSpawnedItems()
        for i = #spawnedItems, 1, -1 do
            if getMapkeyFromUniqueMapkey(spawnedItems[i]) == mapKeyToBeRemoved then
                Osi.RequestDelete(spawnedItems[i])
                table.remove(spawnedItems, i)
            end
        end
        deleteObjectSpell(getKeyByValue(getAddedSpells(), mapKeyToBeRemoved))
    end

    -- Toggle movement on chosen object
    if spell == "Toggle_Movement" then
        if contains(getSpawnedItems(), targetID) then
            local isMovable = Osi.IsMovable(targetID)
            if isMovable == 0 then
                Osi.SetMovable(targetID, 1) 
            else
                Osi.SetMovable(targetID, 0)
            end
        end
    end
end)

-- Delete targeted objects
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, _, _)
    if status == "DELETING" then
        local targetID = getUUIDByUniqueMapkey(object)
        removeFromSpawnedItems(targetID)
    end
end)

-- Object Spawning
Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", function(_, x, y, z, spell, _, _, _)

    -- Initiate spawnedItems
    if not PersistentVars['spawnedItems'] then
        PersistentVars['spawnedItems'] = {}
    end
    
    -- Console print in case user somehow used spawning spell after using uninstall spell 
    -- TODO - This should not print anymore unless something goes terribly wrong
    if not getAddedSpells() then
        print("[DECOR] [DECOR] [DECOR] [DECOR] [DECOR]")
        print("[DECOR] You probably used the UNINSTALL spell.")
        print("[DECOR] Please load a save file for the mod to reregister any possible loaded mods and their game objects as new spells.")
        print("[DECOR] If you intended to remove a mod and its game object/spell please also remove it from your Mod folder/Load Order before loading a new save.")
        print("[DECOR] For more information please visit the Nexus Mod Page of this Mod.")
        return
    end
    
    -- Spawning
    if getAddedSpells()[spell] then
        local spawnedObjects = Osi.CreateAt(getAddedSpells()[spell], x, y, z, 1, 0, "")
        table.insert(getSpawnedItems(), spawnedObjects)
    end
end)


