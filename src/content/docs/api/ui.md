---
title: UXML
description: "Постоянный интерфейс из UXML: создание панелей, HUD-окон и управление их жизненным циклом."
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> `UI` недоступен в `server.lua` Reflex-модуля.

## Когда использовать UI

`UI` загружает постоянные интерфейсы из UXML и позволяет менять их из Lua. Он подходит для панелей, меню, списков и интерактивных окон. Для простого текста или изображения, которое полностью перерисовывается каждый кадр, обычно удобнее [ImGui](../imgui/).

UI разделён на несколько страниц:

- [элементы и события](../ui-elements/);
- [стили](../ui-style/);
- [анимации](../ui-animation/).

## Быстрый старт

Файлы UXML и USS размещаются в папке `ui/` модуля. В Lua путь указывается относительно неё.

```xml title="ui/StatusPanel.uxml"
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <Style src="./styles.uss" />
    <ui:VisualElement name="Root" class="status-panel">
        <ui:Label name="lblStatus" text="Loading..." />
    </ui:VisualElement>
</ui:UXML>
```

```css title="ui/styles.uss"
.status-panel {
    position: absolute;
    left: 24px;
    top: 160px;
    padding: 12px;
    background-color: rgba(8, 13, 20, 0.9);
}
```

```lua title="scripts/main.lua"
local root = UI:BuildFromUxmlAbsolute("StatusPanel.uxml")

if root ~= nil then
    local label = root:GetChild("lblStatus")
    label.text = "Module is active"
end
```

`BuildFromUxmlAbsolute()` сразу добавляет корень на экран. В отличие от ImGui, повторять этот код каждый кадр не нужно.

## Состояние UI

Свойства доступны только для чтения.

| Свойство | Тип | Что показывает |
|---|---|---|
| `UI.IsConsoleVisible` | `boolean` | Открыта ли игровая консоль |
| `UI.IsCursorUnlocked` | `boolean` | Освобождён ли курсор |
| `UI.IsExclusiveWindowOpen` | `boolean` | Открыто ли эксклюзивное окно игры или модуля |
| `UI.IsWindowOpen` | `boolean` | Открыто ли окно этого модуля через `OpenWindow()` |

## Загрузка UXML

### BuildFromUxmlAbsolute

```lua
UI:BuildFromUxmlAbsolute(path: string): VisualElement
```

Загружает UXML и добавляет его в корневой UI. Элемент не перехватывает мышь, пока вы явно не включите взаимодействие. Возвращает корень или `nil`, если файл не удалось загрузить.

### BuildFromUxmlInteractive

```lua
UI:BuildFromUxmlInteractive(path: string): VisualElement
```

Загружает UXML, добавляет его на экран и сразу включает обработку указателя. Используйте для кнопок, полей ввода и других интерактивных панелей.

### BuildFromUxmlAbsoluteCenter

```lua
UI:BuildFromUxmlAbsoluteCenter(
    path: string,
    id: string,
    title: string
): VisualElement
```

Создаёт HUD-окно, начальная позиция которого находится по центру. `id` должен быть непустым и уникальным внутри модуля.

### BuildFromUxml

```lua
UI:BuildFromUxml(
    path: string,
    id: string,
    title: string,
    anchorMode: string,
    posX: string,
    posY: string
): VisualElement
```

Создаёт настраиваемое HUD-окно с указанной привязкой и начальной позицией. Координаты принимают значения UI Toolkit, например `"24px"` или `"10%"`.

Допустимые `anchorMode`:

| Значение | Значение | Значение |
|---|---|---|
| `TopLeft` | `TopMiddle` | `TopRight` |
| `MiddleLeft` | `Middle` | `MiddleRight` |
| `BottomLeft` | `BottomMiddle` | `BottomRight` |

```lua
local panel = UI:BuildFromUxml(
    "StatusPanel.uxml",
    "status-panel",
    "Status",
    "TopRight",
    "24px",
    "120px"
)
```

### CreateFromUxml

```lua
UI:CreateFromUxml(path: string): VisualElement
```

Создаёт дерево из UXML, но не добавляет его на экран. Это удобно для повторяемых строк списка: создайте элемент, затем добавьте его в контейнер через `parent:Add(child)`.

### Создание без UXML

```lua
UI:CreateVisualElement(): VisualElement
UI:CreateLabel(): TextElement
```

Создаёт пустой контейнер или текстовый элемент. Их также нужно добавить в существующее дерево через `Add()`.

:::caution[Лимит элементов]
Один модуль может создать или получить обёртки не более чем для 1024 UI-элементов. В лимит входят элементы, найденные внутри дерева. Удаляйте больше не нужные деревья через `Delete()`.
:::

