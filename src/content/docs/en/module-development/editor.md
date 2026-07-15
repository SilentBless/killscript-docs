---
title: Editor and API completion
description: Set up an editor for a KILLSCRIPT folder module and use the bundled Lua API definitions.
---

A folder module can be edited in any text editor. Visual Studio Code with Lua support is the most convenient option because the game creates project settings and connects KILLSCRIPT API definitions.

## Open the project

The module menu provides two useful actions:

- **Folder** opens the module directory;
- **VS Code** opens that directory as an editor workspace.

Open the module root, not only `main.lua`:

```text
Modules/
└── MyModule/       ← open this directory
    ├── module.json
    ├── scripts/
    └── .vscode/
```

This lets the editor see `.vscode/settings.json`, assets, and all project entry points.

## Where completion comes from

The game stores Lua API definitions in `ModuleAPI` next to the executable. The generated module settings add the appropriate language directory to the Lua workspace library.

After opening the project, the editor should complete globals such as [`Agents`](../../api/agent/), [`Scheduler`](../../api/scheduler/), and [`ImGui`](../../api/imgui/) and their members.

If completion is missing:

1. verify that Lua support is installed;
2. open the module root containing `.vscode`;
3. verify that `ModuleAPI` exists in the current game installation;
4. restart the Lua language server or editor window.

## Diagnostics do not change runtime access

Editor completion shows a known signature but does not change execution context. `Scheduler:OnTick()` remains a Reflex server method even if the editor suggests it in `main.lua`.

Use the [API reference](../../api/array/) for runtime context, `get`/`set` access, and limitations.

## Useful project settings

- save files as UTF-8;
- use indentation consistently;
- avoid formatters that rewrite JSON into an invalid shape;
- over a network share, avoid extensions that hold files open during saves.

:::tip
Save a minimal `print("loaded")` first and confirm hot reload. It is easier to separate editor setup from future code errors.
:::

Continue with the [development and debugging workflow](../../getting-started/workflow/) and [organizing Lua code](../code-organization/).
