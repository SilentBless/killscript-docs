---
title: WorldVisuals
description: Lines and projected areas in the three-dimensional game world.
---

:::note[Verified in game]
Creation, mutation, rendering, and removal were visually confirmed for both object types.
:::

<span class="api-context api-context--client">Client only</span> `WorldVisuals` is unavailable in a Reflex module's `server.lua`.

## How objects are processed

`CreateLineRenderer()` and `CreateSurfaceOverlay()` create real local render objects in the client scene and return control wrappers. Setters update parameters on the existing renderer; they do not need to be repeated every frame when a value is unchanged.

The server does not know about these objects, and physics or gameplay does not account for them. `RemoveObject()` removes only the visual object and does not affect an entity or surface near which it was drawn.

## Where the result appears

- `LineRenderer` draws a line directly in the 3D world through the specified world-space positions. It is not a HUD element.
- `SurfaceOverlay` projects a colored area onto world geometry inside the specified volume. It does not create a flat screen overlay.
- Objects remain in the world until the module calls `WorldVisuals:RemoveObject()` or is unloaded.
- The API renders objects directly and does not depend on a built-in HUD module. It also does not attach them to a camera or entity automatically—update the position yourself for a moving marker.

## Quick example

```lua
local line = WorldVisuals:CreateLineRenderer()

if line ~= nil then
    line:SetPositions({
        Vector3.new(0, 1, 0),
        Vector3.new(2, 1, 2),
        Vector3.new(4, 1, 0),
    })
    line:SetColor(Color.new(1, 0.1, 0.8, 1))
    line:SetWidth(0.08)

    Scheduler:Schedule(5, function()
        WorldVisuals:RemoveObject(line)
    end)
end
```

## WorldVisuals

Global API for creating visual objects in the world.

### CreateLineRenderer

```lua
WorldVisuals:CreateLineRenderer(): LineRenderer
```

Creates and returns a line object. It can return nil when the module reaches its object limit.

### CreateSurfaceOverlay

```lua
WorldVisuals:CreateSurfaceOverlay(): SurfaceOverlay
```

Creates an area projected onto world surfaces. It can return nil when the object limit is reached.

### RemoveObject

```lua
WorldVisuals:RemoveObject(object)
```

Removes a previously created line or area. The call returns `nil`.

## LineRenderer

A polyline made of world-space points.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `PositionCount` | int | `get/set` | Number of line points. The maximum is 2048. |

### Geometry

#### SetPositionCount

```lua
LineRenderer:SetPositionCount(count: int)
```

Sets the number of line points.

#### SetPosition

```lua
LineRenderer:SetPosition(index: int, position: Vector3)
```

Changes one point. Unlike API arrays, this index starts at `0`.

#### SetPositions

```lua
LineRenderer:SetPositions(points: LuaTable)
```

Replaces all points with values from a sequential Lua table. Up to 2048 points are supported.

### Appearance

All setter methods below return `nil`.

| Method | Arguments | Description |
|---|---|---|
| `SetColor` | `color: Color` | Sets the line color. |
| `SetWidth` | `width: number` | Sets a constant width. |
| `SetDistanceWidth` | `nearWidth, farWidth, nearDistance, farDistance: number` | Changes width linearly between near and far distances. |
| `SetOccludedVisibility` | `brightness, transparency: number` | Controls portions occluded by geometry. Values are clamped to `0..1`. |
| `SetPatternEnabled` | `enabled: bool` | Enables or disables the texture pattern. |
| `SetPatternRepeat` | `repeatCount: number` | Sets pattern repetitions along the line. |
| `SetPatternTexture` | `texture: Texture` | Sets the pattern [Texture](../texture/). |
| `SetProgress` | `progress: number` | Sets the completed line portion for materials with `_Progress`. |

## SurfaceOverlay

An area projected onto visible world surfaces.

Every method returns `nil`.

| Method | Arguments | Description |
|---|---|---|
| `SetPosition` | `position: Vector3` | Sets the area center in world space. |
| `SetSize` | `size: Vector3` | Sets the projected volume size. |
| `SetColor` | `color: Color` | Sets color and transparency. |
| `SetFillBase` | `fillBase: number` | Sets the base fill density. |
| `SetOcclusionEnabled` | `enabled: bool` | Enables geometry occlusion masking. |
| `SetVisible` | `visible: bool` | Shows or hides the area. |

Related types: [Vector3](../vector3/), [Color](../color/), and [Texture](../texture/).
