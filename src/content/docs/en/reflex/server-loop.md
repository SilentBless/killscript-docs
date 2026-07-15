---
title: Server loop
description: Scheduler.OnTick, intervals, CPU budget, and safe game-object access.
---

Repeated `server.lua` logic runs through `Scheduler:OnTick()`, once per simulation tick.

## Minimal loop

```lua
local function Tick()
    local agent = Agents:GetLocalAgent()

    if agent == nil or agent.Health == nil then
        return
    end

    -- Server logic
end

Scheduler:OnTick(Tick)
```

Retrieve live objects again. An agent or item cached across rounds may become unavailable.

## Work less often than every tick

Keep a target tick for infrequent checks:

```lua
local TickDuration = Time:TickToSeconds(1)
local IntervalTicks = math.ceil(0.25 / TickDuration)
local NextUpdateTick = 0

local function Tick()
    if Time.Tick < NextUpdateTick then
        return
    end

    NextUpdateTick = Time.Tick + IntervalTicks

    -- At most four times per second
end

Scheduler:OnTick(Tick)
```

`math.ceil(seconds / tickDuration)` avoids shortening a positive interval by one tick due to conversion precision.

## CPU budget

Reflex server execution has a limited budget. Inspect the remainder through `CpuLimit`:

```lua
if CpuLimit.RemainingCpuTime < 0.2 then
    return
end
```

This is an emergency guard, not a substitute for optimization. Reduce expensive scan frequency, return early, avoid identical messages, and do not traverse the same array repeatedly.

## Subscription control

`OnTick()` returns an `EventSubscription`:

```lua
local subscription

subscription = Scheduler:OnTick(function()
    if DefusalGame.IsGameEnded then
        subscription:Cancel()
        return
    end
end)
```

Keep the reference when the loop must stop before reload.

## Context errors stop execution

`server.lua` has no `OnFrame`, [UI](../../api/ui/), [cameras](../../api/camera/), or [client input](../../api/input-action/). Missing-member access can terminate current Lua logic. Do not probe unavailable APIs inside the main loop.

Reference: [Scheduler](../../api/scheduler/), [Time](../../api/time/), [CpuLimit](../../api/cpu-limit/), and [Agent](../../api/agent/).
