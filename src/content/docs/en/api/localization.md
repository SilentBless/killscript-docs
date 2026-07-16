---
title: Localization
description: Module strings, built-in translations, and English fallback in KILLSCRIPT.
---

:::note[Verified in game]
This page was verified on July 15, 2026, in KILLSCRIPT Pre-Alpha with English and Russian selected. Module strings, built-in terms, fallback, and a missing key were confirmed in game.
:::

`Localization` returns a translation for the game's current language. The API is client-only; its global value is `nil` in a Reflex `server.lua`.

`GetTranslation()` only returns a string and does not display it automatically. Pass the result to [UI](../ui/), [ImGui](../imgui/), [NotificationController](../notification/), or another presentation API.

## Where the string comes from

The localization system first looks for the key among module strings and game terms for the selected language. If a module translation is empty, it uses the English column; if the key is missing everywhere, the API returns the key itself. The result is a regular string that is then handled by the calling UI or another API.

## localization.csv

The file belongs in the module root and uses semicolons as separators:

```csv
Keys;English (United States);Russian
PanelTitle;Status panel;Панель состояния
FallbackOnly;English fallback;
```

The first column contains keys. The remaining headers are language names, followed by their translations. UTF-8 Cyrillic text loads correctly.

## GetTranslation

```lua
Localization:GetTranslation(term: string): string
```

Returns the string for the current language:

```lua
local title = Localization:GetTranslation("PanelTitle")
```

For the file above, the result is `Status panel` in English and `Панель состояния` in Russian.

## English fallback

When the current language cell is empty, the method returns the `English (United States)` value:

```lua
local text = Localization:GetTranslation("FallbackOnly")
-- In Russian: "English fallback"
```

Fill the English column for every key.

## Missing key

When a key does not exist, the method returns the argument unchanged:

```lua
local text = Localization:GetTranslation("UnknownTerm")
-- "UnknownTerm"
```

This gives the UI a readable fallback, but a typo does not raise a Lua error.

## Built-in game translations

The method searches both module strings and the game's global terms. These results were confirmed with Russian selected:

| Key | Result |
|---|---|
| `Play` | `Играть` |
| `Settings` | `Настройки` |
| `Back` | `Назад` |
| `Cancel` | `Отмена` |
| `Buy` | `Купить` |
| `Close` | `Закрыть` |

```lua
local cancelText = Localization:GetTranslation("Cancel")
```

## Practical pattern

Resolve user-facing strings when building or refreshing the interface:

```lua
local Text = {
    Title = Localization:GetTranslation("PanelTitle"),
    Cancel = Localization:GetTranslation("Cancel")
}
```

If the language can change without restarting the module, resolve the strings again during an interface refresh instead of caching them forever.

## Common mistakes

- using commas instead of `;` in `localization.csv`;
- omitting the `English (United States)` fallback column;
- expecting `nil` for an unknown key—the key itself is returned;
- calling `Localization` from `server.lua`.
