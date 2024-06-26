getgenv().Config = {
	Invite = "getprojectx",
	Version = "1.1",
}

getgenv().luaguardvars = {
	DiscordName = "bbcdemon_455",
}

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bbcdemon445/dgrfgdfdasd/main/Ohio."))()

library:init() -- Initalizes Library Do Not Delete This

local Window = library.NewWindow({
	title = "tg.ware",
	size = UDim2.new(0, 600, 0.5, 6)
})

local tabs = {
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
	AntiAim = Window:AddTab("Anti Aim"),
	Misc = Window:AddTab("Misc"),
	Settings1 = library:CreateSettingsTab(Window),
}

local sections = {
    AimbotSection = tabs.Combat:AddSection("Aimbot", 1),
    FOVSection = tabs.Combat:AddSection("FOV", 2),
    WhitelistSection = tabs.Combat:AddSection("Whitelist", 5),
    ESPSection = tabs.Visuals:AddSection("ESP", 1),
    ESPColorSection = tabs.Visuals:AddSection("Colors", 2),
    XRaySection = tabs.Visuals:AddSection("XRay", 3),
    AntiAimSection = tabs.AntiAim:AddSection("Anti Aim", 1),
    CameraOffsetSection = tabs.AntiAim:AddSection("Camera Offset", 2),
    MovementSection = tabs.Misc:AddSection("Movement", 1),
    ThirdPersonSection = tabs.Misc:AddSection("Third Person", 2),
    RageSection = tabs.Misc:AddSection("Rage", 1),
}

if game.PlaceId == 4888256398 or game.PlaceId == 17227761001 or game.PlaceId == 15247475957 then
    sections.TGSection = tabs.Misc:AddSection("Tournament Grounds", 2)
end

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Cache = {}
local mouse = LocalPlayer:GetMouse()
local mousePosition = Vector2.new(mouse.X, mouse.Y)

-- Function to update mouse position
local function updateMousePosition()
    mousePosition = Vector2.new(mouse.X, mouse.Y)
end

RunService.RenderStepped:Connect(updateMousePosition)

-- Settings
local ESP_SETTINGS = {
    OutlineColor = Color3.new(0, 0, 0),
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    DistanceColor = Color3.new(1, 1, 1),
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),
    CharSize = Vector2.new(4, 6),
    TeamCheck = false,
    InvisCheck = false,
    AliveCheck = false,
    Enabled = false,
    ShowBox = false,
    BoxType = "2D",
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowTracer = false,
    TracerColor = Color3.new(1, 1, 1),
    TracerThickness = 1,
    TracerPosition = "Bottom",
    ToolESPColor = Color3.new(1, 1, 1),
    ShowTool = false,
    TeamColor = false,  -- Whether to use team colors
}

local function create(class, properties)
    local drawing = Drawing.new(class)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

local function createEsp(player)
    local esp = {
        boxOutline = create("Square", {
            Color = ESP_SETTINGS.OutlineColor,
            Thickness = 2,
            Filled = false,
            Visible = false
        }),
        box = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = false,
            Visible = false
        }),
        filledbox = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = true,
            Visible = false
        }),
        name = create("Text", {
            Color = ESP_SETTINGS.NameColor,
            Outline = true,
            Center = true,
            Size = 13,
            Visible = false
        }),
        tool = create("Text", {
            Color = ESP_SETTINGS.ToolESPColor,
            Outline = true,
            Center = true,
            Size = 12,
            Visible = false
        }),
        healthOutline = create("Line", {
            Thickness = 3,
            Color = ESP_SETTINGS.HealthOutlineColor,
            Visible = false
        }),
        health = create("Line", {
            Thickness = 2,
            Visible = false
        }),
        distance = create("Text", {
            Color = ESP_SETTINGS.DistanceColor,
            Size = 12,
            Outline = true,
            Center = true,
            Visible = false
        }),
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.TracerThickness,
            Color = ESP_SETTINGS.TracerColor,
            Transparency = 1,
            Visible = false
        }),
        boxLines = {}
    }

    Cache[player] = esp
end

local function removeEsp(player)
    local esp = Cache[player]
    if not esp then return end

    for key, drawing in pairs(esp) do
        if drawing.Remove then
            drawing:Remove()
        elseif key == "boxLines" then
            for _, line in ipairs(drawing) do
                if line.Remove then
                    line:Remove()
                end
            end
        else
            print("No Remove method for", key)
        end
    end

    Cache[player] = nil
end

