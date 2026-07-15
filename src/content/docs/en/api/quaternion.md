---
title: Quaternion
description: Three-dimensional rotations in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The type is available in regular modules and in Reflex module `server.lua` files.
:::

`Quaternion` represents a rotation in 3D. A quaternion is usually constructed from angles or directions and then assigned to a rotation property or multiplied by a `Vector3`.

## Quick example

A `90°` rotation around the Y axis turns `Vector3.forward` to the right:

```lua
local rotation = Quaternion.euler(0, 90, 0)
local direction = rotation * Vector3.forward

print(direction) -- (1.00, 0.00, -0.00)
```

## Creating a quaternion

### From components

```lua
Quaternion.new(x: number, y: number, z: number, w: number): Quaternion
```

Quaternion components are not angles. Use `Quaternion.euler()` for a conventional rotation in degrees.

### From Euler angles

```lua
Quaternion.euler(x: number, y: number, z: number): Quaternion
```

Angles are specified in degrees. The actual composition order is `ZXY`:

```lua
Quaternion.euler(x, y, z) ==
    Quaternion.euler(0, 0, z)
    * Quaternion.euler(x, 0, 0)
    * Quaternion.euler(0, y, 0)
```

### From a direction

```lua
Quaternion.lookRotation(forward: Vector3, up?: Vector3): Quaternion
```

Creates a rotation whose forward direction matches `forward`.

### From an angle and axis

```lua
Quaternion.angleAxis(angle: number, axis: Vector3): Quaternion
```

### Between two directions

```lua
Quaternion.fromToRotation(fromDirection: Vector3, toDirection: Vector3): Quaternion
```

Returns a rotation that turns one direction into the other.

Direction arguments also accept a table with named fields:

```lua
local right = { x = 1, y = 0, z = 0 }
local rotation = Quaternion.lookRotation(right)
```

The positional table `{ 1, 0, 0 }` is not supported.

## Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `x` | `number` | `get/set` | X component. |
| `y` | `number` | `get/set` | Y component. |
| `z` | `number` | `get/set` | Z component. |
| `w` | `number` | `get/set` | W component. |
| `normalized` | `Quaternion` | `get` | Normalized copy. |
| `eulerAngles` | [`Vector3`](../vector3/) | `get` | Euler-angle representation of the rotation. |

### eulerAngles limitation

For a rotation around a single axis, `eulerAngles` returns the expected angles. For a combined rotation, its result cannot safely be passed back to `Quaternion.euler()`.

For example, in the current version:

```lua
Quaternion.euler(10, 20, 30).eulerAngles
-- (-1.70, 22.21, 33.62)
```

Constructing a new quaternion from those three numbers produced a different rotation. Use `eulerAngles` for display or analysis, but keep the original `Quaternion` when a rotation must be preserved exactly.

## Methods

### Comparison and conversion

| Call | Returns | Description |
|---|---|---|
| `rotation:Dot(other)` | `number` | Dot product. |
| `rotation:Angle(other)` | `number` | Angle between rotations in degrees. |
| `rotation:Inverse()` | `Quaternion` | Rotation that cancels the source. |
| `rotation:ToAngleAxis()` | `number, Vector3` | Rotation angle and axis. |

`ToAngleAxis()` returns two values:

```lua
local angle, axis = rotation:ToAngleAxis()
```

### Normalize

```lua
rotation:Normalize(): Quaternion
```

:::caution[Normalize modifies Quaternion]
Unlike `Vector2:Normalize()` and `Vector3:Normalize()`, this method modifies the source object and returns its normalized value.
:::

Use the getter when the source object must remain unchanged:

```lua
local normalizedCopy = rotation.normalized
```

### Interpolation

| Call | Description |
|---|---|
| `rotation:Lerp(to, t)` | Linear interpolation; `t` is clamped to `0..1`. |
| `rotation:LerpUnclamped(to, t)` | Linear interpolation without clamping `t`. |
| `rotation:Slerp(to, t)` | Spherical interpolation; `t` is clamped to `0..1`. |
| `rotation:SlerpUnclamped(to, t)` | Spherical interpolation without clamping `t`. |
| `rotation:RotateTowards(to, maxDegreesDelta)` | Moves toward `to` by at most the given number of degrees. |

All interpolation methods return a `Quaternion`.

## Operators

### Quaternion × Quaternion

```lua
local combined = firstRotation * secondRotation
```

Combines two rotations.

### Quaternion × Vector3

```lua
local rotatedDirection = rotation * direction
```

Applies the rotation to a vector and returns a new `Vector3`.

## Common mistakes

### Passing an unkeyed Lua table

Use `{ x = 1, y = 0, z = 0 }`, not `{ 1, 0, 0 }`.

### Assigning normalized or eulerAngles

Both properties are read-only. Store a new quaternion in a variable or assign it to the target object's rotation property.

Related types: [Vector2](../vector2/) and [Vector3](../vector3/).
