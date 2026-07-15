---
title: Settings, input, and data
description: Choose between Config, InputActions, and Storage and combine them in one module.
---

The three mechanisms serve different purposes:

| Mechanism | Use it for |
|---|---|
| [`Config`](../../api/config/) | Settings exposed in the module UI. |
| [`InputActions`](../../api/input-action/) | Buttons and other control actions. |
| [`Storage`](../../api/storage/) | Internal local data across module activations. |

## Config: the user chooses a value

`config.json` contains a JSON array:

```json
[
  {
    "label": "Show status",
    "key": "ShowStatus",
    "type": "bool",
    "value": true
  },
  {
    "label": "Text size",
    "key": "TextSize",
    "type": "number",
    "value": 18,
    "min": 12,
    "max": 32
  }
]
```

```lua
if Config.ShowStatus then
    ImGui:DrawText(
        "Active",
        Rect.new(20, 20, 180, 40),
        Config.TextSize,
        Color.new(1, 1, 1),
        TextAnchor.MiddleLeft
    )
end
```

Do not use `Config` as storage. The game repopulates the table with saved settings after a UI change.

## InputActions: the user presses a control

`inputs.json`:

```json
{
  "Actions": [
    {
      "Name": "ToggleStatus",
      "Type": "Button",
      "Binding": {
        "Path": "<Keyboard>/f8"
      }
    }
  ]
}
```

`main.lua`:

```lua
local action = InputActions:FindAction("ToggleStatus")
local visible = true

if action ~= nil then
    action:OnPerformed(function()
        visible = not visible
    end)
end
```

Check for `nil`: a mismatched name or invalid action definition is not found.

## Storage: the module remembers state

```lua
if Storage.StatusVisible == nil then
    Storage.StatusVisible = true
end

local visible = Storage.StatusVisible

local function Toggle()
    visible = not visible
    Storage.StatusVisible = visible
end
```

`false` is valid, so initialize with `== nil` rather than `if not ...`.

:::caution
`Storage` is serialized when the module is disabled normally. Hot reload is not a save point by itself.
:::

## What to send to a Reflex server

`Config`, `InputActions`, and `Storage` are client concerns. The server receives its own `Config` when loaded but cannot see client input or `Storage`.

Send a small validated table through [`Network`](../../api/network/) when the server needs current client state.

See [Config](../../api/config/), [InputAction](../../api/input-action/), and [Storage](../../api/storage/) for complete formats.
