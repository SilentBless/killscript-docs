---
title: Toggle action
description: Create a custom input action and toggle a HUD block from OnPerformed.
---

Goal: pressing `F8` toggles an information block.

## inputs.json

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

The game rebuilds the module action map after the file is saved.

## main.lua

```lua
local PanelVisible = true
local ToggleAction = InputActions:FindAction("TogglePanel")

if ToggleAction == nil then
    print("TogglePanel action was not found")
else
    ToggleAction:OnPerformed(function()
        PanelVisible = not PanelVisible
    end)
end

Scheduler:OnFrame(function()
    if not PanelVisible then
        return
    end

    ImGui:DrawText(
        "Panel enabled",
        Rect.new(24, 140, 240, 40),
        18,
        Color.new(0.5, 1, 0.7, 1),
        TextAnchor.MiddleLeft
    )
end)
```

## Why use a separate flag

In the current build, `InputAction:Disable()` does not reliably suppress a previously registered `OnPerformed()`. Control behavior through `PanelVisible` or a separate `InputEnabled` flag.

## Hold behavior

Read `IsPressed()` every frame when an action should remain active while held:

```lua
Scheduler:OnFrame(function()
    if ToggleAction ~= nil and ToggleAction:IsPressed() then
        ImGui:DrawDebugText("F8 is held")
    end
end)
```

Reference: [InputAction](../../api/input-action/), [Scheduler](../../api/scheduler/), and [ImGui](../../api/imgui/).
