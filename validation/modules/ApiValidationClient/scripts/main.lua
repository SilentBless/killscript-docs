local SUITE = "CameraBaseline"
local PREFIX = "[API Validation][Client][" .. SUITE .. "]"

local Passed = 0
local Started = false
local WaitingWasLogged = false

local function Pass(name, value)
    Passed = Passed + 1
    print(PREFIX .. " PASS " .. name .. " -> " .. tostring(value))
end

local function ReadCameraProperties(label, camera)
    Pass(label .. ".Aspect.get", camera.Aspect)
    Pass(label .. ".FarClipPlane.get", camera.FarClipPlane)
    Pass(label .. ".Fov.get", camera.Fov)
    Pass(label .. ".IsMainCamera.get", camera.IsMainCamera)
    Pass(label .. ".IsOrthographic.get", camera.IsOrthographic)
    Pass(label .. ".NearClipPlane.get", camera.NearClipPlane)
    Pass(label .. ".OrthographicSize.get", camera.OrthographicSize)
    Pass(label .. ".OutputTexture.get", camera.OutputTexture)
    Pass(label .. ".Position.get", camera.Position)
    Pass(label .. ".Rotation.get", camera.Rotation)
end

local function RunCameraBaseline()
    print(PREFIX .. " BEGIN")

    local mainCamera = Cameras.Main
    Pass("Cameras.Main.get", mainCamera)
    ReadCameraProperties("MainCamera", mainCamera)

    local customCamera = Cameras:CreateCamera()
    Pass("Cameras.CreateCamera", customCamera)

    customCamera:SetRenderSize(320, 180)
    Pass("CustomCamera.SetRenderSize(320, 180)", true)

    customCamera:SetActive(true)
    Pass("CustomCamera.SetActive(true)", true)

    ReadCameraProperties("CustomCamera", customCamera)

    local outputTexture = customCamera.OutputTexture
    Pass("CustomCamera.OutputTexture.width.get", outputTexture.width)
    Pass("CustomCamera.OutputTexture.height.get", outputTexture.height)

    local viewportPoint = mainCamera:WorldToViewportPoint(mainCamera.Position)
    Pass(
        "MainCamera.WorldToViewportPoint",
        string.format(
            "x=%.4f y=%.4f z=%.4f",
            viewportPoint.x,
            viewportPoint.y,
            viewportPoint.z
        )
    )

    customCamera:SetActive(false)
    Pass("CustomCamera.SetActive(false)", true)

    Cameras:RemoveCamera(customCamera)
    Pass("Cameras.RemoveCamera", true)

    print(PREFIX .. " SUMMARY passed=" .. Passed)
    print(PREFIX .. " END")
end

local function StartWhenReady()
    if Started then
        return
    end

    if Cameras.Main == nil then
        if not WaitingWasLogged then
            WaitingWasLogged = true
            print(PREFIX .. " WAITING for an active game camera")
        end
        return
    end

    Started = true
    RunCameraBaseline()
end

Scheduler:OnFrame(StartWhenReady)
print(PREFIX .. " LOADED")
