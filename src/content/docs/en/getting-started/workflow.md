---
title: Development and debugging
description: Hot reload, the game console, a fast editing loop, and common KILLSCRIPT module errors.
---

A normal folder-module workflow takes only a few seconds:

1. start a [custom game session](../../servers/custom-server/);
2. enable the module;
3. edit a file;
4. save it;
5. inspect the result and console.

## Hot reload

The game watches files inside folder modules and requests a reload after a save. This covers Lua code, configuration, and assets.

Some files also trigger additional work:

- changing [`inputs.json`](../../api/input-action/) rebuilds input actions;
- changing `module.json` refreshes metadata and may reload client modules;
- changing `scripts/server.lua` refreshes the server side of the active [Reflex module](../../reflex/architecture/).

Hot reload replaces the previous Lua module instance. Initialize state, subscriptions, and windows as if the file were starting from scratch.

## Console

Open the console with `~`. It contains:

- `print()` output;
- Lua errors with file names and line numbers;
- load and hot-reload messages;
- invalid JSON and asset warnings.

### When print is not visible

The icon next to **Search** controls message-category filters. The console also has a selected log section or source.

Check both:

1. your module's section is selected;
2. informational messages are enabled in the filter.

Then look for lines such as:

```text
[MyModule] [main.lua:12]: Module loaded
```

## A useful diagnostic template

```lua
print("Module loaded")

local frames = 0

Scheduler:OnFrame(function()
    frames = frames + 1

    if frames == 1 then
        print("First frame received")
    end

    ImGui:DrawDebugText("Frames: " .. tostring(frames))
end)
```

The result narrows failures quickly:

- no first line: the module is not running or `main.lua` failed to load;
- first line but no second line: an error happened before `OnFrame` registration;
- both lines but no on-screen text: inspect the [ImGui](../../api/imgui/) call and current game context.

## Common errors

### Lua access failed for member

```text
Lua access failed for member 'SomeProperty'
```

The member is unavailable in the current context or does not support that operation. A read-only property cannot be assigned, and a client-only API cannot be called from `server.lua`.

Check the context and `get`/`set` information on the relevant API page.

### attempt to call a nil value

```text
attempt to call a nil value (global 'type')
```

The Lua sandbox does not expose that global function, or the name is incorrect. A module does not receive every function from standard Lua.

### JSON does not load

Check the shape of the root value first. For example, [`config.json`](../../api/config/) must contain an array:

```json
[
  {
    "label": "Enabled",
    "key": "Enabled",
    "type": "bool",
    "value": true
  }
]
```

An object such as `{ "Enabled": true }` does not match the settings format.

### Sharing violation

When a project is edited over a network share or an editor holds a file while writing, hot reload may report `Sharing violation`. Wait for the save to complete and save once more. Disable editor extensions or other software that holds the changed file open for too long.

### Nothing runs in the menu

Client Lua starts after you enter a game session. You can manage modules in the main menu, but test `main.lua` on a loaded map.

### Reflex code does not run

Verify that:

- `module.json` contains `"IsReflex": true`;
- `scripts/server.lua` exists;
- this Reflex module is selected;
- another Reflex module is not occupying the single active slot.

## When to restart completely

Normal code edits need only hot reload. Toggle the module off and on when its state seems inconsistent. Reserve a full game restart for a package that is not being re-read or a game session that has entered an invalid state.

Continue with [module structure](../module-structure/), [editor and API completion](../../module-development/editor/), and [organizing Lua code](../../module-development/code-organization/).
