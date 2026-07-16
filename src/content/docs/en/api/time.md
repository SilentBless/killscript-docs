---
title: Time
description: Simulation time and ticks in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The API is available in regular modules and in Reflex module `server.lua` files.
:::

`Time` provides the current simulation time, the current tick, and conversions between seconds and ticks.

## Purpose and processing

`Time.Seconds` and `Time.Tick` read the current simulation clock of the context running the module. They do not start a timer or invoke a callback. Use [Scheduler](../scheduler/) to run code later.

`SecondsToTick()` and `TickToSeconds()` are arithmetic conversions based on network tick duration. They do not wait for the given time or change match progression.

## Key points

- `Seconds` and `Tick` are read-only;
- in the current version, one tick lasts approximately `1/60` of a second;
- `SecondsToTick()` is sensitive to floating-point precision;
- converting ticks to seconds and back does not guarantee the original value;
- the API is available in both client-side and server-side Lua.

## Current time

| Property | Type | Access | Description |
|---|---|---|---|
| `Seconds` | `number` | `get` | Current simulation time in seconds. |
| `Tick` | `integer` | `get` | Current simulation tick. |

```lua
local currentSeconds = Time.Seconds
local currentTick = Time.Tick
```

Assigning either property raises a Lua access error:

```lua
Time.Seconds = 0 -- Lua access error
Time.Tick = 0    -- Lua access error
```

During a measured `0.5` seconds, `Tick` advanced by `30`, confirming that both properties follow the same simulation timeline.

## SecondsToTick

```lua
Time:SecondsToTick(seconds: number): integer
```

Converts a duration in seconds to a number of ticks.

```lua
local ticks = Time:SecondsToTick(0.1) -- 6
```

The method accepts zero and negative values.

| Seconds | Result |
|---:|---:|
| `0` | `0` |
| `0.1` | `6` |
| `0.25` | `14` |
| `0.5` | `29` |
| `1` | `59` |
| `2` | `119` |
| `-1` | `-59` |

:::caution[A whole second may lose one tick]
In the current version, `SecondsToTick(1)` returns `59`, while `SecondsToTick(0.5)` returns `29`. This is caused by numeric precision at a tick boundary. Do not add `1` unconditionally: `SecondsToTick(0.1)` already returns the correct value of `6`.

The issue has been reported to the developer and will be fixed in a future build. Until then, use the round-up helper below when a duration must not be shortened.
:::

### Ensuring a minimum duration

For a positive duration that must not finish one tick early, round the ratio up:

```lua
local function SecondsToTicksAtLeast(seconds)
    local tickDuration = Time:TickToSeconds(1)
    return math.ceil(seconds / tickDuration)
end

local halfSecond = SecondsToTicksAtLeast(0.5) -- 30
local oneSecond = SecondsToTicksAtLeast(1)    -- 60
```

This approach was verified with durations of `0.1`, `0.25`, `0.5`, `1`, `1.5`, and `2` seconds.

## TickToSeconds

```lua
Time:TickToSeconds(ticks: integer): number
```

Converts a number of ticks to seconds.

| Ticks | Result |
|---:|---:|
| `0` | `0` |
| `1` | `0.016666667535901` |
| `6` | `0.1000000089407` |
| `30` | `0.5` |
| `60` | `1.0` |
| `600` | `10.000000953674` |

Small fractional tails are normal floating-point representation errors.

## Round trips

Do not assume that converting twice restores the source value:

```lua
local seconds = Time:TickToSeconds(60) -- 1.0
local ticks = Time:SecondsToTick(seconds) -- 59, not 60
```

For tested values of `1`, `6`, `30`, `60`, and `600` ticks, the values `30` and `60` lost one tick after a round trip, while the others were restored exactly. Keep values in ticks when the rest of the logic also operates in ticks.

## Tick-based timer

In a Reflex module's `server.lua`, store a target tick and compare it inside [`Scheduler:OnTick()`](../scheduler/#ontick):

```lua
local durationTicks = math.ceil(0.5 / Time:TickToSeconds(1))
local finishTick = Time.Tick + durationTicks
local subscription

subscription = Scheduler:OnTick(function()
    if Time.Tick >= finishTick then
        -- At least 0.5 seconds of simulation have passed
        subscription:Cancel()
    end
end)
```

When a callback only needs to run once after a delay, [`Scheduler:Schedule()`](../scheduler/#schedule) is usually simpler.
