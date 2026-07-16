---
title: Scheduler
description: Кадровые, серверные и отложенные callback-функции в Lua API KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Контексты методов, отмена подписок и отложенный вызов подтверждены в игре.
:::

`Scheduler` запускает callback каждый кадр, каждый серверный тик или один раз после задержки.

Планировщик сам ничего не рисует и не меняет в игре: видимый или игровой эффект определяется кодом внутри callback. `OnFrame()` подходит для клиентской отрисовки и плавного обновления UI, `OnTick()` — для серверных решений, а `Schedule()` — для одноразовой задержки в текущем контексте.

## Где обрабатываются callback-функции

- `OnFrame()` хранит подписку в клиентском runtime модуля и вызывает её из цикла отрисовки. Частота зависит от FPS, а не от серверного tickrate.
- `OnTick()` хранит подписку в Reflex server runtime и вызывает её один раз за серверный тик модуля.
- `Schedule()` помещает одноразовый callback в очередь текущего runtime; по истечении задержки очередь вызывает функцию в том же client/server-контексте.
- `EventSubscription:Cancel()` удаляет повторяющийся callback из этой очереди. Он не откатывает уже выполненные изменения.

## Контексты

| Метод | Обычный модуль / Reflex `main.lua` | Reflex `server.lua` |
|---|:---:|:---:|
| `OnFrame` | ✅ | ❌ |
| `OnTick` | ❌ | ✅ |
| `Schedule` | ✅ | ✅ |

Ограничения строгие: недоступный метод отсутствует в Lua-объекте. Вызов `OnTick` на клиенте или `OnFrame` на сервере останавливает выполнение Lua access error.

## OnFrame

```lua
Scheduler:OnFrame(callback: function): EventSubscription
```

Вызывает callback каждый отрисованный кадр. Метод доступен только в клиентской Lua-части.

```lua
local subscription
local frames = 0

subscription = Scheduler:OnFrame(function()
    frames = frames + 1

    if frames >= 60 then
        subscription:Cancel()
    end
end)
```

Частота `OnFrame` зависит от частоты кадров. Не используйте количество кадров как таймер в секундах — сравнивайте [`Time.Seconds`](../time/#текущее-время) или применяйте `Schedule()`.

## OnTick

```lua
Scheduler:OnTick(callback: function): EventSubscription
```

Вызывает callback каждый тик симуляции. Метод доступен только в `server.lua` Reflex-модуля.

```lua
local subscription
local ticks = 0

subscription = Scheduler:OnTick(function()
    ticks = ticks + 1

    if ticks >= 30 then
        subscription:Cancel()
    end
end)
```

В проверке 30 последовательных callback-ов соответствовали 30 тикам и `0.5` секунды симуляции.

## EventSubscription

`OnFrame()` и `OnTick()` возвращают объект подписки.

### Cancel

```lua
subscription:Cancel()
```

Отменяет подписку. После вызова её callback больше не выполняется.

Сохраняйте возвращённый объект, если callback должен когда-либо остановиться:

```lua
local subscription = Scheduler:OnFrame(Update)

-- Позже
subscription:Cancel()
```

## Schedule

```lua
Scheduler:Schedule(duration: number, callback: function)
```

Планирует один вызов callback через указанное число секунд. Доступен в обоих Lua-контекстах.

```lua
Scheduler:Schedule(1, function()
    print("One second has passed")
end)
```

Метод возвращает `nil`, а callback вызывается только один раз. Объект `EventSubscription` для такого вызова не создаётся.

### Точность задержки

`Schedule()` выполняет callback на ближайшем последующем обновлении, поэтому фактическая задержка может быть немного больше указанной.

Для `Schedule(0.1, callback)` было получено:

| Контекст | Фактическая задержка |
|---|---:|
| Client | около `0.1064` секунды |
| Reflex server | около `0.1167` секунды, 7 тиков |

Используйте метод для игровой логики и интерфейса, но не ожидайте точности высокочастотного таймера.

### Пустой callback

```lua
Scheduler:Schedule(0, nil)
```

Такой вызов принимается без ошибки и ничего не делает.

## Частые ошибки

### OnTick вызывается в main.lua

`OnTick` не является клиентским методом. Перенесите логику в `server.lua` Reflex-модуля либо используйте `OnFrame`.

### OnFrame вызывается в server.lua

Сервер не отрисовывает кадры. Используйте `OnTick`.

### Потеря ссылки на подписку

Без сохранённого `EventSubscription` код не сможет вызвать `Cancel()`. Присвойте результат `OnFrame()` или `OnTick()` переменной.

### Ожидание подписки от Schedule

`Schedule()` возвращает `nil`. Если нужна отменяемая задержка, реализуйте проверку времени внутри `OnFrame` или `OnTick` и отмените эту подписку после выполнения.
