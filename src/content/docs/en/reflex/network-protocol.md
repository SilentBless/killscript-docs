---
title: Network protocol
description: Message structure, state synchronization, and input validation for Reflex modules.
---

[`Network`](../../api/network/) sends tables between `main.lua` and `server.lua`. Define a small protocol instead of accumulating unrelated fields.

## Always include kind

```lua
Network:SendTable({
    kind = "settings",
    enabled = true,
    threshold = 30
})
```

The receiver dispatches by message type first:

```lua
Network:OnTableReceived(function(data)
    if data.kind == "settings" then
        -- Apply settings
    elseif data.kind == "request_state" then
        -- Send state
    end
end)
```

## Separate commands from state

A useful naming scheme:

- `set_settings`: client supplies settings;
- `request_state`: client requests a snapshot;
- `state`: server sends authoritative state;
- `event`: server reports something that happened.

`SendTable()` returns `nil`, not a response. A response is a separate incoming message.

## Supported data

Send strings, numbers, booleans, nested tables, and sequential tables. Break structures into numbers:

```lua
local function PackVector3(value)
    return {
        x = value.x,
        y = value.y,
        z = value.z
    }
end
```

[`Vector3`](../../api/vector3/), [`Agent`](../../api/agent/), [`Texture`](../../api/texture/), functions, and `nil` fields are not preserved.

## Validate server input

The sandbox does not expose `type`, so use safe conversions and explicit comparisons:

```lua
local function ApplySettings(data)
    local threshold = tonumber(data.threshold)

    if threshold ~= nil then
        threshold = math.max(1, math.min(100, threshold))
        State.threshold = threshold
    end

    State.enabled = data.enabled == true
end
```

Never use a client number as an index, distance, or duration without bounds.

## Do not send every frame

Send when state changes:

```lua
local LastHealth = nil

local function SendHealthIfChanged(health)
    if health == LastHealth then
        return
    end

    LastHealth = health
    Network:SendTable({
        kind = "health_state",
        health = health
    })
end
```

## Initial synchronization

Both sides should recover regardless of startup order:

1. the server starts with safe defaults;
2. the client registers its receiver;
3. the client sends settings;
4. the client requests state;
5. the server responds with a full snapshot.

See the [complete Reflex module](../complete-module/) for the full pattern.
