---
title: Переключатель по кнопке
description: Пользовательское действие, OnPerformed и включение или скрытие HUD-блока.
---

Задача: пользователь нажимает `F8`, а модуль переключает информационный блок.

## inputs.json

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

После сохранения игра перестроит action map модуля.

## main.lua

```lua
local PanelVisible = true
local ToggleAction = InputActions:FindAction("TogglePanel")

if ToggleAction == nil then
    print("TogglePanel action was not found")
else
    ToggleAction:OnPerformed(function()
        PanelVisible = not PanelVisible
    end)
end

Scheduler:OnFrame(function()
    if not PanelVisible then
        return
    end

    ImGui:DrawText(
        "Panel enabled",
        Rect.new(24, 140, 240, 40),
        18,
        Color.new(0.5, 1, 0.7, 1),
        TextAnchor.MiddleLeft
    )
end)
```

## Почему используется собственный флаг

В текущей сборке `InputAction:Disable()` не гарантирует отключение уже зарегистрированного `OnPerformed()`. Управляйте поведением через `PanelVisible` или отдельный `InputEnabled`.

## Для удержания

Если действие должно работать, пока кнопка нажата, проверяйте `IsPressed()` в кадре:

```lua
Scheduler:OnFrame(function()
    if ToggleAction ~= nil and ToggleAction:IsPressed() then
        ImGui:DrawDebugText("F8 is held")
    end
end)
```

Справочник: [InputAction](../../api/input-action/), [Scheduler](../../api/scheduler/) и [ImGui](../../api/imgui/).
