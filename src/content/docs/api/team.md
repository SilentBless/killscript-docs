---
title: Team
description: Счёт, экономика и тайм-ауты команды в матче.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Все свойства и их доступность в client и Reflex server подтверждены в игре.
:::

`Team` представляет одну из команд матча. Объект нельзя создать вручную: его возвращают другие API, например [`DefusalGame.BridgerFrontTeam`](../defusal-game/) и `DefusalGame.KillScriptCompanyTeam`.

Счёт, серия поражений экономики и использованные тайм-ауты рассчитываются серверным режимом матча. `Team` только предоставляет Lua чтение текущего серверного состояния или его клиентской сетевой копии; присваивание не является командой изменить счёт.

```lua
local attackers = DefusalGame.BridgerFrontTeam

print("Rounds: " .. tostring(attackers.RoundWins))
print("Loss streak: " .. tostring(attackers.EconomyLossCount))
```

API доступен в клиентском скрипте и Reflex `server.lua`.

## Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `EconomyLossCount` | `int` | `get` | Количество экономических поражений подряд. |
| `RoundWins` | `int` | `get` | Количество выигранных командой раундов. |
| `TimeoutsTaken` | `int` | `get` | Количество использованных тайм-аутов. |

Все три свойства доступны только для чтения. Попытка присвоить им значение завершает Lua-вызов ошибкой доступа.

## Команды Defusal

```lua
local attackers = DefusalGame.BridgerFrontTeam
local defenders = DefusalGame.KillScriptCompanyTeam

print(
    tostring(attackers.RoundWins)
        .. " : "
        .. tostring(defenders.RoundWins)
)
```

Названия `BridgerFrontTeam` и `KillScriptCompanyTeam` обозначают игровые стороны, а не обязательно постоянный состав игроков: во время матча команды меняются сторонами.
