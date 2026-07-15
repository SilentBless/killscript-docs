---
title: Entity
description: World entities, thrown projectiles, and active explosions.
---

:::note[Verified in game]
This page only documents properties and methods available in the current build with confirmed access behavior.
:::

Game world entity API.

## EMPGrenadeExplosion

Explosion from an EMP grenade.

**Base:** [Explosion](../entity/#explosion)

## Entity

Base object for all entities in the world.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `ID` | int | `get` | Unique entity ID. |
| `IsVisible` | bool | `get` | true if the entity is visible to the local team. When the entity is not visible, all members except Name and ID return undefined values. |
| `Name` | string | `get` | Entity name. |
| `Position` | Vector3 | `get` | Entity position in the world. |
| `TicksSinceLastVisible` | int | `get` | <span class="api-context api-context--client">Client only</span> Number of ticks since the entity was last visible. |

## Explosion

Base explosion object with common lifetime parameters.

**Base:** [Entity](../entity/#entity)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `AsEMPGrenadeExplosion` | [EMPGrenadeExplosion](../entity/#empgrenadeexplosion) | `get` | Returns the explosion as EMPGrenadeExplosion, or nil if it is a different explosion type. |
| `AsFragGrenadeExplosion` | [FragGrenadeExplosion](../entity/#fraggrenadeexplosion) | `get` | Returns the explosion as FragGrenadeExplosion, or nil if it is a different explosion type. |
| `AsIncendiaryExplosion` | [IncendiaryExplosion](../entity/#incendiaryexplosion) | `get` | Returns the explosion as IncendiaryExplosion, or nil if it is a different explosion type. |
| `AsPowerShellExplosion` | [PowerShellExplosion](../entity/#powershellexplosion) | `get` | Returns the explosion as PowerShellExplosion, or nil if it is a different explosion type. |
| `AsSonarExplosion` | [SonarExplosion](../entity/#sonarexplosion) | `get` | Returns the explosion as SonarExplosion, or nil if it is a different explosion type. |
| `Instigator` | [Agent](../agent/#agent) | `get` | The agent that initiated this Explosion. |
| `IsEMPGrenadeExplosion` | bool | `get` | true if this is an explosion from an EMP grenade. |
| `IsFragGrenadeExplosion` | bool | `get` | true if this is an explosion from a Frag grenade. |
| `IsIncendiaryExplosion` | bool | `get` | true if the explosion is a fire area from an incendiary grenade. |
| `IsPowerShellExplosion` | bool | `get` | true if the explosion is a shield dome. |
| `IsSonarExplosion` | bool | `get` | true if the explosion is a sonar. |
| `ThrowableConfig` | [ConfigItemThrowable](../game-config/#configitemthrowable) | `get` | Configuration of the throwable item that created this Explosion. Returns nil if the configuration is unavailable. |
| `ToDespawnTicks` | int | `get` | Remaining number of ticks until the explosion is removed. |

## Explosions

Global API for listing explosions.

### Methods

#### GetAll

```lua
Explosions:GetAll(): Array<Explosion>
```

Returns all active grenade explosions on the map.

**Returns:** Array<[Explosion](../entity/#explosion)>

#### GetEMPGrenadeExplosions

```lua
Explosions:GetEMPGrenadeExplosions(): Array<EMPGrenadeExplosion>
```

Returns all EMP grenade explosions (EMPGrenadeExplosion) on the map.

**Returns:** Array<[EMPGrenadeExplosion](../entity/#empgrenadeexplosion)>

#### GetFragGrenadeExplosions

```lua
Explosions:GetFragGrenadeExplosions(): Array<FragGrenadeExplosion>
```

Returns all Frag grenade explosions (FragGrenadeExplosion) on the map.

**Returns:** Array<[FragGrenadeExplosion](../entity/#fraggrenadeexplosion)>

#### GetIncendiaryExplosions

```lua
Explosions:GetIncendiaryExplosions(): Array<IncendiaryExplosion>
```

Returns all active fire areas (IncendiaryExplosion) on the map.

**Returns:** Array<[IncendiaryExplosion](../entity/#incendiaryexplosion)>

#### GetPowerShellExplosions

```lua
Explosions:GetPowerShellExplosions(): Array<PowerShellExplosion>
```

Returns all active protection domes (PowerShellExplosion) on the map.

**Returns:** Array<[PowerShellExplosion](../entity/#powershellexplosion)>

#### GetSonarExplosions

```lua
Explosions:GetSonarExplosions(): Array<SonarExplosion>
```

Returns all active sonars (SonarExplosion) on the map.

**Returns:** Array<[SonarExplosion](../entity/#sonarexplosion)>

## FragGrenadeExplosion

Explosion from a Frag grenade.

**Base:** [Explosion](../entity/#explosion)

## IncendiaryExplosion

Fire from an incendiary grenade.

**Base:** [Explosion](../entity/#explosion)

## PlantedBridgeCharge

A planted BridgeCharge in the game world.

**Base:** [Entity](../entity/#entity)

In addition to the `Entity` properties, this object exposes the charge icon.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `Icon` | [Texture](../texture/) | `get` | Icon of the planted BridgeCharge. |

## PlantedBridgeCharges

Global API for working with PlantedBridgeCharge.

### Methods

#### GetPlanted

```lua
PlantedBridgeCharges:GetPlanted(): Array<PlantedBridgeCharge>
```

Returns all planted BridgeCharges. The array can be empty before a charge is planted or after it is removed.

**Returns:** Array<[PlantedBridgeCharge](../entity/#plantedbridgecharge)>

## PowerShellExplosion

A PowerShell dome in the world.

**Base:** [Explosion](../entity/#explosion)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `ShellDurability` | number | `get` | Current dome durability. |
| `ShellMaxDurability` | number | `get` | Maximum dome durability. |

## SonarExplosion

Sonar as an object in the world.

**Base:** [Explosion](../entity/#explosion)

## ThrownProjectile

Thrown item in flight, such as a grenade.

**Base:** [Entity](../entity/#entity)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `IsExploded` | bool | `get` | true if the item has already exploded or is no longer active. |
| `ThrowableConfig` | [ConfigItemThrowable](../game-config/#configitemthrowable) | `get` | Throwable item configuration. Returns nil if the configuration is unavailable. |
| `ThrownAtTick` | int | `get` | Tick on which the item was thrown. |
| `ThrownBy` | [Agent](../agent/#agent) | `get` | The agent who threw the item. |
| `Velocity` | Vector3 | `get` | Current flight velocity. |


### Methods

#### SimulateTrajectory

```lua
ThrownProjectile:SimulateTrajectory(): Array<Vector3>
```

<span class="api-context api-context--client">Client only</span> Returns the calculated flight trajectory.

**Returns:** Array<Vector3>

## ThrownProjectiles

Global API for working with thrown items in flight.

### Methods

#### GetAll

```lua
ThrownProjectiles:GetAll(): Array<ThrownProjectile>
```

Returns all active thrown items, such as grenades, that have not exploded yet. On the client, also returns grenades that are not visible now but were visible before and continue to have their trajectory predicted.

**Returns:** Array<[ThrownProjectile](../entity/#thrownprojectile)>

Related types: [Array](../array/) and [Vector3](../vector3/).


