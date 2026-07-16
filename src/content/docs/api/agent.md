---
title: Agent
description: Агенты, прицеливание, здоровье, движение, ввод и события урона.
---

:::note[Проверено в игре]
На странице опубликованы только доступные в текущей сборке свойства и методы с подтверждённым доступом.
:::

`Agent` объединяет состояние игрока: здоровье, прицеливание, движение, инвентарь и статистику. Все свойства `Agent` и вложенных API доступны только для чтения; исключение — поля структур событий и `AgentStats`.

## Как устроен путь данных

Серверная симуляция владеет здоровьем, движением, инвентарём, прицеливанием и статистикой агента. В Reflex `server.lua` обёртки читают это состояние на сервере; в `main.lua` клиент читает полученную сетевую копию и локальные presentation-данные. Ограничения видимости могут скрывать часть сведений о противнике.

`Agent`, `Health`, `Movement`, `Inventory`, `Aim` и остальные вложенные объекты — доступ к существующему агенту, а не отдельные копии персонажа. После смерти, смены раунда или отключения игрока сохранённая ссылка может стать недоступной, поэтому для длительного цикла заново получайте агента через `Agents`.

Структуры `HitEvent`, `DamageEvent`, `DeathEvent` и `AgentStats` передают Lua снимок уже рассчитанного результата. Присваивание их полям меняет только полученное Lua-значение и не переписывает урон, смерть или таблицу счёта.

## Что меняется визуально

- `Agent:TrySpectate()` при успехе переключает основной вид и стандартный spectator HUD на выбранного агента.
- `AgentInput:SetLookRotation()` меняет направление взгляда локального агента, а не создаёт отдельную [камеру](../camera/).
- На клиенте `SetMoveDirection()` и `SetButtonState()` меняют pending input локального агента; сами методы не показывают UI или уведомление. Для Reflex server действует описанный ниже временный баг.
- `Aim:SetAimTarget()` и `ResetAimTarget()` меняют серверное состояние цели прицеливания. Они не рисуют маркер цели — для него нужен отдельный [UI](../ui/) или [WorldVisuals](../world-visuals/).

Setter-методы возвращают `nil`. После команды проверяйте доступное состояние через соответствующие getter-ы, а не ожидайте подтверждение на экране.

## Быстрый пример

```lua
local localAgent = Agents:GetLocalAgent()

if localAgent ~= nil then
    print(localAgent.Nickname)
    print("HP: " .. tostring(localAgent.Health.CurrentHealth))
    print("Position: " .. tostring(localAgent.Movement.Position))
end
```

## Agent

Представляет агента в игре. Этот класс предоставляет доступ к различным свойствам и методам, связанным с агентом, таким как перемещение, здоровье, инвентарь и многое другое.

