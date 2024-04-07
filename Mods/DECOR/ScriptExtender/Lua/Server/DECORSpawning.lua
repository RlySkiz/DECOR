-- refresh spells (used for hot loading)
-- ReloadStats()

function getSpawnedItems()
    return PersistentVars['spawnedItems']
end


-- cleans up all spawned items  
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster,spell, _, _, _)

    if spell == "AAAA_UNINSTALL" or spell == "AAA_CleanUp" then
        

        if getSpawnedItems() then
            for _, item in pairs(getSpawnedItems()) do
                Osi.RequestDelete(item)
            end
        end

        if spell == "AAAA_UNINSTALL" then  
            PersistentVars['spawnedItems'] = nil
            PersistentVars['addedSpells'] = nil


            -- TODO - make variable for multiple containers
            local container = Ext.Stats.Get("DECOR_OBJECTS")

            container.ContainerSpells = ""
            container:Sync()

        end
    end



end)


Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)

    -- UsingSpellOnTarget returns unique mapkey
    -- unique mapkey is Name_ + UUID

    local targetID = getUUIDByUniqueMapkey(target)

    --Clean up single item if it is furniture
    if spell == "AA_CleanUp_One" then
        local name = getNameByUniqueMapkey(target)

        if contains(getSpawnedItems(), targetID) then
            Osi.RequestDelete(targetID)
            table.remove(getSpawnedItems(), getIndex(getSpawnedItems(),targetID))
        end
    end

    -- Toggle movement on chosen furniture
    if spell == "A_Toggle_Movement" then
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



-- Furniture Spawning
Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", function(_, x, y, z, spell, _, _, _)
    -- initiate spawnedItems
    if not PersistentVars['spawnedItems'] then
        PersistentVars['spawnedItems'] = {}
    end
    
    if not getAddedSpells() then
        print("[DECOR] [DECOR] [DECOR] [DECOR] [DECOR]")
        print("[DECOR] You probably used the UNINSTALL spell.")
        print("[DECOR] Please load a save file for the mod to reregister any possible loaded mods and their game objects as new spells.")
        print("[DECOR] If you intended to remove a mod and its game object/spell please also remove it from your Mod folder/Load Order before loading a new save.")
        print("[DECOR] For more information please visit the Nexus Mod Page of this Mod.")
        return
    end
    
    -- Iterate over each spell entry
    -- Check if the current spell matches the spell in the entry
    local mapKey = getMapKeyBySpell(spell, getAddedSpells())
    if mapKey then
        local spawnedObject = Osi.CreateAt(mapKey, x, y, z, 1, 0, "")
        table.insert(PersistentVars['spawnedItems'], spawnedObject) 
    end
end)
