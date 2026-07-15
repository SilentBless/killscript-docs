---
title: Первый Reflex-модуль
description: Создание Reflex-модуля, разделение client/server-кода и первый обмен данными через Network.
---

[Reflex-модуль](../../reflex/architecture/) состоит из двух частей:

- `scripts/main.lua` выполняется на клиенте игрока;
- `scripts/server.lua` выполняется в серверном контексте этого игрока.

Они имеют разные наборы API и обмениваются Lua-таблицами через [`Network`](../../api/network/).

:::note
Одновременно может быть активен только один Reflex-модуль. Для HUD, интерфейса и другой полностью локальной логики используйте обычный модуль.
:::

## 1. Создайте проект

1. Откройте меню модулей и нажмите **Create**.
2. Назовите модуль `HelloReflex`.
3. Включите **Is Reflex**.
4. Подтвердите создание и выберите этот Reflex-модуль активным.
5. Запустите пользовательскую игровую сессию.

В папке проекта должны находиться обе точки входа:

```text
HelloReflex/
├── module.json
└── scripts/
    ├── main.lua
    └── server.lua
```

## 2. Добавьте клиентский код

Откройте `scripts/main.lua`:

```lua title="scripts/main.lua"
Network:OnTableReceived(function(data)
    if data.kind == "server_tick" then
        print("Server tick: " .. tostring(data.tick))
    end
end)

Network:SendTable({
    kind = "get_server_tick"
})
```

Клиент регистрирует обработчик ответа, а затем отправляет запрос серверной части того же модуля.

## 3. Добавьте серверный код

Откройте `scripts/server.lua`:

```lua title="scripts/server.lua"
Network:OnTableReceived(function(data)
    if data.kind == "get_server_tick" then
        Network:SendTable({
            kind = "server_tick",
            tick = Time.Tick
        })
    end
end)
```

Сервер проверяет тип сообщения и отправляет текущий тик обратно. После загрузки обеих частей в консоли клиента появится строка `Server tick: ...`.

Если ответ не появился сразу после hot reload, сохраните `main.lua` ещё раз: клиентский запрос должен отправиться после готовности серверной части.

## Контексты API

Не переносите клиентский код в `server.lua` без проверки справочника.

| Возможность | `main.lua` | `server.lua` |
|---|:---:|:---:|
| [`ImGui`](../../api/imgui/), [`UI`](../../api/ui/), [`Cameras`](../../api/camera/) | ✅ | ❌ |
| `Scheduler:OnFrame()` | ✅ | ❌ |
| `Scheduler:OnTick()` | ❌ | ✅ |
| `Network` | ✅ | ✅ |
| Серверные методы игрового API | Ограничено | ✅ |

На страницах API клиентские и серверные методы отмечены отдельно.

## Какие данные передаёт Network

Можно передавать строки, числа, boolean и вложенные Lua-таблицы. Функции и объекты API, например [`Agent`](../../api/agent/) или [`Vector3`](../../api/vector3/), не сериализуются.

Передавайте составные значения как числа:

```lua
Network:SendTable({
    position = {
        x = position.x,
        y = position.y,
        z = position.z
    }
})
```

## Правила серверной логики

- проверяйте поле типа сообщения, например `kind`;
- проверяйте диапазон и смысл каждого значения от клиента;
- не считайте клиентские данные достоверными только потому, что они пришли через `Network`;
- не вызывайте клиентские API из `server.lua`;
- используйте `Scheduler:OnTick()` для повторяющейся серверной работы.

Дальше изучите [Network](../../api/network/), [Scheduler](../../api/scheduler/) и страницы нужных игровых объектов.
