local status, plantuml = pcall(require, 'plantuml')
if (not status) then
    return
end

local previewer = nil
status, previewer = pcall(require, 'plantuml-previewer')
if (not status) then
    return
end

plantuml.setup()
previewer.setup()
