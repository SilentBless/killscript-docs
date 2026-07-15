---
title: Your first UXML interface
description: Create a persistent UXML panel, apply USS styles, and update elements from Lua.
---

We will build a persistent match-status panel using three files:

```text
MyStatus/
├── scripts/main.lua
└── ui/
    ├── StatusPanel.uxml
    └── StatusPanel.uss
```

## Markup

```xml title="ui/StatusPanel.uxml"
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <Style src="./StatusPanel.uss" />
    <ui:VisualElement name="Root" class="status-panel">
        <ui:Label name="lblTitle" text="MATCH" class="status-panel__title" />
        <ui:Label name="lblValue" text="Loading..." class="status-panel__value" />
    </ui:VisualElement>
</ui:UXML>
```

The tree has one root `VisualElement`. Lua looks up named descendants later.

## Styles

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

The panel is built once. Each frame changes only the existing `TextElement` text.

## Choosing a build method

- `BuildFromUxmlAbsolute()`: fixed non-interactive HUD;
- `BuildFromUxmlInteractive()`: pointer-enabled panel;
- `BuildFromUxml()`: configurable HUD window;
- `CreateFromUxml()`: template added manually to another tree.

## Deletion

When the interface is no longer required:

```lua
if Root ~= nil then
    Root:Delete()
    Root = nil
    ValueLabel = nil
end
```

Do not use element references after `Delete()`.

Reference: [UXML](../../api/ui/), [elements](../../api/ui-elements/), and [styles](../../api/ui-style/).
