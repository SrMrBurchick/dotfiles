;;; config-project.el --- Marker projects and async ripgrep -*- lexical-binding: t; -*-
(require 'project)
(require 'xref)
(defconst my-project-excludes '("Binaries" "DerivedDataCache" "Intermediate"
                               "Saved" ".vs" ".git"))
(defun my-project-marker-p (directory)
  (or (cl-some (lambda (name) (file-exists-p (expand-file-name name directory)))
               '("compile_commands.json" ".p4config" ".p4ignore.txt"))
      (directory-files directory nil "\\.uproject\\'" t)))
(defun my-project-try (directory)
  (unless (file-remote-p directory)
    (when-let* ((root (locate-dominating-file directory #'my-project-marker-p)))
      (cons 'my-unreal (expand-file-name root)))))
(add-hook 'project-find-functions #'my-project-try)
(cl-defmethod project-root ((project (head my-unreal))) (cdr project))
(cl-defmethod project-ignores ((_project (head my-unreal)) _directory)
  (mapcar (lambda (dir) (concat dir "/")) my-project-excludes))
;; No fallback to project.el's synchronous external `find'.
(defvar my-project-file-cache (make-hash-table :test #'equal))
(cl-defmethod project-files ((project (head my-unreal)) &optional dirs)
  (let* ((root (project-root project)) (files (gethash root my-project-file-cache)))
    (unless files (user-error "Use C-c p f to asynchronously populate the file cache"))
    (if dirs (cl-remove-if-not
              (lambda (file) (cl-some (lambda (dir) (file-in-directory-p file dir)) dirs))
              files)
      files)))
(defun my-project-root () (project-root (project-current t)))
(defun my-rg-args (root)
  "Common rg arguments; P4 ignore syntax only partly overlaps rg syntax."
  (append '("--hidden" "--no-ignore-vcs")
          (cl-mapcan (lambda (dir) (list "--glob" (concat "!**/" dir "/**")))
                     my-project-excludes)
          (when (file-exists-p (expand-file-name ".p4ignore.txt" root))
            (list "--ignore-file" (expand-file-name ".p4ignore.txt" root)))))
(defun my-project-scan (root callback &optional basename)
  "Find files asynchronously and call CALLBACK with absolute paths.
BASENAME restricts the scan to a single file name."
  (let ((default-directory root)
        (output (generate-new-buffer " *rg-files*"))
        (errors (generate-new-buffer " *rg-errors*")))
    (make-process
     :name "rg-files" :buffer output :stderr errors :noquery t
     :connection-type 'pipe :coding 'utf-8-unix
     :command (append (list (my-executable "rg") "--files" "--null")
                      (when basename (list "--glob" basename))
                      (my-rg-args root))
     :sentinel
     (lambda (process _event)
       (when (memq (process-status process) '(exit signal))
         (unwind-protect
             (if (and (eq (process-status process) 'exit)
                      (memq (process-exit-status process) '(0 1)))
                 (funcall callback
                          (with-current-buffer output
                            (mapcar (lambda (file) (expand-file-name file root))
                                    (split-string (buffer-string) "\0" t))))
               (display-warning 'project
                                (with-current-buffer errors (buffer-string))))
           (kill-buffer output) (kill-buffer errors)))))))
(defun my-project-find-file (&optional refresh)
  "Find project file; with prefix REFRESH the asynchronous cache."
  (interactive "P")
  (let* ((root (my-project-root))
         (choose (lambda (files)
                   (puthash root files my-project-file-cache)
                   (if files
                       (find-file (expand-file-name
                                   (completing-read "Project file: "
                                                    (mapcar (lambda (f) (file-relative-name f root)) files)
                                                    nil t) root))
                     (message "No project files found")))))
    (if (and (not refresh) (gethash root my-project-file-cache))
        (funcall choose (gethash root my-project-file-cache))
      (message "Scanning with rg asynchronously…")
      (my-project-scan root choose))))
(defun my-project-search (pattern)
  (interactive (list (or (thing-at-point 'symbol t) "")))
  (let ((root (my-project-root)))
    (my-executable "rg")
    (if (require 'consult nil t)
        ;; Consult list expressions preserve each Windows path as one argument.
        (let ((consult-ripgrep-args
               (list (list 'quote (append
                      '("rg" "--null" "--line-buffered" "--color=never"
                        "--max-columns=300" "--path-separator" "/" "--smart-case"
                        "--no-heading" "--with-filename" "--line-number")
                      (my-rg-args root))))))
          (consult-ripgrep root pattern))
      (my-process-output "rg" (my-executable "rg")
                         (append '("--line-number" "--column" "--no-heading" "--color=never")
                                 (my-rg-args root)
                                 (list "--" (read-string "Project regexp: " pattern) ".")) root))))
(defun my-recent-file ()
  (interactive)
  (if (require 'consult nil t) (consult-recent-file)
    (find-file (completing-read "Recent file: " recentf-list nil t))))
(setq project-switch-commands '((my-project-find-file "Find file")
                                (my-project-search "Search")
                                (project-switch-to-buffer "Buffer")
                                (project-shell "Shell"))
      xref-search-program 'ripgrep)
(provide 'config-project)
