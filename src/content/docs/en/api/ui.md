---
title: UXML
description: "Persistent UXML interfaces: create panels and HUD windows, then manage their lifecycle."
---

:::note[Current build]
This page describes the API behavior in the current game version.
:::

<span class="api-context api-context--client">Client only</span> `UI` is unavailable in a Reflex module's `server.lua`.

## When to use UI

`UI` loads persistent interfaces from UXML and lets Lua update them. It is suited to panels, menus, lists, and interactive windows. For simple text or images that are redrawn every frame, [ImGui](../imgui/) is usually more convenient.

The UI reference is split into several pages:

- [elements and events](../ui-elements/);
- [styles](../ui-style/);
- [animations](../ui-animation/).

## How the interface is processed

The UXML loader creates a retained `VisualElement` tree that persists between frames until the module removes it. `Build*` methods immediately attach a root to a screen/HUD container, while `Create*` methods only create detached elements in memory.

After attachment, UI layout calculates sizes and positions, the renderer draws the tree, and the event system routes pointer/focus events to matching elements. Changing a property or style updates that same tree; the module does not need to redraw the whole interface every frame.

## Where the result appears

| Creation method | Where the element lives |
|---|---|
| `BuildFromUxmlAbsolute()` | In the root screen layer. UXML/USS styles control placement; pointer input is disabled by default. |
| `BuildFromUxmlInteractive()` | In the same screen layer, with pointer interaction enabled. |
| `BuildFromUxml()` / `BuildFromUxmlAbsoluteCenter()` | In a separate HUD window exposed in the player's interface editor. |
| `CreateFromUxml()` / `CreateVisualElement()` / `CreateLabel()` | Nowhere until the element is added to an already displayed tree with `Add()`. |

`OpenWindow()` does not create a second copy of the interface. It opens the supplied element as an exclusive window and applies the selected cursor, player-input, blur, and overlapping-UI rules.

## Quick start

Place UXML and USS files in the module's `ui/` directory. Paths passed from Lua are relative to that directory.

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

`BuildFromUxmlAbsolute()` immediately adds the root to the screen. Unlike ImGui, this code does not need to run every frame.

## UI state

These properties are read-only.

| Property | Type | Meaning |
|---|---|---|
| `UI.IsConsoleVisible` | `boolean` | Whether the in-game console is open |
| `UI.IsCursorUnlocked` | `boolean` | Whether the cursor is released |
| `UI.IsExclusiveWindowOpen` | `boolean` | Whether an exclusive game or module window is open |
| `UI.IsWindowOpen` | `boolean` | Whether this module has a window open through `OpenWindow()` |

## Loading UXML

### BuildFromUxmlAbsolute

```lua
UI:BuildFromUxmlAbsolute(path: string): VisualElement
```

Loads UXML and adds it to the root UI. The element does not intercept the pointer until interaction is explicitly enabled. Returns the root, or `nil` if the file cannot be loaded.

### BuildFromUxmlInteractive

```lua
UI:BuildFromUxmlInteractive(path: string): VisualElement
```

Loads UXML, adds it to the screen, and immediately enables pointer handling. Use it for buttons, text fields, and other interactive panels.

### BuildFromUxmlAbsoluteCenter

```lua
UI:BuildFromUxmlAbsoluteCenter(
    path: string,
    id: string,
    title: string
): VisualElement
```

Creates a HUD window whose initial position is centered. `id` must be non-empty and unique within the module.

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

Creates a configurable HUD window with the requested anchor and initial position. Coordinates accept UI Toolkit values such as `"24px"` or `"10%"`.

Supported `anchorMode` values:

| Value | Value | Value |
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

Creates a tree from UXML without adding it to the screen. This is useful for repeated list rows: create an element, then add it to a container with `parent:Add(child)`.

### Creating elements without UXML

```lua
UI:CreateVisualElement(): VisualElement
UI:CreateLabel(): TextElement
```

Creates an empty container or text element. Add it to an existing tree with `Add()`.

