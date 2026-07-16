---
title: Physics
description: Клиентский raycast и структура RaycastHit.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Оба варианта `Raycast()`, попадание, промах и поля результата подтверждены в игре.
:::

`Physics` выполняет лучевую проверку сцены. API доступен только в клиентском Lua-контексте; в Reflex `server.lua` глобальный объект `Physics` равен `nil`.

`Physics.Raycast()` ничего не рисует и не изменяет в мире. Он только возвращает результат пересечения. Для видимого луча или маркера используйте полученные координаты с [WorldVisuals](../world-visuals/); для экранной подписи — с [ImGui](../imgui/) и [`Camera:WorldToViewportPoint()`](../camera/#worldtoviewportpoint).

## Где выполняется проверка

Клиентская физическая сцена проверяет луч по доступным ей collider-ам и сразу возвращает `RaycastHit`. Это локальный пространственный запрос, а не серверная проверка выстрела: результат не наносит урон и не подтверждает, что сервер разрешит действие.

`RaycastHit` — структура результата. Присваивание её полям меняет только локальное значение и не перемещает точку столкновения или collider в сцене.

## Пример

Проверим поверхность под главной камерой:

```lua
local origin = Cameras.Main.Position
local hit = Physics.Raycast(origin, Vector3.down, 100)

if hit.HasHit then
    print("Ground: " .. tostring(hit.Point))
    print("Distance: " .. tostring(hit.Distance))
else
    print("Nothing below the camera")
end
```

## Raycast с ограничением

```lua
Physics.Raycast(
    origin: Vector3,
    direction: Vector3,
    maxDistance: number
): RaycastHit
```

| Аргумент | Тип | Описание |
|---|---|---|
| `origin` | [`Vector3`](../vector3/) | Начало луча в мировых координатах. |
| `direction` | [`Vector3`](../vector3/) | Направление луча. |
| `maxDistance` | `number` | Максимальная длина проверки. |

## Raycast без ограничения

```lua
Physics.Raycast(
    origin: Vector3,
    direction: Vector3
): RaycastHit
```

Вариант без третьего аргумента выполняет ту же проверку без заданного модулем ограничения дистанции.

Оба варианта вызываются через точку: `Physics.Raycast(...)`.

## RaycastHit

Результат возвращается всегда, даже если луч ничего не задел.

| Поле | Тип | Доступ | Описание |
|---|---|---|---|
| `HasHit` | `bool` | `get/set` | `true`, если найдено пересечение. |
| `Distance` | `number` | `get/set` | Дистанция от `origin` до точки попадания. |
| `Point` | [`Vector3`](../vector3/) | `get/set` | Точка попадания в мировых координатах. |

При промахе в проверенном случае результат содержал `HasHit = false`, `Distance = 0` и `Point = Vector3.zero`. Сначала проверяйте `HasHit`, а затем используйте остальные поля.

Поля структуры допускают присваивание, но это изменяет только полученный результат и не влияет на физическую сцену.
