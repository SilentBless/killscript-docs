---
title: Vector3
description: Three-dimensional positions, directions, and vector operations in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The type is available in regular modules and in Reflex module `server.lua` files.
:::

`Vector3` stores `x`, `y`, and `z` coordinates. Most world-space positions and directions in KILLSCRIPT use this type.

## Purpose and processing

`Vector3` is not a world object by itself. It is a value used to pass a position, direction, velocity, or size. `(1, 0, 0)` may be a direction for `Physics.Raycast()`, a line point, or another parameter—the receiving method defines its meaning.

Vector operations only calculate a new value. Changing local components does not move an agent, camera, or world object until the vector is passed to that object's API.

## Quick example

```lua
local movement = Vector3.new(3, 7, 4)
local horizontal = movement:OnlyXZ()

print(horizontal) -- (3.00, 0.00, 4.00)
```

## Creating a vector

```lua
Vector3.new(x: number, y: number, z: number): Vector3
```

```lua
local position = Vector3.new(10, 2, -5)
```

## Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `x` | `number` | `get/set` | X component. |
| `y` | `number` | `get/set` | Y component. |
| `z` | `number` | `get/set` | Z component. |
| `magnitude` | `number` | `get` | Vector length. |
| `sqrMagnitude` | `number` | `get` | Squared vector length. |
| `normalized` | `Vector3` | `get` | Normalized copy. |

`Normalize()` and `normalized` return a copy. They do not modify the source `Vector3`.

## Ready-made directions

| Value | Result |
|---|---|
| `Vector3.back` | `(0, 0, -1)` |
| `Vector3.down` | `(0, -1, 0)` |
| `Vector3.forward` | `(0, 0, 1)` |
| `Vector3.left` | `(-1, 0, 0)` |
| `Vector3.right` | `(1, 0, 0)` |
| `Vector3.up` | `(0, 1, 0)` |
| `Vector3.zero` | `(0, 0, 0)` |
| `Vector3.one` | `(1, 1, 1)` |
| `Vector3.positiveInfinity` | `(inf, inf, inf)` |
| `Vector3.negativeInfinity` | `(-inf, -inf, -inf)` |

## Operators

```lua
local sum = Vector3.new(1, 2, 3) + Vector3.new(4, 5, 6)
local difference = sum - Vector3.new(1, 2, 3)
```

Addition and subtraction between two `Vector3` values are supported.

## Direction from yaw and pitch

```lua
Vector3.fromYawPitchToDirection(yaw: number, pitch: number): Vector3
```

Converts angles in degrees to a unit direction.

| `yaw`, `pitch` | Result |
|---|---|
| `0`, `0` | `(0, 0, 1)` — forward |
| `90`, `0` | `(1, 0, 0)` — right |
| `0`, `90` | `(0, -1, 0)` — down |

:::caution[Pitch direction]
A positive `pitch` points the vector down; a negative value points it up.
:::

## Methods

| Call | Returns | Description |
|---|---|---|
| `vector:Magnitude()` | `number` | Vector length. |
| `vector:Normalize()` | `Vector3` | New normalized copy. |
| `vector:OnlyXZ()` | `Vector3` | Copy with `y = 0`. |
| `vector:Angle(to)` | `number` | Angle between directions in degrees. |
| `vector:Dot(other)` | `number` | Dot product. |
| `point:Distance(other)` | `number` | Distance between points. |
| `vector:Cross(other)` | `Vector3` | Cross product. |

### Cross

Operand order matters:

```lua
local forward = Vector3.right:Cross(Vector3.up)
print(forward) -- (0.00, 0.00, 1.00)
```

## Common mistakes

### Normalizing without assignment

`Normalize()` does not modify the source vector:

```lua
direction = direction:Normalize()
```

### Including vertical velocity in horizontal movement

Use `OnlyXZ()` to get a copy with a zero `y` component.
