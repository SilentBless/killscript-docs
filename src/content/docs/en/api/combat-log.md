---
title: CombatLog
description: Damage dealt and received by the local player.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha using real incoming and outgoing damage events.
:::

`CombatLog` contains the local player's client-side hit history. It is available only in `main.lua`; the global `CombatLog` value is `nil` in a Reflex `server.lua`.

## How the log is populated

The server combat system first confirms a hit and its damage. When the client receives the processed result, the local combat log adds an outgoing or incoming entry. `CombatLog.Entries` only reads accumulated history and does not participate in hit calculation.

Use [`Agents:OnLocalPlayerDealtDamage()`](../agent/#onlocalplayerdealtdamage) or `OnLocalPlayerReceivedDamage()` to react at event time. The log is useful for later presentation and statistics; changing an entry does not alter health or server history.

## Example

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

The list may be empty until the local player deals or receives damage.

## Entries

```lua
local entries = CombatLog.Entries
```

| Property | Type | Access | Description |
|---|---|---|---|
| `Entries` | [`Array`](../array/)`<CombatLogEntry>` | `get` | Local player's combat-log entries. |

`Entries` is read-only. Access the latest entry with `entries[entries.Length]` after confirming that `Length > 0`.

## CombatLogEntry

| Property | Type | Access | Description |
|---|---|---|---|
| `BodyPart` | `EHitboxBodyPart` | `get` | Body part that was hit. |
| `Damage` | `number` | `get` | Damage amount. |
| `Distance` | `number` | `get` | Distance to the target at hit time. |
| `Instigator` | `Agent` | `get` | Attacking agent. |
| `IsFatal` | `bool` | `get` | Whether the hit was fatal. |
| `IsOutgoing` | `bool` | `get` | `true` for damage dealt by the local player. |
| `ItemId` | `int` | `get` | ID of the item or weapon used. |
| `Tick` | `int` | `get` | Event tick. |
| `Victim` | `Agent` | `get` | Agent that received the damage. |
| `WasShieldDestroyed` | `bool` | `get` | The hit destroyed a Kinetic Shield. |
| `WasStunned` | `bool` | `get` | The hit applied a stun. |

:::caution[Entries are read-only]
All 11 `CombatLogEntry` properties reject assignment. Do not rely on older references that mark these fields as `get/set`.
:::

`Instigator` and `Victim` may reference [`Agent`](../agent/) objects. Do not retain these references indefinitely: an agent may become unavailable after a player disconnects or the match changes state.
