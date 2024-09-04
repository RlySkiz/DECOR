DECOR = {}
DECOR.__index = DECOR

local devMode
local deleteMode = false
local function inDev()
    if devMode == true then
        return true
    else
        return false
    end
end
-- local function toggleDeleteMode()
--     if deleteMode == true then
--         return true
--     else
--         return false
--     end
-- end

---------------------------------------------------------------------------------------------------
--                                          Helper
---------------------------------------------------------------------------------------------------

local function stringContains(str, sub)
    local function normalize(s)
        return s:gsub("%s+", ""):lower() -- Remove spaces and convert to lowercase
    end
    local normalizedStr = normalize(str)
    local words = {}
    for word in sub:gmatch("%S+") do
        table.insert(words, normalize(word))
    end
    for _, word in ipairs(words) do
        if not string.find(normalizedStr, word, 1, true) then
            return false
        end
    end
    return true
end

local function search(txt, tbl)
    for _,element in pairs(tbl) do
        if stringContains(element.Label, txt) then
            element.Visible = true
        else
            element.Visible = false
        end
    end
end

local function IsScalar(v) -- by Norbyte
    local ty = Ext.Types.GetValueType(v)
    return ty == "nil" or ty == "string" or ty == "number" or ty == "boolean" or ty == "Enum" or ty == "Bitfield"
end

local function destroyChildren(obj)
    if obj.Children and #obj.Children > 0 then
        for _,child in pairs(obj.Children) do
            child:Destroy()
        end
    end
end

-- local function recursiveSort(t)
--     -- Sort the table keys
--     local sortedKeys = {}
--     for key in pairs(t) do
--         table.insert(sortedKeys, key)
--     end
--     table.sort(sortedKeys)

--     -- Sort the nested tables or the table values
--     for _, key in ipairs(sortedKeys) do
--         local value = t[key]
--         if type(value) == "table" then
--             recursiveSort(value)  -- Recursively sort nested tables
--         end
--     end

--     -- Rebuild the table with sorted keys
--     local sortedTable = {}
--     for _, key in ipairs(sortedKeys) do
--         sortedTable[key] = t[key]
--     end

--     -- Clear the original table and reinsert sorted entries
--     for k in pairs(t) do t[k] = nil end
--     for k, v in pairs(sortedTable) do t[k] = v end
-- end

---------------------------------------------------------------------------------------------------
--                                          Data
---------------------------------------------------------------------------------------------------

local function getSortedRootTemplates()
    local sortedTemplates = {}
    local typeOrder = {}

    -- Gather templates by type
    for _, template in pairs(Ext.Template.GetAllRootTemplates()) do
        local type = template.TemplateType or "No Type"
        -- Create type entry if it doesn't exist
        if not sortedTemplates[type] then
            sortedTemplates[type] = {}
            table.insert(typeOrder, type) -- Insert type into typeOrder
        end
        -- Fill entry with value
        table.insert(sortedTemplates[type], Ext.Types.Serialize(template))
    end

    -- Sort the content within each type
    for type, templates in pairs(sortedTemplates) do
        table.sort(templates, function(a, b)
            return a.Name < b.Name -- Assuming templates have a Name field; adjust as needed
        end)
    end

    -- Sort the types
    table.sort(typeOrder, function(a, b)
        return a < b -- Sort types alphabetically
    end)

    -- Rebuild final sorted table by sorted type names
    local finalSortedTemplates = {}
    for _, type in ipairs(typeOrder) do
        finalSortedTemplates[type] = sortedTemplates[type]
    end
    return finalSortedTemplates
end

local function buildInfo(template, parent)
    destroyChildren(parent)
    local infoTable = parent:AddTable("",3)
    -- infoTable.Borders = true
    local infoRow = infoTable:AddRow()

    if template.Icon then
        infoRow:AddCell():AddImageButton(template.Icon, template.Icon, {50,50})
    end
    local spawnButton = infoRow:AddCell():AddButton("Spawn")
    spawnButton.OnClick = function()
        Ext.Net.PostMessageToServer("DECOR_SpawnObject", Ext.Json.Stringify({template = template.Id, weight = "normal"}))
    end
    local spawnWLButton = infoRow:AddCell():AddButton("Spawn Weightless/Movable")
    spawnWLButton.SameLine = true
    spawnWLButton.OnClick = function()
        Ext.Net.PostMessageToServer("DECOR_SpawnObject", Ext.Json.Stringify({template = template.Id, weight = "weightless"}))
    end
end


