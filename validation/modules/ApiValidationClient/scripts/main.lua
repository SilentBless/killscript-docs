local SUITE = "Camera"
local PREFIX = "[API Validation][Client][" .. SUITE .. "]"

local Passed = 0
local Failed = 0
local Started = false
local WaitingWasLogged = false

local function Describe(value)
    if value == nil then
        return "nil"
    end

    local valueType = type(value)
    if valueType == "number" then
        return string.format("number(%.6g)", value)
    end
    if valueType == "boolean" then
        return "boolean(" .. tostring(value) .. ")"
    end
    if valueType == "string" then
        return "string(" .. value .. ")"
    end

    local ok, text = pcall(function()
        return tostring(value)
    end)
    if ok then
        return valueType .. "(" .. text .. ")"
    end
    return valueType
end

local function Pass(name, detail)
    Passed = Passed + 1
    print(PREFIX .. " PASS " .. name .. " -> " .. detail)
end

local function Fail(name, detail)
    Failed = Failed + 1
    print(PREFIX .. " FAIL " .. name .. " -> " .. detail)
end

local function Test(name, callback)
    local ok, value = pcall(callback)
    if ok then
        Pass(name, Describe(value))
        return true, value
    end

    Fail(name, tostring(value))
    return false, nil
end

local function ExpectRejected(name, callback)
    local ok, value = pcall(callback)
    if ok then
        Fail(name, "write was accepted: " .. Describe(value))
        return false
    end

    Pass(name, "write rejected: " .. tostring(value))
    return true
end

local function TestSameValueWrite(name, value, setter, getter)
    return Test(name, function()
        setter(value)
        return getter()
    end)
end

local function ReadCameraProperties(label, camera)
    local values = {}
    local ok

    ok, values.Aspect = Test(label .. ".Aspect.get", function() return camera.Aspect end)
    values.AspectOk = ok
    ok, values.FarClipPlane = Test(label .. ".FarClipPlane.get", function() return camera.FarClipPlane end)
    values.FarClipPlaneOk = ok
    ok, values.Fov = Test(label .. ".Fov.get", function() return camera.Fov end)
    values.FovOk = ok
    ok, values.IsMainCamera = Test(label .. ".IsMainCamera.get", function() return camera.IsMainCamera end)
    values.IsMainCameraOk = ok
    ok, values.IsOrthographic = Test(label .. ".IsOrthographic.get", function() return camera.IsOrthographic end)
    values.IsOrthographicOk = ok
    ok, values.NearClipPlane = Test(label .. ".NearClipPlane.get", function() return camera.NearClipPlane end)
    values.NearClipPlaneOk = ok
    ok, values.OrthographicSize = Test(label .. ".OrthographicSize.get", function() return camera.OrthographicSize end)
    values.OrthographicSizeOk = ok
    ok, values.OutputTexture = Test(label .. ".OutputTexture.get", function() return camera.OutputTexture end)
    values.OutputTextureOk = ok
    ok, values.Position = Test(label .. ".Position.get", function() return camera.Position end)
    values.PositionOk = ok
    ok, values.Rotation = Test(label .. ".Rotation.get", function() return camera.Rotation end)
    values.RotationOk = ok

    return values
end

local function TestCustomCameraWrites(camera, values)
    if values.AspectOk then
        TestSameValueWrite(
            "CustomCamera.Aspect.set_same",
            values.Aspect,
            function(value) camera.Aspect = value end,
            function() return camera.Aspect end
        )
    end

    if values.FarClipPlaneOk then
        TestSameValueWrite(
            "CustomCamera.FarClipPlane.set_same",
            values.FarClipPlane,
            function(value) camera.FarClipPlane = value end,
            function() return camera.FarClipPlane end
        )
    end

    if values.FovOk then
        TestSameValueWrite(
            "CustomCamera.Fov.set_same",
            values.Fov,
            function(value) camera.Fov = value end,
            function() return camera.Fov end
        )
    end

    if values.IsOrthographicOk then
        TestSameValueWrite(
            "CustomCamera.IsOrthographic.set_same",
            values.IsOrthographic,
            function(value) camera.IsOrthographic = value end,
            function() return camera.IsOrthographic end
        )
    end

    if values.NearClipPlaneOk then
        TestSameValueWrite(
            "CustomCamera.NearClipPlane.set_same",
            values.NearClipPlane,
            function(value) camera.NearClipPlane = value end,
            function() return camera.NearClipPlane end
        )
    end

    if values.OrthographicSizeOk then
        TestSameValueWrite(
            "CustomCamera.OrthographicSize.set_same",
            values.OrthographicSize,
            function(value) camera.OrthographicSize = value end,
            function() return camera.OrthographicSize end
        )
    end

    if values.OutputTextureOk then
        TestSameValueWrite(
            "CustomCamera.OutputTexture.set_same",
            values.OutputTexture,
            function(value) camera.OutputTexture = value end,
            function() return camera.OutputTexture end
        )
    end

    if values.PositionOk then
        TestSameValueWrite(
            "CustomCamera.Position.set_same",
            values.Position,
            function(value) camera.Position = value end,
            function() return camera.Position end
        )
    end

    if values.RotationOk then
        TestSameValueWrite(
            "CustomCamera.Rotation.set_same",
            values.Rotation,
            function(value) camera.Rotation = value end,
            function() return camera.Rotation end
        )
    end
