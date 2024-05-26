local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/1%20Tokyo%20Lib%20(FIXED)/Tokyo%20Lib%20Source.lua"))({
    cheatname = "project_x",
    gamename = "universal",
})

library:init()

local Window1 = library.NewWindow({
    title = "Project X / v2 ",
    size = UDim2.new(0, 600, 0.5, 6)
})

local MainTab = Window1:AddTab("  Main  ")
local ESPTab = Window1:AddTab("  ESP  ")
local MiscTab = Window1:AddTab("  Misc  ")
local SettingsTab = library:CreateSettingsTab(Window1)

local BoxEnabled = false
local BoxInvisibleCheck = false
local BoxTeamCheck = false
local Healthbars = false
local HealthBarInvischeck = false
local HealthBarTeamCheck = false
local NameESPEnable = false
local NameESPInvisible = false
local NameESPTeamCheck = false
local DistanceESP_Enabled = false
local DistanceESP_TeamCheck = false
local DistanceESP_InvisCheck = false

-- Get the local player
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create a table to store the text drawings
local distanceTexts = {}

-- Function to create a new text drawing
local function createText()
    local text = Drawing.new("Text")
    text.Size = 10
    text.Color = Color3.new(1, 1, 1)
    text.Center = true
    text.Outline = true
    text.Visible = true
    return text
end

-- Function to check if a player is on the same team
local function isOnSameTeam(player1, player2)
    if player1.Team == nil or player2.Team == nil then
        return false
    end
    return player1.Team == player2.Team
end

-- Function to check if a character is invisible
local function isCharacterInvisible(character)
    if not character then return false end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            return false
        end
    end
    return true
end

-- Function to update the text drawings with the distance
local function updateDistanceTexts()
    if not DistanceESP_Enabled then
        for _, text in pairs(distanceTexts) do
            text.Visible = false
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if DistanceESP_TeamCheck and isOnSameTeam(LocalPlayer, player) then
                if distanceTexts[player.Name] then
                    distanceTexts[player.Name].Visible = false
                end
            elseif DistanceESP_InvisCheck and isCharacterInvisible(player.Character) then
                if distanceTexts[player.Name] then
                    distanceTexts[player.Name].Visible = false
                end
            else
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                local legPosition = player.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
                local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(legPosition)

                if not distanceTexts[player.Name] then
                    distanceTexts[player.Name] = createText()
                end

                local text = distanceTexts[player.Name]
                text.Text = string.format("[%.0f]", distance)
                text.Position = Vector2.new(screenPoint.X, screenPoint.Y)
                text.Visible = onScreen
            end
        elseif distanceTexts[player.Name] then
            distanceTexts[player.Name].Visible = false
        end
    end
end

-- Update the distances every frame
game:GetService("RunService").RenderStepped:Connect(updateDistanceTexts)

-- Cleanup the drawings when the player leaves
Players.PlayerRemoving:Connect(function(player)
    if distanceTexts[player.Name] then
        distanceTexts[player.Name]:Remove()
        distanceTexts[player.Name] = nil
    end
end)

local lplr = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local CurrentCamera = workspace.CurrentCamera
local worldToViewportPoint = CurrentCamera.worldToViewportPoint

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 3, 0)
local ArmOffset = Vector3.new(0, 2.5, 0)

local function createHealthbar()
    local healthBackground = Drawing.new("Square")
    healthBackground.Visible = false
    healthBackground.Color = Color3.new(0, 0, 0)
    healthBackground.Thickness = 1
    healthBackground.Transparency = 0.5
    healthBackground.Filled = true

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Thickness = 1
    healthBar.Filled = true

    return healthBackground, healthBar
end

local function updateHealthbar(healthBackground, healthBar, v, position, boxSize)
    if v.Character and v.Character:FindFirstChild("Humanoid") then
        local health = v.Character.Humanoid.Health
        local maxHealth = v.Character.Humanoid.MaxHealth

        if health > 0 and maxHealth > 0 then
            local Vector, onScreen = camera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)

            local RootPart = v.Character.HumanoidRootPart
            local RootPosition, RootVis = worldToViewportPoint(CurrentCamera, RootPart.Position)

            local healthRatio = health / maxHealth

            local healthBarWidth = 1
            local healthBarHeight = boxSize.Y
            local healthBarOffset = 5

            healthBackground.Size = Vector2.new(healthBarWidth, healthBarHeight)
            healthBackground.Position = position - Vector2.new(healthBarOffset + healthBarWidth, 0)
            healthBackground.Visible = onScreen and Healthbars and (not HealthBarInvischeck or v.Character.Head.Transparency ~= 1)

            healthBar.Size = Vector2.new(healthBarWidth, boxSize.Y * healthRatio)
            healthBar.Position = position - Vector2.new(healthBarOffset + healthBarWidth, 0) + Vector2.new(0, (1 - healthRatio) * boxSize.Y / 2)
            healthBar.Color = Color3.new(1 - healthRatio, healthRatio, 0)
            healthBar.Visible = onScreen and Healthbars and (not HealthBarInvischeck or v.Character.Head.Transparency ~= 1)

            if HealthBarTeamCheck then
                if v.TeamColor == lplr.TeamColor then
                    healthBackground.Visible = false
                    healthBar.Visible = false
                else
                    healthBackground.Visible = onScreen and Healthbars and (not HealthBarInvischeck or v.Character.Head.Transparency ~= 1)
                    healthBar.Visible = onScreen and Healthbars and (not HealthBarInvischeck or v.Character.Head.Transparency ~= 1)
                end
            end
        else
            healthBackground.Visible = false
            healthBar.Visible = false
        end
    else
        healthBackground.Visible = false
        healthBar.Visible = false
    end
