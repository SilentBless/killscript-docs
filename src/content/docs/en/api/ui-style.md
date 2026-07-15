---
title: Styles
description: "ElementStyle: size, position, color, background, and visual transforms for UI elements."
---

:::note[Current build]
This page describes the API behavior in the current game version.
:::

<span class="api-context api-context--client">Client only</span> Access the style through `element.style`.

## Quick example

```lua
local panel = UI:CreateVisualElement()

panel.style.width = 320
panel.style.height = 120
panel.style.left = 24
panel.style.top = 160
panel.style.backgroundColor = Color.new(0.03, 0.05, 0.08, 0.92)
panel.style.borderRadius = 12
panel.style.opacity = 1
```

Changes apply immediately. For complex persistent layouts, keep most styling in USS and only update state from Lua.

## Dimensions

Numeric values use pixels unless the property name explicitly contains `Percent`.

| Property | Access | Purpose |
|---|---|---|
| `width` | get/set | Width in pixels |
| `height` | get/set | Height in pixels |
| `widthPercent` | get/set | Width in percent |
| `heightPercent` | get/set | Height in percent |
| `minWidth` | get/set | Minimum width |
| `minHeight` | get/set | Minimum height |
| `maxWidth` | get/set | Maximum width |
| `maxHeight` | get/set | Maximum height |

## Position and margins

| Property | Access | Purpose |
|---|---|---|
| `left` | get/set | Left offset |
| `right` | get/set | Right offset |
| `top` | get/set | Top offset |
| `bottom` | get/set | Bottom offset |
| `marginLeft` | get/set | Left margin |
| `marginRight` | get/set | Right margin |
| `marginTop` | get/set | Top margin |
| `marginBottom` | get/set | Bottom margin |

## Color and visibility

| Property | Access | Purpose |
|---|---|---|
| `color` | get/set | Text color |
| `backgroundColor` | get/set | Background color |
| `tintColor` | get/set | Image tint |
| `opacity` | get/set | Overall opacity |
| `display` | get/set | Whether the element participates in layout |
| `borderRadius` | set | Radius for all corners |
| `backgroundImage` | set | Background [Texture](../texture/) |

`borderRadius` and `backgroundImage` are write-only. Reading either property raises an access error.

### DisplayStyle

| Value | Number | Behavior |
|---|---:|---|
| `DisplayStyle.Flex` | `0` | The element is displayed and occupies layout space |
| `DisplayStyle.None` | `1` | The element is hidden and excluded from layout |

For temporary hiding without rebuilding layout, use `element.visible`.

## Background image

| Property | Access | Purpose |
|---|---|---|
| `backgroundPositionX` | get/set | Horizontal background anchor |
| `backgroundPositionY` | get/set | Vertical background anchor |
| `backgroundSize` | get/set | Background scaling mode |

### BackgroundPositionKeyword

| Value | Number |
|---|---:|
| `BackgroundPositionKeyword.Left` | `0` |
| `BackgroundPositionKeyword.Center` | `1` |
| `BackgroundPositionKeyword.Right` | `2` |
| `BackgroundPositionKeyword.Top` | `3` |
| `BackgroundPositionKeyword.Bottom` | `4` |

### BackgroundSizeType

| Value | Number | Behavior |
|---|---:|---|
| `BackgroundSizeType.Contain` | `0` | Fits the complete image inside the element |
| `BackgroundSizeType.Cover` | `1` | Fills the element and may crop the image |
| `BackgroundSizeType.Auto` | `2` | Uses automatic sizing |

```lua
panel.style.backgroundImage = Textures:GetTexture("Panel.png")
panel.style.backgroundPositionX = BackgroundPositionKeyword.Center
panel.style.backgroundPositionY = BackgroundPositionKeyword.Center
panel.style.backgroundSize = BackgroundSizeType.Cover
```

## Transforms

| Property | Type | Purpose |
|---|---|---|
| `translate` | `Vector3` | X/Y offset; Z is ignored |
| `scale` | `Vector3` | Per-axis scale |
| `rotateAngle` | `number` | Rotation in degrees |
| `rotate` | `number` | Equivalent rotation field in degrees |

```lua
panel.style.translate = Vector3.new(0, 12, 0)
panel.style.scale = Vector3.new(1.05, 1.05, 1)
panel.style.rotateAngle = 3
```

Prefer `rotateAngle` in new code because it makes the unit explicit.

## Animating styles

Style properties can be updated smoothly from an `onUpdate` callback:

```lua
panel:ScheduleAnimation({
    duration = 0.2,
    onUpdate = function(t)
        panel.style.opacity = t
        panel.style.translate = Vector3.new(0, (1 - t) * 16, 0)
    end,
})
```

See [UI animations](../ui-animation/) for the complete parameter reference.
