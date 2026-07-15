---
title: CpuLimit
description: Lua module CPU budget in KILLSCRIPT.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The API is available in regular modules and in Reflex module `server.lua` files.
:::

`CpuLimit` reports the total and remaining CPU budget for the current Lua module. Every property is read-only.

## Quick example

```lua
if CpuLimit.RemainingCpuTime < 0.1 then
    return -- postpone optional work
end
```

## Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `CpuCycleLimit` | `integer` | `get` | Maximum CPU-cycle budget for the module's current execution. |
| `RemainingCpuCycles` | `integer` | `get` | Remaining CPU-cycle budget. |
| `RemainingCpuTime` | `number` | `get` | Remaining budget fraction, from `0` to `1`. |

```lua
local usedCycles = CpuLimit.CpuCycleLimit - CpuLimit.RemainingCpuCycles
local remainingPercent = CpuLimit.RemainingCpuTime * 100
```

## The budget decreases during execution

These values describe the current remainder, not a permanent device characteristic. In a test callback, a simple 100-iteration loop reduced `RemainingCpuCycles`.

Read the remainder immediately before an expensive optional operation:

```lua
if CpuLimit.RemainingCpuTime >= 0.2 then
    -- Additional calculations
end
```

## Client and Reflex server

The API works in both contexts, but their limits differ significantly. During testing, one client module received `880000000` cycles, while a Reflex `server.lua` received `1999000`.

:::caution[Do not rely on a specific number]
Values depend on the execution context and may change with another game version or configuration. Read the current properties instead of copying a number from the example.
:::

## Write access

`CpuCycleLimit`, `RemainingCpuCycles`, and `RemainingCpuTime` are getter-only. Assigning any of them raises a Lua access error.