end

local function createESP(v)
    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Color = Color3.new(0, 0, 0)
    BoxOutline.Thickness = 3
    BoxOutline.Transparency = 1
    BoxOutline.Filled = false

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1, 1, 1)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    local NameESPDraw = Drawing.new("Text")
    NameESPDraw.Visible = false
    NameESPDraw.Color = Color3.new(1, 1, 1)
    NameESPDraw.Size = 14
    NameESPDraw.Center = true
    NameESPDraw.Outline = true

    local healthBackground, healthBar = createHealthbar()

    game:GetService("RunService").RenderStepped:Connect(function()
        local onScreen = false

        if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v ~= lplr and v.Character.Humanoid.Health > 0 then
            local humanoid = v.Character.Humanoid
            local rigType = humanoid.RigType

            local RootPart = v.Character.HumanoidRootPart
            local Head = v.Character:FindFirstChild("Head")
            local RightArm = rigType == Enum.HumanoidRigType.R6 and v.Character:FindFirstChild("Right Arm") or v.Character:FindFirstChild("RightUpperArm")
            local LeftArm = rigType == Enum.HumanoidRigType.R6 and v.Character:FindFirstChild("Left Arm") or v.Character:FindFirstChild("LeftUpperArm")
            local RightLeg = rigType == Enum.HumanoidRigType.R6 and v.Character:FindFirstChild("Right Leg") or v.Character:FindFirstChild("RightUpperLeg")
            local LeftLeg = rigType == Enum.HumanoidRigType.R6 and v.Character:FindFirstChild("Left Leg") or v.Character:FindFirstChild("LeftUpperLeg")

            if RootPart and Head and RightArm and LeftArm and RightLeg and LeftLeg then
                local RootPosition, onScreen = camera:worldToViewportPoint(RootPart.Position)
                local HeadPosition = camera:worldToViewportPoint(Head.Position + HeadOff)
                local LegPosition = camera:worldToViewportPoint(RootPart.Position - LegOff)
                local RightArmPosition = camera:worldToViewportPoint(RightArm.Position + ArmOffset)
                local LeftArmPosition = camera:worldToViewportPoint(LeftArm.Position + ArmOffset)

                if onScreen then
                    if BoxInvisibleCheck and Head.Transparency == 1 then
                        BoxOutline.Visible = false
                        Box.Visible = false
                        NameESPDraw.Visible = false
                    else
                        local topY = math.min(HeadPosition.Y, RightArmPosition.Y, LeftArmPosition.Y)
                        local bottomY = math.max(LegPosition.Y, RightArmPosition.Y, LeftArmPosition.Y)

                        local boxSize = Vector2.new(3000 / RootPosition.Z, topY - bottomY)
                        BoxOutline.Size = boxSize
                        BoxOutline.Position = Vector2.new(RootPosition.X - boxSize.X / 2, bottomY)
                        BoxOutline.Visible = BoxEnabled

                        Box.Size = boxSize
                        Box.Position = Vector2.new(RootPosition.X - boxSize.X / 2, bottomY)
                        Box.Visible = BoxEnabled

                        if BoxTeamCheck then
                            if v.TeamColor == lplr.TeamColor then
                                BoxOutline.Visible = false
                                Box.Visible = false
                            else
                                BoxOutline.Visible = BoxEnabled
                                Box.Visible = BoxEnabled
                            end
                        end

                        NameESPDraw.Position = Vector2.new(RootPosition.X, topY - 20)  -- Adjusted position to render above the player
                        NameESPDraw.Text = v.Name
                        NameESPDraw.Visible = NameESPEnable

                        if NameESPInvisible and Head.Transparency == 1 then
                            NameESPDraw.Visible = false
                        end

                        if NameESPTeamCheck and v.TeamColor == lplr.TeamColor then
                            NameESPDraw.Visible = false
                        end
                    end
                else
                    BoxOutline.Visible = false
                    Box.Visible = false
                    NameESPDraw.Visible = false
                end
            else
                BoxOutline.Visible = false
                Box.Visible = false
                NameESPDraw.Visible = false
            end
        else
            BoxOutline.Visible = false
            Box.Visible = false
            NameESPDraw.Visible = false
        end

        updateHealthbar(healthBackground, healthBar, v, Box.Position, Box.Size)
    end)
end

for _, v in ipairs(game.Players:GetPlayers()) do
    createESP(v)
end

game.Players.PlayerAdded:Connect(function(v)
    createESP(v)
end)


--// Cache
local select = select
local pcall, getgenv, next, Vector2, mathclamp, type, mousemoverel = select(1, pcall, getgenv, next, Vector2.new, math.clamp, type, mousemoverel or (Input and Input.MouseMove))

--// Preventing Multiple Processes
pcall(function()
    if getgenv().Aimbot and getgenv().Aimbot.Functions then
        getgenv().Aimbot.Functions:Exit()
    end
end)

--// Environment
getgenv().Aimbot = getgenv().Aimbot or {}
local Environment = getgenv().Aimbot

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Variables
local RequiredDistance, Typing, Running, Animation, ServiceConnections = 2000, false, false, nil, {}

