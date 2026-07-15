---
title: Camera
description: Main and custom cameras in the KILLSCRIPT Lua API.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. Every documented access mode and example was confirmed in game.
:::

The `Camera` API lets you inspect the scene's main camera and create additional cameras. A custom camera renders into a texture that can be displayed through UI or `ImGui`.

This entire API is client-only. In a Reflex module's `server.lua`, the global `Cameras` object is `nil`.

## Key points

- `Cameras.Main` returns the main camera and is read-only.
- `Cameras:CreateCamera()` creates a custom camera.
- `IsMainCamera` and `OutputTexture` are read-only properties.
- `SetActive(false)` stops updating `OutputTexture` and preserves its last frame.
- A custom camera does not replace the main view automatically. You must display its `OutputTexture` yourself.

## Complete example

This example creates a `320 × 180` preview in the top-left corner. The custom camera follows the main camera from a position two metres above it.

```lua
local PreviewCamera = Cameras:CreateCamera()

if PreviewCamera == nil then
    print("[Camera example] Camera limit reached")
else
    PreviewCamera:SetRenderSize(320, 180)
    PreviewCamera.Aspect = 320 / 180
    PreviewCamera.Fov = 60
    PreviewCamera:SetActive(true)

    Scheduler:OnFrame(function()
        local mainCamera = Cameras.Main
        PreviewCamera.Position = mainCamera.Position + Vector3.new(0, 2, 0)
        PreviewCamera.Rotation = mainCamera.Rotation

        local texture = PreviewCamera.OutputTexture
        if texture ~= nil then
            ImGui:DrawTexture(texture, Rect.new(20, 20, 320, 180))
        end
    end)
end
```

`ImGui` uses immediate-mode rendering, so `DrawTexture` is called every frame. The camera itself is created only once.

## Camera

Represents either the main camera or a custom camera. Camera objects are not constructed directly; use `Cameras.Main` or `Cameras:CreateCamera()`.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `Aspect` | `number` | `get/set` | Image width divided by image height. |
| `FarClipPlane` | `number` | `get/set` | Far clipping plane in metres. |
| `Fov` | `number` | `get/set` | Vertical field of view in degrees. |
| `IsMainCamera` | `bool` | `get` | `true` only for the scene's main camera. |
| `IsOrthographic` | `bool` | `get/set` | Whether orthographic projection is enabled. |
| `NearClipPlane` | `number` | `get/set` | Near clipping plane in metres. |
| `OrthographicSize` | `number` | `get/set` | Orthographic camera size. Used when `IsOrthographic = true`. |
| `OutputTexture` | [`Texture`](../texture/) \| `nil` | `get` | The custom camera's output texture. Returns `nil` for the main camera. |
| `Position` | `Vector3` | `get/set` | Camera position in world space. |
| `Rotation` | `Quaternion` | `get/set` | Camera rotation in world space. |

:::caution[The game controls the main camera]
The main camera's setters work, but game logic may write its own values on the next frame. Changing `Position` or `Rotation` moves the main view together with the first-person hands; it does not create a third-person view. Create a custom camera for an independent view.
:::

### SetActive

```lua
camera:SetActive(value: bool)
```

Starts or stops rendering a custom camera.

| Parameter | Type | Description |
|---|---|---|
| `value` | `bool` | `true` updates the image; `false` stops updates. |

When set to `false`, the camera object and its `OutputTexture` remain available, and the texture keeps the last rendered frame. Calling the method with `true` resumes rendering.

### SetRenderSize

```lua
camera:SetRenderSize(width: int, height: int)
```

Sets the custom camera's `OutputTexture` size in pixels.

| Parameter | Type | Description |
|---|---|---|
| `width` | `int` | Texture width. |
| `height` | `int` | Texture height. |

After `camera:SetRenderSize(320, 180)`, `camera.OutputTexture.width` and `camera.OutputTexture.height` return `320` and `180`.

`SetRenderSize` does not update `Aspect` automatically. These values are usually set together:

```lua
camera:SetRenderSize(320, 180)
camera.Aspect = 320 / 180
```

### WorldToViewportPoint

```lua
camera:WorldToViewportPoint(worldPosition: Vector3): Vector3
```

Converts a world-space position to viewport coordinates:

- `(0, 0)` is the bottom-left corner;
- `(1, 1)` is the top-right corner;
- `z` is the distance from the camera in metres;
- a negative `z` means that the point is behind the camera.

For a camera at the world origin with `Fov = 90`, `Aspect = 1`, and zero rotation, the method returns:

| World position | Result |
|---|---|
| `(0, 0, 10)` | `(0.5, 0.5, 10)` — screen centre |
| `(10, 0, 10)` | `(1, 0.5, 10)` — right edge |
| `(0, 10, 10)` | `(0.5, 1, 10)` — top edge |
| `(0, 0, -10)` | `(0.5, 0.5, -10)` — behind the camera |

## Cameras

The global client-side API for accessing and creating cameras.

### Main

```lua
local mainCamera = Cameras.Main
```

Returns the scene's main camera. The `Main` property itself is read-only.

### CreateCamera

```lua
local camera = Cameras:CreateCamera()
```

Creates and returns a custom camera. Check the returned value for `nil` before using it.

### RemoveCamera

```lua
Cameras:RemoveCamera(camera)
```

Removes a previously created custom camera. Do not use a stored reference after removing the camera.

```lua
camera:SetActive(false)
Cameras:RemoveCamera(camera)
camera = nil
```

## Common mistakes

### Writing to read-only properties

The following operations raise a Lua access error:

```lua
Cameras.Main = camera
camera.IsMainCamera = true
camera.OutputTexture = texture
```

### Expecting the main view to switch automatically

`camera:SetActive(true)` starts the custom camera's renderer but does not replace the main camera's image. Display `camera.OutputTexture` through a UI element or `ImGui:DrawTexture()`.

### Using a point behind the camera

Checking only `x` and `y` is not enough. Before drawing a marker, make sure the value returned by `WorldToViewportPoint()` has `z > 0`.
