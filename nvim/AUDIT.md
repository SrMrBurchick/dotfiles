**Audit scope and result**

Inspected every Lua file, the Packer manifest/generated loader, installed package names, relevant installed plugin implementations, and local Neovim runtime APIs before editing. Local versions: Neovim 0.12.5 and clangd 22.1.8, Linux. Windows/UE 5.7 performance was not reproduced here. No confirmed CRITICAL freeze was found; the findings below distinguish active costs from dormant hazards. No plugins were uninstalled and no unrelated dotfiles were changed.

**Dependency map**

`init.lua` loads base settings → configuration (empty extension point) → highlights → maps → Packer specs → workspace tabs → optional cwd `.nvim.rc.lua` → platform/Neovide settings → split-background fallback. Installed start packages load normally; `after/plugin/*.rc.lua` configures them. Originally, a stale generated Packer loader also ran cached configuration bytecode with absolute Linux paths.

LSP originally depended on successful Mason setup before completion initialization. Linux QML/GLSL/clangd setup functions existed but were never called. Modern Mason could independently enable its installed servers; `workspaces.lua` directly started another clangd with different options on an empty tab. The vendored `clangd_extensions.setup()` contained a third, dormant legacy setup path. There was no active call to that extension module, either custom hint renderer, or `code_actions_utils` in this checkout.

No Unreal implementation-generation, RPC `_Implementation`, matching-cpp search, or custom rg helper exists in this tree. The Perforce config is present but the Perforce package is not installed locally. Neither those missing helpers nor a Windows project-local config can be audited from this checkout. Their absence is not proof they are unused on Windows.

**Performance findings**

| Severity | File / relevant original code | Execution and frequency | Technical risk and action |
|---|---|---|---|
| HIGH | `lua/workspaces.lua`: `vim.lsp.start({...})`; `after/plugin/lspconfig.rc.lua`: `mason_lsp.setup()` | Asynchronous server processes, workspace creation / automatic C++ activation | Separate configs and roots could create separate processes/indexes. Not proof two clients always ran. Removed workspace startup; one native config now owns clangd and Mason excludes it. |
| HIGH, dormant | `lua/eol-hints.lua`: whole-buffer `textDocument/inlayHint` plus BufEnter/InsertLeave/CursorHold/BufWritePost; `clangd_extensions/inlay_hints.lua`: repeated autocmd registration and `clangd/inlayHints` | Requests async; result loops/extmarks synchronous; every configured event if explicitly enabled | Repeated large replies, stale-buffer rendering and multiplying autocmds. Replaced with native API compatibility wrappers. No activation found in this checkout. |
| HIGH | `after/plugin/telescope.rc.lua`: `;f` with `no_ignore=true, hidden=true` and no UE exclusions | Async child search; synchronous result/preview processing when picker is used | Unnecessary build-output enumeration and results. Added rg-side exclusions to file and content searches. No exclusions applied to compiler includes. |
| HIGH | `sf`, installed `telescope-file-browser/.../finders.lua`: grouped `fb_utils.job(...)`, fallback `scan.scan_dir(...)` | Synchronous external wait / synchronous scanning on picker open and navigation | Grouped layout waits for fd; without fd, Lua scans directories. Preserve grouping, explicitly bound depth to 1, disable Git status and symlink following, filter UE output. Still potentially slow in one enormous directory. |
| HIGH | Installed `spelunker.vim`: `BufWinEnter,BufWritePost` → `spelunker#words#check()` → `getline(1,'$')` | Synchronous Vimscript full-buffer spelling, on entry/save | Large C++ files incur full-buffer string/spelling work. Changed its supported check mode to visible-area checks on CursorHold. Spelling remains available; idle checks still cost CPU. |
| MEDIUM | `init.lua`: five window/buffer events × all-window loop; local `buffer_highlight` plugin also rewrites winhighlight | Synchronous Lua, window/file switches | Competing visual ownership and repeated redraws. Installed plugin now owns colors; fallback only runs when it is absent, with a cleared augroup and correct global highlight namespace. External setup guarded against reload multiplication. |
| MEDIUM | `after/plugin/soil.rc.lua`: `jobstart({'plantuml','-darkmode','.'})` | Async process on each `.puml` save | Renders a directory and allows overlapping workers. Now async `vim.system` renders only the saved file; repeated saves coalesce with one final rerender. Errors are reported. |
| MEDIUM | `lua/maps.lua`: `vim.lsp.buf.format()` | Synchronous LSP wait, only on `cf` | Slow format responses stall the editor. Same mapping now requests async formatting. |
| MEDIUM, retained | Installed Telescope project extension: `systemlist(git ... rev-parse)`; `scan.scan_dir` for configured base directories | Synchronous, project actions / setup if base_dirs populated | Empty base_dirs currently avoids recursive startup scanning. Project actions can still block on Git. Retained useful plugin; `<leader>tw` is the existing direct workspace path. |
| MEDIUM, retained | Active cmp buffer source, native Tree-sitter highlighting/experimental indentexpr, native hints, color-highlighter callbacks | Completion/typing/indent/redraw events | Real work on main loop or server; no evidence to justify removing active functionality. Color plugin scans visible lines, not the entire buffer. No arbitrary parser size limit or thread cap added without measurements. |
| LOW, retained | `lua/base.lua`: `path += '**'`; `init.lua`: one `fs_stat` + project-local source; clangd before_init database `fs_stat` | `:find` is synchronous on demand; local source once/startup or reload; one stat per LSP client | Wildignore excludes UE output results but does not guarantee pruning every native search. Prefer existing `;f` for large searches. Individual metadata probes may be slow on network shares. |
| LOW, dormant | Vendored AST/type/symbol utilities | Async requests; synchronous reply formatting; CursorMoved only inside explicitly opened AST view | Fixed deprecated option/highlight APIs, buffer-switch races, AST stale-result checks and per-view augroup cleanup. Full AST/memory tree formatting can still be expensive if explicitly requested. |

