;;; init.el --- Minimal Windows Unreal configuration -*- lexical-binding: t; -*-
(when (< emacs-major-version 30) (error "This configuration requires Emacs 30+"))
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(require 'use-package)
;; Installation is explicit: startup never refreshes archives or uses the network.
(setq use-package-always-ensure nil)
(defconst my-packages
  '(evil corfu treemacs treemacs-evil nyan-mode vertico orderless marginalia consult))
(defun my-install-packages ()
  "Install the configured external packages, then restart Emacs."
  (interactive)
  (package-refresh-contents)
  (dolist (package my-packages)
    (unless (package-installed-p package) (package-install package)))
  (message "Packages installed; restart Emacs"))
(dolist (module '(config-core config-ui config-evil config-project
                  config-completion config-cpp config-unreal config-treemacs
                  config-perforce config-debug config-dashboard config-keybindings))
  (require module))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)
(unless (cl-every #'package-installed-p my-packages)
  (display-warning 'setup "Run M-x my-install-packages, then restart Emacs."))
(provide 'init)
