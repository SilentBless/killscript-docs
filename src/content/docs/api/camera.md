---
title: Camera
description: Главная и пользовательские камеры в Lua API KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Все указанные виды доступа и примеры подтверждены в игре.
:::

API `Camera` позволяет читать главную камеру сцены и создавать дополнительные камеры. Дополнительная камера рендерит изображение в текстуру: её можно вывести через [UI](../ui/) или [ImGui](../imgui/).

Весь раздел доступен только в клиентской Lua-части. В `server.lua` Reflex-модуля глобальный объект `Cameras` равен `nil`.

## Как камера обрабатывается игрой

`Cameras.Main` оборачивает реальную активную камеру игрового клиента. Setter-ы сразу меняют её компонент, но контроллер персонажа и другие системы камеры могут записать своё состояние на следующем кадре.

`CreateCamera()` регистрирует отдельную клиентскую камеру и создаёт для неё render texture. Пока камера активна, renderer обновляет `OutputTexture`; `SetActive(false)` останавливает новые кадры, а `RemoveCamera()` удаляет созданный ресурс. Ни один из этих вызовов сам не добавляет текстуру в HUD.

## Главное

- `Cameras.Main` возвращает главную камеру и доступен только для чтения.
- `Cameras:CreateCamera()` создаёт пользовательскую камеру.
- `IsMainCamera` и `OutputTexture` — свойства только для чтения.
- `SetActive(false)` останавливает обновление `OutputTexture`, сохраняя последний кадр.
- Пользовательская камера не заменяет основной вид автоматически: её `OutputTexture` нужно вывести на экран.

## Где появляется результат

| Действие | Что меняется |
|---|---|
| Изменение `Cameras.Main` | Сразу меняет основной игровой вид. Игра может перезаписать значения в следующем кадре. |
| Создание пользовательской камеры | Само по себе ничего не добавляет на экран. Изображение доступно только через `OutputTexture`. |
| `SetActive(false)` | Замораживает обновление текстуры, но не скрывает уже выведенное изображение. |
| `WorldToViewportPoint()` | Только вычисляет экранное положение точки и ничего не рисует. |

Чтобы показать пользовательскую камеру, передайте `OutputTexture` в [ImGui](../imgui/) или элемент [UI](../ui-elements/). Размер текстуры и её размер на экране задаются независимо.

## Полный пример

Пример создаёт превью `320 × 180` в левом верхнем углу. Дополнительная камера следует за главной, но находится на два метра выше.

```lua
local PreviewCamera = Cameras:CreateCamera()

if PreviewCamera == nil then
    print("[Camera example] Camera limit reached")
else
    PreviewCamera:SetRenderSize(320, 180)
    PreviewCamera.Aspect = 320 / 180
    PreviewCamera.Fov = 60
    PreviewCamera:SetActive(true)

    Scheduler:OnFrame(function()
        local mainCamera = Cameras.Main
        PreviewCamera.Position = mainCamera.Position + Vector3.new(0, 2, 0)
        PreviewCamera.Rotation = mainCamera.Rotation

        local texture = PreviewCamera.OutputTexture
        if texture ~= nil then
            ImGui:DrawTexture(texture, Rect.new(20, 20, 320, 180))
        end
    end)
end
```

`ImGui` работает в immediate mode, поэтому `DrawTexture` вызывается каждый кадр. Сама камера при этом создаётся только один раз.

## Camera

Объект главной или пользовательской камеры. Напрямую не создаётся: используйте `Cameras.Main` или `Cameras:CreateCamera()`.

### Свойства

| Свойство | Тип | Доступ | Описание |
|---|---|---|---|
| `Aspect` | `number` | `get/set` | Соотношение ширины изображения к высоте. |
| `FarClipPlane` | `number` | `get/set` | Дальняя плоскость отсечения в метрах. |
| `Fov` | `number` | `get/set` | Вертикальный угол обзора в градусах. |
| `IsMainCamera` | `bool` | `get` | `true` только для главной камеры сцены. |
| `IsOrthographic` | `bool` | `get/set` | Включена ли ортографическая проекция. |
| `NearClipPlane` | `number` | `get/set` | Ближняя плоскость отсечения в метрах. |
| `OrthographicSize` | `number` | `get/set` | Размер ортографической камеры. Используется при `IsOrthographic = true`. |
| `OutputTexture` | [`Texture`](../texture/) \| `nil` | `get` | Текстура пользовательской камеры. У главной камеры возвращает `nil`. |
| `Position` | [`Vector3`](../vector3/) | `get/set` | Позиция камеры в мировых координатах. |
| `Rotation` | [`Quaternion`](../quaternion/) | `get/set` | Вращение камеры в мировых координатах. |

