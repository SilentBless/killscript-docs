---
title: Vector2
description: Двумерные векторы и операции над ними в Lua API KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Тип доступен в обычных модулях и в `server.lua` Reflex-модулей.
:::

`Vector2` хранит две координаты: `x` и `y`. Тип подходит для точек, размеров, направлений и экранных координат.

## Зачем нужен и как обрабатывается

`Vector2` — универсальное значение из двух чисел. Значение получает смысл только в принимающем API: `AgentInput` трактует его как движение или углы взгляда, UI — как двумерную позицию, а математические методы — как обычный вектор.

Операции `Dot`, `Angle`, `Distance`, `Normalize` и арифметика выполняют только вычисление и не меняют игровое состояние. Чтобы результат подействовал, передайте его соответствующему setter-у или методу.

## Быстрый пример

```lua
local direction = Vector2.new(3, 4)
local normalized = direction:Normalize()

print(normalized)         -- (0.60, 0.80)
print(direction)          -- (3.00, 4.00)
print(direction.magnitude) -- 5
```

`Normalize()` возвращает новый вектор и не изменяет исходный.

## Создание

```lua
Vector2.new(x: number, y: number): Vector2
```

```lua
local position = Vector2.new(120, 80)
```

## Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `x` | `number` | `get/set` | Компонент X. |
| `y` | `number` | `get/set` | Компонент Y. |
| `magnitude` | `number` | `get` | Длина вектора. |
| `sqrMagnitude` | `number` | `get` | Квадрат длины. |
| `normalized` | `Vector2` | `get` | Нормализованная копия. |

`magnitude`, `sqrMagnitude` и `normalized` доступны только для чтения. Компоненты `x` и `y` можно менять.

## Готовые значения

| Значение | Результат |
|---|---|
| `Vector2.zero` | `(0, 0)` |
| `Vector2.one` | `(1, 1)` |

## Операторы

```lua
local sum = Vector2.new(1, 2) + Vector2.new(3, 4) -- (4, 6)
local difference = sum - Vector2.new(1, 2)        -- (3, 4)
```

Поддерживаются сложение и вычитание двух `Vector2`.

## Методы

### Magnitude

```lua
vector:Magnitude(): number
```

Возвращает длину вектора. Результат совпадает со свойством `vector.magnitude`.

### Normalize

```lua
vector:Normalize(): Vector2
```

Возвращает новую нормализованную копию и не меняет `vector`. То же значение можно получить через getter `vector.normalized`.

### Dot

```lua
vector:Dot(other: Vector2): number
```

Возвращает скалярное произведение двух векторов.

### Angle

```lua
vector:Angle(to: Vector2): number
```

Возвращает угол между направлениями в градусах. Между `(1, 0)` и `(0, 1)` результат равен `90`.

### Distance

```lua
point:Distance(other: Vector2): number
```

Возвращает расстояние между двумя точками. Между `(0, 0)` и `(3, 4)` результат равен `5`.

## Частые ошибки

### Ожидание изменения исходного вектора

Сохраните результат `Normalize()`:

```lua
direction = direction:Normalize()
```

Вызов без присваивания не изменит `direction`.
