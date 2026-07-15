---
title: Ally screen labels
description: Project world positions through the camera and draw ally names with ImGui.
---

This client example retrieves allies, projects their positions into the viewport, and displays names only for points in front of the camera.

```lua
local function DrawAllyLabels()
    local camera = Cameras.Main
    local allies = Agents:GetAllies()

    if camera == nil or allies == nil then
        return
    end

    for i = 1, allies.Length do
        local ally = allies[i]

        if ally ~= nil and ally.Movement ~= nil then
            local worldPosition =
                ally.Movement.Position + Vector3.new(0, 2, 0)
            local viewport =
                camera:WorldToViewportPoint(worldPosition)

            if viewport.z > 0
                and viewport.x >= 0 and viewport.x <= 1
                and viewport.y >= 0 and viewport.y <= 1 then
                ImGui:DrawTextUV(
                    ally.Nickname,
                    Vector2.new(viewport.x, viewport.y),
                    14,
                    ally.Color,
                    TextAnchor.MiddleCenter
                )
            end
        end
    end
end

Scheduler:OnFrame(DrawAllyLabels)
```

## Important details

- `Array` is indexed from `1` through `Length`;
- `WorldToViewportPoint()` returns `z < 0` behind the camera;
- viewport X and Y are normalized;
- the two-meter offset places a label above the agent position;
- `DrawTextUV()` accepts the same viewport coordinates.

Use the agent visibility and occlusion properties when hidden objects should not expose undefined data.

Reference: [Camera](../../api/camera/), [Agent](../../api/agent/), [Array](../../api/array/), and [ImGui](../../api/imgui/).
