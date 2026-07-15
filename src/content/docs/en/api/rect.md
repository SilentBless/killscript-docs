---
title: Rect
description: Rectangular positions and sizes in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The type is available in regular modules and in Reflex module `server.lua` files.
:::

`Rect` describes a rectangle using position `(x, y)` and size `(width, height)`. It is commonly used to place `ImGui` elements and other two-dimensional regions.

## Quick example

```lua
local area = Rect.new(20, 30, 200, 40)

print(area.center) -- (120.00, 50.00)
```

## Creating a rectangle

```lua
Rect.new(x: number, y: number, width: number, height: number): Rect
```

| Parameter | Type | Description |
|---|---|---|
| `x` | `number` | Position on the X axis. |
| `y` | `number` | Position on the Y axis. |
| `width` | `number` | Width. |
| `height` | `number` | Height. |

## Properties

Every `Rect` property is readable and writable.

| Property | Type | Access | Description |
|---|---|---|---|
| `x` | `number` | `get/set` | X position. |
| `y` | `number` | `get/set` | Y position. |
| `width` | `number` | `get/set` | Width. |
| `height` | `number` | `get/set` | Height. |
| `xMin` | `number` | `get/set` | Minimum X coordinate. |
| `yMin` | `number` | `get/set` | Minimum Y coordinate. |
| `xMax` | `number` | `get/set` | Maximum X coordinate. |
| `yMax` | `number` | `get/set` | Maximum Y coordinate. |
| `center` | [`Vector2`](../vector2/) | `get/set` | Rectangle center. |

For `Rect.new(10, 20, 30, 40)`, the values are:

| Property | Value |
|---|---|
| `x`, `y` | `10`, `20` |
| `width`, `height` | `30`, `40` |
| `xMin`, `yMin` | `10`, `20` |
| `xMax`, `yMax` | `40`, `60` |
| `center` | `(25, 40)` |

## Modifying a rectangle

You can change the position and size, the boundaries, or the center:

```lua
local area = Rect.new(20, 20, 320, 180)

area.width = 400
area.center = Vector2.new(500, 300)
```

These related properties describe the same rectangle. After changing a boundary, center, position, or size, read any other values again before using them in later calculations.

## Using Rect with ImGui

```lua
local area = Rect.new(20, 20, 320, 180)

Scheduler:OnFrame(function()
    ImGui:DrawTexture(texture, area)
end)
```

The API receiving a `Rect` defines its coordinate system. The type itself only stores a rectangular region. See [ImGui](../imgui/) for practical drawing methods.
