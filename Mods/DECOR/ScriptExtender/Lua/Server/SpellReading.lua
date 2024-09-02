-- ----------------------------------------------------------------------------------------
-- --                                                                                    --
-- --                                 SpellReading.lua                                   --
-- --                                                                                    --
-- --                       Adds the custom objects to DECOR                             --
-- --                                                                                    --
-- --                                                                                    --
-- ----------------------------------------------------------------------------------------

-- -- Map addedSpells saves spellName/UUID combination Loaded from additional mods
-- local AddedSpells

-- function getAddedSpells()
--     return AddedSpells
-- end

-- function setAddedSpells(value)
--     AddedSpells = value
-- end



-- -- read custom objects into DECOR
-- -- TODO - Remove Debug prints when tested enough. 
-- function OnSessionLoaded()

--     -- [DEBUG]
--     print("[DECOR] Initialize Spellcheck")

--     -- Purge all DECOR_Containers (this solves a lot of issues)
--     purgeObjectSpells()

--     -- initiate addedSpells
--     if not AddedSpells then
--         AddedSpells = {}
--     end

--     -- Read in spells and uuid
--     for _,spell in pairs(Ext.Stats.GetStats("SpellData"))do 

--         local name = Ext.Stats.Get(spell).Name
--         local mapKey = Ext.Stats.Get(spell).ExtraDescription
--         local containerID = Ext.Stats.Get(spell).SpellContainerID

--         if mapKey and containerID and getPrefix(containerID) == "DECOR" then
            
--             local container = Ext.Stats.Get(containerID)
--             local spellsInContainer = container.ContainerSpells

--             -- only add spell if it isn't already in container
--             if string.find(spellsInContainer, name, 1, true) == nil then   
--                 print("[DECOR] Adding", name, "with MapKey:", mapKey, " to chosen container.")
--                 container.ContainerSpells = spellsInContainer..";" .. name
--                 container:Sync()

--                 -- Adding spell information to Map

--                 AddedSpells[name] = mapKey

--                     -- [DEBUG] - Print the content of AddedSpells
--                 print("[DECOR] Content of AddedSpells:")
--                 for name, mapKey in pairs(AddedSpells) do
--                     print("[DECOR] Name:", name, "MapKey:", mapKey)
--                 end
--             end
--         end
--     end
-- end


-- -- Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)