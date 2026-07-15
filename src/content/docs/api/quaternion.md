---
title: Quaternion
description: Вращения в трёхмерном пространстве в Lua API KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Тип доступен в обычных модулях и в `server.lua` Reflex-модулей.
:::

`Quaternion` представляет вращение в 3D. Обычно кватернион создают из углов или направлений, а затем присваивают свойству вращения либо умножают на `Vector3`.

## Быстрый пример

Поворот на `90°` вокруг оси Y направляет `Vector3.forward` вправо:

```lua
local rotation = Quaternion.euler(0, 90, 0)
local direction = rotation * Vector3.forward

print(direction) -- (1.00, 0.00, -0.00)
```

## Создание

### Из компонентов

```lua
Quaternion.new(x: number, y: number, z: number, w: number): Quaternion
```

Компоненты кватерниона — не углы. Для обычного вращения в градусах используйте `Quaternion.euler()`.

### Из углов Эйлера

```lua
Quaternion.euler(x: number, y: number, z: number): Quaternion
```

Углы задаются в градусах. Фактический порядок композиции — `ZXY`:

```lua
Quaternion.euler(x, y, z) ==
    Quaternion.euler(0, 0, z)
    * Quaternion.euler(x, 0, 0)
    * Quaternion.euler(0, y, 0)
```

### По направлению

```lua
Quaternion.lookRotation(forward: Vector3, up?: Vector3): Quaternion
```

Создаёт вращение, у которого направление вперёд совпадает с `forward`.

### По углу и оси

```lua
Quaternion.angleAxis(angle: number, axis: Vector3): Quaternion
```

### Между направлениями

```lua
Quaternion.fromToRotation(fromDirection: Vector3, toDirection: Vector3): Quaternion
```

Возвращает вращение, переводящее одно направление в другое.

Для аргументов-направлений также принимается таблица с именованными полями:

```lua
local right = { x = 1, y = 0, z = 0 }
local rotation = Quaternion.lookRotation(right)
```

Позиционная таблица `{ 1, 0, 0 }` не поддерживается.

## Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `x` | `number` | `get/set` | Компонент X. |
| `y` | `number` | `get/set` | Компонент Y. |
| `z` | `number` | `get/set` | Компонент Z. |
| `w` | `number` | `get/set` | Компонент W. |
| `normalized` | `Quaternion` | `get` | Нормализованная копия. |
| `eulerAngles` | [`Vector3`](../vector3/) | `get` | Представление вращения углами Эйлера. |

### Ограничение eulerAngles

Для вращения только вокруг одной оси `eulerAngles` возвращает ожидаемые углы. Для комбинированного вращения результат нельзя безопасно передавать обратно в `Quaternion.euler()`.

Например, в текущей версии:

```lua
Quaternion.euler(10, 20, 30).eulerAngles
-- (-1.70, 22.21, 33.62)
```

Повторное создание кватерниона из этих трёх чисел дало другое вращение. Используйте `eulerAngles` для отображения или анализа, но храните исходный `Quaternion`, если вращение должно сохраниться без изменений.

## Методы

### Сравнение и преобразование

| Вызов | Возвращает | Описание |
|---|---|---|
| `rotation:Dot(other)` | `number` | Скалярное произведение. |
| `rotation:Angle(other)` | `number` | Угол между вращениями в градусах. |
| `rotation:Inverse()` | `Quaternion` | Вращение, отменяющее исходное. |
| `rotation:ToAngleAxis()` | `number, Vector3` | Угол и ось вращения. |

`ToAngleAxis()` возвращает два значения:

```lua
local angle, axis = rotation:ToAngleAxis()
```

### Normalize

```lua
rotation:Normalize(): Quaternion
```

:::caution[Normalize изменяет Quaternion]
В отличие от `Vector2:Normalize()` и `Vector3:Normalize()`, этот метод изменяет исходный объект и возвращает его нормализованное значение.
:::

Если исходный объект менять нельзя, используйте getter:

```lua
local normalizedCopy = rotation.normalized
```

### Интерполяция

| Вызов | Описание |
|---|---|
| `rotation:Lerp(to, t)` | Линейная интерполяция; `t` ограничивается диапазоном `0..1`. |
| `rotation:LerpUnclamped(to, t)` | Линейная интерполяция без ограничения `t`. |
| `rotation:Slerp(to, t)` | Сферическая интерполяция; `t` ограничивается диапазоном `0..1`. |
| `rotation:SlerpUnclamped(to, t)` | Сферическая интерполяция без ограничения `t`. |
| `rotation:RotateTowards(to, maxDegreesDelta)` | Шаг к `to` не больше заданного числа градусов. |

Все методы интерполяции возвращают `Quaternion`.

## Операторы

### Quaternion × Quaternion

```lua
local combined = firstRotation * secondRotation
```

Объединяет два вращения.

### Quaternion × Vector3

```lua
local rotatedDirection = rotation * direction
```

Применяет вращение к вектору и возвращает новый `Vector3`.

## Частые ошибки

### Передача обычной Lua-таблицы без ключей

Используйте `{ x = 1, y = 0, z = 0 }`, а не `{ 1, 0, 0 }`.

### Попытка записать normalized или eulerAngles

Оба свойства доступны только для чтения. Записывайте новый кватернион в переменную или целевое свойство объекта.
