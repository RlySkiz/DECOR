-- Checks if something is armor
function Object:IsArmor(item)

    local entity = Ext.Entity.Get(item)
    return string.sub(Osi.GetTemplate(item), 1, 3) == "ARM" 

end

-- Checks if something is armor
function Object:IsWeapon(item)
    return string.sub(Osi.GetTemplate(item), 1, 3) == "WPN" 
end

-- Checks if something is a helper item
function Object:IsHelper(item)
    return string.sub(Osi.GetTemplate(item), 1, 6) == "Helper" 
end

-- Checks if something is a door
function Object:IsDoor(item)
    return string.sub(Osi.GetTemplate(item), 1, 4) == "DOOR" 
end

function Object:IsQuest(item)
    local entity = Ext.Entity.Get(item)
    if entity then
        return entity.ServerItem.StoryItem
    end
    --return string.sub(Osi.GetTemplate(item), 1, 5) == "QUEST"  -- probably not needed anymore if story item works
end

function Object:IsWeird(item)
    local entity = Ext.Entity.Get(item)
    if entity then
        local stats = entity.Data.StatsId 
        if stats == "OBJ_GenericImmutableObject" then
            return true
        end

        -- local name = Helper:GetPropertyOrDefault(entity, "Name",nil)
        local name = entity.ServerItem.Template.Name
        --if name then
            if Helper:StringContains(name, "Generic") then -- TODO - this seems broken. OBJ_Generic still spawns. Pthers are succesfully excluded. They might not have an entity component
                print("Is Generic ", name)
                return true
            --end
        --else
           -- print("does not have a name ", stats )
        end
    else 
        -- if it isnt an enitity its probably weird
        return true
    end
    -- all checks passed. Not weird
    return false
end

function Object:IsEquipment(item)
    local isEquipment = Osi.GetEquipmentSlotForItem(item)
    if isEquipment then
        return true
    else
        return false
    end
end

function Object:IsInChampChest(item)
    local campItems = SATAN_ITEMHelper:getItemsFromCampChests()

    print("fetched all camp chest items")

    if Table:Contains(campItems, item) then
        return true
    else
        return false
    end
end

function Object:IsMagicMirror(item)
    local template = Osi.GetTemplate(item)
    if template == "UNI_MagicMirror_72ae7a39-d0ce-4cb6-8d74-ebdf7cdccf91" then
        return true
    end
end

-- TODO - doesnt work
function Object:IsInInventory(item)


    local entity = Ext.Entity.Get(item)
    local invMember = Helper:GetPropertyOrDefault(entity, "InventoryMember", nil)

    if invMember then
        return true
    else
        return false
    end
    -- Osi.IsInInventory(object)

    -- --local allEntities = Ext.Entity.GetAllEntities()
    -- local allEntities = Ext.Entity.GetAllEntitiesWithComponent("ServerItem")

    -- for _, entity in pairs(allEntities) do
     
    --     local inventoryOwner = Helper:GetPropertyOrDefault(entity, "InventoryOwner", nil)

    --     if inventoryOwner then

    --         for _, inventories in pairs(inventoryOwner.Inventories) do
    --             for _, object in pairs(inventories.InventoryContainer.Items) do
    --                 if item == Ext.Entity.HandleToUuid(object.Item) then
    --                     return true
    --                 end
    --             end
    --         end
    --     end
    -- end
    -- return false
end


-- REF_FUR_Chair_570b18a9-80d4-9f71-71a6-1c93089da759
-- used by Larian to fake sittable Object
function Object:IsDefaultChair(item)
    --local entity = Ext.Entity.Get(item)
    return string.sub(Osi.GetTemplate(item), 1, 3) == "REF" 
    --if entity.GameObjectVisual.RootTemplateId == "5f9243d8-892f-4b4b-81ae-346c5ccd217c" then -- rt probably not a good way to check
    -- if entity.ServerItem.Template.VisualTemplate == "059a4a83-e2ea-74bd-b8a8-9057790a2128" then
    --     print("Is default chair ", item)
    --     return true
    -- else
    --     if entity.Data.StatsId == "OBJ_Chair" then
    --       --  print("not default",  entity.GameObjectVisual.RootTemplateId)
    --     end
    --     return false
    -- end
end


function Object:IsSpawner(item)
    -- probably have to blacklist certain items by hand
    local spawner = {
        "LOW_KurwinCoffin_KoboldGang_Hole",
        "SHA_Shadowquake_Item"
    }

    local entity = Ext.Entity.Get(item)
    if entity then
        local stats = entity.ServerItem.Stats

        if Table:Contains(spawner, stats) then
            print("Is spawner ", stats)
            return true
        end
    end
    return false
end

-- TODO . buttons still seem to get picked up
-- traps, buttons, pressure plates etc.
function Object:IsPuzzle(item)
    local entity = Ext.Entity.Get(item)
    if entity then
        local name = entity.ServerItem.Template.Name
        if Helper:StringContains(name, "PUZ") then
            print("Is PUZZLE ", name)
            return true
        end
    end
    return false
end

-- scrolls, keychains, keys, potions, food like goodberries
-- this should also be solved by excluding inventories

-- loops infinitely
function Object:IsCampChest(item)
    --local allEntities = Ext.Entity.GetAllEntities()
   -- for i, entity in pairs(allEntities) do
       -- local isCampChest = Helper:GetPropertyOrDefault(entity, "CampChest", nil)
       -- local isActuallyCampChest = Helper:GetPropertyOrDefault(isCampChest, "UserID", nil)
        --if isActuallyCampChest then
            --print("CampChest found ", item, " ", isActuallyCampChest)
            --print(entity.ServerItem.Template.Name, " ", entity.Level.LevelName)
       -- end
   -- end
    local entity = Ext.Entity.Get(item)
    local name = entity.ServerItem.Template.Name
    if Helper:StringContains(name, "PlayerCampChest") then
        print("IsCampChest")
        return true
    end
    return false
end


function Object:IsBlacklisted(item)
    local entity = Ext.Entity.Get(item)
    local name = entity.ServerItem.Template.Name
     -- Idol of Silvanus
    if Helper:StringContains(name, "Silvanus") then
        print("IsIdolOfSilvanus")
        return true
    end
    return false
end

function Object:IsScroll(item)
    local entity = Ext.Entity.Get(item)
    if entity then
        local name = entity.ServerItem.Template.Name
        if Helper:StringContains(name, "Scroll") then
            print("Is Scroll ", name)
            return true
        end
    end
    return false
end

function Object:IsUnique(item)
    return string.sub(Osi.GetTemplate(item), 1, 3) == "UNI" 
end

function Object:isPotion(item)
    local entity = Ext.Entity.Get(item)
    if entity then
        local name = entity.ServerItem.Template.Name
        if Helper:StringContains(name, "Potion") then
            print("Is Potion ", name)
            return true
        end
    end
    return false
end


-- TODO - else the amount of objects increases exponentially since the helpers are saved as well
function Object:IsCustomHelper()
end