# Minimal Windows Emacs for Unreal Engine 5.7

Copy this directory's `init.el`, `early-init.el`, and `lisp/` into your
Emacs user directory. This is a native Windows configuration, without Bash,
Projectile, lsp-mode, Company, Git integration, or a distribution framework.

## Installation and external tools

1. Install native GUI Emacs 30+ with JSON support. Tree-sitter support is optional.
   Evaluate `user-emacs-directory` with `M-:` to confirm where Emacs loads your
   configuration. On Windows this depends on HOME/APPDATA; do not assume the
   shell's `~` and Emacs's `~` are the same. Remove competing older init files.
2. Install Unreal Engine 5.7 and its prerequisites. Install Visual Studio 2022
   with **Game development with C++**, the MSVC toolset and Windows SDK required
   by your engine. Epic lists VS 17.8 minimum and recommends 17.14 for UE 5.7.
   Use the toolset versions selected/documented for your specific engine build.
3. Put `clangd.exe`, `rg.exe`, and `p4.exe` on Windows PATH, then restart Emacs.
   Check with `M-: (executable-find "clangd")`, and likewise `rg` and `p4`.
   GUI applications inherit PATH at launch; an already-running Emacs daemon
   does not inherit later changes. No Bash, GNU find, Python or Node is required.
4. Install **JetBrainsMono Nerd Font** in Windows, then restart Emacs. The config
   uses 12pt semibold (about 16px at 96 DPI). Adjust `:height 120` or weight in
   `config-ui.el` for your display. Missing fonts fall back to Emacs's font.
5. Start Emacs, run `M-x my-install-packages`, and restart. This explicit step
   installs Evil, Corfu, Treemacs, treemacs-evil, nyan-mode, Vertico, Orderless,
   Marginalia and Consult plus their declared
   dependencies from GNU ELPA, NonGNU ELPA and MELPA. Startup never accesses
   package archives. Installation failures can be retried with the same command.
   Built-in use-package, Eglot, project.el, xref, Eldoc, hideshow,
   compilation-mode and Modus Vivendi supply the remaining features.
6. Open a project header or source file. Configure the compilation database
   before expecting accurate clangd navigation. Use `C-c p f` for project files.

Package versions are not pinned. Back up your working `elpa/` directory before
explicit upgrades with `M-x list-packages`; no automatic upgrades run.
The supplied configuration was batch-loaded and its helpers tested on Linux
Emacs 31.1. Native Windows GUI, downloaded packages, UE builds and Perforce
server interactions still require workstation validation; this is not a claim
of end-to-end Windows certification.

## clangd and Unreal's compilation database

Install the LLVM clangd distribution and verify `clangd --version` in PowerShell.
The configuration uses exactly these arguments:

```text
clangd --background-index --clang-tidy=false --completion-style=detailed
       --header-insertion=never --log=error --function-arg-placeholders=true
```

clangd needs a **Windows-generated** `compile_commands.json` with real MSVC/SDK
include paths, Unreal defines, response files and generated-header paths for
your current target. A database produced on Linux is not interchangeable.
Build the editor target once so UnrealHeaderTool produces generated headers.
Keep Intermediate available on disk: excluding it from navigation does not mean
it can be excluded from clangd's compiler include paths.

For UE 5.7, use the engine's UnrealBuildTool `GenerateClangDatabase` mode.
From PowerShell, a typical invocation is:

```powershell
& 'D:\Epic\UE_5.7\Engine\Build\BatchFiles\Build.bat' `
  MyGameEditor Win64 Development `
  '-Project=D:\Work\MyGame\MyGame.uproject' '-Mode=GenerateClangDatabase'
```

Replace every path and target. This command is an explicit, potentially costly
UBT operation; it is not run automatically. Check your engine's
`Engine/Source/Programs/UnrealBuildTool/Modes/GenerateClangDatabase.cs` and UBT
output for supported switches and the actual database output location. Engine
variants may differ. Do not assume Visual Studio solution generation alone
creates a usable clangd database. Do not delete response files it references.

