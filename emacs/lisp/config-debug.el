;;; config-debug.el --- Use the real MSVC/PDB debugger -*- lexical-binding: t; -*-
(defcustom my-visual-studio-devenv nil
  "Full path to devenv.exe when Visual Studio is not on PATH."
  :type '(choice (const nil) file) :group 'my-unreal)
(defcustom my-visual-studio-debug-arguments nil
  "Literal executable arguments, e.g. a .uproject path followed by -log."
  :type '(repeat string) :group 'my-unreal)
(defun my-debug-visual-studio (executable)
  "Launch Visual Studio's debugger for EXECUTABLE. Press F5 in VS to run.
For an existing UnrealEditor process use VS Debug > Attach to Process."
  (interactive "fExecutable to debug: ")
  (unless (eq system-type 'windows-nt) (user-error "Visual Studio requires Windows"))
  (let ((devenv (or my-visual-studio-devenv (my-executable "devenv.exe"))))
    (unless (file-exists-p devenv) (user-error "Missing devenv.exe: %s" devenv))
    (make-process :name "visual-studio" :buffer "*Visual Studio*" :noquery t
                  :command (append (list devenv "/DebugExe" (expand-file-name executable))
                                   my-visual-studio-debug-arguments))))
(provide 'config-debug)
