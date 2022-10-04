local M = {}

local clang_new_line = '"command": "\\"clang.exe\\" @\\"C:\\\\Users\\\\s.Bura\\\\.config\\\\nvim\\\\clang-flags.txt\\" '

local function is_valid(file)
    for line in io.lines(file) do
        if line:find("clang-flags.txt") then
            return true
        end
    end

    return false
end

local function lines_from(file)
    local lines = {}

    for line in io.lines(file) do
        lines[#lines+1] = line
    end

    return lines

end

local function update_compile_commands(file_name)
    if is_valid(file_name) then
        return
    end


    local lines = lines_from(file_name)
    if #lines == 0 then
        return
    end

    for k, value in pairs(lines) do
        if string.find(value, "cl") then
            local index = string.find(value, "@")
            local new_line = string.sub(value, index)
            lines[k] = clang_new_line .. new_line
        end
    end

    local file = io.open(file_name, "w+")
    if not file then
        return
    end

    for _, value in ipairs(lines) do
        if string.find(value, "clang++") then
            file:write("\t\t", value, "\n")
        else
            file:write(value, "\n")
        end

    end

    file:close()
end


local function copy_compile_commands(compile_commands)
    local src = io.open(compile_commands, "r")
    local dst = io.open("compile_commands.json", "w+")

    if not src or not dst then
        print("Filed to open %s, or compile_commands.json", compile_commands)
        return
    end

    dst:write(src:read("*a"))

    src:close()
    dst:close()
end


local function parse_vscode_compile_commands(compile_commands)
    if type(compile_commands) ~= "table" then
        print("Invalid compile_commands type: %s", type(compile_commands))
        return
    end

    local default = ""
    local project = ""

    for _, value in pairs(compile_commands) do
        if value:find("Default") then
            default = ".vscode/" .. value
        else
            project = ".vscode/" .. value
        end
    end

    if project ~= "" then
        copy_compile_commands(project)
    else
        copy_compile_commands(default)
    end

    update_compile_commands("compile_commands.json")
end

local function search_vscode_compile_commands()
    local compile_commands = {}
    for dir in io.popen([[dir ".vscode/" /b /ad]]):lines() do
        local t = {}
        dir:gsub("[^%s]+",function(c) table.insert(t,c) end)
        for key, value in pairs(t) do
            if value and value:find("compileCommands_") and value:find("json") then
                compile_commands[key] = value
            end
        end
    end

    parse_vscode_compile_commands(compile_commands)
end

function M.unreal_engine_cpp_setup()
    local compile_commands_file = "compile_commands.json"
    local file = io.open(compile_commands_file, 'r')

    if (not file) then
        print("No compile_commands.json found")
        search_vscode_compile_commands()
        return
    else
        file:close()

        update_compile_commands(compile_commands_file)
    end

end

return M