Put the resulting database at the project root, or create a project `.clangd`:

```yaml
CompileFlags:
  CompilationDatabase: D:/Work/ClangDatabase
```

This must name the directory containing the database. Regenerate after changes
to modules, targets, engine version, toolchain or generated code. Restart with
`M-x eglot-shutdown`, then `M-x eglot-ensure`. Never give clangd an unrestricted
`--query-driver=*`; no driver execution permission is configured here.

Eglot starts only in C/C++ buffers. Flymake and compact inline diagnostics
default on. `C-c c d` toggles Flymake; `C-c c v` independently toggles inline
text without enabling a disabled Flymake. Customize `my-cpp-diagnostics-enabled`
and `my-cpp-inline-diagnostics-enabled` for defaults in new buffers. clangd
still computes and sends diagnostics when Flymake is disabled. clang-tidy is disabled. Background indexing and preamble creation
remain substantial CPU/RAM users; thread counts are left to clangd. To reduce
indexing for a particular engine checkout, use clangd's documented per-path
`Index.Background: Skip` configuration, accepting reduced cross-file results.
No file-watcher capability is forcibly removed: clangd must remain correct when
build inputs change. Emacs itself does not add recursive project watchers.

`K` requests Eldoc documentation/signatures in a normal Emacs buffer. Idle Eldoc
updates its documentation buffer without opening popup windows or echo-area
signature messages. Corfu uses Eglot's completion-at-point backend directly.
clangd argument placeholders do not gain snippet tab stops: no snippet framework
is installed. Use `C-SPC` when automatic completion is unwanted or has not fired.

## Projects, ripgrep and Perforce

The nearest ancestor containing a `.uproject`, `compile_commands.json`,
`.p4config` or `.p4ignore.txt` is a project root. Only ancestor directories are
inspected. Set a marker at the game root if your P4 workspace root is too broad.
`C-c p f` runs `rg --files` asynchronously on first use and caches the result in
memory. `C-u C-c p f` refreshes after adding, removing or syncing files. Built-in
`project-files` consumes that cache; it never falls back to recursive GNU find.
First-time completion over a very large result set can still cost time and RAM.

Search uses `consult-ripgrep` with asynchronous `rg` output in the minibuffer;
select a hit with `RET`. `M-.` explicitly previews it. Without Consult installed,
the command falls back to compilation-mode. The initial search text is the
symbol at point; it is a regexp, so add `\b` boundaries if needed. Generated/build folders
Binaries, DerivedDataCache, Intermediate, Saved and .vs are excluded from scans
and search. `.gen.cpp` references are filtered only for C++ Eglot xref references;
definitions and other xref backends retain normal behavior.

Root `.p4ignore.txt` is passed to rg as an ignore file. This is best-effort:
Perforce and rg ignore syntaxes differ (especially `...`, nested ignore files
and platform-specific patterns). Use a root `.ignore` with rg-compatible patterns
when necessary. These filters do not alter Perforce's own ignore interpretation.

The configuration defaults P4CONFIG to `.p4config` and P4IGNORE to `.p4ignore.txt`
only if those environment variables are unset. A typical workspace `.p4config`:

```text
P4PORT=ssl:perforce.example.com:1666
P4USER=your-user
P4CLIENT=your-workspace
```

Set up `p4 trust` and `p4 login` in PowerShell or `M-x shell` first; do not store
passwords in config files. Explicit commands run from the file/project directory
so P4CONFIG discovery works. `p4 opened` lists opened files for the current
client, and `p4 info` identifies the connection/workspace. There is no polling.
`p4 edit` updates buffer writability after success. `p4 diff` reads disk, so save
first. `p4 revert` refuses unsaved buffers and asks before discarding disk edits;
auto-revert reloads the reverted file, or use `M-x revert-buffer` immediately.
Treemacs has Git, follow and file-watch modes disabled. Toggle it to select the
current project; this replaces its displayed workspace with that single root.
Use its manual refresh after syncs. Built-in image icons fall back when image
support is unavailable; no icon-font package is required for the tree.