local function tryGetComponentValue(template, previousComponent, componentsToCheck)
    local template = Ext.Template.GetTemplate(template)
    _P("Trying to get component value")
    
    
    local remainingComponents = {}
    local function getDeeperComponent(template, remainingComponents)
        if #remainingComponents == 1 then
        end
    end

    for _,component in pairs(template) do
        for _,componentToCheck in pairs(componentsToCheck) do
            if component == componentToCheck then
            end
        end
        -- if #components == 1 then -- End of recursion
        --     if not previousComponent then
        --         local value = Helper:GetPropertyOrDefault(entity, components[1], nil)
        --         return value
        --     else
        --         local value = Helper:GetPropertyOrDefault(previousComponent, components[1], nil)
        --         return value
        --     end
        -- end

        -- local currentComponent
        -- if not previousComponent then -- Recursion
        --     currentComponent = Helper:GetPropertyOrDefault(entity, components[1], nil)
        --     -- obscure cases
        --     if not currentComponent then
        --         return nil
        --     end
        -- else
        --     currentComponent = Helper:GetPropertyOrDefault(previousComponent, components[1], nil)
        -- end

        -- table.remove(components, 1)

        -- -- Return the result of the recursive call
        -- return Entity:TryGetEntityValue(uuid, currentComponent, components)
    end
    getDeeperComponent(template, {remainingComponents})
end

local function valueChange(newVal, template, components)
    local compVal = tryGetComponentValue(template, nil, components)
    _P("Setting new Value")
    compVal = newVal
end

---------------------------------------------------------------------------------------------------
--                                          Structure
---------------------------------------------------------------------------------------------------

local function buildComponents(template, parent)
    local origTemplate = Ext.Template.GetTemplate(template)
    destroyChildren(parent)

    local function recursiveBuildComponents(componentContent, parent)
        local compTable = parent:AddTable("",1)
        compTable.SizingStretchProp = true
        -- compTable.Borders = true
        local compArea = compTable:AddRow():AddCell()

        for compname,compcont in pairs(componentContent) do
            if IsScalar(compcont) then
                if type(compcont) == "string" then
                    local comp = compArea:AddText(compname .. ":")
                    local value = compArea:AddInputText("")
                    value.Text = compcont
                    value.SameLine = false

                    local newValButton = compArea:AddButton("Save")
                    newValButton.SameLine = true
                    newValButton.Visible = false
                    newValButton.OnClick = function()
                        -- valueChange(value.Text, origTemplate, compname) -- NYI
                        newValButton.Visible = false
                    end

                    value.OnChange = function() -- If the Value changes, we want to create a "Save Button"
                        if inDev() then
                            newValButton.Visible = true
                        end
                    end
                else
                    local scalar = compArea:AddText(compname .. " = " .. tostring(compcont))
                end
            else
                local compnode = compArea:AddTree(compname)
                compnode.DefaultOpen = false
                compnode.OnClick = function()
                    destroyChildren(compnode)
                    for _,content in pairs(compcont) do
                        recursiveBuildComponents(compcont,compnode)
                    end
                end
            end
        end
    end
    recursiveBuildComponents(template, parent)
end

local function populateAreas(templates, areas)
    local searchTable = {}
    for _,template in pairs(templates) do
        local treetemp = areas[3]:AddButton(template.Name)
        -- treetemp.DefaultOpen = false
        -- treetemp.Bullet = true
        treetemp.OnClick = function()
            buildInfo(template, areas[1])
            buildComponents(template, areas[2])
        end
        table.insert(searchTable, treetemp)
    end
    return searchTable
end


local function buildTemplateSide(parent)
    local populationAreas = {}
    destroyChildren(parent)

    -- parent.ScrollY = true

    local infoRow = parent:AddRow()
    local infoTable = infoRow:AddCell():AddTable("",1)
    -- infoTable.Borders = true
    infoTable.SizingStretchProp = true
    -- infoTable.Visible = false
    local infoArea = infoTable:AddRow():AddCell()
    table.insert(populationAreas, infoArea)

    local compRow = parent:AddRow()
    local compTable = compRow:AddCell():AddTable("",1)
    compTable.ScrollY = true
    -- compTable.Borders = true
    compTable.SizingStretchProp = true
    -- compTable.Visible = false
    local compArea = compTable:AddRow():AddCell()
    table.insert(populationAreas, compArea)

    local tempplateRow = parent:AddRow()
    local templateTable = tempplateRow:AddCell():AddTable("",1)
    templateTable.ScrollY = true
    -- templateTable.Borders = true
    compTable.SizingStretchProp = true
    local templateArea = templateTable:AddRow():AddCell()
    table.insert(populationAreas, templateArea)

    return populationAreas
end

local makeMovable = false
local buildMode = false
local lockMode = false
local function dockerButtonFunction(button)
    makeMovable = false
    buildMode = false
    lockMode = false
    deleteMode = false
    -- Regardless of which button is pressed, it sets all modes to false initially
    if button == "Make Movable" then
        makeMovable = true
        return "Not yet implemented"
    elseif button == "Build Mode" then
        buildMode = true
        return "Not yet implemented"
    elseif button == "Undo" then
        Ext.Net.PostMessageToServer("DECOR_Undo", "")
        return
    elseif button == "Redo" then
        Ext.Net.PostMessageToServer("DECOR_Redo", "")
        return
    elseif button == "Lock Object" then
        lockMode = true
        return "Not yet implemented"
    elseif button == "Delete Mode" then
        deleteMode = true
        return "Not yet implemented"
    elseif button == "No Mode" then
        return
    end
