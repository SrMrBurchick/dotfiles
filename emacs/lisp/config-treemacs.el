;;; config-treemacs.el --- On-demand project tree -*- lexical-binding: t; -*-
(use-package treemacs
  :if (locate-library "treemacs")
  :commands (treemacs treemacs-add-and-display-current-project-exclusively)
  :init
  (setq treemacs-width 32 treemacs-follow-after-init nil
        treemacs-is-never-other-window t)
  :config
  (treemacs-git-mode -1)
  (treemacs-filewatch-mode -1)
  (treemacs-follow-mode -1)
  (treemacs-fringe-indicator-mode -1)
  (add-to-list 'treemacs-ignored-file-predicates
               (lambda (file _absolute)
                 (member file my-project-excludes)))
  (when (locate-library "treemacs-evil") (require 'treemacs-evil)))
(defun my-treemacs-toggle ()
  (interactive)
  (unless (require 'treemacs nil t) (user-error "Run M-x my-install-packages first"))
  (if (treemacs-get-local-window) (treemacs)
    (let ((default-directory (my-project-root)))
      (treemacs-add-and-display-current-project-exclusively))))
(provide 'config-treemacs)
