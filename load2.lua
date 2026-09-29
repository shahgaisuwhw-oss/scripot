-- universal solara menu | key system (timed) + novo menu + 22 funções extras
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ===================== KEY SYSTEM (timed) =====================
local KeyAccepted = false
local ExpireAt = 0
local KeyTypeLabel = ""
local DurationMap = {
    ["5M"]  = 5 * 60,
    ["1D"]  = 1 * 24 * 60 * 60,
    ["3D"]  = 3 * 24 * 60 * 60,
    ["7D"]  = 7 * 24 * 60 * 60,
    ["15D"] = 15 * 24 * 60 * 60,
    ["30D"] = 30 * 24 * 60 * 60,
    ["PERM"] = 0,
}

local function isValidCode(code)
    if type(code) ~= "string" or #code ~= 8 then return false end
    return code:match("^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]+$") ~= nil
end

local function parseKey(key)
    key = key:gsub("%s+", ""):upper()
    local prefix, dtype, code = key:match("^(SOLARA%-HUB)%-(%w+)%-(%w+)$")
    if not prefix or not dtype or not code then return nil end
    if not DurationMap[dtype] then return nil end
    if not isValidCode(code) then return nil end
    return dtype, DurationMap[dtype]
end

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "SolaraKeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() KeyGui.Parent = CoreGui end)
if not KeyGui.Parent then KeyGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 340, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -170, 0.5, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = KeyGui
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(245, 197, 24)
KeyStroke.Thickness = 1.5
KeyStroke.Transparency = 0.3
KeyStroke.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "SOLARA HUB  ·  KEY"
KeyTitle.TextColor3 = Color3.fromRGB(245, 197, 24)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 16
KeyTitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -40, 0, 36)
KeyBox.Position = UDim2.new(0, 20, 0, 55)
KeyBox.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
KeyBox.Text = ""
KeyBox.PlaceholderText = "solara-hub-1D-XXXXXXXX"
KeyBox.TextColor3 = Color3.fromRGB(220, 225, 255)
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 105, 120)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = KeyFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

local KeyBtn = Instance.new("TextButton")
KeyBtn.Size = UDim2.new(1, -40, 0, 36)
KeyBtn.Position = UDim2.new(0, 20, 0, 105)
KeyBtn.BackgroundColor3 = Color3.fromRGB(245, 197, 24)
KeyBtn.Text = "UNLOCK"
KeyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
KeyBtn.Font = Enum.Font.GothamBold
KeyBtn.TextSize = 14
KeyBtn.Parent = KeyFrame
Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 8)

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, 0, 0, 36)
KeyStatus.Position = UDim2.new(0, 0, 1, -42)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.fromRGB(255, 120, 120)
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.TextSize = 12
KeyStatus.TextWrapped = true
KeyStatus.Parent = KeyFrame

KeyBtn.MouseButton1Click:Connect(function()
    local input = KeyBox.Text
    local dtype, secs = parseKey(input)
    if dtype then
        KeyStatus.TextColor3 = Color3.fromRGB(100, 255, 140)
        if secs == 0 then
            KeyStatus.Text = "key permanente aceita · carregando..."
            ExpireAt = 0
            KeyTypeLabel = "PERM"
        else
            ExpireAt = os.time() + secs
            KeyTypeLabel = dtype
            local mins = math.floor(secs / 60)
            local days = math.floor(secs / 86400)
            local remain = days > 0 and (days .. "d") or (mins .. "m")
            KeyStatus.Text = "key " .. dtype .. " aceita · " .. remain .. " restantes"
        end
        KeyAccepted = true
        task.wait(0.7)
        KeyGui:Destroy()
        loadMainScript()
    else
        KeyStatus.TextColor3 = Color3.fromRGB(255, 120, 120)
        KeyStatus.Text = "key inválida\nuse: solara-hub-5M/1D/3D/7D/15D/30D/PERM-XXXXXXXX"
        KeyBox.Text = ""
    end
end)

KeyBox.FocusLost:Connect(function(enter)
    if enter then KeyBtn.MouseButton1Click:Fire() end
end)

