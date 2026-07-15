local PREFIX = "[API Validation][ReflexServer][RuntimeContext]"
local HasRun = false
local Running = false
local TestIndex = 1
local Passed = 0
local Failed = 0

local function Describe(value)
    if value == nil then
        return "nil"
    end
    return type(value) .. "(" .. tostring(value) .. ")"
end

local function Send(status, name, detail, complete)
    print(PREFIX .. " " .. status .. " " .. name .. " -> " .. detail)
    Network:SendTable({
        ApiValidation = true,
        Status = status,
        Name = name,
        Detail = detail,
        Complete = complete == true
    })
end

local function ExpectAvailable(name, callback)
    local ok, value = pcall(callback)
    if ok then
        Passed = Passed + 1
        Send("PASS", name, Describe(value), false)
        return
    end

    Failed = Failed + 1
    Send("FAIL", name, tostring(value), false)
end

local function ExpectUnavailable(name, callback)
    local ok, value = pcall(callback)
    if ok then
        Failed = Failed + 1
        Send("FAIL", name, "available: " .. Describe(value), false)
        return
    end

    Passed = Passed + 1
    Send("PASS", name, "unavailable: " .. tostring(value), false)
end

local Tests = {
    {
        Name = "Time.Tick",
        Mode = "available",
        Callback = function() return Time.Tick end
    },
    {
        Name = "CpuLimit.CpuCycleLimit",
        Mode = "available",
        Callback = function() return CpuLimit.CpuCycleLimit end
    },
    {
        Name = "MapInfo.MapName",
        Mode = "available",
        Callback = function() return MapInfo.MapName end
    },
    {
        Name = "Agents.GetLocalAgent",
        Mode = "available",
        Callback = function() return Agents:GetLocalAgent() end
    },
    {
        Name = "Cameras.Main",
        Mode = "unavailable",
        Callback = function() return Cameras.Main end
    },
    {
        Name = "Screen.Width",
        Mode = "unavailable",
        Callback = function() return Screen.Width end
    },
    {
        Name = "Performance.AvgFps",
        Mode = "unavailable",
        Callback = function() return Performance.AvgFps end
    },
    {
        Name = "NetworkInfo.Ping",
        Mode = "unavailable",
        Callback = function() return NetworkInfo.Ping end
    }
}

local function StartSuite()
    if HasRun then
        return
    end

    HasRun = true
    Running = true
    TestIndex = 1
    Send("BEGIN", "suite", "server context probe", false)
end

Network:OnTableReceived(function(message)
    if message
        and message.ApiValidation == true
        and message.Command == "RunRuntimeContext" then
        StartSuite()
    end
end)

Scheduler:OnTick(function()
    if not Running then
        return
    end

    local test = Tests[TestIndex]
    if test then
        if test.Mode == "available" then
            ExpectAvailable(test.Name, test.Callback)
        else
            ExpectUnavailable(test.Name, test.Callback)
        end
        TestIndex = TestIndex + 1
        return
    end

    Running = false
    Send(
        "SUMMARY",
        "suite",
        "passed=" .. Passed .. " failed=" .. Failed,
        true
    )
end)

print(PREFIX .. " LOADED")
