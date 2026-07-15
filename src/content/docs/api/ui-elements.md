---
title: Элементы
description: "VisualElement, текст, изображения, поля ввода, прокрутка и события указателя."
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> Элементы создаются и загружаются через [UI](../ui/).

## VisualElement

Базовый тип любого элемента интерфейса. В зависимости от фактического элемента UXML методы поиска автоматически возвращают более точный тип: `TextElement`, `ImageElement`, `TextFieldElement`, `ScrollView` или `DotViewElement`.

### Свойства

| Свойство | Доступ | Описание |
|---|---|---|
| `childCount` | get | Количество непосредственных дочерних элементов |
| `hasChildren` | get | Есть ли дочерние элементы |
| `height` | get | Итоговая высота на экране |
| `name` | get | Имя элемента из UXML или `SetName()` |
| `style` | get | Объект [ElementStyle](../ui-style/) |
| `visible` | get/set | Участвует ли элемент в отображении |
| `width` | get | Итоговая ширина на экране |
| `windowScale` | get | Масштаб HUD-окна, внутри которого находится элемент |

### Дерево элементов

```lua
parent:Add(child: VisualElement)
parent:Clear()
element:RemoveFromHierarchy()
element:Delete(): bool
element:SendToBack()
```

- `Add()` добавляет элемент в контейнер;
- `Clear()` отсоединяет всех непосредственных потомков;
- `RemoveFromHierarchy()` отсоединяет сам элемент без окончательного удаления;
- `Delete()` окончательно удаляет элемент и его обёртки;
- `SendToBack()` перемещает элемент позади соседей.

### Поиск

```lua
element:GetChild(name: string): VisualElement
element:GetChildAt(index: number): VisualElement
```

`GetChild()` ищет именованного потомка рекурсивно. `GetChildAt()` возвращает непосредственного потомка по индексу от `0`. Оба метода возвращают `nil`, если совпадения нет.

### Классы и имя

```lua
element:AddToClassList(className: string)
element:EnableInClassList(className: string, enabled: boolean)
element:SetName(name: string)
```

Классы используются селекторами USS. `EnableInClassList()` удобно применять для состояний вроде `active`, `warning` или `disabled`.

### Указатель и события

По умолчанию абсолютный UI может игнорировать мышь. Включите взаимодействие перед регистрацией событий:

```lua
button:EnableMouseEvents()

button:OnClick(function(clickCount)
    print("Clicks: " .. tostring(clickCount))
end)

button:OnMouseEnter(function()
    button:EnableInClassList("hover", true)
end)

button:OnMouseLeave(function()
    button:EnableInClassList("hover", false)
end)
```

| Метод | Аргумент callback | Назначение |
|---|---|---|
| `OnClick(callback)` | `clickCount` | Завершённый клик |
| `OnPointerDown(callback)` | `clickCount` | Нажатие кнопки указателя |
| `OnMouseEnter(callback)` | нет | Указатель вошёл в элемент |
| `OnMouseLeave(callback)` | нет | Указатель покинул элемент |

Повторная регистрация заменяет предыдущий callback того же события. Передайте `nil`, чтобы убрать обработчик.

```lua
element:GetPickingMode(): number
element:SetPickingMode(mode: number)
```

| Режим | Число | Поведение |
|---|---:|---|
| `Position` | `0` | Элемент участвует в обработке указателя |
| `Ignore` | `1` | Элемент пропускает указатель |

`EnableMouseEvents()` является короткой формой включения режима `Position`.

### Курсор и граница

```lua
element:SetBorderColor(color: Color)
element:SetCursor(cursorName: string): bool
```

`SetCursor()` возвращает `false` для неизвестного имени. Поддерживаются:

`arrow`, `hand`, `text`, `move`, `resize-horizontal`, `resize-vertical`, `pipette`.

## TextElement

Возвращается для `Label` и других текстовых элементов.

```lua
label.text = "Ready"
print(label.text)
```

| Свойство | Тип | Доступ |
|---|---|---|
| `text` | `string` | get/set |

## ImageElement

Возвращается для UXML-элемента `Image`.

```lua
local icon = root:GetChild("imgIcon")
icon.texture = Textures:GetTexture("Icon.png")
```

| Свойство | Тип | Доступ |
|---|---|---|
| `texture` | [Texture](../texture/) | get/set |

## TextFieldElement

```lua
local input = root:GetChild("txtSearch")
input.value = "query"
input:Focus()
```

| Свойство | Тип | Доступ |
|---|---|---|
| `IsFocused` | `boolean` | get |
| `value` | `string` | get/set |

`Focus()` передаёт полю клавиатурный фокус.

## DotViewElement

Специализированный индикатор из нескольких точек.

| Свойство | Тип | Доступ |
|---|---|---|
| `count` | `number` | get/set |
| `fillToValue` | `boolean` | get/set |
| `value` | `number` | get/set |

```lua
dots.count = 5
dots.value = 3
dots.fillToValue = true
dots:Reset()
```

`Reset()` сбрасывает текущее состояние представления.

## ScrollView

```lua
scroll:CanScrollByDelta(deltaY: number): bool
scroll:ScrollByDelta(deltaY: number): bool
scroll:ScrollToTop()
scroll:ScrollToBottom()
scroll:EnableAutoScroll()
scroll:DisableAutoScroll()
scroll:RefreshVerticalScrollerVisibility()
```

- `CanScrollByDelta()` проверяет, возможно ли прокрутить содержимое в указанном направлении;
- `ScrollByDelta()` выполняет шаг прокрутки и возвращает, изменилась ли позиция;
- авто-прокрутка удерживает представление у конца при добавлении содержимого;
- `RefreshVerticalScrollerVisibility()` пересчитывает видимость вертикальной полосы.

## Связанные страницы

- [UI и UXML](../ui/)
- [Стили](../ui-style/)
- [Анимации](../ui-animation/)
