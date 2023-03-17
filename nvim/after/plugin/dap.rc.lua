local status, dap = pcall(require, "dap")
if (not status) then return end

-- VSCode launch
local vscode = {}
status, vscode = pcall(require, 'dap.ext.vscode')
if status then
    vscode.type_to_filetypes = {
        cppdbg = { 'c', 'cpp' },
        lldb = { 'c', 'cpp' },
        codelldb = { 'c', 'cpp' },
        -- cppvsdbg= { 'c', 'cpp' },
    }
end

-- VSCode launch
local json5 = {}
status, json5 = pcall(require, "json5")
if status then
    dap.ext.vscode.json_decode = json5.parse
end

-- Icons
vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })

-- Key maps
local keymap = vim.keymap
keymap.set('n', '<F5>', function()
    vim.cmd [[ :DapLoadLaunchJSON ]]
    vim.cmd [[ :DapContinue ]]
end)

keymap.set('n', '<F5>', function()
    vim.cmd [[ :DapLoadLaunchJSON ]]
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
if (not status) then return end

dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