## Tree-sitter

Run `M-: (treesit-available-p)`. If nil, use an Emacs build with tree-sitter or
keep the automatic CC-mode fallback. For grammar installation, temporarily set:

```elisp
(setq treesit-language-source-alist
      '((c "https://github.com/tree-sitter/tree-sitter-c")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp")))
```

Run `M-x treesit-install-language-grammar` for `c` and `cpp`, then restart Emacs.
The installer requires Git and a working C compiler **only for grammar building**;
they are not used for project/version-control operations. Alternatively install
trusted precompiled grammar DLLs matching Emacs's architecture and tree-sitter
ABI in `~/.emacs.d/tree-sitter/`. Verify with `(treesit-ready-p 'cpp)`.
Grammar releases can change ABI; retain compatible versions when upgrading.
Both modes use four spaces and BSD-style indentation. Unreal macros can confuse
any generic C++ parser; remove the mode remapping if a particular grammar causes
problems. No external tree-sitter framework is used.

## Per-project builds

Put this `.dir-locals.el` at the game root, changing paths/targets:

```elisp
((nil . ((my-unreal-engine-root . "D:/Epic/UE_5.7")
         (my-unreal-project-file . "D:/Work/MyGame/MyGame.uproject")
         (my-unreal-target . "MyGame")
         (my-unreal-editor-target . "MyGameEditor")
         (my-unreal-build-config . "Development"))))
```

Accept local-variable values only for a project you trust; the config does not
mark arbitrary executable paths universally safe. Revisit buffers after changes.
Run builds from a project buffer so its local values apply. Unset engine/target
values are prompted for; no global game name or engine path is assumed.
Target names correspond to your actual `.Target.cs` files.

`C-c u b` builds the game; `C-c u e` builds the editor using Build.bat, Win64,
the selected configuration, `-project=...` and `-WaitMutex`. Build.bat selects
UBT/MSVC. A VS developer shell is optional if your engine detects the installed
toolchain; use one if required by your source build. Compilation buffers retain
clickable MSVC drive-letter paths, line numbers and optional columns. `M-x
recompile` reruns a build; `M-x kill-compilation` requests termination.
Avoid building against an editor session using incompatible Live Coding settings.

Ordinary Windows paths with spaces are supported. Use forward slashes in Lisp
strings, or double each backslash. Batch arguments reject shell expansion and
metacharacters (`%`, `!`, quotes, `&`, etc.) instead of trying unsafe quoting.
The rg/P4/debugger commands pass literal argument lists without a shell.

## Implementation generation

Place point on the **method name** in a header, then `C-c c i`. Same-directory
counterparts are checked first; otherwise rg searches asynchronously using the
same excludes. Multiple matches prompt for a file. No matches prompt for the
new file's location; select the proper module's Private directory. The parent
directory must exist. The helper inserts into an unsaved buffer, never saves it,
and respects read-only Perforce files: use `C-c v e` before insertion.

Supported: ordinary global class/struct methods, multiline declarations,
const, virtual/static, MODULE_API exports, simple override/final, and
UFUNCTION Server/Client/NetMulticast RPCs. RPC names gain `_Implementation`;
top-level argument defaults are removed, including common nested constructor,
template and string expressions. Non-void bodies intentionally need your return
logic before compilation. Required includes are your responsibility.

This helper is deliberately **not a complete C++ parser**. It refuses namespace
or nested classes, templates, constructors/destructors, operators, pure/default/
deleted methods, noexcept/ref qualifiers, comments in the declaration prefix,
and ambiguous expressions. UFUNCTION metadata with nested parentheses is not
supported. A name-level duplicate check also refuses existing overloads rather
than risk a duplicate; it only inspects the selected counterpart file. It does
not generate `_Validate`, BlueprintNativeEvent bodies or code in other modules.
For unsupported declarations try clangd's offered actions with `C-c c a`, or
write the definition manually. Review every generated stub.

