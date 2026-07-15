---
title: HUD на ImGui
description: Практический клиентский HUD с состоянием игрока, цветом и адаптацией к размеру экрана.
---

Сделаем компактный блок, который показывает здоровье локального игрока. Для ImGui не нужны дополнительные файлы — весь пример находится в `scripts/main.lua`.

```lua
local function GetHealthColor(health, maximum)
    local ratio = 0

    if maximum > 0 then
        ratio = health / maximum
    end

    return Color.new(1 - ratio, ratio, 0.2, 1)
end

local function DrawHud()
    local agent = Agents:GetLocalAgent()

    if agent == nil or agent.Health == nil then
        return
    end

    local health = agent.Health.CurrentHealth
    local maximum = agent.Health.MaxHealth
    local text = "HP " .. tostring(health) .. " / " .. tostring(maximum)

    ImGui:DrawText(
        text,
        Rect.new(24, Screen.Height - 86, 260, 46),
        22,
        GetHealthColor(health, maximum),
        TextAnchor.MiddleLeft
    )
end

Scheduler:OnFrame(DrawHud)
```

## Почему отрисовка находится в OnFrame

ImGui не создаёт постоянный элемент. Каждый вызов добавляет содержимое только в текущий кадр, поэтому `DrawHud()` регистрируется через `Scheduler:OnFrame()`.

## Почему объект проверяется на nil

Локальный агент может быть недоступен во время загрузки, наблюдения или перехода между состояниями. Ранний `return` защищает модуль от обращения к отсутствующему объекту.

## Координаты

`Rect.new(x, y, width, height)` использует экранные пиксели от левого верхнего угла. В примере Y вычисляется от `Screen.Height`, поэтому блок остаётся у нижнего края.

Для позиции относительно viewport можно использовать `DrawTextUV()`, а для обычной точки — `DrawTextPos()`.

## Настройка через Config

Размер и цвет удобно отдать пользователю:

```json
[
  {
    "label": "HUD size",
    "key": "HudSize",
    "type": "number",
    "value": 22,
    "min": 12,
    "max": 36
  }
]
```

После этого замените `22` в `DrawText()` на `Config.HudSize`.

Справочник: [ImGui](../../api/imgui/), [Scheduler](../../api/scheduler/), [Agent](../../api/agent/), [Screen](../../api/screen/), [Rect](../../api/rect/), [Color](../../api/color/) и [Config](../../api/config/).
