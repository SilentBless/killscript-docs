---
title: Array
description: Arrays returned by the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The behavior was confirmed in both client-side and server-side Lua.
:::

`Array<T>` is a read-only array returned by many KILLSCRIPT API methods. It is a userdata object, not a regular Lua table.

`T` identifies the element type. For example, `Array<Agent>` contains `Agent` objects, while `Array<Hitbox>` contains `Hitbox` objects.

## Key points

- indexing starts at `1`;
- the number of elements is stored in `Length`;
- an out-of-range index returns `nil`;
- elements and `Length` are read-only;
- `ipairs(array)` works;
- the `#` operator and `pairs(array)` are not supported;
- arrays are available in both client-side Lua and Reflex server Lua.

## Complete example

This example retrieves all agents and iterates from index `1` through `Length`.

```lua
local AgentsArray = Agents:GetAll()
local Count = 0

for Index = 1, AgentsArray.Length do
    if AgentsArray[Index] ~= nil then
        Count = Count + 1
    end
end

print("[Array example] Iterated " .. Count .. " agents")
```

## Array&lt;T&gt;

An array of objects with the same type, created by the game API.

### Length

```lua
local count = array.Length
```

| Property | Type | Access | Description |
|---|---|---|---|
| `Length` | `integer` | `get` | Number of elements in the array. |

The property name starts with an uppercase letter. Assigning `Length` raises a Lua access error.

### Indexing

The first element is at index `1`; the last is at index `Length`.

```lua
local first = array[1]
local last = array[array.Length]
```

An invalid index does not raise an error and returns `nil`:

```lua
array[0]                -- nil
array[-1]               -- nil
array[array.Length + 1] -- nil
```

Array elements are read-only. Even assigning the same object is rejected:

```lua
array[1] = array[1] -- Lua access error
```

## Iterating over elements

### Numeric loop

An explicit loop makes the array boundaries clear and works in either Lua context:

```lua
for index = 1, array.Length do
    local value = array[index]
    -- Use value
end
```

### ipairs

`ipairs` is supported and returns each index together with its element:

```lua
for index, value in ipairs(array) do
    -- index starts at 1
end
```

## Differences from Lua tables

`Array<T>` is exposed to Lua as userdata, so some familiar table operations do not work.

### Length operator

Do not use `#array`:

```lua
local count = #array -- error: attempt to get length of a userdata value
```

Use `array.Length` instead.

### pairs

`pairs(array)` raises `table expected, got userdata`. Use a numeric loop or `ipairs` for sequential arrays.

## Empty arrays

If an API returns an array with `Length == 0`, a loop from `1` to `Length` performs no iterations. You do not need to inspect the first element separately.

```lua
if array.Length == 0 then
    print("Array is empty")
end
```

## Common mistakes

### Starting a loop at 0

Index `0` is always out of range. Start at `1`.

### Using #array

Game arrays do not implement Lua's length operator. Read `Length` instead.

### Trying to modify the array

API arrays are read-only views of game data. You cannot replace an element or change the array's length.
