---
title: NetworkInfo
description: Ping, RTT, traffic, and packet loss in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The API is only available in client-side Lua.
:::

`NetworkInfo` provides current network connection statistics. In a Reflex module's `server.lua`, the global `NetworkInfo` object is `nil`.

## Quick example

```lua
print("Ping: " .. NetworkInfo.Ping .. " ms")
print("Packet loss: " .. NetworkInfo.InPacketLossPercent .. "%")
```

## Properties

Every property is read-only.

| Property | Type | Access | Unit | Description |
|---|---|---|---|---|
| `InKBps` | `number` | `get` | KB/s | Incoming traffic rate. |
| `InPacketLossPercent` | `number` | `get` | `%` | Incoming packet loss. |
| `InterpolationDelayMs` | `number` | `get` | ms | Current interpolation delay. |
| `OutKBps` | `number` | `get` | KB/s | Outgoing traffic rate. |
| `OutPacketLossPercent` | `number` | `get` | `%` | Outgoing packet loss. |
| `Ping` | `integer` | `get` | ms | Average ping based on recent measurements. |
| `RttSeconds` | `number` | `get` | s | Current round-trip time. |
| `ServerTickTimeMs` | `number` | `get` | ms | Processing time of a server network tick. |
| `TickTimeMs` | `number` | `get` | ms | Processing time of a network tick. |

## Ping and RTT

`Ping` and `RttSeconds` are not the same sample expressed in different units. During testing:

- `Ping` was `44 ms`;
- `RttSeconds × 1000` was approximately `60.88 ms`.

Use `Ping` for the ready-made average and `RttSeconds` when you need the current RTT in seconds. Do not expect exact equality between them.

## Dynamic values

Metrics change while connected. Read them when updating an interface or collecting diagnostics:

```lua
Scheduler:OnFrame(function()
    local ping = NetworkInfo.Ping
    -- Update the interface
end)
```

Do not assign these properties: all nine setters raise a Lua access error.