The disabled nvim-tree Git integration also bypasses its synchronous Git helpers. Inactive blame configuration has zero delay, but its plugin is absent; it is not evidence for current stalls. `vim.fn.system()`/`io.popen()` are absent from active custom Lua after these changes. SQL UI's inspected command execution uses asynchronous jobstart; no Perforce implementation is available to inspect.

**Clangd final policy**

All server policy lives in `lua/clangd_setup.lua`; `after/plugin/lspconfig.rc.lua` calls it and manages Mason for other servers. `workspaces.lua` only manages tabs/cwd. Extension setup no longer configures a server. Existing extension-server overrides produce a warning directing their owner to the authoritative module.

- Requested seven command arguments, C/C++ only, one enabled configuration. Removed obsolete `--cross-file-rename` and `--inlay-hints` flags (confirmed obsolete by local clangd 22 help), and old arbitrary completion/reference caps.
- Root detection walks ancestors asynchronously, at most 32 levels, never recursively descends. A `.uproject` beats a nested database; `.p4config`/`.p4ignore.txt` bound the search; nearest database is the fallback. No `.git`, `.clang-format`, or random cwd fallback. No unmarked single-file client. Directory-entry inspection runs in Lua after asynchronous scandir; this is not a constant-time operation in a very wide directory.
- `<leader>tw` deliberately supplies the selected root, including for sibling Engine files. It is an explicit override, so select the actual game project, not the whole depot. Roots are not merged across tabs; files already attached to an existing client retain that attachment.
- A root-level `compile_commands.json` is supplied through clangd's `compilationDatabasePath` initialization option. Lua does not read the JSON. Without that file, normal clangd discovery/.clangd configuration applies. For a database elsewhere, set `CompileFlags.CompilationDatabase` in the project's `.clangd`; do not recursively hunt through Intermediate at startup.
- Native inlay hints enabled on supported C/C++ attachments; `:ClangdToggleInlayHints`, `:ClangdSetInlayHints`, `:ClangdDisableInlayHints`. Per-buffer choice persists across additional attachments. No custom refresh events.
- Semantic-token capability removed before initialize and provider disabled before attach. No automatic document highlights, codelens, signature-help requests, or semantic refreshes. Signature help remains on `<C-k>`.
- Native capabilities plus a single cmp completion capability merge, because cmp/snippets are active. Standard position-encoding negotiation replaces the legacy clangd offsetEncoding advertisement.
- Dynamic watched-file registration disabled for clangd to avoid broad Windows client watchers. This does not disable clangd background indexing. External Perforce edits/header changes should be tested; reload affected files/restart clangd if necessary.
- clangd diagnostic virtual text stays off and update_in_insert stays false; signs, underline, severity sorting retain native/existing behavior. No global diagnostic disable was found; no call enables globally disabled diagnostics. Other servers' diagnostic preferences are untouched.
- Default change debounce, worker count, index retention and include paths remain unchanged. A huge UBT database can still cause a large initial background index; a correct workspace root does not make that database smaller. No UE macro hacks, generated-header exclusions, extra tidy checks or extra clangd analysis features added.

