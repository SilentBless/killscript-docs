local PREFIX = "[API Validation][ReflexServer][RuntimeBaseline]"
local HasRun = false
local Running = false
local TestIndex = 1
local Passed = 0

local function Send(status, name, detail, complete)
    print(PREFIX .. " " .. status .. " " .. name .. " -> " .. tostring(detail))
    Network:SendTable({
        ApiValidation = true,
        Status = status,
        Name = name,
        Detail = tostring(detail),
        Complete = complete == true
    })
end

local Tests = {
    {
        Name = "Time.Tick",
        Callback = function() return Time.Tick end
    },
    {
        Name = "CpuLimit.CpuCycleLimit",
        Callback = function() return CpuLimit.CpuCycleLimit end
    },
    {
        Name = "MapInfo.MapName",
        Callback = function() return MapInfo.MapName end
    },
    {
        Name = "Agents.GetLocalAgent",
        Callback = function() return Agents:GetLocalAgent() end
    }
}

local function StartSuite()
    if HasRun then
        return
    end

    HasRun = true
    Running = true
    TestIndex = 1
    Send("BEGIN", "suite", "server baseline probe", false)
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
        Send("RUN", test.Name, "starting", false)
        local value = test.Callback()
        Passed = Passed + 1
        Send("PASS", test.Name, value, false)
        TestIndex = TestIndex + 1
        return
    end

    Running = false
    Send("SUMMARY", "suite", "passed=" .. Passed, true)
end)

print(PREFIX .. " LOADED")
