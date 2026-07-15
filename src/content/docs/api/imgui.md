---
title: ImGui
description: "Быстрый immediate-mode интерфейс: текст, текстуры и настраиваемые HUD-окна."
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> `ImGui` недоступен в `server.lua` Reflex-модуля.

## Как работает ImGui

ImGui рисует элементы только в текущем кадре. Чтобы текст или изображение оставались на экране, вызывайте методы рисования из `Scheduler:OnFrame()`.

```lua
Scheduler:OnFrame(function()
    ImGui:DrawText(
        "Tick: " .. tostring(Time.Tick),
        Rect.new(20, 20, 280, 36),
        18,
        Color.new(1, 1, 1),
        TextAnchor.MiddleLeft
    )
end)
```

Окна создаются один раз при загрузке модуля. Перерисовывать каждый кадр нужно только их содержимое.

## Координаты

- `DrawText()`, `DrawTextPos()` и глобальные методы текстур используют экранные координаты в пикселях. Начало координат находится в левом верхнем углу.
- `DrawTextUV()` использует нормализованные координаты viewport: `(0, 0)` — левый нижний угол, `(1, 1)` — правый верхний.
- Методы `ImGuiWindow` используют координаты внутри содержимого окна.

## ImGui

Глобальный слой быстрого интерфейса.

### DrawDebugText

```lua
ImGui:DrawDebugText(text: string)
```

Добавляет строку в отладочный блок у края экрана. Несколько вызовов в одном кадре располагаются друг под другом. Возвращает `nil`.

### DrawText

```lua
ImGui:DrawText(
    text: string,
    rect: Rect,
    fontSize: number = 11,
    color: Color? = nil,
    alignment: TextAnchor = TextAnchor.MiddleCenter
)
```

Рисует текст внутри указанной экранной области. Если `color` не передан, используется встроенный светлый цвет текста. Возвращает `nil`.

### DrawTextPos

```lua
ImGui:DrawTextPos(
    text: string,
    screenPosition: Vector2,
    fontSize: number = 11,
    color: Color? = nil,
    alignment: TextAnchor = TextAnchor.MiddleCenter
)
```

Рисует текст в экранной позиции и автоматически подбирает область под содержимое. Возвращает `nil`.

### DrawTextUV

```lua
ImGui:DrawTextUV(
    text: string,
    viewportPosition: Vector2,
    fontSize: number = 11,
    color: Color? = nil,
    alignment: TextAnchor = TextAnchor.MiddleCenter
)
```

Рисует автоматически размеренный текст в нормализованной позиции viewport. Значения преобразуются относительно текущих `Screen.Width` и `Screen.Height`. Возвращает `nil`.

### DrawTexture

```lua
ImGui:DrawTexture(texture: Texture, rect: Rect? = nil)
```

Рисует [Texture](../texture/) в указанной экранной области. Если `rect` не передан, используется вся доступная область глобального слоя. Возвращает `nil`.

### DrawTextureColor

```lua
ImGui:DrawTextureColor(texture: Texture, color: Color, rect: Rect? = nil)
```

Рисует текстуру с цветовой маской. Альфа-канал `color` управляет прозрачностью. Возвращает `nil`.

:::caution[Лимиты одного кадра]
Глобальный слой и каждое окно могут одновременно отрисовать до 64 текстовых элементов и до 16 изображений. Лишние элементы не появятся на экране.
:::

### AddImGuiWindow

```lua
ImGui:AddImGuiWindow(id: string, title: string, rect: Rect): ImGuiWindow
```

Создаёт плавающее HUD-окно, положение и размер которого пользователь может настроить в редакторе интерфейса.

- `id` должен быть непустым и уникальным внутри модуля;
- `title` отображается в заголовке окна;
- `rect` задаёт начальную позицию и размер в экранных пикселях;
- один модуль может создать не больше 16 окон.

Возвращает [ImGuiWindow](#imguiwindow). Для пустого `id` или после достижения лимита возвращает `nil`.

## ImGuiWindow

Плавающее HUD-окно, созданное через `ImGui:AddImGuiWindow()`.

### Быстрый пример

```lua
local window = ImGui:AddImGuiWindow(
    "status",
    "Module status",
    Rect.new(40, 120, 320, 140)
)

if window ~= nil then
    window:SetVisibilityTypes({
        WindowVisibilityType.Match,
        WindowVisibilityType.Spectate,
    })

    Scheduler:OnFrame(function()
        window:DrawText(
            "Module is active",
            Rect.new(12, 12, 296, 32),
            18,
            Color.new(0.4, 1, 0.5),
            TextAnchor.MiddleLeft
        )
    end)
end
```

### DrawText

```lua
ImGuiWindow:DrawText(
    text: string,
    rect: Rect,
    fontSize: number,
    color: Color,
    alignment: TextAnchor = TextAnchor.MiddleCenter
)
```

Рисует текст внутри содержимого окна. В отличие от глобального `DrawText()`, размер шрифта и цвет обязательны. Возвращает `nil`.

### DrawTexture

```lua
ImGuiWindow:DrawTexture(texture: Texture, rect: Rect? = nil)
```

Рисует текстуру внутри окна. Если `rect` не передан, изображение занимает всю доступную область содержимого. Возвращает `nil`.

### DrawTextureColor

```lua
ImGuiWindow:DrawTextureColor(texture: Texture, color: Color, rect: Rect? = nil)
```

Рисует текстуру внутри окна с цветовой маской. Возвращает `nil`.

### GetContentRenderSize

```lua
ImGuiWindow:GetContentRenderSize(): Vector2
```

Возвращает фактический размер области содержимого на экране в пикселях с учётом масштаба UI и масштаба плавающего окна.

### SetVisibilityTypes

```lua
ImGuiWindow:SetVisibilityTypes(visibilityTypes: table): bool
```

Задаёт режимы, в которых окно доступно через редактор раскладки HUD. Передайте массив значений [WindowVisibilityType](#windowvisibilitytype). `nil` или пустая таблица оставляет окно только в общем фильтре всех режимов.

Возвращает true для действующего окна и false, если связанный элемент окна уже недоступен.

## TextAnchor

Выравнивание текста относительно переданной области или позиции.

| Значение | Число | Положение |
|---|---:|---|
| `TextAnchor.UpperLeft` | `0` | Сверху слева |
| `TextAnchor.UpperCenter` | `1` | Сверху по центру |
| `TextAnchor.UpperRight` | `2` | Сверху справа |
| `TextAnchor.MiddleLeft` | `3` | По центру слева |
| `TextAnchor.MiddleCenter` | `4` | По центру |
| `TextAnchor.MiddleRight` | `5` | По центру справа |
| `TextAnchor.LowerLeft` | `6` | Снизу слева |
| `TextAnchor.LowerCenter` | `7` | Снизу по центру |
| `TextAnchor.LowerRight` | `8` | Снизу справа |

## WindowVisibilityType

Режим видимости плавающего HUD-окна.

| Значение | Число | Режим |
|---|---:|---|
| `WindowVisibilityType.Match` | `0` | Обычный матч |
| `WindowVisibilityType.Spectate` | `1` | Наблюдение за игроком |
| `WindowVisibilityType.Killcam` | `2` | Камера убийства |

## Связанные типы

- [Rect](../rect/) — экранная область;
- [Vector2](../vector2/) — позиция;
- [Color](../color/) — цвет и прозрачность;
- [Texture](../texture/) — изображение;
- [Screen](../screen/) — размеры экрана;
- [Scheduler](../scheduler/) — перерисовка каждый кадр.
