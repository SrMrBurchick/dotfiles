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
        :inlayHintProvider :foldingRangeProvider))
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
(defvar-local my-cpp-diagnostics-enabled nil)
(defun my-cpp-toggle-diagnostics ()
  "Toggle diagnostic display for this buffer; clangd still computes diagnostics."
  (interactive)
  (setq my-cpp-diagnostics-enabled (not my-cpp-diagnostics-enabled))
  (flymake-mode (if my-cpp-diagnostics-enabled 1 -1))
  (message "Diagnostic display %s" (if my-cpp-diagnostics-enabled "on" "off")))
(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (when (eglot-managed-p)
              (unless my-cpp-diagnostics-enabled (flymake-mode -1))
              (when (fboundp 'eglot-inlay-hints-mode) (eglot-inlay-hints-mode -1)))))
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
