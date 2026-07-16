---
title: Notification
description: Локальные HUD-подсказки, баннеры, предупреждения и ping-маркеры в мире.
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> Эти API недоступны в `server.lua` Reflex-модуля.

## NotificationController

Глобальный API локальных подсказок и уведомлений.

`ShowHint()` и `ShowNotification()` создают локальное событие в `NotificationController`. Его получают подписчики API, а встроенный presentation-модуль может превратить те же данные в HUD. Это не серверное сообщение и другим игрокам оно не отправляется.

### Где это появляется

API передаёт событие интерфейсу, а стандартный внешний вид создают встроенные модули `Default Notifications` и `Default Ping Marks`.

| API | Область экрана по умолчанию | Как выглядит |
|---|---|---|
| [`ShowHint`](#showhint) / [`OnHint`](#onhint) | По центру снизу; привязка `bottom-middle`, вертикальный отступ `258px` | Компактная жёлтая строка с иконкой. |
| [`ShowNotification`](#shownotification) / [`OnNotification`](#onnotification) | По центру сверху; привязка `top-middle`, вертикальная позиция `14%` | Крупный баннер шириной около `390px`. |
| [`OnViolationNotification`](#onviolationnotification) | Слева сверху; привязка `top-left`, вертикальный отступ `372px` | Жёлтое предупреждение размером около `534×81px`. |
| [`SetPing`](#setping) / [`OnPing`](#onping) | В экранной точке, соответствующей мировой позиции | Маркер с расстоянием; за пределами экрана прижимается к краю и получает стрелку направления. |

Это позиции стандартной раскладки. Игрок может переместить HUD-окна в редакторе интерфейса, а отключение или замена соответствующего встроенного модуля убирает стандартное отображение. Само событие API при этом остаётся доступно другим клиентским модулям.

### Быстрый пример

```lua
NotificationController:ShowHint("Модуль загружен", 2)

Scheduler:Schedule(2.5, function()
    NotificationController:ShowNotification("Функция активна", 2)
end)
```

Для показа подписка не нужна: `ShowHint` и `ShowNotification` сами создают соответствующие локальные события.

### OnHint

```lua
NotificationController:OnHint(callback: LuaFunction): EventSubscription
```

Вызывает callback с [HintNotificationEvent](#hintnotificationevent), когда локальный игрок получает подсказку.

Стандартный HUD показывает только одну подсказку одновременно. Следующая подсказка заменяет текущую и запускает свой таймер показа.

### OnNotification

```lua
NotificationController:OnNotification(callback: LuaFunction): EventSubscription
```

Вызывает callback с [NotificationEvent](#notificationevent), когда локальный игрок получает обычное уведомление.

Стандартный HUD показывает один обычный баннер одновременно. Новое уведомление может заменить уже показанное.

### OnViolationNotification

```lua
NotificationController:OnViolationNotification(callback: LuaFunction): EventSubscription
```

Вызывает callback с [ViolationNotificationEvent](#violationnotificationevent), когда игра сообщает локальному игроку о нарушении.

Публичного метода для самостоятельного создания такого предупреждения нет: этот канал заполняет сама игра.

Все три метода возвращают отменяемую [EventSubscription](../scheduler/#eventsubscription).

### ShowHint

```lua
NotificationController:ShowHint(message: string, duration: number = 1)
```

Показывает локальному игроку подсказку на указанное число секунд. Вызов возвращает `nil` и создаёт событие `OnHint`.

Подсказка подходит для короткого контекстного сообщения, которое не должно перекрывать верхнюю часть HUD. В стандартной раскладке она видна в режимах матча, наблюдения и killcam.

### ShowNotification

```lua
NotificationController:ShowNotification(message: string, duration: number)
```

Показывает локальному игроку уведомление. Вызов возвращает `nil` и создаёт событие `OnNotification`.

Созданное этим методом уведомление имеет код [`GenericText`](#enotificationcode) и отображает `message` крупным текстом. Встроенный HUD умножает `duration` обычного текстового баннера на `1.5`: например, значение `2` даёт примерно `3` секунды показа без учёта короткой анимации исчезновения.

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

Данные обычного уведомления. Конкретное сочетание заполненных полей зависит от `Code`. Структура передаётся callback-у уже после создания события; изменение полей не перестраивает ранее показанный HUD-баннер.

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

Данные внутриигрового нарушения, которое создала сама игровая система. Изменение структуры callback-а не меняет очки нарушения, наказание или стандартное предупреждение.

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

Стандартный модуль `Default Ping Marks` проецирует мировую позицию на весь экран. Видимый маркер следует за точкой в мире, показывает расстояние и становится полупрозрачным за препятствием. Если точка находится за камерой или вне кадра, маркер остаётся у края экрана со стрелкой направления.

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

Метод не выполняет raycast и не выбирает поверхность автоматически — передайте уже вычисленную мировую точку, например `RaycastHit.Point` из [Physics.Raycast](../physics/#raycast). Стандартный визуальный маркер появляется только при включённом модуле `Default Ping Marks`.

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

Связанные типы: [Color](../color/), [Vector3](../vector3/) и [Team](../team/).
