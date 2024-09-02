DECOR = {}
DECOR.__index = DECOR

local devMode
local function inDev()
    if devMode == true then
        return true
    else
        return false
    end
end

local function stringContains(str, sub)
    -- Helper function to remove spaces and convert to lowercase
    local function normalize(s)
        return s:gsub("%s+", ""):lower() -- Remove spaces and convert to lowercase
    end

    -- Normalize the input string by removing spaces and converting to lowercase
    local normalizedStr = normalize(str)

    -- Split the substring into words by space, normalize them, and check each one
    local words = {}
    for word in sub:gmatch("%S+") do
        table.insert(words, normalize(word))
    end

    -- Check if all words are present in the normalized string
    for _, word in ipairs(words) do
        if not string.find(normalizedStr, word, 1, true) then
            return false
        end
    end

    return true
end


local function search(txt, templateButtons, templates, typeButtons)
    local foundTypes = {}
    local type

    for _,template in pairs(templates) do
        if stringContains(template.Name, txt) then
            type = template.TemplateType
        end
    end
    
    for _,typeButton in pairs(typeButtons) do
        if typeButton.Label == tostring(type) then
            typeButton.Visible = true
        else
            typeButton.Visible = false
        end
    end

    for _,templateButton in pairs(templateButtons) do
        if stringContains(templateButton.Label, txt) then
            templateButton.Visible = true
        else
            templateButton.Visible = false
        end
    end

    -- -- First, determine which templates match the search criteria
    -- local matchingTemplates = {}
    -- for _, template in pairs(templates) do
    --     if stringContains(template.Name, txt) then
    --         table.insert(matchingTemplates, template)
    --         foundTypes[template.TemplateType] = true
    --     end
    -- end

    -- -- Adjust visibility of ImGui elements based on the matching templates
    -- for _, element in pairs(tbl) do
    --     local isVisible = false
    --     for _, template in pairs(matchingTemplates) do
    --         if stringContains(element.Label, template.Name) then
    --             isVisible = true
    --             break
    --         end
    --     end
    --     element.Visible = isVisible
    -- end

    -- -- Adjust visibility of type buttons based on found template types
    -- for _, typeButton in pairs(typeButtons) do
    --     local templateType = typeButton.Label
    --     if foundTypes[templateType] or normalizedTxt == "" then
    --         typeButton.Visible = true
    --     else
    --         typeButton.Visible = false
    --     end
    -- end

    -- -- Make everything visible if the search string is empty
    -- if normalizedTxt == "" then
    --     for _, element in pairs(tbl) do
    --         element.Visible = true
    --     end
    --     for _, typeButton in pairs(typeButtons) do
    --         typeButton.Visible = true
    --     end
    -- end
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

local function getSortedRootTemplates()
    local sortedTemplates = {}
    for _, template in pairs(Ext.Template.GetAllRootTemplates()) do
        if template.TemplateType then
            local type = template.TemplateType
            -- Create typ entry if it doesn't exist 
            if not sortedTemplates[type] then
                sortedTemplates[type] = {}
            end
            -- fill entry with value
            table.insert(sortedTemplates[type], Ext.Types.Serialize(template))
        else
            if not sortedTemplates["No Type"] then
                sortedTemplates["No Type"] = {}
            end
            -- fill entry with value
            table.insert(sortedTemplates["No Type"], Ext.Types.Serialize(template))
        end
    end
    table.sort(sortedTemplates)
    return sortedTemplates
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
        Ext.Net.PostMessageToServer("DECOR_SpawnObject", Ext.Json.Stringify(template.Id))
    end
    infoRow:AddCell():AddButton("World")
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
                    local comp = compArea:AddText(compname)
                    local value = compArea:AddInputText("")
                    value.Text = compcont
                    value.SameLine = true

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



local function createModTab(tab)
    -- Developer Mode
    ------------------------------------------------------------
    local dev = tab:AddCheckbox("Developer Mode")
    dev.Visible = false -- NYI
    dev.OnChange = function()
        devMode = true
    end


    -- Search Bar
    ------------------------------------------------------------
    local searchbar = tab:AddInputText("")
    searchbar.Text = "Search"
    -- searchbar.SameLine = true -- "dev" NYI


    -- General structure
    ------------------------------------------------------------
    local t = tab:AddTable("", 1)
    -- t.IDContext = "t"
    t.Borders = true
    t.SizingStretchProp = true
    local trow = t:AddRow()
    local tl = trow:AddCell()
    local tlT = tl:AddTable("", 1)
    -- tlT.SizingStretchProp = true
    local trT
    local trC


    -- Search stuff
    ------------------------------------------------------------
    local areas = {}
    local typeButtons = {}
    local searchTable = {}


    -- Template Buttons
    ------------------------------------------------------------
    local sortedTemplates = getSortedRootTemplates()
    for type,templates in pairs(sortedTemplates) do
        local typeButton = tlT:AddRow():AddCell():AddButton(tostring(type))
        table.insert(typeButtons, typeButton)
        typeButton.OnClick = function()
            if t.Columns == 1 then
                t.Columns = 2
                trC = t:AddColumn("")
                trT = trow:AddCell():AddTable("",1)
                trT.SizingStretchProp = true
                trT.Borders = true
            end
            areas = buildTemplateSide(trT)
            searchTable = populateAreas(templates, areas)

        end
    end


    -- Search
    ------------------------------------------------------------
    searchbar.OnChange = function()
        if #areas > 0 then
            for _,area in pairs(areas) do
                if area ~= areas[3] then
                    destroyChildren(area)
                end
            end
        end
        search(searchbar.Text, searchTable, sortedTemplates, typeButtons)
    end
end


Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Object Browser", function(tab)
    createModTab(tab)
end)