--// Script Settings
Environment.Settings = {
    Enabled = false,
    TeamCheck = false,
    AliveCheck = false,
    WallCheck = false, -- Laggy
    Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
    ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
    ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
    TriggerKey = Enum.KeyCode.J, -- Default keybind set to MouseButton2
    Toggle = false,
    LockPart = "Head", -- Body part to lock on
    Invisible_Check = false, -- Check for players with 1 transparency
    ClosestBodyPartAimbot = false -- Enable closest body part aimbot
}

Environment.FOVSettings = {
    Enabled = false,
    Visible = false,
    Amount = 90,
    Color = Color3.fromRGB(255, 255, 255),
    LockedColor = Color3.fromRGB(255, 70, 70),
    Transparency = 0.5,
    Sides = 60,
    Thickness = 1,
    Filled = false
}

Environment.FOVCircle = Environment.FOVCircle or Drawing.new("Circle")

--// Functions
local function CancelLock()
    Environment.Locked = nil
    if Animation then Animation:Cancel() end
    Environment.FOVCircle.Color = Environment.FOVSettings.Color
end

local function IsInFOV(targetPosition)
    local mouseLocation = UserInputService:GetMouseLocation()
    local fovCircleRadius = Environment.FOVSettings.Amount
    return (targetPosition - mouseLocation).Magnitude <= fovCircleRadius
end

local function GetClosestPlayer()
    if not Environment.Locked then
        RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)

        local closestPlayer = nil
        local closestDistance = math.huge

        for _, v in next, Players:GetPlayers() do
            if v ~= LocalPlayer then
                if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
                    if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                    if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
                    if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end
                    if Environment.Settings.Invisible_Check and v.Character.Head and v.Character.Head.Transparency == 1 then continue end -- Check for transparency

                    local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
                    local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude

                    if Distance < closestDistance and OnScreen then
                        if not Environment.FOVSettings.Enabled or IsInFOV(Vector2(Vector.X, Vector.Y)) then
                            closestPlayer = v
                            closestDistance = Distance
                        end
                    end
                end
            end
        end

        if closestPlayer then
            local closestPart = nil
            local closestPartDistance = math.huge

            if Environment.Settings.ClosestBodyPartAimbot then
                for _, part in ipairs(closestPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local distance = (part.Position - Mouse.Hit.p).Magnitude
                        if distance < closestPartDistance then
                            closestPart = part
                            closestPartDistance = distance
                        end
                    end
                end
            else
                closestPart = closestPlayer.Character:FindFirstChild(Environment.Settings.LockPart)
                closestPartDistance = closestDistance -- Use the distance to the player as the closest part distance
            end

            if closestPart then
                RequiredDistance = closestPartDistance
                Environment.Locked = closestPlayer
                Environment.Settings.LockPart = closestPart.Name
            end
        end
    elseif (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
        CancelLock()
    end
end

--// Typing Check
ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

--// Main
local function Load()
    ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
            Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
            Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
            Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
            Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
            Environment.FOVCircle.Color = Environment.FOVSettings.Color
            Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
            Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
            Environment.FOVCircle.Position = Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        else
            Environment.FOVCircle.Visible = false
        end

        if Running and Environment.Settings.Enabled then
            GetClosestPlayer()

            if Environment.Locked then
                if Environment.Settings.ThirdPerson then
                    Environment.Settings.ThirdPersonSensitivity = mathclamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)

                    local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
                    mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
                else
                    if Environment.Settings.Sensitivity > 0 then
                        Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame= CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
                        Animation:Play()
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
                    end
                end

                Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
            end
        end
    end)

    ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
        if not Typing then
            pcall(function()
                if Input.KeyCode == Environment.Settings.TriggerKey then
                    if Environment.Settings.Toggle then
                        Running = not Running

                        if not Running then
                            CancelLock()
                        end
                    else
                        Running = true
                    end
                end
            end)

            pcall(function()
                if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Environment.Settings.TriggerKey then
                    if Environment.Settings.Toggle then
                        Running = not Running

                        if not Running then
                            CancelLock()
                        end
                    else
                        Running = true
                    end
                end
            end)
        end
    end)

    ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
        if not Typing then
            if not Environment.Settings.Toggle then
                pcall(function()
                    if Input.KeyCode == Environment.Settings.TriggerKey then
                        Running = false; CancelLock()
                    end
                end)

                pcall(function()
                    if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Environment.Settings.TriggerKey then
                        Running = false; CancelLock()
                    end
                end)
            end
        end
    end)
end

--// Functions
Environment.Functions = {}

function Environment.Functions:Exit()
    for _, v in next, ServiceConnections do
        v:Disconnect()
    end

    if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end

    getgenv().Aimbot.Functions = nil
    getgenv().Aimbot = nil
    
    Load = nil; GetClosestPlayer = nil; CancelLock = nil
end

function Environment.Functions:Restart()
    for _, v in next, ServiceConnections do
        v:Disconnect()
    end

    Load()
end

function Environment.Functions:ResetSettings()
    Environment.Settings = {
        Enabled = true,
        TeamCheck = false,
        AliveCheck = true,
        WallCheck = false,
        Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
        ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
        ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
        TriggerKey = Enum.KeyCode.MouseButton2, -- Reset keybind to MouseButton2
        Toggle = false,
        LockPart = "Head" -- Body part to lock on
    }

    Environment.FOVSettings = {
        Enabled = true,
        Visible = true,
        Amount = 90,
        Color = Color3.fromRGB(255, 255, 255),
        LockedColor = Color3.fromRGB(255, 70, 70),
        Transparency = 0.5,
        Sides = 60,
        Thickness = 1,
        Filled = false
    }
