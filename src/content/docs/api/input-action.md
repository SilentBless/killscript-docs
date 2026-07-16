---
title: InputAction
description: Пользовательские и игровые действия ввода в Lua API KILLSCRIPT.
---

:::note[Проверено в игре]
Раздел проверен 15 июля 2026 года в KILLSCRIPT Pre-Alpha. Поиск действий, реальные нажатия, callback-функции и состояние кнопки подтверждены в игре.
:::

`InputActions` находит действия ввода, а `InputAction` позволяет читать их состояние и реагировать на нажатия. API доступен только в клиентской Lua-части. В Reflex `server.lua` глобальный объект `InputActions` равен `nil`.

`inputs.json` регистрирует привязку, но не рисует кнопку или подсказку на HUD. `OnPerformed()` только запускает callback; всё видимое поведение — открытие панели, сообщение или смену состояния — реализует сам модуль через [UI](../ui/), [ImGui](../imgui/) или другой API.

## Где обрабатывается ввод

При загрузке модуля клиент добавляет действия из `inputs.json` в общую карту ввода модулей. Игровая input system обновляет состояние `InputAction`, после чего `IsPressed()` читает текущее значение, а `OnPerformed()` вызывает подписчиков при выполнении действия.

Это локальный пользовательский ввод. Он не становится серверной командой автоматически: Reflex-модуль должен явно отправить нужное состояние через [Network](../network/), а сервер — проверить его и решить, что делать.

## Быстрый старт

Объявите кнопку в `inputs.json` в корне модуля:

```json
{
  "Actions": [
    {
      "Name": "TogglePanel",
      "Type": "Button",
      "Binding": {
        "Path": "<Keyboard>/f8"
      }
    }
  ]
}
```

Найдите действие по тому же имени в `main.lua`:

```lua
local TogglePanel = InputActions:FindAction("TogglePanel")
local PanelVisible = false

if TogglePanel ~= nil then
    TogglePanel:OnPerformed(function()
        PanelVisible = not PanelVisible
    end)
end
```

## inputs.json

Проверенный формат кнопки:

| Поле | Тип | Описание |
|---|---|---|
| `Actions` | `array` | Список действий модуля. |
| `Name` | `string` | Уникальное имя, используемое в `FindAction()`. |
| `Type` | `string` | Для обычной кнопки используйте `Button`. |
| `Binding.Path` | `string` | Путь контрола Unity Input System, например `<Keyboard>/f8`. |

После изменения `inputs.json` игра перестраивает action map модуля.

## InputActions

### FindAction

```lua
InputActions:FindAction(actionName: string): InputAction | nil
```

Возвращает действие модуля или стандартное игровое действие. Например, `UI/Cancel` возвращает игровой action `Cancel`. Если имя не найдено, возвращается `nil`.

Всегда проверяйте результат:

```lua
local action = InputActions:FindAction("TogglePanel")

if action == nil then
    print("TogglePanel action is missing")
    return
end
```

## InputAction

### IsPressed

```lua
action:IsPressed(): bool
```

Возвращает `true`, пока привязанный контрол нажат. Внутри `OnPerformed()` для нажатой кнопки метод вернул `true`, а после физического отпускания — `false`.

```lua
Scheduler:OnFrame(function()
    if action:IsPressed() then
        -- Выполняется, пока кнопка удерживается
    end
end)
```

### OnPerformed

```lua
action:OnPerformed(callback: function)
```

Регистрирует callback, который вызывается при срабатывании действия. Метод возвращает `nil`.

```lua
action:OnPerformed(function()
    print("Action performed")
end)
```

### Enable и Disable

```lua
action:Enable()
action:Disable()
```

Оба метода возвращают `nil`.

:::caution[Disable не блокирует OnPerformed]
В проверенной сборке `Disable()` не подавил пользовательское действие: последующие нажатия продолжили вызывать ранее зарегистрированный `OnPerformed()`, а внутри callback `IsPressed()` возвращал `true`. Сразу после самого вызова `Disable()` метод `IsPressed()` возвращал `false`.

Не используйте `Disable()` как надёжный способ временно отключить обработчик. Проблема передана разработчику и будет исправлена в будущей сборке.
:::

Для управляемого отключения используйте собственный флаг:

```lua
local InputEnabled = true

action:OnPerformed(function()
    if not InputEnabled then
        return
    end

    -- Обработка действия
end)

-- Позже
InputEnabled = false
```

## Частые ошибки

### Имя отличается от inputs.json

`FindAction()` ищет точное имя. `TogglePanel` и `togglePanel` не следует считать одной привязкой.

### Работа с nil

Отсутствующее действие возвращает `nil`. Не вызывайте методы до проверки результата.

### Использование в server.lua

Серверная часть Reflex не получает клавиатурный ввод клиента. Обработайте кнопку в `main.lua` и при необходимости передайте состояние на сервер через [Network](../network/).
