---
title: Custom server
description: Create a custom server, invite players, and use it as a safe module-development environment.
---

A custom server is ideal for development: you can choose a map, restart the match, and test [Reflex](../../reflex/architecture/) without matchmaking.

## Create one

1. Open the custom-server section from the main menu.
2. Optionally provide a link to a custom game configuration.
3. Create the server and wait for the connection.
4. Open the pause menu to copy its invite code.
5. Share the code only with participants you trust.

Lua modules start after the game session is loaded.

## Permissions

Server commands have access levels:

- **Anybody**: general commands;
- **Host**: the custom-server owner;
- **Admin**: internal administrative and diagnostic commands.

The console exposes only commands allowed for the current player and match mode. A matchmaking session may therefore show a different set.

## Module workflow

1. enable the regular module you need;
2. select one Reflex module when required;
3. create the server;
4. open the `~` console and select the module filter;
5. save source files and wait for hot reload;
6. use round-management commands for a repeatable scenario.

Inspect the module log for messages from both sides when testing client/server exchange.

## Custom configuration

The creation UI accepts a game-configuration link. A configuration can alter items, global constants, and mechanic flags.

After changing a connected configuration, run:

```text
reload
```

This reloads the server game database. A particular parameter may still require a map or round restart.

Current parameter names are available through [GameConfig](../../api/game-config/). Do not use an old configuration sheet that does not match the current game build.

## Minimal testing sequence

```text
map-list
restart
start
```

- `map-list` prints available technical map names;
- `restart` reloads the current map and returns to warmup;
- `start` starts the match from warmup.

See [server commands](../commands/) for the complete user-facing list.
