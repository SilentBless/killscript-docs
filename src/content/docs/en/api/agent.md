---
title: Agent
description: Agents, aim, health, movement, input, and damage events.
---

:::note[Verified in game]
This page only documents properties and methods available in the current build with confirmed access behavior.
:::

`Agent` combines player state including health, aim, movement, inventory, and stats. All `Agent` and nested API properties are read-only; event structures and `AgentStats` fields are the exceptions.

## How data flows

Server simulation owns an agent's health, movement, inventory, aim, and stats. Reflex `server.lua` wrappers read that state on the server; `main.lua` reads its replicated client copy and local presentation data. Visibility restrictions may hide some information about an enemy.

`Agent`, `Health`, `Movement`, `Inventory`, `Aim`, and the other nested objects access an existing agent; they are not separate character copies. A retained reference may become unavailable after death, a round transition, or disconnect, so long-running code should reacquire the agent through `Agents`.

`HitEvent`, `DamageEvent`, `DeathEvent`, and `AgentStats` pass Lua a snapshot of a result that has already been calculated. Assigning their fields only changes the received Lua value; it does not rewrite damage, death, or the scoreboard.

## What changes visually

- On success, `Agent:TrySpectate()` switches the main view and standard spectator HUD to the selected agent.
- `AgentInput:SetLookRotation()` changes the local agent's look direction; it does not create a separate [camera](../camera/).
- On the client, `SetMoveDirection()` and `SetButtonState()` change the local agent's pending input; the methods do not show UI or a notification themselves. The temporary Reflex server bug documented below still applies.
- `Aim:SetAimTarget()` and `ResetAimTarget()` change server-side aim-target state. They do not draw a target marker—use separate [UI](../ui/) or [WorldVisuals](../world-visuals/) for that.

Setter methods return `nil`. Verify an available getter after a command instead of expecting on-screen confirmation.

## Quick example

```lua
local localAgent = Agents:GetLocalAgent()

if localAgent ~= nil then
    print(localAgent.Nickname)
    print("HP: " .. tostring(localAgent.Health.CurrentHealth))
    print("Position: " .. tostring(localAgent.Movement.Position))
end
```

## Agent

Represents an agent in the game. This class provides access to various properties and methods related to the agent, such as movement, health, inventory, and more.

