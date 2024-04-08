----------------------------------------------------------------------------------------
--                                                                                    --
--                                 SpellAddition.lua                                  --
--                                                                                    --
--                   Adds the basic utility spells and main containers                --
--                                                                                    --
--                                                                                    --
----------------------------------------------------------------------------------------


-- Add spells for all partymembers
function OnSessionLoaded()

    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
        local party = Osi.DB_PartyMembers:Get(nil)
        for i = #party, 1, -1 do
            addDECORSpells(party[i][1])
        end
    end)

    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(actor)
        addDECORSpells(actor)
    end)
end


-- Add spell if actor doesn't have it yet
function TryAddSpell(actor, spellName)
    if  Osi.HasSpell(actor, spellName) == 0 then
        Osi.AddSpell(actor, spellName)
    end
end

-- list of (spell)containers to add
-- TODO - make more variable
function addDECORSpells(entity)
    TryAddSpell(entity, "DECOR_UTILS")
    TryAddSpell(entity, "DECOR_OBJECTS")
end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)