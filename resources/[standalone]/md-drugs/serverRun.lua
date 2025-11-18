-- Check if ps_lib is available before loading any scripts
if not ps then
    print("^1[md-drugs] ERROR: ps_lib is not available. Cannot load drug scripts.^0")
    print("^1[md-drugs] Please install and start ps_lib before md-drugs.^0")
    print("^1[md-drugs] Download from: https://github.com/Project-Sloth/ps_lib^0")
    return
end

function loadFile(filePath)
    local resourceName = 'md-drugs'
    local fullScript = LoadResourceFile(resourceName, filePath)
    if not fullScript then
        local errorMsg = "Error: Failed to load module '" .. filePath .. "' from resource '" .. resourceName .. "'."
        if ps and ps.error then
            ps.error(errorMsg)
        else
            print("^1[md-drugs] " .. errorMsg .. "^0")
        end
        return false
    end
    local chunk, err = load(fullScript, filePath, "t")
    if not chunk then
        local errorMsg = "Error loading Lua chunk from '" .. filePath .. "': " .. tostring(err)
        if ps and ps.error then
            ps.error(errorMsg)
        else
            print("^1[md-drugs] " .. errorMsg .. "^0")
        end
        return false
    end

    local success, execErr = pcall(chunk)
    if not success then
        local errorMsg = "Error executing Lua chunk from '" .. filePath .. "': " .. tostring(execErr)
        if ps and ps.error then
            ps.error(errorMsg)
        else
            print("^1[md-drugs] " .. errorMsg .. "^0")
        end
        return false
    end
    return true
end

-- Check if Config and Config.Drugs exist before iterating
if Config and Config.Drugs then
    for scriptName, toggle in pairs(Config.Drugs) do
        if not toggle then goto continue end
        loadFile('server/' .. scriptName .. '.lua')
        ::continue::
    end
else
    print("^1[md-drugs] ERROR: Config or Config.Drugs is nil. Cannot load drug scripts.^0")
    print("^1[md-drugs] Make sure ps_lib is installed and started before md-drugs.^0")
end