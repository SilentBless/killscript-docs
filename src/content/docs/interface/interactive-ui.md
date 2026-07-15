---
title: События, стили и анимации
description: Интерактивное UXML-окно с кнопкой, классами состояния и плавным появлением.
---

Построим интерактивное окно, которое освобождает курсор, блокирует управление игроком и закрывается кнопкой.

## UXML

```xml title="ui/Menu.uxml"
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <Style src="./Menu.uss" />
    <ui:VisualElement name="Root" class="menu">
        <ui:Label text="Module menu" class="menu__title" />
        <ui:Button name="btnClose" text="Close" class="menu__button" />
    </ui:VisualElement>
</ui:UXML>
```

## USS

```css title="ui/Menu.uss"
.menu {
    position: absolute;
    left: 50%;
    top: 50%;
    width: 360px;
    padding: 18px;
    background-color: rgba(10, 15, 24, 0.96);
    border-top-left-radius: 12px;
    border-top-right-radius: 12px;
    border-bottom-left-radius: 12px;
    border-bottom-right-radius: 12px;
}

.menu__title {
    color: white;
    font-size: 22px;
    -unity-font-style: bold;
}

.menu__button {
    height: 38px;
    margin-top: 16px;
}
```

## Открытие и закрытие

```lua title="scripts/main.lua"
local Root = UI:BuildFromUxmlInteractive("Menu.uxml")

if Root ~= nil then
    local closeButton = Root:GetChild("btnClose")

    Root.style.opacity = 0
    Root.style.translate = Vector3.new(0, 18, 0)

    Root:ScheduleAnimation({
        duration = 0.2,
        replaceExisting = true,
        onUpdate = function(t)
            Root.style.opacity = t
            Root.style.translate = Vector3.new(0, (1 - t) * 18, 0)
        end
    })

    UI:OpenWindow(Root, true, true, true, true)

    if closeButton ~= nil then
        closeButton:EnableMouseEvents()
        closeButton:OnClick(function()
            UI:CloseWindow(Root, true)
        end)
    end
end
```

Параметры `OpenWindow()` в примере:

1. освобождают курсор;
2. блокируют управление персонажем;
3. скрывают перекрывающий UI;
4. размывают фон.

`CloseWindow()` освобождает эти режимы. Не скрывайте такое окно только через `visible = false`, иначе захваченный ввод может остаться у окна.

## Классы состояния

Постоянное оформление держите в USS, а Lua пусть переключает классы:

```css
.menu.warning {
    background-color: rgba(80, 20, 20, 0.96);
}
```

```lua
Root:EnableInClassList("warning", true)
```

Так проще поддерживать тему, чем присваивать десятки стилевых свойств из Lua.

Справочник: [UXML](../../api/ui/), [элементы и события](../../api/ui-elements/), [стили](../../api/ui-style/) и [анимации](../../api/ui-animation/).
