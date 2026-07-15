---
title: Choosing a UI API
description: When to use ImGui, UXML, or WorldVisuals in a KILLSCRIPT module.
---

KILLSCRIPT provides three main ways to present custom information. Each serves a different job.

| Tool | Best for | Model |
|---|---|---|
| [`ImGui`](../../api/imgui/) | Quick HUD, text, images, debugging | Redrawn every frame |
| [`UI` + UXML/USS](../../api/ui/) | Panels, menus, lists, buttons | Persistent element tree |
| [`WorldVisuals`](../../api/world-visuals/) | Lines and areas inside the world | Objects in world coordinates |

## Choose ImGui when

- you need a few lines or an image;
- content changes often;
- mouse interaction is unnecessary;
- you are prototyping quickly.

```lua
Scheduler:OnFrame(function()
    ImGui:DrawDebugText("Ping: " .. tostring(NetworkInfo.Ping))
end)
```

## Choose UXML when

- the interface contains containers, lists, or forms;
- you need buttons, text fields, or scrolling;
- styling belongs in USS;
- elements should persist between frames.

```lua
local root = UI:BuildFromUxmlAbsolute("Panel.uxml")
```

UXML is built once. Lua then changes existing element properties.

## Choose WorldVisuals when

- a line connects world positions;
- an area lies on a map surface;
- the visual belongs to an object position rather than the screen.

```lua
local line = WorldVisuals:CreateLineRenderer()
line:SetPositionCount(2)
line:SetPosition(0, Vector3.zero)
line:SetPosition(1, Vector3.up)
```

## Combine them when useful

One module can use UXML for settings, ImGui for a lightweight HUD, and WorldVisuals for map objects. Avoid presenting the same information in several layers and remove temporary objects explicitly.

Continue with [an ImGui HUD](../imgui-hud/), [your first UXML interface](../uxml-interface/), and the [WorldVisuals](../../api/world-visuals/) reference. Types used in the examples are documented under [Scheduler](../../api/scheduler/), [NetworkInfo](../../api/network-info/), and [Vector3](../../api/vector3/).
