---
title: Network
description: Exchange Lua tables between the client and server of a Reflex module.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. Bidirectional transport and the supported value types were confirmed in game.
:::

`Network` connects the `main.lua` and `server.lua` sides of the same [Reflex module](../../reflex/architecture/). One side sends a Lua table with `SendTable()` and the other receives it through `OnTableReceived()`.

Transport is not shown to the player automatically. The server normally makes a decision and sends compact state to the client; the client then updates [UI](../ui/), [ImGui](../imgui/), audio, or a notification. `SendTable()` also does not wait for a response or confirm delivery through its return value.

## How a message is processed

`SendTable()` serializes supported values from the table and transports the packet to the other half of the same Reflex module. On receipt, that runtime constructs a new Lua table and invokes the callback registered through `OnTableReceived()`.

The sender does not call a server function directly and does not receive its result. If the protocol needs a response, the receiving side must send a separate message with its own `kind` and request identifier.

## Quick example

The client requests the current round state:

```lua title="scripts/main.lua"
Network:OnTableReceived(function(data)
    if data.kind == "round_state" then
        print("Round: " .. tostring(data.roundId))
    end
end)

Network:SendTable({
    kind = "get_round_state"
})
```

The server responds:

```lua title="scripts/server.lua"
Network:OnTableReceived(function(data)
    if data.kind == "get_round_state" then
        Network:SendTable({
            kind = "round_state",
            roundId = DefusalGame.RoundId
        })
    end
end)
```

:::tip[Include a message type]
A field such as `kind` lets one callback handle multiple message types without confusing requests and responses.
:::

## Supported values

The transport preserves:

- `string`;
- `number`;
- `boolean`, including `false`;
- nested tables;
- array-like tables such as `{ "first", "second" }`.

`nil`, functions, and API objects such as [`Vector3`](../vector3/) are not transported. A field containing one of these values is absent on the receiving side.

```lua
Network:SendTable({
    position = Vector3.zero, -- omitted
    callback = function() end, -- omitted
    visible = false, -- transported
    options = {
        color = "blue",
        size = 2
    }
})
```

Split a vector into numbers before sending it:

```lua
local position = Vector3.new(10, 20, 30)

Network:SendTable({
    position = {
        x = position.x,
        y = position.y,
        z = position.z
    }
})
```

## OnTableReceived

```lua
Network:OnTableReceived(callback)
```

Registers a callback for tables sent by the other side of the module.

| Argument | Type | Description |
|---|---|---|
| `callback` | `function(data)` | Function receiving the reconstructed Lua table. |

The method returns `nil`.

## SendTable

```lua
Network:SendTable(data)
```

Sends a table to the other side of the Reflex module.

| Argument | Type | Description |
|---|---|---|
| `data` | `table` | Message data. |

The method returns `nil`. Sending a table is not a request by itself. If a response is required, define message fields and handle the response through `OnTableReceived()`.

:::caution[Known issue in the current build]
In regular network mode, only the first `SendTable()` call in a tick reaches the receiver, and a payload larger than `16384` UTF-8 bytes is silently dropped. Host mode behaves differently, so a successful local test does not guarantee the same behavior for a remote client. Combine updates into one table per tick and keep the message below the limit.

The issue has been reported to the developer and will be fixed in a future build.
:::

## Common mistakes

- sending a [Vector3](../vector3/), [Agent](../agent/), [Texture](../texture/), or function directly;
- expecting a return value from `SendTable()`;
- omitting a field that identifies the message type;
- trusting client-provided data in server game logic without validation.
