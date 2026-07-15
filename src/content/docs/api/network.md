---
title: Network
description: Обмен Lua-таблицами между клиентом и сервером Reflex-модуля.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Передача данных в обе стороны и поддерживаемые типы подтверждены в игре.
:::

`Network` связывает `main.lua` и `server.lua` одного Reflex-модуля. Сообщение представляет собой Lua-таблицу: одна сторона отправляет её через `SendTable()`, другая принимает через `OnTableReceived()`.

## Быстрый пример

Клиент запрашивает текущее состояние раунда.

```lua title="scripts/main.lua"
Network:OnTableReceived(function(data)
    if data.kind == "round_state" then
        print("Round: " .. tostring(data.roundId))
    end
end)

Network:SendTable({
    kind = "get_round_state"
})
```

Сервер отвечает на запрос.

```lua title="scripts/server.lua"
Network:OnTableReceived(function(data)
    if data.kind == "get_round_state" then
        Network:SendTable({
            kind = "round_state",
            roundId = DefusalGame.RoundId
        })
    end
end)
```

:::tip[Добавляйте тип сообщения]
Поле вроде `kind` позволяет обслуживать несколько видов сообщений одним callback и не путать запросы с ответами.
:::

## Поддерживаемые значения

Передаются:

- `string`;
- `number`;
- `boolean`, включая `false`;
- вложенные таблицы;
- последовательные таблицы вида `{ "first", "second" }`.

`nil`, функции и объекты API вроде `Vector3` не передаются. Если они находятся в поле таблицы, это поле отсутствует на принимающей стороне.

```lua
Network:SendTable({
    position = Vector3.zero, -- поле будет исключено
    callback = function() end, -- поле будет исключено
    visible = false, -- передаётся
    options = {
        color = "blue",
        size = 2
    }
})
```

Чтобы передать вектор, разложите его на числа:

```lua
local position = Vector3.new(10, 20, 30)

Network:SendTable({
    position = {
        x = position.x,
        y = position.y,
        z = position.z
    }
})
```

## OnTableReceived

```lua
Network:OnTableReceived(callback)
```

Регистрирует callback для таблиц, отправленных противоположной стороной модуля.

| Аргумент | Тип | Описание |
|---|---|---|
| `callback` | `function(data)` | Функция, получающая восстановленную Lua-таблицу. |

Метод возвращает `nil`.

## SendTable

```lua
Network:SendTable(data)
```

Отправляет таблицу противоположной стороне Reflex-модуля.

| Аргумент | Тип | Описание |
|---|---|---|
| `data` | `table` | Данные сообщения. |

Метод возвращает `nil`. Отправка не является запросом сама по себе: если нужен ответ, договоритесь о полях сообщения и обработайте его через `OnTableReceived()`.

## Частые ошибки

- попытка передать `Vector3`, `Agent`, `Texture` или функцию напрямую;
- ожидание возвращаемого значения от `SendTable()`;
- отсутствие поля, различающего типы сообщений;
- доверие клиентским данным в серверной игровой логике без проверки.
