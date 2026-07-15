---
title: Ресурсы и локализация
description: Подготовка изображений, звуков, UI-файлов и переводов для модуля KILLSCRIPT.
---

Храните ресурсы по назначению:

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

## Изображения

Поддерживаются PNG, JPG и JPEG. В Lua путь обычно указывается относительно `images`:

```lua
local background = Textures:GetTexture("Hud/Background.png")

if background == nil then
    print("Background was not loaded")
end
```

Используйте точный регистр, расширение и прямые слеши. Изображения больше `4096 × 4096` или `10 MiB` загрузчик пропускает.

## Звуки

Поддерживаются WAV, MP3 и OGG:

```lua
local alert = Sounds:GetSound("Alert.ogg")

if alert ~= nil then
    Sounds:PlaySound2D(alert, 0.7, 1)
end
```

Загружайте ресурс один раз, а не при каждом кадре или событии.

## UXML и USS

Разметку и стили храните в `ui`. UXML может подключить соседний USS:

```xml
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <Style src="./Panel.uss" />
    <ui:VisualElement name="Root" class="panel" />
</ui:UXML>
```

Путь к изображению из `ui/Panel.uss` будет относительным к самому USS:

```css
.panel {
    background-image: url("../images/Hud/Background.png");
}
```

## Локализация

Корневой `localization.csv` использует `;` как разделитель:

```csv
Keys;English (United States);Russian
PanelTitle;Status;Состояние
Enabled;Enabled;Включено
```

Получение строки в Lua:

```lua
local title = Localization:GetTranslation("PanelTitle")
```

Если перевод текущего языка пуст, используется английское значение. Если ключ отсутствует полностью, возвращается сам ключ.

## Иконки описания

- `images/Icon.png` — иконка модуля;
- `images/DescriptionImage.png` — крупное изображение описания.

## Перед публикацией

- удалите неиспользуемые исходники изображений и звука;
- проверьте пути с тем же регистром, что у файлов;
- заполните английскую колонку каждого ключа;
- убедитесь, что суммарный размер не превышает лимит модуля;
- проверьте модуль после копирования в чистую папку.

Справочник: [Texture](../../api/texture/), [Audio](../../api/audio/), [Localization](../../api/localization/) и [UXML](../../api/ui/).
