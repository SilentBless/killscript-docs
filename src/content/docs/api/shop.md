---
title: Shop
description: Покупка, продажа и проверка доступности предметов магазина.
---

:::note[Проверено в игре]
Все методы страницы подтверждены на реальной покупке и продаже в buy zone.
:::

`Shop` — клиентский API магазина. В Reflex server глобальный объект равен `nil`.

Командные методы `BuyItem()`, `BuyAndDropItem()` и `SellItem()` возвращают `nil`. Проверяйте результат операции по инвентарю и query-методам, а не по возвращаемому значению.

## Пример покупки и продажи

```lua
local itemName = "FragGrenade"

if not Shop:IsBuyLimitReachedForItem(itemName) then
    Shop:BuyItem(itemName)
end

if Shop:CanSellItem(itemName) then
    Shop:SellItem(itemName)
end
```

Успешная покупка добавляет предмет в `Agents:GetLocalAgent().Inventory`. После покупки `HasBoughtItem()` становится `true`, а `CanSellItem()` показывает, можно ли вернуть предмет прямо сейчас.

## BuyItem

```lua
Shop:BuyItem(itemName: string)
```

Покупает предмет по внутреннему имени. Операция зависит от стадии раунда, buy zone, денег, доступности предмета и лимита покупок.

## SellItem

```lua
Shop:SellItem(itemName: string)
```

Продаёт ранее купленный предмет, когда `CanSellItem(itemName)` возвращает `true`.

## BuyAndDropItem

```lua
Shop:BuyAndDropItem(itemName: string)
```

Отправляет запрос на покупку предмета с выбросом в мир.

:::caution[Проверяйте появление Drop]
В текущей сборке успешный вызов учитывался как покупка, но новый объект не появился в `Drops:GetAll()` или `Drops:GetNearby()`. Не считайте вызов гарантией того, что `Drop` уже доступен через Lua API.
:::

## Проверки состояния

### CanSellItem

```lua
Shop:CanSellItem(itemName: string): bool
```

Возвращает `true`, если локальный игрок может продать предмет прямо сейчас.

### HasBoughtItem

```lua
Shop:HasBoughtItem(itemName: string): bool
```

Возвращает `true`, если предмет учитывается как купленный локальным игроком в текущем раунде.

### IsBuyLimitReachedForItem

```lua
Shop:IsBuyLimitReachedForItem(itemName: string): bool
```

Возвращает `true`, если достигнут лимит покупок этого предмета.