local function updateEsp()
    for player, esp in pairs(Cache) do
        local character, team = player.Character, player.Team
        if character and (not ESP_SETTINGS.TeamCheck or (team and team ~= LocalPlayer.Team)) then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")
            local isnotDead = ESP_SETTINGS.AliveCheck and humanoid and humanoid.Health == 0
            local isInvisible = ESP_SETTINGS.InvisCheck and head and head.Transparency == 1
            local shouldShow = ESP_SETTINGS.Enabled and not isInvisible and not isnotDead

            if rootPart and shouldShow then
                local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local hrp2D = position
                    local charSize = (Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                    local boxSize = Vector2.new(math.floor(charSize * 1.5), math.floor(charSize * 1.9))
                    local boxPosition = Vector2.new(math.floor(hrp2D.X - charSize * 1.5 / 2), math.floor(hrp2D.Y - charSize * 1.6 / 2))

                    if ESP_SETTINGS.ShowName and ESP_SETTINGS.Enabled then
                        esp.name.Visible = true
                        esp.name.Text = string.lower(player.Name)
                        esp.name.Position = Vector2.new(boxSize.X / 2 + boxPosition.X, boxPosition.Y - 16)
                        if ESP_SETTINGS.TeamColor and team then
                            esp.name.Color = team.TeamColor.Color
                        else
                            esp.name.Color = ESP_SETTINGS.NameColor
                        end
                    else
                        esp.name.Visible = false
                    end

                    if ESP_SETTINGS.ShowTool and ESP_SETTINGS.Enabled then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            esp.tool.Visible = true
                            esp.tool.Text = string.lower(tool.Name)
                        else
                            esp.tool.Visible = true
                            esp.tool.Text = "none"
                        end
                        esp.tool.Position = Vector2.new(boxSize.X / 2 + boxPosition.X, boxPosition.Y - 32)
                        if ESP_SETTINGS.TeamColor and team then
                            esp.tool.Color = team.TeamColor.Color
                        else
                            esp.tool.Color = ESP_SETTINGS.ToolESPColor
                        end
                    else
                        esp.tool.Visible = false
                    end

                    if ESP_SETTINGS.ShowBox and ESP_SETTINGS.Enabled then
                        if ESP_SETTINGS.BoxType == "2D" then
                            esp.boxOutline.Size = boxSize
                            esp.boxOutline.Position = boxPosition
                            esp.boxOutline.Color = ESP_SETTINGS.OutlineColor  -- Always use outline color
                            if ESP_SETTINGS.TeamColor and team then
                                esp.box.Color = team.TeamColor.Color
                            else
                                esp.box.Color = ESP_SETTINGS.BoxColor
                            end
                            esp.box.Size = boxSize
                            esp.box.Position = boxPosition
                            esp.box.Visible = true
                            esp.boxOutline.Visible = true
                        end
                    else
                        esp.boxOutline.Visible = false
                        esp.box.Visible = false
                    end

                    if ESP_SETTINGS.ShowHealth and ESP_SETTINGS.Enabled then
                        esp.healthOutline.Visible = true
                        esp.health.Visible = true
                        local healthPercentage = humanoid.Health / humanoid.MaxHealth
                        esp.healthOutline.From = Vector2.new(boxPosition.X - 5.5, boxPosition.Y + boxSize.Y)
                        esp.healthOutline.To = Vector2.new(esp.healthOutline.From.X, esp.healthOutline.From.Y - boxSize.Y)
                        esp.health.From = Vector2.new(boxPosition.X - 5, boxPosition.Y + boxSize.Y)
                        esp.health.To = Vector2.new(esp.health.From.X, esp.health.From.Y - healthPercentage * boxSize.Y)
                        esp.health.Color = ESP_SETTINGS.HealthLowColor:Lerp(ESP_SETTINGS.HealthHighColor, healthPercentage)
                    else
                        esp.healthOutline.Visible = false
                        esp.health.Visible = false
                    end

                    if ESP_SETTINGS.ShowDistance and ESP_SETTINGS.Enabled then
                        local distance = (Camera.CFrame.p - rootPart.Position).Magnitude
                        esp.distance.Text = string.format("%.1f studs", distance)
                        esp.distance.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 5)
                        esp.distance.Visible = true

                        if ESP_SETTINGS.TeamColor and team then
                            esp.distance.Color = team.TeamColor.Color
                        else
                            esp.distance.Color = ESP_SETTINGS.DistanceColor
                        end
                    else
                        esp.distance.Visible = false
                    end

                    if ESP_SETTINGS.ShowTracer and ESP_SETTINGS.Enabled then
                        if ESP_SETTINGS.TeamColor and team then
                            esp.tracer.Color = team.TeamColor.Color
                        else
                            esp.tracer.Color = ESP_SETTINGS.TracerColor
                        end
                        if ESP_SETTINGS.TracerPosition == "Top" then
                            esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                        elseif ESP_SETTINGS.TracerPosition == "Middle" then
                            esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        elseif ESP_SETTINGS.TracerPosition == 'Mouse' then
                            local tracerOffset = Vector2.new(0, 60)
                            esp.tracer.From = mousePosition + tracerOffset
                        else
                            esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        end

                        if ESP_SETTINGS.TeamCheck and player.TeamColor == LocalPlayer.TeamColor then
                            esp.tracer.Visible = false
                        else
                            esp.tracer.Visible = true
                            esp.tracer.To = Vector2.new(hrp2D.X, hrp2D.Y)
                        end
                    else
                        esp.tracer.Visible = false
                    end

                else
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(esp) do
                    drawing.Visible = false
                end
            end
        else
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
    end
