---
title: Chat
description: Channels, local and network messages, and game-chat events.
---

:::note[Current build]
This page describes the API behavior in the current game version.
:::

<span class="api-context api-context--client">Client only</span> `ChatManager` is unavailable in a Reflex module's `server.lua`.

## How a message is processed

`AddLocalMessage()` adds an entry only to the local chat model. `SendActiveMessage()` and `SendMessage()` pass text to the channel network system; after processing, recipients receive a regular `ChatMessage`, and chat UI reads the updated model.

`ChatChannel` describes a channel and its permissions, while `ChatMessage` is an entry that already exists. Changing the active channel changes the local client's selection but does not move existing messages between channels.

## Where the result appears

The standard chat renders messages in the `Default Chat` HUD window in the bottom-left corner. Players can move this window in the HUD editor. In collapsed mode, messages remain visible for a limited time; the standard value is 10 seconds.

| Action | What the player sees |
|---|---|
| `AddLocalMessage()` | A local system message attributed to the module. It is not sent to other players; the collapsed standard feed may show it only on its next refresh. |
| `SendActiveMessage()` / `SendMessage()` | A network message appears in the selected channel feed for all recipients. |
| `SetActiveChannel*()` | Changes the channel selected for viewing and sending; it does not show a separate notification. |
| `ShowMessageContextMenu()` | Opens the built-in menu next to the matching message. |

The built-in `Default Chat` module provides the standard presentation. If it is disabled or replaced, `ChatManager` data and events remain available but the standard feed may not appear. `AddLocalMessage()` does not invoke `OnMessagesChanged()`: the collapsed standard feed picks it up on its next normal refresh or when chat opens, while custom interfaces should refresh immediately after the call.

## Quick example

```lua
ChatManager:AddLocalMessage("Only you can see this message")

local active = ChatManager:GetActiveChannel()
if active ~= nil and active.IsAvailable and not active.IsReadOnly then
    ChatManager:SendActiveMessage("Message to the active channel")
end
```

## ChatManager

Global game-chat API.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `MessageLimit` | int | `get` | Maximum message length. |

### Messages

#### AddLocalMessage

```lua
ChatManager:AddLocalMessage(text: string)
```

Adds a system message on behalf of the module. It is only visible to the local player and does not invoke `OnMessagesChanged()`.

#### SendActiveMessage

```lua
ChatManager:SendActiveMessage(text: string): bool
```

Sends a network message to the active channel. Returns true if the message was accepted for sending. Check the active channel's `IsAvailable` and `IsReadOnly` properties first.

#### SendMessage

```lua
ChatManager:SendMessage(text: string)
```

Sends a network message to the active channel and returns `nil`.

#### GetMessages

```lua
ChatManager:GetMessages(): Array<ChatMessage>
```

Returns messages currently visible to the player.

### Channels

#### GetActiveChannel

```lua
ChatManager:GetActiveChannel(): ChatChannel
```

Returns the active channel, or nil if no channel is selected.

#### GetChannels

```lua
ChatManager:GetChannels(): Array<ChatChannel>
```

Returns currently available channels.

#### SetActiveChannel

```lua
ChatManager:SetActiveChannel(channelId: string): bool
```

Selects a channel by its `Id`. Returns true if that channel became active.

#### SetActiveChannelByKind

```lua
ChatManager:SetActiveChannelByKind(kind: ChatChannelKind)
```

Selects the first available channel of the specified type. The call returns `nil`.

#### SetActiveLocalTeamChannel

```lua
ChatManager:SetActiveLocalTeamChannel()
```

Selects the local player's team channel. For a spectator, it selects the first available team channel. The call returns `nil`.

#### ShowMessageContextMenu

```lua
ChatManager:ShowMessageContextMenu(messageId: string)
```

Opens the built-in context menu for a visible message. If no message with that `MessageId` exists, nothing happens. The call returns `nil`.

### Events

#### OnActiveChannelChanged

```lua
ChatManager:OnActiveChannelChanged(callback: LuaFunction): EventSubscription
```

Calls the callback after the active channel actually changes.

#### OnChannelsChanged

```lua
ChatManager:OnChannelsChanged(callback: LuaFunction): EventSubscription
```

Calls the callback without arguments when the available channel set or channel data changes. This happens, for example, when entering or leaving a match, when team, party, or private channels appear, or when channel availability changes.

Call `ChatManager:GetChannels()` inside the callback to read the current state:

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

Calls the callback when network messages arrive. Adding a local message through `AddLocalMessage()` does not invoke this event.

All three methods return a cancellable [EventSubscription](../scheduler/#eventsubscription).

## ChatChannelKind

Chat channel type.

| Value | Number | Description |
|---|---:|---|
| `ChatChannelKind.Party` | `0` | Party channel. |
| `ChatChannelKind.Private` | `1` | Private channel. |
| `ChatChannelKind.Match` | `2` | Match-wide channel. |
| `ChatChannelKind.Team` | `3` | Team channel. |
| `ChatChannelKind.System` | `4` | System channel. |

## ChatChannel

Chat channel description. Every property is read-only in the current build.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `DisplayName` | string | `get` | Channel display name. |
| `Id` | string | `get` | Internal ID. |
| `IsAvailable` | bool | `get` | true while the channel is available. |
| `IsReadOnly` | bool | `get` | true if messages cannot be sent. |
| `Kind` | ChatChannelKind | `get` | Channel type. |
| `KindName` | string | `get` | Channel type name. |
| `Team` | [Team](../team/) | `get` | Team for a team channel, or nil. |

## ChatMessage

A message returned by `ChatManager:GetMessages()`. Every property is read-only.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `ChannelDisplayName` | string | `get` | Channel display name. |
| `ChannelId` | string | `get` | Channel ID. |
| `ChannelKind` | ChatChannelKind | `get` | Channel type. |
| `IsLocal` | bool | `get` | true if the local player sent the message. |
| `IsSystem` | bool | `get` | true for a system message. |
| `MessageId` | string | `get` | Unique message ID. |
| `SenderDisplayName` | string | `get` | Sender display name. |
| `SenderUserId` | string | `get` | Sender ID. |
| `Team` | [Team](../team/) | `get` | Team for a team message, or nil. |
| `Text` | string | `get` | Message text. |