:::caution[Главной камерой управляет игра]
Setter-ы главной камеры работают, но игровая логика может записать свои значения уже в следующем кадре. Изменение `Position` или `Rotation` двигает основной вид вместе с моделью рук и не создаёт вид от третьего лица. Для независимого вида создавайте пользовательскую камеру.
:::

### SetActive

```lua
camera:SetActive(value: bool)
```

Включает или останавливает рендер пользовательской камеры.

| Аргумент | Тип | Описание |
|---|---|---|
| `value` | `bool` | `true` — обновлять изображение; `false` — остановить обновление. |

При `false` объект камеры и `OutputTexture` сохраняются, а в текстуре остаётся последний отрисованный кадр. Повторный вызов с `true` возобновляет рендер.

### SetRenderSize

```lua
camera:SetRenderSize(width: int, height: int)
```

Задаёт размер `OutputTexture` пользовательской камеры в пикселях.

| Аргумент | Тип | Описание |
|---|---|---|
| `width` | `int` | Ширина текстуры. |
| `height` | `int` | Высота текстуры. |

После `camera:SetRenderSize(320, 180)` свойства `camera.OutputTexture.width` и `camera.OutputTexture.height` возвращают `320` и `180`.

`SetRenderSize` не меняет `Aspect` автоматически. Обычно оба значения задаются вместе:

```lua
camera:SetRenderSize(320, 180)
camera.Aspect = 320 / 180
```

### WorldToViewportPoint

```lua
camera:WorldToViewportPoint(worldPosition: Vector3): Vector3
```

Преобразует мировую позицию в координаты viewport:

- `(0, 0)` — левый нижний угол;
- `(1, 1)` — правый верхний угол;
- `z` — расстояние от камеры в метрах;
- отрицательный `z` означает, что точка находится позади камеры.

Для камеры в начале координат с `Fov = 90`, `Aspect = 1` и нулевым вращением получены следующие значения:

| Мировая позиция | Результат |
|---|---|
| `(0, 0, 10)` | `(0.5, 0.5, 10)` — центр экрана |
| `(10, 0, 10)` | `(1, 0.5, 10)` — правый край |
| `(0, 10, 10)` | `(0.5, 1, 10)` — верхний край |
| `(0, 0, -10)` | `(0.5, 0.5, -10)` — позади камеры |

## Cameras

Глобальный клиентский API для получения и создания камер.

### Main

```lua
local mainCamera = Cameras.Main
```

Возвращает главную камеру сцены. Само свойство `Main` доступно только для чтения.

### CreateCamera

```lua
local camera = Cameras:CreateCamera()
```

Создаёт и возвращает пользовательскую камеру. Перед использованием результата рекомендуется проверить его на `nil`.

### RemoveCamera

```lua
Cameras:RemoveCamera(camera)
```

Удаляет ранее созданную пользовательскую камеру. После удаления сохранённую ссылку использовать нельзя.

```lua
camera:SetActive(false)
Cameras:RemoveCamera(camera)
camera = nil
```

## Частые ошибки

### Запись в getter-only свойства

Следующие операции завершаются Lua-ошибкой доступа:

```lua
Cameras.Main = camera
camera.IsMainCamera = true
camera.OutputTexture = texture
```

### Ожидание автоматического переключения вида

`camera:SetActive(true)` запускает рендер дополнительной камеры, но не заменяет изображение главной камеры. Покажите `camera.OutputTexture` через [UI-элемент](../ui-elements/) или [`ImGui:DrawTexture()`](../imgui/#drawtexture).

### Точка позади камеры

Проверки только `x` и `y` недостаточно. Перед отрисовкой маркера убедитесь, что результат `WorldToViewportPoint()` имеет `z > 0`.
