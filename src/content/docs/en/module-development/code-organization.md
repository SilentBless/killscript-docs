---
title: Organizing Lua code
description: Entry points, local state, update functions, and a safe module lifecycle.
---

KILLSCRIPT starts `scripts/main.lua` as the client entry point. A [Reflex module](../../reflex/architecture/) also starts `scripts/server.lua` separately. Structure each file around local state, small functions, and one initialization block.

## Basic main.lua structure

```lua
local State = {
    enabled = true,
    frames = 0
}

local function Update()
    State.frames = State.frames + 1

    if not State.enabled then
        return
    end

    ImGui:DrawDebugText(
        "Frames: " .. tostring(State.frames)
    )
end

local function Initialize()
    print("Module initialized")
    Scheduler:OnFrame(Update)
end

Initialize()
```

This order stays easy to scan:

1. state;
2. helpers;
3. handlers;
4. initialization at the end.

## Split client code into files

When `main.lua` becomes too large, split the client side across several Lua files. Every file must be placed directly under `scripts/`:

```text
MyModule/
└── scripts/
    ├── main.lua          # composition root and lifecycle
    ├── domain.lua        # rules and calculations
    ├── game_gateway.lua  # game API access
    └── hud.lua           # presentation
```

An additional file returns its public table:

```lua title="scripts/domain.lua"
local Domain = {}

function Domain.ClampHealth(value)
    return math.max(0, math.min(value, 100))
end

return Domain
```

Load it from `main.lua` by its name, without `.lua` or the `scripts/` prefix:

```lua title="scripts/main.lua"
local Domain = require("domain")

print(Domain.ClampHealth(125))
```

This supports a layered architecture without turning `main.lua` into one large file. A small module can stay in one file; extract a layer when it gains a distinct responsibility.

:::caution
The loader only discovers additional Lua files placed directly under `scripts/`. A nested file such as `scripts/domain/player.lua` and calls such as `require("domain.player")` or `require("domain/player")` do not work.
:::

Additional files belong to the client side only. The Reflex server receives a single [`scripts/server.lua`](../../reflex/architecture/). Keep server layers as local tables and functions in that file, or bundle several source files into one `server.lua` before packaging.

## Prefer local declarations

Use `local` unless a value intentionally needs to be global:

```lua
local PanelVisible = true

local function TogglePanel()
    PanelVisible = not PanelVisible
end
```

This prevents accidental name collisions and makes dependencies explicit.

## Check nil at API boundaries

Many methods, including methods on [`Agents`](../../api/agent/), legitimately return `nil` while an object is unavailable:

```lua
local localAgent = Agents:GetLocalAgent()

if localAgent == nil then
    return
end
```

Check immediately after retrieval, especially during map loading, death, spectating, and round transitions.

## Avoid expensive work every frame

[`Scheduler:OnFrame()`](../../api/scheduler/#onframe) follows the frame rate. Load [textures](../../api/texture/), [sounds](../../api/audio/), and [UXML](../../api/ui/) once during initialization; update only necessary values each frame.

```lua
local Icon = Textures:GetTexture("Icon.png")

Scheduler:OnFrame(function()
    if Icon ~= nil then
        ImGui:DrawTexture(Icon, Rect.new(20, 20, 64, 64))
    end
end)
```

## Account for hot reload

Saving a folder module creates a new Lua instance. Local variables do not survive. Keep persistent user data in [`Storage`](../../api/storage/) and settings in [`Config`](../../api/config/).

Keep references to objects that support explicit removal:

```lua
local Line = WorldVisuals:CreateLineRenderer()

WorldVisuals:RemoveObject(Line)
Line = nil
```

## Separate client and server

Do not duplicate the same update code across both Reflex entry points:

- `main.lua`: input, UI, local effects, and user data;
- `server.lua`: server decisions and `Scheduler:OnTick()`;
- [`Network`](../../api/network/): only required messages between them.

See the [Reflex architecture](../../reflex/architecture/) guide for the complete model.
