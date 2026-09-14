;;; config-cpp.el --- Built-in C++, Eglot and xref -*- lexical-binding: t; -*-
(autoload 'eglot-ensure "eglot")
(autoload 'hs-minor-mode "hideshow")
(setq c-default-style '((java-mode . "java") (other . "bsd"))
      c-basic-offset 4 c-ts-mode-indent-offset 4
      c-ts-mode-indent-style 'bsd
      eglot-events-buffer-config '(:size 0 :format short)
      eglot-autoshutdown t eglot-sync-connect 0
      eglot-send-changes-idle-time 0.5
      eglot-ignored-server-capabilities
      '(:documentHighlightProvider :documentOnTypeFormattingProvider
        :foldingRangeProvider))
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
             '((c-mode c++-mode c-ts-mode c++-ts-mode)
               "clangd" "--background-index" "--clang-tidy=false"
               "--completion-style=detailed" "--header-insertion=never"
               "--log=error" "--function-arg-placeholders=true")))
(when (and (fboundp 'treesit-ready-p) (treesit-ready-p 'c t))
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode)))
(when (and (fboundp 'treesit-ready-p) (treesit-ready-p 'cpp t))
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode)))
(add-to-list 'auto-mode-alist '("\\.\\(h\\|hpp\\|inl\\|cpp\\|cc\\|cxx\\)\\'" . c++-mode))
(defcustom my-cpp-diagnostics-enabled t
  "Default Flymake state in Eglot C/C++ buffers; independently toggle per buffer."
  :type 'boolean :group 'my-unreal)
(make-variable-buffer-local 'my-cpp-diagnostics-enabled)
(defcustom my-cpp-inline-diagnostics-enabled t
  "Show compact native Flymake end-of-line diagnostic summaries."
  :type 'boolean :group 'my-unreal)
(make-variable-buffer-local 'my-cpp-inline-diagnostics-enabled)
(defvar-local my-cpp-inlay-hints-enabled t)
(defun my-cpp-toggle-diagnostics ()
  "Toggle Flymake without changing the inline preference or inlay hints."
  (interactive)
  (require 'flymake)
  (setq-local my-cpp-diagnostics-enabled (not flymake-mode))
  (flymake-mode (if my-cpp-diagnostics-enabled 1 -1))
  (message "Flymake %s" (if my-cpp-diagnostics-enabled "on" "off")))
(defun my-cpp-toggle-inline-diagnostics ()
  "Toggle native diagnostic overlays without enabling a disabled Flymake."
  (interactive)
  (require 'flymake)
  (setq-local my-cpp-inline-diagnostics-enabled (not my-cpp-inline-diagnostics-enabled)
              flymake-show-diagnostics-at-end-of-line
              (and my-cpp-inline-diagnostics-enabled 'short))
  ;; Public APIs clear old overlays and republish diagnostics after a toggle.
  ;; No polling, advice, per-keystroke refresh or private Flymake API is needed.
  (when flymake-mode (flymake-mode -1) (flymake-mode 1))
  (message "Inline diagnostics %s%s"
           (if my-cpp-inline-diagnostics-enabled "on" "off")
           (if flymake-mode "" " (Flymake is disabled)")))
(defun my-cpp-toggle-inlay-hints ()
  "Toggle Eglot's display-only type/parameter hints in this C/C++ buffer."
  (interactive)
  (unless (and (fboundp 'eglot-managed-p) (eglot-managed-p))
    (user-error "This buffer is not managed by Eglot"))
  (eglot-inlay-hints-mode (if eglot-inlay-hints-mode -1 1))
  (setq my-cpp-inlay-hints-enabled eglot-inlay-hints-mode)
  (message "Inlay hints %s" (if eglot-inlay-hints-mode "on" "off (or unsupported by server)")))
(defun my-cpp-managed-setup ()
  (when (and (eglot-managed-p)
             (derived-mode-p 'c-mode 'c++-mode 'c-ts-mode 'c++-ts-mode)
             (not my-large-file-p))
    (setq-local flymake-show-diagnostics-at-end-of-line
                (and my-cpp-inline-diagnostics-enabled 'short))
    (flymake-mode (if my-cpp-diagnostics-enabled 1 -1))
    (eglot-inlay-hints-mode (if my-cpp-inlay-hints-enabled 1 -1))))
(add-hook 'eglot-managed-mode-hook #'my-cpp-managed-setup)
(with-eval-after-load 'eglot
  (set-face-attribute 'eglot-inlay-hint-face nil :inherit 'shadow :height 0.9
                      :foreground "#9a9eab" :weight 'normal))
(with-eval-after-load 'flymake
  (set-face-attribute 'flymake-end-of-line-diagnostics-face nil :height 0.9 :box nil)
  (set-face-attribute 'flymake-error-echo-at-eol nil :foreground "#ff6e83")
  (set-face-attribute 'flymake-warning-echo-at-eol nil :foreground "#e6c384")
  (set-face-attribute 'flymake-note-echo-at-eol nil :foreground "#8bb9fe"))
(defun my-cpp-setup ()
  (unless my-large-file-p
    (hs-minor-mode 1)
    (if (executable-find "clangd") (eglot-ensure)
      (display-warning 'clangd "clangd missing from PATH; C++ editing remains available"))))
(dolist (hook '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook))
  (add-hook hook #'my-cpp-setup))
;; Tree-sitter modes use the same brace-based hideshow rules as CC mode.
(with-eval-after-load 'hideshow
  (dolist (mode '(c-ts-mode c++-ts-mode))
    (add-to-list 'hs-special-modes-alist (list mode "{" "}" "/[*/]" nil nil))))
(defun my-xref-without-generated (original &rest args)
  "Filter only C++ Eglot references, preserving all other xref operations."
  (let ((items (apply original args)))
    (if (and (eq (car args) 'eglot)
             (derived-mode-p 'c-mode 'c++-mode 'c-ts-mode 'c++-ts-mode))
        (cl-remove-if
         (lambda (item)
           (let ((location (xref-item-location item)))
             (and (xref-file-location-p location)
                  (string-match-p "\\.gen\\.cpp\\'" (xref-file-location-file location)))))
         items)
      items)))
(advice-add 'xref-backend-references :around #'my-xref-without-generated)
(provide 'config-cpp)
