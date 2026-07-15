---
title: Анимации
description: "ScheduleAnimation и Tweener: плавное изменение UI, остановка и завершение анимаций."
---

:::note[Актуально для текущей сборки]
На странице описано поведение API в текущей версии игры.
:::

<span class="api-context api-context--client">Только client</span> Анимации работают с элементами, созданными через [UI](../ui/).

## ScheduleAnimation

Обе формы запускают одинаковую анимацию:

```lua
element:ScheduleAnimation(params: table): Tweener
UI:ScheduleAnimation(element: VisualElement, params: table): Tweener
```

`onUpdate` получает прогресс от `0` до `1`. API не меняет стиль автоматически: используйте прогресс для интерполяции нужных свойств.

```lua
local tween = panel:ScheduleAnimation({
    duration = 0.25,
    curve = 1,
    replaceExisting = true,

    onUpdate = function(t)
        panel.style.opacity = t
        panel.style.translate = Vector3.new(0, (1 - t) * 20, 0)
    end,

    onComplete = function()
        print("Animation complete")
    end,
})
```

## Параметры

| Ключ | Тип | Описание |
|---|---|---|
| `duration` | `number` | Длительность в секундах |
| `curve` | `number` | Числовой тип кривой; по умолчанию `1` |
| `replaceExisting` | `boolean` | Остановить предыдущую заменяемую анимацию элемента |
| `onUpdate` | `function(t)` | Вызывается при обновлении с текущим прогрессом |
| `onComplete` | `function()` | Вызывается после полного завершения |

Если `params` не передан, элемент недоступен или достигнут лимит, метод возвращает `nil`.

:::tip[Предсказуемое поведение]
Для анимаций одного и того же состояния ставьте `replaceExisting = true`. Новый переход остановит предыдущий без скачка к его конечному значению.
:::

:::caution[Лимит]
Один модуль может одновременно держать не более 128 запланированных UI-анимаций.
:::

## Tweener

Объект, возвращённый `ScheduleAnimation()`.

### IsComplete

```lua
tween:IsComplete(): boolean
```

Возвращает `true`, если анимация уже полностью завершилась.

### Stop

```lua
tween:Stop(complete: boolean = false)
```

- `Stop(false)` немедленно останавливает анимацию без перехода в конец;
- `Stop(true)` применяет конечный прогресс и завершает анимацию.

```lua
if tween ~= nil and not tween:IsComplete() then
    tween:Stop(false)
end
```

## Появление и скрытие

```lua
local function Show(element)
    element.style.display = DisplayStyle.Flex

    return element:ScheduleAnimation({
        duration = 0.2,
        replaceExisting = true,
        onUpdate = function(t)
            element.style.opacity = t
        end,
    })
end

local function Hide(element)
    return element:ScheduleAnimation({
        duration = 0.2,
        replaceExisting = true,
        onUpdate = function(t)
            element.style.opacity = 1 - t
        end,
        onComplete = function()
            element.style.display = DisplayStyle.None
        end,
    })
end
```

## Интерполяция нескольких значений

```lua
local startX = -280
local endX = 24

panel:ScheduleAnimation({
    duration = 0.35,
    replaceExisting = true,
    onUpdate = function(t)
        local x = startX + (endX - startX) * t
        panel.style.left = x
        panel.style.opacity = t
    end,
})
```

Внутри одного `onUpdate` можно изменять любое количество свойств. Это позволяет синхронно двигать, масштабировать и менять прозрачность элемента.

## Связанные страницы

- [UI и UXML](../ui/)
- [UI-элементы](../ui-elements/)
- [UI-стили](../ui-style/)
