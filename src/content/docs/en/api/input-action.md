---
title: InputAction
description: Custom and built-in input actions in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. Action lookup, physical key presses, callbacks, and pressed state were confirmed in game.
:::

`InputActions` looks up input actions, while `InputAction` exposes their state and performed event. The API is client-only. In a Reflex `server.lua`, the global `InputActions` object is `nil`.

`inputs.json` registers a binding but does not draw a button or hint on the HUD. `OnPerformed()` only runs a callback; the module must implement every visible result—such as opening a panel, showing a message, or changing an indicator—through [UI](../ui/), [ImGui](../imgui/), or another API.

## Where input is processed

When the module loads, the client adds actions from `inputs.json` to the shared module input map. The game input system updates each `InputAction`; `IsPressed()` then reads its current state, while `OnPerformed()` invokes subscribers when the action is performed.

This is local user input. It does not become a server command automatically: a Reflex module must explicitly send the required state through [Network](../network/), and the server must validate it and decide what to do.

## Quick start

Declare a button in the module root's `inputs.json`:

```json
{
  "Actions": [
    {
      "Name": "TogglePanel",
      "Type": "Button",
      "Binding": {
        "Path": "<Keyboard>/f8"
      }
    }
  ]
}
```

Look up the same name from `main.lua`:

```lua
local TogglePanel = InputActions:FindAction("TogglePanel")
local PanelVisible = false

if TogglePanel ~= nil then
    TogglePanel:OnPerformed(function()
        PanelVisible = not PanelVisible
    end)
end
```

## inputs.json

Verified button format:

| Field | Type | Description |
|---|---|---|
| `Actions` | `array` | The module's action list. |
| `Name` | `string` | A unique name passed to `FindAction()`. |
| `Type` | `string` | Use `Button` for a regular button action. |
| `Binding.Path` | `string` | A Unity Input System control path, such as `<Keyboard>/f8`. |

The game rebuilds the module action map after `inputs.json` changes.

## InputActions

### FindAction

```lua
InputActions:FindAction(actionName: string): InputAction | nil
```

Returns a module action or a built-in game action. For example, `UI/Cancel` returns the game's `Cancel` action. A missing name returns `nil`.

Always check the result:

```lua
local action = InputActions:FindAction("TogglePanel")

if action == nil then
    print("TogglePanel action is missing")
    return
end
```

## InputAction

### IsPressed

```lua
action:IsPressed(): bool
```

Returns `true` while the bound control is pressed. Inside `OnPerformed()` for a physical key press it returned `true`, then returned `false` after the key was released.

```lua
Scheduler:OnFrame(function()
    if action:IsPressed() then
        -- Runs while the button is held
    end
end)
```

### OnPerformed

```lua
action:OnPerformed(callback: function)
```

Registers a callback that runs when the action is performed. The method returns `nil`.

```lua
action:OnPerformed(function()
    print("Action performed")
end)
```

### Enable and Disable

```lua
action:Enable()
action:Disable()
```

Both methods return `nil`.

:::caution[Disable does not block OnPerformed]
In the verified build, `Disable()` did not suppress a custom action. Later key presses still called the previously registered `OnPerformed()` callback, and `IsPressed()` returned `true` inside that callback. Immediately after the `Disable()` call itself, `IsPressed()` returned `false`.

Do not rely on `Disable()` to temporarily turn a handler off. The issue has been reported to the developer and will be fixed in a future build.
:::

Use your own guard for predictable behavior:

```lua
local InputEnabled = true

action:OnPerformed(function()
    if not InputEnabled then
        return
    end

    -- Handle the action
end)

-- Later
InputEnabled = false
```

## Common mistakes

### Name differs from inputs.json

`FindAction()` looks up the exact name. Do not treat `TogglePanel` and `togglePanel` as the same binding.

### Calling methods on nil

A missing action returns `nil`. Check the result before calling a method.

### Using input from server.lua

A Reflex server does not receive the client's keyboard input. Handle the action in `main.lua`, then send state through [Network](../network/) when the server needs it.
