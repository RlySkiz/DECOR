function OnSessionLoaded()
    -- Osi.AddSpell(Osi.GetHostCharacter(), "Target_Fly")
end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

Ext.RegisterNetListener("DECOR_SpawnObject", function(e, payload)
    local obj
    local what = "spawn"
    local objToSpawn = Ext.Json.Parse(payload)
    local template = Ext.Template.GetTemplate(objToSpawn.template)
    local position = {}
    position.x, position.y, position.z = Osi.GetPosition(Osi.GetHostCharacter())
    local prevStats
    if objToSpawn.how == "weightless" then
        prevStats = template.Stats
        template.Stats = "DECOR_Template"
    end
    -- if template.TemplateType == "scenery" then
        -- obj = Osi.CreateAt("0e92c207-f20f-46a7-a92a-6d71114122f8", position.x, position.y, position.z, 1, 0, "")
        -- Osi.Transform(obj, template.VisualTemplate, "296bcfb3-9dab-4a93-8ab1-f1c53c6674c9")
    -- else
        obj = Osi.CreateAt(template.Id, position.x, position.y, position.z, 1, 0, "")
    -- end
    if objToSpawn.how == "weightless" then
        Osi.SetMovable(obj, 1)
        template.Stats = prevStats
    end
    table.insert(PersistentVars["Undo"], {obj = obj, what = what})
end)


Ext.RegisterNetListener("DECOR_Undo", function(e, payload)
    if PersistentVars["Undo"] and #PersistentVars["Undo"] > 0 then
        local index = #PersistentVars["Undo"]
        local lastUndo = PersistentVars["Undo"][index]
        if lastUndo.what == "spawn" then
            Osi.RequestDelete(lastUndo.obj)
        elseif lastUndo.what == "somethingelse" then
        end
        table.remove(PersistentVars["Undo"], index)
    end
end)