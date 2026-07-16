---
title: MapInfo
description: Текущая карта, её размеры и зоны в Lua API KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha на карте Castle. API доступен в обычных модулях и в `server.lua` Reflex-модулей.
:::

`MapInfo` предоставляет параметры текущей карты и определяет игровые зоны в мировой позиции.

## Откуда берутся данные

Свойства читаются из загруженного описания карты. `GetZones(position)` проверяет переданную мировую точку по объёмам игровых зон и возвращает имена всех совпавших зон. Метод не перемещает объект в зону и не подписывается на вход/выход.

Для отслеживания агента повторяйте запрос с его актуальной [`Movement.Position`](../agent/#movement) в подходящем цикле.

## Быстрый пример

```lua
local zones = MapInfo:GetZones(Cameras.Main.Position)

for index = 1, zones.Length do
    print(zones[index])
end
```

`Cameras.Main` доступен только на клиенте. В `server.lua` передайте позицию из серверного API.

## Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `BasementBottomY` | `number` | `get` | Нижняя Y-граница подземного уровня. |
| `BasementTopY` | `number` | `get` | Верхняя Y-граница подземного уровня. |
| `MapCameraHeight` | `number` | `get` | Высота камеры миникарты. |
| `MapCenter` | [`Vector3`](../vector3/) | `get` | Центр карты в мировых координатах. |
| `MapName` | `string` | `get` | Имя текущей карты. |
| `MapSize` | `number` | `get` | Размер карты, используемый её представлением. |

Все свойства getter-only.

На карте `Castle` во время проверки были получены:

| Свойство | Значение |
|---|---|
| `BasementBottomY` | `-5` |
| `BasementTopY` | `0` |
| `MapCameraHeight` | `200` |
| `MapCenter` | `(15, 0, 20)` |
| `MapName` | `Castle` |
| `MapSize` | `130` |

Эти значения описывают только проверенную карту и не являются общими константами.

## GetZones

```lua
MapInfo:GetZones(position: Vector3): Array<string>
```

Возвращает [`Array<string>`](../array/) с именами всех зон, содержащих указанную мировую позицию.

Одна позиция может находиться сразу в нескольких зонах:

```lua
local zones = MapInfo:GetZones(Cameras.Main.Position)
-- Пример: BuyZoneCT, CSspawn
```

Если позиция не относится ни к одной зоне, возвращается пустой массив с `Length == 0`, а не `nil`.

```lua
local zones = MapInfo:GetZones(Vector3.zero)

if zones.Length == 0 then
    print("No zone at this position")
end
```

## Контексты

`MapInfo` и `GetZones()` работают и на клиенте, и в Reflex server. Результаты для одной карты и позиции совпали в обоих контекстах.