**Base:** [Entity](../entity/#entity)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `Aim` | [Aim](../agent/#aim) | `get` | Access to the agent aiming API. |
| `Avatar` | [Texture](../texture/) | `get` | <span class="api-context api-context--client">Client only</span> Agent avatar. Returns the player's avatar or the team icon. |
| `AvatarIsTeamPlaceholder` | bool | `get` | <span class="api-context api-context--client">Client only</span> Returns true if Avatar is currently the team placeholder icon instead of the player's real avatar. |
| `Color` | Color | `get` | Returns the color assigned to the agent. |
| `Health` | [Health](../agent/#health) | `get` | Access to the agent health API. |
| `Interactor` | [Interactor](../agent/#interactor) | `get` | Access to the agent interaction API. |
| `Inventory` | [Inventory](../agent/#inventory) | `get` | Access to the agent inventory API. |
| `IsSpectated` | bool | `get` | <span class="api-context api-context--client">Client only</span> true if this agent is being spectated (when the local agent is dead or in spectator mode). |
| `Movement` | [Movement](../agent/#movement) | `get` | Access to the agent movement API. |
| `Nickname` | string | `get` | Player nickname. |
| `Number` | int | `get` | Returns the number assigned to the agent. |
| `OcclusionCulling` | [OcclusionCulling](../agent/#occlusionculling) | `get` | Access to the agent occlusion/visibility API. |
| `Stats` | [AgentStats](../agent/#agentstats) | `get` | Agent stats, always available. |
| `Team` | [Team](../team/) | `get` | Team the agent belongs to. |


### Methods

#### GetHitboxes

```lua
Agent:GetHitboxes(): Array<Hitbox>
```

Returns the agent's hitboxes.

**Returns:** Array<[Hitbox](../agent/#hitbox)>

#### TrySpectate

```lua
Agent:TrySpectate(): bool
```

<span class="api-context api-context--client">Client only</span> Switches spectating to this agent if allowed by the current spectator mode.

**Returns:** bool

## AgentInput

Available in client and Reflex server. Global API for reading input state and controlling the local agent.

:::caution[Temporary Reflex server bug]
In the current build, the `AgentInput:SetButtonState()`, `SetMoveDirection()`, and `SetLookRotation()` setters in `server.lua` change the Lua-visible state but do not apply input to the actually controlled agent. The `AgentInput` getters continue to work. The issue has been reported to the developer and will be fixed in a future build. Until then, do not rely on these setters for server-side input control.
:::

### Methods

#### GetLookRotation

```lua
AgentInput:GetLookRotation(): Vector2
```

Returns the current look rotation of the local agent in degrees (X = pitch, Y = yaw).

**Returns:** Vector2

#### GetMoveDirection

```lua
AgentInput:GetMoveDirection(): Vector2
```

Returns the current movement direction of the local agent.

**Returns:** Vector2

#### IsButtonDown

```lua
AgentInput:IsButtonDown(inputButton: EInputButton): bool
```

true if the input button is being held by the local agent.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `inputButton` | [EInputButton](../agent/#einputbutton) |  | Button to check. |

**Returns:** bool

#### IsJustPressed

```lua
AgentInput:IsJustPressed(inputButton: EInputButton): bool
```

true if the button was pressed by the local agent on this tick.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `inputButton` | [EInputButton](../agent/#einputbutton) |  | Button whose press is checked on the current tick. |

**Returns:** bool

#### SetButtonState

```lua
AgentInput:SetButtonState(inputButton: EInputButton, down: bool)
```

Sets the local agent's input button state (pressed/released).

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `inputButton` | [EInputButton](../agent/#einputbutton) |  | Button to change. |
| `down` | bool |  | `true` to press it, `false` to release it. |

#### SetLookRotation

```lua
AgentInput:SetLookRotation(vector: Vector2)
```

Sets the local agent's absolute look rotation in degrees (X = pitch, Y = yaw).

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `vector` | Vector2 |  |  |

#### SetMoveDirection

```lua
AgentInput:SetMoveDirection(vector: Vector2)
```

Sets the local agent's movement vector in input axes (X = left/right, Y = forward/back).

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `vector` | Vector2 |  |  |

## Agents

Agent listing and events API.

### Methods

#### GetAll

```lua
Agents:GetAll(): Array<Agent>
```

Returns all agents in the match.

**Returns:** Array<[Agent](../agent/#agent)>

#### GetAllies

```lua
Agents:GetAllies(): Array<Agent>
```

Returns all allied agents relative to the local team.

**Returns:** Array<[Agent](../agent/#agent)>

#### GetEnemies

```lua
Agents:GetEnemies(): Array<Agent>
```

Returns all enemy agents relative to the local team.

**Returns:** Array<[Agent](../agent/#agent)>

#### GetLocalAgent

```lua
Agents:GetLocalAgent(): Agent
```

Returns the local player's agent, or nil if the local agent is currently unavailable.

**Returns:** [Agent](../agent/#agent)

#### GetLocalOrSpectatedAgent

```lua
Agents:GetLocalOrSpectatedAgent(): Agent
```

Returns the local player's agent or the spectated agent, or nil if no such agent currently exists.

**Returns:** [Agent](../agent/#agent)

### Combat events

All three events are client-only and return an [`EventSubscription`](../scheduler/#eventsubscription) that can be cancelled with `Cancel()`.

```lua
local deaths = Agents:OnDeath(function(event)
    print(event.Killer .. " eliminated " .. event.Victim)
end)

local dealt = Agents:OnLocalPlayerDealtDamage(function(event)
    print("Dealt: " .. tostring(event.Damage))
end)

local received = Agents:OnLocalPlayerReceivedDamage(function(event)
    print("Received: " .. tostring(event.Damage))
end)
```

#### OnDeath

```lua
Agents:OnDeath(callback: LuaFunction): EventSubscription
```

<span class="api-context api-context--client">Client only</span> Calls the callback with a [`DeathEvent`](../agent/#deathevent) when an agent dies.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `callback` | LuaFunction |  | Function that receives a `DeathEvent`. |

**Returns:** [EventSubscription](../scheduler/#eventsubscription)

#### OnLocalPlayerDealtDamage

```lua
Agents:OnLocalPlayerDealtDamage(callback: LuaFunction): EventSubscription
```

<span class="api-context api-context--client">Client only</span> Calls the callback when the local player deals damage. Returns a subscription that can be cancelled.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `callback` | LuaFunction |  | Function that receives a `HitEvent`. |

**Returns:** [EventSubscription](../scheduler/#eventsubscription)

#### OnLocalPlayerReceivedDamage

```lua
Agents:OnLocalPlayerReceivedDamage(callback: LuaFunction): EventSubscription
```

<span class="api-context api-context--client">Client only</span> Calls the callback when the local player takes damage. The event includes stun information if this damage applied a stun. Returns a subscription that can be cancelled.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `callback` | LuaFunction |  | Function that receives a `DamageEvent`. |

**Returns:** [EventSubscription](../scheduler/#eventsubscription)

## AgentStats

General agent statistics. All nine fields support reading and assignment (`get/set`). Changing the local object is not a server command.

### Fields

| Field | Type | Access | Description |
|---|---|:---:|---|
| `Assists` | int | `get/set` | Number of assists. |
| `Damage` | number | `get/set` | Total damage dealt. |
| `DeathTick` | int | `get/set` | Simulation tick when the agent died. |
| `Deaths` | int | `get/set` | Number of deaths. |
| `IsAlive` | bool | `get/set` | true if alive. |
| `IsConnected` | bool | `get/set` | true if connected. |
| `Kills` | int | `get/set` | Number of kills. |
| `Money` | int | `get/set` | Number of credits. This field is known only for the allied team, for all other teams it is 0. |
| `Ping` | int | `get/set` | Average ping in milliseconds based on recent measurements. |

## Aim

Access to the agent aiming system. Handles the current aim direction, aim spread, and stun.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `AccumulatedUncertainty` | number | `get` | <span class="api-context api-context--local">Local agent</span> Accumulated aiming inaccuracy caused by aim direction changes and other sources. |
| `AimingDownSightsProgress` | number | `get` | Aiming progress (ADS) from 0 to 1. |
| `Direction` | Vector3 | `get` | Current aim direction in world coordinates. |
| `DirectionViewportPoint` | Vector3 | `get` | <span class="api-context api-context--client">Client only</span> <span class="api-context api-context--local">Local agent</span> Viewport coordinates of the aim direction position for UI rendering. |
| `IsAimingDownSights` | bool | `get` | true if the agent is currently aiming (ADS). |
| `IsStunned` | bool | `get` | true if the agent is currently stunned. |
| `IsStunnedVisually` | bool | `get` | true if the stun visual effect is currently active for the agent. Remains active longer than IsStunned so the effect from a short stun does not disappear completely on high ping when the client learns about the stun after it has already ended. |
| `LastStunDuration` | number | `get` | <span class="api-context api-context--local">Local agent</span> Duration of the last stun in seconds. |
| `MovementSpeedUncertainty` | number | `get` | <span class="api-context api-context--local">Local agent</span> Inaccuracy caused by movement speed. |
| `Position` | Vector3 | `get` | World position of the camera used for aiming and shooting. |
| `StunnedUntilTick` | int | `get` | Simulation tick until which the stun remains active. |
| `StunnedVisuallyUntilTick` | int | `get` | Simulation tick until which the stun visual effect remains active. Usually equals StunnedUntilTick plus the network latency in ticks, so the effect from a short stun does not disappear completely on high ping when the client learns about the stun after it has already ended. |
| `Target` | [Agent](../agent/#agent) | `get` | <span class="api-context api-context--local">Local agent</span> Aim target. Returns nil if no target is selected or the target agent is no longer available. |
| `TargetPosition` | Vector3 | `get` | Current aim point in world coordinates. |
| `TotalUncertainty` | number | `get` | <span class="api-context api-context--local">Local agent</span> Sum of accumulated inaccuracy and movement inaccuracy. |


### Methods

#### ResetAimTarget

```lua
Aim:ResetAimTarget()
```

<span class="api-context api-context--server">Reflex server only</span> <span class="api-context api-context--local">Local agent</span> Resets the aim target.

#### SetAimTarget

```lua
Aim:SetAimTarget(targetPosition: Vector3, agent: Agent)
```

<span class="api-context api-context--server">Reflex server only</span> <span class="api-context api-context--local">Local agent</span> Sets the aim target and position.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `targetPosition` | Vector3 |  |  |
| `agent` | [Agent](../agent/#agent) |  |  |

## DamageEvent

Damage received event. The game applies damage first and then passes this structure to `OnLocalPlayerReceivedDamage()`. Every field supports reading and assignment (`get/set`), but changing the structure does not change damage that was already applied.

### Fields

| Field | Type | Access | Description |
|---|---|:---:|---|
| `Damage` | number | `get/set` | Damage taken. |
| `DamageDirection` | Vector3 | `get/set` | Damage direction: from the point where the damage was received to the attack source. |
| `DamageDirectionFromHead` | Vector3 | `get/set` | Damage direction: from the head to the attack source. |
| `DamagePosition` | Vector3 | `get/set` | Point where the damage was received, relative to the agent's position. |
| `DamageTick` | int | `get/set` | Tick on which the damage was observed. |
| `StunnedUntilTick` | int | `get/set` | Tick until which the stun remains active. Equals 0 if this damage did not apply a stun. |
| `WasStunned` | bool | `get/set` | true if this damage applied a stun. |

## DeathEvent

Agent death event passed to `Agents:OnDeath()` after the game processes the death. Every field supports reading and assignment (`get/set`); changing values does not cancel the death or alter the kill feed.

### Fields

| Field | Type | Access | Description |
|---|---|:---:|---|
| `IsCritical` | bool | `get/set` | true if the kill was critical. |
| `Killer` | string | `get/set` | Killer name. |
| `Victim` | string | `get/set` | Name of the agent who died. |
| `WeaponId` | int | `get/set` | ID of the weapon used for the kill. |

## EHitboxBodyPart

Agent hitbox body part.

| Name | Value | Comment |
|---|---:|---|
| `None` | `0` | No body part. |
| `Head` | `1` | Head. |
| `Body` | `2` | Body. |
| `Arm` | `3` | Arm. |
| `Leg` | `4` | Leg. |

## EHitType

Hit type.

| Name | Value | Comment |
|---|---:|---|
| `None` | `0` | No hit. |
| `Regular` | `1` | Regular hit. |
| `Critical` | `2` | Critical hit. |
| `Fatal` | `3` | Fatal hit. |
| `FriendlyFire` | `4` | Friendly fire damage. |
| `KineticShield` | `5` | Kinetic Shield hit. |
| `Stunned` | `6` | Stunning damage. |

## EInputButton

Game input buttons accepted by `AgentInput`. Numeric codes can be passed directly, but named values are easier to read and maintain.

| Name | Value | Comment |
|---|---:|---|
| `Jump` | `0` | Jump. |
| `Crouch` | `1` | Crouch. |
| `Walk` | `2` | Walk slowly. |
| `Fire` | `3` | Primary attack or fire. |
| `AlternateFire` | `4` | Alternate attack. |
| `Reload` | `5` | Reload the weapon. |
| `PrimaryWeapon` | `6` | Select the primary weapon. |
| `SecondaryWeapon` | `7` | Select the secondary weapon. |
| `Knife` | `8` | Select the knife. |
| `BridgeCharge` | `9` | Select the BridgeCharge. |
| `CycleGrenade` | `10` | Cycle to the next grenade. |
| `FragGrenade` | `11` | Select the Frag Grenade. |
| `Incendiary` | `12` | Select the Incendiary. |
| `Sonar` | `13` | Select the Sonar. |
| `EmpGrenade` | `14` | Select the EMP Grenade. |
| `PowerShell` | `15` | Select the PowerShell. |
| `DropItem` | `16` | Drop the active item. |
| `Interact` | `17` | Interact with the available object. |

## Health

Access to the agent health system.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `CurrentHealth` | int | `get` | Current agent health rounded to an integer. |
| `CurrentHealthPrecise` | number | `get` | Current exact health value of the agent. |
| `IsAlive` | bool | `get` | true if the agent is alive. |
| `MaxHealth` | int | `get` | Maximum agent health. |

## Hitbox

Agent hitbox: position, radius, body part, and hit checks.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `Agent` | [Agent](../agent/#agent) | `get` | The agent this hitbox belongs to. Returns nil if the agent is no longer available. |
| `BodyPart` | [EHitboxBodyPart](../agent/#ehitboxbodypart) | `get` | Body part the hitbox belongs to. |
| `IsBox` | bool | `get` | true if the hitbox has a box shape. |
| `IsSphere` | bool | `get` | true if the hitbox has a spherical shape. |
| `IsVisible` | bool | `get` | true if the agent with this hitbox is visible to the local team. When the agent is not visible, all other hitbox members return undefined values. |
| `Position` | Vector3 | `get` | Hitbox center position. |
| `Radius` | number | `get` | Spherical hitbox radius. |
| `Rotation` | Quaternion | `get` | Hitbox rotation in world space. |
| `Size` | Vector3 | `get` | Box hitbox size along each axis in local coordinates. |

## HitEvent

Outgoing hit event. The combat system calculates the hit and damage before passing this structure to `OnLocalPlayerDealtDamage()`. Changing its fields does not affect the server result of the shot.

### Fields

| Field | Type | Access | Description |
|---|---|:---:|---|
| `Damage` | number | `get/set` | Damage amount. |
| `HitEventId` | int | `get/set` | Unique hit event ID. |
| `HitTick` | int | `get/set` | Tick on which the hit occurred. |
| `HitType` | [EHitType](../agent/#ehittype) | `get/set` | Hit type. |
| `StunnedUntilTick` | int | `get/set` | Tick until which the stun remains active. Equals 0 if the hit did not apply a stun. |
| `WasStunned` | bool | `get/set` | true if the hit applied a stun. |

## Interactable

An object an agent can interact with. Every property is read-only.

`CanInteract()` and `GetInteractDuration()` only query the interaction system's current conditions. They do not start pickup or defusal. The actual action is performed by regular game input; a [`Drop`](../item/#drop) also exposes a dedicated `PickUp()` method.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `ActionName` | string | `get` | Name of the available action. |
| `AsDrop` | [Drop](../item/#drop) | `get` | Returns the object as a Drop, or nil if it is a different object type. |
| `AsPlantedBridgeCharge` | [PlantedBridgeCharge](../entity/#plantedbridgecharge) | `get` | Returns the object as a PlantedBridgeCharge, or nil if it is a different object type. |
| `IsDrop` | bool | `get` | true if the object is a Drop. |
| `IsPlantedBridgeCharge` | bool | `get` | true if the object is a PlantedBridgeCharge. |
| `IsVisible` | bool | `get` | true if the object is visible. Other values are undefined while it is hidden. |

### Methods

#### CanInteract

```lua
Interactable:CanInteract(agent: Agent): bool
```

Checks whether the specified agent can currently interact with the object.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `agent` | [Agent](../agent/#agent) |  | Agent for which eligibility is checked. |

**Returns:** bool

#### GetInteractDuration

```lua
Interactable:GetInteractDuration(agent: Agent): number
```

Returns the interaction duration in seconds.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `agent` | [Agent](../agent/#agent) |  | Agent for which the duration is calculated. |

**Returns:** number

## Interactor

Access to the agent interaction system.

Fields report the object selected by the interaction system and progress of the current action. `Interactor` does not expose a command to start or complete an interaction.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `AvailableInteractable` | [Interactable](../agent/#interactable) | `get` | <span class="api-context api-context--local">Local agent</span> Object the agent can interact with. Returns nil if there is no available object. |
| `InteractActionName` | string | `get` | Name of the current interaction action, such as 'Defuse' or 'PickUp'. |
| `InteractProgress` | number | `get` | Progress of the current interaction from 0 to 1. |
| `IsDefusing` | bool | `get` | <span class="api-context api-context--local">Local agent</span> true if the agent is currently defusing the BridgeCharge. |
| `IsInteracting` | bool | `get` | true if the agent is currently interacting with an object. |

## Inventory

Access to the agent inventory and item management.

Despite the name, the published methods here only read slots and items. They do not equip, drop, or purchase anything; those changes come from game input, [`Shop`](../shop/), or methods on specific world objects.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `CurrentItem` | [Item](../item/#item) | `get` | Current equipped item. Returns nil if the inventory is unavailable or no item is equipped. |
| `IsSwitching` | bool | `get` | true if the agent is currently switching CurrentItem. |
| `SwitchingUntil` | int | `get` | Simulation tick until which the CurrentItem switch remains active. |


### Methods

#### GetItem

```lua
Inventory:GetItem(slot: EItemSlot): Item
```

Returns the first item in the specified slot, or nil if the slot is empty or the inventory is unavailable.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `slot` | [EItemSlot](../item/#eitemslot) |  |  |

**Returns:** [Item](../item/#item)

#### GetItems

```lua
Inventory:GetItems(): Array<Item>
```

Returns all items in the agent's inventory.

**Returns:** Array<[Item](../item/#item)>

#### GetItemsInSlot

```lua
Inventory:GetItemsInSlot(slot: EItemSlot): Array<Item>
```

Returns the items in the specified slot.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `slot` | [EItemSlot](../item/#eitemslot) |  |  |

**Returns:** Array<[Item](../item/#item)>

#### IsSlotEmpty

```lua
Inventory:IsSlotEmpty(slot: EItemSlot): bool
```

Checks whether the specified inventory slot is empty.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `slot` | [EItemSlot](../item/#eitemslot) |  |  |

**Returns:** bool

## Movement

Data and calculations related to the agent's movement and position in the world.

Properties are outputs of the movement system after input and physics have been processed for the current tick. `Movement` has no direct setters; `GetZones()` only classifies the current position against map zones.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `CrouchJumpCooldownUntil` | int | `get` | Simulation tick until which the crouch jump cooldown remains active for the agent. |
| `CrouchProgress` | number | `get` | Current crouch progress from 0 to 1. |
| `IsCrouching` | bool | `get` | true if the agent is crouching. |
| `IsGrounded` | bool | `get` | true if the agent is on solid ground. |
| `IsWalking` | bool | `get` | true if the agent is walking slowly. |
| `JumpCooldownUntil` | int | `get` | Simulation tick until which the agent's jump cooldown remains active. |
| `Position` | Vector3 | `get` | Current world position where the agent is standing. |
| `Velocity` | Vector3 | `get` | Agent velocity. |


### Methods

#### GetZones

```lua
Movement:GetZones(): Array<string>
```

Returns the list of zones the agent is currently in.

**Returns:** Array<string>

## OcclusionCulling

Access to the agent occlusion/visibility system.

The client visibility system decides which enemy information can be exposed to a module. These properties describe that result; they do not enable visibility or issue a raycast on demand.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `HasBeenVisible` | bool | `get` | <span class="api-context api-context--client">Client only</span> true if the agent has ever been visible, or is visible now. |
| `SoundRange` | number | `get` | Audible radius of the sound produced by the agent. |
| `TicksSinceLastVisible` | int | `get` | <span class="api-context api-context--client">Client only</span> Number of ticks since the agent was last visible. |

Related types: [Array](../array/), [Color](../color/), [Vector2](../vector2/), [Vector3](../vector3/), and [Quaternion](../quaternion/).
