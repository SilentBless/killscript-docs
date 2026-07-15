---
title: Сохранение состояния
description: Запоминание локального состояния интерфейса через Storage без потери false.
---

Задача: модуль должен помнить, был ли его HUD скрыт при прошлом штатном выключении.

```lua
if Storage.Layout == nil then
    Storage.Layout = {
        version = 1,
        visible = true
    }
end

local Visible = Storage.Layout.visible
local ToggleAction = InputActions:FindAction("TogglePanel")

if ToggleAction ~= nil then
    ToggleAction:OnPerformed(function()
        Visible = not Visible
        Storage.Layout.visible = Visible
    end)
end

Scheduler:OnFrame(function()
    if Visible then
        ImGui:DrawDebugText("Persistent panel")
    end
end)
```

`false` не считается отсутствующим значением. Инициализируется вся таблица только при `Storage.Layout == nil`.

## Версия структуры

При изменении формата выполните простую миграцию:

```lua
if Storage.Layout == nil or Storage.Layout.version ~= 2 then
    local oldVisible = true

    if Storage.Layout ~= nil
        and Storage.Layout.visible ~= nil then
        oldVisible = Storage.Layout.visible
    end

    Storage.Layout = {
        version = 2,
        visible = oldVisible,
        compact = false
    }
end
```

## Ограничения

- сохраняются string, number, boolean и вложенные таблицы;
- userdata вроде `Vector3` нужно разложить на числа;
- присваивание `nil` удаляет ключ после сохранения;
- hot reload не сериализует текущее состояние;
- для проверки выключите модуль штатно и включите снова.

Справочник: [Storage](../../api/storage/), [InputAction](../../api/input-action/) и [Vector3](../../api/vector3/) для сериализации составных значений.
