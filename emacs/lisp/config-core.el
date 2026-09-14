;;; config-core.el --- Editing and process utilities -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'subr-x)
(require 'compile)
(defgroup my-unreal nil "Lightweight Unreal workstation." :group 'tools)
(defconst my-cache-directory (expand-file-name "var/" user-emacs-directory))
(make-directory my-cache-directory t)
(prefer-coding-system 'utf-8-unix)
(setq-default indent-tabs-mode nil tab-width 4 truncate-lines t)
(setq backup-directory-alist `(("." . ,my-cache-directory))
      auto-save-file-name-transforms `((".*" ,my-cache-directory t))
      auto-save-list-file-prefix (expand-file-name "auto-save-" my-cache-directory)
      create-lockfiles nil
      vc-handled-backends nil
      undo-limit (* 8 1024 1024) undo-strong-limit (* 12 1024 1024)
      undo-outer-limit (* 128 1024 1024)
      save-place-file (expand-file-name "places" my-cache-directory)
      savehist-file (expand-file-name "history" my-cache-directory)
      recentf-save-file (expand-file-name "recentf" my-cache-directory)
      recentf-max-saved-items 150 recentf-auto-cleanup 'never
      auto-revert-interval 3 auto-revert-verbose nil
      auto-revert-use-notify nil ; Avoid thousands of OS watchers.
      auto-revert-remote-files nil
      read-process-output-max (* 1024 1024))
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(defcustom my-large-file-bytes (* 5 1024 1024)
  "Files larger than this open in fundamental mode without LSP."
  :type 'integer :group 'my-unreal)
(defvar-local my-large-file-p nil)
(defun my-large-file-check (original &rest args)
  "Bypass mode detection entirely for large visited files."
  (if (and buffer-file-name (> (buffer-size) my-large-file-bytes))
      (progn
        (fundamental-mode)
        (setq-local my-large-file-p t buffer-undo-list t)
        (message "Large file: plain text, undo and LSP disabled"))
    (apply original args)))
(advice-add 'normal-mode :around #'my-large-file-check)
(global-so-long-mode 1)
(defun my-programming-ui ()
  (unless my-large-file-p
    (setq-local display-line-numbers 'relative)
    (setq-local truncate-lines t)))
(add-hook 'prog-mode-hook #'my-programming-ui)
(defun my-executable (name)
  "Return NAME's executable or give an actionable error."
  (or (executable-find name)
      (user-error "Cannot find %s; install it, add it to Windows PATH, restart Emacs" name)))
(defun my-process-output (name program args &optional directory)
  "Run PROGRAM with literal ARGS asynchronously in DIRECTORY."
  (let* ((default-directory (or directory default-directory))
         (buffer (generate-new-buffer (format "*%s*" name))))
    (with-current-buffer buffer (compilation-mode))
    (make-process :name name :buffer buffer :noquery t
                  :connection-type 'pipe :command (cons program args)
                  :sentinel (lambda (process event)
                              (when (buffer-live-p (process-buffer process))
                                (with-current-buffer (process-buffer process)
                                  (let ((inhibit-read-only t))
                                    (goto-char (point-max))
                                    (insert "\n" event))))))
    (display-buffer buffer)))
(provide 'config-core)
