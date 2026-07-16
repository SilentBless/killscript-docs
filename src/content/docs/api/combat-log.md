---
title: CombatLog
description: История нанесённого и полученного локальным игроком урона.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha на реальных событиях входящего и исходящего урона.
:::

`CombatLog` содержит клиентскую историю попаданий локального игрока. API доступен только в `main.lua`; в Reflex `server.lua` глобальный объект `CombatLog` равен `nil`.

## Как заполняется журнал

Сначала серверная система боя подтверждает попадание и урон. Когда клиент получает обработанный результат, локальный combat-log добавляет запись для исходящего или входящего урона. `CombatLog.Entries` только читает накопленную историю и не участвует в расчёте попадания.

Для реакции в момент события используйте [`Agents:OnLocalPlayerDealtDamage()`](../agent/#onlocalplayerdealtdamage) или `OnLocalPlayerReceivedDamage()`. Журнал удобен для последующего отображения и статистики; изменение его записей не меняет здоровье или серверную историю.

## Пример

```lua
local entries = CombatLog.Entries

for i = 1, entries.Length do
    local entry = entries[i]
    local direction = entry.IsOutgoing and "dealt" or "received"

    print(
        direction
            .. " " .. tostring(entry.Damage)
            .. " damage at " .. tostring(entry.Distance)
            .. " meters"
    )
end
```

Список может быть пустым, пока локальный игрок не нанёс и не получил урон.

## Entries

```lua
local entries = CombatLog.Entries
```

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Entries` | [`Array`](../array/)`<CombatLogEntry>` | `get` | Записи боевого журнала локального игрока. |

`Entries` доступен только для чтения. Для последней записи используйте `entries[entries.Length]`, предварительно проверив, что `Length > 0`.

## CombatLogEntry

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `BodyPart` | `EHitboxBodyPart` | `get` | Часть тела, по которой пришлось попадание. |
| `Damage` | `number` | `get` | Количество урона. |
| `Distance` | `number` | `get` | Дистанция до цели в момент попадания. |
| `Instigator` | `Agent` | `get` | Атакующий агент. |
| `IsFatal` | `bool` | `get` | Попадание было смертельным. |
| `IsOutgoing` | `bool` | `get` | `true` для урона, нанесённого локальным игроком. |
| `ItemId` | `int` | `get` | ID использованного предмета или оружия. |
| `Tick` | `int` | `get` | Тик события. |
| `Victim` | `Agent` | `get` | Получивший урон агент. |
| `WasShieldDestroyed` | `bool` | `get` | Попадание разрушило Kinetic Shield. |
| `WasStunned` | `bool` | `get` | Попадание наложило оглушение. |

:::caution[Записи доступны только для чтения]
Все 11 свойств `CombatLogEntry` отклоняют присваивание. Не используйте старые примеры, в которых эти поля обозначены как `get/set`.
:::

`Instigator` и `Victim` могут ссылаться на объекты [`Agent`](../agent/). Не сохраняйте такие ссылки надолго: агент может стать недоступен после выхода игрока или смены состояния матча.
