local PREFIX = "[API Validation][ReflexClient][RuntimeContext]"
local Frame = 0
local Complete = false

Network:OnTableReceived(function(message)
    if not message or message.ApiValidation ~= true then
        return
    end

    local status = tostring(message.Status or "INFO")
    local name = tostring(message.Name or "unknown")
    local detail = tostring(message.Detail or "")
    print(PREFIX .. " " .. status .. " " .. name .. " -> " .. detail)

    if message.Complete == true then
        Complete = true
    end
end)

Scheduler:OnFrame(function()
    if Complete then
        return
    end

    Frame = Frame + 1
    if Frame == 1 or Frame == 120 or Frame == 240 then
        Network:SendTable({
            ApiValidation = true,
            Command = "RunRuntimeContext"
        })
        print(PREFIX .. " REQUEST sent")
    end
end)

print(PREFIX .. " LOADED")