end

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createEsp(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createEsp(player)
    end
end)

-- Remove ESP when players leave
Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

-- Update ESP on each frame
RunService.RenderStepped:Connect(updateEsp)

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
    WallCheck = false, -- Enable wall check
    Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
    ThirdPerson = false, -- Uses mousemoveabs instead of CFrame to support locking in third person (could be choppy)
    ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
    TriggerKey = Enum.KeyCode.J, -- Default keybind set to MouseButton2
    Toggle = false,
    LockPart = "Head", -- Body part to lock on
    Invisible_Check = false, -- Check for players with 1 transparency
    ClosestBodyPartAimbot = false, -- Enable closest body part aimbot
    WhitelistedPlayers = {} -- Array of whitelisted player names
}

Environment.FOVSettings = {
    Enabled = false,
    Visible = false,
    Amount = 1,
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

local function IsObstructed(target)
    local settings = Environment.Settings
    if not settings.WallCheck then
        return false
    end

    local targetCharacter = target.Character
    if not targetCharacter then
        return false
    end

    local lockPart = targetCharacter:FindFirstChild(settings.LockPart)
    if not lockPart then
        return false
    end

    local camera = workspace.CurrentCamera
    if camera then
        local parts = camera:GetPartsObscuringTarget({lockPart.Position}, {game.Players.LocalPlayer.Character, targetCharacter})
        return #parts > 0
    end

    return false
end

local function GetClosestPlayer()
    if not Environment.Locked then
        RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)

        local closestPlayer = nil
        local closestDistance = math.huge

        for _, v in next, Players:GetPlayers() do
            if v ~= LocalPlayer then
                local character = v.Character
                if character and character:FindFirstChild(Environment.Settings.LockPart) and character:FindFirstChildOfClass("Humanoid") then
                    if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                    if Environment.Settings.AliveCheck and character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
                    if Environment.Settings.Invisible_Check and character.Head and character.Head.Transparency == 1 then continue end
                    if table.find(Environment.Settings.WhitelistedPlayers, v.Name) then continue end

                    local lockPartPosition = character[Environment.Settings.LockPart].Position
                    local Vector, OnScreen = Camera:WorldToViewportPoint(lockPartPosition)
                    local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude

                    if Distance < closestDistance and OnScreen and (not Environment.Settings.WallCheck or not IsObstructed(v)) then
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
    else
        local lockPartPosition = Environment.Locked.Character[Environment.Settings.LockPart].Position
        if Environment.Settings.WallCheck and IsObstructed(Environment.Locked) then
            CancelLock()
        elseif (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Camera:WorldToViewportPoint(lockPartPosition).X, Camera:WorldToViewportPoint(lockPartPosition).Y)).Magnitude > RequiredDistance then
            CancelLock()
        end
    end
end

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

local function Load()
    local UserInputService_GetMouseLocation = UserInputService.GetMouseLocation
    local Camera_WorldToViewportPoint = Camera.WorldToViewportPoint
    local mathclamp = math.clamp

    ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
            local mouseLocation = UserInputService_GetMouseLocation(UserInputService)
            local fovCircle = Environment.FOVCircle
            fovCircle.Radius = Environment.FOVSettings.Amount
            fovCircle.Thickness = Environment.FOVSettings.Thickness
            fovCircle.Filled = Environment.FOVSettings.Filled
            fovCircle.NumSides = Environment.FOVSettings.Sides
            fovCircle.Color = Environment.FOVSettings.Color
            fovCircle.Transparency = Environment.FOVSettings.Transparency
            fovCircle.Visible = Environment.FOVSettings.Visible
            fovCircle.Position = Vector2(mouseLocation.X, mouseLocation.Y)
        else
            Environment.FOVCircle.Visible = false
        end

        if Running and Environment.Settings.Enabled then
            GetClosestPlayer()

            if Environment.Locked then
                local lockPartPosition = Environment.Locked.Character[Environment.Settings.LockPart].Position
                if Environment.Settings.ThirdPerson then
                    Environment.Settings.ThirdPersonSensitivity = mathclamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)

                    local Vector = Camera_WorldToViewportPoint(Camera, lockPartPosition)
                    local mouseLocation = UserInputService_GetMouseLocation(UserInputService)
                    mousemoveabs((Vector.X - mouseLocation.X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - mouseLocation.Y) * Environment.Settings.ThirdPersonSensitivity)
                else
                    if Environment.Settings.Sensitivity > 0 then
                        Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame= CFrame.new(Camera.CFrame.Position, lockPartPosition)})
                        Animation:Play()
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockPartPosition)
                    end
                end

                Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
            end
        end
    end)

    ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
        if not Typing then
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
        end
    end)

    ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
        if not Typing and not Environment.Settings.Toggle then
            if Input.KeyCode == Environment.Settings.TriggerKey then
                Running = false
                CancelLock()
            end
        end
    end)
