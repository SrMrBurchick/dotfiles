;;; config-completion.el --- Small completion stack -*- lexical-binding: t; -*-
(setq tab-always-indent 'complete)
(use-package vertico
  :if (locate-library "vertico")
  :demand t
  :config (vertico-mode 1))
(use-package orderless
  :if (locate-library "orderless")
  :demand t
  :config
  (setq completion-styles '(orderless basic)
        orderless-matching-styles '(orderless-literal orderless-flex)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion orderless)))))
(use-package marginalia
  :if (locate-library "marginalia")
  :demand t
  :config (marginalia-mode 1))
(use-package consult
  :if (locate-library "consult")
  :commands (consult-buffer consult-ripgrep consult-recent-file)
  :init
  ;; Explicit preview avoids opening Unreal headers while merely browsing names.
  (setq consult-preview-key "M-."))
(defun my-switch-buffer ()
  "Search open buffers; retain Consult's hidden-buffer escape hatch."
  (interactive)
  (if (require 'consult nil t)
      (let ((consult-buffer-sources '(consult-source-buffer consult-source-hidden-buffer)))
        (consult-buffer))
    (call-interactively #'switch-to-buffer)))
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
