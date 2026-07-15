---
title: Team
description: Team score, economy, and timeout state.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha. Every property and its availability in client and Reflex server contexts were confirmed in game.
:::

`Team` represents one side in a match. It cannot be constructed directly. Other APIs return it, including [`DefusalGame.BridgerFrontTeam`](../defusal-game/) and `DefusalGame.KillScriptCompanyTeam`.

```lua
local attackers = DefusalGame.BridgerFrontTeam

print("Rounds: " .. tostring(attackers.RoundWins))
print("Loss streak: " .. tostring(attackers.EconomyLossCount))
```

The API is available in both client Lua and a Reflex `server.lua`.

## Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `EconomyLossCount` | `int` | `get` | Current consecutive economy losses. |
| `RoundWins` | `int` | `get` | Rounds won by the team. |
| `TimeoutsTaken` | `int` | `get` | Timeouts used by the team. |

All three properties are read-only. Assigning to them ends the Lua call with an access error.

## Defusal sides

```lua
local attackers = DefusalGame.BridgerFrontTeam
local defenders = DefusalGame.KillScriptCompanyTeam

print(
    tostring(attackers.RoundWins)
        .. " : "
        .. tostring(defenders.RoundWins)
)
```

`BridgerFrontTeam` and `KillScriptCompanyTeam` refer to game sides, not necessarily a permanent set of players. Teams swap sides during the match.