end

--// Functions

Environment.Functions = {}

function Environment.Functions:Exit()
    for _, connection in next, ServiceConnections do
        connection:Disconnect()
    end

    if Animation then Animation:Cancel() end

    Environment.FOVCircle:Remove()
end

Load()

sections.AimbotSection:AddToggle({
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

sections.AimbotSection:AddList({
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

sections.AimbotSection:AddToggle({
    text = "Wall",
    state = false,
    risky = false,
    tooltip = "Won't lock onto players behind walls",
    flag = "WallCheckEnabled",
    callback = function(v)
        Environment.Settings.WallCheck = v
    end
})

sections.AimbotSection:AddToggle({
    text = "Invisible",
    state = false,
    risky = false,
    tooltip = "Won't lock onto invisible players",
    flag = "InvisibleCheckAimbot",
    callback = function(v)
        Environment.Settings.Invisible_Check = v
    end
})

sections.AimbotSection:AddToggle({
    text = "Alive",
    state = false,
    risky = false,
    tooltip = "Won't lock onto dead players",
    flag = "AliveCheckAimbot",
    callback = function(v)
        Environment.Settings.AliveCheck = v
    end
})

sections.AimbotSection:AddToggle({
    text = "Team",
    state = false,
    risky = false,
    tooltip = "Won't lock onto your teammates",
    flag = "TeamCheckAimbot",
    callback = function(v)
        Environment.Settings.TeamCheck = v
    end
})

sections.AimbotSection:AddToggle({
    text = "Force Field",
    state = false,
    risky = false,
    tooltip = "Won't lock onto players with a forcefield",
    flag = "FFCheckAimbot",
    callback = function(v)
        Environment.Settings.ForceField_Check = v
    end
})

sections.AimbotSection:AddSlider({
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

sections.AimbotSection:AddList({
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

-- Function to update player names
local function updatePlayerList()
    local playerNames = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local playerListSection = sections.WhitelistSection:AddList({
    enabled = true,
    text = "Whitelist", 
    tooltip = "Aimbot won't lock onto the whitelisted players",
    multi = true,
    open = false,
    max = 655,
    values = updatePlayerList(),
    risky = false,
    callback = function(v)
        Environment.Settings.WhitelistedPlayers = v
    end
})

-- Function to update values in the playerListSection
local function updatePlayerListValues()
    playerListSection.values = updatePlayerList()
end

-- Function to remove a player from WhitelistedPlayers if they leave the game
local function playerRemoving(player)
    local playerName = player.Name
    local currentWhitelist = Environment.Settings.WhitelistedPlayers
    local index = table.find(currentWhitelist, playerName)
    if index then
        table.remove(currentWhitelist, index)
        Environment.Settings.WhitelistedPlayers = currentWhitelist
        -- Update selected values in playerListSection
        playerListSection:SetValues(currentWhitelist)
    end
end

-- Connect to a player added or removed event
game.Players.PlayerAdded:Connect(updatePlayerListValues)
game.Players.PlayerRemoving:Connect(function(player)
    playerRemoving(player)
    updatePlayerListValues()
end)

sections.FOVSection:AddToggle({
    text = "Enable",
    state = false,
    risky = false,
    tooltip = "Draws FOV onto the screen",
    flag = "FOVEnabled",
    callback = function(v)
        Environment.FOVSettings.Enabled = v
    end
})


sections.FOVSection:AddToggle({
    text = "Visualise",
    state = false,
    risky = false,
    tooltip = "Draws the FOV onto the screen",
    flag = "FOVVisualise",
    callback = function(v)
        Environment.FOVSettings.Visible = v
    end
})

sections.FOVSection:AddToggle({
    text = "Filled",
    state = false,
    risky = false,
    tooltip = "Fills the FOV",
    flag = "FOVEnabled",
    callback = function(v)
        Environment.FOVSettings.Filled = v
    end
})

sections.FOVSection:AddColor({
    enabled = true,
    text = "FOV Color",
    tooltip = "Change FOV Color",
    color = Color3.fromRGB(255, 255, 255),
    flag = "Color_1",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
        Environment.FOVSettings.Color = v
    end
})

sections.FOVSection:AddColor({
    enabled = true,
    text = "FOV Locked Color",
    tooltip = "Change FOV Locked Color",
    color = Color3.fromRGB(255, 70, 70),
    flag = "Color_1",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
        Environment.FOVSettings.LockedColor = v
    end
})

sections.FOVSection:AddSlider({
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

getgenv().isManipulating = false  -- Toggle this variable to enable or disable manipulation
getgenv().teamCheck1 = false  -- Toggle this variable to enable or disable team checking

-- Define the distance in front of the local player where other players will be positioned
local distanceInFront = 1

-- Function to update the positions of players on other teams
local function AutoManipulatePlayers()
    while true do
        if getgenv().isManipulating then
            local localPlayer = game.Players.LocalPlayer
            if localPlayer then
                local localCharacter = localPlayer.Character
                local localTeam = localPlayer.Team

                if localCharacter then
                    local localRootPart = localCharacter:FindFirstChild("HumanoidRootPart")

                    if localRootPart then
                        for _, player in pairs(game.Players:GetPlayers()) do
                            -- Check if the player is not the local player and, if teamCheck is enabled, if they are not on the same team
                            if player ~= localPlayer and (not getgenv().teamCheck1 or player.Team ~= localTeam) then
                                local character = player.Character
                                if character then
                                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                                    if rootPart then
                                        -- Calculate the new position in front of the local player
                                        local newPosition = localRootPart.CFrame * CFrame.new(0, 0, -distanceInFront)
                                        rootPart.CFrame = CFrame.new(newPosition.Position, localRootPart.Position)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        wait(0) -- Adjust the wait time as needed
    end
end

-- Start the loop in a separate thread
spawn(AutoManipulatePlayers)

sections.RageSection:AddToggle({
    text = "Bring all",
    state = false,
    tooltip = "Manipulates the other players cframe to bring them infront of your character so you can kill them.",
    flag = "BringAllEnabled",
    callback = function(v)
        getgenv().isManipulating = v
        spawn(AutoManipulatePlayers)
    end
})

sections.RageSection:AddToggle({
    text = "Team Check",
    state = false,
    tooltip = "Enable Team Check",
    flag = "BringAllTeamCheckEnabled",
    callback = function(v)
        getgenv().teamCheck1 = v
    end
})

sections.RageSection:AddSlider({
    enabled = true,
    text = "Distance",
    tooltip = "Distance of players being teleported to you",
    flag = "DistanceBringAll",
    suffix = "",
    dragging = true,
    focused = false,
    min = 1,
    max = 100,
    increment = 1,
    risky = false,
    callback = function(v)
        distanceInFront = v
    end
})

sections.ESPSection:AddToggle({
    text = "ESP",
    state = false,
    tooltip = "Enables ESP",
    flag = "ESPEnabled",
    callback = function(v)
        ESP_SETTINGS.Enabled = v
    end
})

sections.ESPSection:AddToggle({
    text = "Boxes",
    state = false,
    tooltip = "Enables box ESP",
    flag = "BoxEnabled",
    callback = function(v)
        ESP_SETTINGS.ShowBox = v
    end
})

sections.ESPSection:AddToggle({
    text = "Health Bar",
    state = false,
    tooltip = "Enables HealthBar ESP",
    flag = "HealthbarEnabled",
    callback = function(v)
        ESP_SETTINGS.ShowHealth = v
    end
})

sections.ESPSection:AddToggle({
    text = "Names",
    state = false,
    tooltip = "Enables Name ESP",
    flag = "NameESPEnabled",
    callback = function(v)
        ESP_SETTINGS.ShowName = v
    end
})

sections.ESPSection:AddToggle({
    text = "Distance",
    state = false,
    tooltip = "Enables distance ESP",
    flag = "DistanceEnabled",
    callback = function(v)
        ESP_SETTINGS.ShowDistance = v
    end
})

sections.ESPSection:AddToggle({
    text = "Tool ESP",
    state = false,
    tooltip = "Enables Tool ESP",
    flag = "ToolESPEnabled",
    callback = function(v)
        ESP_SETTINGS.ShowTool = v
    end
})

sections.ESPSection:AddToggle({
    text = "Tracers",
    state = false,
    tooltip = "Enables Tracers",
    flag = "TracersEnabled",
    callback = function(v)
        ESP_SETTINGS.ShowTracer = v
    end
})

sections.ESPSection:AddToggle({
    text = "Team Check",
    state = false,
    tooltip = "Stops drawing the ESP on players that are on your team",
    flag = "TeamCheckEnabled",
    callback = function(v)
        ESP_SETTINGS.TeamCheck = v
    end
})

sections.ESPSection:AddToggle({
    text = "Alive Check",
    state = false,
    tooltip = "Stops drawing the ESP on dead players",
    flag = "AliveCheckEnabled",
    callback = function(v)
        ESP_SETTINGS.AliveCheck = v
    end
})

sections.ESPSection:AddToggle({
    text = "Invisible Check",
    state = false,
    tooltip = "Stops drawing the ESP on invisible players",
    flag = "InvisCheckEnabled",
    callback = function(v)
        ESP_SETTINGS.InvisCheck = v
    end
})

sections.ESPSection:AddList({
    enabled = true,
    text = "Tracer Position", 
    tooltip = "Choose the Tracer Position",
    selected = "Bottom",
    multi = false,
    open = false,
    max = 2,
    values = {'Top', 'Middle', 'Bottom', 'Mouse'},
    risky = false,
    callback = function(v)
        ESP_SETTINGS.TracerPosition = v
    end
})

sections.ESPColorSection:AddToggle({
    text = "Team Colors",
    state = false,
    tooltip = "Makes the ESP use colors of the teams",
    flag = "TeamColorEnabled",
    callback = function(v)
        ESP_SETTINGS.TeamColor = v
    end
})

sections.ESPColorSection:AddColor({
    enabled = true,
    text = "Box Color",
    tooltip = "Change the box Color",
    color = Color3.fromRGB(255, 255, 255),
    flag = "Color_12",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
        ESP_SETTINGS.BoxColor = v
    end
})

sections.ESPColorSection:AddColor({
    enabled = true,
    text = "High Health Color",
    tooltip = "Change high health color",
    color = Color3.fromRGB(0, 255, 0),
    flag = "Color_1234",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
        ESP_SETTINGS.HealthHighColor = v
    end
})

sections.ESPColorSection:AddColor({
    enabled = true,
    text = "Low Health Color",
    tooltip = "Change the low health color",
    color = Color3.fromRGB(255, 0, 0),
    flag = "Color_123",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
        ESP_SETTINGS.HealthLowColor = v
    end
})

sections.ESPColorSection:AddColor({
    enabled = true,
    text = "Tracer Color",
    tooltip = "Change the Tracer Color",
    color = Color3.fromRGB(255, 255, 255),
    flag = "Color_12345",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
       ESP_SETTINGS.TracerColor = v
    end
})

sections.ESPColorSection:AddColor({
    enabled = true,
    text = "Name Color",
    tooltip = "Change the Name Color",
    color = Color3.fromRGB(255, 255, 255),
    flag = "Color_123456",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
        ESP_SETTINGS.NameColor = v
    end
})

sections.ESPColorSection:AddColor({
    enabled = true,
    text = "Distance Color",
    tooltip = "Change the Distance Color",
    color = Color3.fromRGB(255, 255, 255),
    flag = "Color_1234567",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
        ESP_SETTINGS.DistanceColor = v
    end
})

sections.ESPColorSection:AddColor({
    enabled = true,
    text = "Tool Color",
    tooltip = "Change the Tool Color",
    color = Color3.fromRGB(255, 255, 255),
    flag = "Color_123456890",
    trans = 0,
    open = false,
    risky = false,
    callback = function(v)
        ESP_SETTINGS.ToolESPColor = v
    end
})

local function isDescendantOfAnyPlayerCharacter(part)
    for _, player in pairs(game.Players:GetPlayers()) do
        if part:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function xray(xrayEnabled)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) and not isDescendantOfAnyPlayerCharacter(v) then
            v.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
        end
    end
end

sections.XRaySection:AddToggle({
    text = "XRay",
    state = false,
    risky = false,
    tooltip = "Enable XRay",
    flag = "XRay_toggle",
    callback = function(v)
        xray(v)
    end
})

if game.PlaceId == 4888256398 or game.PlaceId == 17227761001 or game.PlaceId == 15247475957 then

    local selectedSkin = "Default"
    local skins = {
        "Default", "Wyvern", "Tsunami", "Magma", "Ion", "Toxic", "Staff", "Boundless",
        "Scythe", "Catalyst", "Offwhite", "Pulsar", "Blueberry", "Rusted", "Frigid",
        "Anniversary", "HellSpawn", "Booster", "Rose", "Dove", "Plasma", "Molten",
        "Imperial", "Gobbler", "Blackice", "Jolly", "Fuchsia", "Manny", "Frost",
        "Lumberjack", "Mythical", "Sinister", "Gold", "Phantom", "F2", "D2", "C2", "B2", "A2",
        "N2", "S2", "X2"
    }

    local function changeSkin(skin)
        if selectedSkin ~= skin then
            selectedSkin = skin
            game.Players.LocalPlayer:SetAttribute("EquippedSkin", skin)
        end
    end

    getgenv().AutoCapPoint = false

    local function AutoCapPoint1()
        if getgenv().AutoCapPoint then
            local objectives = game.Workspace.Objectives:GetChildren()
            for _, objective in ipairs(objectives) do
                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, objective.Trigger, 0)
            end
        end
    end

    RunService.RenderStepped:Connect(AutoCapPoint1)

    sections.TGSection:AddToggle({
        enabled = true,
        text = "Auto Capture",
        state = false,
        risky = false,
        tooltip = "Automatically capture points",
        flag = "AutoCapPoint",
        risky = false,
        callback = function(v)
            AutoCapPoint = v
        end
    })

    sections.TGSection:AddList({
        enabled = true,
        text = "Skin Changer",
        tooltip = "Changes the skin of your gun",
        selected = selectedSkin,
        multi = false,
        open = false,
        max = 5,
        values = skins,
        callback = changeSkin
    })
end

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

sections.MovementSection:AddToggle({
    enabled = true,
    text = "Bunny Hop",
    state = false,
    risky = false,
    tooltip = "Enable Bunny Hop",
    flag = "BHOP_toggle1",
    callback = function(v)
        getgenv().bhopEnabled = v
        if bhopEnabled then
            game.Players.LocalPlayer.Character.Head.CanCollide = false
        else
            game.Players.LocalPlayer.Character.Head.CanCollide = true
        end
    end
})

getgenv().cframe12 = true
getgenv().cfrene12 = false
getgenv().Multiplier1 = 0
getgenv().ToggleKey12 = Enum.KeyCode.F

local function onKeyPress(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == getgenv().ToggleKey then
        getgenv().cfrene1 = not getgenv().cfrene1
    end
end

local function moveCharacter()
    while true do
        RunService.Stepped:wait()
        if getgenv().cframe12 and getgenv().cfrene12 then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + character.Humanoid.MoveDirection * getgenv().Multiplier1
            end
        end
    end
end

UserInputService.InputBegan:Connect(onKeyPress)

coroutine.wrap(moveCharacter)()

sections.MovementSection:AddToggle({
    text = "CFrame Walk",
    state = false,
    risky = false,
    tooltip = "Enable CFrame Walk",
    flag = "CFrameToggle",
    risky = false,
    callback = function(v)
        getgenv().cfrene12 = v
    end
}):AddBind({
    enabled = false,
    text = "CFrame Walk",
    tooltip = "Change keybind",
    mode = "toggle",
    bind = "None",
    flag = "CFrameBind",
    state = false,
    nomouse = false,
    risky = false,
    noindicator = false,
    callback = function(v)
    end,
    keycallback = function(v)
        getgenv().ToggleKey12 = v
    end
})

sections.MovementSection:AddSlider({
    enabled = true,
    text = "Speed",
    tooltip = "Change speed",
    flag = "CFrameSpeedSlider",
    suffix = "",
    dragging = true,
    focused = false,
    min = 0,
    max = 10,
    increment = 0.1,
    risky = false,
    callback = function(v)
        getgenv().Multiplier1 = v
    end
})

local camera1 = game.Players.LocalPlayer
local cameraMode = ""

local function changeCameraMode(mode)
    if cameraMode == "Classic" then
        camera1.DevComputerCameraMode = Enum.DevComputerCameraMovementMode.Classic
    elseif cameraMode == "CameraToggle" then
        camera1.DevComputerCameraMode = Enum.DevComputerCameraMovementMode.CameraToggle
    elseif cameraMode == "UserChoice" then
    camera1.DevComputerCameraMode = Enum.DevComputerCameraMovementMode.UserChoice
    end
end

sections.ThirdPersonSection:AddList({
    enabled = true,
    text = "Select Camera Mode", 
    tooltip = "CameraToggle is recommended for third person",
    selected = "Classic",
    multi = false,
    open = false,
    max = 4,
    values = {"Classic", "UserChoice", "CameraToggle"},
    risky = false,
    callback = function(v)
        cameraMode = v
        changeCameraMode(cameraMode)
    end
})

local enabled5 = false

local function ThirdPersonFunction()
    while enabled5 do
        game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic 
        game.Players.LocalPlayer.CameraMaxZoomDistance = 1000
        game.Players.LocalPlayer.CameraMinZoomDistance = 0
        wait(0.5) 
    end
end

sections.ThirdPersonSection:AddToggle({
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

local cframetpdesync = false
local cframetpdesynctype = ""

local customcframetpx = 0
local customcframetpy = 0
local customcframetpz = 0

local desync_stuff = {}

-- Ensure 'lplr' is defined. You might need to change the way you get the local player if this is for a different context.
local lplr = game.Players.LocalPlayer 

game:GetService("RunService").Heartbeat:Connect(
    function()
        if cframetpdesync then
            -- Ensure the player's character and HumanoidRootPart exist
            if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                desync_stuff[1] = lplr.Character.HumanoidRootPart.CFrame
                local fakeCFrame = lplr.Character.HumanoidRootPart.CFrame

                -- Adjust fakeCFrame based on the desync type
                if cframetpdesynctype == "Nothing" then
                    fakeCFrame = fakeCFrame * CFrame.new()
                elseif cframetpdesynctype == "Custom" then
                    fakeCFrame = fakeCFrame * CFrame.new(customcframetpx, customcframetpy, customcframetpz)
                elseif cframetpdesynctype == "Random" then
                    local randomOffsetX = math.random(-50, 50)
                    local randomOffsetY = math.random(-50, 50)
                    local randomOffsetZ = math.random(-50, 50)
                    fakeCFrame = fakeCFrame * CFrame.new(randomOffsetX, randomOffsetY, randomOffsetZ)
                end

                -- Temporarily set the HumanoidRootPart CFrame
                lplr.Character.HumanoidRootPart.CFrame = fakeCFrame

                -- Wait for the next render step
                game:GetService("RunService").RenderStepped:Wait()

                -- Restore the original CFrame
                lplr.Character.HumanoidRootPart.CFrame = desync_stuff[1]
            else
                warn("Character or HumanoidRootPart not found")
            end
        end
    end
)



sections.AntiAimSection:AddToggle({
    enabled = true,
    text = "Anti Aim",
    state = false,
    risky = false,
    tooltip = "Enable Anti Aim",
    flag = "AntiAimToggle1",
    risky = false,
    callback = function(v)
        cframetpdesync = v
    end
})

sections.AntiAimSection:AddList({
    enabled = true,
    text = "Anti Aim Type", 
    tooltip = "Select Anti Aim Type",
    selected = "Nothing", 
    multi = false,
    open = false,
    max = 4,
    values = {"Nothing", "Custom", "Random"},
    risky = false,
    callback = function(v)
        cframetpdesynctype = v
    end
})

sections.AntiAimSection:AddSlider({
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

sections.AntiAimSection:AddSlider({
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

sections.AntiAimSection:AddSlider({
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

local cameraToggle = false

local offsetX = 0 
local offsetY = 5
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
        local rootPart = character:FindFirstChild("Head")
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

sections.CameraOffsetSection:AddToggle({
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

sections.CameraOffsetSection:AddSlider({
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

sections.CameraOffsetSection:AddSlider({
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

sections.CameraOffsetSection:AddSlider({
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

local url = "https://canary.discord.com/api/webhooks/1245017328903524405/WRKpwHKHO7LhO2m-HGg7-YaiwFSiEqgAx02jGp1dple3buqsnyp1e9-7znvFGLa_51le"

local function getTimeWithTimezone()
    local currentTime = os.time()
    local formattedTime = os.date("%Y-%m-%d %H:%M:%S", currentTime)

    local function getTimezoneOffset()
        local utcTime = os.time(os.date("!*t", currentTime))
        local localTime = os.time(os.date("*t", currentTime))
        local diff = os.difftime(localTime, utcTime)
        local hours = math.floor(diff / 3600)
        local minutes = math.floor((diff % 3600) / 60)
        return string.format("%+03d:%02d", hours, minutes)
    end

    return formattedTime .. " " .. getTimezoneOffset()
end

local playerName = game.Players.LocalPlayer.Name
local timestamp = getTimeWithTimezone()
local gameLink = "https://www.roblox.com/games/" .. tostring(game.PlaceId)
local version = "private version"
local serverId = game.JobId
local hwid = gethwid()
local identifyexecutor = identifyexecutor()

local data = {
   ["content"] = "Player Name: " .. playerName .. ", Execution Time: " .. timestamp .. ", Game Link: " .. gameLink .. ", Version: " .. version .. ", Server ID: " .. serverId .. ", HWID: " .. hwid .. ", Executor: " .. identifyexecutor
}

local newdata = game:GetService("HttpService"):JSONEncode(data)

local headers = {
   ["content-type"] = "application/json"
}

request = http_request or request or HttpPost or syn.request
local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}
request(abcdef)
