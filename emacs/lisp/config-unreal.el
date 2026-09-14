;;; config-unreal.el --- Unreal navigation, stubs and builds -*- lexical-binding: t; -*-
(require 'config-project)
(defcustom my-unreal-engine-root nil
  "Engine installation directory containing Engine/, set per project."
  :type '(choice (const nil) directory) :group 'my-unreal)
(defcustom my-unreal-project-file nil
  "Explicit .uproject path, needed when a directory has several projects."
  :type '(choice (const nil) file) :group 'my-unreal)
(defcustom my-unreal-target nil "Game target name, without .Target.cs."
  :type '(choice (const nil) string) :group 'my-unreal)
(defcustom my-unreal-editor-target nil "Editor target name, without .Target.cs."
  :type '(choice (const nil) string) :group 'my-unreal)
(defcustom my-unreal-build-config "Development" "UBT configuration."
  :type 'string :group 'my-unreal)
(dolist (variable '(my-unreal-engine-root my-unreal-project-file my-unreal-target
                    my-unreal-editor-target my-unreal-build-config))
  (make-variable-buffer-local variable))
(defun my-unreal-uproject ()
  "Find a .uproject in ancestor directories only; never recurse."
  (if my-unreal-project-file
      (let ((file (expand-file-name my-unreal-project-file (my-project-root))))
        (unless (file-exists-p file) (user-error "Missing .uproject: %s" file))
        file)
    (let* ((dir (locate-dominating-file
                 default-directory
                 (lambda (d) (directory-files d nil "\\.uproject\\'" t))))
           (files (and dir (directory-files dir t "\\.uproject\\'" t))))
      (pcase (length files)
        (0 (user-error "No ancestor .uproject; set my-unreal-project-file"))
        (1 (car files))
        (_ (completing-read "Unreal project: " files nil t))))))
(defun my-unreal-open-project ()
  (interactive) (dired (file-name-directory (my-unreal-uproject))))
