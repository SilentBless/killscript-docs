---
title: Scheduler
description: Per-frame, server-tick, and delayed callbacks in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. Method contexts, subscription cancellation, and delayed calls were confirmed in game.
:::

`Scheduler` runs a callback every frame, every server tick, or once after a delay.

The scheduler does not draw or change anything by itself; the code inside the callback determines every visible or gameplay effect. Use `OnFrame()` for client rendering and smooth UI updates, `OnTick()` for server decisions, and `Schedule()` for a one-shot delay in the current context.

## Where callbacks are processed

- `OnFrame()` stores a subscription in the client module runtime and invokes it from the render loop. Its rate follows FPS, not server tickrate.
- `OnTick()` stores a subscription in the Reflex server runtime and invokes it once per module server tick.
- `Schedule()` places a one-shot callback in the current runtime's queue; after the delay, the queue invokes it in the same client/server context.
- `EventSubscription:Cancel()` removes a repeating callback from that queue. It does not undo changes that already ran.

## Contexts

| Method | Regular module / Reflex `main.lua` | Reflex `server.lua` |
|---|:---:|:---:|
| `OnFrame` | ✅ | ❌ |
| `OnTick` | ❌ | ✅ |
| `Schedule` | ✅ | ✅ |

These restrictions are strict: an unavailable method is absent from the Lua object. Calling `OnTick` on the client or `OnFrame` on the server stops execution with a Lua access error.

## OnFrame

```lua
Scheduler:OnFrame(callback: function): EventSubscription
```

Calls the callback once per rendered frame. This method is only available in client-side Lua.

```lua
local subscription
local frames = 0

subscription = Scheduler:OnFrame(function()
    frames = frames + 1

    if frames >= 60 then
        subscription:Cancel()
    end
end)
```

The `OnFrame` frequency follows the frame rate. Do not use a frame count as a timer in seconds. Compare [`Time.Seconds`](../time/#current-time) or use `Schedule()`.

## OnTick

```lua
Scheduler:OnTick(callback: function): EventSubscription
```

Calls the callback every simulation tick. This method is only available in a Reflex module's `server.lua`.

```lua
local subscription
local ticks = 0

subscription = Scheduler:OnTick(function()
    ticks = ticks + 1

    if ticks >= 30 then
        subscription:Cancel()
    end
end)
```

In testing, 30 consecutive callbacks corresponded to 30 ticks and `0.5` seconds of simulation.

## EventSubscription

`OnFrame()` and `OnTick()` return a subscription object.

### Cancel

```lua
subscription:Cancel()
```

Cancels the subscription. Its callback is no longer called after cancellation.

Store the returned object when a callback will ever need to stop:

```lua
local subscription = Scheduler:OnFrame(Update)

-- Later
subscription:Cancel()
```

## Schedule

```lua
Scheduler:Schedule(duration: number, callback: function)
```

Schedules one callback call after the specified number of seconds. It is available in both Lua contexts.

```lua
Scheduler:Schedule(1, function()
    print("One second has passed")
end)
```

The method returns `nil`, and the callback is called only once. It does not create an `EventSubscription`.

### Delay precision

`Schedule()` runs the callback on the next applicable update, so the actual delay can be slightly longer than requested.

For `Schedule(0.1, callback)`, testing produced:

| Context | Actual delay |
|---|---:|
| Client | approximately `0.1064` seconds |
| Reflex server | approximately `0.1167` seconds, or 7 ticks |

Use the method for gameplay and interface logic, but do not expect high-frequency timer precision.

### Nil callback

```lua
Scheduler:Schedule(0, nil)
```

This call is accepted without an error and does nothing.

## Common mistakes

### Calling OnTick from main.lua

`OnTick` is not a client-side method. Move the logic into a Reflex module's `server.lua`, or use `OnFrame`.

### Calling OnFrame from server.lua

The server does not render frames. Use `OnTick`.

### Losing the subscription reference

Without a stored `EventSubscription`, code cannot call `Cancel()`. Assign the result of `OnFrame()` or `OnTick()` to a variable.

### Expecting a subscription from Schedule

`Schedule()` returns `nil`. For a cancellable delay, check time from an `OnFrame` or `OnTick` callback, and cancel that subscription after it runs.