end

--// Load
Load()

local Decimals = 4
local Clock = os.clock()

local MainSection = MainTab:AddSection("Main", 1)

MainSection:AddToggle({
    text = "Aimbot",
    state = false,
    risky = false,
    tooltip = "Enables Aimbot",
    flag = "AimbotEnabled",
    callback = function(v)
        Environment.Settings.Enabled = v
    end
}):AddBind({
    enabled = true,
    text = "Aimbot",
    tooltip = "Select Keybind",
    mode = "hold",
    bind = "None",
    flag = "AimbotBind",
    state = false,
    nomouse = false,
    risky = false,
    noindicator = false,
    callback = function(v)

    end,
    keycallback = function(v)
        Environment.Settings.TriggerKey = v
    end
})

MainSection:AddList({
    enabled = true,
    text = "Aimbot type", 
    tooltip = "Choose if mouse or camera",
    selected = "Camera",
    multi = false,
    open = false,
    max = 2,
    values = {'Mouse', 'Camera'},
    risky = false,
    callback = function(v)
        if v == 'Mouse' then
            Environment.Settings.ThirdPerson = true
        elseif v == 'Camera' then
            Environment.Settings.ThirdPerson = false
        end
    end
})

MainSection:AddToggle({
    text = "Wall",
    state = false,
    risky = false,
    tooltip = "Enables Wallcheck",
    flag = "WallCheckEnabled",
    callback = function(v)
        Environment.Settings.WallCheck = v
    end
})

MainSection:AddToggle({
    text = "Invisible",
    state = false,
    risky = false,
    tooltip = "Enables Invisible Check",
    flag = "InvisibleCheckAimbot",
    callback = function(v)
        Environment.Settings.Invisible_Check = v
    end
})

MainSection:AddToggle({
    text = "Alive",
    state = false,
    risky = false,
    tooltip = "Enables Alive Check",
    flag = "AliveCheckAimbot",
    callback = function(v)
        Environment.Settings.AliveCheck = v
    end
})

MainSection:AddToggle({
    text = "Team",
    state = false,
    risky = false,
    tooltip = "Enables Team Check",
    flag = "TeamCheckAimbot",
    callback = function(v)
        Environment.Settings.TeamCheck = v
    end
})

MainSection:AddToggle({
    text = "ForceField",
    state = false,
    risky = false,
    tooltip = "Enables ForceField Check",
    flag = "FFCheckAimbot",
    callback = function(v)
        Environment.Settings.ForceField_Check = v
    end
})


MainSection:AddToggle({
    text = "Closest Point",
    state = false,
    risky = false,
    tooltip = "Enables Closest Point",
    flag = "ClosestPointEnabled",
    callback = function(v)
        Environment.Settings.ClosestBodyPartAimbot = v
    end
})

