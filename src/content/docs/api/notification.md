---
title: Notification
description: Локальные подсказки, уведомления и ping-маркеры в мире.
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> Эти API недоступны в `server.lua` Reflex-модуля.

## NotificationController

Глобальный API локальных подсказок и уведомлений.

### Быстрый пример

```lua
local subscription = NotificationController:OnHint(function(event)
    print(event.Message)
end)

NotificationController:ShowHint("Модуль загружен", 2)

Scheduler:Schedule(10, function()
    subscription:Cancel()
end)
```

### OnHint

```lua
NotificationController:OnHint(callback: LuaFunction): EventSubscription
```

Вызывает callback с [HintNotificationEvent](#hintnotificationevent), когда локальный игрок получает подсказку.

### OnNotification

```lua
NotificationController:OnNotification(callback: LuaFunction): EventSubscription
```

Вызывает callback с [NotificationEvent](#notificationevent), когда локальный игрок получает обычное уведомление.

### OnViolationNotification

```lua
NotificationController:OnViolationNotification(callback: LuaFunction): EventSubscription
```

Вызывает callback с [ViolationNotificationEvent](#violationnotificationevent), когда игра сообщает локальному игроку о нарушении.

Все три метода возвращают отменяемую [EventSubscription](../scheduler/#eventsubscription).

### ShowHint

```lua
NotificationController:ShowHint(message: string, duration: number = 1)
```

Показывает локальному игроку подсказку на указанное число секунд. Вызов возвращает `nil` и создаёт событие `OnHint`.

### ShowNotification

```lua
NotificationController:ShowNotification(message: string, duration: number)
```

Показывает локальному игроку уведомление. Вызов возвращает `nil` и создаёт событие `OnNotification`.

:::note
Обрабатывайте данные уведомления внутри callback. Это не требует дополнительного опроса `NotificationController`.
:::

## HintNotificationEvent

Данные полученной подсказки. Поля поддерживают чтение и присваивание (`get/set`); присваивание меняет только полученную структуру события.

| Поле | Тип | Доступ | Описание |
|---|---|:---:|---|
| `Message` | string | `get/set` | Текст подсказки. |
| `DurationSeconds` | number | `get/set` | Длительность показа в секундах. |

## NotificationEvent

Данные обычного уведомления. Конкретное сочетание заполненных полей зависит от `Code`.

| Поле | Тип | Доступ | Описание |
|---|---|:---:|---|
| `Code` | [ENotificationCode](#enotificationcode) | `get/set` | Тип уведомления. |
| `EventId` | int | `get/set` | Уникальный ID события. |
| `DurationSeconds` | number | `get/set` | Длительность показа в секундах. |
| `SubjectName` | string | `get/set` | Связанное имя: например, игрок или инициатор таймаута. |
| `Message` | string | `get/set` | Текст обычного уведомления. |
| `Amount` | int | `get/set` | Числовое значение, например сумма награды. |
| `CurrentCount` | int | `get/set` | Текущее значение счётчика. |
| `MaxCount` | int | `get/set` | Максимальное значение счётчика. |
| `IsSpectator` | bool | `get/set` | true, если уведомление относится к зрителю. |

## ViolationNotificationEvent

Данные внутриигрового нарушения.

| Поле | Тип | Доступ | Описание |
|---|---|:---:|---|
| `Kind` | [InGameViolationKind](#ingameviolationkind) | `get/set` | Тип нарушения. |
| `Severity` | [InGameViolationSeverity](#ingameviolationseverity) | `get/set` | Серьёзность нарушения. |
| `EventId` | int | `get/set` | Уникальный ID события. |

## ENotificationCode

| Значение | Число | Назначение |
|---|---:|---|
| `None` | `0` | Активного уведомления нет. |
| `GenericText` | `1` | Обычный текст. |
| `TimeoutActivated` | `2` | Таймаут активирован. |
| `TimeoutLimitReached` | `3` | Лимит таймаутов исчерпан. |
| `BridgeChargeDeployed` | `4` | Заряд установлен. |
| `LastRound` | `5` | Последний раунд матча. |
| `LastRoundBeforeSwap` | `6` | Последний раунд перед сменой сторон. |
| `MatchPoint` | `7` | Матчпоинт. |
| `Victory` | `8` | Победа. |
| `Defeat` | `9` | Поражение. |
| `KillReward` | `10` | Награда за убийство. |
| `RoundWonReward` | `11` | Награда за выигранный раунд. |
| `RoundLostReward` | `12` | Награда за проигранный раунд. |
| `BridgeChargePlantedReward` | `13` | Награда за установку заряда. |
| `BridgeChargeDefusedReward` | `14` | Награда за обезвреживание заряда. |
| `SellItemReward` | `15` | Возврат денег за продажу предмета. |
| `TimeoutPendingActivation` | `16` | Таймаут ожидает начала следующего раунда. |
| `WaitingForPlayers` | `17` | Игра ожидает игроков. |
| `MatchStarting` | `18` | Матч скоро начнётся. |
| `WarmupConsoleHint` | `19` | Подсказка о запуске кастомного матча из консоли. |

## InGameViolationKind

| Значение | Число | Назначение |
|---|---:|---|
| `None` | `0` | Нарушения нет. |
| `FriendlyDamage` | `1` | Урон союзнику. |
| `FriendlyHelmetBreak` | `2` | Разрушение защиты союзника. |
| `FriendlyEmpHit` | `3` | Попадание EMP по союзнику. |
| `Afk` | `4` | Игрок не покинул зону закупки. |

## InGameViolationSeverity

| Значение | Число | Назначение |
|---|---:|---|
| `None` | `0` | Серьёзность не задана. |
| `Minor` | `1` | Незначительное нарушение. |
| `Moderate` | `2` | Среднее нарушение. |
| `Severe` | `3` | Тяжёлое нарушение. |

## PingController

Глобальный API ping-маркеров.

### Быстрый пример

```lua
local subscription = PingController:OnPing(function(event)
    print("Ping at " .. tostring(event.Position))
end)

PingController:SetPing(Vector3.new(0, 1, 0))

Scheduler:Schedule(10, function()
    subscription:Cancel()
end)
```

### OnPing

```lua
PingController:OnPing(callback: LuaFunction): EventSubscription
```

Вызывает callback при создании ping и возвращает отменяемую [EventSubscription](../scheduler/#eventsubscription).

### SetPing

```lua
PingController:SetPing(position: Vector3)
```

Создаёт ping в указанной мировой позиции. Вызов возвращает `nil` и порождает событие `OnPing`.

## PingEvent

Данные созданного ping. Все поля поддерживают чтение и присваивание (`get/set`); присваивание меняет только полученную структуру события.

### Поля

| Поле | Тип | Доступ | Описание |
|---|---|:---:|---|
| `Color` | Color | `get/set` | Цвет ping-маркера. |
| `ExpiresAtTick` | int | `get/set` | Тик, на котором маркер исчезнет. |
| `MarkerType` | PingMarkerType | `get/set` | Тип ping-маркера. |
| `Number` | int | `get/set` | Номер игрока. |
| `PingIndex` | int | `get/set` | Порядковый индекс ping. |
| `Position` | Vector3 | `get/set` | Мировая позиция. |
| `TeamId` | int | `get/set` | ID команды. |

## PingMarkerType

| Значение | Число | Назначение |
|---|---:|---|
| `Mine` | `0` | Ping локального игрока. |
| `Party` | `1` | Ping участника группы. |
| `Ally` | `2` | Ping союзника. |
