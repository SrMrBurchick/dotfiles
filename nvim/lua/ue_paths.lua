-- Editor search/explorer exclusions only. Never apply these to clangd includes.
local M = {}
M.outputs = { 'Binaries', 'DerivedDataCache', 'Intermediate', 'Saved', '.vs' }
function M.is_output(path)
    for part in path:gsub('\\', '/'):gmatch('[^/]+') do
        for _, name in ipairs(M.outputs) do
            if part:lower() == name:lower() then return true end
        end
    end
    return false
end
function M.is_tree_ignored(path)
    if M.is_output(path) then return true end
    local defaults = { ['.ccls-cache'] = true, build = true, node_modules = true,
        target = true, ['.zig-cache'] = true }
    for part in path:gsub('\\', '/'):gmatch('[^/]+') do
        if defaults[part] then return true end
    end
    return false
end
function M.ignore_patterns()
    local patterns = {}
    for _, name in ipairs(M.outputs) do
        local escaped = name:gsub('%.', '%%.')
        table.insert(patterns, '[/\\]' .. escaped .. '[/\\]')
        table.insert(patterns, '[/\\]' .. escaped .. '$')
        table.insert(patterns, '^' .. escaped .. '[/\\]')
        table.insert(patterns, '^' .. escaped .. '$')
    end
    return patterns
end
function M.rg_args()
    local args = {}
    for _, name in ipairs(M.outputs) do
        vim.list_extend(args, { '--glob', '!**/' .. name .. '/**' })
    end
    return args
end
return M
