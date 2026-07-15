---
title: Серверный цикл
description: Scheduler.OnTick, интервалы, CPU-бюджет и безопасная работа с игровыми объектами.
---

Повторяющаяся логика `server.lua` запускается через `Scheduler:OnTick()`. Callback вызывается один раз на тик симуляции.

## Минимальный цикл

```lua
local function Tick()
    local agent = Agents:GetLocalAgent()

    if agent == nil or agent.Health == nil then
        return
    end

    -- Серверная логика
end

Scheduler:OnTick(Tick)
```

Получайте живые объекты заново. Агент или предмет, сохранённый между раундами, может стать недоступным.

## Работа не на каждом тике

Для редкой проверки храните следующий целевой тик:

```lua
local TickDuration = Time:TickToSeconds(1)
local IntervalTicks = math.ceil(0.25 / TickDuration)
local NextUpdateTick = 0

local function Tick()
    if Time.Tick < NextUpdateTick then
        return
    end

    NextUpdateTick = Time.Tick + IntervalTicks

    -- Выполняется не чаще четырёх раз в секунду
end

Scheduler:OnTick(Tick)
```

`math.ceil(seconds / tickDuration)` не сокращает заданный положительный интервал на один тик из-за погрешности преобразования.

## CPU-бюджет

Reflex server имеет ограниченный бюджет выполнения. Проверить остаток можно через `CpuLimit`:

```lua
if CpuLimit.RemainingCpuTime < 0.2 then
    return
end
```

Это аварийная защита, а не замена оптимизации. Сначала:

- уменьшайте частоту тяжёлых обходов;
- выходите раньше при отсутствии агента или нужного состояния;
- не формируйте и не отправляйте одинаковые таблицы каждый тик;
- используйте `Length` API-массива и не обходите коллекцию повторно без необходимости.

## Управление подпиской

`OnTick()` возвращает `EventSubscription`:

```lua
local subscription

subscription = Scheduler:OnTick(function()
    if DefusalGame.IsGameEnded then
        subscription:Cancel()
        return
    end
end)
```

Сохраняйте ссылку, если цикл должен останавливаться до reload.

## Ошибка контекста останавливает выполнение

В `server.lua` нет `OnFrame`, [UI](../../api/ui/), [камер](../../api/camera/) и [клиентского ввода](../../api/input-action/). Обращение к отсутствующему члену может завершить текущую Lua-логику. Не используйте пробные вызовы недоступного API внутри основного цикла.

Справочник: [Scheduler](../../api/scheduler/), [Time](../../api/time/), [CpuLimit](../../api/cpu-limit/) и [Agent](../../api/agent/).
