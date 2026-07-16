---
title: Animations
description: "ScheduleAnimation and Tweener: smoothly update UI, then stop or complete animations."
---

:::note[Current build]
This page describes the API behavior in the current game version.
:::

<span class="api-context api-context--client">Client only</span> Animations operate on elements created through [UI](../ui/).

An animation is visible only when `onUpdate` changes properties on an element that already belongs to a displayed UI tree. `ScheduleAnimation()` does not choose what to animate or show a detached element. After `Stop()`, the element remains at its last applied state; `Complete()` advances it to the final progress value.

## ScheduleAnimation

Both forms start the same animation:

```lua
element:ScheduleAnimation(params: table): Tweener
UI:ScheduleAnimation(element: VisualElement, params: table): Tweener
```

`onUpdate` receives progress from `0` to `1`. The API does not modify styles automatically; use that progress to interpolate the properties you need.

```lua
local tween = panel:ScheduleAnimation({
    duration = 0.25,
    curve = 1,
    replaceExisting = true,

    onUpdate = function(t)
        panel.style.opacity = t
        panel.style.translate = Vector3.new(0, (1 - t) * 20, 0)
    end,

    onComplete = function()
        print("Animation complete")
    end,
})
```

## Parameters

| Key | Type | Description |
|---|---|---|
| `duration` | `number` | Duration in seconds |
| `curve` | `number` | Numeric curve type; defaults to `1` |
| `replaceExisting` | `boolean` | Stop the element's previous replaceable animation |
| `onUpdate` | `function(t)` | Called on updates with current progress |
| `onComplete` | `function()` | Called after full completion |

The method returns `nil` when `params` is missing, the element is unavailable, or the animation limit has been reached.

:::tip[Predictable transitions]
Set `replaceExisting = true` for animations that control the same state. A new transition will stop the old one without jumping to its final value.
:::

:::caution[Limit]
A module can have at most 128 scheduled UI animations at the same time.
:::

## Tweener

The object returned by `ScheduleAnimation()`.

### IsComplete

```lua
tween:IsComplete(): boolean
```

Returns `true` once the animation has fully completed.

### Stop

```lua
tween:Stop(complete: boolean = false)
```

- `Stop(false)` immediately stops without advancing to the end;
- `Stop(true)` applies final progress and completes the animation.

```lua
if tween ~= nil and not tween:IsComplete() then
    tween:Stop(false)
end
```

## Showing and hiding

```lua
local function Show(element)
    element.style.display = DisplayStyle.Flex

    return element:ScheduleAnimation({
        duration = 0.2,
        replaceExisting = true,
        onUpdate = function(t)
            element.style.opacity = t
        end,
    })
end

local function Hide(element)
    return element:ScheduleAnimation({
        duration = 0.2,
        replaceExisting = true,
        onUpdate = function(t)
            element.style.opacity = 1 - t
        end,
        onComplete = function()
            element.style.display = DisplayStyle.None
        end,
    })
end
```

## Interpolating multiple values

```lua
local startX = -280
local endX = 24

panel:ScheduleAnimation({
    duration = 0.35,
    replaceExisting = true,
    onUpdate = function(t)
        local x = startX + (endX - startX) * t
        panel.style.left = x
        panel.style.opacity = t
    end,
})
```

A single `onUpdate` can change any number of properties. This keeps movement, scale, and opacity transitions synchronized.

## Related pages

- [UI and UXML](../ui/)
- [UI elements](../ui-elements/)
- [UI styles](../ui-style/)
