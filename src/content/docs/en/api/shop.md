---
title: Shop
description: Buying, selling, and checking in-match shop items.
---

:::note[Verified in game]
Every method on this page was confirmed with a real purchase and sale inside a buy zone.
:::

`Shop` is the client-side in-match shop API. The global is `nil` in a Reflex server.

The command methods `BuyItem()`, `BuyAndDropItem()`, and `SellItem()` return `nil`. Check inventory and the query methods to confirm an operation instead of relying on a return value.

## Buy and sell example

```lua
local itemName = "FragGrenade"

if not Shop:IsBuyLimitReachedForItem(itemName) then
    Shop:BuyItem(itemName)
end

if Shop:CanSellItem(itemName) then
    Shop:SellItem(itemName)
end
```

A successful purchase adds the item to `Agents:GetLocalAgent().Inventory`. After buying, `HasBoughtItem()` becomes `true`, while `CanSellItem()` reports whether it can be refunded right now.

## BuyItem

```lua
Shop:BuyItem(itemName: string)
```

Buys an item by its internal name. The operation depends on the round stage, buy zone, available money, item availability, and purchase limit.

## SellItem

```lua
Shop:SellItem(itemName: string)
```

Sells a previously purchased item when `CanSellItem(itemName)` returns `true`.

## BuyAndDropItem

```lua
Shop:BuyAndDropItem(itemName: string)
```

Requests a purchase that should place the item in the world.

:::caution[Confirm the Drop]
In the current build, a successful call was recorded as a purchase, but no new object appeared in `Drops:GetAll()` or `Drops:GetNearby()`. Do not treat the call as proof that a `Drop` is already exposed through the Lua API.
:::

## State queries

### CanSellItem

```lua
Shop:CanSellItem(itemName: string): bool
```

Returns `true` when the local player can sell the item right now.

### HasBoughtItem

```lua
Shop:HasBoughtItem(itemName: string): bool
```

Returns `true` when the item is recorded as purchased by the local player in the current round.

### IsBuyLimitReachedForItem

```lua
Shop:IsBuyLimitReachedForItem(itemName: string): bool
```

Returns `true` when the purchase limit for the item has been reached.


