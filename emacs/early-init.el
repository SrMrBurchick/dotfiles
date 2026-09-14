;;; early-init.el --- Early startup -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil
      gc-cons-threshold (* 128 1024 1024)
      frame-inhibit-implied-resize t)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 32 1024 1024))))
(provide 'early-init)
