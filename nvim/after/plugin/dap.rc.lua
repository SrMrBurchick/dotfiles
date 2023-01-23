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

-- C++ adapters
dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        -- CHANGE THIS to your path!
        command = vim.fn.stdpath "data" .. '/mason/packages/codelldb/extension/adapter/codelldb',
        args = { "--port", "${port}" },

        -- On windows you may have to uncomment this:
        -- detached = false,
    }
}

dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = "gdb",
    options = {
        detached = false
    }
}

dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode',
    name = 'lldb',
}

dap.adapters.cppvsdbg = {
    type = 'executable',
    command = vim.fn.stdpath "data" .. '/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
    MIMode = 'gdb'
}

dap.configurations.cpp = {
    {
        name = "(CPPDB) Launch",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
    },
    {
        name = "(LLDB) Launch",
        type = "lldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
    },
}

dap.configurations.c = dap.configurations.cpp

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
keymap.set('n', '<F5>', function ()
    vim.cmd [[ :DapLoadLaunchJSON ]]
    vim.cmd [[ :DapContinue ]]
end)

keymap.set('n', '<F5>', function ()
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
