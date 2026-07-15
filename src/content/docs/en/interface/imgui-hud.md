---
title: ImGui HUD
description: Build a practical client HUD with player state, color, and screen-size adaptation.
---

This example displays local-player health. ImGui needs no additional files; everything lives in `scripts/main.lua`.

```lua
local function GetHealthColor(health, maximum)
    local ratio = 0

    if maximum > 0 then
        ratio = health / maximum
    end

    return Color.new(1 - ratio, ratio, 0.2, 1)
end

local function DrawHud()
    local agent = Agents:GetLocalAgent()

    if agent == nil or agent.Health == nil then
        return
    end

    local health = agent.Health.CurrentHealth
    local maximum = agent.Health.MaxHealth
    local text = "HP " .. tostring(health) .. " / " .. tostring(maximum)

    ImGui:DrawText(
        text,
        Rect.new(24, Screen.Height - 86, 260, 46),
        22,
        GetHealthColor(health, maximum),
        TextAnchor.MiddleLeft
    )
end

Scheduler:OnFrame(DrawHud)
```

## Why drawing runs in OnFrame

ImGui does not create a persistent element. Each call contributes only to the current frame, so `DrawHud()` is registered through `Scheduler:OnFrame()`.

## Why the object is checked for nil

The local agent can be unavailable while loading, spectating, or transitioning between states. An early return prevents access to a missing object.

## Coordinates

`Rect.new(x, y, width, height)` uses screen pixels from the top-left corner. The example calculates Y from `Screen.Height`, keeping the block near the bottom.

Use `DrawTextUV()` for viewport-relative placement or `DrawTextPos()` for a single point.

## User settings

Expose size through `config.json`:

```json
[
  {
    "label": "HUD size",
    "key": "HudSize",
    "type": "number",
    "value": 22,
    "min": 12,
    "max": 36
  }
]
```

Then replace `22` in `DrawText()` with `Config.HudSize`.

Reference: [ImGui](../../api/imgui/), [Scheduler](../../api/scheduler/), [Agent](../../api/agent/), [Screen](../../api/screen/), [Rect](../../api/rect/), [Color](../../api/color/), and [Config](../../api/config/).
