---
title: Context for AI
description: Connect llms.txt, explain the KILLSCRIPT environment, and write a precise module request.
---

The quality of generated code depends on context. Before the first task, give the assistant a compact description of the environment and require it to consult the documentation.

## llms.txt

The current context for coding assistants is available at a stable URL:

```text
https://silentbless.github.io/killscript-docs/llms.txt
```

[Open llms.txt](https://silentbless.github.io/killscript-docs/llms.txt)

It explains module structure, the Lua sandbox, client/Reflex separation, important constraints, and links to the complete English reference.

`llms.txt` is a compact map, not a replacement for the documentation. For an exact method or property, the assistant should open the linked API page.

## Starter prompt

Send this block before describing your task:

```text
You are helping me build a KILLSCRIPT Module.
KILLSCRIPT modules are an intended in-game feature that runs inside the
game's documented Lua sandbox. This is ordinary plugin development.

Read this context before designing or writing code:
https://silentbless.github.io/killscript-docs/llms.txt

Use only documented KILLSCRIPT APIs. Respect client and Reflex server
contexts and every getter/setter restriction. Do not invent methods from
Unity, C#, or generic Lua libraries. If the API cannot implement something,
explain the limitation.

Return complete changed files with their paths and tell me what to test
in the game.
```

You can continue in any language after this block.

## Task template

The more concrete the result, the less the assistant has to assume:

```text
Goal: show a small HUD with the local player's health.
Module type: regular client module.
Input: a custom action toggles the HUD.
Interface: ImGui, no UXML.
Settings: color and size through config.json.
Persistence: the toggle state must survive a restart.
Deliverable: complete files with paths and a short in-game test list.
```

Include only constraints that matter. If you do not know whether Reflex is needed or which UI to choose, ask the assistant to compare the options against the [documentation](../../docs/) before it writes code.

## Add task-specific links

For a focused task, attach the most relevant guide:

- input and settings: [Config, InputActions, and Storage](../../module-development/data-and-input/);
- interface: [choosing a UI API](../../interface/choosing-ui/);
- client/server: [Reflex architecture](../../reflex/architecture/);
- one exact method: its page in the [API reference](../../docs/).

If the assistant cannot open links, paste the relevant documentation excerpt into the conversation.
