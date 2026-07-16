---
title: Item
description: Items, inventory objects, hits, trajectories, and world drops.
---

:::note[Verified in game]
This page only documents properties and methods available in the current build with confirmed access behavior.
:::

`Item` represents an item whether it is in an inventory or lying in the world. Every object property on this page is read-only.

## How data flows

The item system owns firearm, grenade, and device instances. `Inventory`, `Items`, and `Drops` expose different views of those game objects: an owner's items, the complete set of existing items, or a dropped world object.

`Item` is a live instance with an owner, ammunition, and state. [`ConfigItem`](../game-config/#configitem) is the immutable definition of an item type. Do not confuse them: reading or editing a local result structure does not change configuration or create an item.

Hitscan and trajectory methods invoke calculation systems and return predictions. Only regular weapon/input commands or a server-approved `Drop:PickUp()` operation change the match.

## Which methods change the game

| Method | Effect |
|---|---|
| `Drop:PickUp()` | Requests a real pickup: on success, the item disappears from the world and enters the inventory. |
| `GetPredictedHits()` | Only returns possible shot outcomes. It does not fire or deal damage. |
| `HitscanFirearm()` / `HitscanMelee()` | Only calculates hits for the supplied position and direction. It does not play a shot, perform a strike, or create effects. |
| `SimulateThrowTrajectory()` | Only returns trajectory points. It does not throw the item or draw anything. |

To display a simulation result, draw the returned points yourself through [WorldVisuals](../world-visuals/) or [ImGui](../imgui/).

## Quick example

```lua
local agent = Agents:GetLocalAgent()
local items = agent.Inventory:GetItems()

for i = 1, items.Length do
    local item = items[i]
    print(item.Name .. " (slot " .. tostring(item.ItemSlot) .. ")")
end
```

## BridgeChargeItem

A BridgeCharge item before it is planted.

**Base:** [Item](../item/#item)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `IsPlanting` | bool | `get` | true while the player is planting the BridgeCharge. |
| `PlantProgress` | number | `get` | Current planting progress from `0` to `1`. |
| `PlantRemainingTicks` | int | `get` | Number of ticks remaining until planting completes. |

## Drop

Entity of an item lying on the ground.

**Base:** [Entity](../entity/#entity)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `Config` | [ConfigItem](../game-config/#configitem) | `get` | Dropped item configuration. Returns nil if the object is hidden or the item configuration is unavailable. |
| `Item` | [Item](../item/#item) | `get` | The item itself. Returns nil if the object is hidden or the item data is unavailable. |


### Methods

#### PickUp

```lua
Drop:PickUp()
```

<span class="api-context api-context--client">Client only</span> Picks up the dropped item.

:::tip[Check eligibility first]
The call returns `nil`. Only call it on an object returned by `Drops:GetNearby()`; that list contains items the local player can actually pick up now.
:::

A successful `PickUp()` adds the item to the inventory and removes the corresponding `Drop` from the world.

## Drops

Global API for listing dropped items.

### Methods

#### GetAll

```lua
Drops:GetAll(): Array<Drop>
```

Returns all dropped items.

**Returns:** Array<[Drop](../item/#drop)>

#### GetNearby

```lua
Drops:GetNearby(): Array<Drop>
```

Returns nearby dropped items from the local team that can be picked up.

**Returns:** Array<[Drop](../item/#drop)>

## EItemSlot

Item slots in the inventory.

| Name | Value | Comment |
|---|---:|---|
| `None` | `0` | Slot is not defined. |
| `PrimaryWeapon` | `1` | Primary weapon. |
| `SecondaryWeapon` | `2` | Secondary weapon. |
| `Knife` | `3` | Knife. |
| `Grenade` | `4` | Grenade. |
| `BridgeCharge` | `5` | BridgeCharge. |
| `Armor` | `6` | Armor. |
| `Defuser` | `7` | Defuse kit. |

## EThrowState

Throwable item throw state.

| Name | Value | Comment |
|---|---:|---|
| `None` | `0` | No throw is being performed. |
| `Preparing` | `1` | Preparing a primary (strong) throw. |
| `PreparingAlternate` | `2` | Preparing an alternate (weak) throw. |
| `Throwing` | `3` | Primary (strong) throw. |
| `ThrowingAlternate` | `4` | Alternate (weak) throw. |

## FirearmItem

Firearm as an inventory item.

**Base:** [Item](../item/#item)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `ClipAmmo` | int | `get` | Amount of ammo in the magazine. |
| `Config` | [ConfigItemFirearm](../game-config/#configitemfirearm) | `get` | Firearm configuration. Returns nil if the configuration is unavailable. |
| `Dispersion` | number | `get` | Full weapon spread taking the current state and configuration into account. |
| `HasAmmo` | bool | `get` | Returns true if there is ammo in the magazine or reserve. |
| `IsReloading` | bool | `get` | Returns true if the weapon is reloading. |
| `ReloadProgress` | number | `get` | Reload progress from 0 to 1. |
| `RemainingAmmo` | int | `get` | Amount of reserve ammo. |


### Methods

#### GetPredictedHits

```lua
FirearmItem:GetPredictedHits(): Array<Array<HitscanHit>>
```

<span class="api-context api-context--server">Reflex server only</span> <span class="api-context api-context--local">Local agent</span> Returns a list of possible hit results if the weapon is held by the local agent and fired right now. Each tick, several random trajectories that the shot can follow are calculated based on the aim direction and current inaccuracy. The shot is guaranteed to follow one of these trajectories. Each element of the returned array is the list of potential hits for one trajectory, similar to calling HitscanHit for that trajectory.

**Returns:** Array<Array<[HitscanHit](../item/#hitscanhit)>>

#### HitscanFirearm

```lua
FirearmItem:HitscanFirearm(firePosition: Vector3, projectileDirection: Vector3): Array<HitscanHit>
```

Simulates a shot from the specified position in the specified direction and returns a list of hits, taking penetrations into account.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `firePosition` | Vector3 |  | Shot origin position. For an agent, you can use Aim.Position. |
| `projectileDirection` | Vector3 |  | Direction from the shot origin. For an agent, you can use Aim.Direction. |

**Returns:** Array<[HitscanHit](../item/#hitscanhit)>

## HitscanHit

Projectile hit result (hitscan).

This is one element of a simulation result, not a registered combat event. It describes intersection and penetration for the calculated ray; reading its `Hitbox` does not deal damage to that agent.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `EntryPoint` | Vector3 | `get` | Projectile entry point into the surface. |
| `EntryPower` | number | `get` | Relative power on entry into the surface (in the 0-1 range, where 1 is full power). Power decreases when penetrating surfaces. |
| `ExitPower` | number | `get` | Relative power on exit from the surface (in the 0-1 range, where 1 is full power). Power decreases when penetrating surfaces. |
| `HasExited` | bool | `get` | true if the projectile passed all the way through. |
| `Hitbox` | [Hitbox](../agent/#hitbox) | `get` | Hitbox that was hit, or nil. |

## Item

Base object for all items.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `AsBridgeChargeItem` | `BridgeChargeItem` | `get` | Returns the item as BridgeChargeItem, or nil if it is a different item type. |
| `AsFirearmItem` | [FirearmItem](../item/#firearmitem) | `get` | Returns the item as FirearmItem, or nil if it is a different item type. |
| `AsMeleeItem` | [MeleeItem](../item/#meleeitem) | `get` | Returns the item as MeleeItem, or nil if it is a different item type. |
| `AsThrowableItem` | [ThrowableItem](../item/#throwableitem) | `get` | Returns the item as ThrowableItem, or nil if it is a different item type. |
| `ConfigItem` | [ConfigItem](../game-config/#configitem) | `get` | Item configuration. Returns nil if the configuration is unavailable. |
| `Icon` | [Texture](../texture/) | `get` | Full-resolution item icon. Returns nil if the item has no icon or the item object is no longer available. |
| `IconSmall` | [Texture](../texture/) | `get` | Small item icon with reduced detail. Returns nil if the item has no such icon or the item object is no longer available. |
| `IsBridgeCharge` | bool | `get` | true if the item is a BridgeCharge. |
| `IsDropped` | bool | `get` | true if the item has no owner. |
| `IsFirearm` | bool | `get` | true if the item is a firearm. |
| `IsMelee` | bool | `get` | true if the item is a melee weapon. |
| `IsThrowable` | bool | `get` | true if the item is throwable. |
| `IsVisible` | bool | `get` | true if the item is visible to the local team. When it is not visible, all members except Name, ItemSlot, ConfigItem return undefined values. |
| `ItemSlot` | [EItemSlot](../item/#eitemslot) | `get` | Inventory slot defined by the item's configuration. |
| `Name` | string | `get` | Item name from the configuration. |
| `Position` | Vector3 | `get` | Position of the agent holding the item, or the position of the dropped item. |

## Items

Global API for listing items.

### Methods

#### GetAll

```lua
Items:GetAll(): Array<Item>
```

Returns all items on the map.

**Returns:** Array<[Item](../item/#item)>

#### GetAllBridgeCharges

```lua
Items:GetAllBridgeCharges(): Array<BridgeChargeItem>
```

Returns BridgeCharges that currently exist as items. After planting completes, use `PlantedBridgeCharges:GetPlanted()` from the [Entity](../entity/#plantedbridgecharges) section.

**Returns:** Array<[BridgeChargeItem](../item/#bridgechargeitem)>

## MeleeItem

Melee weapon as an inventory item.

**Base:** [Item](../item/#item)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `Config` | [ConfigItemMelee](../game-config/#configitemmelee) | `get` | Melee weapon configuration. Returns nil if the configuration is unavailable. |


### Methods

#### HitscanMelee

```lua
MeleeItem:HitscanMelee(firePosition: Vector3, direction: Vector3, distance: number): HitscanHit
```

Simulates a melee strike from the specified position in the specified direction and returns the hit, or nil if there is no hit.

| Parameter | Type | Optional | Description |
|---|---|:---:|---|
| `firePosition` | Vector3 |  | Strike position. For an agent, use `Aim.Position`. |
| `direction` | Vector3 |  | Strike direction. For an agent, use `Aim.Direction`. |
| `distance` | number |  | Maximum simulation distance. `ConfigItemMelee.StrongAttackMaxHitDistance` is a suitable value. |

**Returns:** [HitscanHit](../item/#hitscanhit) or `nil`


## ThrowableItem

Throwable item (grenade) as an inventory item.

**Base:** [Item](../item/#item)

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `Config` | [ConfigItemThrowable](../game-config/#configitemthrowable) | `get` | Throwable item configuration. Returns nil if the configuration is unavailable. |
| `ThrowState` | [EThrowState](../item/#ethrowstate) | `get` | Current throw state. |


### Methods

#### SimulateThrowTrajectory

```lua
ThrowableItem:SimulateThrowTrajectory(throwState: EThrowState): Array<Vector3>
```

<span class="api-context api-context--client">Client only</span> Returns the simulated throw trajectory for the owner's current rotation and position.

| Param | Type | Optional | Comment |
|---|---|:---:|---|
| `throwState` | [EThrowState](../item/#ethrowstate) |  | Must be Preparing or PreparingAlternate, otherwise returns an empty array. For the current item, you can read the state from the ThrowState property. |

**Returns:** Array<Vector3>

Related types: [Array](../array/) and [Vector3](../vector3/).
