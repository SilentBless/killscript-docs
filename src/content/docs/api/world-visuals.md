---
title: WorldVisuals
description: Линии и проецируемые области в трёхмерном игровом мире.
---

:::note[Проверено в игре]
Создание, изменение, отображение и удаление обоих типов объектов подтверждено визуально.
:::

<span class="api-context api-context--client">Только client</span> `WorldVisuals` недоступен в `server.lua` Reflex-модуля.

## Быстрый пример

```lua
local line = WorldVisuals:CreateLineRenderer()

if line ~= nil then
    line:SetPositions({
        Vector3.new(0, 1, 0),
        Vector3.new(2, 1, 2),
        Vector3.new(4, 1, 0),
    })
    line:SetColor(Color.new(1, 0.1, 0.8, 1))
    line:SetWidth(0.08)

    Scheduler:Schedule(5, function()
        WorldVisuals:RemoveObject(line)
    end)
end
```

## WorldVisuals

Глобальный API создания мировых визуальных объектов.

### CreateLineRenderer

```lua
WorldVisuals:CreateLineRenderer(): LineRenderer
```

Создаёт линию и возвращает её объект. Может вернуть nil при достижении лимита объектов модуля.

### CreateSurfaceOverlay

```lua
WorldVisuals:CreateSurfaceOverlay(): SurfaceOverlay
```

Создаёт область, проецируемую на поверхности мира. Может вернуть nil при достижении лимита.

### RemoveObject

```lua
WorldVisuals:RemoveObject(object)
```

Удаляет ранее созданную линию или область. Вызов возвращает `nil`.

## LineRenderer

Ломаная линия из мировых точек.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `PositionCount` | int | `get/set` | Количество точек линии. Максимум — 2048. |

### Геометрия

#### SetPositionCount

```lua
LineRenderer:SetPositionCount(count: int)
```

Задаёт количество точек линии.

#### SetPosition

```lua
LineRenderer:SetPosition(index: int, position: Vector3)
```

Изменяет одну точку. В отличие от API-массивов, индекс здесь начинается с `0`.

#### SetPositions

```lua
LineRenderer:SetPositions(points: LuaTable)
```

Заменяет все точки значениями последовательной Lua-таблицы. Поддерживается до 2048 точек.

### Внешний вид

Все setter-методы ниже возвращают `nil`.

| Метод | Аргументы | Описание |
|---|---|---|
| `SetColor` | `color: Color` | Устанавливает цвет линии. |
| `SetWidth` | `width: number` | Задаёт постоянную толщину. |
| `SetDistanceWidth` | `nearWidth, farWidth, nearDistance, farDistance: number` | Линейно изменяет толщину между ближней и дальней дистанциями. |
| `SetOccludedVisibility` | `brightness, transparency: number` | Настраивает видимость перекрытых геометрией участков. Значения ограничиваются диапазоном `0..1`. |
| `SetPatternEnabled` | `enabled: bool` | Включает или отключает текстурный паттерн. |
| `SetPatternRepeat` | `repeatCount: number` | Задаёт число повторений паттерна вдоль линии. |
| `SetPatternTexture` | `texture: Texture` | Устанавливает [Texture](../texture/) паттерна. |
| `SetProgress` | `progress: number` | Задаёт пройденную часть линии для материалов с `_Progress`. |

## SurfaceOverlay

Область, которая проецируется на видимые поверхности мира.

Все методы возвращают `nil`.

| Метод | Аргументы | Описание |
|---|---|---|
| `SetPosition` | `position: Vector3` | Задаёт центр области в мире. |
| `SetSize` | `size: Vector3` | Задаёт размер проецируемого объёма. |
| `SetColor` | `color: Color` | Задаёт цвет и прозрачность. |
| `SetFillBase` | `fillBase: number` | Задаёт базовую плотность заливки. |
| `SetOcclusionEnabled` | `enabled: bool` | Включает маску перекрытий геометрией. |
| `SetVisible` | `visible: bool` | Показывает или скрывает область. |

Связанные типы: [Vector3](../vector3/), [Color](../color/) и [Texture](../texture/).
