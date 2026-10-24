# Sketchybar taskbar icon duplication diagnosis

Goal: explain why app icons in the top-left taskbar duplicate when an app quits.

Confirmed context:
- `items/spaces.sh:56-64` defines `space_creator_new`, subscribes it to `space_windows_change`, and runs `plugins/space_windows.sh`.
- `plugins/space_windows.sh:23-26` builds the current app list from `$INFO` with `jq -r '.apps | keys[]?'`.
- `plugins/space_windows.sh:32-36` builds existing SketchyBar items with names starting with the current `space.` prefix.
- `plugins/space_windows.sh:41-46` deletes items only when item count is greater than app count, and deletes the last item returned by `sketchybar --query bar`.
- `plugins/space_windows.sh:53-70` names icon items by position, e.g. `${space}.app.${i}`, and overwrites their image by current app index.

Diagnosis:
- The script uses positional slots rather than stable app identities.
- When an app that is not the final slot quits, remaining apps shift index.
- The script removes only a last returned item, not the stale app's item or a deterministic numeric suffix.
- Then it overwrites surviving indexed items with the shifted app list, so the next app can appear duplicated while the closed app's stale slot is not removed immediately/correctly.

Oracle review:
- Primary diagnosis confirmed.
- Secondary issues: `jq keys[]?` sorts object keys, existing items are not sorted by numeric suffix, item identity is index-based, and `sketchybar --query bar` return order may not equal numeric suffix order.
- Minimal fix direction: remove items by deterministic numeric suffix where suffix >= app count.
- Cleaner long-term fix: name items by sanitized/hash app identity and remove existing items whose app identity is no longer present.

Applied change:
- User chose the minimal deterministic fix, one icon per app, current app-key order, and a small redraw delay acceptable.
- Before editing, backed up the full current config to `/Users/alexandre/.config/sketchybar.backup.20260711-225024`.
- Updated `plugins/space_windows.sh` to query only indexed app items matching `${space}.app.N`, remove stale items by numeric suffix `N >= app_count`, and quote item names in existence/add/move calls. The item query uses `startswith("${space}.app.") and test("[0-9]+$")` instead of relying on broad `${space}.` prefix matching.
- Validation: `bash -n plugins/space_windows.sh` passed.

Refactoring review:
- Highest-value cleanup is removing the abandoned commented prototype block in `plugins/space_windows.sh:77-158`.
- Extract the current phases into functions: get apps, get space app items, remove stale app items, and upsert app items.
- Remove noisy runtime logging like `echo "${item} exists"` or guard it behind a debug flag.
- Make app extraction safer with `.apps // {} | keys[]`.
- Rename `items` to `app_items` for clarity.
- Stable app-identity item names are not necessary yet unless adding animations, per-app click actions, preserved ordering, richer metadata, or fewer redraws.

Refactor applied:
- Backed up the fixed plugin to `plugins/space_windows.sh.backup-before-refactor-20260712-115455`.
- Replaced the long prototype-heavy script with documented functions: `item_exists`, `get_current_space`, `get_apps`, `get_space_app_items`, `remove_stale_app_items`, `upsert_app_items`, and `update_space_app_icons`.
- Removed old commented experiments and noisy runtime logging.
- Preserved index-based minimal deterministic behavior.
- Restored executable bit after rewrite.
- Validation: `bash -n plugins/space_windows.sh` passed.
- Oracle review accepted the refactor as-is; no blockers. Optional future cleanup only: document or reduce shared globals if the plugin grows.

Desktop switch lag investigation:
- User reports SketchyBar appears to unload/reload for about 1s when switching desktops.
- No local switch hook was found that calls `sketchybar --reload`.
- Live `sketchybar --query bar` reports `sticky=on`, so the bar should stay visible across space changes; docs confirm sticky keeps the bar visible during space changes and defaults to on.
- `items/spaces.sh:31-37` creates 12 space items, each subscribed to `front_app_switched`, `space_change`, and `display_change`; on a desktop switch, this can fan out into many `plugins/space.sh` invocations.
- `plugins/space.sh:3-11` sources colors and calls `sketchybar --set` for each subscribed space item.
- `items/spaces.sh:62-64` subscribes `space_creator_new` to `space_windows_change`, running `plugins/space_windows.sh`.
- `plugins/space_windows.sh` is heavier: parses `$INFO` with `jq`, calls `sketchybar --query bar | jq`, then may query/add/move/set multiple app icon items.
- Mock timings: one `space.sh` invocation around 0.014s; one `space_windows.sh` invocation with 4 app names around 0.19s. A switch may trigger multiple space scripts plus the app-icon reconciler, causing visible redraw/reflow.
- Oracle review: likely not a real reload; most likely event storm + expensive dynamic app-icon reconciliation. First tests: temporarily disable `space_creator_new`, remove unnecessary `front_app_switched` subscription, and/or add timestamp logs to count invocations per switch.
- User clarified AeroSpace/Yabai are old configs; current window manager is Amethyst. Active Amethyst config is `/Users/alexandre/.config/amethyst/amethyst.yml`.
- User observations: direct desktop-by-index switching has very low latency; switching to desktop 1 has no delay; on delayed switches, macOS widgets reappear at the same time as SketchyBar.
- This makes a SketchyBar-only root cause less likely. If macOS widgets and SketchyBar reappear together, the delay is likely at the macOS Space/WindowServer overlay redraw layer, possibly triggered or amplified by Amethyst reflow/focus handling.
- Amethyst config details: layout HUD on space change is disabled (`enables-layout-hud-on-space-change: false`), mouse/focus-follow features are disabled, but `follow-space-thrown-windows: true` is enabled for throw-space workflows. The visible delay on normal desktop switching is not explained by an explicit Amethyst config delay.
- External research: Amethyst has known issues around Space focus/reflow races and macOS Mission Control timing; SketchyBar sticky bars/widgets can reappear only after Space animation/WindowServer finishes. Direct numbered Space jumps vs previous/next Space transitions may behave differently in macOS.
- User further isolated the issue: delay also happens with the three-finger trackpad gesture, not only Amethyst's shortcut. This strongly points to macOS's relative Space transition path (next/previous/gesture) rather than Amethyst shortcut implementation. Direct numbered Space jumps remain fast.

Amethyst stale layout / Hammerspoon workaround:
- User observed Amethyst can leave a hole after quitting tiled apps with Cmd+Q; `reevaluate-windows` (`mod1+z`) fixes it immediately, confirming stale window tracking / missed app termination window cleanup.
- Hammerspoon installed via Homebrew cask. Initial install had stale cask state, resolved by uninstalling and reinstalling.
- Created `/Users/alexandre/.hammerspoon/init.lua` with an `hs.application.watcher` that listens for app termination, waits 0.25s, then sends Amethyst's reevaluate shortcut (`cmd+alt+z`).
- Amethyst config already had `reevaluate-windows: mod1 + z` enabled in `/Users/alexandre/.config/amethyst/amethyst.yml`.
- Backed up Amethyst config to `/Users/alexandre/.config/amethyst/amethyst.yml.backup-before-hammerspoon-20260712-152449`.
- Added `hs.ipc.cliInstall()` to allow `hs -c 'hs.reload()'`; verified `hs -c 'return "ok"'` works and Hammerspoon is running.
- Documented this workaround in Obsidian note `/Users/alexandre/Documents/Obsidian/Knowledge/life/Apple/Macbook Pro/Rice/Amethyst.md` under troubleshooting.
