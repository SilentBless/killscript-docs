---
title: Экранные метки союзников
description: Проекция мировых координат камерой и отрисовка имён союзников через ImGui.
---

Этот клиентский пример получает союзников, проецирует их позиции в viewport и показывает имена только для точек перед камерой.

```lua
local function DrawAllyLabels()
    local camera = Cameras.Main
    local allies = Agents:GetAllies()

    if camera == nil or allies == nil then
        return
    end

    for i = 1, allies.Length do
        local ally = allies[i]

        if ally ~= nil and ally.Movement ~= nil then
            local worldPosition =
                ally.Movement.Position + Vector3.new(0, 2, 0)
            local viewport =
                camera:WorldToViewportPoint(worldPosition)

            if viewport.z > 0
                and viewport.x >= 0 and viewport.x <= 1
                and viewport.y >= 0 and viewport.y <= 1 then
                ImGui:DrawTextUV(
                    ally.Nickname,
                    Vector2.new(viewport.x, viewport.y),
                    14,
                    ally.Color,
                    TextAnchor.MiddleCenter
                )
            end
        end
    end
end

Scheduler:OnFrame(DrawAllyLabels)
```

## Важные детали

- `Array` индексируется с `1` до `Length`;
- `WorldToViewportPoint()` возвращает `z < 0` для точки позади камеры;
- viewport использует нормализованные `x` и `y`;
- смещение на два метра поднимает подпись над позицией агента;
- `DrawTextUV()` принимает те же viewport-координаты.

Если нужно учитывать видимость или окклюзию, используйте соответствующие свойства агента и не показывайте неопределённые данные скрытого объекта.

Справочник: [Camera](../../api/camera/), [Agent](../../api/agent/), [Array](../../api/array/) и [ImGui](../../api/imgui/).
