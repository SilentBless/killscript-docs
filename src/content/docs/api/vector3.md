---
title: Vector3
description: Трёхмерные позиции, направления и векторные операции в Lua API KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Тип доступен в обычных модулях и в `server.lua` Reflex-модулей.
:::

`Vector3` хранит координаты `x`, `y` и `z`. Большинство мировых позиций и направлений KILLSCRIPT представлены этим типом.

## Быстрый пример

```lua
local movement = Vector3.new(3, 7, 4)
local horizontal = movement:OnlyXZ()

print(horizontal) -- (3.00, 0.00, 4.00)
```

## Создание

```lua
Vector3.new(x: number, y: number, z: number): Vector3
```

```lua
local position = Vector3.new(10, 2, -5)
```

## Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `x` | `number` | `get/set` | Компонент X. |
| `y` | `number` | `get/set` | Компонент Y. |
| `z` | `number` | `get/set` | Компонент Z. |
| `magnitude` | `number` | `get` | Длина вектора. |
| `sqrMagnitude` | `number` | `get` | Квадрат длины. |
| `normalized` | `Vector3` | `get` | Нормализованная копия. |

`Normalize()` и `normalized` возвращают копию. Исходный `Vector3` не изменяется.

## Готовые направления

| Значение | Результат |
|---|---|
| `Vector3.back` | `(0, 0, -1)` |
| `Vector3.down` | `(0, -1, 0)` |
| `Vector3.forward` | `(0, 0, 1)` |
| `Vector3.left` | `(-1, 0, 0)` |
| `Vector3.right` | `(1, 0, 0)` |
| `Vector3.up` | `(0, 1, 0)` |
| `Vector3.zero` | `(0, 0, 0)` |
| `Vector3.one` | `(1, 1, 1)` |
| `Vector3.positiveInfinity` | `(inf, inf, inf)` |
| `Vector3.negativeInfinity` | `(-inf, -inf, -inf)` |

## Операторы

```lua
local sum = Vector3.new(1, 2, 3) + Vector3.new(4, 5, 6)
local difference = sum - Vector3.new(1, 2, 3)
```

Поддерживаются сложение и вычитание двух `Vector3`.

## Направление из yaw и pitch

```lua
Vector3.fromYawPitchToDirection(yaw: number, pitch: number): Vector3
```

Преобразует углы в градусах в единичное направление.

| `yaw`, `pitch` | Результат |
|---|---|
| `0`, `0` | `(0, 0, 1)` — вперёд |
| `90`, `0` | `(1, 0, 0)` — вправо |
| `0`, `90` | `(0, -1, 0)` — вниз |

:::caution[Направление pitch]
Положительный `pitch` направляет вектор вниз, отрицательный — вверх.
:::

## Методы

| Вызов | Возвращает | Описание |
|---|---|---|
| `vector:Magnitude()` | `number` | Длина вектора. |
| `vector:Normalize()` | `Vector3` | Новая нормализованная копия. |
| `vector:OnlyXZ()` | `Vector3` | Копия с `y = 0`. |
| `vector:Angle(to)` | `number` | Угол между направлениями в градусах. |
| `vector:Dot(other)` | `number` | Скалярное произведение. |
| `point:Distance(other)` | `number` | Расстояние между точками. |
| `vector:Cross(other)` | `Vector3` | Векторное произведение. |

### Cross

Порядок аргументов имеет значение:

```lua
local forward = Vector3.right:Cross(Vector3.up)
print(forward) -- (0.00, 0.00, 1.00)
```

## Частые ошибки

### Нормализация без присваивания

`Normalize()` не изменяет исходный вектор:

```lua
direction = direction:Normalize()
```

### Вертикальная скорость попадает в горизонтальное движение

Используйте `OnlyXZ()`, чтобы получить копию с обнулённым `y`.