-- ===================== MAIN SCRIPT =====================
function loadMainScript()
    local States = {
        Invisible = false,
        Noclip = false,
        Speed = false,
        SpeedValue = 2,
        Fly = false,
        InfiniteJump = false,
        NoRecoil = false,
        InfiniteAmmo = false,
        FOVEnabled = false,
        FOVValue = 70,
        PullPart = "Head",
        ESPEnabled = false,
        ESPBoxes = true,
        ESPNames = true,
        ESPTracers = true,
        ESPDistance = true,
        ESPHealth = true,
        ESPTeamCheck = false,
        ESPMaxDist = 1000,
        ESPSkeleton = false,
        ESPChams = false,
        Aimbot = false,
        AimbotLite = false,
        AimAssist = false,
        AimSilent = false,
        AimPredict = false,
        Wallbang = false,
        Wallcheck = false,
        Triggerbot = false,
        HitboxExpander = false,
        HitboxSize = 5,
        AntiKick = true,
        AntiBan = true,
        Fullbright = false,
        XRay = false,
        NoFall = false,
        BunnyHop = false,
        Spinbot = false,
        SpinSpeed = 20,
        AntiAFK = true,
        AutoFire = false,
        Godmode = false,
        Crosshair = false,
        RapidFire = false,
        NoSpread = false,
        AutoReload = false,
        KillAura = false,
        KillAuraRange = 15,
        ThirdPerson = false,
        Freecam = false,
        ZoomLock = false,
        JumpPower = false,
        JumpValue = 50,
        GravityControl = false,
        GravityValue = 196.2,
        Freeze = false,
        FPSBoost = false,
        Radar = false,
        Spectate = false,
        SpectateTarget = nil,
        BringAll = false,
        ServerHop = false,
        Rejoin = false,
        ChatSpam = false,
        ChatMsg = "solara hub on top",
        Trail = false,
        ForceField = false,
        PlatformStand = false,
        SwimSpeed = false,
        LowGFX = false,
    }

    local Connections = {}
    local ESPObjects = {}
    local DrawingLib = Drawing or nil
    local FOVCircle = nil
    local ScreenGui = nil
    local Main = nil
    local FloatBtn = nil
    local ExpireLabel = nil
    local currentTab = "inicio"
    local originalAmbient = Lighting.Ambient
    local originalBrightness = Lighting.Brightness
    local originalFog = Lighting.FogEnd
    local originalOutdoor = Lighting.OutdoorAmbient
    local originalGravity = workspace.Gravity
    local freecamPart = nil
    local freecamConn = nil
    local radarFrame = nil

    local function FullUnload()
        for k, v in pairs(States) do
            if type(v) == "boolean" then States[k] = false end
        end
        Camera.FieldOfView = 70
        Camera.CameraType = Enum.CameraType.Custom
        workspace.Gravity = originalGravity
        Lighting.Ambient = originalAmbient
        Lighting.Brightness = originalBrightness
        Lighting.FogEnd = originalFog
        Lighting.OutdoorAmbient = originalOutdoor
        if freecamPart then freecamPart:Destroy() freecamPart = nil end
        if freecamConn then freecamConn:Disconnect() end
        if radarFrame then radarFrame:Destroy() end
        for _, conn in ipairs(Connections) do
            pcall(function() conn:Disconnect() end)
        end
        Connections = {}
        if FOVCircle then pcall(function() FOVCircle:Remove() end) end
        for _, obj in pairs(ESPObjects) do
            pcall(function()
                if obj.Remove then obj:Remove() end
                if typeof(obj) == "Instance" then obj:Destroy() end
            end)
        end
        ESPObjects = {}
        if ScreenGui then pcall(function() ScreenGui:Destroy() end) end
        print("[solara universal] fully unloaded")
    end

    if ExpireAt > 0 then
        table.insert(Connections, RunService.Heartbeat:Connect(function()
            if os.time() >= ExpireAt then
                print("[solara] key expirou · fechando hub")
                FullUnload()
            end
        end))
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SolaraUniversal"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    FloatBtn = Instance.new("TextButton")
    FloatBtn.Name = "FloatS"
    FloatBtn.Size = UDim2.new(0, 52, 0, 52)
    FloatBtn.Position = UDim2.new(0, 20, 0.5, -26)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    FloatBtn.Text = "☀"
    FloatBtn.TextColor3 = Color3.fromRGB(245, 197, 24)
    FloatBtn.Font = Enum.Font.GothamBold
    FloatBtn.TextSize = 22
    FloatBtn.AutoButtonColor = false
    FloatBtn.Parent = ScreenGui
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Color = Color3.fromRGB(245, 197, 24)
    FloatStroke.Thickness = 1.5
    FloatStroke.Transparency = 0.2
    FloatStroke.Parent = FloatBtn

    local draggingFloat = false
    local hasDragged = false
    local dragStart, startPos
    local DRAG_THRESHOLD = 6

    local function OpenPanel()
        if Main then Main.Visible = true FloatBtn.Visible = false end
    end
    local function MinimizePanel()
        if Main then Main.Visible = false FloatBtn.Visible = true end
    end

    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingFloat = true
            hasDragged = false
            dragStart = input.Position
            startPos = FloatBtn.Position
        end
    end)
    FloatBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingFloat = false
            if not hasDragged then OpenPanel() end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingFloat and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD then
                hasDragged = true
            end
            if hasDragged then
                FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 740, 0, 520)
    Main.Position = UDim2.new(0.5, -370, 0.5, -260)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Main.Visible = false
    Main.Active = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(40, 40, 40)
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    local SideFix = Instance.new("Frame")
    SideFix.Size = UDim2.new(0, 20, 1, 0)
    SideFix.Position = UDim2.new(1, -20, 0, 0)
    SideFix.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    SideFix.BorderSizePixel = 0
    SideFix.Parent = Sidebar

    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(1, -20, 0, 50)
    Logo.Position = UDim2.new(0, 12, 0, 8)
    Logo.BackgroundTransparency = 1
    Logo.Text = "☀  SOLARA HUB"
    Logo.TextColor3 = Color3.fromRGB(245, 197, 24)
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 15
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.Parent = Sidebar

    local tabs = {
        {id = "inicio", name = "INÍCIO", icon = "⌂"},
        {id = "visuals", name = "VISUALS", icon = "👁"},
        {id = "aimbot", name = "AIMBOT", icon = "◎"},
        {id = "combat", name = "COMBAT", icon = "⚔"},
        {id = "player", name = "PLAYER", icon = "👤"},
        {id = "misc", name = "MISC", icon = "•••"},
    }

    local tabButtons = {}
    local contentFrames = {}

    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 36)
        btn.Position = UDim2.new(0, 8, 0, 58 + (i-1)*40)
        btn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        btn.Text = "  " .. tab.icon .. "   " .. tab.name
        btn.TextColor3 = Color3.fromRGB(140, 140, 140)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = Sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        tabButtons[tab.id] = btn

        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -200, 1, -20)
        content.Position = UDim2.new(0, 190, 0, 10)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = Color3.fromRGB(245, 197, 24)
        content.CanvasSize = UDim2.new(0, 0, 0, 1100)
        content.Visible = false
        content.Parent = Main
        contentFrames[tab.id] = content
    end

    local function switchTab(id)
        currentTab = id
        for tid, btn in pairs(tabButtons) do
            if tid == id then
                btn.BackgroundColor3 = Color3.fromRGB(35, 28, 0)
                btn.TextColor3 = Color3.fromRGB(245, 197, 24)
            else
                btn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                btn.TextColor3 = Color3.fromRGB(140, 140, 140)
            end
        end
        for tid, frame in pairs(contentFrames) do
            frame.Visible = (tid == id)
        end
    end

    for _, tab in ipairs(tabs) do
        tabButtons[tab.id].MouseButton1Click:Connect(function()
            switchTab(tab.id)
        end)
    end

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -38, 0, 12)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = Main
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(FullUnload)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -72, 0, 12)
    MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MinBtn.Text = "–"
    MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 18
    MinBtn.Parent = Main
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
    MinBtn.MouseButton1Click:Connect(MinimizePanel)

    local draggingMain = false
    local mainDragStart, mainStartPos
    local TitleDrag = Instance.new("Frame")
    TitleDrag.Size = UDim2.new(1, -180, 0, 50)
    TitleDrag.Position = UDim2.new(0, 180, 0, 0)
    TitleDrag.BackgroundTransparency = 1
    TitleDrag.Parent = Main

    TitleDrag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMain = true
            mainDragStart = input.Position
            mainStartPos = Main.Position
        end
    end)
    TitleDrag.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMain = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mainDragStart
            Main.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if Main and Main.Visible then MinimizePanel() else OpenPanel() end
        end
    end)

    local function CreateSection(parent, title, y)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, y)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Color3.fromRGB(120, 120, 120)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent
        return y + 26
    end

    local function CreateToggle(parent, text, desc, y, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 44)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -70, 0, 20)
        name.Position = UDim2.new(0, 12, 0, 6)
        name.BackgroundTransparency = 1
        name.Text = text
        name.TextColor3 = Color3.fromRGB(230, 230, 230)
        name.Font = Enum.Font.GothamMedium
        name.TextSize = 13
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = frame

        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -70, 0, 16)
        d.Position = UDim2.new(0, 12, 0, 24)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(110, 110, 110)
        d.Font = Enum.Font.Gotham
        d.TextSize = 11
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 42, 0, 22)
        btn.Position = UDim2.new(1, -52, 0.5, -11)
        btn.BackgroundColor3 = default and Color3.fromRGB(245, 197, 24) or Color3.fromRGB(40, 40, 40)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.Parent = btn
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(245, 197, 24) or Color3.fromRGB(40, 40, 40)
            circle.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            callback(state)
        end)
        return y + 50
    end

    local function CreateSlider(parent, text, y, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 18)
        label.Position = UDim2.new(0, 12, 0, 6)
        label.BackgroundTransparency = 1
        label.Text = text .. "  [" .. default .. "]"
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -24, 0, 6)
        bar.Position = UDim2.new(0, 12, 0, 32)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        bar.Parent = frame
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(245, 197, 24)
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

        local dragging = false
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * rel)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                label.Text = text .. "  [" .. val .. "]"
                callback(val)
            end
        end)
        return y + 56
    end

    local function CreatePartSelector(parent, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "Target Part"
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local parts = {"Head", "Chest", "Feet"}
        local current = 1
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 0, 26)
        btn.Position = UDim2.new(1, -102, 0.5, -13)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.Text = parts[current]
        btn.TextColor3 = Color3.fromRGB(245, 197, 24)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            current = current % 3 + 1
            btn.Text = parts[current]
            States.PullPart = parts[current]
        end)
        return y + 48
    end

    local function CreateButton(parent, text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 36)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(35, 28, 0)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(245, 197, 24)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
        return y + 44
    end

    -- ===================== TAB: INÍCIO =====================
    local inicio = contentFrames["inicio"]
    local y = 8
    y = CreateSection(inicio, "RECURSOS", y)
    y = CreateToggle(inicio, "Anti Kick", "Impede que você seja kickado do jogo", y, true, function(s) States.AntiKick = s end)
    y = CreateToggle(inicio, "Anti Ban", "Protege sua conta contra banimentos", y, true, function(s) States.AntiBan = s end)
    y = CreateToggle(inicio, "Anti AFK", "Evita kick por inatividade", y, true, function(s) States.AntiAFK = s end)
    y = CreateToggle(inicio, "FPS Boost", "Desativa partículas e efeitos pesados", y, false, function(s)
        States.FPSBoost = s
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = not s
            end
        end
    end)
    y = CreateToggle(inicio, "Low GFX", "Força gráficos baixos", y, false, function(s)
        States.LowGFX = s
        if s then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)

    local infoBox = Instance.new("Frame")
    infoBox.Size = UDim2.new(1, -10, 0, 110)
    infoBox.Position = UDim2.new(0, 0, 0, y + 10)
    infoBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    infoBox.BorderSizePixel = 0
    infoBox.Parent = inicio
    Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 8)

    local infoTitle = Instance.new("TextLabel")
    infoTitle.Size = UDim2.new(1, -20, 0, 22)
    infoTitle.Position = UDim2.new(0, 12, 0, 8)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Text = "INFORMAÇÕES"
    infoTitle.TextColor3 = Color3.fromRGB(120, 120, 120)
    infoTitle.Font = Enum.Font.GothamBold
    infoTitle.TextSize = 11
    infoTitle.TextXAlignment = Enum.TextXAlignment.Left
    infoTitle.Parent = infoBox

    ExpireLabel = Instance.new("TextLabel")
    ExpireLabel.Size = UDim2.new(1, -20, 0, 60)
    ExpireLabel.Position = UDim2.new(0, 12, 0, 32)
    ExpireLabel.BackgroundTransparency = 1
    ExpireLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ExpireLabel.Font = Enum.Font.Gotham
    ExpireLabel.TextSize = 13
    ExpireLabel.TextXAlignment = Enum.TextXAlignment.Left
    ExpireLabel.TextYAlignment = Enum.TextYAlignment.Top
    ExpireLabel.Parent = infoBox

    if ExpireAt == 0 then
        ExpireLabel.Text = "Chave: ATIVA\nTipo: PERMANENTE\nExpira: Nunca"
    else
        table.insert(Connections, RunService.Heartbeat:Connect(function()
            local left = ExpireAt - os.time()
            if left <= 0 then
                ExpireLabel.Text = "Chave: EXPIRADA"
                return
            end
            local d = math.floor(left / 86400)
            local h = math.floor((left % 86400) / 3600)
            local m = math.floor((left % 3600) / 60)
            if d > 0 then
                ExpireLabel.Text = string.format("Chave: ATIVA\nTipo: %s\nRestante: %dd %02dh %02dm", KeyTypeLabel, d, h, m)
            else
                ExpireLabel.Text = string.format("Chave: ATIVA\nTipo: %s\nRestante: %02dh %02dm", KeyTypeLabel, h, m)
            end
        end))
    end

    -- ===================== TAB: VISUALS =====================
    local visuals = contentFrames["visuals"]
    y = 8
    y = CreateSection(visuals, "ESP PRINCIPAL", y)
    y = CreateToggle(visuals, "ESP Master", "Ativa/desativa todo o ESP (fixado)", y, false, function(s)
        States.ESPEnabled = s
        if not s then
            for _, obj in pairs(ESPObjects) do
                pcall(function()
                    if obj.Remove then obj:Remove() end
                    if typeof(obj) == "Instance" then obj:Destroy() end
                end)
            end
            ESPObjects = {}
        end
    end)
    y = CreateToggle(visuals, "ESP Boxes", "Caixa ao redor dos jogadores", y, true, function(s) States.ESPBoxes = s end)
    y = CreateToggle(visuals, "ESP Names", "Mostra o nome do jogador", y, true, function(s) States.ESPNames = s end)
    y = CreateToggle(visuals, "ESP Tracers", "Linhas até os inimigos", y, true, function(s) States.ESPTracers = s end)
    y = CreateToggle(visuals, "ESP Distance", "Distância até o alvo", y, true, function(s) States.ESPDistance = s end)
    y = CreateToggle(visuals, "ESP Health", "Barra / valor de vida", y, true, function(s) States.ESPHealth = s end)
    y = CreateToggle(visuals, "ESP Skeleton", "Esqueleto dos ossos", y, false, function(s) States.ESPSkeleton = s end)
    y = CreateToggle(visuals, "ESP Chams", "Highlight sólido nos inimigos", y, false, function(s) States.ESPChams = s end)
    y = CreateToggle(visuals, "ESP Team Check", "Ignora aliados do mesmo time", y, false, function(s) States.ESPTeamCheck = s end)
    y = CreateSlider(visuals, "ESP Max Distance", y, 50, 2000, 1000, function(val) States.ESPMaxDist = val end)
    y = CreateSection(visuals, "VISUAL EXTRA", y)
    y = CreateToggle(visuals, "Fullbright", "Ilumina tudo (sem sombra)", y, false, function(s)
        States.Fullbright = s
        if s then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Ambient = originalAmbient
            Lighting.Brightness = originalBrightness
            Lighting.FogEnd = originalFog
            Lighting.OutdoorAmbient = originalOutdoor
        end
    end)
    y = CreateToggle(visuals, "XRay", "Atravessa paredes visualmente", y, false, function(s)
        States.XRay = s
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character or workspace) then
                v.LocalTransparencyModifier = s and 0.6 or 0
            end
        end
    end)
    y = CreateToggle(visuals, "Crosshair Custom", "Mira custom amarela no centro", y, false, function(s) States.Crosshair = s end)
    y = CreateToggle(visuals, "Radar 2D", "Radar minimapa dos inimigos", y, false, function(s)
        States.Radar = s
        if s and not radarFrame then
            radarFrame = Instance.new("Frame")
            radarFrame.Size = UDim2.new(0, 160, 0, 160)
            radarFrame.Position = UDim2.new(1, -180, 0, 20)
            radarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            radarFrame.BackgroundTransparency = 0.3
            radarFrame.BorderSizePixel = 0
            radarFrame.Parent = ScreenGui
            Instance.new("UICorner", radarFrame).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(245, 197, 24)
            stroke.Thickness = 1
            stroke.Parent = radarFrame
        elseif not s and radarFrame then
            radarFrame:Destroy()
            radarFrame = nil
        end
    end)
    y = CreateToggle(visuals, "Trail", "Deixa rastro amarelo no personagem", y, false, function(s)
        States.Trail = s
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local old = char.HumanoidRootPart:FindFirstChild("SolaraTrail")
            if old then old:Destroy() end
            if s then
                local att0 = Instance.new("Attachment", char.HumanoidRootPart)
                local att1 = Instance.new("Attachment", char.HumanoidRootPart)
                att1.Position = Vector3.new(0, 0, -1)
                local trail = Instance.new("Trail")
                trail.Name = "SolaraTrail"
                trail.Attachment0 = att0
                trail.Attachment1 = att1
                trail.Color = ColorSequence.new(Color3.fromRGB(245, 197, 24))
                trail.Lifetime = NumberSequence.new(0.1)
                trail.Lifetime = 0.4
                trail.Parent = char.HumanoidRootPart
            end
        end
    end)

    -- ===================== TAB: AIMBOT =====================
    local aimbot = contentFrames["aimbot"]
    y = 8
    y = CreateSection(aimbot, "AIMBOT PRINCIPAL", y)
    y = CreateToggle(aimbot, "Aimbot", "Mira automática dura (gruda)", y, false, function(s) States.Aimbot = s end)
    y = CreateToggle(aimbot, "Aimbot Lite", "Mira suave com lerp (não gruda)", y, false, function(s) States.AimbotLite = s end)
    y = CreateToggle(aimbot, "Aim Assist", "Assistente de mira sutil (puxa levemente)", y, false, function(s) States.AimAssist = s end)
    y = CreateToggle(aimbot, "Aim Silent", "Aimbot silencioso (server-side)", y, false, function(s) States.AimSilent = s end)
    y = CreateToggle(aimbot, "Aim Predict", "Prevê movimento do alvo", y, false, function(s) States.AimPredict = s end)
    y = CreateToggle(aimbot, "Wallbang", "Tiros atravessam paredes", y, false, function(s) States.Wallbang = s end)
    y = CreateToggle(aimbot, "Wallcheck", "Só mira em alvos visíveis", y, false, function(s) States.Wallcheck = s end)
    y = CreateToggle(aimbot, "FOV Pull", "Puxa inimigos para o FOV", y, false, function(s)
        States.FOVEnabled = s
        if not s then Camera.FieldOfView = 70 end
    end)
    y = CreateSlider(aimbot, "FOV Value", y, 0, 120, 70, function(val)
        States.FOVValue = val
        if States.FOVEnabled then Camera.FieldOfView = val end
    end)
    y = CreatePartSelector(aimbot, y)

    -- ===================== TAB: COMBAT =====================
    local combat = contentFrames["combat"]
    y = 8
    y = CreateSection(combat, "COMBAT EXTRA", y)
    y = CreateToggle(combat, "Triggerbot", "Atira automaticamente quando mira no inimigo", y, false, function(s) States.Triggerbot = s end)
    y = CreateToggle(combat, "Auto Fire", "Segura o tiro automaticamente", y, false, function(s) States.AutoFire = s end)
    y = CreateToggle(combat, "Rapid Fire", "Aumenta cadência de tiro", y, false, function(s) States.RapidFire = s end)
    y = CreateToggle(combat, "No Spread", "Remove espalhamento da arma", y, false, function(s) States.NoSpread = s end)
    y = CreateToggle(combat, "Auto Reload", "Recarrega automaticamente", y, false, function(s) States.AutoReload = s end)
    y = CreateToggle(combat, "Hitbox Expander", "Aumenta hitbox dos inimigos", y, false, function(s) States.HitboxExpander = s end)
    y = CreateSlider(combat, "Hitbox Size", y, 2, 20, 5, function(val) States.HitboxSize = val end)
    y = CreateToggle(combat, "Kill Aura", "Dano automático em inimigos próximos", y, false, function(s) States.KillAura = s end)
    y = CreateSlider(combat, "Kill Aura Range", y, 5, 40, 15, function(val) States.KillAuraRange = val end)
    y = CreateToggle(combat, "No Recoil", "Remove o recuo das armas", y, false, function(s) States.NoRecoil = s end)
    y = CreateToggle(combat, "Infinite Ammo", "Munição infinita", y, false, function(s) States.InfiniteAmmo = s end)
    y = CreateToggle(combat, "Godmode", "Tenta imortalidade local", y, false, function(s) States.Godmode = s end)
    y = CreateToggle(combat, "Spinbot", "Gira o personagem (anti-aim visual)", y, false, function(s) States.Spinbot = s end)
    y = CreateSlider(combat, "Spin Speed", y, 5, 50, 20, function(val) States.SpinSpeed = val end)

    -- ===================== TAB: PLAYER =====================
    local player = contentFrames["player"]
    y = 8
    y = CreateSection(player, "PLAYER CONTROLS", y)
    y = CreateToggle(player, "Noclip", "Atravessa paredes e objetos", y, false, function(s) States.Noclip = s end)
    y = CreateToggle(player, "Invisible", "Fica invisível para outros jogadores", y, false, function(s)
        States.Invisible = s
        local char = LocalPlayer.Character
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
                if v.Name ~= "HumanoidRootPart" then v.Transparency = s and 1 or 0 end
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") then
                v.Enabled = not s
            end
        end
        pcall(function()
            if char.Head and char.Head:FindFirstChild("face") then
                char.Head.face.Transparency = s and 1 or 0
            end
        end)
    end)
    y = CreateToggle(player, "Speed Hack", "Aumenta a velocidade de movimento", y, false, function(s) States.Speed = s end)
    y = CreateSlider(player, "Speed Multiplier", y, 1, 15, 2, function(val) States.SpeedValue = val end)
    y = CreateToggle(player, "Fly", "Voo livre", y, false, function(s) States.Fly = s end)
    y = CreateToggle(player, "Infinite Jump", "Pulo infinito", y, false, function(s) States.InfiniteJump = s end)
    y = CreateToggle(player, "Bunny Hop", "Pulo automático contínuo", y, false, function(s) States.BunnyHop = s end)
    y = CreateToggle(player, "Jump Power", "Aumenta força do pulo", y, false, function(s) States.JumpPower = s end)
    y = CreateSlider(player, "Jump Value", y, 50, 200, 50, function(val) States.JumpValue = val end)
    y = CreateToggle(player, "No Fall Damage", "Remove dano de queda", y, false, function(s) States.NoFall = s end)
    y = CreateToggle(player, "Gravity Control", "Controla gravidade do mundo", y, false, function(s)
        States.GravityControl = s
        if not s then workspace.Gravity = originalGravity end
    end)
    y = CreateSlider(player, "Gravity Value", y, 0, 300, 196, function(val)
        States.GravityValue = val
        if States.GravityControl then workspace.Gravity = val end
    end)
    y = CreateToggle(player, "Freeze / PlatformStand", "Congela o personagem no ar", y, false, function(s)
        States.Freeze = s
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = s end
    end)
    y = CreateToggle(player, "Third Person", "Câmera em terceira pessoa", y, false, function(s)
        States.ThirdPerson = s
        if s then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            Camera.CameraType = Enum.CameraType.Custom
            LocalPlayer.CameraMinZoomDistance = 10
            LocalPlayer.CameraMaxZoomDistance = 20
        else
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end)
    y = CreateToggle(player, "Freecam", "Câmera livre (WASD + mouse)", y, false, function(s)
        States.Freecam = s
        if s then
            if not freecamPart then
                freecamPart = Instance.new("Part")
                freecamPart.Anchored = true
                freecamPart.CanCollide = false
                freecamPart.Transparency = 1
                freecamPart.Size = Vector3.new(1, 1, 1)
                freecamPart.CFrame = Camera.CFrame
                freecamPart.Parent = workspace
                Camera.CameraSubject = freecamPart
            end
        else
            if freecamPart then freecamPart:Destroy() freecamPart = nil end
            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end)
    y = CreateToggle(player, "Force Field Visual", "Mostra forcefield no personagem", y, false, function(s)
        States.ForceField = s
        local char = LocalPlayer.Character
        if char then
            local old = char:FindFirstChild("SolaraFF")
            if old then old:Destroy() end
            if s then
                local ff = Instance.new("ForceField")
                ff.Name = "SolaraFF"
                ff.Visible = true
                ff.Parent = char
            end
        end
    end)

    -- ===================== TAB: MISC =====================
    local misc = contentFrames["misc"]
    y = 8
    y = CreateSection(misc, "UTILIDADES", y)
    y = CreateButton(misc, "Teleport to Closest Enemy", y, function()
        local closest, dist = nil, math.huge
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (plr.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = plr.Character.HumanoidRootPart
                end
            end
        end
        if closest then
            myHRP.CFrame = closest.CFrame * CFrame.new(0, 0, 3)
        end
    end)
    y = CreateButton(misc, "Bring All Players (local)", y, function()
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = myHRP.CFrame * CFrame.new(math.random(-8, 8), 0, math.random(-8, 8))
            end
        end
    end)
    y = CreateButton(misc, "Copy My Position", y, function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            setclipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
            print("[solara] posição copiada")
        end
    end)
    y = CreateButton(misc, "Server Hop", y, function()
        pcall(function()
            local placeId = game.PlaceId
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
    end)
    y = CreateButton(misc, "Rejoin Same Server", y, function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end)
    y = CreateToggle(misc, "Chat Spam", "Spamma mensagem no chat", y, false, function(s) States.ChatSpam = s end)
    y = CreateButton(misc, "Spectate Closest", y, function()
        local closest, dist = nil, math.huge
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                local d = (plr.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = plr
                end
            end
        end
        if closest then
            Camera.CameraSubject = closest.Character.Humanoid
            States.Spectate = true
            States.SpectateTarget = closest
        end
    end)
    y = CreateButton(misc, "Stop Spectate", y, function()
        States.Spectate = false
        States.SpectateTarget = nil
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end)

    switchTab("inicio")

    -- ===================== LOGIC =====================
    if DrawingLib then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 64
        FOVCircle.Radius = 0
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(245, 197, 24)
        FOVCircle.Transparency = 0.3
        FOVCircle.Visible = false
    end

    local CrosshairH, CrosshairV
    if DrawingLib then
        CrosshairH = Drawing.new("Line")
        CrosshairH.Thickness = 1.5
        CrosshairH.Color = Color3.fromRGB(245, 197, 24)
        CrosshairH.Visible = false
        CrosshairV = Drawing.new("Line")
        CrosshairV.Thickness = 1.5
        CrosshairV.Color = Color3.fromRGB(245, 197, 24)
        CrosshairV.Visible = false
    end

    local function isVisible(part)
        if not part then return false end
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.IgnoreWater = true
        local result = workspace:Raycast(origin, direction, params)
        if result then
            local hit = result.Instance
            local hitModel = hit:FindFirstAncestorOfClass("Model")
            local targetModel = part:FindFirstAncestorOfClass("Model")
            if hitModel and targetModel and hitModel == targetModel then return true end
            if Players:GetPlayerFromCharacter(hitModel) then return true end
            return false
        end
        return true
    end

    local function getTargetPart(char)
        if not char then return nil end
        if States.PullPart == "Head" then
            return char:FindFirstChild("Head")
        elseif States.PullPart == "Chest" then
            return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        else
            return char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot") or char:FindFirstChild("HumanoidRootPart")
        end
    end

    local function getClosestInFOV()
        local closest = nil
        local shortest = math.huge
        local fovRad = math.rad(States.FOVValue)
        local camPos = Camera.CFrame.Position
        local camLook = Camera.CFrame.LookVector
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if States.ESPTeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
                local part = getTargetPart(plr.Character)
                if part then
                    local dir = (part.Position - camPos).Unit
                    local angle = math.acos(math.clamp(dir:Dot(camLook), -1, 1))
                    if angle <= fovRad / 2 then
                        if States.Wallcheck and not isVisible(part) then continue end
                        local dist = (part.Position - camPos).Magnitude
                        if dist < shortest and dist <= States.ESPMaxDist then
                            shortest = dist
                            closest = part
                        end
                    end
                end
            end
        end
        return closest
    end

    local function predictPosition(part)
        if not States.AimPredict or not part then return part.Position end
        local vel = part.AssemblyLinearVelocity or Vector3.zero
        return part.Position + vel * 0.12
    end

    local function forceWallbang(obj)
        if not obj or not obj:IsA("BasePart") then return end
        local name = obj.Name:lower()
        if name:find("bullet") or name:find("projectile") or name:find("ammo") or name:find("shot") or
           name:find("pellet") or name:find("round") or name:find("shell") or name:find("tracer") or
           name:find("beam") or name:find("laser") or name:find("missile") or name:find("rocket") or
           name:find("arrow") or name:find("bolt") or name:find("slug") or name:find("ball") then
            obj.CanCollide = false
            obj.CanQuery = false
        end
    end

    table.insert(Connections, workspace.DescendantAdded:Connect(function(obj)
        if States.Wallbang then forceWallbang(obj) end
        if States.XRay and obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character or workspace) then
            obj.LocalTransparencyModifier = 0.6
        end
        if States.FPSBoost and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire")) then
            obj.Enabled = false
        end
    end))

    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.Wallbang then
            for _, obj in ipairs(workspace:GetDescendants()) do
                forceWallbang(obj)
            end
        end
    end))

    table.insert(Connections, RunService.Stepped:Connect(function()
        if States.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end))

    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 * States.SpeedValue
        end
        if States.JumpPower and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = States.JumpValue
            LocalPlayer.Character.Humanoid.JumpHeight = States.JumpValue / 7
        end
    end))

    local flyBody = nil
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if not flyBody then
                flyBody = Instance.new("BodyVelocity")
                flyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBody.Parent = hrp
            end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            flyBody.Velocity = dir.Magnitude > 0 and dir.Unit * 55 or Vector3.zero
        else
            if flyBody then flyBody:Destroy() flyBody = nil end
        end
    end))

    -- Freecam movement
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if States.Freecam and freecamPart then
            local speed = 1.2
            local cf = freecamPart.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then cf = cf + Camera.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then cf = cf - Camera.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then cf = cf - Camera.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then cf = cf + Camera.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then cf = cf + Vector3.new(0, speed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then cf = cf - Vector3.new(0, speed, 0) end
            freecamPart.CFrame = CFrame.new(cf.Position, cf.Position + Camera.CFrame.LookVector)
            Camera.CFrame = freecamPart.CFrame
        end
    end))

    table.insert(Connections, UserInputService.JumpRequest:Connect(function()
        if (States.InfiniteJump or States.BunnyHop) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))

    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.NoFall and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end
    end))

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if States.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(States.SpinSpeed), 0)
        end
    end))

    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.Godmode and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
    end))

    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.HitboxExpander then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    for _, part in ipairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") and (part.Name == "Head" or part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso") then
                            part.Size = Vector3.new(States.HitboxSize, States.HitboxSize, States.HitboxSize)
                            part.Transparency = 0.7
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end))

    -- Kill Aura
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.KillAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if dist <= States.KillAuraRange then
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            pcall(function()
                                hum.Health = 0
                            end)
                        end
                    end
                end
            end
        end
    end))

    table.insert(Connections, LocalPlayer.Idled:Connect(function()
        if States.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end))

    -- Chat Spam
    local lastSpam = 0
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.ChatSpam and tick() - lastSpam > 1.8 then
            lastSpam = tick()
            pcall(function()
                local chat = game:GetService("TextChatService")
                if chat and chat.ChatInputBarConfiguration then
                    -- modern chat
                    local channel = chat:FindFirstChild("TextChannels") and chat.TextChannels:FindFirstChild("RBXGeneral")
                    if channel then
                        channel:SendAsync(States.ChatMsg)
                    end
                else
                    StarterGui:SetCore("ChatMakeSystemMessage", {Text = States.ChatMsg})
                    local rs = game:GetService("ReplicatedStorage")
                    local remote = rs:FindFirstChild("DefaultChatSystemChatEvents")
                    if remote and remote:FindFirstChild("SayMessageRequest") then
                        remote.SayMessageRequest:FireServer(States.ChatMsg, "All")
                    end
                end
            end)
        end
    end))

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if States.AutoFire or States.RapidFire then
            pcall(function() mouse1press() end)
        end
        if States.Triggerbot then
            local target = getClosestInFOV()
            if target then
                local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                if onScreen then
                    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                    if math.abs(screenPos.X - cx) < 45 and math.abs(screenPos.Y - cy) < 45 then
                        pcall(function() mouse1click() end)
                    end
                end
            end
        end
    end))

    -- Radar update
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if States.Radar and radarFrame then
            for _, child in ipairs(radarFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name == "dot" then child:Destroy() end
            end
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local rel = myHRP.CFrame:PointToObjectSpace(plr.Character.HumanoidRootPart.Position)
                    local scale = 0.8
                    local x = math.clamp(rel.X * scale + 80, 4, 156)
                    local y = math.clamp(-rel.Z * scale + 80, 4, 156)
                    local dot = Instance.new("Frame")
                    dot.Name = "dot"
                    dot.Size = UDim2.new(0, 6, 0, 6)
                    dot.Position = UDim2.new(0, x - 3, 0, y - 3)
                    dot.BackgroundColor3 = Color3.fromRGB(245, 197, 24)
                    dot.BorderSizePixel = 0
                    dot.Parent = radarFrame
                    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                end
            end
        end
    end))

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if FOVCircle then
            if States.Aimbot or States.AimbotLite or States.AimAssist or States.AimSilent then
                FOVCircle.Visible = true
                FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                FOVCircle.Radius = (States.FOVValue / 100) * (Camera.ViewportSize.Y / 2.2)
            else
                FOVCircle.Visible = false
            end
        end

        if CrosshairH and CrosshairV then
            if States.Crosshair then
                local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                CrosshairH.From = Vector2.new(cx - 8, cy)
                CrosshairH.To = Vector2.new(cx + 8, cy)
                CrosshairV.From = Vector2.new(cx, cy - 8)
                CrosshairV.To = Vector2.new(cx, cy + 8)
                CrosshairH.Visible = true
                CrosshairV.Visible = true
            else
                CrosshairH.Visible = false
                CrosshairV.Visible = false
            end
        end

        if States.FOVEnabled then
            Camera.FieldOfView = States.FOVValue
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local targetPart = getTargetPart(myChar) or myChar.HumanoidRootPart
                local fovRad = math.rad(States.FOVValue)
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        local dir = (hrp.Position - Camera.CFrame.Position).Unit
                        local angle = math.acos(math.clamp(dir:Dot(Camera.CFrame.LookVector), -1, 1))
                        if angle <= fovRad / 2 then
                            hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0, -3)
                        end
                    end
                end
            end
        end

        if States.Aimbot then
            local targetPart = getClosestInFOV()
            if targetPart then
                local pos = predictPosition(targetPart)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
            end
        end

        if States.AimbotLite then
            local targetPart = getClosestInFOV()
            if targetPart then
                local pos = predictPosition(targetPart)
                local current = Camera.CFrame
                local target = CFrame.new(current.Position, pos)
                Camera.CFrame = current:Lerp(target, 0.18)
            end
        end

        if States.AimAssist then
            local targetPart = getClosestInFOV()
            if targetPart then
                local pos = predictPosition(targetPart)
                local current = Camera.CFrame
                local target = CFrame.new(current.Position, pos)
                Camera.CFrame = current:Lerp(target, 0.06)
            end
        end

        if States.AimSilent then
            local targetPart = getClosestInFOV()
            if targetPart then
                local pos = predictPosition(targetPart)
                pcall(function()
                    Mouse.Hit = CFrame.new(pos)
                    Mouse.Target = targetPart
                end)
            end
        end
    end))

    -- ===================== ESP FIXED =====================
    local function ClearESP()
        for key, obj in pairs(ESPObjects) do
            pcall(function()
                if obj.Remove then obj:Remove() end
                if typeof(obj) == "Instance" then obj:Destroy() end
            end)
        end
        ESPObjects = {}
    end

    local function getOrCreateESP(key, typeName)
        if ESPObjects[key] then return ESPObjects[key] end
        if not DrawingLib then return nil end
        local obj
        if typeName == "box" then
            obj = Drawing.new("Square")
            obj.Thickness = 1.5
            obj.Filled = false
            obj.Color = Color3.fromRGB(245, 197, 24)
            obj.Visible = false
        elseif typeName == "tracer" then
            obj = Drawing.new("Line")
            obj.Thickness = 1.2
            obj.Color = Color3.fromRGB(245, 197, 24)
            obj.Visible = false
        elseif typeName == "text" then
            obj = Drawing.new("Text")
            obj.Size = 13
            obj.Center = true
            obj.Outline = true
            obj.OutlineColor = Color3.fromRGB(0, 0, 0)
            obj.Color = Color3.fromRGB(245, 197, 24)
            obj.Visible = false
        elseif typeName == "line" then
            obj = Drawing.new("Line")
            obj.Thickness = 1.2
            obj.Color = Color3.fromRGB(245, 197, 24)
            obj.Visible = false
        end
        if obj then ESPObjects[key] = obj end
        return obj
    end

    local bonePairs = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
        -- R6 fallback
        {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
    }

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if not States.ESPEnabled then
            ClearESP()
            return
        end

        local myPos = Camera.CFrame.Position
        local activeKeys = {}

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if not plr.Character then continue end
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            if States.ESPTeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end

            local dist = (hrp.Position - myPos).Magnitude
            if dist > States.ESPMaxDist then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then continue end

            local head = plr.Character:FindFirstChild("Head")
            local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
            local foot = plr.Character:FindFirstChild("LeftFoot") or plr.Character:FindFirstChild("RightFoot") or hrp
            local footPos = Camera:WorldToViewportPoint(foot.Position)

            local height = math.abs(headPos.Y - footPos.Y)
            local width = height * 0.55
            if height < 8 then height = 20 end

            if DrawingLib then
                if States.ESPBoxes then
                    local key = plr.Name .. "_box"
                    activeKeys[key] = true
                    local box = getOrCreateESP(key, "box")
                    if box then
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(pos.X - width / 2, headPos.Y)
                        box.Visible = true
                    end
                end

                if States.ESPTracers then
                    local key = plr.Name .. "_tracer"
                    activeKeys[key] = true
                    local tracer = getOrCreateESP(key, "tracer")
                    if tracer then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                    end
                end

                if States.ESPNames or States.ESPDistance or States.ESPHealth then
                    local key = plr.Name .. "_text"
                    activeKeys[key] = true
                    local text = getOrCreateESP(key, "text")
                    if text then
                        local str = ""
                        if States.ESPNames then str = plr.Name end
                        if States.ESPDistance then str = str .. string.format(" [%.0fm]", dist) end
                        if States.ESPHealth then
                            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                            if hum then
                                str = str .. string.format("\nHP: %.0f/%.0f", hum.Health, hum.MaxHealth)
                            end
                        end
                        text.Text = str
                        text.Position = Vector2.new(pos.X, headPos.Y - 18)
                        text.Visible = true
                    end
                end

                if States.ESPSkeleton then
                    for i, pair in ipairs(bonePairs) do
                        local p1 = plr.Character:FindFirstChild(pair[1])
                        local p2 = plr.Character:FindFirstChild(pair[2])
                        if p1 and p2 then
                            local key = plr.Name .. "_sk" .. i
                            activeKeys[key] = true
                            local line = getOrCreateESP(key, "line")
                            if line then
                                local a, ona = Camera:WorldToViewportPoint(p1.Position)
                                local b, onb = Camera:WorldToViewportPoint(p2.Position)
                                if ona and onb then
                                    line.From = Vector2.new(a.X, a.Y)
                                    line.To = Vector2.new(b.X, b.Y)
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            end
                        end
                    end
                end
            else
                local hlKey = plr.Name .. "_hl"
                activeKeys[hlKey] = true
                if not ESPObjects[hlKey] then
                    local highlight = Instance.new("Highlight")
                    highlight.FillTransparency = States.ESPChams and 0.4 or 0.65
                    highlight.OutlineColor = Color3.fromRGB(245, 197, 24)
                    highlight.FillColor = Color3.fromRGB(80, 60, 0)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = plr.Character
                    ESPObjects[hlKey] = highlight
                end

                local billKey = plr.Name .. "_bill"
                activeKeys[billKey] = true
                if not ESPObjects[billKey] then
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 140, 0, 50)
                    bill.StudsOffset = Vector3.new(0, 3.2, 0)
                    bill.AlwaysOnTop = true
                    bill.Parent = head or hrp
                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(245, 197, 24)
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 12
                    txt.TextStrokeTransparency = 0.4
                    txt.Parent = bill
                    ESPObjects[billKey] = bill
                end
                local bill = ESPObjects[billKey]
                if bill and bill:FindFirstChildOfClass("TextLabel") then
                    local str = plr.Name
                    if States.ESPDistance then str = str .. string.format(" [%.0fm]", dist) end
                    if States.ESPHealth then
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if hum then str = str .. string.format("\n%.0f HP", hum.Health) end
                    end
                    bill.TextLabel.Text = str
                end
            end

            if States.ESPChams and DrawingLib then
                local chKey = plr.Name .. "_chams"
                activeKeys[chKey] = true
                if not ESPObjects[chKey] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.35
                    hl.OutlineColor = Color3.fromRGB(245, 197, 24)
                    hl.FillColor = Color3.fromRGB(100, 80, 0)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = plr.Character
                    ESPObjects[chKey] = hl
                end
            end
        end

        for key, obj in pairs(ESPObjects) do
            if not activeKeys[key] then
                pcall(function()
                    if obj.Remove then obj:Remove() end
                    if typeof(obj) == "Instance" then obj:Destroy() end
                end)
                ESPObjects[key] = nil
            end
        end
    end))

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.6)
        if States.Invisible then
            local char = LocalPlayer.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
                        v.Transparency = 1
                    end
                end
            end
        end
        if States.ForceField then
            local ff = Instance.new("ForceField")
            ff.Name = "SolaraFF"
            ff.Visible = true
            ff.Parent = LocalPlayer.Character
        end
        if States.Trail then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local att0 = Instance.new("Attachment", hrp)
                local att1 = Instance.new("Attachment", hrp)
                att1.Position = Vector3.new(0, 0, -1)
                local trail = Instance.new("Trail")
                trail.Name = "SolaraTrail"
                trail.Attachment0 = att0
                trail.Attachment1 = att1
                trail.Color = ColorSequence.new(Color3.fromRGB(245, 197, 24))
                trail.Lifetime = NumberSequence.new(0.1)
                trail.Lifetime = 0.4
                trail.Parent = hrp
            end
        end
    end)

    print("[solara universal] key aceita · +22 funções · tipo " .. KeyTypeLabel)
end

print("[solara hub] digite a key para liberar")
