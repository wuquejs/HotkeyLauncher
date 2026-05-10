# HotkeyLauncher

Native macOS hotkey launcher built with SwiftUI, AppKit, and Carbon global hotkeys.

![demo](./hotkey-launcher.png)

## Build and Run

```bash
./script/build_and_run.sh
```

The app stores shortcuts at:

```text
~/Library/Application Support/HotkeyLauncher/shortcuts.json
```

Global settings are stored at:

```text
~/Library/Application Support/HotkeyLauncher/settings.json
```

Enable **New window when none are visible** to apply the behavior to all
shortcuts. When a target app is already running but has no visible regular
windows, HotkeyLauncher activates it and sends `Command+N` so apps like Chrome
create a window instead of appearing to do nothing. macOS may require
Accessibility permission for HotkeyLauncher to send that keystroke.

Default shortcuts:

- `Option+Command+T` -> `/Applications/FlowDeck.app`
- `Option+Command+C` -> `/Applications/Google Chrome.app`
- `Option+Command+X` -> `/Applications/Codex.app`
- `Option+Command+F` -> `/Applications/Fork.app`
