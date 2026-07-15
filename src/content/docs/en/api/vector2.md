---
title: Vector2
description: Two-dimensional vectors and operations in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The type is available in regular modules and in Reflex module `server.lua` files.
:::

`Vector2` stores two coordinates: `x` and `y`. It is suitable for points, sizes, directions, and screen coordinates.

## Quick example

```lua
local direction = Vector2.new(3, 4)
local normalized = direction:Normalize()

print(normalized)          -- (0.60, 0.80)
print(direction)           -- (3.00, 4.00)
print(direction.magnitude) -- 5
```

`Normalize()` returns a new vector and does not modify the source.

## Creating a vector

```lua
Vector2.new(x: number, y: number): Vector2
```

```lua
local position = Vector2.new(120, 80)
```

## Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `x` | `number` | `get/set` | X component. |
| `y` | `number` | `get/set` | Y component. |
| `magnitude` | `number` | `get` | Vector length. |
| `sqrMagnitude` | `number` | `get` | Squared vector length. |
| `normalized` | `Vector2` | `get` | Normalized copy. |

`magnitude`, `sqrMagnitude`, and `normalized` are read-only. The `x` and `y` components are writable.

## Ready-made values

| Value | Result |
|---|---|
| `Vector2.zero` | `(0, 0)` |
| `Vector2.one` | `(1, 1)` |

## Operators

```lua
local sum = Vector2.new(1, 2) + Vector2.new(3, 4) -- (4, 6)
local difference = sum - Vector2.new(1, 2)        -- (3, 4)
```

Addition and subtraction between two `Vector2` values are supported.

## Methods

### Magnitude

```lua
vector:Magnitude(): number
```

Returns the vector length. The result matches `vector.magnitude`.

### Normalize

```lua
vector:Normalize(): Vector2
```

Returns a new normalized copy without modifying `vector`. The `vector.normalized` getter provides the same kind of value.

### Dot

```lua
vector:Dot(other: Vector2): number
```

Returns the dot product of two vectors.

### Angle

```lua
vector:Angle(to: Vector2): number
```

Returns the angle between two directions in degrees. The result between `(1, 0)` and `(0, 1)` is `90`.

### Distance

```lua
point:Distance(other: Vector2): number
```

Returns the distance between two points. The result between `(0, 0)` and `(3, 4)` is `5`.

## Common mistakes

### Expecting the source vector to change

Store the result of `Normalize()`:

```lua
direction = direction:Normalize()
```

Calling the method without assignment does not change `direction`.