(defun my-unreal-counterpart (callback)
  "Call CALLBACK with matching source/header path, using async rg if needed."
  (unless buffer-file-name (user-error "Visit a source file first"))
  (let* ((source buffer-file-name)
         (header (member (downcase (or (file-name-extension source) "")) '("h" "hpp")))
         (name (concat (file-name-base source) (if header ".cpp" ".h")))
         (local (expand-file-name name (file-name-directory source))))
    (if (file-exists-p local) (funcall callback local)
      (my-project-scan
       (my-project-root)
       (lambda (files)
         (cond ((null files)
                (funcall callback
                         (read-file-name (format "Create %s at: " name)
                                         (file-name-directory local) local nil name)))
               ((null (cdr files)) (funcall callback (car files)))
               (t (funcall callback (completing-read "Matching file: " files nil t)))))
       name))))
(defun my-unreal-switch-header-source ()
  (interactive) (my-unreal-counterpart #'find-file))
(defun my-unreal-parameters (text)
  "Remove top-level defaults from ordinary named C++ parameters.
Balance templates, braces, parentheses and quoted literals; reject ambiguity."
  (let ((stack nil) (quote-char nil) (escaped nil) (default nil)
        (part "") (parts nil))
    (cl-loop for ch across text do
             (cond
              (quote-char
               (unless default (setq part (concat part (string ch))))
               (cond (escaped (setq escaped nil))
                     ((eq ch ?\\) (setq escaped t))
                     ((eq ch quote-char) (setq quote-char nil))))
              ((memq ch '(?\" ?\'))
               (setq quote-char ch)
               (unless default (setq part (concat part (string ch)))))
              ((and (null stack) (eq ch ?=)) (setq default t))
              ((and (null stack) (eq ch ?,))
               (push (string-trim part) parts) (setq part "" default nil))
              (t
               (cond ((memq ch '(?\( ?\[ ?{ ?<)) (push ch stack))
                     ((memq ch '(?\) ?\] ?} ?>))
                      (unless (eq (pop stack) (cdr (assq ch '((?\) . ?\() (?\] . ?\[)
                                                             (?} . ?{) (?> . ?<)))))
                        (user-error "Ambiguous parameter expression; use clangd code actions"))))
               (unless default (setq part (concat part (string ch)))))))
    (when (or stack quote-char) (user-error "Unbalanced parameter expression"))
    (push (string-trim part) parts)
    (mapconcat #'identity (nreverse parts) ", ")))
(defun my-unreal-declaration ()
  "Parse an ordinary method with point on its NAME; return (QUALIFIED STUB).
Use a temporary CC-mode buffer so this works with both C++ major modes."
  (require 'cc-mode)
  (let ((text (buffer-substring-no-properties (point-min) (point-max)))
        (position (point)))
    (with-temp-buffer
      (insert text)
      (delay-mode-hooks (c++-mode))
      (goto-char position)
      (skip-syntax-backward "w_")
      (let* ((start (point))
             (name (thing-at-point 'symbol t))
             (brace (nth 1 (syntax-ppss))) open close class prefix suffix parameters rpc)
        (unless (and name brace (eq (char-after brace) ?{))
          (user-error "Place point on a method name inside a class"))
        (forward-symbol 1) (skip-chars-forward " \t\r\n")
        (unless (eq (char-after) ?\() (user-error "Point must be on the method name"))
        (setq open (point) close (scan-sexps open 1))
        (unless close (user-error "Unbalanced declaration"))
        (setq parameters (my-unreal-parameters
                          (buffer-substring-no-properties (1+ open) (1- close))))
        (goto-char close)
        (unless (re-search-forward ";" (min (point-max) (+ close 200)) t)
          (user-error "No declaration terminator"))
        (setq suffix (string-trim (buffer-substring-no-properties close (1- (point)))))
        (unless (string-match-p "\\`\\(?:const\\)?[ \t\n]*\\(?:override\\|final\\)?[ \t\n]*\\'" suffix)
          (user-error "Unsupported suffix (templates, noexcept, pure/default/delete, ref qualifiers)"))
        (setq suffix (if (string-match-p "\\_<const\\_>" suffix) " const" ""))
        (goto-char brace)
        ;; Only global, non-template classes: namespace/nested scope needs a real AST.
        (when (nth 1 (syntax-ppss)) (user-error "Nested/namespace classes: use clangd code actions"))
        (unless (re-search-backward "\\_<\\(class\\|struct\\)\\_>" (max (point-min) (- brace 2000)) t)
          (user-error "Cannot find containing class"))
        (let ((head (buffer-substring-no-properties (point) brace)))
          (unless (string-match "\\`\\(?:class\\|struct\\)[ \t\n]+\\(?:[A-Za-z0-9_]+_API[ \t\n]+\\)?\\([A-Za-z_][A-Za-z0-9_]*\\)\\(?:[ \t\n:]\\|\\'\\)" head)
            (user-error "Unsupported class declaration"))
          (setq class (match-string 1 head)))
        (save-excursion
          (beginning-of-line)
          (when (re-search-backward "\\_<template[ \t\n]*<" (max (point-min) (- (point) 200)) t)
            (user-error "Template class: use clangd code actions")))
        (goto-char start)
        (let ((begin (if (re-search-backward "[;{}]" (1+ brace) t) (1+ (point)) (1+ brace))))
          (setq prefix (string-trim (buffer-substring-no-properties begin start))))
        (setq rpc (and (string-match "UFUNCTION[ \t\n]*(\\([^)]*\\))" prefix)
                       (cl-some (lambda (specifier)
                                  (member (string-trim specifier)
                                          '("Server" "Client" "NetMulticast")))
                                (split-string (match-string 1 prefix) "," t))))
        (setq prefix (replace-regexp-in-string "UFUNCTION[ \t\n]*([^)]*)" "" prefix))
        (setq prefix (replace-regexp-in-string "GENERATED_\\(?:BODY\\|UCLASS_BODY\\)[ \t\n]*([^)]*)" "" prefix))
        (setq prefix (replace-regexp-in-string "\\_<\\(?:public\\|protected\\|private\\)[ \t\n]*:" "" prefix))
        (setq prefix (replace-regexp-in-string "\\_<\\(?:virtual\\|static\\|[A-Za-z0-9_]+_API\\)\\_>" "" prefix))
        (setq prefix (string-trim (replace-regexp-in-string "[ \t\n\r]+" " " prefix)))
        (when (or (string-empty-p prefix)
                  (string-match-p "[^[:alnum:]_:<>, *&]" prefix)
                  (string-match-p "[()#=~]\\|\\_<\\(?:template\\|friend\\|operator\\|constexpr\\|inline\\)\\_>" prefix))
          (user-error "Unsupported declaration; use M-x eglot-code-actions"))
        (let ((qualified (concat class "::" name (if rpc "_Implementation" ""))))
          (list qualified (format "%s %s(%s)%s\n{\n}\n" prefix qualified parameters suffix)))))))
(defun my-unreal-create-implementation ()
  "Insert a reviewable stub into a matching .cpp, without saving.
A name-level duplicate guard deliberately refuses ambiguous overloads."
  (interactive)
  (unless (and buffer-file-name (string-match-p "\\.h\\(?:pp\\)?\\'" buffer-file-name))
    (user-error "Run this on a method name in a header"))
  (pcase-let ((`(,qualified ,stub) (my-unreal-declaration)))
    (my-unreal-counterpart
     (lambda (file)
       (find-file file)
       (barf-if-buffer-read-only)
       (save-restriction
         (widen)
         (goto-char (point-min))
         (if (re-search-forward (concat (mapconcat #'regexp-quote (split-string qualified "::")
                                             "[ \t\r\n]*::[ \t\r\n]*")
                                       "[ \t\r\n]*(") nil t)
             (message "%s already exists (or has an overload); inspect it" qualified)
           (atomic-change-group
             (goto-char (point-max))
             (unless (bolp) (insert "\n"))
             (insert "\n" stub))
           (message "Inserted stub; review and fill its body before saving")))))))
(defun my-unreal-cmd-quote (argument)
  "Quote one controlled cmd.exe batch argument; reject expansion characters."
  (when (string-match-p "[\"%!?&|<>^\r\n]" argument)
    (user-error "Unsupported cmd.exe metacharacter in argument: %s" argument))
  (concat "\"" argument "\""))
(defun my-unreal-build (&optional editor)
  "Build configured target using Build.bat; with prefix EDITOR build editor."
  (interactive "P")
  (unless (eq system-type 'windows-nt) (user-error "Build.bat requires native Windows Emacs"))
  (let* ((project (my-unreal-uproject))
         (target (or (if editor my-unreal-editor-target my-unreal-target)
                     (read-string (if editor "Editor target: " "Game target: "))))
         (engine (or my-unreal-engine-root (read-directory-name "Unreal installation: ")))
         (batch (expand-file-name "Engine/Build/BatchFiles/Build.bat" engine))
         (default-directory (file-name-directory project))
         (shell-file-name (or (getenv "COMSPEC") (my-executable "cmd.exe")))
         (shell-command-switch "/c"))
    (unless (file-exists-p batch) (user-error "Build.bat missing: %s" batch))
    (unless (string-match-p "\\`[A-Za-z0-9_]+\\'" target) (user-error "Invalid target name"))
    (save-some-buffers)
    ;; CALL avoids cmd.exe stripping the executable path's surrounding quotes.
    (compilation-start
     (concat "call " (mapconcat #'my-unreal-cmd-quote
                             (list (convert-standard-filename batch) target "Win64"
                                   my-unreal-build-config
                                   (concat "-project=" (convert-standard-filename project))
                                   "-WaitMutex") " "))
     'compilation-mode)))
(defun my-unreal-build-editor () (interactive) (my-unreal-build t))
(with-eval-after-load 'compile
  (add-to-list 'compilation-error-regexp-alist-alist
               '(my-msvc "^[ \t]*\\(?:[0-9]+>\\)?\\([A-Za-z]:[^\n]+?\\)(\\([0-9]+\\)\\(?:,\\([0-9]+\\)\\)?):[ \t]*\\(?:fatal error\\|error\\|warning\\|note\\)" 1 2 3))
  (add-to-list 'compilation-error-regexp-alist 'my-msvc))
(provide 'config-unreal)
