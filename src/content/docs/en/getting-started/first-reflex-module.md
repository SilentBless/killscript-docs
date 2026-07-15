---
title: Your first Reflex module
description: Create a Reflex module, separate client and server code, and exchange data through Network.
---

A [Reflex module](../../reflex/architecture/) has two sides:

- `scripts/main.lua` runs on the player's client;
- `scripts/server.lua` runs in that player's server context.

They expose different API sets and exchange Lua tables through [`Network`](../../api/network/).

:::note
Only one Reflex module can be active at a time. Use a regular module for HUD, UI, and any other fully local behavior.
:::

## 1. Create the project

1. Open the module menu and select **Create**.
2. Name the module `HelloReflex`.
3. Enable **Is Reflex**.
4. Confirm creation and select this Reflex module as active.
5. Start a custom game session.

The project directory should contain both entry points:

```text
HelloReflex/
├── module.json
└── scripts/
    ├── main.lua
    └── server.lua
```

## 2. Add the client code

Open `scripts/main.lua`:

```lua title="scripts/main.lua"
Network:OnTableReceived(function(data)
    if data.kind == "server_tick" then
        print("Server tick: " .. tostring(data.tick))
    end
end)

Network:SendTable({
    kind = "get_server_tick"
})
```

The client registers its response handler and then sends a request to the server side of the same module.

## 3. Add the server code

Open `scripts/server.lua`:

```lua title="scripts/server.lua"
Network:OnTableReceived(function(data)
    if data.kind == "get_server_tick" then
        Network:SendTable({
            kind = "server_tick",
            tick = Time.Tick
        })
    end
end)
```

The server checks the message type and sends its current tick back. Once both sides are loaded, the client console shows `Server tick: ...`.

If no response appears immediately after hot reload, save `main.lua` once more. The client request must be sent after the server side is ready.

## API contexts

Do not move client code into `server.lua` without checking the reference.

| Capability | `main.lua` | `server.lua` |
|---|:---:|:---:|
| [`ImGui`](../../api/imgui/), [`UI`](../../api/ui/), [`Cameras`](../../api/camera/) | ✅ | ❌ |
| `Scheduler:OnFrame()` | ✅ | ❌ |
| `Scheduler:OnTick()` | ❌ | ✅ |
| `Network` | ✅ | ✅ |
| Server game API methods | Limited | ✅ |

API pages mark client and server members separately.

## Data supported by Network

Strings, numbers, booleans, and nested Lua tables can be sent. Functions and API objects such as [`Agent`](../../api/agent/) or [`Vector3`](../../api/vector3/) are not serialized.

Send compound values as numbers:

```lua
Network:SendTable({
    position = {
        x = position.x,
        y = position.y,
        z = position.z
    }
})
```

## Server-logic rules

- check a message-type field such as `kind`;
- validate the range and meaning of every client value;
- do not trust data merely because it arrived through `Network`;
- do not call client APIs from `server.lua`;
- use `Scheduler:OnTick()` for repeating server work.

Continue with [Network](../../api/network/), [Scheduler](../../api/scheduler/), and the reference pages for the game objects you need.
