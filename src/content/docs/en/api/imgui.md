---
title: ImGui
description: "Fast immediate-mode UI for text, textures, and configurable HUD windows."
---

:::note[Current build]
This page describes the API behavior in the current game build.
:::

<span class="api-context api-context--client">Client only</span> `ImGui` is unavailable in a Reflex module's `server.lua`.

## How ImGui works

ImGui elements are drawn for the current frame only. Call drawing methods from `Scheduler:OnFrame()` to keep text or images visible.

```lua
Scheduler:OnFrame(function()
    ImGui:DrawText(
        "Tick: " .. tostring(Time.Tick),
        Rect.new(20, 20, 280, 36),
        18,
        Color.new(1, 1, 1),
        TextAnchor.MiddleLeft
    )
end)
```

Create windows once when the module loads. Only their contents need to be redrawn every frame.

## Coordinates

- `DrawText()`, `DrawTextPos()`, and global texture methods use screen pixels with the origin in the top-left corner.
- `DrawTextUV()` uses normalized viewport coordinates: `(0, 0)` is the bottom-left corner and `(1, 1)` is the top-right corner.
- `ImGuiWindow` methods use coordinates inside the window content area.

## ImGui

The global fast-UI layer.

### DrawDebugText

```lua
ImGui:DrawDebugText(text: string)
```

Adds a line to the debug block at the edge of the screen. Multiple calls in one frame are stacked vertically. Returns `nil`.

### DrawText

```lua
ImGui:DrawText(
    text: string,
    rect: Rect,
    fontSize: number = 11,
    color: Color? = nil,
    alignment: TextAnchor = TextAnchor.MiddleCenter
)
```

Draws text inside the specified screen region. A built-in light text color is used when `color` is omitted. Returns `nil`.

### DrawTextPos

```lua
ImGui:DrawTextPos(
    text: string,
    screenPosition: Vector2,
    fontSize: number = 11,
    color: Color? = nil,
    alignment: TextAnchor = TextAnchor.MiddleCenter
)
```

Draws text at a screen position and automatically sizes its region to the content. Returns `nil`.

### DrawTextUV

```lua
ImGui:DrawTextUV(
    text: string,
    viewportPosition: Vector2,
    fontSize: number = 11,
    color: Color? = nil,
    alignment: TextAnchor = TextAnchor.MiddleCenter
)
```

Draws automatically sized text at a normalized viewport position. Values are converted using the current `Screen.Width` and `Screen.Height`. Returns `nil`.

### DrawTexture

```lua
ImGui:DrawTexture(texture: Texture, rect: Rect? = nil)
```

Draws a [Texture](../texture/) in the specified screen region. When `rect` is omitted, the entire available global layer is used. Returns `nil`.

### DrawTextureColor

```lua
ImGui:DrawTextureColor(texture: Texture, color: Color, rect: Rect? = nil)
```

Draws a texture with a color tint. The `color` alpha controls transparency. Returns `nil`.

:::caution[Per-frame limits]
The global layer and each window can draw up to 64 text elements and 16 images at the same time. Additional elements are not displayed.
:::

### AddImGuiWindow

```lua
ImGui:AddImGuiWindow(id: string, title: string, rect: Rect): ImGuiWindow
```

Creates a floating HUD window whose position and size can be configured by the player in the UI editor.

- `id` must be non-empty and unique within the module;
- `title` is shown in the window header;
- `rect` sets the initial position and size in screen pixels;
- one module can create at most 16 windows.

Returns an [ImGuiWindow](#imguiwindow). Returns `nil` for an empty `id` or after the window limit is reached.

## ImGuiWindow

A floating HUD window created with `ImGui:AddImGuiWindow()`.

### Quick example

```lua
local window = ImGui:AddImGuiWindow(
    "status",
    "Module status",
    Rect.new(40, 120, 320, 140)
)

if window ~= nil then
    window:SetVisibilityTypes({
        WindowVisibilityType.Match,
        WindowVisibilityType.Spectate,
    })

    Scheduler:OnFrame(function()
        window:DrawText(
            "Module is active",
            Rect.new(12, 12, 296, 32),
            18,
            Color.new(0.4, 1, 0.5),
            TextAnchor.MiddleLeft
        )
    end)
end
```

### DrawText

```lua
ImGuiWindow:DrawText(
    text: string,
    rect: Rect,
    fontSize: number,
    color: Color,
    alignment: TextAnchor = TextAnchor.MiddleCenter
)
```

Draws text inside the window content area. Unlike the global `DrawText()`, font size and color are required. Returns `nil`.

### DrawTexture

```lua
ImGuiWindow:DrawTexture(texture: Texture, rect: Rect? = nil)
```

Draws a texture inside the window. When `rect` is omitted, the image fills the available content area. Returns `nil`.

### DrawTextureColor

```lua
ImGuiWindow:DrawTextureColor(texture: Texture, color: Color, rect: Rect? = nil)
```

Draws a texture with a color tint inside the window. Returns `nil`.

### GetContentRenderSize

```lua
ImGuiWindow:GetContentRenderSize(): Vector2
```

Returns the content area's actual on-screen size in pixels, including UI scale and floating-window scale.

### SetVisibilityTypes

```lua
ImGuiWindow:SetVisibilityTypes(visibilityTypes: table): bool
```

Sets the modes in which the window is available in the HUD layout editor. Pass an array of [WindowVisibilityType](#windowvisibilitytype) values. `nil` or an empty table leaves the window only in the editor's all-modes filter.

Returns true for a valid window and false when its underlying window element is no longer available.

## TextAnchor

Text alignment relative to the supplied region or position.

| Value | Number | Placement |
|---|---:|---|
| `TextAnchor.UpperLeft` | `0` | Top left |
| `TextAnchor.UpperCenter` | `1` | Top center |
| `TextAnchor.UpperRight` | `2` | Top right |
| `TextAnchor.MiddleLeft` | `3` | Middle left |
| `TextAnchor.MiddleCenter` | `4` | Center |
| `TextAnchor.MiddleRight` | `5` | Middle right |
| `TextAnchor.LowerLeft` | `6` | Bottom left |
| `TextAnchor.LowerCenter` | `7` | Bottom center |
| `TextAnchor.LowerRight` | `8` | Bottom right |

## WindowVisibilityType

Floating HUD window visibility mode.

| Value | Number | Mode |
|---|---:|---|
| `WindowVisibilityType.Match` | `0` | Regular match |
| `WindowVisibilityType.Spectate` | `1` | Spectating a player |
| `WindowVisibilityType.Killcam` | `2` | Killcam |

## Related types

- [Rect](../rect/) — screen region;
- [Vector2](../vector2/) — position;
- [Color](../color/) — color and transparency;
- [Texture](../texture/) — image;
- [Scheduler](../scheduler/) — redraw every frame.
