local function GetModVar(modvar)
    local modVars = Ext.Vars.GetModVariables(ModuleUUID)
    local var = {}
    if modVars and modVars[modvar] then
        var = modVars[modvar]
    end
    return var
end

local function UpdateModVar(modvar, var)
    Ext.Vars.GetModVariables(ModuleUUID)[modvar] = var or {}
end

function OnSessionLoaded()
    -- Loading ModVars including PersistentVars for compatibility in case someone used a version earlier than 0.3.0
    local totalUndo = {}
    local totalRedo = {}
    local totalSpawned = {}
    local persUndo = {}
    local persSpawned = {}
    if PersistentVars["Undo"] then
        persUndo = PersistentVars["Undo"]
    end
    if PersistentVars['spawnedItems'] then
        persSpawned = PersistentVars['spawnedItems']
    end

    _P("[DECOR] Updating ModVars")
    totalUndo = GetModVar("Undo")
    if #persUndo > 0 then
        table.insert(totalUndo, persUndo)
    end
    UpdateModVar("Undo", totalUndo)

    totalSpawned = GetModVar("SpawnedItems")
    if #persSpawned > 0 then
        table.insert(totalSpawned, persSpawned)
    end
    UpdateModVar("SpawnedItems", totalSpawned)


    totalRedo = GetModVar("Redo")
    UpdateModVar("Redo", totalRedo)

    _D(GetModVar("Undo"))
    _D(GetModVar("Redo"))
    _D(GetModVar("SpawnedItems"))

    ---------------------------------------------------------------------------------------------------
    --                               Remove Spells from old Versions
    ---------------------------------------------------------------------------------------------------

    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
        local party = Osi.DB_PartyMembers:Get(nil)
        for i = #party, 1, -1 do
            Osi.RemoveSpell((party[i][1]), "DECOR_UTILS")
            Osi.RemoveSpell((party[i][1]), "DECOR_OBJECTS")
            Osi.RemoveSpell((party[i][1]), "DECOR_DANGER")
        end
    end)

    -- Osi.AddSpell(Osi.GetHostCharacter(), "Target_Fly")
end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

local function spawnObject(payload)
    local obj
    local what = "spawn"
    local objToSpawn = Ext.Json.Parse(payload)
    local objWeight = objToSpawn.weight or weight
    local template = Ext.Template.GetTemplate(objToSpawn.template)
    local position = objToSpawn.pos or {}
    if position == {} then
        position.x, position.y, position.z = Osi.GetPosition(Osi.GetHostCharacter())
    end

    -- Need to find different way to remove weight other than completely changing the stat template
    local prevStats
    if objToSpawn.weight == "weightless" then
        prevStats = template.Stats
        template.Stats = "DECOR_Template"
    end
    obj = Osi.CreateAt(template.Id, position.x, position.y, position.z, 1, 0, "")
    local objPosition = Osi.GetPosition(obj)
    if objToSpawn.weight == "weightless" then
        Osi.SetMovable(obj, 1)
        template.Stats = prevStats
    end
    local undo = {}
    undo = GetModVar("Undo")
    table.insert(undo, {obj = obj, what = what, weight = objToSpawn.weight, pos = objPosition})
    UpdateModVar("Undo", undo)
end

Ext.RegisterNetListener("DECOR_SpawnObject", function(e, payload)
    spawnObject(payload)
end)


Ext.RegisterNetListener("DECOR_Undo", function(e, payload)
    if GetModVar("Undo") and #GetModVar("Undo") > 0 then
        local i = #GetModVar("Undo")
        local lastUndo = GetModVar("Undo")[i]
        if lastUndo.what == "spawn" then
            Osi.RequestDelete(lastUndo.obj)
            table.insert(GetModVar("Redo"), {obj = lastUndo.obj, what = "delete", weight = lastUndo.weight, pos = lastUndo.pos})
        elseif lastUndo.what == "delete" then
            spawnObject(tostring({template = lastUndo.obj, weight = lastUndo.weight, pos = lastUndo.pos}))
        end
        table.remove(GetModVar("Undo"), i)
    end
end)

Ext.RegisterNetListener("DECOR_Redo", function(e, payload)
    if GetModVar("Redo") and #GetModVar("Redo") > 0 then
        local i = #GetModVar("Redo")
        local lastRedo = GetModVar("Redo")[i]
        if lastRedo.what == "delete" then
            -- tostring to Parse it in spawnObject() like regular event payload
            -- No .what necessary because we use spawnObject which saves it correctly in Undo again
            spawnObject(tostring({template = lastRedo.obj, weight = lastRedo.weight, pos = lastRedo.pos}))
        elseif lastRedo.what == "somethingelse" then
        end
        table.remove(GetModVar("Redo"), i)
    end
end)


Ext.RegisterNetListener("DECOR_RemoveObjectWeight", function(e, payload)
end)
Ext.RegisterNetListener("DECOR_SpawnObjectAtLocation", function(e, payload)
    spawnObject(payload.uuid, "normal", payload.location)
end)

Ext.RegisterNetListener("DECOR_LockObject", function(e, payload)
    local obj = Ext.Json.Parse(payload)
    if Osi.IsMovable(obj) == 0 then
        Osi.SetMovable(targetID, 1)
    else
        Osi.SetMovable(targetID, 0)
    end
end)

Ext.RegisterNetListener("DECOR_DeleteObject", function(e, uuid)
    for i,entry in ipairs(GetModVar("Undo")) do
        if uuid == entry.obj then
            local weight = entry.weight
            Osi.RequestDelete(uuid)
            table.insert(GetModVar("Undo"), {obj = uuid, what = "delete", weight = weight})
        end
        -- table.remove(GetModVar("Undo"), i)
    end
    for i,entry in ipairs(GetModVar("SpawnedItems")) do
        if uuid == entry then -- SpawnedItems were saved by their uuid per entry
            Osi.RequestDelete(uuid)
            -- Slowly convert them over to undo table
            table.insert(GetModVar("Undo"), {obj = uuid, what = "delete", weight = "weightless"}) -- all were spawned weightless
        end
        -- table.remove(GetModVar("SpawnedItems"), i)
    end
end)