end

local function RunCameraSuite()
    print(PREFIX .. " BEGIN")

    local mainOk, mainCamera = Test("Cameras.Main.get", function()
        return Cameras.Main
    end)
    if not mainOk or mainCamera == nil then
        Fail("suite", "main camera is unavailable")
        print(PREFIX .. " SUMMARY passed=" .. Passed .. " failed=" .. Failed)
        return
    end

    local mainValues = ReadCameraProperties("MainCamera", mainCamera)

    -- This known read-only member is tested before allocating a custom camera.
    -- If the Lua bridge bypasses pcall, the suite stops without leaking a camera.
    if mainValues.IsMainCameraOk then
        ExpectRejected("MainCamera.IsMainCamera.set_same", function()
            mainCamera.IsMainCamera = mainValues.IsMainCamera
            return mainCamera.IsMainCamera
        end)
    end

    ExpectRejected("Cameras.Main.set_same", function()
        Cameras.Main = mainCamera
        return Cameras.Main
    end)

    local customOk, customCamera = Test("Cameras.CreateCamera", function()
        return Cameras:CreateCamera()
    end)
    if not customOk or customCamera == nil then
        Fail("suite", "custom camera was not created")
        print(PREFIX .. " SUMMARY passed=" .. Passed .. " failed=" .. Failed)
        return
    end

    Test("CustomCamera.SetRenderSize(320, 180)", function()
        customCamera:SetRenderSize(320, 180)
        return true
    end)

    Test("CustomCamera.SetActive(true)", function()
        customCamera:SetActive(true)
        return true
    end)

    local customValues = ReadCameraProperties("CustomCamera", customCamera)

    Test("CustomCamera.OutputTexture.dimensions", function()
        local texture = customCamera.OutputTexture
        return string.format("%dx%d", texture.width, texture.height)
    end)

    ExpectRejected("CustomCamera.OutputTexture.width.set_same", function()
        local texture = customCamera.OutputTexture
        texture.width = texture.width
        return texture.width
    end)

    ExpectRejected("CustomCamera.OutputTexture.height.set_same", function()
        local texture = customCamera.OutputTexture
        texture.height = texture.height
        return texture.height
    end)

    TestCustomCameraWrites(customCamera, customValues)

    Test("MainCamera.WorldToViewportPoint", function()
        local point = mainCamera:WorldToViewportPoint(mainCamera.Position)
        return string.format("x=%.4f y=%.4f z=%.4f", point.x, point.y, point.z)
    end)

    Test("CustomCamera.SetActive(false)", function()
        customCamera:SetActive(false)
        return true
    end)

    Test("Cameras.RemoveCamera", function()
        Cameras:RemoveCamera(customCamera)
        return true
    end)

    print(PREFIX .. " SUMMARY passed=" .. Passed .. " failed=" .. Failed)
    print(PREFIX .. " END")
end

local function StartWhenReady()
    if Started then
        return
    end

    local ok, mainCamera = pcall(function()
        return Cameras.Main
    end)
    if not ok or mainCamera == nil then
        if not WaitingWasLogged then
            WaitingWasLogged = true
            print(PREFIX .. " WAITING for an active game camera")
        end
        return
    end

    Started = true
    RunCameraSuite()
end

Scheduler:OnFrame(StartWhenReady)
print(PREFIX .. " LOADED")
