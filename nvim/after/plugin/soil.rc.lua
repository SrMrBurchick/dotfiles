local status, soil = pcall(require, 'soil')
if (not status) then
    return
end

soil.setup({
    opts = {
        actions = {
            redraw = true
        }
    },
    image = {
        darkmode = true,
        execute_to_open = function(img)
        end
    }
})

-- Render only the saved file. Coalesce saves while a render is running.
-- Preserve job state across :source so reloads cannot spawn duplicate renders.
_G.config_plantuml_jobs = _G.config_plantuml_jobs or {}
local jobs = _G.config_plantuml_jobs
local function render(path)
    if jobs[path] then jobs[path].pending = true; return end
    local state = {}
    jobs[path] = state
    local ok, job = pcall(vim.system, { 'plantuml', '-darkmode', path }, { text = true }, vim.schedule_wrap(function(result)
        jobs[path] = nil
        if result.code ~= 0 then
            vim.notify('PlantUML: ' .. (result.stderr or ''), vim.log.levels.WARN)
        end
        if state.pending then render(path) end
    end))
    if ok then
        state.job = job
    else
        jobs[path] = nil
        vim.notify(tostring(job), vim.log.levels.ERROR)
    end
end
vim.api.nvim_create_autocmd('BufWritePost', {
    group = vim.api.nvim_create_augroup('ConfigPlantuml', { clear = true }),
    pattern = '*.puml',
    callback = function(args) render(vim.api.nvim_buf_get_name(args.buf)) end,
})
