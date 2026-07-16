---
title: DefusalGame
description: Состояние матча, раунда и BridgeCharge в режиме Defusal.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Свойства, контексты и история раундов подтверждены в client и Reflex server.
:::

`DefusalGame` — глобальный API текущего матча Defusal. Через него можно узнать стадию раунда, оставшееся время, состояние BridgeCharge, счёт и игровые стороны.

Все свойства самого `DefusalGame` доступны только для чтения.

## Откуда берётся состояние

Серверный режим Defusal управляет стадиями раунда, таймерами, сторонами, счётом и жизненным циклом BridgeCharge. В `server.lua` свойства читают это авторитетное состояние; клиент получает его сетевое представление для HUD и модулей.

`DefusalGame` ничего не запускает и не завершает: это интерфейс наблюдения. `GetMatchRoundsLog()` возвращает записи уже рассчитанной истории. Даже если поля `DefusalRoundState` допускают присваивание в Lua, изменяется только локальный объект записи, а не матч.

## Состояние текущего раунда

```lua
local secondsLeft = Time.TickToSeconds(
    DefusalGame.StageRemainingTicks
)

print("Round: " .. tostring(DefusalGame.RoundId))
print("Stage: " .. tostring(DefusalGame.Stage))
print("Seconds left: " .. tostring(secondsLeft))
```

`DefusalGame` доступен в клиентском скрипте и Reflex `server.lua`. Исключение — `IsVictory`, которое существует только на клиенте, поскольку зависит от команды локального игрока.

## Свойства

### BridgeCharge

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `BridgeChargeExplosionRemainingTicks` | `int` | `get` | Оставшиеся тики до взрыва установленного заряда. |
| `IsBridgeChargeDefused` | `bool` | `get` | Заряд обезврежен в текущем раунде. |
| `IsBridgeChargeExploded` | `bool` | `get` | Заряд взорвался в текущем раунде. |
| `IsBridgeChargePlanted` | `bool` | `get` | Заряд установлен. |

Значение в секундах можно получить через [`Time.TickToSeconds()`](../time/):

```lua
local seconds = Time.TickToSeconds(
    DefusalGame.BridgeChargeExplosionRemainingTicks
)
```

### Матч и раунд

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `IsGameEnded` | `bool` | `get` | Матч завершён. |
| `IsOvertime` | `bool` | `get` | Матч находится в дополнительных раундах. |
| `IsRoundBeforeSwap` | `bool` | `get` | После текущего раунда команды поменяются сторонами. |
| `IsRoundTimeOver` | `bool` | `get` | Время раунда закончилось до установки BridgeCharge. |
| `IsTeamSwapping` | `bool` | `get` | Сейчас выполняется смена сторон. |
| `IsVictory` | `bool` | `get` | Победа команды локального игрока. Только client. |
| `IsWarmupTimerActive` | `bool` | `get` | В разминке активен таймер ожидания или запуска. |
| `RoundId` | `int` | `get` | Номер текущего раунда. До начала игровых раундов может быть `0`. |
| `RoundWinnerTeam` | [`Team`](../team/) | `get` | Победившая команда, если она уже определена. |
| `Stage` | `EDefusalRoundStage` | `get` | Текущая стадия раунда. |
| `StageRemainingTicks` | `int` | `get` | Оставшиеся тики текущей стадии. |
| `WarmupRemainingTicks` | `int` | `get` | Оставшиеся тики таймера разминки. |

### Игровые стороны

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `BridgerFrontTeam` | [`Team`](../team/) | `get` | Атакующая сторона. |
| `BridgerFrontTeamTexture` | [`Texture`](../texture/) | `get` | Иконка атакующей стороны. |
| `KillScriptCompanyTeam` | [`Team`](../team/) | `get` | Обороняющаяся сторона. |
| `KillScriptCompanyTeamTexture` | [`Texture`](../texture/) | `get` | Иконка обороняющейся стороны. |

## GetMatchRoundsLog

```lua
DefusalGame:GetMatchRoundsLog(): Array<DefusalRoundState>
```

Возвращает историю состояний раундов в виде [`Array`](../array/). Как и у остальных API-массивов, индексация начинается с `1`.

:::caution[Известная проблема текущей сборки]
Метод сейчас возвращает все `52` сетевых слота, включая будущие пустые раунды с искусственным `RoundId`. Не используйте `Length` как количество сыгранных раундов и фильтруйте записи по текущему состоянию матча. Проблема передана разработчику и будет исправлена в будущей сборке.
:::

```lua
local rounds = DefusalGame:GetMatchRoundsLog()

for i = 1, rounds.Length do
    local round = rounds[i]
    print(
        "Round " .. tostring(round.RoundId)
            .. ": " .. tostring(round.Stage)
    )
end
```

## DefusalRoundState

Запись одного раунда из истории матча.

| Поле | Тип | Доступ | Описание |
|---|---|---|---|
| `IsBridgeChargeDefused` | `bool` | `get/set` | BridgeCharge была обезврежена. |
| `IsBridgeChargeExploded` | `bool` | `get/set` | BridgeCharge взорвалась. |
| `IsBridgeChargePlanted` | `bool` | `get/set` | BridgeCharge была установлена. |
| `IsRoundTimeOver` | `bool` | `get/set` | Раунд завершился по времени до установки заряда. |
| `IsTeamSwapping` | `bool` | `get/set` | Запись относится к смене сторон. |
| `RoundId` | `int` | `get/set` | Номер раунда. |
| `RoundWinnerTeam` | [`Team`](../team/) | `get/set` | Победившая команда. |
| `Stage` | `EDefusalRoundStage` | `get/set` | Стадия раунда. |

Присваивание этим полям принимается Lua API. Рассматривайте объект как запись данных: изменение полученного значения не является командой серверу и не изменяет результат матча.

## EDefusalRoundStage

| Значение | Код | Описание |
|---|---:|---|
| `None` | `0` | Активной стадии нет. |
| `Buy` | `1` | Стадия закупки. |
| `Fight` | `2` | Основная стадия боя. |
| `End` | `3` | Завершение раунда. |

При выводе значение enum содержит и имя, и код, например `Fight: 2`. Сравнивайте его с числовым кодом:

```lua
local FIGHT_STAGE = 2

if DefusalGame.Stage == FIGHT_STAGE then
    -- Раунд находится в боевой стадии
end
```

## Контекст server.lua

В Reflex server доступны все перечисленные свойства, кроме `IsVictory`. Попытка прочитать `DefusalGame.IsVictory` там завершает текущий Lua-вызов ошибкой доступа — не проверяйте его обычным сравнением с `nil`.
