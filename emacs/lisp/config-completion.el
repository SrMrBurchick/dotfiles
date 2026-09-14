;;; config-completion.el --- Small completion stack -*- lexical-binding: t; -*-
(setq completion-styles '(basic partial-completion)
      completion-category-defaults nil
      tab-always-indent 'complete)
(icomplete-mode 1)
(use-package corfu
  :if (locate-library "corfu")
  :hook ((prog-mode . corfu-mode))
  :init
  (setq corfu-auto t corfu-auto-delay 0.3 corfu-auto-prefix 2
        corfu-cycle t corfu-preview-current nil)
  :config
  (define-key corfu-map (kbd "TAB") #'corfu-next)
  (define-key corfu-map [tab] #'corfu-next)
  (define-key corfu-map [backtab] #'corfu-previous)
  (define-key corfu-map (kbd "S-TAB") #'corfu-previous)
  (define-key corfu-map (kbd "RET") #'corfu-insert)
  (define-key corfu-map [escape] #'corfu-quit))
(global-set-key (kbd "C-SPC") #'completion-at-point)
(with-eval-after-load 'evil
  (define-key evil-insert-state-map (kbd "C-SPC") #'completion-at-point))
(setq eldoc-idle-delay 0.8 eldoc-echo-area-use-multiline-p nil
      eldoc-display-functions '(eldoc-display-in-buffer))
(provide 'config-completion)