MainSection:AddList({
    enabled = true,
    text = "Aim Part", 
    tooltip = "The part the aimbot locks onto",
    selected = "Head",
    multi = false,
    open = false,
    max = 6,
    values = {'Head', 'HumanoidRootPart', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'},
    risky = false,
    callback = function(v)
        Environment.Settings.LockPart = v
    end
})

MainSection:AddSlider({
    enabled = true,
    text = "Smoothness",
    tooltip = "Aimbot smoothness",
    flag = "AimSens",
    suffix = "",
    dragging = true,
    focused = false,
    min = 0,
    max = 5,
    increment = 0.01,
    risky = false,
    callback = function(v)
        Environment.Settings.Sensitivity = v
    end
})

local FOVSection = MainTab:AddSection("FOV", 2)

FOVSection:AddToggle({
    text = "Enable",
    state = false,
    risky = false,
    tooltip = "Draws FOV onto the screen",
    flag = "FOVEnabled",
    callback = function(v)
        Environment.FOVSettings.Enabled = v
    end
})

FOVSection:AddToggle({
    text = "Visualise",
    state = false,
    risky = false,
    tooltip = "Draws FOV onto the screen",
    flag = "FOVVisualise",
    callback = function(v)
        Environment.FOVSettings.Visible = v
    end
})

FOVSection:AddSlider({
    enabled = true,
    text = "Radius",
    tooltip = "FOV radius",
    flag = "FOVRadius",
    suffix = "",
    dragging = true,
    focused = false,
    min = 1,
    max = 800,
    increment = 1,
    risky = false,
    callback = function(v)
        Environment.FOVSettings.Amount = v
    end
})

local ESPSection = ESPTab:AddSection("ESP", 1)

ESPSection:AddToggle({
    text = "Boxes",
    state = false,
    tooltip = "Enables box ESP",
    flag = "BoxEnabled",
    callback = function(v)
        BoxEnabled = v
    end
})

ESPSection:AddToggle({
    text = "Health Bar",
    state = false,
    tooltip = "Enables HealthBar ESP",
    flag = "HealthbarEnabled",
    callback = function(v)
        Healthbars = v
    end
})

ESPSection:AddToggle({
    text = "Names",
    state = false,
    tooltip = "Enables Name ESP",
    flag = "NameESPEnabled",
    callback = function(v)
        NameESPEnable = v
    end
})

ESPSection:AddToggle({
    text = "Distance",
    state = false,
    tooltip = "Enables distance ESP",
    flag = "DistanceEnabled",
    callback = function(v)
        DistanceESP_Enabled = v
    end
})

ESPSection:AddToggle({
    text = "Invisible Check",
    state = false,
    tooltip = "Stops ESP drawing on invisible players",
    flag = "ESPInvisibleCheck",
    callback = function(v)
        BoxInvisibleCheck = v
        HealthBarInvischeck = v
        DistanceESP_InvisCheck = v
        NameESPInvisCheck = v
        NameESPInvisible = v
    end
})

ESPSection:AddToggle({
    text = "Team Check",
    state = false,
    tooltip = "Stops ESP drawing onto teammates",
    flag = "ESPTeamCheck",
    callback = function(v)
        BoxTeamCheck = v
        HealthBarTeamCheck = v
        DistanceESP_TeamCheck = v
        NameESPTeamCheck = v
    end
})

--//xray

local XRaySection = ESPTab:AddSection("XRay", 3)

local function xray(xrayEnabled)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
            v.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
        end
    end
end   

XRaySection:AddToggle({
    text = "XRay",
    state = false,
    risky = false,
    tooltip = "Enable XRay",
    flag = "XRay_toggle",
    callback = function(v)
        xray(v)
    end
})

--//cframe walk bit buggy

local MovementSection = MiscTab:AddSection("Movement", 1)

--[[
    
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().cframe = true
getgenv().cfrene = false
getgenv().Multiplier = 0.1
getgenv().ToggleKey = Enum.KeyCode.F

local function onKeyPress(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == getgenv().ToggleKey then
        getgenv().cfrene = not getgenv().cfrene
    end
end

local function moveCharacter()
    while true do
        RunService.Stepped:Wait()
        if getgenv().cframe and getgenv().cfrene then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + character.Humanoid.MoveDirection * getgenv().Multiplier
            end
        end
    end
end

UserInputService.InputBegan:Connect(onKeyPress)

local function setupCharacterEvents(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        getgenv().cfrene = false
    end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    setupCharacterEvents(character)
end)

if LocalPlayer.Character then
    setupCharacterEvents(LocalPlayer.Character)
end


MovementSection:AddToggle({
    enabled = true,
    text = "CFrame Walk",
    state = false,
    tooltip = "Enable CFrame Walk",
    flag = "CFrame_Walk_Toggle",
    callback = function(v)
        getgenv().cfrene = v
    end
}):AddBind({
    enabled = true,
    text = "CFrame Walk",
    tooltip = "CFrame Keybind",
    mode = "toggle",
    bind = "F",
    flag = "ToggleKey_155",
    state = false,
    nomouse = false,
    risky = false,
    noindicator = false,
    callback = function(v)
    end,
    keycallback = function(v)
        getgenv().ToggleKey = v
    end
})

MovementSection:AddSlider({
    enabled = true,
    text = "Speed",
    tooltip = "CFrame Speed",
    flag = "Slider_12",
    suffix = "",
    dragging = true,
    focused = false,
    min = 0.1,
    max = 10,
    increment = 0.1,
    callback = function(v)
        getgenv().Multiplier = v
    end
})

--// bhop

MovementSection:AddSeparator({
    enabled = true,
    text = "Bunny Hop"
})

]]--
getgenv().bhopEnabled = false

local function bhop()
    if getgenv().bhopEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end

UserInputService.InputBegan:Connect(onKeyPress)
RunService.RenderStepped:Connect(bhop)

local function changeBhopKey(newKey)
    getgenv().bhopKey = newKey
end

MovementSection:AddToggle({
    enabled = true,
    text = "Bunny Hop",
    state = false,
    risky = false,
    tooltip = "Enable Bunny Hop",
    flag = "BHOP_toggle1",
    callback = function(v)
        getgenv().bhopEnabled = v
    end
})

--// basic walkspeed and jump power changer

MovementSection:AddSeparator({
    enabled = true,
    text = "General"
})

local function changeJumpPower(value)
    lplr.Character.Humanoid.JumpPower = value
end

local function changeWalkSpeed(value)
    lplr.Character.Humanoid.WalkSpeed = value
end

MovementSection:AddSlider({
    enabled = true,
    text = "Walkspeed",
    tooltip = "Adjust the walkspeed of your character",
    flag = "Walkspeed_Slider",
    suffix = "",
    dragging = true,
    focused = false,
    min = 16,
    max = 100,
    increment = 0.1,
    risky = false,
    callback = function(v)
        changeWalkSpeed(v)
    end
})

MovementSection:AddSlider({
    enabled = true,
    text = "Jump Power",
    tooltip = "Adjust the jump power of your character",
    flag = "Jumppower_Slider",
    suffix = "",
    dragging = true,
    focused = false,
    min = 50,
    max = 500,
    increment = 0.1,
    risky = false,
    callback = function(v)
        changeJumpPower(v)
    end
})

--// Lighting Section

local LightingSection = MiscTab:AddSection("Lighting", 2)

local function changeBrightness(value)
    game:GetService("Lighting").Brightness = value
end

LightingSection:AddSlider({
    enabled = true,
    text = "Brightness",
    tooltip = "Adjust the brightness of the game",
    flag = "Brightness_Slider",
    suffix = "",
    dragging = true,
    focused = false,
    min = 1,
    max = 10,
    increment = 0.1,
    risky = false,
    callback = function(v)
        changeBrightness(v)
    end
})

--// Third Person 

local ThirdPersonSection = MiscTab:AddSection("Third Person", 3)

local enabled5 = false

local function ThirdPersonFunction()
    while enabled5 do
        game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic 
        game.Players.LocalPlayer.CameraMaxZoomDistance = 1000
        game.Players.LocalPlayer.CameraMinZoomDistance = 0
        wait(0.5) 
    end
end

ThirdPersonSection:AddToggle({
    text = "Third Person",
    state = false,
    risky = false,
    tooltip = "Enable Third Person",
    flag = "Toggle_1",
    callback = function(v)
        enabled5 = v
        if enabled5 then
            ThirdPersonFunction()
        end
    end
})

local enabled1 = false

local transparencyvalue = 0

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp1 = character.HumanoidRootPart

local function transparentCharFunction()
    while enabled1 do
        wait(0.05)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = transparencyvalue
                hrp1.Transparency = 1
            elseif part:IsA("ParticleEmitter") or part:IsA("Trail") then
                part.Enabled = false
            end
        end
    end    
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    transparentCharFunction()
end)

ThirdPersonSection:AddToggle({
    text = "Make Character Transparent",
    state = false,
    risky = true,
    tooltip = "Make your character transparent",
    flag = "Toggle_15675",
    risky = false,
    callback = function(v)
        enabled1 = v
        if enabled1 then
            transparentCharFunction()
        end    
    end
})

ThirdPersonSection:AddSlider({
    enabled = true,
    text = "Transparency",
    tooltip = "Change Transparency",
    flag = "Slider_1124241",
    suffix = "",
    dragging = true,
    focused = false,
    min = 0,
    max = 1,
    increment = 0.01,
    risky = false,
    callback = function(v)
        transparencyvalue = v
    end
})

--[[ shit just dont work? 

local camera1 = game.StarterPlayer
local cameraMode = ""

local function changeCameraMode(mode)
    if mode == "Classic" then
        camera1.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode.Classic
    elseif mode == "CameraToggle" then
        camera1.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode.CameraToggle
    end
end

ThirdPersonSection:AddList({
    enabled = true,
    text = "Select Camera Mode", 
    tooltip = "CameraToggle is recommended for third person",
    selected = "Classic",
    multi = false,
    open = false,
    max = 4,
    values = {"Classic", "CameraToggle (Recommended)"},
    risky = false,
    callback = function(v)
        cameraMode = v
        changeCameraMode(cameraMode)
    end
})

]]

--// Anti Aim

local AntiAimSection = MiscTab:AddSection("Anti Aim", 1)

local cframetpdesync = false
local cframetpdesynctype = ""

local customcframetpx = 0
local customcframetpy = 0
local customcframetpz = 0

local desync_stuff = {}

game:GetService("RunService").heartbeat:Connect(
    function()
        if cframetpdesync == true then
            desync_stuff[1] = lplr.Character.HumanoidRootPart.CFrame
            local fakeCFrame = lplr.Character.HumanoidRootPart.CFrame
            if cframetpdesynctype == "Nothing" then
                fakeCFrame = fakeCFrame * CFrame.new()
            elseif cframetpdesynctype == "Underground" then
                fakeCFrame = fakeCFrame * CFrame.new(customcframetpx, customcframetpy, customcframetpz)
            end
            lplr.Character.HumanoidRootPart.CFrame = fakeCFrame
            game:GetService("RunService").RenderStepped:Wait()
            lplr.Character.HumanoidRootPart.CFrame = desync_stuff[1]
        else
        end
    end
)

AntiAimSection:AddToggle({
    enabled = true,
    text = "Anti Aim",
    state = false,
    risky = true,
    tooltip = "Enable Anti Aim",
    flag = "AntiAimToggle1",
    risky = false,
    callback = function(v)
        cframetpdesync = v
    end
})

AntiAimSection:AddList({
    enabled = true,
    text = "Anti Aim Type", 
    tooltip = "Select Anti Aim Type",
    selected = "Nothing", 
    multi = false,
    open = false,
    max = 4,
    values = {"Nothing", "Underground"},
    risky = false,
    callback = function(v)
        cframetpdesynctype = v
    end
})

AntiAimSection:AddSlider({
    enabled = true,
    text = "X",
    tooltip = "Change the X offset",
    flag = "Slider_11",
    suffix = "",
    dragging = true,
    focused = false,
    min = -50,
    max = 50,
    increment = 1,
    risky = false,
    callback = function(v)
        customcframetpx = v
    end
})

AntiAimSection:AddSlider({
    enabled = true,
    text = "Y",
    tooltip = "Change the Y offset",
    flag = "Slider_13",
    suffix = "",
    dragging = true,
    focused = false,
    min = -50,
    max = 50,
    increment = 1,
    risky = false,
    callback = function(v)
        customcframetpy = v 
    end
})

AntiAimSection:AddSlider({
    enabled = true,
    text = "Z",
    tooltip = "Change the Z offset",
    flag = "Slider_15",
    suffix = "",
    dragging = true,
    focused = false,
    min = -50,
    max = 50,
    increment = 1,
    risky = false,
    callback = function(v)
        customcframetpz = v 
    end
})

--// Camera Offsets

AntiAimSection:AddSeparator({
    enabled = true,
    text = "Camera Offset"
})

local cameraToggle = false

local offsetX = 0 
local offsetY = 0 
local offsetZ = 0 

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = game.Workspace.CurrentCamera

local cameraPart = Instance.new("Part")
cameraPart.Name = "CameraPosition"
cameraPart.Size = Vector3.new(math.huge, math.huge, math.huge)
cameraPart.Transparency = 1
cameraPart.Anchored = true
cameraPart.CanCollide = false
cameraPart.Parent = game.Workspace

local function updateCamera()
    if cameraToggle then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            cameraPart.Position = rootPart.Position + Vector3.new(offsetX, offsetY, offsetZ)
            camera.CameraSubject = cameraPart
        end
    else
        camera.CameraSubject = character:FindFirstChild("Humanoid") or character:FindFirstChild("Head")
    end
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    updateCamera()
end

player.CharacterAdded:Connect(onCharacterAdded)

game:GetService("RunService").RenderStepped:Connect(updateCamera)

AntiAimSection:AddToggle({
    text = "Camera Offset",
    state = false,
    risky = true,
    tooltip = "Enable Camera Offset",
    flag = "Toggle_1",
    risky = false,
    callback = function(v)
        cameraToggle = v
        updateCamera() 
    end
})

AntiAimSection:AddSlider({
    enabled = true,
    text = "X",
    tooltip = "Change the X offset",
    flag = "Slider_11",
    suffix = "",
    dragging = true,
    focused = false,
    min = -50,
    max = 50,
    increment = 1,
    risky = false,
    callback = function(v)
        offsetX = v
    end
})

AntiAimSection:AddSlider({
    enabled = true,
    text = "Y",
    tooltip = "Change the Y offset",
    flag = "Slider_13",
    suffix = "",
    dragging = true,
    focused = false,
    min = -50,
    max = 50,
    increment = 1,
    risky = false,
    callback = function(v)
        offsetY = v
    end
})

AntiAimSection:AddSlider({
    enabled = true,
    text = "Z",
    tooltip = "Change the Z offset",
    flag = "Slider_157",
    suffix = "",
    dragging = true,
    focused = false,
    min = -50,
    max = 50,
    increment = 1,
    risky = false,
    callback = function(v)
        offsetZ = v
    end
})

local tg = 4888256398 

local function isTargetGame()
    return game.PlaceId == tg
end

if isTargetGame() then
    local SkinTabSection = MiscTab:AddSection("SkinTab", 5)

    local replicatedStorage = game:GetService("ReplicatedStorage")
    local projectXFolder = replicatedStorage:FindFirstChild("ProjectXStorage") or Instance.new("Folder")
    projectXFolder.Name = "ProjectXStorage"
    projectXFolder.Parent = replicatedStorage

    local function cloneModelIntoFolder(model, folder)
        local clonedModel = model:Clone()
        clonedModel.Parent = folder
        return clonedModel
    end

    local ar15WeaponsFolder = replicatedStorage:WaitForChild("Models"):WaitForChild("Weapons"):FindFirstChild("AR-15")
    local glock19WeaponsFolder = replicatedStorage:WaitForChild("Models"):WaitForChild("Weapons"):FindFirstChild("Glock 19")

    if ar15WeaponsFolder and glock19WeaponsFolder then
        for _, model in ipairs(ar15WeaponsFolder:GetChildren()) do
            cloneModelIntoFolder(model, projectXFolder)
        end
        for _, model in ipairs(glock19WeaponsFolder:GetChildren()) do
            cloneModelIntoFolder(model, projectXFolder)
        end
    end

    local function updateWeapon(weaponFolder, defaultName, newName, soundId)
        local defaultModel = weaponFolder:FindFirstChild(defaultName)
        if defaultModel then
            defaultModel:Destroy()
        end
        
        local newModel = weaponFolder:FindFirstChild(newName)
        if newModel then
            local clonedNewModel = newModel:Clone()
            clonedNewModel.Name = defaultName
            if clonedNewModel:FindFirstChild("Grip") and clonedNewModel.Grip:FindFirstChild("Fire") then
                clonedNewModel.Grip.Fire.SoundId = soundId
            end
            clonedNewModel.Parent = weaponFolder
        end
    end

    local selectedSkin = "N/A"
    local function changeSkin(skin)
        if selectedSkin == skin then
            return
        end
        
        selectedSkin = skin
        
        local skins = {
            Wyvern = {ar15 = "AR-15_Wyvern", glock = "Glock 19_Wyvern", ar15Sound = "rbxassetid://16114480242", glockSound = "rbxassetid://16114355620"},
            Tsunami = {ar15 = "AR-15_Tsunami", glock = "Glock 19_Tsunami", ar15Sound = "rbxassetid://3993858994", glockSound = "rbxassetid://3175583137"},
            Magma = {ar15 = "AR-15_Magma", glock = "Glock 19_Magma", ar15Sound = "rbxassetid://709722701", glockSound = "rbxassetid://3017057413"},
            Ion = {ar15 = "AR-15_Ion", glock = "Glock 19_Ion", ar15Sound = "rbxassetid://5968535032", glockSound = "rbxassetid://1517589139"},
            Toxic = {ar15 = "AR-15_Toxic", glock = "Glock 19_Toxic", ar15Sound = "rbxassetid://6096390331", glockSound = "rbxassetid://3175583137"},
            Staff = {ar15 = "AR-15_Staff", glock = "Glock 19_Staff", ar15Sound = "rbxassetid://14451535723", glockSound = "rbxassetid://14451535723"},
            Boundless = {ar15 = "AR-15_Boundless", glock = "Glock 19_Boundless", ar15Sound = "rbxassetid://15839018814", glockSound = "rbxassetid://15837541604"},
            Scythe = {ar15 = "AR-15_Scythe", glock = "Glock 19_Scythe", ar15Sound = "rbxassetid://17108695959", glockSound = "rbxassetid://17108696161"},
            S2 = {ar15 = "AR-15_S2", glock = "Glock 19_S2", ar15Sound = "rbxassetid://6862108495", glockSound = "rbxassetid://6185638804"},
            Catalyst = {ar15 = "AR-15_Catalyst", glock = "Glock 19_Catalyst", ar15Sound = "rbxassetid://14483100795", glockSound = "rbxassetid://14483100795"},
            Offwhite = {ar15 = "AR-15_Offwhite", glock = "Glock 19_Offwhite", ar15Sound = "rbxassetid://15786931534", glockSound = "rbxassetid://15786931708"},
            N2 = {ar15 = "AR-15_N2", glock = "Glock 19_N2", ar15Sound = "rbxassetid://6862108495", glockSound = "rbxassetid://6185638804"},
            X2 = {ar15 = "AR-15_X2", glock = "Glock 19_X2", ar15Sound = "rbxassetid://17487820584", glockSound = "rbxassetid://1421545840"},
            Pulsar = {ar15 = "AR-15_Pulsar", glock = "Glock 19_Pulsar", ar15Sound = "rbxassetid://858857503", glockSound = "rbxassetid://858857503"},
            Blueberry = {ar15 = "AR-15_Blueberry", glock = "Glock 19_Blueberry", ar15Sound = "rbxassetid://13960258523", glockSound = "rbxassetid://6196023927"},
            Rusted = {ar15 = "AR-15_Rusted", glock = "Glock 19_Rusted", ar15Sound = "rbxassetid://16496768586", glockSound = "rbxassetid://16338769384"},
            Frigid = {ar15 = "AR-15_Frigid", glock = "Glock 19_Frigid", ar15Sound = "rbxassetid://5400076200", glockSound = "rbxassetid://6196023927"},
            Anniversary = {ar15 = "AR-15_Anniversary", glock = "Glock 19_Anniversary", ar15Sound = "rbxassetid://5400076200", glockSound = "rbxassetid://244233148"},
            HellSpawn = {ar15 = "AR-15_HellSpawn", glock = "Glock 19_HellSpawn", ar15Sound = "rbxassetid://709722701", glockSound = "rbxassetid://244233148"}
        }
        
        local selected = skins[skin]
        if selected then
            updateWeapon(ar15WeaponsFolder, "AR-15_Default", selected.ar15, selected.ar15Sound)
            updateWeapon(glock19WeaponsFolder, "Glock 19_Default", selected.glock, selected.glockSound)
        end
    end

    SkinTabSection:AddList({
        enabled = true,
        text = "Skin Changer",
        tooltip = "Changes the skin of your gun",
        selected = selectedSkin,
        multi = false,
        open = false,
        max = 20,
        values = {
            "Wyvern", "Tsunami", "Toxic", "Staff", "Boundless", "Scythe", "S2", "Catalyst", "Offwhite", "N2", "Magma", "Ion", "X2", "Pulsar", "Blueberry", "Rusted", "Frigid", "Anniversary", "HellSpawn"
        },
        callback = function(v)
            changeSkin(v)
        end
    })
end

local SpinBotSection = MiscTab:AddSection("Spinbot", 6)

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local SpinBotspeed = 0
local spinActive = false
local velocity
local humRoot

local function initialize()
    repeat task.wait() until plr.Character
    humRoot = plr.Character:WaitForChild("HumanoidRootPart")
    plr.Character:WaitForChild("Humanoid").AutoRotate = false
end

local function startSpin()
    if spinActive then return end 
    velocity = Instance.new("AngularVelocity")
    velocity.Attachment0 = humRoot:WaitForChild("RootAttachment")
    velocity.MaxTorque = math.huge
    velocity.AngularVelocity = Vector3.new(0, SpinBotspeed, 0)
    velocity.Parent = humRoot
    velocity.Name = "Spinbot"
    spinActive = true
end

local function stopSpin()
    if not spinActive then return end
    
    if velocity then
        velocity:Destroy()
    end
    spinActive = false
end

local function updateSpinSpeed()
    if velocity then
        velocity.AngularVelocity = Vector3.new(0, SpinBotspeed, 0)
    end
end

SpinBotSection:AddToggle({
    text = "Spinbot",
    state = false,
    risky = false,
    tooltip = "Enable Spinbot",
    flag = "Toggle_3252351",
    risky = false,
    callback = function(v)
        if v then
            initialize()
            startSpin()
            local function onCharacterAdded(newCharacter)
                character = newCharacter
                startSpin()
            end
        else
            stopSpin()
            plr.Character:WaitForChild("Humanoid").AutoRotate = true
        end
    end
})

SpinBotSection:AddSlider({
    enabled = true,
    text = "Speed",
    tooltip = "Increase Speed",
    flag = "Slider_1555",
    suffix = "",
    dragging = true,
    focused = false,
    min = 0,
    max = 100,
    increment = 0.1,
    risky = false,
    callback = function(v)
        SpinBotspeed = v
        updateSpinSpeed()
    end
})

local Time = (string.format("%."..tostring(Decimals).."f", os.clock() - Clock))
library:SendNotification(("Loaded In "..tostring(Time)), 6)
