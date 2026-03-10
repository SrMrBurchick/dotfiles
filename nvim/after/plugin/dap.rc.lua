local status, mason_dap = pcall(require, "mason-nvim-dap")
if (not status) then
	vim.notify("Failed to load Mason-DAP")
	return
end

mason_dap.setup({
	ensure_installed = {"cppdbg"},
    automatic_installation = true,
	handlers = {}
})

function tableToString(tbl)
    local result = "{ "
    for key, value in pairs(tbl) do
        -- Handle keys and values
        if type(key) == "string" then
            key = "\"" .. key .. "\""
        end
        if type(value) == "string" then
            value = "\"" .. value .. "\""
        end
        
        result = result .. "[" .. key .. "] = " .. tostring(value) .. ", "
    end
    -- Remove the last comma and space
    result = result:sub(1, -3) .. " }"
    return result
end

-- dap.adapters = adapters;
-- dap.filetypes = filetypes;
-- dap.configurations.rust = dap.configurations.cpp


-- -- VSCode launch
-- local vscode = {}
-- status, vscode = pcall(require, 'dap.ext.vscode')
-- if status then
--     vscode.type_to_filetypes = {
--         cppdbg = { 'c', 'cpp' },
--         lldb = { 'c', 'cpp' },
--         codelldb = { 'c', 'cpp' },
--         cppvsdbg= { 'c', 'cpp' },
--     }
-- end

-- VSCode launch
-- local json5 = {}
-- status, json5 = pcall(require, "json5")
-- if status then
--     dap.ext.vscode.json_decode = json5.parse
-- end

-- Icons
vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })

-- Key maps
local keymap = vim.keymap
keymap.set('n', '<F5>', function()
    vim.cmd [[ :DapContinue ]]
end)

keymap.set('n', '<F10>', '<Cmd>DapStepOver<CR>')
keymap.set('n', '<F11>', '<Cmd>DapStepInto<CR>')
keymap.set('n', '<F12>', '<Cmd>DapStepOut<CR>')
keymap.set('n', '<F9>', '<Cmd>DapToggleBreakpoint<CR>')
keymap.set('n', '<c-F9>', '<Cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')

-- DAP UI
local dapui = {}

status, dapui = pcall(require, "dapui")
if (not status) then
    print("DAP UI failed to load")
    return
end

dapui.setup()

local dap = {};
status, dap = pcall(require, "dap")
if (not status) then
	vim.notify("Failed to load DAP")
	return
end

local adapters = require('mason-nvim-dap.mappings.adapters')
local filetypes = require('mason-nvim-dap.mappings.filetypes')
local configurations = require('mason-nvim-dap.mappings.configurations')
-- dap.configurations = configurations;
vim.notify("DAP adapters = " .. #dap.adapters)
vim.notify("DAP filetypes = " .. #filetypes)
vim.notify("DAP configurations = " .. tableToString(dap.configurations))


dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
