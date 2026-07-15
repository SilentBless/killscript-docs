---
title: MapInfo
description: Current map dimensions and zones in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha on Castle. The API is available in regular modules and in Reflex module `server.lua` files.
:::

`MapInfo` provides parameters of the current map and finds the gameplay zones at a world position.

## Quick example

```lua
local zones = MapInfo:GetZones(Cameras.Main.Position)

for index = 1, zones.Length do
    print(zones[index])
end
```

`Cameras.Main` is client-only. In `server.lua`, pass a position obtained from a server-side API.

## Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `BasementBottomY` | `number` | `get` | Lower Y boundary of the basement level. |
| `BasementTopY` | `number` | `get` | Upper Y boundary of the basement level. |
| `MapCameraHeight` | `number` | `get` | Minimap camera height. |
| `MapCenter` | [`Vector3`](../vector3/) | `get` | Map center in world space. |
| `MapName` | `string` | `get` | Current map name. |
| `MapSize` | `number` | `get` | Map size used by its representation. |

All properties are getter-only.

Testing on `Castle` produced:

| Property | Value |
|---|---|
| `BasementBottomY` | `-5` |
| `BasementTopY` | `0` |
| `MapCameraHeight` | `200` |
| `MapCenter` | `(15, 0, 20)` |
| `MapName` | `Castle` |
| `MapSize` | `130` |

These values describe only the tested map and are not global constants.

## GetZones

```lua
MapInfo:GetZones(position: Vector3): Array<string>
```

Returns an [`Array<string>`](../array/) containing the names of every zone that includes the given world position.

A position can belong to multiple zones at once:

```lua
local zones = MapInfo:GetZones(Cameras.Main.Position)
-- Example: BuyZoneCT, CSspawn
```

When a position is not inside any zone, the method returns an empty array with `Length == 0`, not `nil`.

```lua
local zones = MapInfo:GetZones(Vector3.zero)

if zones.Length == 0 then
    print("No zone at this position")
end
```

## Contexts

`MapInfo` and `GetZones()` work on both the client and the Reflex server. Results for the same map and position matched in both contexts.
