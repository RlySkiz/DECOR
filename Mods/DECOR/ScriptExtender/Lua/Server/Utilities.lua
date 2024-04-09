----------------------------------------------------------------------------------------
--                                                                                    --       
--                                   Utilities.lua                                    --
--                                                                                    --
--                      Useful functions to make life easier                          --
--                                                                                    --
--                                                                                    --
----------------------------------------------------------------------------------------

-- Necessary for hot loading
function ReloadStats()
    Ext.Stats.LoadStatsFile("Public/DECOR/Stats/Generated/Data/DECOR_boosts.txt", 0)
    Ext.Stats.LoadStatsFile("Public/DECOR/Stats/Generated/Data/DECOR_templates.txt", 0)
    Ext.Stats.LoadStatsFile("Public/DECOR/Stats/Generated/Data/DECOR_spells_util.txt", 0)
    Ext.Stats.LoadStatsFile("Public/DECOR/Stats/Generated/Data/DECOR_spells_danger.txt", 0)
    Ext.Stats.LoadStatsFile("Public/DECOR/Stats/Generated/Data/DECOR_spells_container.txt", 0)
end

----------------------------------------------------------------------------------------

-- TODO - Clean up this mess

-- Get index by item directly
function getIndex(list, item)
    for i, object in ipairs(list) do
        if object == item then
            return i
        end
    end
end


-- For tables
function contains(list, item)
    for i, object in ipairs(list) do
        if object == item then
            return true
        end  
    end
    return false
end


-- For maps
function containsValue(map, item)
    for key, object in pairs(map) do
        if object == item then
            return true
        end
    end
    return false
end


-- For maps
function getKeyByValue(map, value)
    for key, val in pairs(map) do
        if val == value then
            return key
        end
    end
    return nil
end

-- uniqueMapkey is returned by "UsingSpellOnTarget"
function getUUIDByUniqueMapkey(uniqueMapkey)

    local startPosition = #uniqueMapkey - 35
    local uuid = string.sub(uniqueMapkey, startPosition)
    return uuid
end


function getNameByUniqueMapkey(uniqueMapkey)
    local endPosition = #uniqueMapkey - 37
    local strippedString = string.sub(uniqueMapkey, 1, endPosition)
    return strippedString
end


function getPrefix(s)
    return string.sub(s, 1, 5)
end


--- Retrieves the value of a specified property from an object or returns a default value if the property doesn't exist.
-- @param obj           The object from which to retrieve the property value.
-- @param propertyName  The name of the property to retrieve.
-- @param defaultValue  The default value to return if the property is not found.
-- @return              The value of the property if found; otherwise, the default value.
function getPropertyOrDefault(obj, propertyName, defaultValue)
    local success, value = pcall(function() return obj.propertyName end)
    if success then
        return value or defaultValue
    else
        return defaultValue
    end
end


--- Retrieves the MapKey (visual) from uniqueMapkey
-- @param uniqueMapkey  The handle
-- @return              The GameObjectVisual RootTemplateID
function getMapkeyFromUniqueMapkey(uniqueMapkey)
    local entity = Ext.Entity.Get(uniqueMapkey) 
    local mapkey = entity:GetComponent("GameObjectVisual").RootTemplateId
    return mapkey
end


-- functions below are depreated for now (were used for persistentVars that save tables)

--- Checks if spell/object is currently loaded or not
--- This is for checking entries within a table which holds tables of entries, which can be accessed with entry.name
-- @param name          Name of the spell/object to check
-- @param persVariable  Which persistantVariable to check
-- @return              Whether the spell is loaded
function isSpellLoadedObject(name, persVariable)
    if persVariable then
        for _, entry in ipairs(persVariable) do
            if entry.name == name then         
                return true
            end
        end
        return false
    else
        return false
    end
end


--- Returns matching MapKey for spellName
-- @param name          Name of the spell/object to check
-- @param persVariable  Which persistantVariable to check
-- @return              Mapkey matching the spell
function getMapKeyBySpell(name, persVariable)
    if isSpellLoadedObject(name, persVariable) then
        for _, entry in ipairs(persVariable) do
            if entry.name == name then         
                return entry.mapKey
            end
        end
    end
end