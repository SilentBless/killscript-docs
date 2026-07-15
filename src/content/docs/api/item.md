---
title: Item
description: Предметы, инвентарь, попадания, траектории и выброшенные предметы.
---

:::note[Проверено в игре]
На странице опубликованы только доступные в текущей сборке свойства и методы с подтверждённым доступом.
:::

`Item` описывает предмет независимо от того, находится он в инвентаре или лежит в мире. Все свойства объектов на этой странице доступны только для чтения.

## Быстрый пример

```lua
local agent = Agents:GetLocalAgent()
local items = agent.Inventory:GetItems()

for i = 1, items.Length do
    local item = items[i]
    print(item.Name .. " (slot " .. tostring(item.ItemSlot) .. ")")
end
```

## BridgeChargeItem

BridgeCharge как предмет до его установки.

**Base:** [Item](../item/#item)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `IsPlanting` | bool | `get` | true, пока игрок устанавливает BridgeCharge. |
| `PlantProgress` | number | `get` | Текущий прогресс установки от `0` до `1`. |
| `PlantRemainingTicks` | int | `get` | Количество тиков до завершения установки. |

## Drop

Сущность лежащего на земле предмета.

**Base:** [Entity](../entity/#entity)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Config` | [ConfigItem](../game-config/#configitem) | `get` | Конфигурация лежащего предмета. Возвращает nil, если объект скрыт или конфигурация предмета недоступна. |
| `Item` | [Item](../item/#item) | `get` | Сам предмет. Возвращает nil, если объект скрыт или данные предмета недоступны. |


### Методы

#### PickUp

```lua
Drop:PickUp()
```

<span class="api-context api-context--client">Только client</span> Подбирает выброшенный предмет.

:::tip[Проверяйте доступность]
Вызов возвращает `nil`. Используйте только объект из `Drops:GetNearby()`: этот список содержит предметы, которые локальный игрок действительно может подобрать сейчас.
:::

`PickUp()` успешно добавляет предмет в инвентарь и удаляет соответствующий `Drop` из мира.

## Drops

Глобальный API для листинга выброшенных предметов.

### Методы

#### GetAll

```lua
Drops:GetAll(): Array<Drop>
```

Возвращает все выброшенные предметы.

**Возвращает:** Array<[Drop](../item/#drop)>

#### GetNearby

```lua
Drops:GetNearby(): Array<Drop>
```

Возвращает доступные локальному игроку предметы поблизости. Для безопасного вызова `PickUp()` выбирайте объект именно из этого массива.

**Возвращает:** Array<[Drop](../item/#drop)>

## EItemSlot

Слоты предметов в инвентаре.

| Значение | Код | Описание |
|---|---:|---|
| `None` | `0` | Слот не определен. |
| `PrimaryWeapon` | `1` | Основное оружие. |
| `SecondaryWeapon` | `2` | Вторичное оружие. |
| `Knife` | `3` | Нож. |
| `Grenade` | `4` | Граната. |
| `BridgeCharge` | `5` | BridgeCharge. |
| `Armor` | `6` | Броня. |
| `Defuser` | `7` | Набор для разминирования. |

## EThrowState

Состояние броска метательного предмета.

| Значение | Код | Описание |
|---|---:|---|
| `None` | `0` | Бросок не выполняется. |
| `Preparing` | `1` | Подготовка к основному (сильному) броску. |
| `PreparingAlternate` | `2` | Подготовка к альтернативному (слабому) броску. |
| `Throwing` | `3` | Основной (сильный) бросок. |
| `ThrowingAlternate` | `4` | Альтернативный (слабый) бросок. |

## FirearmItem

Огнестрельное оружие как предмет инвентаря.

**Base:** [Item](../item/#item)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `ClipAmmo` | int | `get` | Количество патронов в магазине. |
| `Config` | [ConfigItemFirearm](../game-config/#configitemfirearm) | `get` | Конфигурация огнестрельного оружия. Возвращает nil, если конфигурация недоступна. |
| `Dispersion` | number | `get` | Полный разброс оружия с учетом текущего состояния и конфигурации. |
| `HasAmmo` | bool | `get` | Возвращает true, если в магазине или в запасе есть патроны. |
| `IsReloading` | bool | `get` | Возвращает true, если оружие перезаряжается. |
| `ReloadProgress` | number | `get` | Прогресс перезарядки от 0 до 1. |
| `RemainingAmmo` | int | `get` | Количество патронов в запасе. |


### Методы

#### GetPredictedHits

```lua
FirearmItem:GetPredictedHits(): Array<Array<HitscanHit>>
```

<span class="api-context api-context--server">Только Reflex server</span> <span class="api-context api-context--local">Локальный агент</span> Возвращает список возможных точек попадания, если оружие находится в руках локального агента, и он выстрелит прямо сейчас. Каждый тик на основе направления прицеливания и значения неточности вычисляется несколько случайных траекторий, по которым может быть произведен выстрел. Выстрел гарантированно будет произведен по одной из этих траекторий. Каждое значение возвращаемого массива - список потенциальных попаданий по одной из траекторий, аналогично результатам вызова HitscanHit для этой траектории.

**Возвращает:** Array<Array<[HitscanHit](../item/#hitscanhit)>>

#### HitscanFirearm

```lua
FirearmItem:HitscanFirearm(firePosition: Vector3, projectileDirection: Vector3): Array<HitscanHit>
```

Проводит симуляцию выстрела из указанной позиции в указанном направлении и возвращает список попаданий с учетом прострелов.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `firePosition` | Vector3 |  | Позиция источника выстрела, для агента можно взять из Aim.Position |
| `projectileDirection` | Vector3 |  | Направление из источника для выстрела, для агента можно взять из Aim.Direction |

**Возвращает:** Array<[HitscanHit](../item/#hitscanhit)>

## HitscanHit

Результат попадания снаряда (hitscan).

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `EntryPoint` | Vector3 | `get` | Точка входа снаряда в поверхность. |
| `EntryPower` | number | `get` | Относительная мощность на входе в поверхность (в диапазоне 0-1, где 1 - полная мощность). Мощность уменьшается при прострелах насквозь. |
| `ExitPower` | number | `get` | Относительная мощность на выходе из поверхности (в диапазоне 0-1, где 1 - полная мощность). Мощность уменьшается при прострелах насквозь. |
| `HasExited` | bool | `get` | true, если снаряд вышел насквозь. |
| `Hitbox` | [Hitbox](../agent/#hitbox) | `get` | Хитбокс, в который произошло попадание (или nil). |

## Item

Базовый объект всех предметов.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `AsBridgeChargeItem` | `BridgeChargeItem` | `get` | Возвращает предмет как BridgeChargeItem или nil, если это предмет другого типа. |
| `AsFirearmItem` | [FirearmItem](../item/#firearmitem) | `get` | Возвращает предмет как FirearmItem или nil, если это предмет другого типа. |
| `AsMeleeItem` | [MeleeItem](../item/#meleeitem) | `get` | Возвращает предмет как MeleeItem или nil, если это предмет другого типа. |
| `AsThrowableItem` | [ThrowableItem](../item/#throwableitem) | `get` | Возвращает предмет как ThrowableItem или nil, если это предмет другого типа. |
| `ConfigItem` | [ConfigItem](../game-config/#configitem) | `get` | Конфигурация предмета. Возвращает nil, если конфигурация недоступна. |
| `Icon` | [Texture](../texture/) | `get` | Иконка предмета в полном разрешении. Возвращает nil, если у предмета нет иконки или объект предмета уже недоступен. |
| `IconSmall` | [Texture](../texture/) | `get` | Маленькая иконка предмета с уменьшенной детализацией. Возвращает nil, если у предмета нет такой иконки или объект предмета уже недоступен. |
| `IsBridgeCharge` | bool | `get` | true, если предмет — BridgeCharge. |
| `IsDropped` | bool | `get` | true, если у предмета нет владельца. |
| `IsFirearm` | bool | `get` | true, если предмет — огнестрельное оружие. |
| `IsMelee` | bool | `get` | true, если предмет — оружие ближнего боя. |
| `IsThrowable` | bool | `get` | true, если предмет — метательный. |
| `IsVisible` | bool | `get` | true, если предмет видим для локальной команды. Когда предмет не виден, все его члены, кроме Name, ItemSlot, ConfigItem, возвращают неопределённые значения. |
| `ItemSlot` | [EItemSlot](../item/#eitemslot) | `get` | Слот инвентаря, в который кладется предмет из конфигурации. |
| `Name` | string | `get` | Название предмета из конфигурации. |
| `Position` | Vector3 | `get` | Позиция агента, у которого находится предмет, либо позиция выброшенного предмета. |

## Items

Глобальный API для листинга предметов.

### Методы

#### GetAll

```lua
Items:GetAll(): Array<Item>
```

Возвращает все предметы (Items) на карте.

**Возвращает:** Array<[Item](../item/#item)>

#### GetAllBridgeCharges

```lua
Items:GetAllBridgeCharges(): Array<BridgeChargeItem>
```

Возвращает BridgeCharge, существующие сейчас как предметы. После завершения установки используйте `PlantedBridgeCharges:GetPlanted()` из раздела [Entity](../entity/#plantedbridgecharges).

**Возвращает:** Array<[BridgeChargeItem](../item/#bridgechargeitem)>

## MeleeItem

Оружие ближнего боя как предмет инвентаря.

**Base:** [Item](../item/#item)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Config` | [ConfigItemMelee](../game-config/#configitemmelee) | `get` | Конфигурация холодного оружия. Возвращает nil, если конфигурация недоступна. |


## ThrowableItem

Метательный предмет (граната) как элемент инвентаря.

**Base:** [Item](../item/#item)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Config` | [ConfigItemThrowable](../game-config/#configitemthrowable) | `get` | Конфигурация метательного предмета. Возвращает nil, если конфигурация недоступна. |
| `ThrowState` | [EThrowState](../item/#ethrowstate) | `get` | Текущее состояние броска. |


### Методы

#### SimulateThrowTrajectory

```lua
ThrowableItem:SimulateThrowTrajectory(throwState: EThrowState): Array<Vector3>
```

<span class="api-context api-context--client">Только client</span> Возвращает симулированную траекторию броска для текущего поворота и позиции владельца.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `throwState` | [EThrowState](../item/#ethrowstate) |  | Должно быть Preparing или PreparingAlternate, иначе вернет пустой массив, для текущего предмета состояние можно взять из поля ThrowState |

**Возвращает:** Array<Vector3>

Связанные типы: [Array](../array/) и [Vector3](../vector3/).


