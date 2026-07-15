---
title: Texture
description: Loading and using images in KILLSCRIPT modules.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. The example and documented limits were confirmed in game.
:::

The `Textures` API loads images from the current module's `images` directory. A `Texture` object can be displayed through [UI](../ui/) or [ImGui](../imgui/); textures are also returned by other APIs, such as [`Camera.OutputTexture`](../camera/#properties).

`Textures` is available only in client-side Lua. In a Reflex module's `server.lua`, this global object is `nil`.

## Key points

- `.png`, `.jpg`, and `.jpeg` are supported;
- the file extension is required in the path;
- the recommended path is relative to the `images` directory;
- `width` and `height` are read-only;
- a missing or skipped file returns `nil`;
- images larger than `4096 × 4096` or files larger than `10 MB` are not loaded.

## File placement

Place image assets in the module's `images` directory. Nested directories are supported.

```text
MyModule/
├── images/
│   ├── Icon.png
│   └── UI/
│       └── Background.jpg
└── scripts/
    └── main.lua
```

Lua paths are relative to `images`:

```lua
local icon = Textures:GetTexture("Icon.png")
local background = Textures:GetTexture("UI/Background.jpg")
```

The optional `images/` prefix is also accepted, but a relative path is shorter and avoids accidentally writing `images/images/`:

```lua
Textures:GetTexture("images/Icon.png") -- works
Textures:GetTexture("Icon.png")        -- recommended
```

## Complete example

This example includes an `images/Icon.png` file. The code loads it once and draws it at `128 × 128` in the top-left corner.

```lua
local Icon = Textures:GetTexture("Icon.png")

if Icon == nil then
    print("[Texture example] images/Icon.png was not loaded")
else
    Scheduler:OnFrame(function()
        ImGui:DrawTexture(Icon, Rect.new(20, 20, 128, 128))
    end)
end
```

`ImGui` uses immediate-mode rendering, so `DrawTexture` is called every frame. The file does not need to be loaded again; keep the returned `Texture` in a variable.

## Texture

Represents an image loaded by the module or created by the game.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `width` | `int` | `get` | Image width in pixels. |
| `height` | `int` | `get` | Image height in pixels. |

Both properties are read-only. Assigning either property raises a Lua access error.

```lua
local icon = Textures:GetTexture("Icon.png")

if icon ~= nil then
    print("Icon size: " .. icon.width .. "x" .. icon.height)
end
```

## Textures

The global client-side image API for the current module.

### GetTexture

```lua
Textures:GetTexture(path: string): Texture | nil
```

Returns a loaded texture, or `nil` if the path was not found or the image was skipped by the loader.

| Parameter | Type | Description |
|---|---|---|
| `path` | `string` | A path with a file extension, relative to the `images` directory. |

Valid PNG, JPG, and JPEG files all return the same `Texture` object type.

## Paths

Use the exact file name, extension, and forward slashes:

```lua
Textures:GetTexture("Icon.png")
Textures:GetTexture("HUD/Weapons/Rifle.jpg")
```

The current Windows build treats paths as case-insensitive and accepts backslashes, but relying on this is discouraged. Matching the file's case and using `/` makes paths clearer and more resilient to future changes.

| Path | Result |
|---|---|
| `Icon.png` | loads `images/Icon.png` |
| `images/Icon.png` | also works |
| `Icon` | `nil` — the extension is missing |
| `./Icon.png` | `nil` |
| `Icon.png ` | `nil` — the space is part of the path |
| `images/images/Icon.png` | `nil` — the directory is included twice |

## File limits

The loader skips:

- unknown file extensions;
- corrupted images;
- files larger than `10 MB`;
- images whose width or height exceeds `4096` pixels.

In these cases, `GetTexture()` returns `nil`. The limits were confirmed with a corrupted PNG, a `4097 × 4097` image, and a decodable PNG containing `11,000,000` bytes.

## Common mistakes

### Storing the file next to main.lua

`Textures` scans `images`, not `scripts`. Move the asset into `images` and use a path relative to that directory.

### Omitting the extension

`Textures:GetTexture("Icon")` returns `nil`. Use the full file name: `Icon.png`.

### Loading the texture every frame

Get the `Texture` once when the module starts. Inside [`Scheduler:OnFrame()`](../scheduler/#onframe), pass the stored object to your [UI](../ui/) code.
