---
title: Превью дополнительной камеры
description: Пользовательская камера, OutputTexture и вывод живого изображения через ImGui.
---

Дополнительная камера не заменяет основной вид. Она рендерит `OutputTexture`, которую модуль выводит как обычную текстуру.

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

## Пауза изображения

```lua
Preview:SetActive(false)
```

Камера прекращает обновлять текстуру, а последний кадр остаётся видимым. `SetActive(true)` продолжает рендер.

## Удаление

```lua
if Preview ~= nil then
    Cameras:RemoveCamera(Preview)
    Preview = nil
end
```

После удаления прежнюю ссылку использовать нельзя.

:::caution
Не перемещайте `Cameras.Main` для независимого вида: игровая камера также управляет видом и моделью рук, а игра может переписать её положение в следующем кадре.
:::

Справочник: [Camera](../../api/camera/), [Texture](../../api/texture/) и [ImGui](../../api/imgui/).
