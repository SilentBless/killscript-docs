---
title: Custom camera preview
description: Create a custom camera and display its live OutputTexture through ImGui.
---

A custom camera does not replace the main view. It renders an `OutputTexture` that the module displays like any other texture.

```lua
local Preview = Cameras:CreateCamera()

if Preview == nil then
    print("Camera limit reached")
else
    Preview:SetRenderSize(320, 180)
    Preview.Aspect = 320 / 180
    Preview.Fov = 60
    Preview:SetActive(true)

    Scheduler:OnFrame(function()
        local main = Cameras.Main

        if main == nil then
            return
        end

        Preview.Position =
            main.Position + Vector3.new(0, 2, 0)
        Preview.Rotation = main.Rotation

        if Preview.OutputTexture ~= nil then
            ImGui:DrawTexture(
                Preview.OutputTexture,
                Rect.new(20, 20, 320, 180)
            )
        end
    end)
end
```

## Freeze the image

```lua
Preview:SetActive(false)
```

The texture keeps its final frame while rendering stops. `SetActive(true)` resumes updates.

## Removal

```lua
if Preview ~= nil then
    Cameras:RemoveCamera(Preview)
    Preview = nil
end
```

Do not use the previous reference after removal.

:::caution
Do not move `Cameras.Main` for an independent view. It also drives the regular view and hand model, and the game may overwrite it on the next frame.
:::

Reference: [Camera](../../api/camera/), [Texture](../../api/texture/), and [ImGui](../../api/imgui/).
