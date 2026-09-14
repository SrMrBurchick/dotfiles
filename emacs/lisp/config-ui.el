;;; config-ui.el --- Dark, simple UI -*- lexical-binding: t; -*-
(load-theme 'modus-vivendi t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t ring-bell-function #'ignore
      scroll-margin 3 scroll-conservatively 101 scroll-step 1
      mouse-wheel-scroll-amount '(3 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      mode-line-compact t)
(set-fringe-mode 8)
(defcustom my-font-height 160
  "Default GUI font height in tenths of a point."
  :type 'integer :group 'my-unreal)
(defun my-frame-font (&optional frame)
  "Apply JetBrains NF to the explicit GUI FRAME, or warn if unavailable."
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (if (and (member "JetBrains NF" (font-family-list frame))
               (find-font (font-spec :family "JetBrains NF") frame))
          (set-face-attribute 'default frame :family "JetBrains NF"
                              :height my-font-height :weight 'semi-bold)
        (display-warning 'font
                         "JetBrains NF was not found. Install that font family in Windows, then run M-: (my-frame-font), or restart Emacs.")))))
;; Re-evaluation also updates existing GUI frames; daemon frames use the hook.
(dolist (frame (frame-list)) (my-frame-font frame))
(add-hook 'after-make-frame-functions #'my-frame-font)
(require 'whitespace)
(setq display-line-numbers-type t
      whitespace-action nil
      whitespace-style '(face tabs spaces trailing space-mark tab-mark)
      whitespace-display-mappings '((space-mark ?\s [?·] [?.])
                                    (tab-mark ?\t [?> ?- ?- ?-])))
;; A fixed four-cell tab marker matches the configured four-space indentation.
;; Only display tables/font-lock faces change; no whitespace cleanup is run.
(set-face-attribute 'whitespace-space nil :foreground "#454955" :background 'unspecified)
(set-face-attribute 'whitespace-tab nil :foreground "#555968" :background 'unspecified)
(set-face-attribute 'whitespace-trailing nil :foreground "#8b6571" :background "#251d24")
(defun my-programming-whitespace ()
  "Enable absolute line numbers and subtle whitespace in source buffers."
  (unless (bound-and-true-p my-large-file-p)
    (setq-local display-line-numbers t display-line-numbers-type t)
    (whitespace-mode 1)))
(add-hook 'prog-mode-hook #'my-programming-whitespace)
;; Apply the changed UI to buffers already open when using M-x eval-buffer.
(dolist (buffer (buffer-list))
  (with-current-buffer buffer
    (when (derived-mode-p 'prog-mode) (my-programming-whitespace))))
(set-face-attribute 'mode-line nil :background "#263b54" :foreground "#ffffff"
                    :box nil)
(set-face-attribute 'mode-line-inactive nil :background "#161a22"
                    :foreground "#777777" :box nil)
(when (fboundp 'pixel-scroll-precision-mode) (pixel-scroll-precision-mode 1))
(use-package nyan-mode
  :if (locate-library "nyan-mode")
  :hook (after-init . my-enable-nyan)
  :init
  (setq nyan-bar-length 12 nyan-minimum-window-width 64
        nyan-animate-nyancat t nyan-wavy-trail t))
(defun my-enable-nyan ()
  "Enable Nyan globally and start its single animation timer."
  (when (require 'nyan-mode nil t)
    (unless (bound-and-true-p nyan-mode) (nyan-mode 1))
    (when nyan-animate-nyancat (nyan-start-animation))))
;; after-init has already run when this module is evaluated interactively.
(when after-init-time (my-enable-nyan))
(defun my-toggle-window-maximize ()
  "Maximize this window, or restore this frame's saved window configuration."
  (interactive)
  (when (window-minibuffer-p) (user-error "Select an editing window first"))
  (let* ((frame (selected-frame))
         (saved (frame-parameter frame 'my-window-maximize)))
    (if saved
        (let ((buffer (current-buffer)) (position (point)))
          (set-window-configuration (car saved))
          (set-frame-parameter frame 'my-window-maximize nil)
          ;; Retain editing progress when returning to the original buffer.
          (when (eq buffer (current-buffer)) (goto-char position)))
      (when (window-parameter nil 'window-side)
        (user-error "Select a source window before maximizing"))
      (let ((configuration (current-window-configuration))
            (ignore-window-parameters t))
        (delete-other-windows)
        (set-frame-parameter frame 'my-window-maximize (list configuration))))))
(provide 'config-ui)
