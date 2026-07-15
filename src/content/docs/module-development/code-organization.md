---
title: Организация Lua-кода
description: Точки входа, локальное состояние, функции обновления и безопасный жизненный цикл модуля.
---

KILLSCRIPT запускает `scripts/main.lua` как клиентскую точку входа. У [Reflex-модуля](../../reflex/architecture/) отдельно запускается `scripts/server.lua`. Каждый файл лучше строить из локального состояния, небольших функций и одного блока инициализации.

## Базовая структура main.lua

```lua
local State = {
    enabled = true,
    frames = 0
}

local function Update()
    State.frames = State.frames + 1

    if not State.enabled then
        return
    end

    ImGui:DrawDebugText(
        "Frames: " .. tostring(State.frames)
    )
end

local function Initialize()
    print("Module initialized")
    Scheduler:OnFrame(Update)
end

Initialize()
```

Такой порядок легко читать:

1. состояние;
2. вспомогательные функции;
3. обработчики;
4. инициализация в конце файла.

## Используйте local

Объявляйте переменные и функции через `local`, если они не должны быть глобальными:

```lua
local PanelVisible = true

local function TogglePanel()
    PanelVisible = not PanelVisible
end
```

Это защищает код от случайного пересечения имён и делает зависимости явными.

## Проверяйте nil на границах API

Многие методы, включая методы [`Agents`](../../api/agent/), корректно возвращают `nil`, когда объект пока отсутствует:

```lua
local localAgent = Agents:GetLocalAgent()

if localAgent == nil then
    return
end
```

Проверяйте результат сразу после получения. Это особенно важно во время загрузки карты, смерти, наблюдения и смены раунда.

## Не делайте тяжёлую работу каждый кадр

[`Scheduler:OnFrame()`](../../api/scheduler/#onframe) вызывается с частотой FPS. Загружайте [текстуры](../../api/texture/), [звуки](../../api/audio/) и [UXML](../../api/ui/) один раз при инициализации, а в кадре обновляйте только нужные значения.

```lua
local Icon = Textures:GetTexture("Icon.png")

Scheduler:OnFrame(function()
    if Icon ~= nil then
        ImGui:DrawTexture(Icon, Rect.new(20, 20, 64, 64))
    end
end)
```

## Учитывайте hot reload

После сохранения папочного модуля создаётся новый экземпляр Lua-кода. Не рассчитывайте, что локальные переменные переживут reload. Постоянные пользовательские данные храните в [`Storage`](../../api/storage/), а настройки — в [`Config`](../../api/config/).

При создании объектов, которые можно удалить явно, сохраняйте ссылку:

```lua
local Line = WorldVisuals:CreateLineRenderer()

-- Когда объект больше не нужен:
WorldVisuals:RemoveObject(Line)
Line = nil
```

## Разделяйте client и server

В Reflex не копируйте один и тот же update-код в обе точки входа:

- `main.lua` — ввод, интерфейс, локальные эффекты и пользовательские данные;
- `server.lua` — серверные решения и `Scheduler:OnTick()`;
- [`Network`](../../api/network/) — только необходимые сообщения между ними.

Подробная схема приведена в разделе [Reflex](../../reflex/architecture/).
