-- Run: nvim --headless -u NONE -i NONE -l tests/clangd_audit.lua
-- Requires clangd on PATH; creates only a temporary project.
local config = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)))
vim.opt.rtp:prepend(config)
local clangd = require('clangd_setup')
local base = vim.fn.tempname()
local game = base .. '/Game'
vim.fn.mkdir(game .. '/Source/Module', 'p')
vim.fn.mkdir(game .. '/Intermediate', 'p')
vim.fn.mkdir(base .. '/Engine/Source', 'p')
vim.fn.writefile({ '{}' }, game .. '/Game.uproject')
vim.fn.writefile({ 'P4PORT=example:1666' }, base .. '/.p4config')
vim.fn.writefile({ '[]' }, game .. '/Intermediate/compile_commands.json')
vim.fn.writefile({ 'int add(int x, int y) { return x + y; }',
    'int main() { auto result = add(1, 2); return result + AUDIT_DB_FLAG; }' }, game .. '/Source/Module/test.cpp')
vim.fn.writefile({ 'int add(int x, int y);' }, game .. '/Source/Module/test.h')
vim.fn.writefile({ vim.json.encode({ {
    directory = game, file = game .. '/Source/Module/test.cpp',
    arguments = { 'clang++', '-DAUDIT_DB_FLAG=0', '-std=c++20', '-c', game .. '/Source/Module/test.cpp' },
} }) }, game .. '/compile_commands.json')
local function root(path, expected)
    local buf = vim.fn.bufadd(path)
    local found
    clangd.root_dir(buf, function(dir) found = dir end)
    assert(vim.wait(5000, function() return found ~= nil end), 'root timed out: ' .. path)
    assert(found == expected, path .. ': ' .. found .. ' != ' .. expected)
end
root(base .. '/Game/Source/Module/test.cpp', base .. '/Game')
root(base .. '/Game/Intermediate/generated.h', base .. '/Game')
root(base .. '/Engine/Source/test.cpp', base)
vim.t.root_dir = base .. '/Game'
root(base .. '/Engine/Source/test.cpp', base .. '/Game')
vim.t.root_dir = nil
local called = false
clangd.root_dir(vim.fn.bufadd(vim.fn.tempname() .. '/file.cpp'), function() called = true end)
vim.wait(200)
assert(not called, 'unmarked directory must not start clangd')
clangd.setup()
vim.cmd.edit(base .. '/Game/Source/Module/test.cpp')
vim.bo.filetype = 'cpp'
assert(vim.wait(10000, function()
    local c = vim.lsp.get_clients({ name = 'clangd', bufnr = 0 })
    return #c == 1 and c[1].initialized
end), 'clangd did not attach')
local clients = vim.lsp.get_clients({ name = 'clangd' })
assert(#clients == 1)
local client = clients[1]
assert(client.root_dir == base .. '/Game')
assert(client.server_capabilities.semanticTokensProvider == nil)
assert(vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }))
assert(client.config.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration == false)
for _, key in ipairs({ 'gd', 'gD', 'gi', 'ca', '<C-k>' }) do assert(vim.fn.maparg(key, 'n') ~= '', key) end
vim.cmd.ClangdToggleInlayHints()
assert(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }))
vim.cmd.ClangdToggleInlayHints()
assert(vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }))
local hints
client:request('textDocument/inlayHint', {
    textDocument = vim.lsp.util.make_text_document_params(),
    range = { start = { line = 0, character = 0 }, ['end'] = { line = 2, character = 0 } },
}, function(err, result) assert(not err, vim.inspect(err)); hints = result end, 0)
assert(vim.wait(10000, function() return hints ~= nil end), 'hint response timed out')
assert(#hints > 0, 'no native type/parameter hints')
local hover
client:request('textDocument/hover', {
    textDocument = vim.lsp.util.make_text_document_params(),
    position = { line = 1, character = 65 },
}, function(err, result) assert(not err, vim.inspect(err)); hover = result or false end, 0)
assert(vim.wait(5000, function() return hover ~= nil end), 'database hover timed out')
assert(hover and vim.inspect(hover):find('AUDIT_DB_FLAG'), 'compile database macro not resolved')
print('PASS: compile_commands.json macro resolved by real clangd')
vim.cmd.edit(base .. '/Game/Source/Module/test.h')
vim.bo.filetype = 'cpp'
assert(vim.wait(5000, function() return #vim.lsp.get_clients({ bufnr = 0, name = 'clangd' }) == 1 end))
assert(#vim.lsp.get_clients({ name = 'clangd' }) == 1, 'duplicate clangd')
clangd.setup()
assert(#vim.lsp.get_clients({ name = 'clangd' }) == 1)
print('PASS: roots, nested database, explicit Engine workspace, no-root guard, one client/two buffers, mappings, native hints/toggle, semantic token and watcher policy')
client:stop()
vim.wait(2000, function() return client:is_stopped() end)
vim.cmd.qa({ bang = true })