**Other cleanup / changed files**

| Files | Change |
|---|---|
| `init.lua`, `lua/base.lua`, `lua/maps.lua`, `lua/workspaces.lua` | Scoped autocmds; remove global `autocmd!`; fix bare `syntax=on`; modern uv; escape local source path; earlier correct netrw flags; fix broken `local status,telescope = require(...)`; async formatting; retain window/tab/navigation mappings. |
| `lua/clangd_setup.lua`, `after/plugin/lspconfig.rc.lua`, `after/plugin/completion.rc.lua` | One native server policy; remove uncalled legacy server setup and deprecated diagnostic wrapper; retain completion/snippet source order and insert mappings; modern diagnostic jumps. |
| `lua/eol-hints.lua`, `lua/code_actions_utils.lua`, `lua/clangd_extensions/{init,inlay_hints,ast,memory_usage,symbol_info,type_hierarchy}.lua` | Native hint compatibility, safer dormant helpers, no alternate LSP setup; preserve extension command entry points. |
| `lua/plugins.lua`, `plugin/packer_compiled.lua`, `after/plugin/{startup,csvview,highlight-colors}.rc.lua` | Fix nested neoqmllsp use and malformed DAP list; add missing Tree-sitter spec; move three setups out of cached loader into readable files. All packages remain eager; no Packer migration. |
| `after/plugin/treesitter.rc.lua` | Current main API, native FileType start, cleared augroup, no automatic downloads. Retain original supported filetypes/indent intent; remove ineffective legacy autotag/rainbow options and double regex highlighting. |
| `lua/ue_paths.lua`, `after/plugin/{telescope,nvim-tree}.rc.lua` | Search/explorer exclusions; retain default tree watcher exclusions as well as UE outputs. Merge duplicate renderer tables (restores intended group_empty). Tree `U` can reveal filtered files. |
| `after/plugin/{buffer-highlight,soil,dap,git,lspsaga}.rc.lua` | Guard visual setup; coalesced file render; supported Mason DAP setup instead of assigning internal maps; remove exact F5 duplicate; fix nil Octo assignment; update `gp` to supported `peek_definition`. |
| `tests/clangd_audit.lua`, `AUDIT.md` | Repeatable real-clangd regression check and audit record. |

Existing CRLF conventions are retained in previously CRLF files. `git -c core.whitespace=cr-at-eol diff --check -- .` passes; plain diff --check treats CR as trailing whitespace in this repo.

**Plugin inventory**

Classification describes the inspected configuration, not whether a plugin is intrinsically good or bad. No plugin was uninstalled.

