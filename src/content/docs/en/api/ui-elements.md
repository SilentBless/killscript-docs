---
title: Elements
description: "VisualElement, text, images, input fields, scrolling, and pointer events."
---

:::note[Current build]
This page describes the API behavior in the current game version.
:::

<span class="api-context api-context--client">Client only</span> Elements are created and loaded through [UI](../ui/).

## VisualElement

The base type of every UI element. Depending on the actual UXML element, query methods automatically return a more specific type: `TextElement`, `ImageElement`, `TextFieldElement`, `ScrollView`, or `DotViewElement`.

### Properties

| Property | Access | Description |
|---|---|---|
| `childCount` | get | Number of direct children |
| `hasChildren` | get | Whether the element has children |
| `height` | get | Resolved on-screen height |
| `name` | get | Name from UXML or `SetName()` |
| `style` | get | [ElementStyle](../ui-style/) object |
| `visible` | get/set | Whether the element participates in rendering |
| `width` | get | Resolved on-screen width |
| `windowScale` | get | Scale of the HUD window containing the element |

### Element tree

```lua
parent:Add(child: VisualElement)
parent:Clear()
element:RemoveFromHierarchy()
element:Delete(): bool
element:SendToBack()
```

- `Add()` adds an element to a container;
- `Clear()` detaches all direct children;
- `RemoveFromHierarchy()` detaches the element without permanently deleting it;
- `Delete()` permanently deletes the element and its wrappers;
- `SendToBack()` moves the element behind its siblings.

### Queries

```lua
element:GetChild(name: string): VisualElement
element:GetChildAt(index: number): VisualElement
```

`GetChild()` recursively searches for a named descendant. `GetChildAt()` returns a direct child using a zero-based index. Both methods return `nil` when no element is found.

### Classes and name

```lua
element:AddToClassList(className: string)
element:EnableInClassList(className: string, enabled: boolean)
element:SetName(name: string)
```

USS selectors use classes. `EnableInClassList()` is convenient for states such as `active`, `warning`, or `disabled`.

### Pointer and events

Absolute UI may ignore the pointer by default. Enable interaction before registering events:

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

| Method | Callback argument | Purpose |
|---|---|---|
| `OnClick(callback)` | `clickCount` | Completed click |
| `OnPointerDown(callback)` | `clickCount` | Pointer button press |
| `OnMouseEnter(callback)` | none | Pointer entered the element |
| `OnMouseLeave(callback)` | none | Pointer left the element |

Registering again replaces the previous callback for the same event. Pass `nil` to remove the handler.

```lua
element:GetPickingMode(): number
element:SetPickingMode(mode: number)
```

| Mode | Number | Behavior |
|---|---:|---|
| `Position` | `0` | The element participates in pointer handling |
| `Ignore` | `1` | The element ignores the pointer |

`EnableMouseEvents()` is a shortcut for enabling `Position` mode.

### Cursor and border

```lua
element:SetBorderColor(color: Color)
element:SetCursor(cursorName: string): bool
```

`SetCursor()` returns `false` for an unknown name. Supported names are:

`arrow`, `hand`, `text`, `move`, `resize-horizontal`, `resize-vertical`, `pipette`.

## TextElement

Returned for `Label` and other text elements.

```lua
label.text = "Ready"
print(label.text)
```

| Property | Type | Access |
|---|---|---|
| `text` | `string` | get/set |

## ImageElement

Returned for a UXML `Image` element.

```lua
local icon = root:GetChild("imgIcon")
icon.texture = Textures:GetTexture("Icon.png")
```

| Property | Type | Access |
|---|---|---|
| `texture` | [Texture](../texture/) | get/set |

## TextFieldElement

```lua
local input = root:GetChild("txtSearch")
input.value = "query"
input:Focus()
```

| Property | Type | Access |
|---|---|---|
| `IsFocused` | `boolean` | get |
| `value` | `string` | get/set |

`Focus()` gives the field keyboard focus.

## DotViewElement

A specialized multi-dot indicator.

| Property | Type | Access |
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

`Reset()` resets the current view state.

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

- `CanScrollByDelta()` checks whether content can move in the requested direction;
- `ScrollByDelta()` performs a scroll step and reports whether the position changed;
- auto-scroll keeps the view at the end when content is added;
- `RefreshVerticalScrollerVisibility()` recalculates vertical scrollbar visibility.

## Related pages

- [UI and UXML](../ui/)
- [Styles](../ui-style/)
- [Animations](../ui-animation/)
