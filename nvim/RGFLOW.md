**Workflow**

| Mapping / command | Action |
|---|---|
| `;r` / `:RgFlowSearch` | Open rgflow's normal three-line search form at `vim.t.root_dir` or cwd. Edit flags/pattern/path, then Enter to run rgflow. |
| `;R` / `:RgFlowTelescope` | Show the latest retained rgflow search in Telescope, without another search. |
| `:RgFlowQuickfix` | Reopen the latest retained rgflow quickfix result buffer. |
| `:RgFlowHistory` | Pick a retained rgflow search, then view its existing results in Telescope. |
| `:RgFlowAbort` | Native rgflow abort/close action. |
| `:copen`, `:cnext`, `:cprev`, `:colder`, `:cnewer`, `:chistory` | Normal quickfix navigation/history. |

Enter in the results picker activates the original quickfix list and uses `:cc` to jump to its exact location. This also makes subsequent `:cnext` / `:cprev` refer to that search. Standard Telescope split/vertical split/tab selections are retained. Escape closes Telescope in either mode; it does not close, clear or wipe the original quickfix list. Merely viewing an older search does not switch the active list. The result text is displayed intact, including literal pipes, with file:line:column and Telescope's normal source preview/highlighter.

Use the dedicated reopen commands instead of `;;`: these pickers intentionally disable Telescope result caching, so a second persistent result store is not created. `;;` and all other existing Telescope mappings remain unchanged. Ctrl-Q/Alt-Q export actions are disabled only inside these two custom pickers because exporting would create a duplicate quickfix list. Use rgflow's native quickfix operations instead.

For an explicitly selected quickfix ID, the Lua functions are `require('rgflow_telescope').results(id)` and `.quickfix(id)`; ordinary commands select the latest retained search, not whichever list an unrelated tool last created.

**What upstream actually stores**

Inspected rgflow commit `c97daadc871aad548cb717b04bbaa948dd2f0fea`; the Packer spec pins this revision. Its public API, search execution, quickfix population, defaults, UI lifecycle and mappings were read before implementation.

- Completed entries live in native quickfix lists. The quickfix buffer renders a list; it is not a separate authoritative store. `getqflist({id=..., items=0})` is the supported result-access API.
- The two rgflow-specific scratch buffers are the input form and its headings. They use wipe-on-hide behavior. They are not persistent search-result buffers.
- Each search that produces output creates a new quickfix list. Several searches can coexist in the native history stack; the integration enables rgflow's supported `new_list_always_appended` setting to preserve newer lists when searching from an older one.
- `open_again()` reopens the search form; command-history entries recall search parameters. Neither is an API for reopening completed results. Our result/history commands never call `open_again`, `search`, or a Telescope grep builtin.
- Upstream keeps a temporary queue while adding matches, but the integration neither reads nor retains it.

