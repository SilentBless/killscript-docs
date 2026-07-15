---
title: Entity
description: Сущности мира, летящие гранаты и активные взрывы.
---

:::note[Проверено в игре]
На странице опубликованы только доступные в текущей сборке свойства и методы с подтверждённым доступом.
:::

`Entity` — общая основа объектов игрового мира. На этой странице описаны летящие гранаты и активные объекты взрывов. Все свойства доступны только для чтения.

## Быстрый пример

```lua
local projectiles = ThrownProjectiles:GetAll()

for i = 1, projectiles.Length do
    local projectile = projectiles[i]
    print(projectile.Name .. ": " .. tostring(projectile.Position))
end
```

## EMPGrenadeExplosion

Взрыв от EMP гранаты.

**Base:** [Explosion](../entity/#explosion)

## Entity

Базовый объект всех сущностей в мире.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `ID` | int | `get` | Уникальный ID сущности. |
| `IsVisible` | bool | `get` | true, если сущность видима для локальной команды. Когда сущность не видна, все её члены, кроме Name и ID, возвращают неопределённые значения. |
| `Name` | string | `get` | Имя сущности. |
| `Position` | Vector3 | `get` | Позиция сущности в мире. |
| `TicksSinceLastVisible` | int | `get` | <span class="api-context api-context--client">Только client</span> Количество тиков с момента, когда сущность была видна в последний раз. |

## Explosion

Базовый объект взрыва с общими параметрами времени жизни.

**Base:** [Entity](../entity/#entity)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `AsEMPGrenadeExplosion` | [EMPGrenadeExplosion](../entity/#empgrenadeexplosion) | `get` | Возвращает взрыв как EMPGrenadeExplosion или nil, если это взрыв другого типа. |
| `AsFragGrenadeExplosion` | [FragGrenadeExplosion](../entity/#fraggrenadeexplosion) | `get` | Возвращает взрыв как FragGrenadeExplosion или nil, если это взрыв другого типа. |
| `AsIncendiaryExplosion` | [IncendiaryExplosion](../entity/#incendiaryexplosion) | `get` | Возвращает взрыв как IncendiaryExplosion или nil, если это взрыв другого типа. |
| `AsPowerShellExplosion` | [PowerShellExplosion](../entity/#powershellexplosion) | `get` | Возвращает взрыв как PowerShellExplosion или nil, если это взрыв другого типа. |
| `AsSonarExplosion` | [SonarExplosion](../entity/#sonarexplosion) | `get` | Возвращает взрыв как SonarExplosion или nil, если это взрыв другого типа. |
| `Instigator` | [Agent](../agent/#agent) | `get` | Агент, который инициировал Explosion. |
| `IsEMPGrenadeExplosion` | bool | `get` | true, если является взрывом от EMP гранаты. |
| `IsFragGrenadeExplosion` | bool | `get` | true, если является взрывом от Frag гранаты. |
| `IsIncendiaryExplosion` | bool | `get` | true, если взрыв является областью огня от зажигательной гранаты. |
| `IsPowerShellExplosion` | bool | `get` | true, если взрыв является куполом щита. |
| `IsSonarExplosion` | bool | `get` | true, если взрыв является сонаром. |
| `ThrowableConfig` | [ConfigItemThrowable](../game-config/#configitemthrowable) | `get` | Конфигурация метательного предмета которым был создан этот Explosion. Возвращает nil, если конфигурация недоступна. |
| `ToDespawnTicks` | int | `get` | Оставшееся количество тиков до удаления взрыва. |

## Explosions

Глобальный API для листинга взрывов.

### Методы

#### GetAll

```lua
Explosions:GetAll(): Array<Explosion>
```

Возвращает все активные взрывы от гранат на карте.

**Возвращает:** Array<[Explosion](../entity/#explosion)>

#### GetEMPGrenadeExplosions

```lua
Explosions:GetEMPGrenadeExplosions(): Array<EMPGrenadeExplosion>
```

Возвращает все взрывы от EMP гранаты (EMPGrenadeExplosion) на карте.

**Возвращает:** Array<[EMPGrenadeExplosion](../entity/#empgrenadeexplosion)>

#### GetFragGrenadeExplosions

```lua
Explosions:GetFragGrenadeExplosions(): Array<FragGrenadeExplosion>
```

Возвращает все взрывы от Frag гранаты (FragGrenadeExplosion) на карте.

**Возвращает:** Array<[FragGrenadeExplosion](../entity/#fraggrenadeexplosion)>

#### GetIncendiaryExplosions

```lua
Explosions:GetIncendiaryExplosions(): Array<IncendiaryExplosion>
```

Возвращает все активные области огня (IncendiaryExplosion) на карте.

**Возвращает:** Array<[IncendiaryExplosion](../entity/#incendiaryexplosion)>

#### GetPowerShellExplosions

```lua
Explosions:GetPowerShellExplosions(): Array<PowerShellExplosion>
```

Возвращает все активные купола защиты (PowerShellExplosion) на карте.

**Возвращает:** Array<[PowerShellExplosion](../entity/#powershellexplosion)>

#### GetSonarExplosions

```lua
Explosions:GetSonarExplosions(): Array<SonarExplosion>
```

Возвращает все активные сонары (SonarExplosion) на карте.

**Возвращает:** Array<[SonarExplosion](../entity/#sonarexplosion)>

## FragGrenadeExplosion

Взрыв от Frag гранаты.

**Base:** [Explosion](../entity/#explosion)

## IncendiaryExplosion

Огонь от зажигательной граната.

**Base:** [Explosion](../entity/#explosion)

## PlantedBridgeCharge

Установленный BridgeCharge в игровом мире.

**Base:** [Entity](../entity/#entity)

Помимо свойств `Entity`, объект предоставляет иконку заряда.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Icon` | [Texture](../texture/) | `get` | Иконка установленного BridgeCharge. |

## PlantedBridgeCharges

Глобальный API для работы с PlantedBridgeCharge.

### Методы

#### GetPlanted

```lua
PlantedBridgeCharges:GetPlanted(): Array<PlantedBridgeCharge>
```

Возвращает все установленные BridgeCharge. До установки или после удаления заряда массив может быть пустым.

**Возвращает:** Array<[PlantedBridgeCharge](../entity/#plantedbridgecharge)>

## PowerShellExplosion

Купол PowerShell в мире.

**Base:** [Explosion](../entity/#explosion)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `ShellDurability` | number | `get` | Текущая прочность купола. |
| `ShellMaxDurability` | number | `get` | Максимальная прочность купола. |

## SonarExplosion

Сонар как объект в мире.

**Base:** [Explosion](../entity/#explosion)

## ThrownProjectile

Брошенный предмет (например, граната) в полете.

**Base:** [Entity](../entity/#entity)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `IsExploded` | bool | `get` | true, если предмет уже взорвался или больше не активен. |
| `ThrowableConfig` | [ConfigItemThrowable](../game-config/#configitemthrowable) | `get` | Конфигурация метательного предмета. Возвращает nil, если конфигурация недоступна. |
| `ThrownAtTick` | int | `get` | Тик, в который предмет был брошен. |
| `ThrownBy` | [Agent](../agent/#agent) | `get` | Агент, который бросил предмет. |
| `Velocity` | Vector3 | `get` | Текущая скорость полета. |


### Методы

#### SimulateTrajectory

```lua
ThrownProjectile:SimulateTrajectory(): Array<Vector3>
```

<span class="api-context api-context--client">Только client</span> Возвращает рассчитанную траекторию полета.

**Возвращает:** Array<Vector3>

## ThrownProjectiles

Глобальный API для работы с предметами в полете.

### Методы

#### GetAll

```lua
ThrownProjectiles:GetAll(): Array<ThrownProjectile>
```

Возвращает все активные брошенные предметы (например, гранаты), которые еще не взорвались. На клиенте также возвращает гранаты, которые сейчас не видны, но были видны ранее и продолжают предсказываться по траектории.

**Возвращает:** Array<[ThrownProjectile](../entity/#thrownprojectile)>



