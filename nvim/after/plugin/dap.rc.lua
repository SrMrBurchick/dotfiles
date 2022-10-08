local status, dap = pcall(require, "dap")
if (not status) then return end

dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        -- CHANGE THIS to your path!
        command = vim.fn.stdpath "data" .. '\\mason\\packages\\codelldb\\extension\\adapter\\codelldb.exe',
        args = { "--port", "${port}" },

        -- On windows you may have to uncomment this:
        -- detached = false,
    }
}

dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = vim.fn.stdpath "data" .. '\\mason\\packages\\cpptools\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe',
    options = {
        detached = false
    }
}

dap.adapters.lldb = {
    type = 'executable',
    command = 'lldb',
}

dap.adapters.vsdbg = {
    type = 'executable',
    command = vim.fn.stdpath "data" .. '\\mason\\packages\\cpptools\\extension\\debugAdapters\\vsdbg\\bin\\vsdbg.exe',
}


dap.configurations.cpp = {
    {
        name = "(cppDBG) Launch",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
    },
    {
        name = "(VSDBG) Launch",
        type = "vsdbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
    },
    {
        name = "(CodeLLDB) Launch",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
    },
    {
        name = "(Unreal Engine) Launch",
        type = "vsdbg",
        request = "launch",
        program = "D:\\Education\\UnrealEngine\\Engine\\Binaries\\Win64\\UE4Editor.exe",
        args = {
            "D:\\Projects\\MyProject\\MyProject.uproject"
        },
        cwd = 'D:\\Education\\UnrealEngine',
        stopAtEntry = true,
    },

    {
        name = 'Attach to gdbserver :1234',
        type = 'cppdbg',
        request = 'launch',
        MIMode = 'gdb',
        miDebuggerServerAddress = 'localhost:1234',
        miDebuggerPath = '/usr/bin/gdb',
        cwd = '${workspaceFolder}',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
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
keymap.set('n', '<F5>', '<Cmd>lua require"dap".continue()<CR>')
keymap.set('n', '<F10>', '<Cmd>lua require"dap".step_over()<CR>')
keymap.set('n', '<F11>', '<Cmd>lua require"dap".step_into()<CR>')
keymap.set('n', '<F12>', '<Cmd>lua require"dap".step_out()<CR>')
keymap.set('n', '<F9>', '<Cmd>lua require"dap".toggle_breakpoint()<CR>')
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
