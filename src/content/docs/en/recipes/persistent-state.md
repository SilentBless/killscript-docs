---
title: Persistent state
description: Remember local UI state through Storage without losing false values.
---

Goal: remember whether the HUD was hidden when the module was disabled normally.

```lua
if Storage.Layout == nil then
    Storage.Layout = {
        version = 1,
        visible = true
    }
end

local Visible = Storage.Layout.visible
local ToggleAction = InputActions:FindAction("TogglePanel")

if ToggleAction ~= nil then
    ToggleAction:OnPerformed(function()
        Visible = not Visible
        Storage.Layout.visible = Visible
    end)
end

Scheduler:OnFrame(function()
    if Visible then
        ImGui:DrawDebugText("Persistent panel")
    end
end)
```

`false` is not missing. Initialize the table only when `Storage.Layout == nil`.

## Structure version

Perform a small migration when the format changes:

```lua
if Storage.Layout == nil or Storage.Layout.version ~= 2 then
    local oldVisible = true

    if Storage.Layout ~= nil
        and Storage.Layout.visible ~= nil then
        oldVisible = Storage.Layout.visible
    end

    Storage.Layout = {
        version = 2,
        visible = oldVisible,
        compact = false
    }
end
```

## Limitations

- strings, numbers, booleans, and nested tables persist;
- split userdata such as `Vector3` into numbers;
- assigning `nil` removes a key after save;
- hot reload does not serialize current state;
- test by disabling and enabling the module normally.

Reference: [Storage](../../api/storage/), [InputAction](../../api/input-action/), and [Vector3](../../api/vector3/) for serializing structured values.
