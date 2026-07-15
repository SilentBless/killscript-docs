---
title: Assets and localization
description: Prepare images, sounds, UI files, and translations for a KILLSCRIPT module.
---

Organize assets by purpose:

```text
MyModule/
├── images/
│   ├── Icon.png
│   └── Hud/Background.png
├── sounds/
│   └── Alert.ogg
├── ui/
│   ├── Panel.uxml
│   └── Panel.uss
└── localization.csv
```

## Images

PNG, JPG, and JPEG are supported. Lua paths are normally relative to `images`:

```lua
local background = Textures:GetTexture("Hud/Background.png")

if background == nil then
    print("Background was not loaded")
end
```

Use exact casing, an extension, and forward slashes. Images above `4096 × 4096` or `10 MiB` are skipped.

## Sounds

WAV, MP3, and OGG are supported:

```lua
local alert = Sounds:GetSound("Alert.ogg")

if alert ~= nil then
    Sounds:PlaySound2D(alert, 0.7, 1)
end
```

Load the asset once rather than inside every frame or event.

## UXML and USS

Store markup and styles under `ui`. A UXML file can include a neighboring USS file:

```xml
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <Style src="./Panel.uss" />
    <ui:VisualElement name="Root" class="panel" />
</ui:UXML>
```

An image path in `ui/Panel.uss` is relative to that USS file:

```css
.panel {
    background-image: url("../images/Hud/Background.png");
}
```

## Localization

The root `localization.csv` uses `;` as its delimiter:

```csv
Keys;English (United States);Russian
PanelTitle;Status;Состояние
Enabled;Enabled;Включено
```

Read a string in Lua:

```lua
local title = Localization:GetTranslation("PanelTitle")
```

An empty current-language cell falls back to English. A completely missing key returns the key itself.

## Description images

- `images/Icon.png`: module icon;
- `images/DescriptionImage.png`: large description image.

## Before publishing

- remove unused source assets;
- verify path casing against file names;
- fill the English value for every localization key;
- keep the total package within the module size limit;
- test after copying into a clean folder.

Reference: [Texture](../../api/texture/), [Audio](../../api/audio/), [Localization](../../api/localization/), and [UXML](../../api/ui/).