**Base:** [Entity](../entity/#entity)

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Aim` | [Aim](../agent/#aim) | `get` | Доступ к API прицеливания агента. |
| `Avatar` | [Texture](../texture/) | `get` | <span class="api-context api-context--client">Только client</span> Аватар агента. Возвращает аватарку игрока или иконку команды. |
| `AvatarIsTeamPlaceholder` | bool | `get` | <span class="api-context api-context--client">Только client</span> Возвращает true, если Avatar сейчас является командной иконкой-заглушкой, а не настоящим аватаром игрока. |
| `Color` | Color | `get` | Возвращает цвет, назначенный агенту. |
| `Health` | [Health](../agent/#health) | `get` | Доступ к API здоровья агента. |
| `Interactor` | [Interactor](../agent/#interactor) | `get` | Доступ к API взаимодействий агента. |
| `Inventory` | [Inventory](../agent/#inventory) | `get` | Доступ к API инвентаря агента. |
| `IsSpectated` | bool | `get` | <span class="api-context api-context--client">Только client</span> true, если идет наблюдение за этим агентом (когда локальный агент мертв, либо в режиме наблюдателя). |
| `Movement` | [Movement](../agent/#movement) | `get` | Доступ к API перемещения агента. |
| `Nickname` | string | `get` | Никнейм игрока. |
| `Number` | int | `get` | Возвращает номер, назначенный агенту. |
| `OcclusionCulling` | [OcclusionCulling](../agent/#occlusionculling) | `get` | Доступ к API окклюзии/видимости агента. |
| `Stats` | [AgentStats](../agent/#agentstats) | `get` | Статистика агента, доступна всегда. |
| `Team` | [Team](../team/) | `get` | Команда, к которой относится агент. |


### Методы

#### GetHitboxes

```lua
Agent:GetHitboxes(): Array<Hitbox>
```

Возвращает хитбоксы агента.

**Возвращает:** Array<[Hitbox](../agent/#hitbox)>

#### TrySpectate

```lua
Agent:TrySpectate(): bool
```

<span class="api-context api-context--client">Только client</span> Переключает наблюдение на данного агента, если это допустимо в текущем spectator-режиме.

**Возвращает:** bool

## AgentInput

Доступен на клиенте и в Reflex server. Глобальный API для получения состояния ввода и управления локальным агентом.

:::caution[Временный баг Reflex server]
В текущей сборке setter-ы `AgentInput:SetButtonState()`, `SetMoveDirection()` и `SetLookRotation()` в `server.lua` изменяют доступное Lua состояние, но не применяют ввод к фактически управляемому агенту. Getter-ы `AgentInput` продолжают работать. Проблема передана разработчику и будет исправлена в будущей сборке. До исправления не полагайтесь на серверное управление вводом через эти setter-ы.
:::

### Методы

#### GetLookRotation

```lua
AgentInput:GetLookRotation(): Vector2
```

Возвращает текущий поворот взгляда локального агента в градусах (X = pitch, Y = yaw).

**Возвращает:** Vector2

#### GetMoveDirection

```lua
AgentInput:GetMoveDirection(): Vector2
```

Возвращает текущее направление движения локального агента.

**Возвращает:** Vector2

#### IsButtonDown

```lua
AgentInput:IsButtonDown(inputButton: EInputButton): bool
```

true, если кнопка ввода удерживается локальным агентом.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `inputButton` | [EInputButton](../agent/#einputbutton) |  | Проверяемая кнопка. |

**Возвращает:** bool

#### IsJustPressed

```lua
AgentInput:IsJustPressed(inputButton: EInputButton): bool
```

true, если кнопка была нажата локальным агентом в этом тике.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `inputButton` | [EInputButton](../agent/#einputbutton) |  | Кнопка, для которой проверяется нажатие в текущем тике. |

**Возвращает:** bool

#### SetButtonState

```lua
AgentInput:SetButtonState(inputButton: EInputButton, down: bool)
```

Устанавливает состояние кнопки ввода локального агента (нажата/отпущена).

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `inputButton` | [EInputButton](../agent/#einputbutton) |  | Изменяемая кнопка. |
| `down` | bool |  | `true` — нажать, `false` — отпустить. |

#### SetLookRotation

```lua
AgentInput:SetLookRotation(vector: Vector2)
```

Устанавливает абсолютный поворот взгляда локального агента в градусах (X = pitch, Y = yaw).

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `vector` | Vector2 |  |  |

#### SetMoveDirection

```lua
AgentInput:SetMoveDirection(vector: Vector2)
```

Устанавливает вектор движения локального агента в осях ввода (X = влево/вправо, Y = вперед/назад).

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `vector` | Vector2 |  |  |

## Agents

API для листинга агентов и их ивентов.

### Методы

#### GetAll

```lua
Agents:GetAll(): Array<Agent>
```

Возвращает всех агентов в матче.

**Возвращает:** Array<[Agent](../agent/#agent)>

#### GetAllies

```lua
Agents:GetAllies(): Array<Agent>
```

Возвращает всех дружественных агентов относительно локальной команды.

**Возвращает:** Array<[Agent](../agent/#agent)>

#### GetEnemies

```lua
Agents:GetEnemies(): Array<Agent>
```

Возвращает всех вражеских агентов относительно локальной команды.

**Возвращает:** Array<[Agent](../agent/#agent)>

#### GetLocalAgent

```lua
Agents:GetLocalAgent(): Agent
```

Возвращает агента локального игрока или nil, если локальный агент сейчас недоступен.

**Возвращает:** [Agent](../agent/#agent)

#### GetLocalOrSpectatedAgent

```lua
Agents:GetLocalOrSpectatedAgent(): Agent
```

Возвращает агента локального игрока или наблюдаемого, или nil, если такого агента сейчас нет.

**Возвращает:** [Agent](../agent/#agent)

### События боя

Все три события доступны только на клиенте и возвращают [`EventSubscription`](../scheduler/#eventsubscription), которую можно отменить через `Cancel()`.

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

<span class="api-context api-context--client">Только client</span> Вызывает коллбек с объектом [`DeathEvent`](../agent/#deathevent), когда агент умирает.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `callback` | LuaFunction |  | Функция, принимающая `DeathEvent`. |

**Возвращает:** [EventSubscription](../scheduler/#eventsubscription)

#### OnLocalPlayerDealtDamage

```lua
Agents:OnLocalPlayerDealtDamage(callback: LuaFunction): EventSubscription
```

<span class="api-context api-context--client">Только client</span> Вызывает коллбек при нанесении урона локальным игроком. Возвращает подписку, которую можно отменить.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `callback` | LuaFunction |  | Функция, принимающая `HitEvent`. |

**Возвращает:** [EventSubscription](../scheduler/#eventsubscription)

#### OnLocalPlayerReceivedDamage

```lua
Agents:OnLocalPlayerReceivedDamage(callback: LuaFunction): EventSubscription
```

<span class="api-context api-context--client">Только client</span> Вызывает коллбек при получении урона локальным игроком. Событие содержит информацию об оглушении, если оно было наложено этим уроном. Возвращает подписку, которую можно отменить.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `callback` | LuaFunction |  | Функция, принимающая `DamageEvent`. |

**Возвращает:** [EventSubscription](../scheduler/#eventsubscription)

## AgentStats

Общая статистика агента. Все девять полей поддерживают чтение и присваивание (`get/set`). Изменение локального объекта не является командой серверу.

### Поля

| Поле | Тип | Доступ | Описание |
|---|---|:---:|---|
| `Assists` | int | `get/set` | Количество ассистов. |
| `Damage` | number | `get/set` | Суммарный нанесенный урон. |
| `DeathTick` | int | `get/set` | Тик симуляции, когда умер агент. |
| `Deaths` | int | `get/set` | Количество смертей. |
| `IsAlive` | bool | `get/set` | true, если жив. |
| `IsConnected` | bool | `get/set` | true, если подключен. |
| `Kills` | int | `get/set` | Количество убийств. |
| `Money` | int | `get/set` | Количество кредитов, это поле известно только для союзной команды, для всех других команд равно 0. |
| `Ping` | int | `get/set` | Средний пинг в миллисекундах по последним измерениям. |

## Aim

Доступ к системе прицеливания агента. Отвечает за текущее направление прицеливания, разброс и оглушение.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `AccumulatedUncertainty` | number | `get` | <span class="api-context api-context--local">Локальный агент</span> Накопленная неточность прицеливания из-за изменения направления прицеливания и других источников. |
| `AimingDownSightsProgress` | number | `get` | Прогресс прицеливания (ADS) от 0 до 1. |
| `Direction` | Vector3 | `get` | Текущее направление прицеливания в мировых координатах. |
| `DirectionViewportPoint` | Vector3 | `get` | <span class="api-context api-context--client">Только client</span> <span class="api-context api-context--local">Локальный агент</span> Viewport координаты позиции направления прицеливания для UI-рендера. |
| `IsAimingDownSights` | bool | `get` | true, если агент сейчас прицеливается (ADS). |
| `IsStunned` | bool | `get` | true, если агент сейчас оглушен. |
| `IsStunnedVisually` | bool | `get` | true, если для агента сейчас активен визуальный эффект оглушения. Действует дольше, чем IsStunned. Нужно, чтобы эффект от короткого оглушения не пропадал полностью при высоком пинге, когда клиент узнает об оглушении когда оно уже закончилось. |
| `LastStunDuration` | number | `get` | <span class="api-context api-context--local">Локальный агент</span> Длительность последнего оглушения в секундах. |
| `MovementSpeedUncertainty` | number | `get` | <span class="api-context api-context--local">Локальный агент</span> Неточность, вызванная скоростью движения. |
| `Position` | Vector3 | `get` | Мировая позиция камеры, используемой для прицеливания и стрельбы. |
| `StunnedUntilTick` | int | `get` | Тик симуляции, до которого действует оглушение. |
| `StunnedVisuallyUntilTick` | int | `get` | Тик симуляции, до которого действует визуальный эффект оглушения. Обычно равен StunnedUntilTick плюс число тиков сетевой задержки. Нужно, чтобы эффект от короткого оглушения не пропадал полностью при высоком пинге, когда клиент узнает об оглушении когда уже оно закончилось. |
| `Target` | [Agent](../agent/#agent) | `get` | <span class="api-context api-context--local">Локальный агент</span> Цель прицеливания. Возвращает nil, если цель не выбрана или целевой агент уже недоступен. |
| `TargetPosition` | Vector3 | `get` | Текущая точка прицеливания в мировых координатах. |
| `TotalUncertainty` | number | `get` | <span class="api-context api-context--local">Локальный агент</span> Сумма накопленной неточности и неточности от движения. |


### Методы

#### ResetAimTarget

```lua
Aim:ResetAimTarget()
```

<span class="api-context api-context--server">Только Reflex server</span> <span class="api-context api-context--local">Локальный агент</span> Сбрасывает цель прицеливания.

#### SetAimTarget

```lua
Aim:SetAimTarget(targetPosition: Vector3, agent: Agent)
```

<span class="api-context api-context--server">Только Reflex server</span> <span class="api-context api-context--local">Локальный агент</span> Устанавливает цель и позицию прицеливания.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `targetPosition` | Vector3 |  |  |
| `agent` | [Agent](../agent/#agent) |  |  |

## DamageEvent

Событие получения урона. Игровая система сначала применяет урон, затем передаёт структуру в callback `OnLocalPlayerReceivedDamage()`. Все поля доступны для чтения и присваивания (`get/set`), но изменение структуры не меняет уже применённый урон.

### Поля

| Поле | Тип | Доступ | Описание |
|---|---|:---:|---|
| `Damage` | number | `get/set` | Полученный урон. |
| `DamageDirection` | Vector3 | `get/set` | Направление урона: от точки получения урона к источнику атаки. |
| `DamageDirectionFromHead` | Vector3 | `get/set` | Направление урона: от головы к источнику атаки. |
| `DamagePosition` | Vector3 | `get/set` | Точка получения урона, относительно позиции агента. |
| `DamageTick` | int | `get/set` | Тик, в который был замечен урон. |
| `StunnedUntilTick` | int | `get/set` | Тик, до которого действует оглушение. Равен 0, если этот урон не наложил оглушение. |
| `WasStunned` | bool | `get/set` | true, если этот урон наложил оглушение. |

## DeathEvent

Событие смерти агента, передаваемое в callback `Agents:OnDeath()` после обработки смерти игрой. Все поля структуры доступны для чтения и присваивания (`get/set`); изменение значений не отменяет смерть и не меняет kill feed.

### Поля

| Поле | Тип | Доступ | Описание |
|---|---|:---:|---|
| `IsCritical` | bool | `get/set` | true, если убийство было критическим. |
| `Killer` | string | `get/set` | Имя убийцы. |
| `Victim` | string | `get/set` | Имя погибшего агента. |
| `WeaponId` | int | `get/set` | ID оружия, которым было совершено убийство. |

## EHitboxBodyPart

Часть тела hitbox агента.

| Значение | Код | Описание |
|---|---:|---|
| `None` | `0` | Нет части тела. |
| `Head` | `1` | Голова. |
| `Body` | `2` | Туловище. |
| `Arm` | `3` | Рука. |
| `Leg` | `4` | Нога. |

## EHitType

Тип попадания/хита.

| Значение | Код | Описание |
|---|---:|---|
| `None` | `0` | Нет попадания. |
| `Regular` | `1` | Обычное попадание. |
| `Critical` | `2` | Критическое попадание. |
| `Fatal` | `3` | Смертельное попадание. |
| `FriendlyFire` | `4` | Урон по союзнику. |
| `KineticShield` | `5` | Попадание в Kinetic Shield. |
| `Stunned` | `6` | Оглушающий урон. |

## EInputButton

Кнопки игрового ввода, которые принимает `AgentInput`. Числовые коды можно передавать напрямую, но именованные значения легче читать и поддерживать.

| Значение | Код | Описание |
|---|---:|---|
| `Jump` | `0` | Прыжок. |
| `Crouch` | `1` | Приседание. |
| `Walk` | `2` | Медленная ходьба. |
| `Fire` | `3` | Основная атака или выстрел. |
| `AlternateFire` | `4` | Альтернативная атака. |
| `Reload` | `5` | Перезарядка оружия. |
| `PrimaryWeapon` | `6` | Выбор основного оружия. |
| `SecondaryWeapon` | `7` | Выбор вторичного оружия. |
| `Knife` | `8` | Выбор ножа. |
| `BridgeCharge` | `9` | Выбор BridgeCharge. |
| `CycleGrenade` | `10` | Переключение на следующую гранату. |
| `FragGrenade` | `11` | Выбор Frag Grenade. |
| `Incendiary` | `12` | Выбор Incendiary. |
| `Sonar` | `13` | Выбор Sonar. |
| `EmpGrenade` | `14` | Выбор EMP Grenade. |
| `PowerShell` | `15` | Выбор PowerShell. |
| `DropItem` | `16` | Выброс активного предмета. |
| `Interact` | `17` | Взаимодействие с доступным объектом. |

## Health

Доступ к системе здоровья агента.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `CurrentHealth` | int | `get` | Текущее здоровье агента округленное в целое число. |
| `CurrentHealthPrecise` | number | `get` | Текущее точное значение здоровья агента. |
| `IsAlive` | bool | `get` | true, если агент жив. |
| `MaxHealth` | int | `get` | Максимальное здоровье агента. |

## Hitbox

Хитбокс агента: позиция, радиус, часть тела и проверка попаданий.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Agent` | [Agent](../agent/#agent) | `get` | Агент, которому принадлежит хитбокс. Возвращает nil, если агент уже недоступен. |
| `BodyPart` | [EHitboxBodyPart](../agent/#ehitboxbodypart) | `get` | Часть тела, к которой относится хитбокс. |
| `IsBox` | bool | `get` | true, если хитбокс имеет кубоидную форму. |
| `IsSphere` | bool | `get` | true, если хитбокс имеет сферическую форму. |
| `IsVisible` | bool | `get` | true, если агент с этим хитбоксом видим для локальной команды. Когда агент не виден, все его члены возвращают неопределённые значения. |
| `Position` | Vector3 | `get` | Позиция центра хитбокса. |
| `Radius` | number | `get` | Радиус сферического хитбокса. |
| `Rotation` | Quaternion | `get` | Поворот хитбокса в мире. |
| `Size` | Vector3 | `get` | Размер кубоидного хитбокса по каждой оси в локальных координатах. |

## HitEvent

Событие исходящего попадания. Система боя рассчитывает попадание и урон, после чего передаёт структуру в `OnLocalPlayerDealtDamage()`. Изменение её полей не влияет на серверный результат выстрела.

### Поля

| Поле | Тип | Доступ | Описание |
|---|---|:---:|---|
| `Damage` | number | `get/set` | Нанесенный урон. |
| `HitEventId` | int | `get/set` | Уникальный ID события попадания. |
| `HitTick` | int | `get/set` | Тик, в который произошло попадание. |
| `HitType` | [EHitType](../agent/#ehittype) | `get/set` | Тип попадания. |
| `StunnedUntilTick` | int | `get/set` | Тик, до которого действует оглушение. Равен 0, если попадание не наложило оглушение. |
| `WasStunned` | bool | `get/set` | true, если попадание наложило оглушение. |

## Interactable

Объект, с которым агент может взаимодействовать. Все свойства доступны только для чтения.

`CanInteract()` и `GetInteractDuration()` только спрашивают систему взаимодействий о текущих условиях. Они не запускают подбор или обезвреживание. Фактическое действие выполняет обычный игровой input; для [`Drop`](../item/#drop) также доступен отдельный `PickUp()`.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `ActionName` | string | `get` | Название доступного действия. |
| `AsDrop` | [Drop](../item/#drop) | `get` | Возвращает объект как Drop или nil, если это другой тип объекта. |
| `AsPlantedBridgeCharge` | [PlantedBridgeCharge](../entity/#plantedbridgecharge) | `get` | Возвращает объект как PlantedBridgeCharge или nil, если это другой тип объекта. |
| `IsDrop` | bool | `get` | true, если объект является Drop. |
| `IsPlantedBridgeCharge` | bool | `get` | true, если объект является PlantedBridgeCharge. |
| `IsVisible` | bool | `get` | true, если объект видим. У невидимого объекта остальные значения не определены. |

### Методы

#### CanInteract

```lua
Interactable:CanInteract(agent: Agent): bool
```

Проверяет, может ли указанный агент сейчас взаимодействовать с объектом.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `agent` | [Agent](../agent/#agent) |  | Агент, для которого выполняется проверка. |

**Возвращает:** bool

#### GetInteractDuration

```lua
Interactable:GetInteractDuration(agent: Agent): number
```

Возвращает длительность взаимодействия в секундах.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `agent` | [Agent](../agent/#agent) |  | Агент, для которого рассчитывается длительность. |

**Возвращает:** number

## Interactor

Доступ к системе взаимодействий агента.

Поля отражают уже выбранный системой доступный объект и прогресс текущего действия. `Interactor` не предоставляет команды начать или завершить взаимодействие.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `AvailableInteractable` | [Interactable](../agent/#interactable) | `get` | <span class="api-context api-context--local">Локальный агент</span> Объект, с которым агент может взаимодействовать. Возвращает nil, если доступного объекта нет. |
| `InteractActionName` | string | `get` | Название текущего действия взаимодействия, например 'Defuse' или 'PickUp'. |
| `InteractProgress` | number | `get` | Прогресс текущего взаимодействия от 0 до 1. |
| `IsDefusing` | bool | `get` | <span class="api-context api-context--local">Локальный агент</span> true, если агент сейчас разминирует BridgeCharge. |
| `IsInteracting` | bool | `get` | true, если агент сейчас взаимодействует с объектом. |

## Inventory

Доступ к инвентарю агента и управлению предметами.

Несмотря на название, опубликованные методы здесь только читают слоты и предметы. Они не экипируют, не выбрасывают и не покупают предметы; такие изменения выполняют игровой input, [`Shop`](../shop/) или методы конкретных мировых объектов.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `CurrentItem` | [Item](../item/#item) | `get` | Текущий экипированный предмет. Возвращает nil, если инвентарь недоступен или предмет не экипирован. |
| `IsSwitching` | bool | `get` | true, если агент сейчас меняет CurrentItem. |
| `SwitchingUntil` | int | `get` | Тик симуляции, до которого действует смена CurrentItem. |


### Методы

#### GetItem

```lua
Inventory:GetItem(slot: EItemSlot): Item
```

Возвращает первый предмет в указанном слоте или nil, если слот пуст или инвентарь недоступен.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `slot` | [EItemSlot](../item/#eitemslot) |  |  |

**Возвращает:** [Item](../item/#item)

#### GetItems

```lua
Inventory:GetItems(): Array<Item>
```

Возвращает все предметы в инвентаре агента.

**Возвращает:** Array<[Item](../item/#item)>

#### GetItemsInSlot

```lua
Inventory:GetItemsInSlot(slot: EItemSlot): Array<Item>
```

Возвращает предметы в указанном слоте.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `slot` | [EItemSlot](../item/#eitemslot) |  |  |

**Возвращает:** Array<[Item](../item/#item)>

#### IsSlotEmpty

```lua
Inventory:IsSlotEmpty(slot: EItemSlot): bool
```

Проверяет, пуст ли указанный слот инвентаря.

| Параметр | Тип | Необязательный | Описание |
|---|---|:---:|---|
| `slot` | [EItemSlot](../item/#eitemslot) |  |  |

**Возвращает:** bool

## Movement

Данные и расчеты, связанные с движением агента и расположением его в мире.

Свойства являются выходом системы движения после обработки ввода и физики текущего тика. Прямых setter-ов у `Movement` нет; `GetZones()` только классифицирует текущую позицию по зонам карты.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `CrouchJumpCooldownUntil` | int | `get` | Тик симуляции, до которого действует ограничение прыжка сидя для агента. |
| `CrouchProgress` | number | `get` | Прогресс текущего приседа от 0 до 1. |
| `IsCrouching` | bool | `get` | true, если агент в приседе. |
| `IsGrounded` | bool | `get` | true, если агент на твердой поверхности. |
| `IsWalking` | bool | `get` | true, если агент идет медленным шагом. |
| `JumpCooldownUntil` | int | `get` | Тик симуляции, до которого действует ограничение прыжка для агента. |
| `Position` | Vector3 | `get` | Текущая мировая позиция на которой стоит агент. |
| `Velocity` | Vector3 | `get` | Скорость агента. |


### Методы

#### GetZones

```lua
Movement:GetZones(): Array<string>
```

Возвращает список зон, в которых сейчас находится агент.

**Возвращает:** Array<string>

## OcclusionCulling

Доступ к системе окклюзии/видимости агента.

Клиентская система видимости решает, какие данные противника можно раскрыть модулю. Эти свойства описывают результат такого решения; они не включают видимость и не выполняют raycast по запросу.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `HasBeenVisible` | bool | `get` | <span class="api-context api-context--client">Только client</span> true, если агент уже был виден раньше или виден сейчас. |
| `SoundRange` | number | `get` | Радиус слышимости звука, создаваемого агентом. |
| `TicksSinceLastVisible` | int | `get` | <span class="api-context api-context--client">Только client</span> Количество тиков с момента, когда агент был виден в последний раз. |

Связанные типы: [Array](../array/), [Color](../color/), [Vector2](../vector2/), [Vector3](../vector3/) и [Quaternion](../quaternion/).
