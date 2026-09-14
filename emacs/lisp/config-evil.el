;;; config-evil.el --- Vim editing -*- lexical-binding: t; -*-
(use-package evil
  :if (locate-library "evil")
  :demand t
  :init
  (setq evil-want-C-u-scroll t evil-want-C-d-scroll t
        evil-want-keybinding nil evil-undo-system 'undo-redo
        evil-want-integration t)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") #'evil-normal-state))
(dolist (map (list minibuffer-local-map minibuffer-local-ns-map
                   minibuffer-local-completion-map
                   minibuffer-local-must-match-map))
  (define-key map [escape] #'abort-recursive-edit))
(provide 'config-evil)