| Plugin(s) | Classification / evidence |
|---|---|
| packer.nvim | Necessary for current management; possibly obsolete/unmaintained upstream. Retained to avoid a manager migration. |
| nvim-lspconfig | Necessary/useful native server definitions, including other Mason-enabled servers. |
| mason.nvim, mason-lspconfig.nvim | Useful binary/other-server management; registry refresh can perform startup I/O. clangd does not depend on Mason succeeding. |
| nvim-treesitter | Necessary; missing from manifest/install originally. Added main-branch spec; temporary C/C++ validation only, normal install pending. |
| nvim-cmp, cmp-nvim-lsp, cmp-path, cmp-buffer | Useful, actively configured; buffer source potentially expensive. Retained. |
| LuaSnip, cmp_luasnip, friendly-snippets | Useful, actively configured expansion/loading and Tab/Shift-Tab integration. Retained. |
| lspkind.nvim | Useful, active completion formatting. |
| lspsaga.nvim | Useful, active finder/rename/peek/hover/outline/diagnostic mappings. Lightbulb already disabled. |
| telescope.nvim, plenary.nvim | Necessary for existing searches and plugin dependencies. |
| telescope-file-browser.nvim | Useful; potentially expensive synchronous grouped browsing, now bounded by default. |
| telescope-project.nvim | Useful; potentially expensive synchronous Git/project actions remain. |
| telescope-media-files.nvim | Possibly unused: installed/spec present, no load_extension or mapping found. Retained for manual extension use. |
| popup.nvim | Possibly obsolete/redundant dependency; no direct config use found. Retained because older extensions may rely on it. |
| nvim-tree.lua, nvim-web-devicons | Necessary for explorer/UI; active setup. |
| vim-devicons | Possibly redundant alongside web-devicons, but supports Vimscript plugins. Retained. |
| lualine.nvim | Useful active statusline; built-in components only, no custom expensive callback. |
| cyberdream.nvim | Necessary current theme, unchanged appearance/settings. |
| awesome-vim-colorschemes | Useful optional theme library, not selected now. Retained. |
| buffer_highlight.nvim (local) | Useful active visual behavior; synchronous window loops and ungrouped autocmds upstream, guarded locally. |
| nvim-highlight-colors | Useful, active color rendering; visible-area callbacks on changes, buffer entry, scrolling and LSP attach. Retained. |
| csvview.nvim | Useful CSV commands; setup restored outside stale loader. |
| qmake-syntax-vim, vim-qml | Useful QML/qmake syntax, retained. |
| neoqmllsp | Possibly unused: installed/spec present, no active explicit server config. Do not remove a language tool based only on that. |
| nvim-autopairs | Useful active editing behavior, retained. |
| spelunker.vim | Useful/potentially expensive; supported visible-area mode now replaces automatic full-buffer scans. |
| markdown-preview.nvim | Useful, three existing mappings retained. |
| nvim-dap, mason-nvim-dap.nvim, nvim-dap-ui, nvim-nio | Useful debugging stack/dependencies, mappings retained. Actual Windows adapters need manual testing. |
| startup.nvim | Useful current startup screen; readable setup retained. |
| nvim-soil, nvim-nyctophilia | Useful UML generation/syntax; render scope/concurrency fixed. |
| sqlui (local) | Useful manual SQL interface; local external package retained, inspected job execution is async. |
| true-zen.nvim | Useful active normal-mode Ctrl-F focus mapping. Does not conflict with insert-mode cmp Ctrl-F. |

Configured but not installed locally: bufferline, Comment, notify, perforce, blame_line, octo, plantuml/plantuml-previewer and optional json5. Their guarded config remains. `ta`/`la` reference missing vstask/vslaunch extensions; kept because project-local Windows additions are unknown. `lsp_signature` is neither configured nor installed here. Vendored cmp_scores is unreferenced and retained. No blanket plugin cleanup was run.

`<Space>` remains the window-cycle mapping, including its existing prefix interactions. The leader remains Neovim's default backslash; `<leader>tw` is unchanged. Normal/insert Ctrl-F maps have separate modes. The only exact duplicate removed was F5. Corrected `<M-o>` and `gp` without changing their keys.

**Validation and remaining manual work**

