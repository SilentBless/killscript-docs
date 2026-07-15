---
title: Events, styles, and animations
description: Build an interactive UXML window with a button, state classes, and a smooth entrance.
---

This example opens a window that releases the cursor, blocks player controls, and closes from a button.

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

## Open and close

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

The `OpenWindow()` flags in this example release the cursor, block player input, hide overlapping UI, and blur the background.

`CloseWindow()` releases these modes. Do not hide such a window only with `visible = false`, or it may retain captured input.

## State classes

Keep persistent styling in USS and toggle state classes from Lua:

```css
.menu.warning {
    background-color: rgba(80, 20, 20, 0.96);
}
```

```lua
Root:EnableInClassList("warning", true)
```

This is easier to maintain than assigning many style properties from Lua.

Reference: [UXML](../../api/ui/), [elements and events](../../api/ui-elements/), [styles](../../api/ui-style/), and [animations](../../api/ui-animation/).
