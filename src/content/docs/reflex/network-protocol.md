---
title: Протокол Network
description: Структура сообщений, синхронизация состояния и проверка данных Reflex-модуля.
---

[`Network`](../../api/network/) передаёт таблицы между `main.lua` и `server.lua`. Чтобы модуль оставался понятным, задайте небольшой протокол вместо набора несвязанных полей.

## Всегда указывайте kind

```lua
Network:SendTable({
    kind = "settings",
    enabled = true,
    threshold = 30
})
```

Получатель сначала выбирает тип сообщения:

```lua
Network:OnTableReceived(function(data)
    if data.kind == "settings" then
        -- Применить настройки
    elseif data.kind == "request_state" then
        -- Отправить состояние
    end
end)
```

Так один callback обслуживает весь протокол без неоднозначности.

## Разделяйте команды и состояние

Удобная схема имён:

- `set_settings` — клиент передаёт настройки;
- `request_state` — клиент просит снимок;
- `state` — сервер отправляет подтверждённое состояние;
- `event` — сервер сообщает о произошедшем событии.

Не используйте возвращаемое значение `SendTable()` как ответ: метод возвращает `nil`. Ответ — отдельное входящее сообщение.

## Поддерживаемые данные

Передавайте:

- `string`;
- `number`;
- `boolean`;
- вложенные таблицы;
- последовательные таблицы.

Разложите структуры на числа:

```lua
local function PackVector3(value)
    return {
        x = value.x,
        y = value.y,
        z = value.z
    }
end
```

[`Vector3`](../../api/vector3/), [`Agent`](../../api/agent/), [`Texture`](../../api/texture/), функции и `nil`-поля не сохраняются транспортом.

## Проверяйте вход сервера

Lua-песочница не предоставляет `type`, поэтому используйте доступные безопасные преобразования и явные сравнения:

```lua
local function ApplySettings(data)
    local threshold = tonumber(data.threshold)

    if threshold ~= nil then
        threshold = math.max(1, math.min(100, threshold))
        State.threshold = threshold
    end

    State.enabled = data.enabled == true
end
```

Никогда не используйте клиентское число как индекс, дистанцию или длительность без диапазона.

## Не отправляйте состояние каждый кадр

Отправляйте сообщение, когда значение действительно изменилось:

```lua
local LastHealth = nil

local function SendHealthIfChanged(health)
    if health == LastHealth then
        return
    end

    LastHealth = health
    Network:SendTable({
        kind = "health_state",
        health = health
    })
end
```

Это уменьшает трафик и количество Lua-callbacks.

## Начальная синхронизация

Обе стороны должны уметь восстановить состояние независимо от порядка загрузки:

1. сервер хранит безопасные значения по умолчанию;
2. клиент регистрирует приём;
3. клиент отправляет настройки;
4. клиент запрашивает состояние;
5. сервер отвечает полным снимком.

Полный пример находится на странице [готового Reflex-модуля](../complete-module/).