:::caution[Element limit]
A module can create or obtain wrappers for at most 1,024 UI elements. Elements found inside a tree count toward the limit. Delete trees that are no longer needed with `Delete()`.
:::

## Queries and lifecycle

```lua
UI:Q(root: VisualElement, id: string): VisualElement
root:GetChild(name: string): VisualElement
root:GetChildAt(index: number): VisualElement
```

`Q()` and `GetChild()` recursively find a descendant by `name` and return `nil` when no match exists. `GetChildAt()` accesses a direct child using a zero-based index.

:::caution[Known issue in the current build]
`GetChildAt()` raises a Lua error for an out-of-range index instead of returning `nil`. Check `index >= 0` and `index < element.childCount` before calling it. The issue has been reported to the developer and will be fixed in a future build.
:::

```lua
UI:RemoveFromHierarchy(root: VisualElement)
root:RemoveFromHierarchy()
```

Detaches the element from its current parent while keeping the object available for later reuse.

```lua
UI:Delete(element: VisualElement): bool
element:Delete(): bool
```

Permanently deletes the element and the wrappers created for its tree. Do not use old references after a successful deletion.

## Exclusive windows

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

Opens an element as the module's current exclusive window and applies the selected modes. Returns `false` when the element is unavailable, another exclusive window is already open, or player input is already locked by another window.

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

Closes the current window and releases the resources it acquired. With `hideVisual = true`, the element is hidden as well. Returns `false` if the supplied element is not the current window.

### Controlling individual modes

Each method returns `true` when the mode was applied or released for the current window.

| Enable | Disable | Effect |
|---|---|---|
| `UI:LockCursor(element)` | `UI:UnlockCursor(element)` | Capture or release the cursor |
| `UI:LockPlayerInput(element)` | `UI:UnlockPlayerInput(element)` | Lock player controls |
| `UI:HideOverlappingUI(element)` | `UI:ShowOverlappingUI(element)` | Hide overlapping game UI |
| `UI:BlurBackground(element)` | `UI:UnblurBackground(element)` | Blur the background |

These resources are scoped to the active window. The methods return `false` for a regular panel that was not opened with `OpenWindow()`.

## HUD window visibility

```lua
UI:SetWindowVisibilityTypes(
    element: VisualElement,
    visibilityTypes: table
): bool
```

Sets the modes in which a HUD window is available. The method only works with elements created through `BuildFromUxml()` or `BuildFromUxmlAbsoluteCenter()`.

```lua
UI:SetWindowVisibilityTypes(panel, {
    WindowVisibilityType.Match,
    WindowVisibilityType.Spectate,
})
```

| Value | Number | Mode |
|---|---:|---|
| `WindowVisibilityType.Match` | `0` | Regular match |
| `WindowVisibilityType.Spectate` | `1` | Spectating |
| `WindowVisibilityType.Killcam` | `2` | Killcam |

## Coordinates and strings

```lua
UI:GetMousePosition(): Vector2
UI:ViewportToUiPoint(point: Vector3): Vector2
UI:UiToViewportPoint(point: Vector2): Vector2
UI:ToUpperInvariant(text: string): string
```

- `GetMousePosition()` returns the current cursor position;
- `ViewportToUiPoint()` converts a viewport position to UI coordinates;
- `UiToViewportPoint()` performs the inverse conversion;
- `ToUpperInvariant()` converts text to uppercase without depending on the system language. It returns `nil` for `nil`.

:::caution[Known issue in the current build]
`GetMousePosition()` currently returns raw screen coordinates rather than UI Toolkit panel coordinates. Do not use the result directly for layout or pass it to `UiToViewportPoint()` without your own conversion. The issue has been reported to the developer and will be fixed in a future build.
:::

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

Populates the standard rank display elements from an agent, or clears them.

## Next steps

- [VisualElement and specialized elements](../ui-elements/)
- [ElementStyle](../ui-style/)
- [Animations and Tweener](../ui-animation/)
