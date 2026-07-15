---
title: Настройки, ввод и данные
description: Как выбирать между Config, InputActions и Storage и связывать их в одном модуле.
---

Три механизма решают разные задачи:

| Механизм | Для чего используется |
|---|---|
| [`Config`](../../api/config/) | Настройки, которые пользователь меняет в интерфейсе модуля. |
| [`InputActions`](../../api/input-action/) | Кнопки и другие действия управления. |
| [`Storage`](../../api/storage/) | Внутренние локальные данные между включениями модуля. |

## Config: пользователь выбирает значение

`config.json` содержит JSON-массив настроек:

```json
[
  {
    "label": "Show status",
    "key": "ShowStatus",
    "type": "bool",
    "value": true
  },
  {
    "label": "Text size",
    "key": "TextSize",
    "type": "number",
    "value": 18,
    "min": 12,
    "max": 32
  }
]
```

```lua
if Config.ShowStatus then
    ImGui:DrawText(
        "Active",
        Rect.new(20, 20, 180, 40),
        Config.TextSize,
        Color.new(1, 1, 1),
        TextAnchor.MiddleLeft
    )
end
```

Не используйте `Config` как хранилище: игра заново заполняет таблицу сохранёнными настройками после изменения UI.

## InputActions: пользователь нажимает кнопку

`inputs.json`:

```json
{
  "Actions": [
    {
      "Name": "ToggleStatus",
      "Type": "Button",
      "Binding": {
        "Path": "<Keyboard>/f8"
      }
    }
  ]
}
```

`main.lua`:

```lua
local action = InputActions:FindAction("ToggleStatus")
local visible = true

if action ~= nil then
    action:OnPerformed(function()
        visible = not visible
    end)
end
```

Проверяйте `nil`: действие с другим именем или неверным описанием не будет найдено.

## Storage: модуль запоминает состояние

```lua
if Storage.StatusVisible == nil then
    Storage.StatusVisible = true
end

local visible = Storage.StatusVisible

local function Toggle()
    visible = not visible
    Storage.StatusVisible = visible
end
```

`false` является допустимым значением, поэтому начальное состояние проверяется через `== nil`, а не `if not ...`.

:::caution
`Storage` сериализуется при штатном выключении модуля. Hot reload сам по себе не является точкой сохранения.
:::

## Что передавать в Reflex server

`Config`, `InputActions` и `Storage` относятся к клиенту. Серверная часть получает собственный `Config` при загрузке, но не видит клиентский ввод и `Storage`.

Если серверу нужно актуальное клиентское состояние, отправьте небольшую проверенную таблицу через [`Network`](../../api/network/).

Подробности форматов: [Config](../../api/config/), [InputAction](../../api/input-action/) и [Storage](../../api/storage/).
