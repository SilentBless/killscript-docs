---
title: Your first module
description: Create, run, and debug a folder-based KILLSCRIPT module.
---

We will create a regular client module that writes to the console and displays the current tick on screen. This small example confirms code loading, hot reload, and API access.

## 1. Create the module

1. Open the in-game module menu.
2. Select **Create**.
3. Enter `HelloDebug` as the name.
4. Leave **Is Reflex** disabled.
5. Do not add tags yet.
6. Confirm creation and enable the module.

The name cannot be empty or contain the `@` character.

The game creates `Modules/HelloDebug/` with starter files. Use **Folder** to open it or **VS Code** to open the editor if it is installed.

## 2. Start a game session

Module Lua code runs inside a game session, not in the main menu. A [custom server](../../servers/custom-server/) with any map is the most convenient development environment.

After you enter the game, the default `scripts/main.lua` prints:

```text
Hello world!
```

## 3. Find the log in the console

1. Open the console with `~`.
2. Select your module's log section or source.
3. If the message is hidden, use the filter icon next to **Search** and enable informational messages.
4. Find a line prefixed with `[HelloDebug]`.

The console remembers its category filters. If `print()` appears to do nothing, check both the selected module section and the filter icon first.

## 4. Replace main.lua

Open `Modules/HelloDebug/scripts/main.lua` and replace its contents:

```lua
print("HelloDebug loaded")

Scheduler:OnFrame(function()
    ImGui:DrawDebugText(
        "[HelloDebug] Tick: " .. tostring(Time.Tick)
    )
end)
```

Save the file. The game automatically reloads a folder module.

You should now see:

- `HelloDebug loaded` in the console;
- a continuously updating tick number near the edge of the screen.

[`ImGui`](../../api/imgui/) draws for the current frame only, so `DrawDebugText()` is called from [`Scheduler:OnFrame()`](../../api/scheduler/#onframe).

## 5. Confirm hot reload

Change the loaded message or the label before the tick and save again. You should not need to restart the game or toggle the module—the new content appears after the automatic reload.

If it does not reload, verify that:

- the module is enabled;
- a game session is loaded;
- you are editing the folder under the current game installation;
- the console does not report a Lua error or a locked file.

## Next steps

- [Module structure](../module-structure/) — settings, inputs, images, sounds, and UI files;
- [Development and debugging](../workflow/) — hot reload, console filters, and common errors;
- [ImGui](../../api/imgui/) — a quick HUD without UXML;
- [UI and UXML](../../api/ui/) — persistent panels and windows.
