-- Ext.RegisterNetListener("DECOR_RequestTemplates", function(e)
--     local sortedTemplates = {}
--     for _, template in pairs(Ext.Template.GetAllRootTemplates()) do
--         if template.TemplateType then
--             local type = template.TemplateType
--             -- Create typ entry if it doesn't exist 
--             if not sortedTemplates[type] then
--                 sortedTemplates[type] = {}
--             end
--             -- fill entry with value
--             table.insert(sortedTemplates[type], Ext.Types.Serialize(template))
--         else
--             if not sortedTemplates["No Type"] then
--                 sortedTemplates["No Type"] = {}
--             end
--             -- fill entry with value
--             table.insert(sortedTemplates["No Type"], Ext.Types.Serialize(template))
--         end
--     end

--     -- _D(sortedTemplates["item"])

--     for type,template in pairs(sortedTemplates) do
--         Ext.Net.PostMessageToServer("DECOR_SendTemplatesToServer", Ext.Json.Stringify({templates = sortedTemplates[type], type = type}))
--     end
--     -- _D(sortedTemplates[1])
-- end)

-- Ext.RegisterNetListener("DECOR_AddToUndo", function(e, payload)
--     local undo = Ext.Json.Parse(payload)
--     table.insert(DECOR.undoList, undo)
-- end)