These decisions follow the inspected [rgflow API](https://github.com/mangelozzi/rgflow.nvim/blob/c97daadc871aad548cb717b04bbaa948dd2f0fea/lua/rgflow/init.lua), [UI](https://github.com/mangelozzi/rgflow.nvim/blob/c97daadc871aad548cb717b04bbaa948dd2f0fea/lua/rgflow/ui.lua), and [quickfix implementation](https://github.com/mangelozzi/rgflow.nvim/blob/c97daadc871aad548cb717b04bbaa948dd2f0fea/lua/rgflow/quickfix.lua).

The architecture is:

```
rgflow form -> rgflow's asynchronous rg process -> native quickfix list
                                                   |             |
                                             quickfix buffer  Telescope view
```

The supported `quickfix.open_qf_cmd_or_func` hook tags each new list using native quickfix context metadata, then opens it normally. The tag stores a display label only, not result entries. History reads list IDs, labels and sizes; it does not read every search's results. A picker gets one temporary copy of its selected list through Neovim's API, as required by Telescope's in-memory finder. That copy is not cached across invocations; reopening reads quickfix again.

**Lifetime and validity**

Results survive closing Telescope, closing/wiping the quickfix view buffer, switching windows/files and normal editing. Reopening quickfix recreates its view if necessary. This is in-session persistence, not an on-disk search database or a promise of persistence across Neovim restarts.

Retention is bounded by Neovim's quickfix history (default 10; governed by `chistory` on Neovim 0.12). The integration leaves that limit unchanged and does not create an unlimited set of hidden search buffers. Old lists disappear when the stack expires them or a tool explicitly clears/replaces history. Other tools can still discard newer lists when branching from an older list; rgflow's append setting controls rgflow only.

Quickfix delete/mark operations remain authoritative, and the next picker reads their current entries. Native `:Cfilter` creates a new derived list without inheriting context; it remains accessible through `:chistory`/`:colder`/`:cnewer`, but is not identified as a new rgflow search in `:RgFlowHistory`. No broad autocmd is added to intercept other tools' quickfix operations.

Saved match text is a search snapshot. Neovim can adjust quickfix positions for edits in loaded source buffers; opening the picker reads those current native positions. External disk changes are not continuously tracked or searched. The ordinary preview shows current source content, which can differ from old match text. If quickfix changes while a picker is open, selection is rejected with a request to reopen, preventing a saved row index from jumping to a different item. There is no periodic validation or automatic rerun.

**One isolated internal dependency**

`idle()` reads `require('rgflow.state').get_state().mode` and compares it with `rgflow.modes` to prevent our commands from switching the active list while rgflow is populating it, or while its form is open. This is the only use of undocumented rgflow state. It does not access private results, window IDs, buffer IDs or queues.

It is necessary because upstream appends batches to the *current* list, and its public completion callback is only invoked in one final-batch path. Small/no-match searches can finish through `search.on_exit` without invoking that callback. A callback-only busy flag would get stuck. No monkey-patching, polling or replacement search engine was introduced. Recheck these two modules and rerun the tests when updating the pinned plugin. Native commands such as `:colder` remain under user control; avoid switching lists or starting another raw `rgflow.search()` while an rgflow job is adding results.

A native edge case remains: zero-match searches do not create a new result list and may retitle the previous list while leaving its entries intact. Errors similarly need checking in `:messages`. The custom pickers use the saved original label; “latest retained search” means the newest actual retained result list, not a new empty snapshot. See [search completion](https://github.com/mangelozzi/rgflow.nvim/blob/c97daadc871aad548cb717b04bbaa948dd2f0fea/lua/rgflow/search.lua).

**Unreal/Perforce exclusions**

Default flags reuse `ue_paths.rg_args()` unchanged: Binaries, DerivedDataCache, Intermediate, Saved and .vs are excluded by rg itself. No include/index configuration is changed. Flags are editable in rgflow, and upstream remembers those edits for later searches; deliberately removing an exclusion remains possible.

`--smart-case` preserves regex searching; `--no-ignore-vcs` avoids relying on Git ignore state while retaining ripgrep's `.ignore`/`.rgignore` support. The default `--max-columns 500` follows rgflow's long-line protection; long matches may be reported as omitted text. Change it in the flags field if needed.

No `.p4ignore.txt` was present to inspect. Ripgrep's `--ignore-file` reads Git-style rules. Perforce's syntax overlaps but is not identical: for example its `**` can cross path separators in placements that do not have equivalent Git glob semantics; Windows path separators also need care. Accordingly no automatic `.p4ignore.txt` ingestion or guessed conversion is enabled. Put verified search-specific rules in a project `.rgignore`, or explicitly use `--ignore-file` only after checking the file's semantics. Upstream splits its flags field on spaces rather than shell-parsing quotes, so quoted paths containing spaces in *flags* are not supported. The separate search-path field is passed as one argument and was tested with spaces.

Sources: [ripgrep filtering guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#automatic-filtering), [Perforce P4IGNORE syntax](https://help.perforce.com/helix-core/server-apps/cmdref/current/Content/CmdRef/P4IGNORE.html).

**Performance and tests**

No project traversal, synchronous process call, filesystem watcher, CursorMoved/TextChanged callback or refresh loop is added. Telescope only transforms/filters one existing result set and reads the selected file through its standard buffer previewer. Native API copying and Telescope filtering cost O(result count); huge result sets can still consume noticeable memory/time. History construction costs O(retained list count), without materializing all those lists' entries.

Upstream itself is not cost-free: it removes queued entries from the front of a Lua array and copies/re-highlights quickfix entries across batches. Very broad searches can therefore be costly even though rg runs asynchronously. The standard batch size is retained; no unmeasured “faster” batch setting is imposed. Upstream's first manual flags autocomplete calls synchronous `rg -h`, and its explicit path completion uses Vim's file completion. These existing on-demand features are preserved; they are not used by search-result/history pickers. A help invocation is separate from the single actual search. See [upstream autocomplete](https://github.com/mangelozzi/rgflow.nvim/blob/c97daadc871aad548cb717b04bbaa948dd2f0fea/lua/rgflow/autocomplete.lua).

Run:

```sh
nvim --headless -u NONE -i NONE -l tests/rgflow_telescope.lua
```

The test uses real rgflow, ripgrep and Telescope. It creates a temporary project, instruments `uv.spawn`, and rejects synchronous system/systemlist/popen calls on the exercised paths. Four searches (including no-match and 3,000-match searches) started exactly four rg processes. Result reopen/history/selection/preview started none. It checks UE exclusions even with `--hidden`, a root containing spaces, byte columns including Unicode, source preview highlighting, Escape preservation, native line adjustments, history selection, quickfix buffer wipe/reopen, append-history behavior, unrelated quickfix lists, stale selection rejection, list deletion, and setup reload counts. The 3,000-result picker took about 34 ms locally; this is not a Windows performance guarantee.

Testing uses default headless screen dimensions: resizing the screen after startup triggered a Neovim 0.12.5 native `grid_clear_line` crash in the original test harness. Removing that test-only resize resolved it; production configuration does not resize the screen.

The inspected revision was installed in the local Packer start directory. Full-config startup, command registration, existing Telescope/window mappings, the ordinary Telescope buffers picker, and reload safety passed. Sandbox-only failures in the existing Telescope project data-file write and Mason initialization disappeared when the full check ran outside the sandbox. The pre-existing missing Bufferline notice remains.

Changed configuration files: `lua/plugins.lua`, `after/plugin/telescope.rc.lua`, new `after/plugin/rgflow.rc.lua`, and new `lua/rgflow_telescope.lua`. Added this guide and `tests/rgflow_telescope.lua`. Clangd/LSP, Tree-sitter, existing UE exclusions and unrelated mappings are unchanged. Install/sync the declared Packer plugin on other machines before using the new commands.
