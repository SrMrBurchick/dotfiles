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
(defun my-frame-font (&optional frame)
  (when (display-graphic-p frame)
    (with-selected-frame (or frame (selected-frame))
      (when (find-font (font-spec :family "JetBrainsMono Nerd Font"))
        ;; 12 points is approximately 16px at 96 DPI; Windows scaling applies.
        (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font"
                            :height 120 :weight 'semi-bold)))))
(my-frame-font)
(add-hook 'after-make-frame-functions #'my-frame-font)
(set-face-attribute 'mode-line nil :background "#263b54" :foreground "#ffffff"
                    :box nil)
(set-face-attribute 'mode-line-inactive nil :background "#161a22"
                    :foreground "#777777" :box nil)
(when (fboundp 'pixel-scroll-precision-mode) (pixel-scroll-precision-mode 1))
(provide 'config-ui)
