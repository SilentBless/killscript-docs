---
title: Стили
description: "ElementStyle: размеры, позиция, цвет, фон и визуальные преобразования UI-элементов."
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> Стиль доступен через `element.style`.

Стиль меняет внешний вид сразу, но результат виден только у элемента, добавленного в отображаемое UI-дерево. Например, `UI:CreateVisualElement()` создаёт объект в памяти; после настройки его всё ещё нужно добавить через `parent:Add(element)` либо получить корень одним из отображающих методов [UI](../ui/#где-появляется-результат).

## Быстрый пример

```lua
local panel = UI:CreateVisualElement()

panel.style.width = 320
panel.style.height = 120
panel.style.left = 24
panel.style.top = 160
panel.style.backgroundColor = Color.new(0.03, 0.05, 0.08, 0.92)
panel.style.borderRadius = 12
panel.style.opacity = 1
```

Изменения применяются сразу. Для сложной постоянной разметки удобнее задавать основную часть оформления в USS, а из Lua менять только состояние.

## Размеры

Числовые значения задаются в пикселях, если в названии свойства явно не указано `Percent`.

| Свойство | Доступ | Назначение |
|---|---|---|
| `width` | get/set | Ширина в пикселях |
| `height` | get/set | Высота в пикселях |
| `widthPercent` | get/set | Ширина в процентах |
| `heightPercent` | get/set | Высота в процентах |
| `minWidth` | get/set | Минимальная ширина |
| `minHeight` | get/set | Минимальная высота |
| `maxWidth` | get/set | Максимальная ширина |
| `maxHeight` | get/set | Максимальная высота |

## Позиция и отступы

| Свойство | Доступ | Назначение |
|---|---|---|
| `left` | get/set | Отступ слева |
| `right` | get/set | Отступ справа |
| `top` | get/set | Отступ сверху |
| `bottom` | get/set | Отступ снизу |
| `marginLeft` | get/set | Внешний отступ слева |
| `marginRight` | get/set | Внешний отступ справа |
| `marginTop` | get/set | Внешний отступ сверху |
| `marginBottom` | get/set | Внешний отступ снизу |

## Цвет и видимость

| Свойство | Доступ | Назначение |
|---|---|---|
| `color` | get/set | Цвет текста |
| `backgroundColor` | get/set | Цвет фона |
| `tintColor` | get/set | Цветовая маска изображения |
| `opacity` | get/set | Общая прозрачность |
| `display` | get/set | Участие элемента в раскладке |
| `borderRadius` | set | Радиус всех углов |
| `backgroundImage` | set | Фоновая [Texture](../texture/) |

`borderRadius` и `backgroundImage` доступны только для записи. Попытка прочитать их вызывает ошибку доступа.

### DisplayStyle

| Значение | Число | Поведение |
|---|---:|---|
| `DisplayStyle.Flex` | `0` | Элемент отображается и занимает место |
| `DisplayStyle.None` | `1` | Элемент скрыт и исключён из раскладки |

Для временного скрытия без перестройки раскладки можно использовать `element.visible`.

## Фоновое изображение

| Свойство | Доступ | Назначение |
|---|---|---|
| `backgroundPositionX` | get/set | Горизонтальная привязка фона |
| `backgroundPositionY` | get/set | Вертикальная привязка фона |
| `backgroundSize` | get/set | Масштабирование фона |

### BackgroundPositionKeyword

| Значение | Число |
|---|---:|
| `BackgroundPositionKeyword.Left` | `0` |
| `BackgroundPositionKeyword.Center` | `1` |
| `BackgroundPositionKeyword.Right` | `2` |
| `BackgroundPositionKeyword.Top` | `3` |
| `BackgroundPositionKeyword.Bottom` | `4` |

### BackgroundSizeType

| Значение | Число | Поведение |
|---|---:|---|
| `BackgroundSizeType.Contain` | `0` | Вписывает изображение полностью |
| `BackgroundSizeType.Cover` | `1` | Заполняет область с возможной обрезкой |
| `BackgroundSizeType.Auto` | `2` | Использует автоматический размер |

```lua
panel.style.backgroundImage = Textures:GetTexture("Panel.png")
panel.style.backgroundPositionX = BackgroundPositionKeyword.Center
panel.style.backgroundPositionY = BackgroundPositionKeyword.Center
panel.style.backgroundSize = BackgroundSizeType.Cover
```

## Преобразования

| Свойство | Тип | Назначение |
|---|---|---|
| `translate` | `Vector3` | Смещение по X и Y; Z игнорируется |
| `scale` | `Vector3` | Масштаб по осям |
| `rotateAngle` | `number` | Поворот в градусах |
| `rotate` | `number` | Эквивалентное поле поворота в градусах |

```lua
panel.style.translate = Vector3.new(0, 12, 0)
panel.style.scale = Vector3.new(1.05, 1.05, 1)
panel.style.rotateAngle = 3
```

Для нового кода используйте `rotateAngle`: оно яснее показывает единицу измерения.

## Анимация стилей

Стилевые свойства можно плавно менять из callback `onUpdate`:

```lua
panel:ScheduleAnimation({
    duration = 0.2,
    onUpdate = function(t)
        panel.style.opacity = t
        panel.style.translate = Vector3.new(0, (1 - t) * 16, 0)
    end,
})
```

Полное описание параметров находится на странице [UI-анимации](../ui-animation/). Значения `translate` и цвета используют [Vector3](../vector3/) и [Color](../color/).
