---
title: Performance
description: FPS and performance metrics in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The API is only available in client-side Lua.
:::

`Performance` provides averaged FPS, frame-time, and CPU/GPU utilization metrics. In a Reflex module's `server.lua`, the global `Performance` object is `nil`.

## Where values come from

The client performance collector aggregates frame duration and CPU/GPU occupancy, while the API exposes calculated values for the latest measurement window. This diagnoses the local client: reading these properties does not affect FPS or control graphics quality.

## Quick example

```lua
print("FPS: " .. Performance.AvgFps)
print("Max frame: " .. Performance.MaxFrameMs .. " ms")
```

## Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `AvgFps` | `number` | `get` | Average FPS over the last second. |
| `CpuUsagePercent` | `number` | `get` | Average CPU utilization by the game over the last second relative to frame time. |
| `GpuUsagePercent` | `number` | `get` | Average GPU utilization by the game over the last second relative to frame time. |
| `MaxFrameMs` | `number` | `get` | Maximum frame time over the last second, in milliseconds. |

:::caution[Every property is getter-only]
The previous documentation incorrectly marked all four properties as `get/set`. In game, assigning any of them raises a Lua access error.
:::

## Interpreting values

These metrics are dynamic and describe a recent interval, not the entire match. One test produced `AvgFps ≈ 144.83`, `CpuUsagePercent ≈ 99.96`, `GpuUsagePercent ≈ 87.81`, and `MaxFrameMs ≈ 20.76`.

Do not treat those numbers as expected values. They depend on the device, settings, and current workload.

## Low-FPS warning example

```lua
Scheduler:OnFrame(function()
    if Performance.AvgFps < 30 then
        -- Show a warning in the interface
    end
end)
```
