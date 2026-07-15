---
title: Полный Reflex-модуль
description: Готовый пример предупреждения о низком здоровье с настройками, серверным тиком и Network.
---

Соберём `HealthWarning`: сервер следит за здоровьем локального [`Agent`](../../api/agent/), а клиент показывает предупреждение. Клиент отправляет порог, сервер проверяет его и возвращает только подтверждённое состояние.

## Структура

```text
HealthWarning/
├── module.json
├── config.json
└── scripts/
    ├── main.lua
    └── server.lua
```

В `module.json` должно быть `"IsReflex": true`.

## config.json

Это обычная конфигурация модуля в формате [`Config`](../../api/config/):

```json
[
  {
    "label": "Show warning",
    "key": "Enabled",
    "type": "bool",
    "value": true
  },
  {
    "label": "Health threshold",
    "key": "Threshold",
    "type": "number",
    "value": 30,
    "min": 1,
    "max": 100
  }
]
```

## scripts/main.lua

```lua
local ServerState = {
    health = 0,
    low = false
}

local LastEnabled = nil
local LastThreshold = nil

local function SendSettings()
    LastEnabled = Config.Enabled
    LastThreshold = Config.Threshold

    Network:SendTable({
        kind = "set_settings",
        enabled = Config.Enabled,
        threshold = Config.Threshold
    })

    Network:SendTable({
        kind = "request_state"
    })
end

Network:OnTableReceived(function(data)
    if data.kind == "health_state" then
        ServerState.health = tonumber(data.health) or 0
        ServerState.low = data.low == true
    end
end)

Scheduler:Schedule(0.5, SendSettings)

Scheduler:OnFrame(function()
    if LastEnabled ~= Config.Enabled
        or LastThreshold ~= Config.Threshold then
        SendSettings()
    end

    if Config.Enabled and ServerState.low then
        ImGui:DrawText(
            "LOW HEALTH: " .. tostring(ServerState.health),
            Rect.new((Screen.Width - 360) * 0.5, 90, 360, 48),
            24,
            Color.new(1, 0.25, 0.2, 1),
            TextAnchor.MiddleCenter
        )
    end
end)
```

## scripts/server.lua

```lua
local State = {
    enabled = true,
    threshold = 30,
    health = -1,
    low = false
}

local function SendState()
    Network:SendTable({
        kind = "health_state",
        health = State.health,
        low = State.low
    })
end

Network:OnTableReceived(function(data)
    if data.kind == "set_settings" then
        local threshold = tonumber(data.threshold)

        if threshold ~= nil then
            State.threshold = math.max(1, math.min(100, threshold))
        end

        State.enabled = data.enabled == true
    elseif data.kind == "request_state" then
        SendState()
    end
end)

Scheduler:OnTick(function()
    local agent = Agents:GetLocalAgent()
    local health = 0
    local low = false

    if agent ~= nil and agent.Health ~= nil then
        health = agent.Health.CurrentHealth
        low = State.enabled
            and agent.Health.IsAlive
            and health <= State.threshold
    end

    if health ~= State.health or low ~= State.low then
        State.health = health
        State.low = low
        SendState()
    end
end)
```

## Что важно в примере

- клиент отвечает за настройки и отображение;
- сервер ограничивает порог диапазоном `1…100`;
- состояние отправляется только при изменении;
- API-объекты не передаются через [`Network`](../../api/network/);
- обе стороны имеют безопасные значения до первой синхронизации.

После сохранения выберите `HealthWarning` активным Reflex-модулем и зайдите на [пользовательский сервер](../../servers/custom-server/).

Справочник примера: [Network](../../api/network/), [Scheduler](../../api/scheduler/), [Agent](../../api/agent/), [Config](../../api/config/) и [ImGui](../../api/imgui/).