## Dashboard, navigation and window focus

`config-dashboard.el` supplies a small button-based startup buffer, with no
additional dashboard package. Known projects come directly from
`project-known-project-roots`; recent files come from recentf. Neither list is
validated or recursively scanned during dashboard rendering. Use TAB/Shift-TAB
and RET, or click a button. `g` refreshes; `C-c h` reopens the dashboard.

Open project selects a saved root. Add project registers a directory using
project.el. Opening a root creates a project landing buffer whose
`default-directory` is that root, so `C-c p f`, search, shell and other project.el
commands immediately use the selected project. Project context in Emacs is
buffer-local, not a global replacement for the project of every open file.
Missing roots are diagnosed when selected; forget stale entries with
`M-x project-forget-project`. CLI file visits still use Emacs's normal startup
handling; the dashboard is configured through `initial-buffer-choice`.

Vertico, Orderless, Marginalia and Consult replace Icomplete. Space-separated
search terms match in any order, with literal and fuzzy subsequence matching.
`\` in Evil normal mode searches open buffers; useful special buffers remain
available. Consult's hidden-buffer source (`SPC` narrowing prefix) can reveal
internal buffers filtered by its normal source. `C-c b` provides the same command
outside normal mode. Arrow keys or C-n/C-p select candidates, RET accepts, and
Escape cancels. Recent files use Consult. Project files retain the asynchronous
rg cache and use Vertico/Orderless via standard completing-read; no synchronous
Consult find traversal or additional fd executable is introduced. `M-.` opts
into Consult previews, avoiding automatic visits to large files.

`C-f` overrides Evil's forward-page command **only in normal state**. It saves
the current frame's window configuration and maximizes the selected editing
window, including hiding side windows such as Treemacs. Press it again to
restore the prior splits, sizes, buffers and selected window. Editing progress
in the original selected buffer is retained where practical. Saved layouts are
per-frame. Buffers are not killed and OS fullscreen is never changed. Select a
source window first if currently in a sidebar. Killing buffers or resizing the
frame while maximized can necessarily limit exact restoration. Insert and
minibuffer C-f keep their usual behavior; backslash still inserts normally in
insert state. `C-e` keeps its open/focus/hide Treemacs behavior.

Nyan mode uses its global `nyan-mode` API with a short 12-unit bar, no animation
or music, and a minimum window width of 64 columns. It replaces only the normal
modeline position indicator, retaining line/column information. Its own text
fallback works without XPM image support. No custom modeline framework is added.

## Inline diagnostics and C++ inlay hints

These are distinct native features in Emacs 30+; neither inserts source text.

- Flymake's `flymake-show-diagnostics-at-end-of-line` is set to `short` in managed
  C/C++ buffers: the most severe message on each affected line is shown using
  separate red error, amber warning and blue note faces. Flymake owns overlay
  updates and removal when backend reports change. There is no polling timer,
  automatic diagnostics window or extra diagnostic package. `C-c c v` toggles
  inline text; if Flymake is enabled it restarts that buffer's Flymake once to
  clear/recreate overlays through public APIs. It does not change `C-c c d`'s
  enabled/disabled state. The compact text may be clipped on long source lines
  because source buffers truncate rather than wrap.
- Native `eglot-inlay-hints-mode` is enabled automatically in managed c-mode,
  c++-mode, c-ts-mode and c++-ts-mode buffers. `C-c c n` toggles it for the buffer.
  The previous ignored `:inlayHintProvider` setting has been removed. Subtle
  gray overlays show clangd's deduced types and parameter names independently
  of Flymake. Eglot controls visible-region hint requests and overlay cleanup.

Current clangd enables parameter-name and deduced-type hints by default; no new
server flags or nonstandard LSP initialization settings are required. If an
existing clangd configuration overrides them, merge this into the project's
`.clangd` (do not replace its compilation database settings):

```yaml
InlayHints:
  Enabled: true
  ParameterNames: true
  DeducedTypes: true
