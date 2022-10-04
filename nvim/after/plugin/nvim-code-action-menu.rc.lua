local status, code_action = pcall(require, 'code_action_menu')
if (not status) then
    print("nvim-code-action-menu not installed")
    return
end

