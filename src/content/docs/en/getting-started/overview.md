---
title: Module overview
description: What KILLSCRIPT modules are, how regular and Reflex modules differ, and where to start.
---

A module is a Lua program that runs inside KILLSCRIPT and uses the game API. It can add a HUD, change how information is presented, process input, or implement custom gameplay logic.

User modules live in the `Modules` directory at the game root:

```text
KILLSCRIPT Pre-Alpha/
└── Modules/
    └── MyModule/
```

## Regular and Reflex modules

| | Regular module | Reflex module |
|---|---|---|
| Client code | `scripts/main.lua` | `scripts/main.lua` |
| Server code | — | `scripts/server.lua` |
| Main use | HUD, UI, cameras, and local effects | Logic that requires the server context |
| Concurrent modules | Multiple modules | Only one active Reflex module |

Choose a regular module for your first project. [Reflex](../../reflex/architecture/) is needed only when part of the logic must run on the server. The client and server expose different API sets; each reference page marks the context of its members.

## Folder and .KillScript file

KILLSCRIPT supports two module representations:

- a **folder** is an editable source project under `Modules/MyModule/`;
- a **`.KillScript` file** is a ready-to-import single-file package for distribution.

A `.KillScript` file is not an individual Lua script and should not replace your project directory. Develop in a folder and install downloaded `.KillScript` files through **Import**.

## What you need

- KILLSCRIPT installed;
- any text editor;
- a basic understanding of Lua tables, functions, and conditions.

Visual Studio Code with Lua support is a convenient choice. When the game creates a folder module, it also writes workspace settings for the API definitions under `ModuleAPI`.

## Recommended path

1. [Create your first module](../first-module/) and confirm that its log and on-screen text appear.
2. Learn the [module structure](../module-structure/).
3. Set up a fast [development and debugging workflow](../workflow/).
4. Use the [API reference](../../api/array/) while building features.
5. Read about [imports and packages](../packages/) when you need to install or share a finished module.

:::tip
Start with a minimal `main.lua` and add one capability at a time. This keeps failures close to the most recent change.
:::
