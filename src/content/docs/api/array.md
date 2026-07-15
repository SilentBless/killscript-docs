---
title: Array
description: Массивы, которые возвращает Lua API KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Поведение подтверждено в клиентской и серверной частях Lua.
:::

`Array<T>` — массив только для чтения, который возвращают многие методы KILLSCRIPT API. Это userdata-объект, а не обычная Lua-таблица.

`T` обозначает тип элемента. Например, `Array<Agent>` содержит объекты [`Agent`](../agent/), а `Array<Hitbox>` — объекты [`Hitbox`](../agent/#hitbox).

## Главное

- индексация начинается с `1`;
- количество элементов находится в `Length`;
- выход за диапазон возвращает `nil`;
- элементы и `Length` доступны только для чтения;
- `ipairs(array)` работает;
- оператор `#` и `pairs(array)` не поддерживаются;
- массивы доступны и в client, и в Reflex server.

## Полный пример

Пример получает всех агентов и обходит массив по индексам от `1` до `Length`.

```lua
local AgentsArray = Agents:GetAll()
local Count = 0

for Index = 1, AgentsArray.Length do
    if AgentsArray[Index] ~= nil then
        Count = Count + 1
    end
end

print("[Array example] Iterated " .. Count .. " agents")
```

## Array&lt;T&gt;

Массив объектов одного типа, созданный игровым API.

### Length

```lua
local count = array.Length
```

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Length` | `integer` | `get` | Количество элементов массива. |

Имя свойства начинается с заглавной буквы. Запись в `Length` завершается Lua-ошибкой доступа.

### Индексация

Первый элемент расположен по индексу `1`, последний — по индексу `Length`.

```lua
local first = array[1]
local last = array[array.Length]
```

Недопустимый индекс не вызывает ошибку и возвращает `nil`:

```lua
array[0]                -- nil
array[-1]               -- nil
array[array.Length + 1] -- nil
```

Элементы массива доступны только для чтения. Даже присваивание того же объекта не разрешено:

```lua
array[1] = array[1] -- Lua access error
```

## Обход элементов

### Числовой цикл

Явный цикл лучше всего показывает границы массива и работает в любой Lua-части:

```lua
for index = 1, array.Length do
    local value = array[index]
    -- Работа с value
end
```

### ipairs

`ipairs` поддерживается и возвращает индекс вместе с элементом:

```lua
for index, value in ipairs(array) do
    -- index начинается с 1
end
```

## Отличия от Lua-таблицы

`Array<T>` отображается в Lua как userdata. Поэтому некоторые привычные операции с таблицами не работают.

### Оператор длины

Не используйте `#array`:

```lua
local count = #array -- ошибка: attempt to get length of a userdata value
```

Используйте `array.Length`.

### pairs

`pairs(array)` завершается ошибкой `table expected, got userdata`. Для последовательного массива используйте числовой цикл или `ipairs`.

## Пустой массив

Если API вернул массив с `Length == 0`, цикл от `1` до `Length` не выполнит ни одной итерации. Дополнительная проверка первого элемента не требуется.

```lua
if array.Length == 0 then
    print("Array is empty")
end
```

## Частые ошибки

### Цикл начинается с 0

Индекс `0` всегда находится вне диапазона. Начинайте с `1`.

### Используется #array

Игровой массив не реализует Lua-оператор длины. Читайте `Length`.

### Попытка изменить массив

Массивы API являются представлением данных игры только для чтения. Нельзя заменить элемент или изменить длину массива.
