---
title: Color
description: RGBA colors in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The type is available in regular modules and in Reflex module `server.lua` files.
:::

`Color` stores the red, green, blue, and alpha components of a color. It is used by [UI](../ui/), [ImGui](../imgui/), [WorldVisuals](../world-visuals/), and other APIs that accept a color.

## Purpose and processing

`Color` is a data value, not a draw command. Construction and changes to `r/g/b/a` are handled by the Lua wrapper and display nothing by themselves. A color affects the game only after it is passed to a consumer such as a UI style, `ImGui`, or `LineRenderer:SetColor()`.

Changing a local `Color` after a call does not automatically update an object that was already configured. Pass the new value to the consumer again.

## Quick example

```lua
local cyan = Color.new(0.2, 0.8, 1)
local translucentRed = Color.new(1, 0, 0, 0.5)

print(cyan.a) -- 1
```

When only RGB is provided, the constructor automatically sets `a = 1`.

## Creating a color

```lua
Color.new(r: number, g: number, b: number): Color
Color.new(r: number, g: number, b: number, a: number): Color
```

| Parameter | Type | Description |
|---|---|---|
| `r` | `number` | Red component. |
| `g` | `number` | Green component. |
| `b` | `number` | Blue component. |
| `a` | `number` | Alpha component. Defaults to `1` when omitted. |

## Components

| Property | Type | Access | Description |
|---|---|---|---|
| `r` | `number` | `get/set` | Red component. |
| `g` | `number` | `get/set` | Green component. |
| `b` | `number` | `get/set` | Blue component. |
| `a` | `number` | `get/set` | Alpha component. |

Components can be changed after construction:

```lua
local color = Color.new(1, 1, 1)
color.g = 0.5
color.a = 0.75
```

:::caution[Values are not clamped automatically]
`Color` preserves numbers outside `0..1`. For example, `Color.new(-0.5, 1.5, 2, 3)` is created without an error and without clamping its components. Clamp values yourself when the receiving API expects a conventional color range.
:::

## Common mistakes

### Using values from 0 to 255

The usual representation uses values from `0` to `1`. For the RGB color `128, 200, 255`, divide each component by `255`:

```lua
local color = Color.new(128 / 255, 200 / 255, 1)
```

### Unexpected opacity

The three-component constructor sets `a = 1`. Pass the fourth argument when you need a different alpha value.