## Поиск и жизненный цикл

```lua
UI:Q(root: VisualElement, id: string): VisualElement
root:GetChild(name: string): VisualElement
root:GetChildAt(index: number): VisualElement
```

`Q()` и `GetChild()` рекурсивно ищут потомка по `name`. `GetChildAt()` обращается к непосредственному дочернему элементу по индексу, начиная с `0`. Если элемент не найден, возвращается `nil`.

```lua
UI:RemoveFromHierarchy(root: VisualElement)
root:RemoveFromHierarchy()
```

Отсоединяет элемент от текущего родителя, но оставляет объект пригодным для повторного добавления.

```lua
UI:Delete(element: VisualElement): bool
element:Delete(): bool
```

Полностью удаляет элемент вместе с созданными для его дерева обёртками. После успешного удаления прежние ссылки использовать нельзя.

## Эксклюзивные окна

### OpenWindow

```lua
UI:OpenWindow(
    element: VisualElement,
    unlockCursor: boolean,
    lockInput: boolean,
    hideOverlappingUI: boolean,
    blurBackground: boolean
): bool
```

Открывает элемент как текущее эксклюзивное окно модуля и применяет выбранные режимы. Возвращает `false`, если элемент недоступен, уже открыто другое эксклюзивное окно или управление уже заблокировано другим окном.

```lua
local menu = UI:BuildFromUxmlInteractive("Menu.uxml")

if menu ~= nil then
    UI:OpenWindow(menu, true, true, true, true)
end
```

### CloseWindow

```lua
UI:CloseWindow(element: VisualElement, hideVisual: boolean = true): bool
```

Закрывает текущее окно и освобождает захваченные им ресурсы. При `hideVisual = true` элемент также скрывается. Возвращает `false`, если переданный элемент не является текущим окном.

### Управление отдельными режимами

Каждый метод возвращает `true`, если режим был применён или освобождён для текущего окна.

| Включить | Выключить | Эффект |
|---|---|---|
| `UI:LockCursor(element)` | `UI:UnlockCursor(element)` | Захват или освобождение курсора |
| `UI:LockPlayerInput(element)` | `UI:UnlockPlayerInput(element)` | Блокировка управления игроком |
| `UI:HideOverlappingUI(element)` | `UI:ShowOverlappingUI(element)` | Скрытие перекрывающего игрового UI |
| `UI:BlurBackground(element)` | `UI:UnblurBackground(element)` | Размытие фона |

Эти ресурсы привязаны к активному окну. Для обычной панели, которая не открыта через `OpenWindow()`, методы возвращают `false`.

## Видимость HUD-окон

```lua
UI:SetWindowVisibilityTypes(
    element: VisualElement,
    visibilityTypes: table
): bool
```

Задаёт режимы, в которых HUD-окно доступно. Метод работает только с элементом, созданным через `BuildFromUxml()` или `BuildFromUxmlAbsoluteCenter()`.

```lua
UI:SetWindowVisibilityTypes(panel, {
    WindowVisibilityType.Match,
    WindowVisibilityType.Spectate,
})
```

| Значение | Число | Режим |
|---|---:|---|
| `WindowVisibilityType.Match` | `0` | Обычный матч |
| `WindowVisibilityType.Spectate` | `1` | Наблюдение |
| `WindowVisibilityType.Killcam` | `2` | Камера убийства |

## Координаты и строки

```lua
UI:GetMousePosition(): Vector2
UI:ViewportToUiPoint(point: Vector3): Vector2
UI:UiToViewportPoint(point: Vector2): Vector2
UI:ToUpperInvariant(text: string): string
```

- `GetMousePosition()` возвращает текущую позицию курсора в координатах UI;
- `ViewportToUiPoint()` переводит viewport-позицию в UI;
- `UiToViewportPoint()` выполняет обратное преобразование;
- `ToUpperInvariant()` переводит текст в верхний регистр без зависимости от языка системы. Для `nil` возвращает `nil`.

## PlayerRankDisplay

```lua
PlayerRankDisplay:BindAgent(
    agent: Agent,
    rankContainer: VisualElement,
    rankImage: VisualElement
)

PlayerRankDisplay:Clear(
    rankContainer: VisualElement,
    rankImage: VisualElement
)
```

Заполняет стандартные элементы отображения ранга данными агента или очищает их.

## Дальше

- [VisualElement и специализированные элементы](../ui-elements/)
- [ElementStyle](../ui-style/)
- [Анимации и Tweener](../ui-animation/)
