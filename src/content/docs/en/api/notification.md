---
title: Notification
description: Local HUD hints, banners, warnings, and world-space ping markers.
---

:::note[Current build]
This page describes the API behavior in the current game version.
:::

<span class="api-context api-context--client">Client only</span> These APIs are unavailable in a Reflex module's `server.lua`.

## NotificationController

Global API for local hints and notifications.

`ShowHint()` and `ShowNotification()` create a local event in `NotificationController`. API subscribers are invoked, and a built-in presentation module can turn the same data into HUD. This is not a server message and is not sent to other players.

### Where it appears

The API emits an event to the UI. The built-in `Default Notifications` and `Default Ping Marks` modules provide the standard presentation.

| API | Default screen area | Presentation |
|---|---|---|
| [`ShowHint`](#showhint) / [`OnHint`](#onhint) | Bottom center; `bottom-middle` anchor with a `258px` vertical offset | Compact yellow row with an icon. |
| [`ShowNotification`](#shownotification) / [`OnNotification`](#onnotification) | Top center; `top-middle` anchor at `14%` vertically | Large banner about `390px` wide. |
| [`OnViolationNotification`](#onviolationnotification) | Upper left; `top-left` anchor with a `372px` vertical offset | Yellow warning approximately `534×81px`. |
| [`SetPing`](#setping) / [`OnPing`](#onping) | At the screen point corresponding to its world position | Marker with distance; moves to the screen edge with a direction arrow when off-screen. |

These are the default layout positions. The player can move HUD windows in the interface editor. Disabling or replacing the corresponding built-in module removes the standard presentation, while the API event remains available to other client modules.

### Quick example

```lua
NotificationController:ShowHint("Module loaded", 2)

Scheduler:Schedule(2.5, function()
    NotificationController:ShowNotification("Feature enabled", 2)
end)
```

No subscription is required for display: `ShowHint` and `ShowNotification` emit their corresponding local events themselves.

### OnHint

```lua
NotificationController:OnHint(callback: LuaFunction): EventSubscription
```

Calls the callback with a [HintNotificationEvent](#hintnotificationevent) when the local player receives a hint.

The standard HUD displays one hint at a time. A later hint replaces the current one and starts its own display timer.

### OnNotification

```lua
NotificationController:OnNotification(callback: LuaFunction): EventSubscription
```

Calls the callback with a [NotificationEvent](#notificationevent) when the local player receives a regular notification.

The standard HUD displays one regular banner at a time. A new notification may replace the banner already on screen.

### OnViolationNotification

```lua
NotificationController:OnViolationNotification(callback: LuaFunction): EventSubscription
```

Calls the callback with a [ViolationNotificationEvent](#violationnotificationevent) when the game reports a violation to the local player.

There is no public method for creating this warning yourself; the game owns this channel.

All three methods return a cancellable [EventSubscription](../scheduler/#eventsubscription).

### ShowHint

```lua
NotificationController:ShowHint(message: string, duration: number = 1)
```

Displays a hint to the local player for the specified number of seconds. The call returns `nil` and emits an `OnHint` event.

Use a hint for short contextual text that should not cover the upper HUD. In the default layout it is visible in match, spectate, and killcam contexts.

### ShowNotification

```lua
NotificationController:ShowNotification(message: string, duration: number)
```

Displays a local notification. The call returns `nil` and emits an `OnNotification` event.

This method creates a [`GenericText`](#enotificationcode) notification and renders `message` as large text. The built-in HUD multiplies a regular text banner's `duration` by `1.5`: for example, `2` produces approximately `3` seconds on screen, excluding the short exit animation.

:::note
Handle notification data inside the callback. No additional `NotificationController` polling is required.
:::

## HintNotificationEvent

Data for a received hint. Fields support reading and assignment (`get/set`); assignment only changes the received event structure.

| Field | Type | Access | Description |
|---|---|:---:|---|
| `Message` | string | `get/set` | Hint text. |
| `DurationSeconds` | number | `get/set` | Display duration in seconds. |

## NotificationEvent

Data for a regular notification. The fields populated depend on `Code`. The structure reaches the callback after event creation; changing its fields does not rebuild a HUD banner that was already shown.

| Field | Type | Access | Description |
|---|---|:---:|---|
| `Code` | [ENotificationCode](#enotificationcode) | `get/set` | Notification type. |
| `EventId` | int | `get/set` | Unique event ID. |
| `DurationSeconds` | number | `get/set` | Display duration in seconds. |
| `SubjectName` | string | `get/set` | Related name, such as a player or timeout initiator. |
| `Message` | string | `get/set` | Plain notification text. |
| `Amount` | int | `get/set` | Numeric value, such as a reward amount. |
| `CurrentCount` | int | `get/set` | Current counter value. |
| `MaxCount` | int | `get/set` | Maximum counter value. |
| `IsSpectator` | bool | `get/set` | true if the notification applies to a spectator. |

## ViolationNotificationEvent

Data for an in-game violation created by the game system itself. Changing the callback structure does not alter violation points, punishment, or the standard warning.

| Field | Type | Access | Description |
|---|---|:---:|---|
| `Kind` | [InGameViolationKind](#ingameviolationkind) | `get/set` | Violation type. |
| `Severity` | [InGameViolationSeverity](#ingameviolationseverity) | `get/set` | Violation severity. |
| `EventId` | int | `get/set` | Unique event ID. |

## ENotificationCode

| Value | Number | Meaning |
|---|---:|---|
| `None` | `0` | No active notification. |
| `GenericText` | `1` | Plain text. |
| `TimeoutActivated` | `2` | A timeout was activated. |
| `TimeoutLimitReached` | `3` | The timeout limit was reached. |
| `BridgeChargeDeployed` | `4` | The charge was planted. |
| `LastRound` | `5` | Last round of the match. |
| `LastRoundBeforeSwap` | `6` | Last round before the side switch. |
| `MatchPoint` | `7` | Match point. |
| `Victory` | `8` | Victory. |
| `Defeat` | `9` | Defeat. |
| `KillReward` | `10` | Kill reward. |
| `RoundWonReward` | `11` | Round-win reward. |
| `RoundLostReward` | `12` | Round-loss reward. |
| `BridgeChargePlantedReward` | `13` | Charge-plant reward. |
| `BridgeChargeDefusedReward` | `14` | Charge-defuse reward. |
| `SellItemReward` | `15` | Money returned for selling an item. |
| `TimeoutPendingActivation` | `16` | A timeout awaits the next round. |
| `WaitingForPlayers` | `17` | The game is waiting for players. |
| `MatchStarting` | `18` | The match is about to start. |
| `WarmupConsoleHint` | `19` | Custom-match console-start hint. |

## InGameViolationKind

| Value | Number | Meaning |
|---|---:|---|
| `None` | `0` | No violation. |
| `FriendlyDamage` | `1` | Damage dealt to an ally. |
| `FriendlyHelmetBreak` | `2` | An ally's protection was broken. |
| `FriendlyEmpHit` | `3` | An ally was hit by EMP. |
| `Afk` | `4` | The player did not leave the buy zone. |

## InGameViolationSeverity

| Value | Number | Meaning |
|---|---:|---|
| `None` | `0` | No severity assigned. |
| `Minor` | `1` | Minor violation. |
| `Moderate` | `2` | Moderate violation. |
| `Severe` | `3` | Severe violation. |

## PingController

Global API for ping markers.

The built-in `Default Ping Marks` module projects the world position across the full screen. An on-screen marker follows the world point, shows distance, and becomes translucent when obstructed. When the point is behind the camera or outside the viewport, the marker stays on the screen edge with a direction arrow.

### Quick example

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

Calls the callback when a ping is created and returns a cancellable [EventSubscription](../scheduler/#eventsubscription).

### SetPing

```lua
PingController:SetPing(position: Vector3)
```

Creates a ping at the specified world position. The call returns `nil` and emits an `OnPing` event.

The method does not perform a raycast or choose a surface automatically. Pass an already computed world point, such as `RaycastHit.Point` from [Physics.Raycast](../physics/#raycast). The standard visual marker requires the `Default Ping Marks` module to be enabled.

## PingEvent

Data for a created ping. Every field supports reading and assignment (`get/set`); assignment only changes the received event structure.

### Fields

| Field | Type | Access | Description |
|---|---|:---:|---|
| `Color` | Color | `get/set` | Ping marker color. |
| `ExpiresAtTick` | int | `get/set` | Tick on which the marker expires. |
| `MarkerType` | PingMarkerType | `get/set` | Ping marker type. |
| `Number` | int | `get/set` | Player number. |
| `PingIndex` | int | `get/set` | Sequential ping index. |
| `Position` | Vector3 | `get/set` | World position. |
| `TeamId` | int | `get/set` | Team ID. |

## PingMarkerType

| Value | Number | Meaning |
|---|---:|---|
| `Mine` | `0` | Local player's ping. |
| `Party` | `1` | Party member's ping. |
| `Ally` | `2` | Ally's ping. |

Related types: [Color](../color/), [Vector3](../vector3/), and [Team](../team/).
