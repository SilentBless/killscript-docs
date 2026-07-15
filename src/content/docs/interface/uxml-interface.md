---
title: Первый интерфейс на UXML
description: Постоянная UXML-панель, USS-стили и обновление элементов из Lua.
---

Создадим постоянную панель со статусом матча. Проекту понадобятся три файла:

```text
MyStatus/
├── scripts/main.lua
└── ui/
    ├── StatusPanel.uxml
    └── StatusPanel.uss
```

## Разметка

```xml title="ui/StatusPanel.uxml"
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <Style src="./StatusPanel.uss" />
    <ui:VisualElement name="Root" class="status-panel">
        <ui:Label name="lblTitle" text="MATCH" class="status-panel__title" />
        <ui:Label name="lblValue" text="Loading..." class="status-panel__value" />
    </ui:VisualElement>
</ui:UXML>
```

У дерева есть один корневой `VisualElement`. Именованные элементы затем находятся из Lua.

## Стили

```css title="ui/StatusPanel.uss"
.status-panel {
    position: absolute;
    left: 24px;
    top: 160px;
    width: 240px;
    padding: 14px;
    background-color: rgba(8, 13, 20, 0.9);
    border-top-left-radius: 10px;
    border-top-right-radius: 10px;
    border-bottom-left-radius: 10px;
    border-bottom-right-radius: 10px;
}

.status-panel__title {
    color: rgba(255, 255, 255, 0.55);
    font-size: 11px;
}

.status-panel__value {
    margin-top: 4px;
    color: rgb(255, 255, 255);
    font-size: 20px;
    -unity-font-style: bold;
}
```

## Lua

```lua title="scripts/main.lua"
local Root = UI:BuildFromUxmlAbsolute("StatusPanel.uxml")
local ValueLabel = nil

if Root ~= nil then
    ValueLabel = Root:GetChild("lblValue")
end

Scheduler:OnFrame(function()
    if ValueLabel == nil then
        return
    end

    ValueLabel.text =
        "Round " .. tostring(DefusalGame.RoundId)
end)
```

Панель создаётся один раз. Каждый кадр меняется только текст существующего `TextElement`.

## Выбор способа построения

- `BuildFromUxmlAbsolute()` — фиксированный HUD без взаимодействия;
- `BuildFromUxmlInteractive()` — панель с обработкой указателя;
- `BuildFromUxml()` — настраиваемое HUD-окно;
- `CreateFromUxml()` — шаблон, который нужно вручную добавить в другое дерево.

## Удаление

Когда интерфейс больше не нужен:

```lua
if Root ~= nil then
    Root:Delete()
    Root = nil
    ValueLabel = nil
end
```

Не используйте ссылки на элементы после `Delete()`.

Справочник: [UXML](../../api/ui/), [элементы](../../api/ui-elements/) и [стили](../../api/ui-style/).
