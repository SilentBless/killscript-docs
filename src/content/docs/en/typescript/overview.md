---
title: Developing with TypeScript
description: An experimental community toolchain for developing KILLSCRIPT modules in TypeScript.
---

:::caution[For advanced users]
The TypeScript toolchain is a third-party community project, not a built-in or official way to use the KILLSCRIPT API. It is under active development and may lag behind game updates. The native Lua documentation on this site remains the source of truth.
:::

Choose this path after you understand the [structure of regular and Reflex modules](../../getting-started/overview/) and want types, completion, a multi-file project, and error checking before the game starts. Lua is the simpler route for a first module.

## How it works

You write the client and server parts in TypeScript. The community compiler:

1. checks API availability for the client and Reflex server;
2. bundles imported files and transpiles them to Lua;
3. creates the required `config.json`, `inputs.json`, and entry points;
4. synchronizes a folder module for hot reload or builds a `.KillScript` package.

The game still runs a regular Lua module. The toolchain grants no additional permissions and bypasses no API restrictions: client code remains client-side, while server logic still requires Reflex.

```text
TypeScript → validation and build → scripts/main.lua + scripts/server.lua → KILLSCRIPT
```

## Small example

A key binding can live next to the code that consumes it:

```ts
import { Keyboard, defineControls } from "@killscript/sdk/client";

const controls = defineControls("hello", {
  showMessage: Keyboard.F6,
});

controls.showMessage.onPressed(() => {
  NotificationController.ShowHint("Hello from TypeScript", 2);
});
```

During the build, the declaration becomes part of the game's input configuration and the callback becomes generated `scripts/main.lua` code. The result uses the same [`NotificationController`](../../api/notification/) as a module written directly in Lua.

## Continue with the toolchain

Installation, the CLI, project architecture, SDK wrappers, and limitations live in the separate [KILLSCRIPT TypeScript SDK documentation](https://silentbless.github.io/killscript/guides/getting-started/).

The toolchain source is available in the [killscript repository](https://github.com/SilentBless/killscript). Before updating dependencies, read the documentation for the selected version and test the result in the game.
