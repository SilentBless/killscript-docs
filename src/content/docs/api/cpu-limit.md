---
title: CpuLimit
description: CPU-бюджет Lua-модуля в KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. API доступен в обычных модулях и в `server.lua` Reflex-модулей.
:::

`CpuLimit` показывает общий и оставшийся CPU-бюджет текущего Lua-модуля. Все свойства доступны только для чтения.

## Быстрый пример

```lua
if CpuLimit.RemainingCpuTime < 0.1 then
    return -- отложить необязательную работу
end
```

## Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `CpuCycleLimit` | `integer` | `get` | Максимальный бюджет CPU-циклов модуля на текущее выполнение. |
| `RemainingCpuCycles` | `integer` | `get` | Оставшийся бюджет в CPU-циклах. |
| `RemainingCpuTime` | `number` | `get` | Оставшаяся доля бюджета: от `0` до `1`. |

```lua
local usedCycles = CpuLimit.CpuCycleLimit - CpuLimit.RemainingCpuCycles
local remainingPercent = CpuLimit.RemainingCpuTime * 100
```

## Бюджет уменьшается во время выполнения

Значения отражают текущий остаток, а не постоянную характеристику устройства. В контрольном callback простой цикл из 100 итераций уменьшил `RemainingCpuCycles`.

Читайте остаток непосредственно перед дорогой необязательной операцией:

```lua
if CpuLimit.RemainingCpuTime >= 0.2 then
    -- Дополнительные расчёты
end
```

## Client и Reflex server

API работает в обоих контекстах, но лимиты сильно различаются. Во время проверки один клиентский модуль получил `880000000`, а `server.lua` Reflex-модуля — `1999000` циклов.

:::caution[Не полагайтесь на конкретное число]
Значения зависят от контекста и могут измениться в другой версии игры или конфигурации. Используйте текущие свойства, а не число из примера.
:::

## Доступ на запись

`CpuCycleLimit`, `RemainingCpuCycles` и `RemainingCpuTime` являются getter-only. Попытка изменить любое из них завершается Lua access error.
