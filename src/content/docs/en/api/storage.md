---
title: Storage
description: Persistent local data for KILLSCRIPT Lua modules.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. Value types, nested tables, key deletion, and the save lifecycle were confirmed in game.
:::

`Storage` is a regular Lua table containing local data for the current module. It is client-only; the global `Storage` value is `nil` in a Reflex `server.lua`.

## Quick example

```lua
if Storage.Settings == nil then
    Storage.Settings = {
        ShowHints = true,
        Scale = 1
    }
end

Storage.Settings.Scale = 1.25
```

Storage is isolated by module. Another module does not receive this table.

## Supported values

| Lua value | Persisted |
|---|:---:|
| `string` | ✅ |
| `number` | ✅ |
| `boolean`, including `false` | ✅ |
| nested `table` | ✅ |
| `nil` | deletes the key |
| `Vector2`, `Vector3`, `Color`, and other userdata | ❌ |
| `function` | ❌ |

Unsupported values are silently discarded during serialization.

Store a structure such as [`Vector3`](../vector3/) as separate numbers:

```lua
local position = Vector3.new(10, 2, 5)

Storage.Position = {
    x = position.x,
    y = position.y,
    z = position.z
}

local saved = Storage.Position
local restored = Vector3.new(saved.x, saved.y, saved.z)
```

## When data is saved

The game saves `Storage` when the module is disabled normally and loads it the next time the module is enabled.

:::caution[Hot reload does not save the current table]
Editing `main.lua` and triggering an automatic hot reload did not serialize the active module's data. A value that had been written but not saved was absent after reload.

Do not treat hot reload as a save point. Disable the module normally when testing persistent data.
:::

## Deleting data

Assign `nil`, then disable the module normally:

```lua
Storage.LegacyValue = nil
Storage.OldSettings = nil
```

The removed keys remain `nil` after the next enable.

## Recommended structure

Keep data under one versioned key to make migrations easier:

```lua
if Storage.Data == nil or Storage.Data.Version ~= 1 then
    Storage.Data = {
        Version = 1,
        Enabled = true,
        Opacity = 0.8
    }
end
```

## Common mistakes

### Storing userdata directly

`Storage.Position = Vector3.one` works in the live Lua table, but the value disappears during serialization. Convert the [vector](../vector3/) to a table of numbers.

### Testing a boolean with if not

When `false` is a valid stored value, distinguish it from a missing key:

```lua
if Storage.Enabled == nil then
    Storage.Enabled = true
end
```

Structured values such as [Vector2](../vector2/), [Vector3](../vector3/), and [Color](../color/) must be stored as number tables.
