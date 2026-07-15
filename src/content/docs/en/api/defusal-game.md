---
title: DefusalGame
description: Match, round, and BridgeCharge state in Defusal mode.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. Properties, execution contexts, and round history were confirmed in client and Reflex server Lua.
:::

`DefusalGame` is the global API for the current Defusal match. It exposes the round stage, remaining time, BridgeCharge state, score, and game sides.

Every property on `DefusalGame` itself is read-only.

## Current round state

```lua
local secondsLeft = Time.TickToSeconds(
    DefusalGame.StageRemainingTicks
)

print("Round: " .. tostring(DefusalGame.RoundId))
print("Stage: " .. tostring(DefusalGame.Stage))
print("Seconds left: " .. tostring(secondsLeft))
```

`DefusalGame` is available in client Lua and a Reflex `server.lua`. `IsVictory` is the exception: it is client-only because it depends on the local player's team.

## Properties

### BridgeCharge

| Property | Type | Access | Description |
|---|---|---|---|
| `BridgeChargeExplosionRemainingTicks` | `int` | `get` | Ticks remaining before the planted charge explodes. |
| `IsBridgeChargeDefused` | `bool` | `get` | The charge was defused in the current round. |
| `IsBridgeChargeExploded` | `bool` | `get` | The charge exploded in the current round. |
| `IsBridgeChargePlanted` | `bool` | `get` | The charge is planted. |

Convert the timer to seconds with [`Time.TickToSeconds()`](../time/):

```lua
local seconds = Time.TickToSeconds(
    DefusalGame.BridgeChargeExplosionRemainingTicks
)
```

### Match and round

| Property | Type | Access | Description |
|---|---|---|---|
| `IsGameEnded` | `bool` | `get` | The match has ended. |
| `IsOvertime` | `bool` | `get` | The match is in overtime rounds. |
| `IsRoundBeforeSwap` | `bool` | `get` | Teams will swap sides after this round. |
| `IsRoundTimeOver` | `bool` | `get` | Round time expired before the BridgeCharge was planted. |
| `IsTeamSwapping` | `bool` | `get` | A side swap is currently in progress. |
| `IsVictory` | `bool` | `get` | The local player's team won. Client-only. |
| `IsWarmupTimerActive` | `bool` | `get` | A waiting or start timer is active during warmup. |
| `RoundId` | `int` | `get` | Current round number. It may be `0` before game rounds begin. |
| `RoundWinnerTeam` | [`Team`](../team/) | `get` | Winning team, if one has been determined. |
| `Stage` | `EDefusalRoundStage` | `get` | Current round stage. |
| `StageRemainingTicks` | `int` | `get` | Ticks remaining in the current stage. |
| `WarmupRemainingTicks` | `int` | `get` | Ticks remaining on the warmup timer. |

### Game sides

| Property | Type | Access | Description |
|---|---|---|---|
| `BridgerFrontTeam` | [`Team`](../team/) | `get` | Attacking side. |
| `BridgerFrontTeamTexture` | [`Texture`](../texture/) | `get` | Attacking-side icon. |
| `KillScriptCompanyTeam` | [`Team`](../team/) | `get` | Defending side. |
| `KillScriptCompanyTeamTexture` | [`Texture`](../texture/) | `get` | Defending-side icon. |

## GetMatchRoundsLog

```lua
DefusalGame:GetMatchRoundsLog(): Array<DefusalRoundState>
```

Returns round-state history as an [`Array`](../array/). Like other API arrays, indexing starts at `1`.

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

A single round record from match history.

| Field | Type | Access | Description |
|---|---|---|---|
| `IsBridgeChargeDefused` | `bool` | `get/set` | The BridgeCharge was defused. |
| `IsBridgeChargeExploded` | `bool` | `get/set` | The BridgeCharge exploded. |
| `IsBridgeChargePlanted` | `bool` | `get/set` | The BridgeCharge was planted. |
| `IsRoundTimeOver` | `bool` | `get/set` | Time expired before the charge was planted. |
| `IsTeamSwapping` | `bool` | `get/set` | The record represents a side swap. |
| `RoundId` | `int` | `get/set` | Round number. |
| `RoundWinnerTeam` | [`Team`](../team/) | `get/set` | Winning team. |
| `Stage` | `EDefusalRoundStage` | `get/set` | Round stage. |

The Lua API accepts assignment to these fields. Treat the object as a data record: changing the returned value is not a server command and does not change the match result.

## EDefusalRoundStage

| Value | Code | Description |
|---|---:|---|
| `None` | `0` | No active stage. |
| `Buy` | `1` | Buy stage. |
| `Fight` | `2` | Main combat stage. |
| `End` | `3` | End-of-round stage. |

When converted to text, an enum value includes its name and code, such as `Fight: 2`. Compare it to the numeric code:

```lua
local FIGHT_STAGE = 2

if DefusalGame.Stage == FIGHT_STAGE then
    -- The round is in its combat stage
end
```

## server.lua context

A Reflex server exposes every listed property except `IsVictory`. Reading `DefusalGame.IsVictory` there ends the current Lua call with an access error; it cannot be safely probed with an ordinary comparison to `nil`.
