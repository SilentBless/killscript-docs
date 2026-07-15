---
title: Config
description: User-facing module settings through config.json and the Config Lua table.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The file format, setting types, normalization, and client/Reflex server behavior were confirmed in game.
:::

`config.json` declares settings that the game presents to the user. Their current Lua values are stored in the global `Config` table.

`Config` is available in `main.lua` and a Reflex `server.lua`. It is an empty table when the module declares no settings.

## Minimal config.json

The file belongs in the module root. Its root must be a JSON array:

```json
[
  {
    "label": "Show panel",
    "key": "ShowPanel",
    "type": "bool",
    "value": true
  },
  {
    "label": "Panel scale",
    "key": "PanelScale",
    "type": "number",
    "value": 1,
    "min": 0.5,
    "max": 2
  }
]
```

Use the values from Lua:

```lua
if Config.ShowPanel then
    local scale = Config.PanelScale
    -- Draw the panel
end
```

:::caution[The root is not an object]
`{ "ShowPanel": true }` does not load. The game expects an item array: `[{ ... }]`.
:::

## Common fields

| Field | Type | Description |
|---|---|---|
| `label` | `string` | Setting label shown in the interface. |
| `key` | `string` | Value key in the `Config` table. |
| `type` | `string` | Setting type. |
| `value` | type-specific | Initial value. |
| `min` | `number` | Optional lower limit for `number`. |
| `max` | `number` | Optional upper limit for `number`. |
| `options` | `string[]` | Options for `enum` and `maskenum`. |

Field names use lowercase spelling exactly as shown.

## Setting types

### bool

```json
{
  "label": "Show panel",
  "key": "ShowPanel",
  "type": "bool",
  "value": true
}
```

Lua receives a `boolean`.

### number

```json
{
  "label": "Panel scale",
  "key": "PanelScale",
  "type": "number",
  "value": 1,
  "min": 0.5,
  "max": 2
}
```

Lua receives a `number`. The value is clamped to `min…max` when loaded. A value of `999` with `max = 20` became `20`, and `-999` with `min = 0` became `0`.

### color

```json
{
  "label": "Panel color",
  "key": "PanelColor",
  "type": "color",
  "value": [0.1, 0.7, 1, 0.8]
}
```

Lua receives a [`Color`](../color/). The JSON array contains `r`, `g`, `b`, and `a`. Each component is clamped to `0…1` when loaded.

### enum

```json
{
  "label": "Panel side",
  "key": "PanelSide",
  "type": "enum",
  "value": 1,
  "options": ["Left", "Center", "Right"]
}
```

Both `value` and Lua use a zero-based option index:

| Option | Value |
|---|---:|
| `Left` | `0` |
| `Center` | `1` |
| `Right` | `2` |

:::caution[Do not put an option string in value]
`"value": "Center"` was rejected by the validator. Use `"value": 1` for the second option.
:::

### maskenum

```json
{
  "label": "Visible sections",
  "key": "VisibleSections",
  "type": "maskenum",
  "value": ["Health", "Ammo"],
  "options": ["Health", "Armor", "Ammo"]
}
```

Lua receives a numeric bit mask. Selecting the first and third options produces `5` (`1 + 4`).

| Option | Bit |
|---|---:|
| first | `1` |
| second | `2` |
| third | `4` |

## Changing Config from Lua

`Config` is a regular Lua table. Code can temporarily replace a value, even outside `min/max`:

```lua
Config.PanelScale = 999
```

The file constraints are not applied to this assignment. However, changing any setting through the UI repopulates the entire client-side table with the current saved configuration.

Use `Config` as the source of user settings, not as persistent internal storage. Use [`Storage`](../storage/) for module data.

## Reflex server

Declared settings are available in `server.lua` when the script loads. Its update lifecycle differs from the client:

- a UI setting change immediately repopulates the client `Config` table;
- it did not update the already-running table in `server.lua`;
- after a `server.lua` hot reload, the server received the saved values.

Do not assume the server sees a setting change immediately. Reload the server script or explicitly send the value through `Network`.

## Common mistakes

- using a JSON object instead of an array at the root;
- using an option string instead of a numeric `enum` index;
- expecting a string table from `maskenum` instead of a number;
- using `Config` for persistent internal module data.