end

local function buildBuildSection(parent)
    local buttons = {"Make Movable", "Build Mode", "Undo", "Redo", "Lock Object", "Delete Mode", "No Mode"}
    local docker = parent:AddTable("", #buttons)
    local dockerRow = docker:AddRow()
    local infoText = parent:AddText("")
    infoText.Visible = false
    for _,button in pairs(buttons) do
        local dockerButton = dockerRow:AddCell():AddButton(button)
        dockerButton.OnClick = function()
            local info = dockerButtonFunction(button)
            if info ~= nil then
                infoText.Label = info
                infoText.Visible = true
            else
                infoText.Visible = false
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
--                                          General Tab
---------------------------------------------------------------------------------------------------

local function createModTab(tab)
    local dev = tab:AddCheckbox("Developer Mode")
    dev.Visible = false -- NYI
    dev.OnChange = function()
        devMode = true
    end

    local searchbar = tab:AddInputText("")
    searchbar.Text = "Search"
    -- searchbar.SameLine = true -- "dev" NYI

    local dockerButtonBar = buildBuildSection(tab)

    -- local undoButton = tab:AddButton("Undo")
    -- undoButton.SameLine = true
    -- undoButton.OnClick = function()
    --     Ext.Net.PostMessageToServer("DECOR_Undo", "")
    --     -- table.remove(DECOR.undoList, #DECOR.undoList) -- Remove latest entry
    -- end

    -- local deleteBox = tab:AddCheckbox("Delete Mode")
    -- deleteBox.SameLine = true

    -- local deleteHelpTable = tab:AddTable("",2)
    -- local deleteHelpRow = deleteHelpTable:AddRow()
    -- deleteHelpTable.Visible = false
    -- local deleteHelp = deleteHelpRow:AddCell():AddText("Delete with Mouseover + F")
    -- local deleteDisclaimer = deleteHelpRow:AddCell():AddText("Only works on spawned items")

    
    -- deleteBox.OnChange = function()
    --     if deleteBox.Checked == true then
    --         deleteMode = true
    --         deleteHelpTable.Visible = true
    --     else
    --         deleteMode = false
    --         deleteHelpTable.Visible = false
    --     end
    -- end
    
    local t = tab:AddTable("", 1)
    -- t.IDContext = "t"
    t.Borders = true
    t.SizingStretchProp = true
    local trow = t:AddRow()
    local tl = trow:AddCell()
    local tlT = tl:AddTable("", 1)
    -- tlT.SizingStretchProp = true
    local trT

    local sortedTemplates = getSortedRootTemplates()
    for type,templates in pairs(sortedTemplates) do
        local typeButton = tlT:AddRow():AddCell():AddButton(tostring(type))
        
        typeButton.OnClick = function()
            if t.Columns == 1 then
                t.Columns = 2
                t:AddColumn("")
                trT = trow:AddCell():AddTable("",1)
                trT.SizingStretchProp = true
                trT.Borders = true
            end
            local areas = buildTemplateSide(trT)
            local searchTable = populateAreas(templates, areas)

            searchbar.OnChange = function()
                for _,area in pairs(areas) do
                    if area ~= areas[3] then
                        destroyChildren(area)
                    end
                end
                search(searchbar.Text, searchTable)
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
--                                          Mouseover
---------------------------------------------------------------------------------------------------

local function getMouseover()
    local mouseover = Ext.UI.GetPickingHelper(1)
    if mouseover ~= nil then
    -- setSavedMouseover(mouseover)
        return mouseover
    else
        _P("[DECOR] Not a viable mouseover!")
    end 
end

local function getUUIDFromUserdata(mouseover)
    local entity = mouseover.Inner.Inner[1].GameObject
    if entity ~= nil then
        return Ext.Entity.HandleToUuid(entity)
    else
        _P("[DECOR] getUUIDFromUserdata(mouseover) - Not an entity!")
    end
end

Ext.Events.KeyInput:Subscribe(function (e)
    if e.Event == "KeyDown" and e.Repeat == false then
        if e.Key == "F" then
            local uuid = getUUIDFromUserdata(getMouseover())
            if makeMovable == true then
                Ext.Net.PostMessageToServer("DECOR_RemoveObjectWeight", uuid)
            elseif buildMode == true then
                Ext.Net.PostMessageToServer("DECOR_SpawnObjectAtLocation", {uuid = uuid, location = getMouseover().Inner.Inner[1]}) -- need to find correct location component
            elseif lockMode == true then
                Ext.Net.PostMessageToServer("DECOR_LockObject", uuid)
            elseif deleteMode == true then
                Ext.Net.PostMessageToServer("DECOR_DeleteObject", uuid)
            end
        end
    end
end)

---------------------------------------------------------------------------------------------------
--                                       Load MCM Tab
---------------------------------------------------------------------------------------------------

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Object Browser", function(tab)
    createModTab(tab)
end)