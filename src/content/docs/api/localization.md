---
title: Localization
description: Строки модуля, игровые переводы и английский fallback в KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha на английском и русском языках. Модульные строки, игровые термины, fallback и отсутствующий ключ подтверждены в игре.
:::

`Localization` возвращает перевод для текущего языка игры. API доступен только в клиентской Lua-части; в Reflex `server.lua` глобальный объект равен `nil`.

## localization.csv

Файл лежит в корне модуля и использует точку с запятой как разделитель:

```csv
Keys;English (United States);Russian
PanelTitle;Status panel;Панель состояния
FallbackOnly;English fallback;
```

Первая колонка содержит ключи, остальные — названия языков и переводы. Кириллица в UTF-8 загружается корректно.

## GetTranslation

```lua
Localization:GetTranslation(term: string): string
```

Возвращает строку текущего языка:

```lua
local title = Localization:GetTranslation("PanelTitle")
```

Для примера выше результатом будет `Status panel` на английском и `Панель состояния` на русском.

## Fallback на английский

Если ячейка текущего языка пуста, возвращается значение из `English (United States)`:

```lua
local text = Localization:GetTranslation("FallbackOnly")
-- На русском: "English fallback"
```

Поэтому английскую колонку следует заполнять для каждого ключа.

## Отсутствующий ключ

Если ключ не найден, метод возвращает сам аргумент:

```lua
local text = Localization:GetTranslation("UnknownTerm")
-- "UnknownTerm"
```

Это позволяет безопасно показывать читаемый ключ, но опечатка не создаёт Lua-ошибку.

## Игровые переводы

Метод ищет не только строки модуля, но и глобальные термины игры. На русском языке подтверждены, например:

| Ключ | Результат |
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

## Практический шаблон

Получайте пользовательские строки при построении или обновлении интерфейса:

```lua
local Text = {
    Title = Localization:GetTranslation("PanelTitle"),
    Cancel = Localization:GetTranslation("Cancel")
}
```

Если язык может изменяться без перезапуска модуля, получите переводы повторно при обновлении интерфейса, а не храните их навсегда.

## Частые ошибки

- запятая вместо `;` в `localization.csv`;
- отсутствующая колонка `English (United States)` для fallback;
- ожидание `nil` для неизвестного ключа — фактически возвращается сам ключ;
- вызов `Localization` из `server.lua`.
