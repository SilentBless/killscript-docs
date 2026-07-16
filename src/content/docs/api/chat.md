---
title: Chat
description: Каналы, локальные и сетевые сообщения, а также события игрового чата.
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> `ChatManager` недоступен в `server.lua` Reflex-модуля.

## Как обрабатывается сообщение

`AddLocalMessage()` добавляет запись только в локальную модель чата. `SendActiveMessage()` и `SendMessage()` передают текст сетевой системе канала; после обработки получатели получают обычную `ChatMessage`, а интерфейс чата читает обновлённую модель.

`ChatChannel` описывает канал и его права, а `ChatMessage` — уже созданную запись. Изменение активного канала влияет на выбор локального клиента, но не перемещает существующие сообщения между каналами.

## Где появляется результат

Стандартный чат отображает сообщения в HUD-окне `Default Chat` в левом нижнем углу. Игрок может переместить это окно в редакторе HUD. В свёрнутом виде сообщения остаются видимыми ограниченное время; стандартное значение — 10 секунд.

| Действие | Что увидит игрок |
|---|---|
| `AddLocalMessage()` | Локальное системное сообщение от имени модуля. Другим игрокам оно не отправляется; свёрнутая стандартная лента может показать его только при следующем обновлении. |
| `SendActiveMessage()` / `SendMessage()` | Сетевое сообщение появляется в ленте выбранного канала у всех его получателей. |
| `SetActiveChannel*()` | Меняется канал, выбранный для просмотра и отправки; отдельного уведомления не появляется. |
| `ShowMessageContextMenu()` | Встроенное меню открывается рядом с найденным сообщением. |

Отображение обеспечивает встроенный модуль `Default Chat`. Если он отключён или заменён, данные и события `ChatManager` остаются доступны, но стандартная лента может не появиться. `AddLocalMessage()` не вызывает `OnMessagesChanged()`: стандартная свёрнутая лента обновит его при следующем обычном обновлении или открытии чата, а собственному интерфейсу следует обновиться сразу после вызова.

## Быстрый пример

```lua
ChatManager:AddLocalMessage("Сообщение видно только вам")

local active = ChatManager:GetActiveChannel()
if active ~= nil and active.IsAvailable and not active.IsReadOnly then
    ChatManager:SendActiveMessage("Сообщение в активный канал")
end
```

## ChatManager

Глобальный API игрового чата.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `MessageLimit` | int | `get` | Максимальная длина сообщения. |

### Сообщения

#### AddLocalMessage

```lua
ChatManager:AddLocalMessage(text: string)
```

Добавляет системное сообщение от имени модуля. Оно видно только локальному игроку и не вызывает `OnMessagesChanged()`.

#### SendActiveMessage

```lua
ChatManager:SendActiveMessage(text: string): bool
```

Отправляет сетевое сообщение в активный канал. Возвращает true, если сообщение принято к отправке. Перед вызовом проверяйте `IsAvailable` и `IsReadOnly` активного канала.

#### SendMessage

```lua
ChatManager:SendMessage(text: string)
```

Отправляет сетевое сообщение в активный канал и возвращает `nil`.

#### GetMessages

```lua
ChatManager:GetMessages(): Array<ChatMessage>
```

Возвращает видимые сейчас сообщения.

### Каналы

#### GetActiveChannel

```lua
ChatManager:GetActiveChannel(): ChatChannel
```

Возвращает активный канал или nil, если канал не выбран.

#### GetChannels

```lua
ChatManager:GetChannels(): Array<ChatChannel>
```

Возвращает доступные сейчас каналы.

#### SetActiveChannel

```lua
ChatManager:SetActiveChannel(channelId: string): bool
```

Выбирает канал по его `Id`. Возвращает true, если канал стал активным.

#### SetActiveChannelByKind

```lua
ChatManager:SetActiveChannelByKind(kind: ChatChannelKind)
```

Выбирает первый доступный канал указанного типа. Вызов возвращает `nil`.

#### SetActiveLocalTeamChannel

```lua
ChatManager:SetActiveLocalTeamChannel()
```

Выбирает командный канал локального игрока. Для зрителя выбирает первый доступный командный канал. Вызов возвращает `nil`.

#### ShowMessageContextMenu

```lua
ChatManager:ShowMessageContextMenu(messageId: string)
```

Открывает встроенное контекстное меню видимого сообщения. Если сообщение с таким `MessageId` не найдено, ничего не происходит. Вызов возвращает `nil`.

### События

#### OnActiveChannelChanged

```lua
ChatManager:OnActiveChannelChanged(callback: LuaFunction): EventSubscription
```

Вызывает callback после фактической смены активного канала.

#### OnChannelsChanged

```lua
ChatManager:OnChannelsChanged(callback: LuaFunction): EventSubscription
```

Вызывает callback без аргументов, когда меняется набор доступных каналов или данные канала. Событие возникает, например, при входе или выходе из матча, появлении командного, группового или личного канала и изменении доступности канала.

Чтобы получить актуальное состояние, вызовите `ChatManager:GetChannels()` внутри callback:

```lua
local subscription = ChatManager:OnChannelsChanged(function()
    local channels = ChatManager:GetChannels()
    print("Channels: " .. tostring(channels.Length))
end)
```

#### OnMessagesChanged

```lua
ChatManager:OnMessagesChanged(callback: LuaFunction): EventSubscription
```

Вызывает callback при появлении сетевых сообщений. Добавление локального сообщения через `AddLocalMessage()` это событие не вызывает.

Все три метода возвращают отменяемую [EventSubscription](../scheduler/#eventsubscription).

## ChatChannelKind

Тип канала чата.

| Значение | Число | Описание |
|---|---:|---|
| `ChatChannelKind.Party` | `0` | Канал группы. |
| `ChatChannelKind.Private` | `1` | Личный канал. |
| `ChatChannelKind.Match` | `2` | Общий канал матча. |
| `ChatChannelKind.Team` | `3` | Командный канал. |
| `ChatChannelKind.System` | `4` | Системный канал. |

## ChatChannel

Описание канала чата. В текущей сборке все свойства доступны только для чтения.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `DisplayName` | string | `get` | Отображаемое имя канала. |
| `Id` | string | `get` | Внутренний ID. |
| `IsAvailable` | bool | `get` | true, если канал сейчас доступен. |
| `IsReadOnly` | bool | `get` | true, если отправка сообщений запрещена. |
| `Kind` | ChatChannelKind | `get` | Тип канала. |
| `KindName` | string | `get` | Название типа канала. |
| `Team` | [Team](../team/) | `get` | Команда для командного канала или nil. |

## ChatMessage

Сообщение из `ChatManager:GetMessages()`. Все свойства доступны только для чтения.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `ChannelDisplayName` | string | `get` | Отображаемое имя канала. |
| `ChannelId` | string | `get` | ID канала. |
| `ChannelKind` | ChatChannelKind | `get` | Тип канала. |
| `IsLocal` | bool | `get` | true, если сообщение отправлено локальным игроком. |
| `IsSystem` | bool | `get` | true для системного сообщения. |
| `MessageId` | string | `get` | Уникальный ID сообщения. |
| `SenderDisplayName` | string | `get` | Отображаемое имя отправителя. |
| `SenderUserId` | string | `get` | ID отправителя. |
| `Team` | [Team](../team/) | `get` | Команда для командного сообщения или nil. |
| `Text` | string | `get` | Текст сообщения. |
