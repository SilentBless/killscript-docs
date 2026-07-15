---
title: Working loop
description: Build, test, and correct a generated module through small iterations.
---

Reliable vibe coding uses a short loop: one task, complete files, an in-game test, and exact feedback.

## 1. Start with a minimal result

Split the idea into vertical steps. For a configurable HUD, that could be:

1. draw a static block;
2. insert local-player data;
3. add an input action;
4. add settings;
5. persist the state;
6. polish the presentation.

Every step should run on its own. A large module produced in one request is harder to inspect and repair.

## 2. Get complete files

Confirm that the answer includes paths and the full contents of every changed file. The standard layout is documented under [Module structure](../../getting-started/module-structure/).

Do not add `server.lua` “just in case.” It belongs only in a [Reflex module](../../reflex/architecture/).

## 3. Apply and run

Put the files in a folder project under `Modules`. The game hot reloads the changed module; console filters and the complete loop are covered under [Development and debugging](../../getting-started/workflow/).

Test more than the absence of errors:

- did the expected UI appear;
- does the action trigger at the correct time;
- does state survive disabling and reopening the module;
- is missing local-player or object state handled safely;
- do client and Reflex server behavior match the task.

## 4. Report the result without paraphrasing

Use a compact feedback format:

```text
Context: regular module running on Castle.
Expected: pressing F8 once hides the HUD.
Actual: the HUD remains visible.
Console: [paste the complete module log]
Changed files: scripts/main.lua, inputs.json.
```

Keep file names and line numbers intact. If there is no error, describe the observable behavior and the exact actions that led to it.

## 5. Do not fix one guess with another

If a property is inaccessible or a method is missing, consult its API page first. The correct conclusion may be that a feature is unavailable in that context or requires a different architecture.

Pay particular attention to:

- client and Reflex server availability;
- `get` and `get/set` annotations;
- `nil` before a player, item, or interface exists;
- one-based API [Array](../../api/array/) indexing;
- standard-library functions allowed by the Lua sandbox;
- subscription lifecycle and hot reload.

## 6. Save a working checkpoint

After a successful step, save the working version or create a Git commit. Start the next change from verified code so a failed iteration is easy to undo.

:::tip
Ask the assistant to end each response with its assumptions and concrete in-game checks. Hidden dependencies then become visible before the next iteration.
:::
