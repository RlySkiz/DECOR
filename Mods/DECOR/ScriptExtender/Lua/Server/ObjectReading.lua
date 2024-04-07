-- Loaded from additional mods
DecorObjects = {}

-- Read JSON file and populate DecorObjects table
--@param filePath string The path to the JSON file
function readObject(filePath)
    -- Load JSON file content
    local jsonContent = Ext.IO.LoadFile(filePath)
    print(jsonContent)
    print("1")
    if jsonContent == nil then
        -- Handle file loading error
        print("Failed to load JSON file:", filePath)
        print("2")
        return
    end

    -- Split JSON content by lines
    local lines = {}
    for line in string.gmatch(jsonContent, "[^\r\n]+") do
        table.insert(lines, line)
        print("3")
    end

    -- Extract name and UUID manually
    local name, uuid
    for _, line in ipairs(lines) do
        print("4")
        local key, value = string.match(line, '"(%w+)"%s*:%s*"(.*)"')
        if key == "Name" then
            name = value
            print("4,1")
        elseif key == "UUID" then
            uuid = value
            print("4,2")
        end
    end

    -- Check if both name and uuid are extracted
    if name and uuid then
        -- Store the data in DecorObjects
        DecorObjects[name] = uuid
        print("5")
    else
        -- Handle missing keys error
        print("Missing keys in JSON:", filePath)
    end
end

-- Example usage:
function readJson(cmd, filePath)
    print("readJson initialized")
    readObject(filePath)
end

-- Access data in DecorObjects
for name, uuid in pairs(DecorObjects) do
    print("Name:", name, "UUID:", uuid)
    print("6")
end

function getList(cmd)
    _P(DecorObjects)
    _D(DecorObjects)
    return DecorObjects
end

Ext.RegisterConsoleCommand("readJson", readJson)
Ext.RegisterConsoleCommand("getList", getList)