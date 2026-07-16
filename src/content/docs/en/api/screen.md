---
title: Screen
description: Game screen dimensions in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The API is only available in client-side Lua.
:::

`Screen` provides the current width and height of the game image. In a Reflex module's `server.lua`, the global `Screen` object is `nil`.

## What the values describe

This is the client render area's size in pixels at read time. Properties update when resolution or window size changes and change nothing by themselves.

The values are useful for `ImGui` and screen-space calculations. UXML/UI may additionally apply HUD scale and its own layout, so the pixel center of `Screen` is not always the coordinate center inside a specific UI container.

## Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `Width` | `number` | `get` | Screen width in pixels. |
| `Height` | `number` | `get` | Screen height in pixels. |

Both properties are getter-only.

## Aspect ratio

```lua
local aspect = Screen.Width / Screen.Height
```

At `1920 × 1080`, the result is approximately `1.7778`.

## Screen center

```lua
local center = Vector2.new(Screen.Width / 2, Screen.Height / 2)
```

## Rect example

The following `320 × 180` rectangle is centered on screen:

```lua
local width = 320
local height = 180

local area = Rect.new(
    (Screen.Width - width) / 2,
    (Screen.Height - height) / 2,
    width,
    height
)
```

See [`Rect`](../rect/) for rectangular regions.
