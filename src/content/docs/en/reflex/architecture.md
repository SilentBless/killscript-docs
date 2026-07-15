---
title: Reflex architecture
description: Reflex lifecycle, client/server contexts, and boundaries of responsibility.
---

A Reflex module adds a server entry point to a regular client `main.lua`. Both sides belong to one module but run independently and receive different APIs.

```text
ReflexModule/
├── module.json          # IsReflex: true
└── scripts/
    ├── main.lua         # client
    └── server.lua       # player's server context
```

## Responsibilities

### main.lua

- reads `InputActions`;
- builds ImGui and UXML;
- uses local cameras, audio, and graphics;
- stores local data in `Storage`;
- sends user intent and settings to the server.

### server.lua

- runs work through `Scheduler:OnTick()`;
- reads authoritative game objects;
- invokes Reflex-server-only methods;
- validates client messages;
- sends only display data required by the client.

## The Network boundary

The two sides do not share Lua tables or globals. [`Network`](../../api/network/) is their direct channel.

```text
main.lua  ── SendTable ──▶  server.lua
main.lua  ◀─ SendTable ──  server.lua
```

Messages are serialized, so only strings, numbers, booleans, and nested tables cross the boundary. API objects do not.

## Do not route decisions through the client

When a decision can be derived from state available to the server, keep the complete loop in `server.lua`:

```text
server state → server decision → server action
                              └→ client presentation
```

The `server state → client decision → server action` path adds a network round trip. The original state may already be stale when the command returns. This matters for movement, simulated button state, server-side look direction, aim targets, firing, and other tick-sensitive behavior.

[`InputActions`](../../api/input-action/) are client-only, so a custom binding may send a mode activation, deactivation, or setting change to the server. After that, keep observation, timing, and supported mutations through [`AgentInput` and `Aim`](../../api/agent/#agentinput) on the server. Do not stream commands every frame when one mode-state message is sufficient.

Send only the result required for UI, cameras, audio, or other local feedback back to the client. The server must not wait for client confirmation when it can make the decision itself.

:::caution
If the required read or mutation is unavailable in the Reflex server API, a client-side implementation is not an equivalent substitute. State the limitation and choose a different design.
:::

## Lifecycle

1. The user enables and selects a Reflex module.
2. Its client side starts in a game session.
3. The server starts `server.lua` for that player.
4. Both sides register callbacks and exchange messages.
5. Hot reload replaces the previous instance.

Do not depend on the order of the first messages. Register `OnTableReceived()` before `SendTable()` and resend initial state after a short delay when necessary.

## One Reflex module

Only one Reflex module can be active at a time. This rule is independent from regular functional tags.

## Context matters

| API | Client | Reflex server |
|---|:---:|:---:|
| [`InputActions`](../../api/input-action/), [`Storage`](../../api/storage/), [`Localization`](../../api/localization/) | ✅ | ❌ |
| [`ImGui`](../../api/imgui/), [`UI`](../../api/ui/), [`Cameras`](../../api/camera/), [`Textures`](../../api/texture/) | ✅ | ❌ |
| [`Scheduler:OnFrame()`](../../api/scheduler/#onframe) | ✅ | ❌ |
| [`Scheduler:OnTick()`](../../api/scheduler/#ontick) | ❌ | ✅ |
| [`Network`](../../api/network/), [`Time`](../../api/time/), [`Agents`](../../api/agent/) | ✅ | ✅ |

Individual objects may expose different properties too. Always check context labels in the API reference.

## Core principle

The client reports **what the user intends**; the server decides **whether it is allowed and what the valid result is**. Do not move a server decision to the client merely for UI convenience.

Continue with the [Network protocol](../network-protocol/) and [server loop](../server-loop/).
