---
title: Server commands
description: Current KILLSCRIPT custom-server console commands and arguments.
---

Open the console with `~` and enter a command without an extra prefix. The console displays only commands permitted for the current player.

## Match control — Host

| Command | Purpose |
|---|---|
| `start` | Start the custom match from warmup. |
| `restart` | Reload the current map. |
| `reload` | Reload the game database or connected configuration. |
| `map-list` | List available technical map names. |
| `load-map <scene_name>` | Switch to a scene returned by `map-list`. |

Example:

```text
map-list
load-map Castle
```

Use the exact name returned by `map-list`.

## Agents and items — Host

| Command | Purpose |
|---|---|
| `list-agents` | List every match agent ID. |
| `heal [agent_id]` | Heal an agent, or your own when omitted. |
| `kill [agent_id]` | Kill an agent, or your own when omitted. |
| `kill-team <team_id>` | Kill all agents on a team. |
| `give-item <item_name>` | Give an item by its technical name. |

Examples:

```text
list-agents
heal 3
kill-team 2
give-item LightPistol
```

Use [GameConfig](../../api/game-config/) or current game content to find item names.

## Players — Host

| Command | Purpose |
|---|---|
| `list-players` | List connected player IDs. |
| `kick <player_id>` | Disconnect a player. |

Player IDs and agent IDs are different. Use `list-players` for `kick`, and `list-agents` for `heal` and `kill`.

## Personal and team commands

| Command | Purpose |
|---|---|
| `suicide` | Kill your own agent. |
| `spectate` | Toggle spectator mode. |
| `change-team` | Switch to the opposite team. |
| `change-agent <id>` | Move into an available agent by ID. |
| `version` | Show the server application version. |

Access to `spectate`, `change-team`, and `change-agent` depends on the match mode. The custom-server console shows what is actually permitted.

## When a command fails

- check spelling and argument count;
- retrieve a fresh ID through `list-agents` or `list-players`;
- verify that you are the host;
- use a result from `map-list` for scenes;
- inspect the command response and error filters in the console.

:::note
Diagnostic admin commands are intentionally omitted. They are unavailable to a normal server owner or inactive in release builds.
:::

See [custom server](../custom-server/) for session creation, permissions, and game-configuration setup.