Passed on local Neovim 0.12.5 / clangd 22.1.8:

- All config Lua files compile; actual Packer specs and installed completion/UI/search/DAP setups load.
- Real clangd fixture: one client for two C++ buffers, automatic .uproject selection, nested Intermediate database overridden, Perforce boundary, explicit Engine workspace, unmarked-file guard, native hints and toggle, semantic-token/watcher policy, navigation mappings.
- A macro defined only in compile_commands.json resolves in an actual hover response, confirming database use, not merely path selection. Tested with and without installed lspconfig/cmp capability integration.
- Real temporary C and C++ parsers parse/highlight successfully; repeated FileType reuses parser; workspace/Tree-sitter augroup counts and full init reload stay stable.
- Full startup succeeds with isolated data/cache directories. Earlier sandbox Mason EPERM vanished outside the sandbox; earlier Telescope project data-file error vanished with writable isolated data. Neither is claimed as a config freeze.
- checkhealth: native LSP/Tree-sitter checks pass; vim.deprecated reports no deprecated functions on the exercised path. nvim-treesitter reports **tree-sitter-cli not found**. Bufferline's existing missing-plugin notice remains.
- One final startup measurement was about 142 ms in this Linux test environment. Baseline startup had errors/different cache state, so no defensible before/after speedup is claimed.

Run `nvim --headless -u NONE -i NONE -l tests/clangd_audit.lua` from this config to repeat the focused server test (requires clangd; creates a temporary project). Temporary parser builds do not validate Lua highlighting or parser installation on Windows.

On Windows:

1. Verify Neovim version first. This native LSP config needs >=0.11; current Tree-sitter main requires >=0.12, tree-sitter CLI >=0.26.1, curl/tar and a C compiler. Install the newly declared plugin with Packer, then `:TSInstall c cpp lua` and `:checkhealth nvim-treesitter`. Install other previously configured parsers only as needed. No package updates/installations were made to the normal local plugin directory during this audit.
2. Select the actual game root with `<leader>tw` when editing sibling Engine files. Open two project C++ files, check `:checkhealth vim.lsp`/`:lua vim.print(vim.lsp.get_clients({name='clangd'}))` for one client per intended root. Inspect its root and UBT database location; validate generated headers/macros with the real UE database.
3. Exercise gd/gD/gi/gr/gp, references across modules, completion/snippet Tab/Enter, hint toggle, window/tab navigation, `;f`, `;r`, `sf`, tree expansion/filter toggle and external Perforce file changes.
4. Test missing custom RPC/implementation helpers and Perforce commands in their real installation; review any `.nvim.rc.lua` for its own LSP startup or synchronous p4/rg calls. Check Windows DAP F5/F9 and rapid PlantUML saves.
5. If stalls persist, capture a profile around the editing action, not just startup: `:profile start <writable-path>/nvim-profile.log`, `:profile func *`, `:profile file *`, reproduce, `:profile stop`. This primarily profiles Vimscript (useful for Spelunker); it does not fully profile Lua or clangd CPU. Compare briefly with hints toggled off, and record clangd CPU/RAM and action timing. Do not leave verbose LSP logging on for normal editing.

The theme, Neovide appearance, split/navigation layout, active completion stack, Perforce entry points and original useful commands were deliberately retained. No project compiler flags, include directories, .clangd, query-driver allowlist, worker counts, index scope or semantic-token re-enable was guessed.

**API references checked**

Current native config/enable and inlay-hint APIs: [Neovim LSP documentation](https://neovim.io/doc/user/lsp.html). Current setup/start/install pattern and requirements: [nvim-treesitter README](https://github.com/nvim-treesitter/nvim-treesitter). Database initialization option and encoding transition: [clangd protocol extensions](https://clangd.llvm.org/extensions). Project database/inlay configuration: [clangd configuration](https://clangd.llvm.org/config). Installed plugin/runtime source was also inspected for actual behavior; no plugin performance conclusion relies solely on age.
