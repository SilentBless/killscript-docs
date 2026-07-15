---
title: Vibe coding basics
description: Use an AI coding assistant to build KILLSCRIPT modules and produce results you can verify.
---

Vibe coding is a collaborative workflow: you describe the desired behavior, and an AI helps design and write the module. It can accelerate development, but it does not replace documentation or in-game testing.

:::note[An intended game feature]
KILLSCRIPT modules run in the built-in Lua sandbox and use APIs provided by the game. Work that stays inside the documented API is ordinary game-module development.
:::

## What to delegate

- creating a regular or [Reflex module](../../reflex/architecture/);
- writing complete `module.json`, `config.json`, `inputs.json`, and Lua files;
- building HUDs with [ImGui or UXML](../../interface/choosing-ui/);
- handling input, settings, and [persistent data](../../module-development/data-and-input/);
- diagnosing an exact console error;
- making a small change to an already working module.

## Core principles

### Documentation is the source of truth

An assistant must not infer methods from Unity, C#, or generic Lua libraries. KILLSCRIPT has its own sandbox, separate client/server contexts, and explicit `get`/`set` restrictions. Use the [API reference](../../docs/) for exact signatures.

### Choose the context first

A regular module runs client-side `scripts/main.lua`. Reflex adds `scripts/server.lua`, but the server exposes a different API set. Start with a regular module unless server-side logic is required.

### Request complete files

“Return the complete contents of every changed file with its path” is more reliable than disconnected snippets. It makes the result easier to apply and review.

### Build one working capability at a time

Start with the smallest observable result: draw a HUD, handle an action, or read a value. Add settings, persistence, and polish only after it works.

### Test in the game

An AI cannot see your visual result, current match state, or console. Anything dependent on a map, input, item, or Reflex server must be confirmed manually.

### Return the exact error

Do not reduce feedback to “nothing happens.” Send the full module log, the expected behavior, and the actual result. This removes most guesswork.

## Start here

1. Open [Context for AI](../context/) and send the starter prompt.
2. Ask for the smallest useful version of your feature.
3. Apply the files and follow the [working loop](../workflow/).

If you have never run module code before, create [your first module](../../getting-started/first-module/) first.
