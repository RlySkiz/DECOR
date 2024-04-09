----------------------------------------------------------------------------------------
--                                                                                    --
--                                 SpellHandling.lua                                  --
--                                                                                    --
--                   Adds the basic utility spells and main containers                --
--                                                                                    --
--                                                                                    --
----------------------------------------------------------------------------------------


local baseSpell = {"DECOR_UTILS", "DECOR_DANGER"}


-- Add utility spells to partymembers
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
    local party = Osi.DB_PartyMembers:Get(nil)
    for i = #party, 1, -1 do
        addDECORSpells(party[i][1])
    end
end)
Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(actor)
    addDECORSpells(actor)
end)


-- Add spell if actor doesn't have it yet
function TryAddSpell(actor, spellName)
    if  Osi.HasSpell(actor, spellName) == 0 then
        Osi.AddSpell(actor, spellName)
    end
end

-- Remove spell if actor has it
function TryRemoveSpell(actor, spellName, removeContainer)
    if  Osi.HasSpell(actor, spellName) == 1 then
        Osi.RemoveSpell(actor, spellName, removeContainer)
    end
end


-- List of (spell)containers to add
-- TODO - Make more variable
function addDECORSpells(entity)
    TryAddSpell(entity, "DECOR_UTILS")
    TryAddSpell(entity, "DECOR_OBJECTS")
    TryAddSpell(entity, "DECOR_DANGER")
end


-- Deletes one spell from container
-- TODO - Check if it deletes containers correctly when we have more examples
function deleteObjectSpell(spellToBeDeleted)

    -- bool switch
    local removeContainer = 0

    local party = Osi.DB_PartyMembers:Get(nil)
    
    local containerID = Ext.Stats.Get(spellToBeDeleted).SpellContainerID
    local container = Ext.Stats.Get(containerID)

    if container then
        local containerSpells = container.ContainerSpells

        local toBeRemoved = ";" .. spellToBeDeleted

        local updatedSpells = string.gsub(containerSpells, toBeRemoved, "")
    
        container.ContainerSpells = updatedSpells
        container:Sync()

        -- If containerSpells is empty because the last spell got removed, the container can be removed as well
        if container.ContainerSpells == "" then
            removeContainer = 1
        end

        for i = #party, 1, -1 do
            TryRemoveSpell(party[i][1], spellToBeDeleted, removeContainer)
        end
    end


end

-- TODO - Make it variable for multiple (custom) containers
function deleteAllObjectSpells()
    for _, spell in pairs(Ext.Stats.GetStats("SpellData")) do

        local containerID = Ext.Stats.Get(spell).SpellContainerID

        -- Only purge if corresponding container is from DECOR
        if getPrefix(containerID) == "DECOR" and not (contains(baseSpell, containerID)) then
            deleteObjectSpell(spell)
        end
    end
end


-- TODO - Container spells stay (because they themselves are not in a container with prefix "DECOR" - maybe revise)
-- TODO - When custom containers are available, change accordingly
-- Cannot be the same as deleteAllObjectSpells since Osi.DB cannot be calles on load
function purgeObjectSpells()

    for _, spell in pairs(Ext.Stats.GetStats("SpellData")) do

        -- If ContainerSpells exists, the spell is a container
        if Ext.Stats.Get(spell).ContainerSpells and getPrefix(spell) == "DECOR" and not (contains(baseSpell, spell)) then
            local container = Ext.Stats.Get(spell)
            container.ContainerSpells = ""
            container:Sync()
        end
    end
end