```

clangd decides when a hint is useful; redundant argument-name hints or excessively
long types may be suppressed. Accurate hints require a valid compilation database
and successful parsing. These settings cannot repair missing Unreal includes.
Restart an existing Eglot connection after loading the updated configuration,
then revisit buffers. For missing hints check `M-x describe-variable RET
eglot-inlay-hints-mode`, your clangd version/configuration, and its advertised
inlayHintProvider capability. Neither feature is enabled in large-file fallback
buffers. Inline diagnostics and inlay hints do add overlays; toggle them per
buffer if profiling shows a cost on an especially dense translation unit.

## MSVC/PDB debugging

Use **Visual Studio's native debugger**. Build Tools alone do not supply the full
Visual Studio debugging UI. Set `my-visual-studio-devenv` through Customize if
`devenv.exe` is not on PATH, for example its installed Common7/IDE/devenv.exe.
`C-c d v` selects an executable and opens Visual Studio with `/DebugExe`; press
F5 there. Set `my-visual-studio-debug-arguments` to a list such as
`("D:/Work/MyGame/MyGame.uproject" "-log")` when launching UnrealEditor.exe.
For an already running editor, use Visual Studio **Debug > Attach to Process**,
select UnrealEditor.exe and native code. Load matching PDBs and source files.
Development builds optimize code; DebugGame Editor can improve game-code stepping.

Microsoft documents `cppvsdbg` for its VS Code C++ extension. This configuration
does not assume that adapter is a supported, licensed, tested Emacs backend.
No DAP adapter is installed and there are no in-Emacs breakpoints, stepping or
watch windows here. GDB is not offered as an MSVC/PDB replacement.

## Keybindings

| Keys | Action |
|---|---|
| `gd`, `gD`, `gr`, `gi` | Definition, declaration, references, implementation |
| `K` / `C-c c k` | Request documentation/signature in Eldoc buffer |
| `ss`, `sv` | Split below/right and focus new window |
| `sh`, `sj`, `sk`, `sl` | Focus left/down/up/right |
| `SPC` | Next window; **not a leader prefix** |
| `C-u`, `C-d` | Evil half-page scrolling |
| `Esc` | Leave insert state / cancel minibuffer; dismiss Corfu first if open |
| `C-SPC` | Completion (replaces Emacs set-mark; use Evil visual selection) |
| `Tab`, `S-Tab`, `RET` | Next, previous, accept while Corfu popup is active |
| `C-c p f`, `C-u C-c p f` | Project file / refresh file cache |
| `C-c p s`, `C-c p b`, `C-c p p` | Project search, project buffer, switch project |
| `C-c p t` | Project shell, native Windows shell |
| `C-c f r`, `C-c b` | Consult recent file, open buffers |
| `\` (normal mode) | Search open buffers using Consult |
| `C-f` (normal mode) | Maximize selected window / restore previous layout |
| `C-c h` | Startup dashboard |
| `C-e` / `C-c t` | Open/focus Treemacs; hide it when already focused |
| `C-c c h`, `C-c c i`, `C-c c a` | Header/source, create implementation, LSP action |
| `C-c c d` | Toggle this buffer's Flymake diagnostics |
| `C-c c v` | Toggle inline diagnostic summaries independently |
| `C-c c n` | Toggle clangd type/parameter inlay hints independently |
| `za`, `zc`, `zo`, `zM`, `zR` | Toggle/close/open fold, close/open all |
| `C-c u o`, `C-c u b`, `C-c u e` | Open .uproject directory, game build, editor build |
| `C-c v e/r/o/d/i` | P4 edit/revert/opened/diff/info |
| `C-c d v` | Open executable in Visual Studio debugger |
| `M-g n`, `M-g p` | Next/previous compilation or search hit |

## Performance and troubleshooting

- Missing packages: run `my-install-packages`; first installation needs network.
- Missing executables: inspect `executable-find`, fix Windows PATH, restart.
- Wrong includes/navigation: inspect the database command for that source file,
  verify response files and generated headers exist, and check clangd version.
  Temporarily set `eglot-events-buffer-config` to `(:size 200000 :format full)`
  before reconnecting to inspect `M-x eglot-events-buffer`; restore size 0 after.
- Missing references: wait for background indexing. `.gen.cpp` hits are
  deliberately filtered; remove the advice with
  `(advice-remove 'xref-backend-references #'my-xref-without-generated)` to inspect.
- Stale file/tree lists: refresh explicitly after a P4 sync. Auto-revert polls
  visited local buffers every three seconds; it does not crawl the workspace
  and does not overwrite unsaved buffer edits.
- Files over 5 MiB open in fundamental-mode before expensive parsers start, with
  undo disabled. `global-so-long-mode` additionally guards pathological long
  lines. Raise `my-large-file-bytes` only if you accept that cost, then reopen.
- Automatic completion can be disabled in a buffer with `(setq-local corfu-auto
  nil)`; manual completion remains. Indexing, file-list completion and expanding
  very large individual Treemacs directories can still be expensive.
- Native Emacs builds vary in tree-sitter and image support; both have fallbacks.
- Backups, auto-saves and history live in `.emacs.d/var/`. Lock files are disabled;
  avoid editing the same file in multiple Emacs instances. Undo history is not
  persisted between sessions. The theme has no transparency or animation.

## Validation

After installing the configured packages, run from this configuration directory:

```text
emacs -Q --batch -l tests/config-ui-tests.el
```

The eight regression tests cover project landing context, dashboard rendering
without file probes, exact window restoration including sidebars, diagnostic
update/removal, independent toggles, Evil/minibuffer key scope, Consult argument
boundaries for paths with spaces, and idempotent static Nyan integration.
They use temporary state rather than writing your normal Emacs history files.
These tests passed with Emacs 31.1 and the current installed packages on Linux.
A separate live clangd check returned both type and parameter hints and verified
that toggling hints preserved source text and Flymake state. Native Windows GUI
rendering and the Unreal/MSVC/P4 environment still need workstation validation.

## References

- [Epic: Visual Studio setup and engine/version compatibility](https://dev.epicgames.com/documentation/en-us/unreal-engine/setting-up-visual-studio-development-environment-for-cplusplus-projects-in-unreal-engine)
- [clangd installation and compilation databases](https://clangd.llvm.org/installation)
- [clangd configuration](https://clangd.llvm.org/config)
- [GNU Eglot manual](https://www.gnu.org/software/emacs/manual/html_node/eglot/)
- [Treemacs documentation](https://github.com/Alexander-Miller/treemacs)
- [Microsoft: devenv /DebugExe](https://learn.microsoft.com/en-us/visualstudio/ide/reference/debugexe-devenv-exe?view=visualstudio)
- [Microsoft: C++ debugger configuration and cppvsdbg](https://code.visualstudio.com/docs/cpp/launch-json-reference)

Additional verified APIs:

- [Emacs 30.1 Flymake implementation and end-of-line diagnostics](https://github.com/emacs-mirror/emacs/blob/emacs-30.1/lisp/progmodes/flymake.el)
- [Emacs 30 Eglot native inlay hints](https://github.com/emacs-mirror/emacs/blob/emacs-30/lisp/progmodes/eglot.el)
- [clangd inlay-hint configuration](https://clangd.llvm.org/config#inlayhints)
- [Nyan mode API and installation](https://github.com/TeMPOraL/nyan-mode)
- [Consult](https://github.com/minad/consult), [Vertico](https://github.com/minad/vertico), [Orderless](https://github.com/oantolin/orderless), [Marginalia](https://github.com/minad/marginalia)
