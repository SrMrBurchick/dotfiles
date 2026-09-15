local ok, startup = pcall(require, 'startup')
if ok then startup.setup() end
