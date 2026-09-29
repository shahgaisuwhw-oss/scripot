-- universal solara menu | key system (timed) + novo menu sidebar amarelo + fixes + 12 funções novas
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
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

-- Key GUI
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
        Aimbot = false,
        AimbotLite = false,
        AimAssist = false,
        AimSilent = false,
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
        TeleportTarget = nil,
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

    local function FullUnload()
        States.Invisible = false
        States.Noclip = false
        States.Speed = false
        States.Fly = false
        States.InfiniteJump = false
        States.FOVEnabled = false
        States.Aimbot = false
        States.AimbotLite = false
        States.AimAssist = false
        States.AimSilent = false
        States.Wallbang = false
        States.Wallcheck = false
        States.ESPEnabled = false
        States.Triggerbot = false
        States.HitboxExpander = false
        States.Fullbright = false
        States.XRay = false
        States.NoFall = false
        States.BunnyHop = false
        States.Spinbot = false
        States.AutoFire = false
        States.Godmode = false
        States.Crosshair = false
        Camera.FieldOfView = 70
        Lighting.Ambient = originalAmbient
        Lighting.Brightness = originalBrightness
        Lighting.FogEnd = originalFog
        Lighting.OutdoorAmbient = originalOutdoor
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

    -- Float button
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

    -- ===================== MAIN WINDOW =====================
    Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 720, 0, 500)
    Main.Position = UDim2.new(0.5, -360, 0.5, -250)
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

    -- SIDEBAR
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
        {id = "misc", name = "MISC", icon = "•••"},
    }

    local tabButtons = {}
    local contentFrames = {}

    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 38)
        btn.Position = UDim2.new(0, 8, 0, 60 + (i-1)*44)
        btn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        btn.Text = "  " .. tab.icon .. "   " .. tab.name
        btn.TextColor3 = Color3.fromRGB(140, 140, 140)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
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
        content.CanvasSize = UDim2.new(0, 0, 0, 800)
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

    -- Close / Minimize
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

    -- Drag main
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

    -- ===================== HELPERS =====================
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
    y = CreateToggle(inicio, "Universal (Jogos de Tiro)", "Recursos otimizados para jogos de tiro", y, true, function() end)
    y = CreateToggle(inicio, "Compatibilidade Roblox", "Totalmente compatível com Roblox", y, true, function() end)

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
            local s = left % 60
            if d > 0 then
                ExpireLabel.Text = string.format("Chave: ATIVA\nTipo: %s\nRestante: %dd %02dh %02dm", KeyTypeLabel, d, h, m)
            else
                ExpireLabel.Text = string.format("Chave: ATIVA\nTipo: %s\nRestante: %02dh %02dm %02ds", KeyTypeLabel, h, m, s)
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
                if s then
                    v.LocalTransparencyModifier = 0.6
                else
                    v.LocalTransparencyModifier = 0
                end
            end
        end
    end)
    y = CreateToggle(visuals, "Crosshair Custom", "Mira custom amarela no centro", y, false, function(s) States.Crosshair = s end)

    -- ===================== TAB: AIMBOT =====================
    local aimbot = contentFrames["aimbot"]
    y = 8
    y = CreateSection(aimbot, "AIMBOT PRINCIPAL", y)
    y = CreateToggle(aimbot, "Aimbot", "Mira automática dura (gruda)", y, false, function(s) States.Aimbot = s end)
    y = CreateToggle(aimbot, "Aimbot Lite", "Mira suave com lerp (não gruda)", y, false, function(s) States.AimbotLite = s end)
    y = CreateToggle(aimbot, "Aim Assist", "Assistente de mira sutil (puxa levemente)", y, false, function(s) States.AimAssist = s end)
    y = CreateToggle(aimbot, "Aim Silent", "Aimbot silencioso (server-side)", y, false, function(s) States.AimSilent = s end)
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
    y = CreateToggle(combat, "Hitbox Expander", "Aumenta hitbox dos inimigos", y, false, function(s) States.HitboxExpander = s end)
    y = CreateSlider(combat, "Hitbox Size", y, 2, 20, 5, function(val) States.HitboxSize = val end)
    y = CreateToggle(combat, "No Recoil", "Remove o recuo das armas", y, false, function(s) States.NoRecoil = s end)
    y = CreateToggle(combat, "Infinite Ammo", "Munição infinita", y, false, function(s) States.InfiniteAmmo = s end)
    y = CreateToggle(combat, "Godmode", "Tenta imortalidade local", y, false, function(s) States.Godmode = s end)
    y = CreateToggle(combat, "Spinbot", "Gira o personagem (anti-aim visual)", y, false, function(s) States.Spinbot = s end)
    y = CreateSlider(combat, "Spin Speed", y, 5, 50, 20, function(val) States.SpinSpeed = val end)

    -- ===================== TAB: MISC =====================
    local misc = contentFrames["misc"]
    y = 8
    y = CreateSection(misc, "MOVIMENTO & UTIL", y)
    y = CreateToggle(misc, "Noclip", "Atravessa paredes e objetos", y, false, function(s) States.Noclip = s end)
    y = CreateToggle(misc, "Invisible", "Fica invisível para outros jogadores", y, false, function(s)
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
    y = CreateToggle(misc, "Speed Hack", "Aumenta a velocidade de movimento", y, false, function(s) States.Speed = s end)
    y = CreateSlider(misc, "Speed Multiplier", y, 1, 10, 2, function(val) States.SpeedValue = val end)
    y = CreateToggle(misc, "Fly", "Voo livre", y, false, function(s) States.Fly = s end)
    y = CreateToggle(misc, "Infinite Jump", "Pulo infinito", y, false, function(s) States.InfiniteJump = s end)
    y = CreateToggle(misc, "Bunny Hop", "Pulo automático contínuo", y, false, function(s) States.BunnyHop = s end)
    y = CreateToggle(misc, "No Fall Damage", "Remove dano de queda", y, false, function(s) States.NoFall = s end)
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
    y = CreateButton(misc, "Copy My Position", y, function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            setclipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
            print("[solara] posição copiada: " .. string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
        end
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

    -- Crosshair Drawing
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

    -- Speed
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 * States.SpeedValue
        end
    end))

    -- Fly
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
            flyBody.Velocity = dir.Magnitude > 0 and dir.Unit * 50 or Vector3.zero
        else
            if flyBody then flyBody:Destroy() flyBody = nil end
        end
    end))

    -- Infinite Jump + BunnyHop
    table.insert(Connections, UserInputService.JumpRequest:Connect(function()
        if (States.InfiniteJump or States.BunnyHop) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))

    -- No Fall
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.NoFall and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end
    end))

    -- Spinbot
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if States.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(States.SpinSpeed), 0)
        end
    end))

    -- Godmode attempt
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if States.Godmode and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
            end
        end
    end))

    -- Hitbox Expander
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

    -- Anti AFK
    table.insert(Connections, LocalPlayer.Idled:Connect(function()
        if States.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end))

    -- Auto Fire / Triggerbot
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if States.AutoFire then
            pcall(function()
                mouse1press()
            end)
        end
        if States.Triggerbot then
            local target = getClosestInFOV()
            if target then
                local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                if onScreen then
                    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                    if math.abs(screenPos.X - cx) < 40 and math.abs(screenPos.Y - cy) < 40 then
                        pcall(function()
                            mouse1click()
                        end)
                    end
                end
            end
        end
    end))

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        -- FOV Circle
        if FOVCircle then
            if States.Aimbot or States.AimbotLite or States.AimAssist or States.AimSilent then
                FOVCircle.Visible = true
                FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                FOVCircle.Radius = (States.FOVValue / 100) * (Camera.ViewportSize.Y / 2.2)
            else
                FOVCircle.Visible = false
            end
        end

        -- Crosshair
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

        -- Aimbot hard
        if States.Aimbot then
            local targetPart = getClosestInFOV()
            if targetPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end

        -- Aimbot Lite (smooth lerp)
        if States.AimbotLite then
            local targetPart = getClosestInFOV()
            if targetPart then
                local current = Camera.CFrame
                local target = CFrame.new(current.Position, targetPart.Position)
                Camera.CFrame = current:Lerp(target, 0.18)
            end
        end

        -- Aim Assist (subtle)
        if States.AimAssist then
            local targetPart = getClosestInFOV()
            if targetPart then
                local current = Camera.CFrame
                local target = CFrame.new(current.Position, targetPart.Position)
                Camera.CFrame = current:Lerp(target, 0.06)
            end
        end

        if States.AimSilent then
            local targetPart = getClosestInFOV()
            if targetPart then
                pcall(function()
                    Mouse.Hit = CFrame.new(targetPart.Position)
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
        end
        if obj then ESPObjects[key] = obj end
        return obj
    end

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
            else
                -- Fallback Highlight + Billboard (mais estável em alguns jogos)
                local hlKey = plr.Name .. "_hl"
                activeKeys[hlKey] = true
                if not ESPObjects[hlKey] then
                    local highlight = Instance.new("Highlight")
                    highlight.FillTransparency = 0.65
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
        end

        -- limpa objetos de jogadores que sumiram
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
    end)

    print("[solara universal] key aceita · menu novo + fixes + 12 funções · tipo " .. KeyTypeLabel)
end

print("[solara hub] digite a key para liberar")
