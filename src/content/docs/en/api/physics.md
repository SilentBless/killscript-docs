---
title: Physics
description: Client-side raycasts and the RaycastHit structure.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. Both `Raycast()` overloads, hits, misses, and result fields were confirmed in game.
:::

`Physics` performs ray queries against the scene. It is available only in client Lua; the global `Physics` value is `nil` in a Reflex `server.lua`.

`Physics.Raycast()` does not draw or change anything in the world. It only returns an intersection result. To display a ray or marker, use the returned coordinates with [WorldVisuals](../world-visuals/); for a screen-space label, combine [ImGui](../imgui/) with [`Camera:WorldToViewportPoint()`](../camera/#worldtoviewportpoint).

## Where the query runs

The client physics scene tests the ray against colliders available to it and immediately returns a `RaycastHit`. This is a local spatial query, not server shot validation: the result deals no damage and does not confirm that the server will allow an action.

`RaycastHit` is a result structure. Assigning its fields only changes the local value and does not move the collision point or a collider in the scene.

## Example

Check the surface below the main camera:

```lua
local origin = Cameras.Main.Position
local hit = Physics.Raycast(origin, Vector3.down, 100)

if hit.HasHit then
    print("Ground: " .. tostring(hit.Point))
    print("Distance: " .. tostring(hit.Distance))
else
    print("Nothing below the camera")
end
```

## Raycast with a limit

```lua
Physics.Raycast(
    origin: Vector3,
    direction: Vector3,
    maxDistance: number
): RaycastHit
```

| Argument | Type | Description |
|---|---|---|
| `origin` | [`Vector3`](../vector3/) | Ray origin in world coordinates. |
| `direction` | [`Vector3`](../vector3/) | Ray direction. |
| `maxDistance` | `number` | Maximum query distance. |

## Raycast without a limit

```lua
Physics.Raycast(
    origin: Vector3,
    direction: Vector3
): RaycastHit
```

The two-argument overload performs the same query without a distance limit supplied by the module.

Both overloads use dot syntax: `Physics.Raycast(...)`.

## RaycastHit

A result is always returned, even when the ray does not hit anything.

| Field | Type | Access | Description |
|---|---|---|---|
| `HasHit` | `bool` | `get/set` | Whether an intersection was found. |
| `Distance` | `number` | `get/set` | Distance from `origin` to the hit point. |
| `Point` | [`Vector3`](../vector3/) | `get/set` | Hit point in world coordinates. |

In the verified miss case, the result contained `HasHit = false`, `Distance = 0`, and `Point = Vector3.zero`. Check `HasHit` before using the other fields.

The fields accept assignment, but changing them only edits the returned result. It does not affect the physics scene.
