local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer


-- ==============================================
-- Scripture機能統合: サービス・変数初期化
-- ==============================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")

local localPlayer = LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
localPlayer.CharacterAdded:Connect(function(character) playerCharacter = character end)

local toysFolder = workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
if not toysFolder then
    pcall(function() toysFolder = workspace:WaitForChild(localPlayer.Name .. "SpawnedInToys", 5) end)
end
local AutoRecoverDroppedPartsCoroutine
local connectionBombReload
local reloadBombCoroutine
local antiExplosionConnection
local poisonAuraCoroutine
local deathAuraCoroutine
local reloadBombCoroutine
local poisonCoroutines = {}
local strengthConnection
local coroutineRunning = false
local autoStruggleCoroutine
local autoDefendCoroutine
local auraCoroutine
local gravityCoroutine
local kickCoroutine
local kickGrabCoroutine
local hellSendGrabCoroutine
local anchoredParts = {}
local anchoredConnections = {}
local compiledGroups = {}
local compileConnections = {}
local compileCoroutine
local fireAllCoroutine
local connections = {}
local renderSteppedConnections = {}
local ragdollAllCoroutine
local crouchJumpCoroutine
local crouchSpeedCoroutine
local anchorGrabCoroutine
local poisonGrabCoroutine
local ufoGrabCoroutine
local burnPart
local fireGrabCoroutine
local noclipGrabCoroutine
local antiKickCoroutine
local kickGrabConnections = {}
local blobmanCoroutine
local lighBitSpeedCoroutine
local lightbitpos = {}
local lightbitparts = {}
local lightbitcon
local lightbitcon2
local lightorbitcon
local bodyPositions = {}
local alignOrientations = {}



local decoyOffset = 15
local stopDistance = 5
local circleRadius = 10
local circleSpeed = 2
local auraToggle = 1
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local kickMode = 1
local auraRadius = 20
local lightbit = 0.3125
local lightbitoffset = 1
local lightbitradius = 20
local usingradius = lightbitradius


-- Utilitiesインライン（U依存除去）
local function isDescendantOf(target, other)
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then return true end
        currentParent = currentParent.Parent
    end
    return false
end

local U = {}
function U.FindFirstAncestorOfType(child, className)
    local current = child.Parent
    while current do
        if current:IsA(className) then return current end
        current = current.Parent
    end
    return nil
end
function U.GetDescendant(parent, name, className)
    if not parent then return nil end
    for _, v in ipairs(parent:GetDescendants()) do
        if v.Name == name and (not className or v:IsA(className)) then return v end
    end
    return nil
end

-- owned toysの取得
local ownedToys = {}
local bombList = {}
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.005
pcall(function()
    for _, v in pairs(localPlayer:WaitForChild("PlayerGui",2):WaitForChild("MenuGui",2):WaitForChild("Menu",2):WaitForChild("TabContents",2):WaitForChild("Toys",2):WaitForChild("Contents",2):GetChildren()) do
        if v.Name ~= "UIGridLayout" then ownedToys[v.Name] = true end
    end
end)

local poisonHurtParts = {}
local paintPlayerParts = {}
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "PoisonHurtPart" then table.insert(poisonHurtParts, v) end
        if v:IsA("BasePart") and v.Name == "PaintPlayerPart" then table.insert(paintPlayerParts, v) end
    end
end)

local function cleanupConnections(conns) for _, c in ipairs(conns) do if c then c:Disconnect() end end end
local function getVersion() local ok,v = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/Undebolted/FTAP/main/Version.txt") end); return ok and v or "unknown" end
--[[
    Utilities.IsDescendantOf(child, parent)

    Utilities.GetDescendant(parent, name, className)

    Utilities.GetAncestor(child, name, className)

    Utilities.FindFirstAncestorOfType(child, className)

    Utilities.GetChildrenByType(parent, className)

    Utilities.GetDescendantsByType(parent, className)

    Utilities.HasAttribute(instance, attributeName)

    Utilities.GetAttributeOrDefault(instance, attributeName, defaultValue)

    Utilities.CloneInstance(instance, newParent)
    
    Utilities.WaitForChildOfType(parent, className, timeout)

    Utilities.IsPointInPart(part, point)

    Utilities.GetDistance(pointA, pointB)

    Utilities.GetAngleBetweenVectors(vectorA, vectorB)

    Utilities.RotateVectorY(vector, angle)

    Utilities.GetSurroundingVectors(target, radius, amount, offset)


--]]
local followMode = true
local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local playerList = {}
local selection 
local blobman 
local platforms = {}
local ownedToys = {}
local bombList = {}
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.005



local function isDescendantOf(target, other)
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then
            return true
        end
        currentParent = currentParent.Parent
    end
    return false
end
local function DestroyT(toy)
    local toy = toy or toysFolder:FindFirstChildWhichIsA("Model")
    DestroyToy:FireServer(toy)
end


local function getDescendantParts(descendantName)
    local parts = {}
    for _, descendant in ipairs(workspace.Map:GetDescendants()) do
        if descendant:IsA("Part") and descendant.Name == descendantName then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")

local function updatePlayerList()
    playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerList, player.Name)
    end
end

local function onPlayerAdded(player)
    table.insert(playerList, player.Name)
end

local function onPlayerRemoving(player)
    for i, name in ipairs(playerList) do
        if name == player.Name then
            table.remove(playerList, i)
            break
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for i, v in pairs(localPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents"):GetChildren()) do
    if v.Name ~= "UIGridLayout" then
        ownedToys[v.Name] = true
    end
end

local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (playerCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end

    return nearestPlayer
end

local function cleanupConnections(connectionTable)
    for _, connection in ipairs(connectionTable) do
        connection:Disconnect()
    end
    connectionTable = {}
end

local function getVersion()
    local url = "https://raw.githubusercontent.com/Undebolted/FTAP/main/VERSION.json"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        return data.version
    else
        return "Unknown"
    end
end

local function spawnItem(itemName, position, orientation)
    task.spawn(function()
        local cframe = CFrame.new(position)
        local rotation = Vector3.new(0, 90, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function arson(part)
    if not toysFolder:FindFirstChild("Campfire") then
        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
    end
    local campfire = toysFolder:FindFirstChild("Campfire")
    burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
    burnPart.Size = Vector3.new(7, 7, 7)
    burnPart.Position = part.Position
    task.wait(0.3)
    burnPart.Position = Vector3.new(0, -50, 0)
end

local function handleCharacterAdded(player)
    local characterAddedConnection = player.CharacterAdded:Connect(function(character)
        local hrp = character:WaitForChild("HumanoidRootPart")
        local fpp = hrp:WaitForChild("FirePlayerPart")
        fpp.Size = Vector3.new(4.5, 5, 4.5)
        fpp.CollisionGroup = "1"
        fpp.CanQuery = true
    end)
    table.insert(kickGrabConnections, characterAddedConnection)
end

local function kickGrab()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if hrp:FindFirstChild("FirePlayerPart") then
                local fpp = hrp.FirePlayerPart
                fpp.Size = Vector3.new(4.5, 5.5, 4.5)
                fpp.CollisionGroup = "1"
                fpp.CanQuery = true
            end
        end
        handleCharacterAdded(player)
    end

    local playerAddedConnection = Players.PlayerAdded:Connect(handleCharacterAdded)
    table.insert(kickGrabConnections, playerAddedConnection)
end

local function grabHandler(grabType)
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local head = grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    while workspace:FindFirstChild("GrabParts") do
                        local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
                        for _, part in pairs(partsTable) do
                            part.Size = Vector3.new(2, 2, 2)
                            part.Transparency = 1
                            part.Position = head.Position
                        end
                        wait()
                        for _, part in pairs(partsTable) do
                            part.Position = Vector3.new(0, -200, 0)
                        end
                    end
                    for _, part in pairs(partsTable) do
                        part.Position = Vector3.new(0, -200, 0)
                    end
                end
            end
        end)
        wait()
    end
end

local function fireGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local head = grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    arson(head)
                end
            end
        end)
        wait()
    end
end

local function noclipGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local character = grabbedPart.Parent
                if character.HumanoidRootPart then
                    while workspace:FindFirstChild("GrabParts") do
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        wait()
                    end
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end)
        wait()
    end
end
local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        local rotation = Vector3.new(0, 0, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function fireAll()
    while true do
        local success, err = pcall(function()
            if toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                wait(0.5)
            end
            spawnItemCf("Campfire", playerCharacter.Head.CFrame)
            local campfire = toysFolder:WaitForChild("Campfire")
            local firePlayerPart
            for _, part in pairs(campfire:GetChildren()) do
                if part.Name == "FirePlayerPart" then
                    part.Size = Vector3.new(10, 10, 10)
                    firePlayerPart = part
                    break
                end
            end
            local originalPosition = playerCharacter.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            playerCharacter:MoveTo(firePlayerPart.Position)
            wait(0.3)
            playerCharacter:MoveTo(originalPosition)
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                        if player.Character and player.Character.HumanoidRootPart and player.Character ~= playerCharacter then
                            firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            wait()
                        end
                    end)
                end  
                wait()
            end
        end)
        if not success then
        end
        wait()
    end
end

local function createHighlight(parent)
    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillTransparency = 1
    highlight.Name = "Highlight"
    highlight.OutlineColor = Color3.new(0, 0, 1)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = parent
    return highlight
end

local function onPartOwnerAdded(descendant, primaryPart)
    if descendant.Name == "PartOwner" and descendant.Value ~= localPlayer.Name then
        local highlight = primaryPart:FindFirstChild("Highlight") or U.GetDescendant(U.FindFirstAncestorOfType(primaryPart, "Model"), "Highlight", "Highlight")
        if highlight then
            if descendant.Value ~= localPlayer.Name then
                highlight.OutlineColor = Color3.new(1, 0, 0)
            else
                highlight.OutlineColor = Color3.new(0, 0, 1)
            end
        end
    end
end

local function createBodyMovers(part, position, rotation)
    local bodyPosition = Instance.new("BodyPosition")
    local bodyGyro = Instance.new("BodyGyro")

    bodyPosition.P = 15000
    bodyPosition.D = 200
    bodyPosition.MaxForce = Vector3.new(5000000, 5000000, 5000000)
    bodyPosition.Position = position
    bodyPosition.Parent = part

    bodyGyro.P = 15000
    bodyGyro.D = 200
    bodyGyro.MaxTorque = Vector3.new(5000000, 5000000, 5000000)
    bodyGyro.CFrame = rotation
    bodyGyro.Parent = part
end

local function anchorGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end

            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end

            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end

            local primaryPart = weldConstraint.Part1.Name == "SoundPart" and weldConstraint.Part1 or weldConstraint.Part1.Parent.SoundPart or weldConstraint.Part1.Parent.PrimaryPart or weldConstraint.Part1
            if not primaryPart then return end
            if primaryPart.Anchored then return end

            if isDescendantOf(primaryPart, workspace.Map) then return end
            for _, player in pairs(Players:GetChildren()) do
                if isDescendantOf(primaryPart, player.Character) then return end
            end
            local t = true
            for _, v in pairs(primaryPart:GetDescendants()) do
                if table.find(anchoredParts, v) then
                    t = false
                end

            end
            if t and not table.find(anchoredParts, primaryPart) then
                local target 
                if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then
                    target = U.FindFirstAncestorOfType(primaryPart, "Model")
                else
                    target = primaryPart
                end

                local highlight = createHighlight(target)
                table.insert(anchoredParts, primaryPart)
                
                local connection = target.DescendantAdded:Connect(function(descendant)
                    onPartOwnerAdded(descendant, primaryPart)
                end)
                table.insert(anchoredConnections, connection)
            end

            
            if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then 
                for _, child in ipairs(U.FindFirstAncestorOfType(primaryPart, "Model"):GetDescendants()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            else
                for _, child in ipairs(primaryPart:GetChildren()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            end

            while workspace:FindFirstChild("GrabParts") do
                wait()
            end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        wait()
    end
end
local function anchorKickGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end

            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end

            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end

            local primaryPart = weldConstraint.Part1
            if not primaryPart then return end

            if isDescendantOf(primaryPart, workspace.Map) then return end
            if primaryPart.Name ~= "FirePlayerPart" then return end

            for _, child in ipairs(primaryPart:GetChildren()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end

            while workspace:FindFirstChild("GrabParts") do
                wait()
            end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        wait()
    end
end

local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part then
            if part:FindFirstChild("BodyPosition") then
                part.BodyPosition:Destroy()
            end
            if part:FindFirstChild("BodyGyro") then
                part.BodyGyro:Destroy()
            end
            local highlight = part:FindFirstChild("Highlight") or part.Parent and part.Parent:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end

    cleanupConnections(anchoredConnections)
    anchoredParts = {}
end

local function updateBodyMovers(primaryPart)
    for _, group in ipairs(compiledGroups) do
        if group.primaryPart and group.primaryPart == primaryPart then
            for _, data in ipairs(group.group) do
                local bodyPosition = data.part:FindFirstChild("BodyPosition")
                local bodyGyro = data.part:FindFirstChild("BodyGyro")
                if bodyPosition then
                    bodyPosition.Position = (primaryPart.CFrame * data.offset).Position
                end
                if bodyGyro then
                    bodyGyro.CFrame = primaryPart.CFrame * data.offset
                end
            end
        end
    end
end

local function compileGroup()
    if #anchoredParts == 0 then 
        OrionLib:MakeNotification({Name = "エラー", Content = "固定パーツが見つかりません", Image = "rbxassetid://4483345998", Time = 5})
    else
        OrionLib:MakeNotification({Name = "成功", Content = "Compiled "..#anchoredParts.."個のおもちゃを結合しました", Image = "rbxassetid://4483345998", Time = 5})
    end

    local primaryPart = anchoredParts[1]
    if not primaryPart then return end

    local highlight =  primaryPart:FindFirstChild("Highlight") or primaryPart.Parent:FindFirstChild("Highlight")
    if not highlight then
        highlight = createHighlight(primaryPart.Parent:IsA("Model") and primaryPart.Parent or primaryPart)
    end
    highlight.OutlineColor = Color3.new(0, 1, 0) 
    

    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part ~= primaryPart then
            local offset = primaryPart.CFrame:toObjectSpace(part.CFrame)
            table.insert(group, {part = part, offset = offset})
        end
    end
    table.insert(compiledGroups, {primaryPart = primaryPart, group = group})
    
    local connection = primaryPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(compileConnections, connection)

    local renderSteppedConnection = RunService.Heartbeat:Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(renderSteppedConnections, renderSteppedConnection)
end

local function cleanupCompiledGroups()
    for _, groupData in ipairs(compiledGroups) do
        for _, data in ipairs(groupData.group) do
            if data.part then
                if data.part:FindFirstChild("BodyPosition") then
                    data.part.BodyPosition:Destroy()
                end
                if data.part:FindFirstChild("BodyGyro") then
                    data.part.BodyGyro:Destroy()
                end
            end
        end
        if groupData.primaryPart and groupData.primaryPart.Parent then
            local highlight = groupData.primaryPart:FindFirstChild("Highlight") or groupData.primaryPart.Parent:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
    
    cleanupConnections(compileConnections)
    cleanupConnections(renderSteppedConnections)
    compiledGroups = {}
end

local function compileCoroutineFunc()
    while true do
        pcall(function()
            for _, groupData in ipairs(compiledGroups) do
                updateBodyMovers(groupData.primaryPart)
            end
        end)
        wait()
    end
end

local function unanchorPrimaryPart()
    local primaryPart = anchoredParts[1]
    if not primaryPart then return end
    if primaryPart:FindFirstChild("BodyPosition") then
        primaryPart.BodyPosition:Destroy()
    end
    if primaryPart:FindFirstChild("BodyGyro") then
        primaryPart.BodyGyro:Destroy()
    end
    local highlight = primaryPart.Parent:FindFirstChild("Highlight") or primaryPart:FindFirstChild("Highlight")
    if highlight then
        highlight:Destroy()
    end
end
local function recoverParts()
    while true do
        local success, err = pcall(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local head = character.Head
                local humanoidRootPart = character.HumanoidRootPart

                for _, partModel in pairs(anchoredParts) do
                    coroutine.wrap(function()
                        if partModel then
                            local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                            if distance <= 30 then
                                local highlight = partModel:FindFirstChild("Highlight") or partModel.Parent:FindFirstChild("Highlight")
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    if partModel:WaitForChild("PartOwner") and partModel.PartOwner.Value == localPlayer.Name then
                                        highlight.OutlineColor = Color3.new(0, 0, 1)
                                    end
                                end
                            end
                        end
                    end)()
                end
            end
        end)
        wait(0.02)
    end
end
local function ragdollAll()
    while true do
        local success, err = pcall(function()
            if not toysFolder:FindFirstChild("FoodBanana") then
                spawnItem("FoodBanana", Vector3.new(-72.9304581, -5.96906614, -265.543732))
            end
            local banana = toysFolder:WaitForChild("FoodBanana")
            local bananaPeel
            for _, part in pairs(banana:GetChildren()) do
                if part.Name == "BananaPeel" and part:FindFirstChild("TouchInterest") then
                    part.Size = Vector3.new(10, 10, 10)
                    part.Transparency = 1
                    bananaPeel = part
                    break
                end
            end
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Parent = banana.Main
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if player.Character and player.Character ~= playerCharacter then
                            bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                            wait()
                        end
                    end)
                end   
                wait()
            end
        end)
        if not success then
        end
        wait()
    end
end
local function reloadMissile(bool)
    if bool then
        if not ownedToys[_G.ToyToLoad] then
            OrionLib:MakeNotification({
                Name = "おもちゃ未所有",
                Content = "You do not own the ".._G.ToyToLoad.." toy.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end

        if not reloadBombCoroutine then
            reloadBombCoroutine = coroutine.create(function()
                connectionBombReload = toysFolder.ChildAdded:Connect(function(child)
                    if child.Name == _G.ToyToLoad and child:WaitForChild("ThisToysNumber", 1) then
                        if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                            local connection2
                            connection2 = toysFolder.ChildRemoved:Connect(function(child2)
                                if child2 == child then
                                    connection2:Disconnect()
                                end
                            end)

                            SetNetworkOwner:FireServer(child.Body, child.Body.CFrame)
                            local waiting = child.Body:WaitForChild("PartOwner", 0.5)
                            local connection = child.DescendantAdded:Connect(function(descendant)
                                if descendant.Name == "PartOwner" then
                                    if descendant.Value ~= localPlayer.Name then
                                        DestroyT(child)
                                        connection:Disconnect()
                                    end
                                end
                            end)
                            Debris:AddItem(connectio, 60)
                            if waiting and waiting.Value == localPlayer.Name then
                                for _, v in pairs(child:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                    end
                                end
                                child:SetPrimaryPartCFrame(CFrame.new(-72.9304581, -3.96906614, -265.543732))
                                wait(0.2)
                                for _, v in pairs(child:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.Anchored = true
                                    end
                                end
                                table.insert(bombList, child)
                                child.AncestryChanged:Connect(function()
                                    if not child.Parent then
                                        for i, bomb in ipairs(bombList) do
                                            if bomb == child then
                                                table.remove(bombList, i)
                                                break
                                            end
                                        end
                                    end
                                end)
                                connection2:Disconnect()
                            else
                                DestroyT(child)
                            end
                        end
                    end
                end)

                while true do
                    if localPlayer.CanSpawnToy and localPlayer.CanSpawnToy.Value and #bombList < _G.MaxMissiles and playerCharacter:FindFirstChild("Head") then
                        spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            coroutine.resume(reloadBombCoroutine)
        end
    else
        if reloadBombCoroutine then
            coroutine.close(reloadBombCoroutine)
            reloadBombCoroutine = nil
        end
        if connectionBombReload then
            connectionBombReload:Disconnect()
        end
    end
end
local function setupAntiExplosion(character)
    local partOwner = character:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
    if partOwner then
        local partOwnerChangedConn
        partOwnerChangedConn = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
            if partOwner.Value then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
            else
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
            end
        end)
        antiExplosionConnection = partOwnerChangedConn
    end
end


local blobalter = 1
local function blobGrabPlayer(player, blobman)
    if blobalter == 1 then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local args = {
                [1] = blobman:FindFirstChild("LeftDetector"),
                [2] = player.Character:FindFirstChild("HumanoidRootPart"),
                [3] = blobman:FindFirstChild("LeftDetector"):FindFirstChild("LeftWeld")
            }
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 2
        end
    else
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local args = {
                [1] = blobman:FindFirstChild("RightDetector"),
                [2] = player.Character:FindFirstChild("HumanoidRootPart"),
                [3] = blobman:FindFirstChild("RightDetector"):FindFirstChild("RightWeld")
            }
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 1
        end
    end
end




-- Orion UIライブラリの読み込み - 茶色の背景色を適用
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Orion UIの色設定をカスタマイズ
local Theme = {
    BackgroundColor = Color3.fromRGB(139, 69, 19),  -- 茶色 (Brown)
    SliderColor = Color3.fromRGB(255, 105, 180),     -- ホットピンク (Hot Pink)
    TextColor = Color3.fromRGB(255, 255, 255),       -- 白 (White)
    SectionColor = Color3.fromRGB(210, 180, 140),    -- 薄茶色 (Light Brown)
}

-- ====================================================================
-- 横一列の配置設定（羽） - 独立した設定
-- ====================================================================
local FeatherConfig = {
    Enabled = false,  -- 羽の機能はデフォルトでオフ
    spacing = 3,
    heightOffset = 2,
    backwardOffset = 3,  -- 前方オフセットから背中オフセットに変更
    maxSparklers = 20,
    tiltAngle = 45,
    waveSpeed = 2,
    baseAmplitude = 1,
}

-- 羽の専用変数
local FeatherToys = {}
local FeatherRowPoints = {}
local FeatherAssignedToys = {}
local FeatherLoopConn = nil
local FeatherTime = 0

-- ====================================================================
-- 魔法陣［RingX2］機能 - 独立した設定
-- ====================================================================
local RingConfig = {
    Enabled = false,
    RingHeight = 5.0,
    RingDiameter = 5.0,
    ObjectCount = 10,
    RotationSpeed = 20.0
}

local RingList = {}
local RingLoopConn = nil
local RingTAccum = 0

-- ====================================================================
-- ハート形配置機能
-- ====================================================================
local HeartConfig = {
    Enabled = false,
    Height = 5.0,           -- 高さ
    Size = 5.0,             -- ハートのサイズ
    ObjectCount = 12,       -- 花火の数
    RotationSpeed = 1.0,    -- 回転速度
    PulseSpeed = 2.0,       -- 脈動速度
    PulseAmplitude = 0.5,   -- 脈動振幅
    FollowPlayer = true,    -- プレイヤーを追従
}

local HeartToys = {}
local HeartPoints = {}
local HeartAssignedToys = {}
local HeartLoopConn = nil
local HeartTime = 0

-- ====================================================================
-- おっきぃ♡配置機能（大きいハート）- 速度設定を拡張
-- ====================================================================
local BigHeartConfig = {
    Enabled = false,
    Height = 8.0,           -- 高さ（デフォルトより高い）
    Size = 10.0,            -- ハートのサイズ（大きい）
    ObjectCount = 20,       -- 花火の数（多い）
    RotationSpeed = 0.5,    -- 回転速度（ゆっくり）
    RotationSpeedMax = 10.0, -- 最大回転速度（追加）
    PulseSpeed = 1.0,       -- 脈動速度（ゆっくり）
    PulseSpeedMax = 10.0,   -- 最大脈動速度（追加）
    PulseAmplitude = 1.0,   -- 脈動振幅（大きい）
    FollowPlayer = true,    -- プレイヤーを追従
    HeartScale = 2.0,       -- スケール係数
    VerticalStretch = 1.2,  -- 垂直方向の伸び
}

local BigHeartToys = {}
local BigHeartPoints = {}
local BigHeartAssignedToys = {}
local BigHeartLoopConn = nil
local BigHeartTime = 0

-- ====================================================================
-- ダビデ星配置機能
-- ====================================================================
local StarOfDavidConfig = {
    Enabled = false,
    Height = 5.0,           -- 高さ
    Size = 5.0,             -- サイズ
    ObjectCount = 12,       -- 花火の数（6の倍数推奨）
    RotationSpeed = 1.0,    -- 回転速度
    PulseSpeed = 1.5,       -- 脈動速度
    FollowPlayer = true,    -- プレイヤーを追従
    TriangleHeight = 0.5,   -- 三角形の高さ
}

local StarOfDavidToys = {}
local StarOfDavidPoints = {}
local StarOfDavidAssignedToys = {}
local StarOfDavidLoopConn = nil
local StarOfDavidTime = 0

-- ====================================================================
-- スター配置機能（⭐️の形）
-- ====================================================================
local StarConfig = {
    Enabled = false,
    Height = 5.0,           -- 高さ
    Size = 5.0,             -- サイズ
    ObjectCount = 10,       -- 花火の数
    RotationSpeed = 1.0,    -- 回転速度
    TwinkleSpeed = 2.0,     -- きらめき速度
    FollowPlayer = true,    -- プレイヤーを追従
    StarPoints = 5,         -- 星の頂点数（5角星）
    OuterRadius = 5.0,      -- 外側の半径
    InnerRadius = 2.0,      -- 内側の半径
}

local StarToys = {}
local StarPoints = {}
local StarAssignedToys = {}
local StarLoopConn = nil
local StarTime = 0

-- ====================================================================
-- スーパーリング（竜巻）配置機能
-- ====================================================================
local SuperRingConfig = {
    Enabled = false,
    BaseHeight = 2.0,       -- 基本高さ
    Height = 10.0,          -- 全体の高さ
    Radius = 3.0,           -- 半径
    ObjectCount = 16,       -- 花火の数
    RotationSpeed = 2.0,    -- 回転速度
    SpiralSpeed = 1.0,      -- らせん速度
    WaveSpeed = 1.5,        -- 波の速度
    WaveAmplitude = 0.5,    -- 波の振幅
    FollowPlayer = true,    -- プレイヤーを追従
    TornadoEffect = true,   -- 竜巻効果
}

local SuperRingToys = {}
local SuperRingPoints = {}
local SuperRingAssignedToys = {}
local SuperRingLoopConn = nil
local SuperRingTime = 0

-- ====================================================================
-- 卍マンジ配置機能（追加）
-- ====================================================================
local ManjiConfig = {
    Enabled = false,
    Height = 6.0,           -- 高さ
    Size = 8.0,             -- サイズ
    ObjectCount = 16,       -- 花火の数
    RotationSpeed = 1.0,    -- 回転速度
    RotationSpeedMax = 15.0, -- 最大回転速度
    PulseSpeed = 2.0,       -- 脈動速度
    PulseSpeedMax = 15.0,   -- 最大脈動速度
    PulseAmplitude = 0.8,   -- 脈動振幅
    FollowPlayer = true,    -- プレイヤーを追従
    ArmLength = 1.5,        -- 卍の腕の長さ
    ArmThickness = 0.3,     -- 腕の太さ
}

local ManjiToys = {}
local ManjiPoints = {}
local ManjiAssignedToys = {}
local ManjiLoopConn = nil
local ManjiTime = 0

-- ====================================================================
-- スター2✫配置機能（追加 - 太陽のようなギザギザ模様）
-- ====================================================================
local Star2Config = {
    Enabled = false,
    Height = 10.0,          -- 高さ
    Size = 15.0,            -- 基本サイズ
    ObjectCount = 24,       -- 花火の数（多い）
    RotationSpeed = 5.0,    -- 回転速度（高速）
    RotationSpeedMax = 30.0, -- 最大回転速度
    PulseSpeed = 8.0,       -- 脈動速度（高速）
    PulseSpeedMax = 20.0,   -- 最大脈動速度
    PulseAmplitude = 2.0,   -- 脈動振幅（大きい）
    FollowPlayer = true,    -- プレイヤーを追従
    RayCount = 12,          -- 光線の数
    RayLength = 3.0,        -- 光線の長さ
    RayLengthMax = 10.0,    -- 最大光線長
    JitterSpeed = 5.0,      -- ギザギザの揺れ速度
    JitterAmount = 1.0,     -- ギザギザの揺れ量
    SizeMax = 30.0,         -- 最大サイズ
}

local Star2Toys = {}
local Star2Points = {}
local Star2AssignedToys = {}
local Star2LoopConn = nil
local Star2Time = 0

-- ====================================================================
-- 便利機能 (Mi(=^・^=))
-- ====================================================================
local UtilityConfig = {
    InfiniteJump = false,
    Noclip = false,
}

local NoclipConnection = nil
local OriginalCollision = {}

-- ====================================================================
-- 共通ユーティリティ関数
-- ====================================================================
local function findFireworkSparklers()
    local toys = {}
    
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item.Name == "FireworkSparkler" then
            local alreadyAdded = false
            for _, existingToy in ipairs(toys) do
                if existingToy == item then
                    alreadyAdded = true
                    break
                end
            end
            if not alreadyAdded then
                table.insert(toys, item)
            end
        end
    end
    
    table.sort(toys, function(a, b)
        return a.Name < b.Name
    end)
    
    return toys
end

local function getPrimaryPart(model)
    if model.PrimaryPart then
        return model.PrimaryPart
    end
    
    local potentialParts = {"Handle", "Main", "Part", "Base", "Sparkler", "Firework"}
    for _, partName in ipairs(potentialParts) do
        local part = model:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    
    return nil
end

-- ====================================================================
-- Noclip修正関数
-- ====================================================================
local function enableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    -- 元の衝突判定を保存
    OriginalCollision = {}
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                OriginalCollision[part] = part.CanCollide
            end
        end
    end
    
    -- Noclipを有効化
    NoclipConnection = RunService.Stepped:Connect(function()
        if UtilityConfig.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    -- 元の衝突判定を復元
    if LocalPlayer.Character then
        for part, canCollide in pairs(OriginalCollision) do
            if part and part.Parent then
                part.CanCollide = canCollide
            end
        end
        OriginalCollision = {}
    end
end

-- ====================================================================
-- 羽（Feather）機能専用関数
-- ====================================================================
local function createFeatherRowPoints(count)
    local points = {}
    
    if count == 0 then return points end
    
    local totalWidth = (count - 1) * FeatherConfig.spacing
    local startX = -totalWidth / 2
    
    for i = 1, count do
        local x = startX + (i - 1) * FeatherConfig.spacing
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        
        points[i] = {
            offsetX = x,
            part = part,
            assignedToy = nil,
        }
    end
    
    return points
end

local function attachFeatherPhysics(part)
    if not part then return nil, nil end
    
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    
    if existingBG and existingBP then 
        return existingBG, existingBP
    end
    
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    
    local BP = Instance.new("BodyPosition")  
    local BG = Instance.new("BodyGyro")  
    
    BP.P = 15000  
    BP.D = 200  
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10  
    BP.Parent = part  
    
    BG.P = 15000  
    BG.D = 200  
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10  
    BG.Parent = part  
    
    return BG, BP
end

local function assignFeatherToysToPoints()
    FeatherAssignedToys = {}
    local distanceGroups = {}
    
    for i, point in ipairs(FeatherRowPoints) do
        local absDistance = math.abs(point.offsetX)
        
        if not distanceGroups[absDistance] then
            distanceGroups[absDistance] = {}
        end
        table.insert(distanceGroups[absDistance], i)
    end
    
    local sortedDistances = {}
    for distance, _ in pairs(distanceGroups) do
        table.insert(sortedDistances, distance)
    end
    table.sort(sortedDistances)
    
    for rank, distance in ipairs(sortedDistances) do
        for _, pointIndex in ipairs(distanceGroups[distance]) do
            FeatherRowPoints[pointIndex].distanceRank = rank
        end
    end
    
    for i = 1, math.min(#FeatherToys, #FeatherRowPoints) do
        local toy = FeatherToys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachFeatherPhysics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    RowIndex = i,
                    offsetX = FeatherRowPoints[i].offsetX,
                    distanceRank = FeatherRowPoints[i].distanceRank
                }  
                
                FeatherRowPoints[i].assignedToy = toyTable
                table.insert(FeatherAssignedToys, toyTable)
            end  
        end
    end
    
    return FeatherAssignedToys
end

local function startFeatherLoop()
    if FeatherLoopConn then
        FeatherLoopConn:Disconnect()
        FeatherLoopConn = nil
    end
    
    FeatherTime = 0
    
    FeatherLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not FeatherConfig.Enabled or not LocalPlayer.Character then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        FeatherTime += dt * FeatherConfig.waveSpeed
        
        local charCFrame = humanoidRootPart.CFrame
        local rightVector = charCFrame.RightVector
        local lookVector = charCFrame.LookVector
        
        -- 背中側に配置するために、前方ではなく後方にオフセット
        local backVector = -lookVector
        
        local basePosition = torso.Position + 
                             Vector3.new(0, FeatherConfig.heightOffset, 0) + 
                             (backVector * FeatherConfig.backwardOffset)
        
        for i, point in ipairs(FeatherRowPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                local targetPosition = basePosition + (rightVector * toy.offsetX)
                
                local amplitude = FeatherConfig.baseAmplitude * toy.distanceRank
                local waveMovement = math.sin(FeatherTime) * amplitude
                local finalPosition = targetPosition + Vector3.new(0, waveMovement, 0)
                
                if point.part then
                    point.part.Position = finalPosition
                end
                
                toy.BP.Position = finalPosition
                
                -- プレイヤーの背中側を向くように修正
                local backYRotation = math.atan2(-lookVector.X, -lookVector.Z)
                local baseCFrame = CFrame.new(finalPosition) * CFrame.Angles(0, backYRotation, 0)
                local tiltedCFrame = baseCFrame * CFrame.Angles(math.rad(-FeatherConfig.tiltAngle), 0, 0)
                
                local currentCFrame = toy.BG.CFrame
                local interpolatedCFrame = currentCFrame:Lerp(tiltedCFrame, 0.3)
                
                toy.BG.CFrame = interpolatedCFrame
            end
        end
    end)
end

local function stopFeatherLoop()
    if FeatherLoopConn then
        FeatherLoopConn:Disconnect()
        FeatherLoopConn = nil
    end
    
    -- 物理演算をクリーンアップ
    for _, point in ipairs(FeatherRowPoints) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    FeatherRowPoints = {}
    FeatherAssignedToys = {}
end

local function toggleFeather(state)
    FeatherConfig.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if RingConfig.Enabled then
            toggleRingAura(false)
        end
        if HeartConfig.Enabled then
            toggleHeart(false)
        end
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
        end
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
        end
        if StarConfig.Enabled then
            toggleStar(false)
        end
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
        end
        if ManjiConfig.Enabled then
            toggleManji(false)
        end
        if Star2Config.Enabled then
            toggleStar2(false)
        end
        
        FeatherToys = findFireworkSparklers()
        FeatherRowPoints = createFeatherRowPoints(math.min(#FeatherToys, FeatherConfig.maxSparklers))
        FeatherAssignedToys = assignFeatherToysToPoints()
        startFeatherLoop()
        
        OrionLib:MakeNotification({
            Name = "羽[Feather]起動",
            Content = "花火数: " .. #FeatherAssignedToys .. "本 (背中側)",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopFeatherLoop()
        OrionLib:MakeNotification({
            Name = "羽[Feather]停止",
            Content = "羽の配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- 魔法陣［RingX2］機能専用関数
-- ====================================================================
local function HRP()
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return c:FindFirstChild("HumanoidRootPart")
end

local function attachRingPhysics(rec)
    local model = rec.model
    local part = rec.part
    if not model or not part or not part.Parent then return end
    
    -- ネットワークオーナー設定
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p:SetNetworkOwner(LocalPlayer) end)
            p.CanCollide = false
            p.CanTouch = false
        end
    end
    
    -- BodyVelocity追加
    if not part:FindFirstChild("RingBodyVelocity") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "RingBodyVelocity"
        bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
        bv.Velocity = Vector3.new()
        bv.P = 1e6
        bv.Parent = part
    end
    
    -- BodyGyro追加
    if not part:FindFirstChild("RingBodyGyro") then
        local bg = Instance.new("BodyGyro")
        bg.Name = "RingBodyGyro"
        bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
        bg.CFrame = part.CFrame
        bg.P = 1e6
        bg.Parent = part
    end
end

local function detachRingPhysics(rec)
    local model = rec.model
    local part = rec.part
    if not model or not part then return end
    
    local bv = part:FindFirstChild("RingBodyVelocity")
    if bv then bv:Destroy() end
    
    local bg = part:FindFirstChild("RingBodyGyro")
    if bg then bg:Destroy() end
    
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = true
            p.CanTouch = true
            pcall(function() p:SetNetworkOwner(nil) end)
        end
    end
end

local function rescanRing()
    for _, r in ipairs(RingList) do
        detachRingPhysics(r)
    end
    RingList = {}
    
    local foundCount = 0
    
    for _, d in ipairs(workspace:GetDescendants()) do
        if foundCount >= RingConfig.ObjectCount then break end
        
        if d:IsA("Model") and d.Name == "FireworkSparkler" then
            local part = getPrimaryPart(d)
            if part and not part.Anchored then
                local rec = { model = d, part = part }
                table.insert(RingList, rec)
                foundCount = foundCount + 1
            end
        end
    end
    
    for i = 1, #RingList do
        attachRingPhysics(RingList[i])
    end
end

local function startRingLoop()
    if RingLoopConn then
        RingLoopConn:Disconnect()
        RingLoopConn = nil
    end
    RingTAccum = 0
    
    RingLoopConn = RunService.Heartbeat:Connect(function(dt)
        if not RingConfig.Enabled then return end
        
        local root = HRP()
        if not root or #RingList == 0 then return end
        
        RingTAccum = RingTAccum + dt * (RingConfig.RotationSpeed / 10)
        
        local radius = RingConfig.RingDiameter / 2
        local angleIncrement = 360 / #RingList
        
        -- HRPの速度を取得 (飛行中も追従させるため)
        local rootVelocity = root.AssemblyLinearVelocity or root.Velocity or Vector3.new()
        
        for i, rec in ipairs(RingList) do
            local part = rec.part
            if not part or not part.Parent then continue end
            
            -- 回転角度計算
            local angle = math.rad(i * angleIncrement + RingTAccum * 50)
            
            -- リング上の位置計算 (HRPの向きに関係なく水平リングを維持)
            local localPos = Vector3.new(
                radius * math.cos(angle),
                RingConfig.RingHeight,
                radius * math.sin(angle)
            )
            
            -- ワールド座標での目標位置 (HRPの回転を無視して水平を維持)
            local targetPos = root.Position + localPos
            
            -- BodyVelocityで移動 (飛行中の速度も加算)
            local dir = targetPos - part.Position
            local distance = dir.Magnitude
            local bv = part:FindFirstChild("RingBodyVelocity")
            
            if bv then
                if distance > 0.1 then
                    -- HRPの速度を加算して飛行中も追従
                    local moveVelocity = dir.Unit * math.min(3000, distance * 50)
                    bv.Velocity = moveVelocity + rootVelocity
                else
                    bv.Velocity = rootVelocity
                end
            end
            
            -- BodyGyroで回転 (外側を向く)
            local bg = part:FindFirstChild("RingBodyGyro")
            if bg then
                local lookAtCFrame = CFrame.lookAt(targetPos, root.Position) * CFrame.Angles(0, math.pi, 0)
                bg.CFrame = lookAtCFrame
            end
        end
    end)
end

local function stopRingLoop()
    if RingLoopConn then
        RingLoopConn:Disconnect()
        RingLoopConn = nil
    end
    for _, rec in ipairs(RingList) do
        detachRingPhysics(rec)
    end
    RingList = {}
end

local function toggleRingAura(state)
    RingConfig.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if FeatherConfig.Enabled then
            toggleFeather(false)
        end
        if HeartConfig.Enabled then
            toggleHeart(false)
        end
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
        end
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
        end
        if StarConfig.Enabled then
            toggleStar(false)
        end
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
        end
        if ManjiConfig.Enabled then
            toggleManji(false)
        end
        if Star2Config.Enabled then
            toggleStar2(false)
        end
        
        rescanRing()
        startRingLoop()
        OrionLib:MakeNotification({
            Name = "魔法陣［RingX2］起動",
            Content = "高さ: " .. RingConfig.RingHeight .. ", 直径: " .. RingConfig.RingDiameter .. ", 数: " .. RingConfig.ObjectCount,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopRingLoop()
        OrionLib:MakeNotification({
            Name = "魔法陣［RingX2］停止",
            Content = "リングオーラを解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- ハート形配置機能専用関数
-- ====================================================================
local function createHeartPoints(count)
    local points = {}
    
    if count == 0 then return points end
    
    for i = 1, count do
        -- ハート曲線に沿った角度を計算
        local t = (i - 1) * (2 * math.pi / count)
        
        -- 参考点用パート
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        
        points[i] = {
            angle = t,
            part = part,
            assignedToy = nil,
        }
    end
    
    return points
end

local function getHeartPosition(t, size, pulse, scale, verticalStretch)
    -- ハート曲線のパラメトリック方程式
    -- x = 16 * sin^3(t)
    -- y = 13 * cos(t) - 5 * cos(2t) - 2 * cos(3t) - cos(4t)
    
    local baseScale = size / 20  -- スケーリング係数
    local currentScale = baseScale * (scale or 1)
    
    -- ハートのX座標
    local x = 16 * (math.sin(t) ^ 3) * currentScale
    
    -- ハートのY座標
    local y = (13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)) * currentScale
    
    -- 垂直方向の伸びを適用
    if verticalStretch and verticalStretch > 1 then
        y = y * verticalStretch
    end
    
    -- 脈動効果を加える
    if pulse > 0 then
        local pulseFactor = 1 + (pulse * 0.1)
        x = x * pulseFactor
        y = y * pulseFactor
    end
    
    return x, y
end

local function attachHeartPhysics(part)
    if not part then return nil, nil end
    
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    
    if existingBG and existingBP then 
        return existingBG, existingBP
    end
    
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    
    local BP = Instance.new("BodyPosition")  
    local BG = Instance.new("BodyGyro")  
    
    BP.P = 15000  
    BP.D = 200  
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10  
    BP.Parent = part  
    
    BG.P = 15000  
    BG.D = 200  
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10  
    BG.Parent = part  
    
    return BG, BP
end

local function assignHeartToysToPoints()
    HeartAssignedToys = {}
    
    for i = 1, math.min(#HeartToys, #HeartPoints) do
        local toy = HeartToys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachHeartPhysics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    PointIndex = i,
                    baseAngle = HeartPoints[i].angle,
                }  
                
                HeartPoints[i].assignedToy = toyTable
                table.insert(HeartAssignedToys, toyTable)
            end  
        end
    end
    
    return HeartAssignedToys
end

local function startHeartLoop()
    if HeartLoopConn then
        HeartLoopConn:Disconnect()
        HeartLoopConn = nil
    end
    
    HeartTime = 0
    
    HeartLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not HeartConfig.Enabled or not LocalPlayer.Character then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        HeartTime += dt
        
        local basePosition
        if HeartConfig.FollowPlayer then
            basePosition = torso.Position
        else
            -- プレイヤーの現在位置を基準にするが追従しない
            basePosition = torso.Position
        end
        
        -- 脈動効果の計算
        local pulseEffect = 0
        if HeartConfig.PulseSpeed > 0 then
            pulseEffect = math.sin(HeartTime * HeartConfig.PulseSpeed) * HeartConfig.PulseAmplitude
        end
        
        for i, point in ipairs(HeartPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                -- 回転角度を計算（時間経過で回転）
                local currentAngle = toy.baseAngle + (HeartTime * HeartConfig.RotationSpeed)
                
                -- ハート曲線上の位置を計算
                local x, y = getHeartPosition(currentAngle, HeartConfig.Size, pulseEffect, 1, 1)
                
                -- 高さ調整（少しランダムな高さで立体的に）
                local heightOffset = HeartConfig.Height + (math.sin(currentAngle * 2) * 0.5)
                
                -- 最終的な位置（上から見た時にハート形になるようXZ平面で配置）
                local localPos = Vector3.new(x, heightOffset, y)
                
                local targetPosition = basePosition + localPos
                
                if point.part then
                    point.part.Position = targetPosition
                end
                
                toy.BP.Position = targetPosition
                
                -- 上を向くように設定
                toy.BG.CFrame = CFrame.new(targetPosition) * CFrame.Angles(-math.rad(90), 0, 0)
            end
        end
    end)
end

local function stopHeartLoop()
    if HeartLoopConn then
        HeartLoopConn:Disconnect()
        HeartLoopConn = nil
    end
    
    -- 物理演算をクリーンアップ
    for _, point in ipairs(HeartPoints) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    HeartPoints = {}
    HeartAssignedToys = {}
end

local function toggleHeart(state)
    HeartConfig.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if FeatherConfig.Enabled then
            toggleFeather(false)
        end
        if RingConfig.Enabled then
            toggleRingAura(false)
        end
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
        end
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
        end
        if StarConfig.Enabled then
            toggleStar(false)
        end
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
        end
        if ManjiConfig.Enabled then
            toggleManji(false)
        end
        if Star2Config.Enabled then
            toggleStar2(false)
        end
        
        HeartToys = findFireworkSparklers()
        HeartPoints = createHeartPoints(math.min(#HeartToys, HeartConfig.ObjectCount))
        HeartAssignedToys = assignHeartToysToPoints()
        startHeartLoop()
        
        OrionLib:MakeNotification({
            Name = "♡ハート♡起動",
            Content = "サイズ: " .. HeartConfig.Size .. ", 高さ: " .. HeartConfig.Height .. ", 数: " .. HeartConfig.ObjectCount,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopHeartLoop()
        OrionLib:MakeNotification({
            Name = "♡ハート♡停止",
            Content = "ハート形配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- おっきぃ♡配置機能専用関数（大きいハート）- 速度拡張版
-- ====================================================================
local function createBigHeartPoints(count)
    local points = {}
    
    if count == 0 then return points end
    
    for i = 1, count do
        -- ハート曲線に沿った角度を計算
        local t = (i - 1) * (2 * math.pi / count)
        
        -- 参考点用パート
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        
        points[i] = {
            angle = t,
            part = part,
            assignedToy = nil,
        }
    end
    
    return points
end

local function assignBigHeartToysToPoints()
    BigHeartAssignedToys = {}
    
    for i = 1, math.min(#BigHeartToys, #BigHeartPoints) do
        local toy = BigHeartToys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachHeartPhysics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    PointIndex = i,
                    baseAngle = BigHeartPoints[i].angle,
                }  
                
                BigHeartPoints[i].assignedToy = toyTable
                table.insert(BigHeartAssignedToys, toyTable)
            end  
        end
    end
    
    return BigHeartAssignedToys
end

local function startBigHeartLoop()
    if BigHeartLoopConn then
        BigHeartLoopConn:Disconnect()
        BigHeartLoopConn = nil
    end
    
    BigHeartTime = 0
    
    BigHeartLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not BigHeartConfig.Enabled or not LocalPlayer.Character then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        BigHeartTime += dt
        
        local basePosition
        if BigHeartConfig.FollowPlayer then
            basePosition = torso.Position
        else
            -- プレイヤーの現在位置を基準にするが追従しない
            basePosition = torso.Position
        end
        
        -- 脈動効果の計算（拡張された速度範囲）
        local pulseEffect = 0
        if BigHeartConfig.PulseSpeed > 0 then
            pulseEffect = math.sin(BigHeartTime * BigHeartConfig.PulseSpeed) * BigHeartConfig.PulseAmplitude
        end
        
        for i, point in ipairs(BigHeartPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                -- 回転角度を計算（拡張された速度範囲）
                local currentAngle = toy.baseAngle + (BigHeartTime * BigHeartConfig.RotationSpeed)
                
                -- 大きなハート曲線上の位置を計算
                local x, y = getHeartPosition(
                    currentAngle, 
                    BigHeartConfig.Size, 
                    pulseEffect, 
                    BigHeartConfig.HeartScale,
                    BigHeartConfig.VerticalStretch
                )
                
                -- 高さ調整（大きいハートなので高さも大きめ）
                local heightOffset = BigHeartConfig.Height + (math.sin(currentAngle * 2) * 1.0)
                
                -- 最終的な位置（上から見た時にハート形になるようXZ平面で配置）
                local localPos = Vector3.new(x, heightOffset, y)
                
                local targetPosition = basePosition + localPos
                
                if point.part then
                    point.part.Position = targetPosition
                end
                
                toy.BP.Position = targetPosition
                
                -- 上を向くように設定
                toy.BG.CFrame = CFrame.new(targetPosition) * CFrame.Angles(-math.rad(90), 0, 0)
            end
        end
    end)
end

local function stopBigHeartLoop()
    if BigHeartLoopConn then
        BigHeartLoopConn:Disconnect()
        BigHeartLoopConn = nil
    end
    
    -- 物理演算をクリーンアップ
    for _, point in ipairs(BigHeartPoints) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    BigHeartPoints = {}
    BigHeartAssignedToys = {}
end

local function toggleBigHeart(state)
    BigHeartConfig.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if FeatherConfig.Enabled then
            toggleFeather(false)
        end
        if RingConfig.Enabled then
            toggleRingAura(false)
        end
        if HeartConfig.Enabled then
            toggleHeart(false)
        end
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
        end
        if StarConfig.Enabled then
            toggleStar(false)
        end
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
        end
        if ManjiConfig.Enabled then
            toggleManji(false)
        end
        if Star2Config.Enabled then
            toggleStar2(false)
        end
        
        BigHeartToys = findFireworkSparklers()
        BigHeartPoints = createBigHeartPoints(math.min(#BigHeartToys, BigHeartConfig.ObjectCount))
        BigHeartAssignedToys = assignBigHeartToysToPoints()
        startBigHeartLoop()
        
        OrionLib:MakeNotification({
            Name = "おっきぃ♡起動",
            Content = "サイズ: " .. BigHeartConfig.Size .. "×" .. BigHeartConfig.HeartScale .. ", 高さ: " .. BigHeartConfig.Height .. ", 数: " .. BigHeartConfig.ObjectCount,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopBigHeartLoop()
        OrionLib:MakeNotification({
            Name = "おっきぃ♡停止",
            Content = "大きなハート形配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- ダビデ星配置機能専用関数
-- ====================================================================
local function createStarOfDavidPoints(count)
    local points = {}
    
    if count == 0 then return points end
    
    for i = 1, count do
        -- 6角形の頂点に配置（2つの正三角形を重ねた形）
        local angle = (i - 1) * (2 * math.pi / 6)
        
        -- 参考点用パート
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        
        points[i] = {
            angle = angle,
            part = part,
            assignedToy = nil,
            triangleIndex = math.floor((i - 1) / 2) + 1,  -- 三角形のインデックス
        }
    end
    
    return points
end

local function getStarOfDavidPosition(i, angle, size, triangleHeight, time, pulseSpeed)
    local scale = size / 10
    
    -- 基本的な六角形の位置
    local baseX = math.cos(angle) * scale
    local baseZ = math.sin(angle) * scale
    
    -- 三角形の高さを考慮（上下の三角形）
    local heightOffset = 0
    if i % 2 == 0 then
        -- 上の三角形の頂点
        heightOffset = triangleHeight
    else
        -- 下の三角形の頂点
        heightOffset = -triangleHeight
    end
    
    -- 脈動効果
    local pulse = math.sin(time * pulseSpeed) * 0.1
    
    return baseX, baseZ, heightOffset + pulse
end

local function attachStarOfDavidPhysics(part)
    if not part then return nil, nil end
    
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    
    if existingBG and existingBP then 
        return existingBG, existingBP
    end
    
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    
    local BP = Instance.new("BodyPosition")  
    local BG = Instance.new("BodyGyro")  
    
    BP.P = 15000  
    BP.D = 200  
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10  
    BP.Parent = part  
    
    BG.P = 15000  
    BG.D = 200  
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10  
    BG.Parent = part  
    
    return BG, BP
end

local function assignStarOfDavidToysToPoints()
    StarOfDavidAssignedToys = {}
    
    for i = 1, math.min(#StarOfDavidToys, #StarOfDavidPoints) do
        local toy = StarOfDavidToys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachStarOfDavidPhysics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    PointIndex = i,
                    baseAngle = StarOfDavidPoints[i].angle,
                    triangleIndex = StarOfDavidPoints[i].triangleIndex,
                }  
                
                StarOfDavidPoints[i].assignedToy = toyTable
                table.insert(StarOfDavidAssignedToys, toyTable)
            end  
        end
    end
    
    return StarOfDavidAssignedToys
end

local function startStarOfDavidLoop()
    if StarOfDavidLoopConn then
        StarOfDavidLoopConn:Disconnect()
        StarOfDavidLoopConn = nil
    end
    
    StarOfDavidTime = 0
    
    StarOfDavidLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not StarOfDavidConfig.Enabled or not LocalPlayer.Character then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        StarOfDavidTime += dt
        
        local basePosition
        if StarOfDavidConfig.FollowPlayer then
            basePosition = torso.Position
        else
            basePosition = torso.Position
        end
        
        for i, point in ipairs(StarOfDavidPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                -- 回転角度を計算
                local currentAngle = toy.baseAngle + (StarOfDavidTime * StarOfDavidConfig.RotationSpeed)
                
                -- ダビデ星の位置を計算
                local x, z, heightOffset = getStarOfDavidPosition(
                    i, currentAngle, StarOfDavidConfig.Size, 
                    StarOfDavidConfig.TriangleHeight, StarOfDavidTime, StarOfDavidConfig.PulseSpeed
                )
                
                -- 最終的な高さ
                local finalHeight = StarOfDavidConfig.Height + heightOffset
                
                -- 最終的な位置
                local localPos = Vector3.new(x, finalHeight, z)
                local targetPosition = basePosition + localPos
                
                if point.part then
                    point.part.Position = targetPosition
                end
                
                toy.BP.Position = targetPosition
                
                -- 外側を向く
                local direction = (targetPosition - basePosition).Unit
                if direction.Magnitude > 0 then
                    local lookCFrame = CFrame.lookAt(targetPosition, targetPosition + direction)
                    toy.BG.CFrame = lookCFrame
                end
            end
        end
    end)
end

local function stopStarOfDavidLoop()
    if StarOfDavidLoopConn then
        StarOfDavidLoopConn:Disconnect()
        StarOfDavidLoopConn = nil
    end
    
    -- 物理演算をクリーンアップ
    for _, point in ipairs(StarOfDavidPoints) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    StarOfDavidPoints = {}
    StarOfDavidAssignedToys = {}
end

local function toggleStarOfDavid(state)
    StarOfDavidConfig.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if FeatherConfig.Enabled then
            toggleFeather(false)
        end
        if RingConfig.Enabled then
            toggleRingAura(false)
        end
        if HeartConfig.Enabled then
            toggleHeart(false)
        end
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
        end
        if StarConfig.Enabled then
            toggleStar(false)
        end
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
        end
        if ManjiConfig.Enabled then
            toggleManji(false)
        end
        if Star2Config.Enabled then
            toggleStar2(false)
        end
        
        StarOfDavidToys = findFireworkSparklers()
        StarOfDavidPoints = createStarOfDavidPoints(math.min(#StarOfDavidToys, StarOfDavidConfig.ObjectCount))
        StarOfDavidAssignedToys = assignStarOfDavidToysToPoints()
        startStarOfDavidLoop()
        
        OrionLib:MakeNotification({
            Name = "ダビデ✡起動",
            Content = "サイズ: " .. StarOfDavidConfig.Size .. ", 高さ: " .. StarOfDavidConfig.Height .. ", 数: " .. StarOfDavidConfig.ObjectCount,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopStarOfDavidLoop()
        OrionLib:MakeNotification({
            Name = "ダビデ✡停止",
            Content = "ダビデ星配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- スター配置機能専用関数（⭐️の形）
-- ====================================================================
local function createStarPoints(count)
    local points = {}
    
    if count == 0 then return points end
    
    for i = 1, count do
        -- 星の頂点に沿って配置（10個の頂点：5つの外側頂点と5つの内側頂点）
        local starIndex = (i - 1) % 10  -- 0-9
        local isOuter = starIndex % 2 == 0  -- 外側頂点（0,2,4,6,8）
        
        -- 参考点用パート
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        
        points[i] = {
            starIndex = starIndex,
            isOuter = isOuter,
            part = part,
            assignedToy = nil,
        }
    end
    
    return points
end

local function getStarPosition(starIndex, isOuter, outerRadius, innerRadius, time, rotationSpeed, twinkleSpeed)
    -- 星の角度（5角星なので72度間隔）
    local anglePerPoint = 2 * math.pi / 5
    local pointAngle = starIndex * (anglePerPoint / 2)  -- 内側と外側が交互になる
    
    -- 星の頂点の半径を決定
    local radius = isOuter and outerRadius or innerRadius
    
    -- 回転効果
    local rotationAngle = pointAngle + (time * rotationSpeed)
    
    -- 星の位置を計算
    local x = math.cos(rotationAngle) * radius
    local z = math.sin(rotationAngle) * radius
    
    -- きらめき効果
    local twinkle = math.sin(time * twinkleSpeed + starIndex) * 0.2
    local finalRadius = radius * (1 + twinkle)
    x = math.cos(rotationAngle) * finalRadius
    z = math.sin(rotationAngle) * finalRadius
    
    return x, z, pointAngle
end

local function attachStarPhysics(part)
    if not part then return nil, nil end
    
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    
    if existingBG and existingBP then 
        return existingBG, existingBP
    end
    
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    
    local BP = Instance.new("BodyPosition")  
    local BG = Instance.new("BodyGyro")  
    
    BP.P = 15000  
    BP.D = 200  
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10  
    BP.Parent = part  
    
    BG.P = 15000  
    BG.D = 200  
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10  
    BG.Parent = part  
    
    return BG, BP
end

local function assignStarToysToPoints()
    StarAssignedToys = {}
    
    for i = 1, math.min(#StarToys, #StarPoints) do
        local toy = StarToys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachStarPhysics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    PointIndex = i,
                    starIndex = StarPoints[i].starIndex,
                    isOuter = StarPoints[i].isOuter,
                }  
                
                StarPoints[i].assignedToy = toyTable
                table.insert(StarAssignedToys, toyTable)
            end  
        end
    end
    
    return StarAssignedToys
end

local function startStarLoop()
    if StarLoopConn then
        StarLoopConn:Disconnect()
        StarLoopConn = nil
    end
    
    StarTime = 0
    
    StarLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not StarConfig.Enabled or not LocalPlayer.Character then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        StarTime += dt
        
        local basePosition
        if StarConfig.FollowPlayer then
            basePosition = torso.Position
        else
            basePosition = torso.Position
        end
        
        for i, point in ipairs(StarPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                -- 星の位置を計算
                local x, z, pointAngle = getStarPosition(
                    toy.starIndex, toy.isOuter, 
                    StarConfig.OuterRadius, StarConfig.InnerRadius,
                    StarTime, StarConfig.RotationSpeed, StarConfig.TwinkleSpeed
                )
                
                -- 高さ調整（星の頂点によって少し変化）
                local heightVariation = math.sin(pointAngle * 3) * 0.5
                local finalHeight = StarConfig.Height + heightVariation
                
                -- 最終的な位置
                local localPos = Vector3.new(x, finalHeight, z)
                local targetPosition = basePosition + localPos
                
                if point.part then
                    point.part.Position = targetPosition
                end
                
                toy.BP.Position = targetPosition
                
                -- 星の中心から外側を向く
                local direction = (targetPosition - basePosition).Unit
                if direction.Magnitude > 0 then
                    local lookCFrame = CFrame.lookAt(targetPosition, targetPosition + direction)
                    toy.BG.CFrame = lookCFrame
                end
            end
        end
    end)
end

local function stopStarLoop()
    if StarLoopConn then
        StarLoopConn:Disconnect()
        StarLoopConn = nil
    end
    
    -- 物理演算をクリーンアップ
    for _, point in ipairs(StarPoints) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    StarPoints = {}
    StarAssignedToys = {}
end

local function toggleStar(state)
    StarConfig.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if FeatherConfig.Enabled then
            toggleFeather(false)
        end
        if RingConfig.Enabled then
            toggleRingAura(false)
        end
        if HeartConfig.Enabled then
            toggleHeart(false)
        end
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
        end
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
        end
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
        end
        if ManjiConfig.Enabled then
            toggleManji(false)
        end
        if Star2Config.Enabled then
            toggleStar2(false)
        end
        
        StarToys = findFireworkSparklers()
        StarPoints = createStarPoints(math.min(#StarToys, StarConfig.ObjectCount))
        StarAssignedToys = assignStarToysToPoints()
        startStarLoop()
        
        OrionLib:MakeNotification({
            Name = "スター★起動",
            Content = "外径: " .. StarConfig.OuterRadius .. ", 内径: " .. StarConfig.InnerRadius .. ", 数: " .. StarConfig.ObjectCount,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopStarLoop()
        OrionLib:MakeNotification({
            Name = "スター★停止",
            Content = "星形配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- スーパーリング（竜巻）配置機能専用関数
-- ====================================================================
local function createSuperRingPoints(count)
    local points = {}
    
    if count == 0 then return points end
    
    for i = 1, count do
        -- らせんに沿った角度を計算
        local angle = (i - 1) * (2 * math.pi / count)
        
        -- 参考点用パート
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        
        points[i] = {
            angle = angle,
            part = part,
            assignedToy = nil,
            heightOffset = (i - 1) * (SuperRingConfig.Height / count),  -- 高さオフセット
        }
    end
    
    return points
end

local function getSuperRingPosition(angle, radius, heightOffset, time, rotationSpeed, spiralSpeed, waveSpeed, waveAmplitude, tornadoEffect)
    -- 基本の円周上の位置
    local x = math.cos(angle) * radius
    local z = math.sin(angle) * radius
    
    -- 回転効果
    local rotationAngle = angle + (time * rotationSpeed)
    x = math.cos(rotationAngle) * radius
    z = math.sin(rotationAngle) * radius
    
    -- らせん効果
    local spiralOffset = 0
    if spiralSpeed > 0 then
        spiralOffset = math.sin(time * spiralSpeed + angle) * 0.5
    end
    
    -- 波の効果
    local waveOffset = 0
    if waveSpeed > 0 then
        waveOffset = math.sin(time * waveSpeed + angle * 2) * waveAmplitude
    end
    
    -- 竜巻効果（半径が高さによって変わる）
    local currentRadius = radius
    if tornadoEffect then
        -- 高くなるほど半径が小さくなる
        local heightFactor = 1 - (heightOffset / SuperRingConfig.Height) * 0.5
        currentRadius = radius * heightFactor
        x = math.cos(rotationAngle) * currentRadius
        z = math.sin(rotationAngle) * currentRadius
    end
    
    -- 最終的な高さ
    local finalHeight = SuperRingConfig.BaseHeight + heightOffset + spiralOffset + waveOffset
    
    return x, z, finalHeight, currentRadius
end

local function attachSuperRingPhysics(part)
    if not part then return nil, nil end
    
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    
    if existingBG and existingBP then 
        return existingBG, existingBP
    end
    
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    
    local BP = Instance.new("BodyPosition")  
    local BG = Instance.new("BodyGyro")  
    
    BP.P = 15000  
    BP.D = 200  
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10  
    BP.Parent = part  
    
    BG.P = 15000  
    BG.D = 200  
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10  
    BG.Parent = part  
    
    return BG, BP
end

local function assignSuperRingToysToPoints()
    SuperRingAssignedToys = {}
    
    for i = 1, math.min(#SuperRingToys, #SuperRingPoints) do
        local toy = SuperRingToys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachSuperRingPhysics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    PointIndex = i,
                    baseAngle = SuperRingPoints[i].angle,
                    baseHeightOffset = SuperRingPoints[i].heightOffset,
                }  
                
                SuperRingPoints[i].assignedToy = toyTable
                table.insert(SuperRingAssignedToys, toyTable)
            end  
        end
    end
    
    return SuperRingAssignedToys
end

local function startSuperRingLoop()
    if SuperRingLoopConn then
        SuperRingLoopConn:Disconnect()
        SuperRingLoopConn = nil
    end
    
    SuperRingTime = 0
    
    SuperRingLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not SuperRingConfig.Enabled or not LocalPlayer.Character then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        SuperRingTime += dt
        
        local basePosition
        if SuperRingConfig.FollowPlayer then
            basePosition = torso.Position
        else
            basePosition = torso.Position
        end
        
        for i, point in ipairs(SuperRingPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                -- 角度を計算
                local currentAngle = toy.baseAngle + (SuperRingTime * SuperRingConfig.RotationSpeed * 0.5)
                
                -- スーパーリングの位置を計算
                local x, z, height, radius = getSuperRingPosition(
                    currentAngle, SuperRingConfig.Radius, toy.baseHeightOffset,
                    SuperRingTime, SuperRingConfig.RotationSpeed, SuperRingConfig.SpiralSpeed,
                    SuperRingConfig.WaveSpeed, SuperRingConfig.WaveAmplitude, SuperRingConfig.TornadoEffect
                )
                
                -- 最終的な位置
                local localPos = Vector3.new(x, height, z)
                local targetPosition = basePosition + localPos
                
                if point.part then
                    point.part.Position = targetPosition
                end
                
                toy.BP.Position = targetPosition
                
                -- 竜巻効果がある場合、外側を向く
                if SuperRingConfig.TornadoEffect then
                    local direction = (targetPosition - basePosition).Unit
                    if direction.Magnitude > 0 then
                        local lookCFrame = CFrame.lookAt(targetPosition, targetPosition + direction)
                        toy.BG.CFrame = lookCFrame
                    end
                else
                    -- 上を向く
                    toy.BG.CFrame = CFrame.new(targetPosition) * CFrame.Angles(-math.rad(90), 0, 0)
                end
            end
        end
    end)
end

local function stopSuperRingLoop()
    if SuperRingLoopConn then
        SuperRingLoopConn:Disconnect()
        SuperRingLoopConn = nil
    end
    
    -- 物理演算をクリーンアップ
    for _, point in ipairs(SuperRingPoints) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    SuperRingPoints = {}
    SuperRingAssignedToys = {}
end

local function toggleSuperRing(state)
    SuperRingConfig.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if FeatherConfig.Enabled then
            toggleFeather(false)
        end
        if RingConfig.Enabled then
            toggleRingAura(false)
        end
        if HeartConfig.Enabled then
            toggleHeart(false)
        end
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
        end
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
        end
        if StarConfig.Enabled then
            toggleStar(false)
        end
        if ManjiConfig.Enabled then
            toggleManji(false)
        end
        if Star2Config.Enabled then
            toggleStar2(false)
        end
        
        SuperRingToys = findFireworkSparklers()
        SuperRingPoints = createSuperRingPoints(math.min(#SuperRingToys, SuperRingConfig.ObjectCount))
        SuperRingAssignedToys = assignSuperRingToysToPoints()
        startSuperRingLoop()
        
        OrionLib:MakeNotification({
            Name = "SuperRing起動",
            Content = "半径: " .. SuperRingConfig.Radius .. ", 高さ: " .. SuperRingConfig.Height .. ", 数: " .. SuperRingConfig.ObjectCount,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopSuperRingLoop()
        OrionLib:MakeNotification({
            Name = "SuperRing停止",
            Content = "スーパーリング配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- 卍マンジ配置機能専用関数（追加）
-- ====================================================================
local function createManjiPoints(count)
    local points = {}
    
    if count == 0 then return points end
    
    for i = 1, count do
        -- 卍の形に沿った角度を計算
        local t = (i - 1) * (2 * math.pi / count)
        
        -- 参考点用パート
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        
        points[i] = {
            angle = t,
            part = part,
            assignedToy = nil,
        }
    end
    
    return points
end

local function getManjiPosition(t, size, pulse, armLength, armThickness)
    -- 卍の形を計算する関数
    -- 基本的な円形に、4つの腕を追加
    
    local scale = size / 10
    
    -- 基本の円形位置
    local baseX = math.cos(t) * scale
    local baseZ = math.sin(t) * scale
    
    -- 卍の腕の位置を計算
    -- 4つの角度に腕を追加
    local armAngle1 = 0  -- 右
    local armAngle2 = math.pi / 2  -- 上
    local armAngle3 = math.pi  -- 左
    local armAngle4 = 3 * math.pi / 2  -- 下
    
    -- 現在の角度に最も近い腕を探す
    local closestArm = armAngle1
    local minDiff = math.abs(t - armAngle1)
    
    for _, arm in ipairs({armAngle2, armAngle3, armAngle4}) do
        local diff = math.abs(t - arm)
        if diff < minDiff then
            minDiff = diff
            closestArm = arm
        end
    end
    
    -- 腕の位置を計算
    local armFactor = 0
    if minDiff < (math.pi / 8) then  -- 腕の角度付近
        armFactor = (1 - (minDiff / (math.pi / 8))) * armLength
        
        -- 腕の幅方向の調整
        local perpendicularAngle = closestArm + math.pi / 2
        local perpX = math.cos(perpendicularAngle) * armThickness
        local perpZ = math.sin(perpendicularAngle) * armThickness
        
        -- 基本位置に腕の位置を追加
        baseX = baseX + math.cos(closestArm) * armFactor + perpX
        baseZ = baseZ + math.sin(closestArm) * armFactor + perpZ
    end
    
    -- 脈動効果
    if pulse > 0 then
        local pulseFactor = 1 + (pulse * 0.05)
        baseX = baseX * pulseFactor
        baseZ = baseZ * pulseFactor
    end
    
    return baseX, baseZ
end

local function attachManjiPhysics(part)
    if not part then return nil, nil end
    
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    
    if existingBG and existingBP then 
        return existingBG, existingBP
    end
    
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    
    local BP = Instance.new("BodyPosition")  
    local BG = Instance.new("BodyGyro")  
    
    BP.P = 15000  
    BP.D = 200  
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10  
    BP.Parent = part  
    
    BG.P = 15000  
    BG.D = 200  
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10  
    BG.Parent = part  
    
    return BG, BP
end

local function assignManjiToysToPoints()
    ManjiAssignedToys = {}
    
    for i = 1, math.min(#ManjiToys, #ManjiPoints) do
        local toy = ManjiToys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachManjiPhysics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    PointIndex = i,
                    baseAngle = ManjiPoints[i].angle,
                }  
                
                ManjiPoints[i].assignedToy = toyTable
                table.insert(ManjiAssignedToys, toyTable)
            end  
        end
    end
    
    return ManjiAssignedToys
end

local function startManjiLoop()
    if ManjiLoopConn then
        ManjiLoopConn:Disconnect()
        ManjiLoopConn = nil
    end
    
    ManjiTime = 0
    
    ManjiLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not ManjiConfig.Enabled or not LocalPlayer.Character then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        ManjiTime += dt
        
        local basePosition
        if ManjiConfig.FollowPlayer then
            basePosition = torso.Position
        else
            basePosition = torso.Position
        end
        
        -- 脈動効果の計算
        local pulseEffect = 0
        if ManjiConfig.PulseSpeed > 0 then
            pulseEffect = math.sin(ManjiTime * ManjiConfig.PulseSpeed) * ManjiConfig.PulseAmplitude
        end
        
        for i, point in ipairs(ManjiPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                -- 回転角度を計算（時間経過で回転）
                local currentAngle = toy.baseAngle + (ManjiTime * ManjiConfig.RotationSpeed)
                
                -- 卍の形の位置を計算
                local x, z = getManjiPosition(
                    currentAngle, 
                    ManjiConfig.Size, 
                    pulseEffect,
                    ManjiConfig.ArmLength,
                    ManjiConfig.ArmThickness
                )
                
                -- 高さ調整
                local heightOffset = ManjiConfig.Height + (math.sin(currentAngle * 2) * 0.3)
                
                -- 最終的な位置
                local localPos = Vector3.new(x, heightOffset, z)
                local targetPosition = basePosition + localPos
                
                if point.part then
                    point.part.Position = targetPosition
                end
                
                toy.BP.Position = targetPosition
                
                -- 外側を向く
                local direction = (targetPosition - basePosition).Unit
                if direction.Magnitude > 0 then
                    local lookCFrame = CFrame.lookAt(targetPosition, targetPosition + direction)
                    toy.BG.CFrame = lookCFrame
                end
            end
        end
    end)
end

local function stopManjiLoop()
    if ManjiLoopConn then
        ManjiLoopConn:Disconnect()
        ManjiLoopConn = nil
    end
    
    -- 物理演算をクリーンアップ
    for _, point in ipairs(ManjiPoints) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    ManjiPoints = {}
    ManjiAssignedToys = {}
end

local function toggleManji(state)
    ManjiConfig.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if FeatherConfig.Enabled then
            toggleFeather(false)
        end
        if RingConfig.Enabled then
            toggleRingAura(false)
        end
        if HeartConfig.Enabled then
            toggleHeart(false)
        end
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
        end
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
        end
        if StarConfig.Enabled then
            toggleStar(false)
        end
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
        end
        if Star2Config.Enabled then
            toggleStar2(false)
        end
        
        ManjiToys = findFireworkSparklers()
        ManjiPoints = createManjiPoints(math.min(#ManjiToys, ManjiConfig.ObjectCount))
        ManjiAssignedToys = assignManjiToysToPoints()
        startManjiLoop()
        
        OrionLib:MakeNotification({
            Name = "卍マンジ起動",
            Content = "サイズ: " .. ManjiConfig.Size .. ", 高さ: " .. ManjiConfig.Height .. ", 数: " .. ManjiConfig.ObjectCount,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopManjiLoop()
        OrionLib:MakeNotification({
            Name = "卍マンジ停止",
            Content = "卍形配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- スター2✫配置機能専用関数（追加 - 太陽のようなギザギザ模様）
-- ====================================================================
local function createStar2Points(count)
    local points = {}
    
    if count == 0 then return points end
    
    for i = 1, count do
        -- 光線に沿った角度を計算
        local t = (i - 1) * (2 * math.pi / count)
        
        -- 参考点用パート
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        
        points[i] = {
            angle = t,
            part = part,
            assignedToy = nil,
            rayIndex = (i - 1) % Star2Config.RayCount,
        }
    end
    
    return points
end

local function getStar2Position(t, size, pulse, rayLength, rayIndex, time, jitterSpeed, jitterAmount)
    -- 太陽のようなギザギザ模様を計算
    local scale = size / 10
    
    -- 基本の円形位置
    local baseRadius = scale
    
    -- 光線の効果（ギザギザ）
    local rayFactor = 0
    local anglePerRay = 2 * math.pi / Star2Config.RayCount
    local rayAngle = rayIndex * anglePerRay
    
    -- 現在の角度と最も近い光線の角度の差を計算
    local angleDiff = math.abs(t - rayAngle)
    if angleDiff > math.pi then
        angleDiff = 2 * math.pi - angleDiff
    end
    
    -- 光線の位置を計算
    if angleDiff < (anglePerRay / 4) then
        -- 光線の先端に近い場合
        rayFactor = (1 - (angleDiff / (anglePerRay / 4))) * rayLength
        
        -- ギザギザ効果（揺れ）
        local jitter = math.sin(time * jitterSpeed + rayIndex) * jitterAmount
        rayFactor = rayFactor * (1 + jitter * 0.1)
    end
    
    -- 脈動効果
    local pulseFactor = 1
    if pulse > 0 then
        pulseFactor = 1 + (pulse * 0.1)
    end
    
    -- 最終的な半径
    local finalRadius = (baseRadius + rayFactor) * pulseFactor
    
    -- 位置を計算
    local x = math.cos(t) * finalRadius
    local z = math.sin(t) * finalRadius
    
    return x, z, finalRadius
end

local function attachStar2Physics(part)
    if not part then return nil, nil end
    
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    
    if existingBG and existingBP then 
        return existingBG, existingBP
    end
    
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    
    local BP = Instance.new("BodyPosition")  
    local BG = Instance.new("BodyGyro")  
    
    BP.P = 20000  -- より高い値で高速移動に対応
    BP.D = 300
    BP.MaxForce = Vector3.new(1, 1, 1) * 1.5e10  -- より大きな力
    BP.Parent = part  
    
    BG.P = 20000
    BG.D = 300
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1.5e10
    BG.Parent = part  
    
    return BG, BP
end

local function assignStar2ToysToPoints()
    Star2AssignedToys = {}
    
    for i = 1, math.min(#Star2Toys, #Star2Points) do
        local toy = Star2Toys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachStar2Physics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    PointIndex = i,
                    baseAngle = Star2Points[i].angle,
                    rayIndex = Star2Points[i].rayIndex,
                }  
                
                Star2Points[i].assignedToy = toyTable
                table.insert(Star2AssignedToys, toyTable)
            end  
        end
    end
    
    return Star2AssignedToys
end

local function startStar2Loop()
    if Star2LoopConn then
        Star2LoopConn:Disconnect()
        Star2LoopConn = nil
    end
    
    Star2Time = 0
    
    Star2LoopConn = RunService.RenderStepped:Connect(function(dt)
        if not Star2Config.Enabled or not LocalPlayer.Character then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        Star2Time += dt
        
        local basePosition
        if Star2Config.FollowPlayer then
            basePosition = torso.Position
        else
            basePosition = torso.Position
        end
        
        -- 高速脈動効果の計算
        local pulseEffect = 0
        if Star2Config.PulseSpeed > 0 then
            pulseEffect = math.sin(Star2Time * Star2Config.PulseSpeed) * Star2Config.PulseAmplitude
        end
        
        for i, point in ipairs(Star2Points) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                -- 高速回転角度を計算
                local currentAngle = toy.baseAngle + (Star2Time * Star2Config.RotationSpeed)
                
                -- スター2（太陽）の位置を計算
                local x, z, radius = getStar2Position(
                    currentAngle, 
                    Star2Config.Size, 
                    pulseEffect,
                    Star2Config.RayLength,
                    toy.rayIndex,
                    Star2Time,
                    Star2Config.JitterSpeed,
                    Star2Config.JitterAmount
                )
                
                -- 高さ調整（揺れ効果）
                local heightVariation = math.sin(Star2Time * 3 + toy.rayIndex) * 0.5
                local heightOffset = Star2Config.Height + heightVariation
                
                -- 最終的な位置
                local localPos = Vector3.new(x, heightOffset, z)
                local targetPosition = basePosition + localPos
                
                if point.part then
                    point.part.Position = targetPosition
                end
                
                -- 高速移動用の調整
                toy.BP.Position = targetPosition
                
                -- 外側を向く（高速回転用に滑らかに）
                local direction = (targetPosition - basePosition).Unit
                if direction.Magnitude > 0 then
                    local currentCFrame = toy.BG.CFrame
                    local targetCFrame = CFrame.lookAt(targetPosition, targetPosition + direction)
                    local interpolatedCFrame = currentCFrame:Lerp(targetCFrame, 0.5)  -- 高速用に補間率を上げる
                    toy.BG.CFrame = interpolatedCFrame
                end
            end
        end
    end)
end

local function stopStar2Loop()
    if Star2LoopConn then
        Star2LoopConn:Disconnect()
        Star2LoopConn = nil
    end
    
    -- 物理演算をクリーンアップ
    for _, point in ipairs(Star2Points) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    Star2Points = {}
    Star2AssignedToys = {}
end

local function toggleStar2(state)
    Star2Config.Enabled = state
    if state then
        -- 他の機能を停止（同時に両方は動作しない）
        if FeatherConfig.Enabled then
            toggleFeather(false)
        end
        if RingConfig.Enabled then
            toggleRingAura(false)
        end
        if HeartConfig.Enabled then
            toggleHeart(false)
        end
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
        end
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
        end
        if StarConfig.Enabled then
            toggleStar(false)
        end
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
        end
        if ManjiConfig.Enabled then
            toggleManji(false)
        end
        
        Star2Toys = findFireworkSparklers()
        Star2Points = createStar2Points(math.min(#Star2Toys, Star2Config.ObjectCount))
        Star2AssignedToys = assignStar2ToysToPoints()
        startStar2Loop()
        
        OrionLib:MakeNotification({
            Name = "スター2✫起動",
            Content = "サイズ: " .. Star2Config.Size .. ", 高さ: " .. Star2Config.Height .. ", 光線: " .. Star2Config.RayCount,
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopStar2Loop()
        OrionLib:MakeNotification({
            Name = "スター2✫停止",
            Content = "太陽形配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- 便利機能 (Mi(=^・^=))
-- ====================================================================
local function toggleInfiniteJump(state)
    UtilityConfig.InfiniteJump = state
    
    if state then
        -- 無限ジャンプを有効化
        local connection
        connection = game:GetService("UserInputService").JumpRequest:Connect(function()
            if UtilityConfig.InfiniteJump and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState("Jumping")
                end
            end
        end)
        
        OrionLib:MakeNotification({
            Name = "無限ジャンプ",
            Content = "無限ジャンプを有効化しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    else
        OrionLib:MakeNotification({
            Name = "無限ジャンプ",
            Content = "無限ジャンプを無効化しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

local function toggleNoclip(state)
    UtilityConfig.Noclip = state
    
    if state then
        -- Noclipを有効化
        enableNoclip()
        OrionLib:MakeNotification({
            Name = "壁すり抜け",
            Content = "Noclipを有効化しました（壁抜け可能）",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    else
        -- Noclipを無効化
        disableNoclip()
        OrionLib:MakeNotification({
            Name = "壁すり抜け",
            Content = "Noclipを無効化しました（通常の当たり判定）",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- ====================================================================
-- Orion UI作成
-- ====================================================================
local Window = OrionLib:MakeWindow({
    Name = "🌸 さくらhub + Scripture 統合版 🌸",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = false,
    ThemeColor = Theme.BackgroundColor,
    BackgroundColor = Theme.BackgroundColor,
    TextColor = Theme.TextColor
})

-- ====================================================================
-- タブ1: 羽[Feather]
-- ====================================================================
local MainTab = Window:MakeTab({
    Name = "羽[Feather]",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

-- 羽のON/OFFトグル
MainTab:AddToggle({
    Name = "羽を起動 (背中側)",
    Default = false,
    Callback = function(Value)
        toggleFeather(Value)
    end
})

local FeatherSection1 = MainTab:AddSection({
    Name = "配置設定"
})

MainTab:AddSlider({
    Name = "最大花火数",
    Min = 2,
    Max = 40,
    Default = FeatherConfig.maxSparklers,
    Color = Theme.SliderColor,
    Increment = 2,
    ValueName = "本",
    Callback = function(Value)
        FeatherConfig.maxSparklers = Value
        if FeatherConfig.Enabled then
            toggleFeather(false)
            task.wait(0.1)
            toggleFeather(true)
        end
    end
})

MainTab:AddSlider({
    Name = "花火の間隔",
    Min = 1,
    Max = 10,
    Default = FeatherConfig.spacing,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        FeatherConfig.spacing = Value
        if FeatherConfig.Enabled then
            toggleFeather(false)
            task.wait(0.1)
            toggleFeather(true)
        end
    end
})

MainTab:AddSlider({
    Name = "高さオフセット",
    Min = -5,
    Max = 10,
    Default = FeatherConfig.heightOffset,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        FeatherConfig.heightOffset = Value
    end
})

MainTab:AddSlider({
    Name = "背中オフセット",
    Min = 0,
    Max = 10,
    Default = FeatherConfig.backwardOffset,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        FeatherConfig.backwardOffset = Value
    end
})

local FeatherSection2 = MainTab:AddSection({
    Name = "角度設定"
})

MainTab:AddSlider({
    Name = "花火の傾き角度",
    Min = 0,
    Max = 90,
    Default = FeatherConfig.tiltAngle,
    Color = Theme.SliderColor,
    Increment = 5,
    ValueName = "度",
    Callback = function(Value)
        FeatherConfig.tiltAngle = Value
    end
})

local FeatherSection3 = MainTab:AddSection({
    Name = "上下動設定"
})

MainTab:AddSlider({
    Name = "上下動の速度",
    Min = 0,
    Max = 10,
    Default = FeatherConfig.waveSpeed,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "速度",
    Callback = function(Value)
        FeatherConfig.waveSpeed = Value
    end
})

MainTab:AddSlider({
    Name = "基本振幅（最も近い花火）",
    Min = 0,
    Max = 5,
    Default = FeatherConfig.baseAmplitude,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        FeatherConfig.baseAmplitude = Value
    end
})

local FeatherSection4 = MainTab:AddSection({
    Name = "その他"
})

MainTab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if FeatherConfig.Enabled then
            toggleFeather(false)
            task.wait(0.1)
            toggleFeather(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- ====================================================================
-- タブ2: 魔法陣［RingX2］
-- ====================================================================
local RingTab = Window:MakeTab({
    Name = "魔法陣［RingX2］",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local RingSection1 = RingTab:AddSection({
    Name = "魔法陣基本設定"
})

RingTab:AddToggle({
    Name = "魔法陣を起動",
    Default = false,
    Callback = function(Value)
        toggleRingAura(Value)
    end
})

RingTab:AddSlider({
    Name = "魔法陣の高さ",
    Min = 0,
    Max = 20,
    Default = RingConfig.RingHeight,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        RingConfig.RingHeight = Value
    end
})

RingTab:AddSlider({
    Name = "魔法陣の直径",
    Min = 2,
    Max = 20,
    Default = RingConfig.RingDiameter,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        RingConfig.RingDiameter = Value
    end
})

RingTab:AddSlider({
    Name = "花火の数",
    Min = 3,
    Max = 20,
    Default = RingConfig.ObjectCount,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "個",
    Callback = function(Value)
        RingConfig.ObjectCount = Value
        if RingConfig.Enabled then
            rescanRing()
        end
    end
})

local RingSection2 = RingTab:AddSection({
    Name = "魔法陣回転設定"
})

RingTab:AddSlider({
    Name = "回転速度",
    Min = 1,
    Max = 50,
    Default = RingConfig.RotationSpeed,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "速度",
    Callback = function(Value)
        RingConfig.RotationSpeed = Value
    end
})

-- ====================================================================
-- タブ3: ♡ハート♡
-- ====================================================================
local HeartTab = Window:MakeTab({
    Name = "♡ハート♡",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local HeartSection1 = HeartTab:AddSection({
    Name = "基本設定"
})

HeartTab:AddToggle({
    Name = "ハート形を起動",
    Default = false,
    Callback = function(Value)
        toggleHeart(Value)
    end
})

HeartTab:AddToggle({
    Name = "プレイヤー追従",
    Default = HeartConfig.FollowPlayer,
    Callback = function(Value)
        HeartConfig.FollowPlayer = Value
    end
})

local HeartSection2 = HeartTab:AddSection({
    Name = "サイズ設定"
})

HeartTab:AddSlider({
    Name = "ハートのサイズ",
    Min = 2,
    Max = 15,
    Default = HeartConfig.Size,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        HeartConfig.Size = Value
    end
})

HeartTab:AddSlider({
    Name = "基本高さ",
    Min = 0,
    Max = 20,
    Default = HeartConfig.Height,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        HeartConfig.Height = Value
    end
})

HeartTab:AddSlider({
    Name = "花火の数",
    Min = 6,
    Max = 24,
    Default = HeartConfig.ObjectCount,
    Color = Theme.SliderColor,
    Increment = 2,
    ValueName = "個",
    Callback = function(Value)
        HeartConfig.ObjectCount = Value
        if HeartConfig.Enabled then
            toggleHeart(false)
            task.wait(0.1)
            toggleHeart(true)
        end
    end
})

local HeartSection3 = HeartTab:AddSection({
    Name = "動き設定"
})

HeartTab:AddSlider({
    Name = "回転速度",
    Min = 0,
    Max = 3,
    Default = HeartConfig.RotationSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        HeartConfig.RotationSpeed = Value
    end
})

HeartTab:AddSlider({
    Name = "脈動速度",
    Min = 0,
    Max = 5,
    Default = HeartConfig.PulseSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        HeartConfig.PulseSpeed = Value
    end
})

HeartTab:AddSlider({
    Name = "脈動振幅",
    Min = 0,
    Max = 2,
    Default = HeartConfig.PulseAmplitude,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "スタッド",
    Callback = function(Value)
        HeartConfig.PulseAmplitude = Value
    end
})

local HeartSection4 = HeartTab:AddSection({
    Name = "制御"
})

HeartTab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if HeartConfig.Enabled then
            toggleHeart(false)
            task.wait(0.1)
            toggleHeart(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- ====================================================================
-- タブ4: おっきぃ♡（大きいハート）- 速度拡張版
-- ====================================================================
local BigHeartTab = Window:MakeTab({
    Name = "おっきぃ♡",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local BigHeartSection1 = BigHeartTab:AddSection({
    Name = "基本設定"
})

BigHeartTab:AddToggle({
    Name = "おっきぃ♡を起動",
    Default = false,
    Callback = function(Value)
        toggleBigHeart(Value)
    end
})

BigHeartTab:AddToggle({
    Name = "プレイヤー追従",
    Default = BigHeartConfig.FollowPlayer,
    Callback = function(Value)
        BigHeartConfig.FollowPlayer = Value
    end
})

local BigHeartSection2 = BigHeartTab:AddSection({
    Name = "サイズ設定（大きい）"
})

BigHeartTab:AddSlider({
    Name = "ハートの基本サイズ",
    Min = 5,
    Max = 25,
    Default = BigHeartConfig.Size,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "スタッド",
    Callback = function(Value)
        BigHeartConfig.Size = Value
    end
})

BigHeartTab:AddSlider({
    Name = "拡大スケール",
    Min = 1.0,
    Max = 4.0,
    Default = BigHeartConfig.HeartScale,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "倍",
    Callback = function(Value)
        BigHeartConfig.HeartScale = Value
    end
})

BigHeartTab:AddSlider({
    Name = "垂直方向の伸び",
    Min = 1.0,
    Max = 2.0,
    Default = BigHeartConfig.VerticalStretch,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "倍",
    Callback = function(Value)
        BigHeartConfig.VerticalStretch = Value
    end
})

BigHeartTab:AddSlider({
    Name = "基本高さ",
    Min = 5,
    Max = 30,
    Default = BigHeartConfig.Height,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "スタッド",
    Callback = function(Value)
        BigHeartConfig.Height = Value
    end
})

BigHeartTab:AddSlider({
    Name = "花火の数（多い）",
    Min = 12,
    Max = 40,
    Default = BigHeartConfig.ObjectCount,
    Color = Theme.SliderColor,
    Increment = 2,
    ValueName = "個",
    Callback = function(Value)
        BigHeartConfig.ObjectCount = Value
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
            task.wait(0.1)
            toggleBigHeart(true)
        end
    end
})

local BigHeartSection3 = BigHeartTab:AddSection({
    Name = "動き設定（高速対応）"
})

BigHeartTab:AddSlider({
    Name = "回転速度（高速対応）",
    Min = 0,
    Max = BigHeartConfig.RotationSpeedMax,
    Default = BigHeartConfig.RotationSpeed,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "速度",
    Callback = function(Value)
        BigHeartConfig.RotationSpeed = Value
    end
})

BigHeartTab:AddSlider({
    Name = "脈動速度（高速対応）",
    Min = 0,
    Max = BigHeartConfig.PulseSpeedMax,
    Default = BigHeartConfig.PulseSpeed,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "速度",
    Callback = function(Value)
        BigHeartConfig.PulseSpeed = Value
    end
})

BigHeartTab:AddSlider({
    Name = "脈動振幅（大きく）",
    Min = 0,
    Max = 3,
    Default = BigHeartConfig.PulseAmplitude,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "スタッド",
    Callback = function(Value)
        BigHeartConfig.PulseAmplitude = Value
    end
})

local BigHeartSection4 = BigHeartTab:AddSection({
    Name = "制御"
})

BigHeartTab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if BigHeartConfig.Enabled then
            toggleBigHeart(false)
            task.wait(0.1)
            toggleBigHeart(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- ====================================================================
-- タブ5: ダビデ✡
-- ====================================================================
local StarOfDavidTab = Window:MakeTab({
    Name = "ダビデ✡",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local StarOfDavidSection1 = StarOfDavidTab:AddSection({
    Name = "基本設定"
})

StarOfDavidTab:AddToggle({
    Name = "ダビデ星を起動",
    Default = false,
    Callback = function(Value)
        toggleStarOfDavid(Value)
    end
})

StarOfDavidTab:AddToggle({
    Name = "プレイヤー追従",
    Default = StarOfDavidConfig.FollowPlayer,
    Callback = function(Value)
        StarOfDavidConfig.FollowPlayer = Value
    end
})

local StarOfDavidSection2 = StarOfDavidTab:AddSection({
    Name = "サイズ設定"
})

StarOfDavidTab:AddSlider({
    Name = "星のサイズ",
    Min = 2,
    Max = 15,
    Default = StarOfDavidConfig.Size,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        StarOfDavidConfig.Size = Value
    end
})

StarOfDavidTab:AddSlider({
    Name = "基本高さ",
    Min = 0,
    Max = 20,
    Default = StarOfDavidConfig.Height,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        StarOfDavidConfig.Height = Value
    end
})

StarOfDavidTab:AddSlider({
    Name = "三角形の高さ",
    Min = 0,
    Max = 5,
    Default = StarOfDavidConfig.TriangleHeight,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "スタッド",
    Callback = function(Value)
        StarOfDavidConfig.TriangleHeight = Value
    end
})

StarOfDavidTab:AddSlider({
    Name = "花火の数",
    Min = 6,
    Max = 24,
    Default = StarOfDavidConfig.ObjectCount,
    Color = Theme.SliderColor,
    Increment = 2,
    ValueName = "個",
    Callback = function(Value)
        StarOfDavidConfig.ObjectCount = Value
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
            task.wait(0.1)
            toggleStarOfDavid(true)
        end
    end
})

local StarOfDavidSection3 = StarOfDavidTab:AddSection({
    Name = "動き設定"
})

StarOfDavidTab:AddSlider({
    Name = "回転速度",
    Min = 0,
    Max = 3,
    Default = StarOfDavidConfig.RotationSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        StarOfDavidConfig.RotationSpeed = Value
    end
})

StarOfDavidTab:AddSlider({
    Name = "脈動速度",
    Min = 0,
    Max = 5,
    Default = StarOfDavidConfig.PulseSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        StarOfDavidConfig.PulseSpeed = Value
    end
})

local StarOfDavidSection4 = StarOfDavidTab:AddSection({
    Name = "制御"
})

StarOfDavidTab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if StarOfDavidConfig.Enabled then
            toggleStarOfDavid(false)
            task.wait(0.1)
            toggleStarOfDavid(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- ====================================================================
-- タブ6: スター★（⭐️の形）
-- ====================================================================
local StarTab = Window:MakeTab({
    Name = "スター★",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local StarSection1 = StarTab:AddSection({
    Name = "基本設定"
})

StarTab:AddToggle({
    Name = "星形を起動",
    Default = false,
    Callback = function(Value)
        toggleStar(Value)
    end
})

StarTab:AddToggle({
    Name = "プレイヤー追従",
    Default = StarConfig.FollowPlayer,
    Callback = function(Value)
        StarConfig.FollowPlayer = Value
    end
})

local StarSection2 = StarTab:AddSection({
    Name = "サイズ設定"
})

StarTab:AddSlider({
    Name = "外側の半径",
    Min = 2,
    Max = 10,
    Default = StarConfig.OuterRadius,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        StarConfig.OuterRadius = Value
    end
})

StarTab:AddSlider({
    Name = "内側の半径",
    Min = 1,
    Max = 5,
    Default = StarConfig.InnerRadius,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        StarConfig.InnerRadius = Value
    end
})

StarTab:AddSlider({
    Name = "基本高さ",
    Min = 0,
    Max = 20,
    Default = StarConfig.Height,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        StarConfig.Height = Value
    end
})

StarTab:AddSlider({
    Name = "花火の数",
    Min = 5,
    Max = 20,
    Default = StarConfig.ObjectCount,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "個",
    Callback = function(Value)
        StarConfig.ObjectCount = Value
        if StarConfig.Enabled then
            toggleStar(false)
            task.wait(0.1)
            toggleStar(true)
        end
    end
})

local StarSection3 = StarTab:AddSection({
    Name = "動き設定"
})

StarTab:AddSlider({
    Name = "回転速度",
    Min = 0,
    Max = 3,
    Default = StarConfig.RotationSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        StarConfig.RotationSpeed = Value
    end
})

StarTab:AddSlider({
    Name = "きらめき速度",
    Min = 0,
    Max = 5,
    Default = StarConfig.TwinkleSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        StarConfig.TwinkleSpeed = Value
    end
})

local StarSection4 = StarTab:AddSection({
    Name = "制御"
})

StarTab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if StarConfig.Enabled then
            toggleStar(false)
            task.wait(0.1)
            toggleStar(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- ====================================================================
-- タブ7: SuperRing
-- ====================================================================
local SuperRingTab = Window:MakeTab({
    Name = "SuperRing",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local SuperRingSection1 = SuperRingTab:AddSection({
    Name = "基本設定"
})

SuperRingTab:AddToggle({
    Name = "SuperRingを起動",
    Default = false,
    Callback = function(Value)
        toggleSuperRing(Value)
    end
})

SuperRingTab:AddToggle({
    Name = "プレイヤー追従",
    Default = SuperRingConfig.FollowPlayer,
    Callback = function(Value)
        SuperRingConfig.FollowPlayer = Value
    end
})

SuperRingTab:AddToggle({
    Name = "竜巻効果",
    Default = SuperRingConfig.TornadoEffect,
    Callback = function(Value)
        SuperRingConfig.TornadoEffect = Value
    end
})

local SuperRingSection2 = SuperRingTab:AddSection({
    Name = "サイズ設定"
})

SuperRingTab:AddSlider({
    Name = "基本半径",
    Min = 1,
    Max = 10,
    Default = SuperRingConfig.Radius,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        SuperRingConfig.Radius = Value
    end
})

SuperRingTab:AddSlider({
    Name = "基本高さ",
    Min = 0,
    Max = 10,
    Default = SuperRingConfig.BaseHeight,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        SuperRingConfig.BaseHeight = Value
    end
})

SuperRingTab:AddSlider({
    Name = "全体の高さ",
    Min = 5,
    Max = 30,
    Default = SuperRingConfig.Height,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "スタッド",
    Callback = function(Value)
        SuperRingConfig.Height = Value
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
            task.wait(0.1)
            toggleSuperRing(true)
        end
    end
})

SuperRingTab:AddSlider({
    Name = "花火の数",
    Min = 8,
    Max = 32,
    Default = SuperRingConfig.ObjectCount,
    Color = Theme.SliderColor,
    Increment = 2,
    ValueName = "個",
    Callback = function(Value)
        SuperRingConfig.ObjectCount = Value
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
            task.wait(0.1)
            toggleSuperRing(true)
        end
    end
})

local SuperRingSection3 = SuperRingTab:AddSection({
    Name = "動き設定"
})

SuperRingTab:AddSlider({
    Name = "回転速度",
    Min = 0,
    Max = 5,
    Default = SuperRingConfig.RotationSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        SuperRingConfig.RotationSpeed = Value
    end
})

SuperRingTab:AddSlider({
    Name = "らせん速度",
    Min = 0,
    Max = 3,
    Default = SuperRingConfig.SpiralSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        SuperRingConfig.SpiralSpeed = Value
    end
})

SuperRingTab:AddSlider({
    Name = "波の速度",
    Min = 0,
    Max = 3,
    Default = SuperRingConfig.WaveSpeed,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "速度",
    Callback = function(Value)
        SuperRingConfig.WaveSpeed = Value
    end
})

SuperRingTab:AddSlider({
    Name = "波の振幅",
    Min = 0,
    Max = 2,
    Default = SuperRingConfig.WaveAmplitude,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "スタッド",
    Callback = function(Value)
        SuperRingConfig.WaveAmplitude = Value
    end
})

local SuperRingSection4 = SuperRingTab:AddSection({
    Name = "制御"
})

SuperRingTab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if SuperRingConfig.Enabled then
            toggleSuperRing(false)
            task.wait(0.1)
            toggleSuperRing(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- ====================================================================
-- タブ8: 卍マンジ（追加）
-- ====================================================================
local ManjiTab = Window:MakeTab({
    Name = "卍マンジ",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local ManjiSection1 = ManjiTab:AddSection({
    Name = "基本設定"
})

ManjiTab:AddToggle({
    Name = "卍形を起動",
    Default = false,
    Callback = function(Value)
        toggleManji(Value)
    end
})

ManjiTab:AddToggle({
    Name = "プレイヤー追従",
    Default = ManjiConfig.FollowPlayer,
    Callback = function(Value)
        ManjiConfig.FollowPlayer = Value
    end
})

local ManjiSection2 = ManjiTab:AddSection({
    Name = "サイズ設定"
})

ManjiTab:AddSlider({
    Name = "卍のサイズ",
    Min = 3,
    Max = 20,
    Default = ManjiConfig.Size,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "スタッド",
    Callback = function(Value)
        ManjiConfig.Size = Value
    end
})

ManjiTab:AddSlider({
    Name = "基本高さ",
    Min = 0,
    Max = 20,
    Default = ManjiConfig.Height,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        ManjiConfig.Height = Value
    end
})

ManjiTab:AddSlider({
    Name = "腕の長さ",
    Min = 0.5,
    Max = 4.0,
    Default = ManjiConfig.ArmLength,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "スタッド",
    Callback = function(Value)
        ManjiConfig.ArmLength = Value
    end
})

ManjiTab:AddSlider({
    Name = "腕の太さ",
    Min = 0.1,
    Max = 1.0,
    Default = ManjiConfig.ArmThickness,
    Color = Theme.SliderColor,
    Increment = 0.05,
    ValueName = "スタッド",
    Callback = function(Value)
        ManjiConfig.ArmThickness = Value
    end
})

ManjiTab:AddSlider({
    Name = "花火の数",
    Min = 8,
    Max = 32,
    Default = ManjiConfig.ObjectCount,
    Color = Theme.SliderColor,
    Increment = 2,
    ValueName = "個",
    Callback = function(Value)
        ManjiConfig.ObjectCount = Value
        if ManjiConfig.Enabled then
            toggleManji(false)
            task.wait(0.1)
            toggleManji(true)
        end
    end
})

local ManjiSection3 = ManjiTab:AddSection({
    Name = "動き設定（高速対応）"
})

ManjiTab:AddSlider({
    Name = "回転速度（高速）",
    Min = 0,
    Max = ManjiConfig.RotationSpeedMax,
    Default = ManjiConfig.RotationSpeed,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "速度",
    Callback = function(Value)
        ManjiConfig.RotationSpeed = Value
    end
})

ManjiTab:AddSlider({
    Name = "脈動速度（高速）",
    Min = 0,
    Max = ManjiConfig.PulseSpeedMax,
    Default = ManjiConfig.PulseSpeed,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "速度",
    Callback = function(Value)
        ManjiConfig.PulseSpeed = Value
    end
})

ManjiTab:AddSlider({
    Name = "脈動振幅",
    Min = 0,
    Max = 2,
    Default = ManjiConfig.PulseAmplitude,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "スタッド",
    Callback = function(Value)
        ManjiConfig.PulseAmplitude = Value
    end
})

local ManjiSection4 = ManjiTab:AddSection({
    Name = "制御"
})

ManjiTab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if ManjiConfig.Enabled then
            toggleManji(false)
            task.wait(0.1)
            toggleManji(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- ====================================================================
-- タブ9: スター2✫（追加 - 太陽のようなギザギザ模様）
-- ====================================================================
local Star2Tab = Window:MakeTab({
    Name = "スター2✫",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local Star2Section1 = Star2Tab:AddSection({
    Name = "基本設定（高速・巨大）"
})

Star2Tab:AddToggle({
    Name = "太陽形を起動",
    Default = false,
    Callback = function(Value)
        toggleStar2(Value)
    end
})

Star2Tab:AddToggle({
    Name = "プレイヤー追従",
    Default = Star2Config.FollowPlayer,
    Callback = function(Value)
        Star2Config.FollowPlayer = Value
    end
})

local Star2Section2 = Star2Tab:AddSection({
    Name = "サイズ設定（巨大）"
})

Star2Tab:AddSlider({
    Name = "基本サイズ（巨大）",
    Min = 5,
    Max = Star2Config.SizeMax,
    Default = Star2Config.Size,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "スタッド",
    Callback = function(Value)
        Star2Config.Size = Value
    end
})

Star2Tab:AddSlider({
    Name = "光線の長さ",
    Min = 1.0,
    Max = Star2Config.RayLengthMax,
    Default = Star2Config.RayLength,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "スタッド",
    Callback = function(Value)
        Star2Config.RayLength = Value
    end
})

Star2Tab:AddSlider({
    Name = "基本高さ（高い）",
    Min = 5,
    Max = 30,
    Default = Star2Config.Height,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "スタッド",
    Callback = function(Value)
        Star2Config.Height = Value
    end
})

Star2Tab:AddSlider({
    Name = "光線の数",
    Min = 6,
    Max = 24,
    Default = Star2Config.RayCount,
    Color = Theme.SliderColor,
    Increment = 2,
    ValueName = "本",
    Callback = function(Value)
        Star2Config.RayCount = Value
        if Star2Config.Enabled then
            toggleStar2(false)
            task.wait(0.1)
            toggleStar2(true)
        end
    end
})

Star2Tab:AddSlider({
    Name = "花火の数（多い）",
    Min = 12,
    Max = 48,
    Default = Star2Config.ObjectCount,
    Color = Theme.SliderColor,
    Increment = 4,
    ValueName = "個",
    Callback = function(Value)
        Star2Config.ObjectCount = Value
        if Star2Config.Enabled then
            toggleStar2(false)
            task.wait(0.1)
            toggleStar2(true)
        end
    end
})

local Star2Section3 = Star2Tab:AddSection({
    Name = "動き設定（超高速）"
})

Star2Tab:AddSlider({
    Name = "回転速度（超高速）",
    Min = 0,
    Max = Star2Config.RotationSpeedMax,
    Default = Star2Config.RotationSpeed,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "速度",
    Callback = function(Value)
        Star2Config.RotationSpeed = Value
    end
})

Star2Tab:AddSlider({
    Name = "脈動速度（超高速）",
    Min = 0,
    Max = Star2Config.PulseSpeedMax,
    Default = Star2Config.PulseSpeed,
    Color = Theme.SliderColor,
    Increment = 1,
    ValueName = "速度",
    Callback = function(Value)
        Star2Config.PulseSpeed = Value
    end
})

Star2Tab:AddSlider({
    Name = "脈動振幅（大きく）",
    Min = 0,
    Max = 5,
    Default = Star2Config.PulseAmplitude,
    Color = Theme.SliderColor,
    Increment = 0.2,
    ValueName = "スタッド",
    Callback = function(Value)
        Star2Config.PulseAmplitude = Value
    end
})

local Star2Section4 = Star2Tab:AddSection({
    Name = "ギザギザ効果"
})

Star2Tab:AddSlider({
    Name = "ギザギザ速度",
    Min = 0,
    Max = 10,
    Default = Star2Config.JitterSpeed,
    Color = Theme.SliderColor,
    Increment = 0.5,
    ValueName = "速度",
    Callback = function(Value)
        Star2Config.JitterSpeed = Value
    end
})

Star2Tab:AddSlider({
    Name = "ギザギザ量",
    Min = 0,
    Max = 3,
    Default = Star2Config.JitterAmount,
    Color = Theme.SliderColor,
    Increment = 0.1,
    ValueName = "スタッド",
    Callback = function(Value)
        Star2Config.JitterAmount = Value
    end
})

local Star2Section5 = Star2Tab:AddSection({
    Name = "制御"
})

Star2Tab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if Star2Config.Enabled then
            toggleStar2(false)
            task.wait(0.1)
            toggleStar2(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- ====================================================================
-- タブ10: Mi(=^・^=)
-- ====================================================================
local UtilityTab = Window:MakeTab({
    Name = "Mi(=^・^=)",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local UtilitySection1 = UtilityTab:AddSection({
    Name = "便利機能"
})

UtilityTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(Value)
        toggleInfiniteJump(Value)
    end
})

UtilityTab:AddToggle({
    Name = "Noclip (壁抜け)",
    Default = false,
    Callback = function(Value)
        toggleNoclip(Value)
    end
})

local UtilitySection2 = UtilityTab:AddSection({
    Name = "情報"
})

UtilityTab:AddLabel("現在のプレイヤー: " .. LocalPlayer.Name)
UtilityTab:AddLabel("ゲーム: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

UtilityTab:AddButton({
    Name = "スクリプトを再読み込み",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "再読み込み",
            Content = "ゲームを再起動してスクリプトを再実行してください",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end
})

-- ====================================================================
-- 初期化
-- ====================================================================
OrionLib:MakeNotification({
    Name = "さくらhub起動",
    Content = "全10タブの機能が使用可能です",
    Image = "rbxassetid://4483362458",
    Time = 5
})

-- テーマカスタマイズ（Init再帰バグ修正済み）

-- ==============================================
-- Scripture機能: Grab/Object/Defense/Aura/Fun系タブ
-- ==============================================

local GrabTab = Window:MakeTab({Name = "掴み操作", Icon =  "rbxassetid://18624615643", PremiumOnly = false})

local ObjectGrabTab = Window:MakeTab({Name = "オブジェクト掴み", Icon =  "rbxassetid://18624606749", PremiumOnly = false})
local DefenseTab = Window:MakeTab({Name = "防御", Icon =  "rbxassetid://18624604880", PremiumOnly = false})
local BlobmanTab = Window:MakeTab({Name = "ブロブマン操作", Icon =  "rbxassetid://18624614127", PremiumOnly = false})
local FunTab = Window:MakeTab({Name = "お楽しみ", Icon =  "rbxassetid://18624603093", PremiumOnly = false})
local ScriptTab = Window:MakeTab({Name = "外部スクリプト", Icon =  "rbxassetid://11570626783", PremiumOnly = false})
local AuraTab = Window:MakeTab({Name = "オーラ", Icon =  "rbxassetid://18624608005", PremiumOnly = false})
local CharacterTab = Window:MakeTab({Name = "キャラクター", Icon =  "rbxassetid://18624601543", PremiumOnly = false})
local ExplosionTab = Window:MakeTab({Name = "爆発操作", Icon =  "rbxassetid://18624610285", PremiumOnly = false})
local KeybindsTab = Window:MakeTab({Name = "キーバインド", Icon =  "rbxassetid://18624616682", PremiumOnly = false})
local DevTab = Window:MakeTab({Name = "開発テスト", Icon =  "rbxassetid://18624599762", PremiumOnly = false})



_G.strength = 400


GrabTab:AddSlider({
    Name = "投げ力",
    Min = 300,
    Max = 4000,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = _G.strength,
    Save = true,
    Flag = "StrengthSlider",
    Callback = function(value)
        _G.strength = value
    end
})

GrabTab:AddToggle({
    Name = "投げ力",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "StrengthToggle",
    Callback = function(enabled)
        if enabled then
            strengthConnection = workspace.ChildAdded:Connect(function(model)
                if model.Name == "GrabParts" then
                    local partToImpulse = model.GrabPart.WeldConstraint.Part1
                    if partToImpulse then
                        local velocityObj = Instance.new("BodyVelocity", partToImpulse)
                        model:GetPropertyChangedSignal("Parent"):Connect(function()
                            if not model.Parent then
                                if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                                    velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    velocityObj.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.strength
                                    Debris:AddItem(velocityObj, 1)
                                else
                                    velocityObj:Destroy()
                                end
                            end
                        end)
                    end
                end
            end)
        elseif strengthConnection then
            strengthConnection:Disconnect()
        end
    end
})

GrabTab:AddParagraph("掴み系", "相手を掴んだ時にこれらの効果が適用されます")

GrabTab:AddToggle({
    Name = "毒掴み",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "PoisonGrab",
    Callback = function(enabled)
        if enabled then
            poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
            coroutine.resume(poisonGrabCoroutine)
        else
            if poisonGrabCoroutine then
                coroutine.close(poisonGrabCoroutine)
                poisonGrabCoroutine = nil
                for _, part in pairs(poisonHurtParts) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "放射能掴み",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "RadioactiveGrab",
    Callback = function(enabled)
        if enabled then
            ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end)
            coroutine.resume(ufoGrabCoroutine)
        else
            if ufoGrabCoroutine then
                coroutine.close(ufoGrabCoroutine)
                ufoGrabCoroutine = nil
                for _, part in pairs(paintPlayerParts) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "炎掴み",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "FireGrab",
    Callback = function(enabled)
        if enabled then
            fireGrabCoroutine = coroutine.create(fireGrab)
            coroutine.resume(fireGrabCoroutine)
        else
            if fireGrabCoroutine then
                coroutine.close(fireGrabCoroutine)
                fireGrabCoroutine = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "すり抜け掴み",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "NoclipGrab",
    Callback = function(enabled)
        if enabled then
            noclipGrabCoroutine = coroutine.create(noclipGrab)
            coroutine.resume(noclipGrabCoroutine)
        else
            if noclipGrabCoroutine then
                coroutine.close(noclipGrabCoroutine)
                noclipGrabCoroutine = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "キック掴み",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "KickGrab",
    Callback = function(enabled)
        if enabled then
            kickGrab()
        else
            for _, connection in pairs(kickGrabConnections) do
                connection:Disconnect()
            end
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    if hrp:FindFirstChild("FirePlayerPart") then
                        local fpp = hrp.FirePlayerPart
                        fpp.Size = Vector3.new(2.5, 5.5, 2.5)
                        fpp.CollisionGroup = "Default"
                        fpp.CanQuery = false
                    end
                end
            end
            kickGrabConnections = {}
        end
    end
})


GrabTab:AddToggle({
    Name = "キック掴み固定（キック掴みと併用）",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "AnchorKickGrab",
    Callback = function(enabled)
        if enabled then
            if not anchorKickCoroutine or coroutine.status(anchorKickCoroutine) == "dead" then
                anchorKickCoroutine = coroutine.create(anchorKickGrab)
                coroutine.resume(anchorKickCoroutine)
            end
        else
            if anchorKickCoroutine and coroutine.status(anchorKickCoroutine) ~= "dead" then
                coroutine.close(anchorKickCoroutine)
                anchorKickCoroutine = nil
            end
        end
    end
})

GrabTab:AddParagraph("All-Features", "Make sure there are no campfires spawned by you BEFORE using this")

GrabTab:AddToggle({
    Name = "全員炎攻撃",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
            fireAllCoroutine = coroutine.create(fireAll)
            coroutine.resume(fireAllCoroutine)
        else
            if fireAllCoroutine then
                coroutine.close(fireAllCoroutine)
                fireAllCoroutine = nil
            end
        end
    end
})


ObjectGrabTab:AddParagraph("Object-Only", "These effects only apply on objects.")

ObjectGrabTab:AddToggle({
    Name = "固定掴み",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AnchorGrab",
    Callback = function(enabled)
        if enabled then
            if not anchorGrabCoroutine or coroutine.status(anchorGrabCoroutine) == "dead" then
                anchorGrabCoroutine = coroutine.create(anchorGrab)
                coroutine.resume(anchorGrabCoroutine)
            end
        else
            if anchorGrabCoroutine and coroutine.status(anchorGrabCoroutine) ~= "dead" then
                coroutine.close(anchorGrabCoroutine)
                anchorGrabCoroutine = nil
            end
        end
    end
})

ObjectGrabTab:AddParagraph("Anchor grab information", "If someone grabs your anchored parts, they will fall and you will need to position them again!")

ObjectGrabTab:AddButton({
    Name = "パーツ固定解除",
    Callback = cleanupAnchoredParts
})

ObjectGrabTab:AddParagraph("Compile?", "(New) This option allows you to compile all the anchored parts into one. To control this 'Build', you need to move the header part. The first part you grabbed will be the header and will be highlighted green")

ObjectGrabTab:AddButton({
    Name = "パーツ結合",
    Callback = function()
        compileGroup()
        if not compileCoroutine or coroutine.status(compileCoroutine) == "dead" then
            compileCoroutine = coroutine.create(compileCoroutineFunc)
            coroutine.resume(compileCoroutine)
        end
    end
})

ObjectGrabTab:AddParagraph("Disassemble", "De-compiles the build")

ObjectGrabTab:AddButton({
    Name = "パーツ分解",
    Callback = function()
        cleanupCompiledGroups()
        cleanupAnchoredParts()

        if compileCoroutine and coroutine.status(compileCoroutine) ~= "dead" then
            coroutine.close(compileCoroutine)
            compileCoroutine = nil
        end
    end
})
ObjectGrabTab:AddToggle({
    Name = "落としたパーツ自動回収",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "AutoRecoverDroppedParts",
    Callback = function(enabled)
        if enabled then
            if not AutoRecoverDroppedPartsCoroutine or coroutine.status(AutoRecoverDroppedPartsCoroutine) == "dead" then
                AutoRecoverDroppedPartsCoroutine = coroutine.create(recoverParts)
                coroutine.resume(AutoRecoverDroppedPartsCoroutine)
            end
        else
            if AutoRecoverDroppedPartsCoroutine and coroutine.status(AutoRecoverDroppedPartsCoroutine) ~= "dead" then
                coroutine.close(AutoRecoverDroppedPartsCoroutine)
                AutoRecoverDroppedPartsCoroutine = nil
            end
        end
    end
})
ObjectGrabTab:AddButton({
    Name = "ヘッダーパーツ固定解除",
    Callback = unanchorPrimaryPart
})


DefenseTab:AddLabel("Grab Defense")

DefenseTab:AddToggle({
    Name = "掴み防止",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "AutoStruggle",
    Callback = function(enabled)
        if enabled then
            autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("Head") then
                    local head = character.Head
                    local partOwner = head:FindFirstChild("PartOwner")
                    if partOwner then
                        Struggle:FireServer()
                        ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        while localPlayer.IsHeld.Value do
                            wait()
                        end
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
                    end
                end
            end)
        else
            if autoStruggleCoroutine then
                autoStruggleCoroutine:Disconnect()
                autoStruggleCoroutine = nil
            end
        end
    end
})

DefenseTab:AddToggle({
    Name = "キック掴み防止",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AntiKickGrab",
    Callback = function(enabled)
        if enabled then
            local character = localPlayer.Character

            antiKickCoroutine = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart") then
                    local partOwner = character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart"):FindFirstChild("PartOwner")
                    if partOwner and partOwner.Value ~= localPlayer.Name then
                        local args = {[1] = character:WaitForChild("HumanoidRootPart"), [2] = 0}
                        game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
                        wait(0.1)
                        Struggle:FireServer()
                    end
                end
            end)
        else
            if antiKickCoroutine then
                antiKickCoroutine:Disconnect()
                antiKickCoroutine = nil
            end
        end
    end
})


DefenseTab:AddToggle({
    Name = "爆発防止",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AntiExplosion",
    Callback = function(enabled)
        local localPlayer = game.Players.LocalPlayer

        if enabled then
            if localPlayer.Character then
                setupAntiExplosion(localPlayer.Character)
            end
            characterAddedConn = localPlayer.CharacterAdded:Connect(function(character)
                if antiExplosionConnection then
                    antiExplosionConnection:Disconnect()
                end
                setupAntiExplosion(character)
            end)
        else
            if antiExplosionConnection then
                antiExplosionConnection:Disconnect()
                antiExplosionConnection = nil
            end
            if characterAddedConn then
                characterAddedConn:Disconnect()
                characterAddedConn = nil
            end
        end
    end
})



DefenseTab:AddLabel("Self-Defense")

DefenseTab:AddToggle({
    Name = "自衛 - 空中浮遊",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "SelfDefenseAirSuspend",
    Callback = function(enabled)
        if enabled then
            autoDefendCoroutine = coroutine.create(function()
                while wait(0.02) do
                    local character = localPlayer.Character
                    if character and character:FindFirstChild("Head") then
                        local head = character.Head
                        local partOwner = head:FindFirstChild("PartOwner")
                        if partOwner then
                            local attacker = Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character then
                                Struggle:FireServer()
                                SetNetworkOwner:FireServer(attacker.Character.Head or attacker.Character.Torso, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                task.wait(0.1)
                                local target = attacker.Character:FindFirstChild("Torso")
                                if target then
                                    local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity")
                                    velocity.Name = "l"
                                    velocity.Parent = target
                                    velocity.Velocity = Vector3.new(0, 50, 0)
                                    velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                    Debris:AddItem(velocity, 100)
                                end
                            end
                        end
                    end
                end
            end)
            coroutine.resume(autoDefendCoroutine)
        else
            if autoDefendCoroutine then
                coroutine.close(autoDefendCoroutine)
                autoDefendCoroutine = nil
            end
        end
    end
})

DefenseTab:AddToggle({
    Name = "自衛キック - サイレント",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "SelfDefenseKick",
    Callback = function(enabled)
        if enabled then
            autoDefendKickCoroutine = coroutine.create(function()
                while enabled do
                    local character = localPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        local head = character:FindFirstChild("Head")
                        if head then
                            local partOwner = head:FindFirstChild("PartOwner")
                            if partOwner then
                                local attacker = Players:FindFirstChild(partOwner.Value)
                                if attacker and attacker.Character then
                                    Struggle:FireServer()
                                    SetNetworkOwner:FireServer(attacker.Character.HumanoidRootPart.FirePlayerPart, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                    task.wait(0.1)
                                    if not attacker.Character.HumanoidRootPart.FirePlayerPart:FindFirstChild("BodyVelocity") then
                                        local bodyVelocity = Instance.new("BodyVelocity")
                                        bodyVelocity.Name = "BodyVelocity"
                                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                                        bodyVelocity.Parent = attacker.Character.HumanoidRootPart.FirePlayerPart
                                    end
                                end
                            end
                        end
                    end
                    wait(0.02)
                end
            end)
            coroutine.resume(autoDefendKickCoroutine)
        else
            if autoDefendKickCoroutine then
                coroutine.close(autoDefendKickCoroutine)
                autoDefendKickCoroutine = nil
            end
        end
    end
})
local blobman1
blobman1 = BlobmanTab:AddToggle({
    Name = "全員掴みループ",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Callback = function(enabled)
        if enabled then
            blobmanCoroutine = coroutine.create(function()
                local foundBlobman = false
                for i, v in pairs(game.Workspace:GetDescendants()) do
                    if v.Name == "CreatureBlobman" then
                        if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(v.VehicleSeat.SeatWeld.Part1, localPlayer.Character) then
                            blobman = v
                            foundBlobman = true
                            break
                        end
                    end
                end

                if not foundBlobman then
                    OrionLib:MakeNotification({
                        Name = "エラー",
                        Content = "You must be mounted upon a blobman to begin this process. Please mount one and toggle this again!", 
                        Image = "rbxassetid://4483345998", 
                        Time = 5
                    })
                    blobman1:Set(false)
                    blobman = nil
                    coroutine.close(blobmanCoroutine)
                    blobmanCoroutine = nil
                    return
                end

                while true do
                    pcall(function()
                        while wait() do
                            for i, v in pairs(Players:GetChildren()) do
                                if blobman and v ~= localPlayer then
                                    blobGrabPlayer(v, blobman)
                                    wait(_G.BlobmanDelay)
                                end
                            end
                        end
                    end)
                    wait(0.02)
                end
            end)
            coroutine.resume(blobmanCoroutine)
        else
            if blobmanCoroutine then
                coroutine.close(blobmanCoroutine)
                blobmanCoroutine = nil
                blobman = nil
            end
        end
    end
})
BlobmanTab:AddSlider({
    Name = "遅延",
    Min = 0.0005,
    Max = 1,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 0.001,
    Default = _G.BlobmanDelay ,
    Callback = function(value)
        _G.BlobmanDelay  = value
    end
})
AuraTab:AddLabel("オーラ")

AuraTab:AddSlider({
    Name = "範囲",
    Min = 5,
    Max = 40,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = auraRadius,
    Callback = function(value)
        auraRadius = value
    end
})

AuraTab:AddToggle({
    Name = "空中浮遊オーラ",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            auraCoroutine = coroutine.create(function()
                while true do
                    local success, err = pcall(function()
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                            local head = character.Head
                            local humanoidRootPart = character.HumanoidRootPart

                            for _, player in pairs(Players:GetPlayers()) do
                                coroutine.wrap(function()
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Torso")
                                        if playerTorso then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
                                                task.wait(0.1)
                                                local velocity = playerTorso:FindFirstChild("l") or Instance.new("BodyVelocity", playerTorso)
                                                velocity.Name = "l"
                                                velocity.Velocity = Vector3.new(0, 50, 0)
                                                velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                                Debris:AddItem(velocity, 100)
                                            end
                                        end
                                    end
                                end)()
                            end
                        end
                    end)
                    if not success then
                    end
                    wait(0.02)
                end
            end)
            coroutine.resume(auraCoroutine)
        else
            if auraCoroutine then
                coroutine.close(auraCoroutine)
                auraCoroutine = nil
            end
        end
    end
})

AuraTab:AddToggle({
    Name = "地獄送りオーラ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
            gravityCoroutine = coroutine.create(function()
                while enabled do
                    local success, err = pcall(function()
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local humanoidRootPart = character.HumanoidRootPart

                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= localPlayer and player.Character then
                                    local playerCharacter = player.Character
                                    local playerTorso = playerCharacter:FindFirstChild("Torso")
                                    if playerTorso then
                                        local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                        if distance <= auraRadius then
                                            SetNetworkOwner:FireServer(playerTorso, humanoidRootPart.FirePlayerPart.CFrame)
                                            task.wait(0.1)
                                            local force = playerTorso:FindFirstChild("GravityForce") or Instance.new("BodyForce")
                                            force.Parent = playerTorso
                                            force.Name = "GravityForce"
                                            for _, part in ipairs(playerCharacter:GetDescendants()) do
                                                if part:IsA("BasePart") then
                                                    part.CanCollide = false
                                                end
                                            end
                                            force.Force = Vector3.new(0, 1200, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    if not success then
                    end
                    wait(0.02)
                end
            end)
            coroutine.resume(gravityCoroutine)
        elseif gravityCoroutine then
            coroutine.close(gravityCoroutine)
            gravityCoroutine = nil
        end
    end
})

AuraTab:AddToggle({
    Name = "キックオーラ",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if auraToggle == 1 then
            if enabled then
                kickCoroutine = coroutine.create(function()
                    while enabled do
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Head")

                                        if playerTorso then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                SetNetworkOwner:FireServer(playerCharacter:WaitForChild("HumanoidRootPart").FirePlayerPart, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
                                                if not platforms[player] then
                                                    local platform = playerCharacter:FindFirstChild("FloatingPlatform") or Instance.new("Part")
                                                    platform.Name = "FloatingPlatform"
                                                    platform.Size = Vector3.new(5, 2, 5)
                                                    platform.Anchored = true
                                                    platform.Transparency = 1
                                                    platform.CanCollide = true
                                                    platform.Parent = playerCharacter
                                                    platforms[player] = platform
                                                end
                                            end
                                        end
                                    end
                                end
                                for player, platform in pairs(platforms) do
                                    if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health > 1 then
                                        local playerHumanoidRootPart = player.Character.HumanoidRootPart
                                        platform.Position = playerHumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                                    else
                                        platforms[player] = nil
                                    end
                                end
                            end
                        end)
                        if not success then
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(kickCoroutine)
            elseif kickCoroutine then
                coroutine.close(kickCoroutine)
                kickCoroutine = nil
                for _, platform in pairs(platforms) do
                    if platform then
                        platform:Destroy()
                    end
                end
                platforms = {}
            end
        elseif auraToggle == 2 then
            if enabled then
                kickCoroutine = coroutine.create(function()
                    while enabled do
                        local success, err = pcall(function()
                            local character = localPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local humanoidRootPart = character.HumanoidRootPart

                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local playerCharacter = player.Character
                                        local playerTorso = playerCharacter:FindFirstChild("Head")

                                        if playerTorso then
                                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                            if distance <= auraRadius then
                                                SetNetworkOwner:FireServer(playerCharacter:WaitForChild("HumanoidRootPart").FirePlayerPart, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
                                                if not playerCharacter.HumanoidRootPart.FirePlayerPart:FindFirstChild("BodyVelocity") then
                                                    local bodyVelocity = Instance.new("BodyVelocity")
                                                    bodyVelocity.Name = "BodyVelocity"
                                                    bodyVelocity.Velocity = Vector3.new(0, 20, 0) 
                                                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                    bodyVelocity.Parent = playerCharacter.HumanoidRootPart.FirePlayerPart
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        if not success then
                        end
                        wait(0.02)
                    end
                end)
                coroutine.resume(kickCoroutine)
            else
                if kickCoroutine then
                    coroutine.close(kickCoroutine)
                    kickCoroutine = nil
                end
            end
        end
    end
})

AuraTab:AddDropdown({
    Name = "キックモード選択",
    Options = {"Sky", "Silent"},
    Default = "",
    Save = true,
    Flag = "KickModeFlag",
    Callback = function(selected)
        if selected == "Sky" then 
            auraToggle = 2 
        else 
            auraToggle = 1 
        end
    end
})

AuraTab:AddToggle({
    Name = "毒オーラ",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Callback = function(enabled)
        if enabled then
            poisonAuraCoroutine = coroutine.create(function()
                while enabled do
                    local success, err = pcall(function()
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local humanoidRootPart = character.HumanoidRootPart

                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= localPlayer and player.Character then
                                    local playerCharacter = player.Character
                                    local playerTorso = playerCharacter:FindFirstChild("Torso")
                                    if playerTorso then
                                        local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                        if distance <= auraRadius then
                                            local head = playerCharacter:FindFirstChild("Head")
                                            while distance <= auraRadius do
                                                SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                                                distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Size = Vector3.new(1, 3, 1)
                                                    part.Transparency = 1
                                                    part.Position = head.Position
                                                end
                                                wait()
                                                for _, part in pairs(poisonHurtParts) do
                                                    part.Position = Vector3.new(0, -200, 0)
                                                end
                                            end
                                            for _, part in pairs(poisonHurtParts) do
                                                part.Position = Vector3.new(0, -200, 0)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    if not success then
                    end
                    wait(0.02)
                end
            end)
            coroutine.resume(poisonAuraCoroutine)
        elseif poisonAuraCoroutine then
            coroutine.close(poisonAuraCoroutine)
            for _, part in pairs(poisonHurtParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
            poisonAuraCoroutine = nil
        end
    end
})


CharacterTab:AddToggle({
    Name = "しゃがみ速度",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "CrouchSpeed",
    Callback = function(enabled)
        if enabled then
            crouchSpeedCoroutine = coroutine.create(function()
                while true do
                    pcall(function()
                        if not playerCharacter.Humanoid then return end
                        if playerCharacter.Humanoid.WalkSpeed == 5 then
                            playerCharacter.Humanoid.WalkSpeed = crouchWalkSpeed
                        end
                    end)
                    wait()
                end
            end)
            coroutine.resume(crouchSpeedCoroutine)
        elseif crouchSpeedCoroutine then
            coroutine.close(crouchSpeedCoroutine)
            crouchSpeedCoroutine = nil
            if playerCharacter.Humanoid then
                playerCharacter.Humanoid.WalkSpeed = 16
            end
        end
    end
})

CharacterTab:AddSlider({
    Name = "しゃがみ速度設定",
    Min = 6,
    Max = 1000,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = crouchWalkSpeed,
    Save = true,
    Flag = "SetCrouchSpeed",
    Callback = function(value)
        crouchWalkSpeed = value
    end
})

CharacterTab:AddToggle({
    Name = "しゃがみジャンプ力",
    Default = false,
    Save = true,
    Flag = "CrouchJumpPower",
    Color = Color3.fromRGB(240, 0, 0),
    Callback = function(enabled)
        if enabled then
            crouchJumpCoroutine = coroutine.create(function()
                while true do
                    pcall(function()
                        if not playerCharacter.Humanoid then return end
                        if playerCharacter.Humanoid.JumpPower == 12 then
                            playerCharacter.Humanoid.JumpPower = crouchJumpPower
                        end
                    end)
                    wait()
                end
            end)
            coroutine.resume(crouchJumpCoroutine)
        elseif crouchJumpCoroutine then
            coroutine.close(crouchJumpCoroutine)
            crouchJumpCoroutine = nil
            if playerCharacter.Humanoid then
                playerCharacter.Humanoid.JumpPower = 24
            end
        end
    end
})

CharacterTab:AddSlider({
    Name = "しゃがみジャンプ力設定",
    Min = 6,
    Max = 1000,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = crouchJumpPower,
    Save = true,
    Flag = "SetCrouchJumpPower",
    Callback = function(value)
        crouchJumpPower = value
    end
})


FunTab:AddLabel("Clone Manipulation (grab them to keep their NetworkOwnership)")

FunTab:AddSlider({
    Name = "オフセット",
    Min = 1,
    Max = 10,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = ".",
    Increment = 1,
    Default = decoyOffset,
    Callback = function(value)
        decoyOffset = value
    end
})

FunTab:AddTextbox({
    Name = "円の半径",
    Default = "Radius for Surround Mode (Adjust based on clones)",
    TextDisappear = false,
    Callback = function(value)
        circleRadius = tonumber(value) or 10
    end
})

FunTab:AddButton({
    Name = "デコイ追従",
    Callback = function()
        local decoys = {}
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant.Name == "YouDecoy" then
                table.insert(decoys, descendant)
            end
        end
        local numDecoys = #decoys
        local midPoint = math.ceil(numDecoys / 2)

        local function updateDecoyPositions()
            for index, decoy in pairs(decoys) do
                local torso = decoy:FindFirstChild("Torso")
                if torso then
                    local bodyPosition = torso:FindFirstChild("BodyPosition")
                    local bodyGyro = torso:FindFirstChild("BodyGyro")
                    if bodyPosition and bodyGyro then
                        local targetPosition
                        if followMode then
                            if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
                                targetPosition = playerCharacter.HumanoidRootPart.Position
                                local offset = (index - midPoint) * decoyOffset
                                local forward = playerCharacter.HumanoidRootPart.CFrame.LookVector
                                local right = playerCharacter.HumanoidRootPart.CFrame.RightVector
                                targetPosition = targetPosition - forward * decoyOffset + right * offset
                            end
                        else
                            local nearestPlayer = getNearestPlayer()
                            if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local angle = math.rad((index - 1) * (360 / numDecoys))
                                targetPosition = nearestPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.cos(angle) * circleRadius, 0, math.sin(angle) * circleRadius)
                                bodyGyro.CFrame = CFrame.new(torso.Position, nearestPlayer.Character.HumanoidRootPart.Position)
                            end
                        end

                        if targetPosition then
                            local distance = (targetPosition - torso.Position).Magnitude
                            if distance > stopDistance then
                                bodyPosition.Position = targetPosition
                                if followMode then
                                    bodyGyro.CFrame = CFrame.new(torso.Position, targetPosition)
                                end
                            else
                                bodyPosition.Position = torso.Position
                                bodyGyro.CFrame = torso.CFrame
                            end
                        end
                    end
                end
            end
        end

        local function setupDecoy(decoy)
            local torso = decoy:FindFirstChild("Torso")
            if torso then
                local bodyPosition = Instance.new("BodyPosition")
                local bodyGyro = Instance.new("BodyGyro")
                bodyPosition.Parent = torso
                bodyGyro.Parent = torso
                bodyPosition.MaxForce = Vector3.new(40000, 40000, 40000)
                bodyPosition.D = 100
                bodyPosition.P = 100
                bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
                bodyGyro.D = 100
                bodyGyro.P = 20000
                local connection = RunService.Heartbeat:Connect(function()
                    updateDecoyPositions()
                end)
                table.insert(connections, connection)
                SetNetworkOwner:FireServer(torso, playerCharacter.Head.CFrame)
            end
        end

        for _, decoy in pairs(decoys) do
            setupDecoy(decoy)
        end
        OrionLib:MakeNotification({Name = "通知", Content = "Got "..numDecoys.." units. Manually click each unit if they don't move", Image = "rbxassetid://4483345998", Time = 5})
    end
})

FunTab:AddButton({
    Name = "モード切替",
    
    Callback = function()
        followMode = not followMode
    end
})

FunTab:AddButton({
    Name = "クローン切断",
    Callback = cleanupConnections(connections)
})


ScriptTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",true))()
    end
})
ScriptTab:AddButton({
    Name = "Infinite Yield REBORN",
    Callback = function()
        loadstring(game:HttpGet("https://github.com/fuckusfm/infiniteyield-reborn/raw/master/source"))()
    end
})

ScriptTab:AddButton({
    Name = "Dark Dex V3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", true))()
    end
})
local KeybindSection = KeybindsTab:AddSection({Name = "プレイヤー操作キー"})
KeybindSection:AddParagraph("ヒント", "Press while looking at a player")

KeybindSection:AddBind({
    Name = "地獄送り",
    Default = "Z",
    Hold = false,
    Save = true,
    Flag = "SendToHellKeybind",
    Callback = function()
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Part") then
                        part.CanCollide = false
                    end
                end

                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = character.Torso
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.new(0, -4, 0)
                character.Torso.CanCollide = false
                task.wait(1)
                character.Torso.CanCollide = false
            end
        end
    end
})

KeybindSection:AddBind({
    Name = "キック",
    Default = "X",
    Hold = false,
    Save = true,
    Flag = "KickKeybind",
    Callback = function()
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
                if kickMode == 1 then   
                    SetNetworkOwner:FireServer(character.HumanoidRootPart.FirePlayerPart, character.HumanoidRootPart.FirePlayerPart.CFrame)
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Parent = character.HumanoidRootPart.FirePlayerPart
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                elseif kickMode == 2 then
                    SetNetworkOwner:FireServer(character.HumanoidRootPart.FirePlayerPart, character.HumanoidRootPart.FirePlayerPart.CFrame)
                    local platform = Instance.new("Part")
                    platform.Name = "FloatingPlatform"
                    platform.Size = Vector3.new(5, 2, 5)
                    platform.Anchored = true
                    platform.Transparency = 1
                    platform.CanCollide = true
                    platform.Parent = character
                    while character do
                        wait()
                        platform.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
                    end 
                end
            end
        end
    end
})

KeybindSection:AddDropdown({
    Name = "キックモード選択",
    Options = {"Sky", "Silent"},
    Default = "Silent",
    Callback = function(selected)
        if selected == "Sky" then kickMode = 1 else kickMode = 2 end
    end
})

KeybindSection:AddBind({
    Name = "キル（不安定）",
    Default = "C",
    Hold = false,
    Save = true,
    Flag = "KillKeybind",
    Callback = function()
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
                for _, motor in pairs(character.Torso:GetChildren()) do
                    SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
                    if motor:IsA('Motor6D') then motor:Destroy() end
                end
                task.wait(0.5)
                SetNetworkOwner:FireServer(character.Head, character.Head.CFrame)
            end
        end
    end
})

KeybindSection:AddBind({
    Name = "燃やす",
    Default = "V",
    Hold = false,
    Save = true,
    Flag = "BurnKeybind",
    Callback = function()
        local mouse = localPlayer:GetMouse()
        local target = mouse.Target
        if not ownedToys["Campfire"] then 
            OrionLib:MakeNotification({Name = "おもちゃ未所有", Content = "キャンプファイヤーを持っていません", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        if target and target:IsA("BasePart") then
            local character = target.Parent
            if target.Name == "FirePlayerPart" then
                character = target.Parent.Parent
            end
            if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
                if not toysFolder:FindFirstChild("Campfire") then
                    spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
                end
                local campfire = toysFolder.Campfire
                local firePlayerPart
                SetNetworkOwner:FireServer(character.HumanoidRootPart, character.HumanoidRootPart.CFrame)
                for _, part in pairs(campfire:GetChildren()) do
                    if part.Name == "FirePlayerPart" then
                        part.Size = Vector3.new(9, 9, 9)
                        firePlayerPart = part
                        break
                    end
                end
                firePlayerPart.Position = character.Head.Position or character.HumanoidRootPart.Position
                task.wait(0.5)
                firePlayerPart.Position = Vector3.new(0, -50, 0)
            end
        end
    end
})
local KeybindSection2 = KeybindsTab:AddSection({Name = "ミサイル操作キー"})
KeybindSection2:AddParagraph("ヒント", "どこかを押してください")
KeybindSection2:AddBind({
    Name = "爆弾爆発",
    Default = "B",
    Hold = false,
    Save = true,
    Flag = "ExplodeBombKeybind",
    Callback = function()
        if not ownedToys["BombMissile"] then 
            OrionLib:MakeNotification({Name = "おもちゃ未所有", Content = "爆弾ミサイルを持っていません", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "BombMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame)
                        local bomb = child
                        local args = {
                            [1] = {
                                ["範囲"] = 17.5,
                                ["TimeLength"] = 2,
                                ["Hitbox"] = child.PartHitDetector,
                                ["ExplodesByFire"] = false,
                                ["MaxForcePerStudSquared"] = 225,
                                ["Model"] = child,
                                ["ImpactSpeed"] = 100,
                                ["ExplodesByPointy"] = false,
                                ["DestroysModel"] = false,
                                ["PositionPart"] = child.Body
                            },
                            [2] = child.Body.Position
                        }
                        ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))

                    end
                end
            end
        end)
        spawnItemCf("BombMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        wait(1)
        connection:Disconnect()
    end
})
KeybindSection2:AddBind({
    Name = "爆弾投げ",
    Default = "M",
    Hold = false,
    Save = true,
    Flag = "ThrowBombKeybind",
    Callback = function()
        if not ownedToys["BombMissile"] then 
            OrionLib:MakeNotification({Name = "おもちゃ未所有", Content = "爆弾ミサイルを持っていません", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "BombMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
               
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
           
                        connection:Disconnect()

                        SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame)
                        local velocityObj = Instance.new("BodyVelocity", child.PartHitDetector)
                        velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        velocityObj.Velocity = workspace.CurrentCamera.CFrame.lookVector * 500
                        Debris:AddItem(velocityObj, 10)
                    end
                end
            end
        end)
        spawnItemCf("BombMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
    end
})

KeybindSection2:AddBind({
    Name = "花火爆発",
    Default = "N",
    Hold = false,
    Save = true,
    Flag = "ExplodeFireworkKeybind",
    Callback = function()
        if not ownedToys["FireworkMissile"] then 
            OrionLib:MakeNotification({Name = "おもちゃ未所有", Content = "花火ミサイルを持っていません", Image = "rbxassetid://4483345998", Time = 3})
            return
        end
        local connection
        connection = toysFolder.ChildAdded:Connect(function(child)
            if child.Name == "FireworkMissile" then
                if child:WaitForChild("ThisToysNumber", 1) then
                    if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                        connection:Disconnect()
                        
                        SetNetworkOwner:FireServer(child.PartHitDetector, child.PartHitDetector.CFrame)
                        local bomb = child
                        local args = {
                            [1] = {
                                ["範囲"] = 17.5,
                                ["TimeLength"] = 2,
                                ["Hitbox"] = child.PartHitDetector,
                                ["ExplodesByFire"] = false,
                                ["MaxForcePerStudSquared"] = 225,
                                ["Model"] = child,
                                ["ImpactSpeed"] = 100,
                                ["ExplodesByPointy"] = false,
                                ["DestroysModel"] = false,
                                ["PositionPart"] = child.Body
                            },
                            [2] = child.Body.Position
                        }
                        ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))

                    end
                end
            end
        end)
        spawnItemCf("FireworkMissile", playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
        wait(1)
        connection:Disconnect()
    end
})
KeybindSection2:AddParagraph("ヒント", "Hold to reload bombs")

KeybindSection2:AddBind({
    Name = "ミサイル補充",
    Default = "R",
    Hold = true,
    Save = true,
    Flag = "BombCacheReload",
    Callback = function(bool)
        reloadMissile(bool)
    end
})





KeybindSection2:AddBind({
    Name = "保存ミサイル爆発",
    Default = "T",
    Hold = false,
    Save = true,
    Flag = "ExplodeCachedBombKeybind",
    Callback = function()
        if #bombList == 0 then 
            OrionLib:MakeNotification({Name = "爆弾なし", Content = "保存された爆弾がありません", Image = "rbxassetid://4483345998", Time = 2})
            return
        end

        local bomb = table.remove(bombList, 1)

        local args = {
            [1] = {
                ["範囲"] = 17.5,
                ["TimeLength"] = 2,
                ["Hitbox"] = bomb.PartHitDetector,
                ["ExplodesByFire"] = false,
                ["MaxForcePerStudSquared"] = 225,
                ["Model"] = bomb,
                ["ImpactSpeed"] = 100,
                ["ExplodesByPointy"] = false,
                ["DestroysModel"] = false,
                ["PositionPart"] = localPlayer.Character.HumanoidRootPart or localPlayer.Character.PrimaryPart
            },
            [2] = localPlayer.Character.HumanoidRootPart.Position or localPlayer.Character.PrimaryPart.Position
        }
        ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
    end
})
KeybindSection2:AddBind({
    Name = "全保存ミサイル爆発",
    Default = "Y",
    Hold = false,
    Save = true,
    Flag = "ExplodeAllCachedBombsKeybind",
    Callback = function()
        if #bombList == 0 then 
            OrionLib:MakeNotification({Name = "爆弾なし", Content = "保存された爆弾がありません", Image = "rbxassetid://4483345998", Time = 2})
            return
        end
        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
            local args = {
                [1] = {
                    ["範囲"] = 17.5,
                    ["TimeLength"] = 2,
                    ["Hitbox"] = bomb.PartHitDetector,
                    ["ExplodesByFire"] = false,
                    ["MaxForcePerStudSquared"] = 225,
                    ["Model"] = bomb,
                    ["ImpactSpeed"] = 100,
                    ["ExplodesByPointy"] = false,
                    ["DestroysModel"] = false,
                    ["PositionPart"] = localPlayer.Character.HumanoidRootPart or localPlayer.Character.PrimaryPart
                },
                [2] = localPlayer.Character.HumanoidRootPart.Position or localPlayer.Character.PrimaryPart.Position
            }
            ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
        end
    end
})

KeybindSection2:AddBind({
    Name = "最寄りプレイヤーに全ミサイル発射",
    Default = "U",
    Hold = false,
    Save = true,
    Flag = "ExplodeAllCachedBombsOnNearestPlayerKeybind",
    Callback = function()
        if #bombList == 0 then 
            OrionLib:MakeNotification({Name = "爆弾なし", Content = "保存された爆弾がありません", Image = "rbxassetid://4483345998", Time = 2})
            return
        end
        local char = getNearestPlayer().Character
        for i = #bombList, 1, -1 do
            local bomb = table.remove(bombList, i)
            local args = {
                [1] = {
                    ["範囲"] = 17.5,
                    ["TimeLength"] = 2,
                    ["Hitbox"] = bomb.PartHitDetector,
                    ["ExplodesByFire"] = false,
                    ["MaxForcePerStudSquared"] = 225,
                    ["Model"] = bomb,
                    ["ImpactSpeed"] = 100,
                    ["ExplodesByPointy"] = false,
                    ["DestroysModel"] = false,
                    ["PositionPart"] = char.HumanoidRootPart or char.Torso or char.PrimaryPart
                },
                [2] = char.HumanoidRootPart.Position or char.Torso.Position or char.PrimaryPart.Position
            }
            ReplicatedStorage:WaitForChild("BombEvents"):WaitForChild("BombExplode"):FireServer(unpack(args))
        end
    end
})

KeybindSection2:AddToggle({
    Name = "開発用（無視）",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = false,
    Callback = function(enabled)
		if enabled then
			for i, v in pairs(toysFolder:GetChildren()) do
				if v.Name ~= "ToyNumber" then
                    local part
                    if v:FindFirstChild("SoundPart") then
                        part = v.SoundPart
                    elseif v.PrimaryPart then
                        part = v.PrimaryPart
                    else
                        part = v:FindFirstChildWhichIsActive("BasePart")
                    end
					table.insert(lightbitparts, part)
					for _, p in pairs(v:GetDescendants()) do
						if p:IsA("BasePart") then
							p.CanCollide = false
						end
					end
            

					local bodyPosition = Instance.new("BodyPosition")

					bodyPosition.P = 15000
					bodyPosition.D = 200
					bodyPosition.MaxForce = Vector3.new(5000000, 5000000, 5000000)
					bodyPosition.Parent = part
					bodyPosition.Position = part.Position
					table.insert(bodyPositions, bodyPosition)

					local alignOrientation = Instance.new("AlignOrientation")
					alignOrientation.MaxTorque = 400000
					alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
					alignOrientation.Responsiveness = 2000
					alignOrientation.Parent = part
					alignOrientation.PrimaryAxisOnly = false
					table.insert(alignOrientations, alignOrientation)

					local attachment = Instance.new("Attachment")
					attachment.Parent = part
					alignOrientation.Attachment0 = attachment
				end
			end
			lightorbitcon = RunService.Heartbeat:Connect(function()
				if not localPlayer.Character or not localPlayer.Character.HumanoidRootPart then return end
				lightbitoffset = lightbitoffset + lightbit
				lightbitpos = U.GetSurroundingVectors(localPlayer.Character.HumanoidRootPart.Position, usingradius, #lightbitparts, lightbitoffset)

				for i, v in ipairs(lightbitpos) do
					bodyPositions[i].Position = v
					local direction = (localPlayer.Character.HumanoidRootPart.Position - bodyPositions[i].Position).unit
					local lookAtCFrame = CFrame.lookAt(bodyPositions[i].Position, localPlayer.Character.HumanoidRootPart.Position)
					alignOrientations[i].CFrame = lookAtCFrame
				end
			end)
		else
            pcall(function()
                lightorbitcon:Disconnect()
            end)
			
			for i, v in ipairs(lightbitparts) do
				for _, p in pairs(v:GetDescendants()) do
					if p:IsA("BasePart") then
						p.CanCollide = true
					end
				end
			end
			for _, v in ipairs(bodyPositions) do
				v:Destroy()
			end
			bodyPositions = {}
			for _, v in ipairs(alignOrientations) do
				v:Destroy()
			end
			alignOrientations = {}
			for _, v in ipairs(lightbitparts) do
				v:FindFirstChild("Attachment"):Destroy()
			end
			lightbitparts = {}
		end
    end
})


KeybindSection2:AddBind({
    Name = "開発用キー（無効）",
    Default = "K",
    Hold = true,
    Save = true,
    Flag = "LightBitSpeedUpDev",
    Callback = function(isHeld)
        pcall(function()
            lightbitcon:Disconnect()
        end)
		lightbitcon = RunService.Heartbeat:Connect(function()
			if isHeld then
				lightbit = lightbit + 0.025
			else
				if lightbit > 0.3125 then
					lightbit = lightbit - 0.0125
				end
			end
		end)
    end
})
KeybindSection2:AddBind({
    Name = "開発用キー2（無効）",
    Default = "J",
    Hold = true,
    Save = true,
    Flag = "LightBitRadiusUpDev",
    Callback = function(isHeld)
        pcall(function()
            lightbitcon2:Disconnect()
        end)
		lightbitcon2 = RunService.Heartbeat:Connect(function()
			if isHeld then
				usingradius = usingradius + 1
			else 
				if usingradius > lightbitradius then
					usingradius = usingradius - 1
				end
			end
		end)
    end
})

ExplosionTab:AddDropdown({
	Name = "読み込むおもちゃ",
	Default = "BombMissile",
	Options = {"BombMissile", "FireworkMissile"},
	Callback = function(Value)
		_G.ToyToLoad = Value
	end    
})
ExplosionTab:AddSlider({
    Name = "最大ミサイル数",
    Min = 1,
    Max = localPlayer.ToysLimitCap.Value / 10,
    Color = Color3.fromRGB(240, 0, 0),
    ValueName = "発",
    Increment = 1,
    Default = _G.MaxMissiles,
    Save = true,
    Flag = "NaxMissilesSlider",
    Callback = function(value)
        _G.MaxMissiles = value
    end
})

ExplosionTab:AddToggle({
    Name = "自動ミサイル補充",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "AutoReloadBombs",
    Callback = function(enabled)
       reloadMissile(enabled)
    end
})
DevTab:AddLabel("Spawn and eat a banana first!")

DevTab:AddToggle({
    Name = "全員転倒",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            ragdollAllCoroutine = coroutine.create(ragdollAll)
            coroutine.resume(ragdollAllCoroutine)
        else
            if ragdollAllCoroutine then
                coroutine.close(ragdollAllCoroutine)
                ragdollAllCoroutine = nil
            end
        end
    end
})


-- ==============================================
-- AF_Hub V3: ターゲット選択・キル・爆発システム
-- ==============================================
-- =============================
local TargetSystem = {
    TargetList = {},  -- {[UserId] = {Player = player, Name = name, BuggedUntil = tick(), LastRespawn = tick()}}
    AllPlayersMode = false,
    Dropdowns = {}
}

-- すべてのプレイヤー名を取得
local function getAllPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

-- ドロップダウンを更新
local function updateAllDropdowns()
    local names = getAllPlayerNames()
    for _, dropdown in pairs(TargetSystem.Dropdowns) do
        if dropdown and dropdown.Refresh then
            pcall(function()
                dropdown:Refresh(names, true)
            end)
        end
    end
end

-- プレイヤーをターゲットリストに追加
local function addPlayerToTargets(player)
    if player and player ~= localPlayer then
        TargetSystem.TargetList[player.UserId] = {
            Player = player,
            Name = player.Name,
            BuggedUntil = 0,
            LastRespawn = tick()
        }
        return true
    end
    return false
end

-- プレイヤーをターゲットリストから削除
local function removePlayerFromTargets(userId)
    TargetSystem.TargetList[userId] = nil
end

-- ターゲットリストをクリア
local function clearTargetList()
    TargetSystem.TargetList = {}
end

-- プレイヤーがバグ状態かチェック
local function isPlayerBugged(userId)
    local target = TargetSystem.TargetList[userId]
    if target and target.BuggedUntil > tick() then
        return true
    end
    return false
end

-- プレイヤーをバグ状態に設定
local function setPlayerBugged(userId, duration)
    local target = TargetSystem.TargetList[userId]
    if target then
        target.BuggedUntil = tick() + (duration or 5)
    end
end

-- プレイヤーがリスポーンしたか検出
local function detectRespawn(player)
    local target = TargetSystem.TargetList[player.UserId]
    if not target then return false end
    
    local char = player.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    -- リスポーン判定：Healthが100になった、またはキャラクターが再追加された
    if humanoid.Health >= 100 and (tick() - target.LastRespawn) > 2 then
        target.LastRespawn = tick()
        target.BuggedUntil = 0  -- バグ状態をリセット
        return true
    end
    
    return false
end

-- プレイヤーの状態を監視
task.spawn(function()
    while task.wait(1) do
        for userId, target in pairs(TargetSystem.TargetList) do
            if target.Player and target.Player.Parent then
                detectRespawn(target.Player)
            else
                -- プレイヤーが退出した場合は削除
                removePlayerFromTargets(userId)
            end
        end
    end
end)

-- プレイヤーの入退出を監視
Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    updateAllDropdowns()
    
    -- 全員モードの場合は自動追加
    if TargetSystem.AllPlayersMode then
        addPlayerToTargets(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerFromTargets(player.UserId)
    updateAllDropdowns()
end)

-- =============================
-- シグマプレイヤータブ
-- =============================
local V3PlayerTab = Window:MakeTab({Name = "シグマプレイヤー", Icon = "rbxassetid://4483362458", PremiumOnly = false})

V3PlayerTab:AddSection({Name = "移動"})

-- 歩行速度
local hackedWalkSpeed = 16
local walkSpeedConnection = nil

V3PlayerTab:AddSlider({
    Name = "歩行速度",
    Min = 16, Max = 1000,
    Default = 16,
    Increment = 1,
    ValueName = "速度",
    Callback = function(value)
        hackedWalkSpeed = value
        
        if walkSpeedConnection then
            walkSpeedConnection:Disconnect()
        end
        
        local char = localPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
        
        walkSpeedConnection = RunService.Heartbeat:Connect(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = hackedWalkSpeed
            end
        end)
    end
})

-- ジャンプ力
V3PlayerTab:AddSlider({
    Name = "ジャンプ力",
    Min = 50, Max = 500,
    Default = 50,
    Increment = 5,
    ValueName = "パワー",
    Callback = function(value)
        local char = localPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end
})

-- 無限ジャンプ
local infiniteJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = localPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

V3PlayerTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
    end
})

V3PlayerTab:AddSection({Name = "カメラ＆3人称視点"})

-- 3人称視点（ホイールズーム対応）
local thirdPersonEnabled = false
local thirdPersonDistance = 15
local minZoom = 5
local maxZoom = 100

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel and thirdPersonEnabled then
        local delta = input.Position.Z
        thirdPersonDistance = math.clamp(thirdPersonDistance - (delta * 2), minZoom, maxZoom)
        
        if thirdPersonEnabled then
            localPlayer.CameraMaxZoomDistance = thirdPersonDistance
            localPlayer.CameraMinZoomDistance = thirdPersonDistance
        end
    end
end)

V3PlayerTab:AddToggle({
    Name = "3人称視点",
    Default = false,
    Callback = function(value)
        thirdPersonEnabled = value
        if value then
            localPlayer.CameraMode = Enum.CameraMode.Classic
            localPlayer.CameraMaxZoomDistance = thirdPersonDistance
            localPlayer.CameraMinZoomDistance = thirdPersonDistance
            
            OrionLib:MakeNotification({
                Name = "3人称視点有効",
                Content = "マウスホイールでズームイン/アウト！",
                Time = 3
            })
        else
            localPlayer.CameraMaxZoomDistance = 128
            localPlayer.CameraMinZoomDistance = 0.5
        end
    end
})

V3PlayerTab:AddSlider({
    Name = "3人称距離",
    Min = 5, Max = 100,
    Default = 15,
    Increment = 1,
    ValueName = "スタッド",
    Callback = function(value)
        thirdPersonDistance = value
        if thirdPersonEnabled then
            localPlayer.CameraMaxZoomDistance = value
            localPlayer.CameraMinZoomDistance = value
        end
    end
})

-- =============================
-- 戦闘＆キルタブ（完全版）
-- =============================
local CombatTab = Window:MakeTab({Name = "戦闘＆キル", Icon = "rbxassetid://4483362458", PremiumOnly = false})

CombatTab:AddSection({Name = "ターゲット選択"})

-- プレイヤー選択ドロップダウン
local selectedPlayerName = nil
local playerDropdown = CombatTab:AddDropdown({
    Name = "プレイヤーを選択",
    Options = getAllPlayerNames(),
    Default = "",
    Callback = function(option)
        selectedPlayerName = option
    end
})
table.insert(TargetSystem.Dropdowns, playerDropdown)

-- 選択したプレイヤーを追加
CombatTab:AddButton({
    Name = "選択したプレイヤーをターゲットに追加",
    Callback = function()
        if selectedPlayerName then
            local player = Players:FindFirstChild(selectedPlayerName)
            if addPlayerToTargets(player) then
                OrionLib:MakeNotification({
                    Name = "追加成功",
                    Content = selectedPlayerName .. " をターゲットリストに追加しました",
                    Time = 2
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "プレイヤーを選択してください",
                Time = 2
            })
        end
    end
})

-- ターゲットリストをクリア
CombatTab:AddButton({
    Name = "ターゲットリストをクリア",
    Callback = function()
        clearTargetList()
        OrionLib:MakeNotification({
            Name = "クリア完了",
            Content = "ターゲットリストを空にしました",
            Time = 2
        })
    end
})

-- 全員モード
CombatTab:AddToggle({
    Name = "全員をターゲット（自動更新）",
    Default = false,
    Callback = function(value)
        TargetSystem.AllPlayersMode = value
        
        if value then
            -- 全プレイヤーを追加
            for _, player in ipairs(Players:GetPlayers()) do
                addPlayerToTargets(player)
            end
            
            OrionLib:MakeNotification({
                Name = "全員モード有効",
                Content = "全プレイヤーが自動的にターゲットに追加されます",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "全員モード無効",
                Content = "手動でターゲットを管理します",
                Time = 2
            })
        end
    end
})

CombatTab:AddSection({Name = "キル機能"})

-- キルループ（Cosmic Hub方式 - バグ検出・自動リトライ対応）
local killLoopEnabled = false
local killLoopConnection = nil
local killDelay = 0.5

local function attemptKill(targetPlayer)
    if not targetPlayer or targetPlayer == localPlayer then return false end
    
    -- バグ状態チェック
    if isPlayerBugged(targetPlayer.UserId) then
        return false
    end
    
    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    
    local targetHum = targetChar:FindFirstChild("Humanoid")
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    
    if not (targetHum and targetHRP) then return false end
    if targetHum.Health <= 0 then return false end
    
    -- プレイヤーが掴まれているかチェック
    if targetPlayer:FindFirstChild("IsHeld") and targetPlayer.IsHeld.Value == true then
        -- バグ状態に設定
        setPlayerBugged(targetPlayer.UserId, 3)
        return false
    end
    
    local myChar = localPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not myHRP then return false end
    
    -- キル試行
    pcall(function()
        -- TPしてキル
        local originalPos = myHRP.CFrame
        myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        
        task.wait(0.1)
        
        -- ダメージを与える
        targetHum.Health = 0
        
        task.wait(0.1)
        
        -- 元の位置に戻る
        myHRP.CFrame = originalPos
        
        -- バグチェック
        if targetPlayer:FindFirstChild("IsHeld") and targetPlayer.IsHeld.Value == true then
            setPlayerBugged(targetPlayer.UserId, 5)
        end
    end)
    
    return true
end

CombatTab:AddToggle({
    Name = "キルループ（選択したプレイヤー）",
    Default = false,
    Callback = function(value)
        killLoopEnabled = value
        
        if value then
            killLoopConnection = RunService.Heartbeat:Connect(function()
                for userId, target in pairs(TargetSystem.TargetList) do
                    if target.Player and not isPlayerBugged(userId) then
                        attemptKill(target.Player)
                        task.wait(killDelay)
                    end
                end
            end)
            
            OrionLib:MakeNotification({
                Name = "キルループ有効",
                Content = "選択したプレイヤーを継続的にキルします",
                Time = 3
            })
        else
            if killLoopConnection then
                killLoopConnection:Disconnect()
            end
            
            OrionLib:MakeNotification({
                Name = "キルループ無効",
                Content = "停止しました",
                Time = 2
            })
        end
    end
})

CombatTab:AddSlider({
    Name = "キルループ間隔",
    Min = 0.1, Max = 2,
    Default = 0.5,
    Increment = 0.1,
    ValueName = "秒",
    Callback = function(value)
        killDelay = value
    end
})

CombatTab:AddSection({Name = "ブロブマン対策"})

-- ブロブマンキック（選択したプレイヤーのみ - Ftap方式）
local blobKickEnabled = false
local blobKickConnections = {}

local function spawnSnowball(position)
    task.spawn(function()
        if MenuToys then
            local spawnFunc = MenuToys:FindFirstChild("SpawnToyRemoteFunction")
            if spawnFunc then
                pcall(function()
                    spawnFunc:InvokeServer("BallSnowball", CFrame.new(position), Vector3.new())
                end)
            end
        end
    end)
end

local function tpSnowballsToTarget(targetPlayer)
    local toyFolder = Workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
    if not toyFolder then return end
    
    local targetChar = targetPlayer.Character
    local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    for _, toy in ipairs(toyFolder:GetChildren()) do
        if toy:IsA("Model") and toy.Name == "BallSnowball" then
            for _, part in ipairs(toy:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Position = targetHRP.Position
                    end)
                end
            end
        end
    end
end

local function startBlobKick()
    -- 検出ループ
    blobKickConnections.detect = RunService.Heartbeat:Connect(function()
        for userId, target in pairs(TargetSystem.TargetList) do
            if target.Player and target.Player.Character then
                local humanoid = target.Player.Character:FindFirstChildOfClass("Humanoid")
                
                -- ブロブマンに乗っているかチェック
                if humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent.Name == "CreatureBlobman" then
                    -- スノーボールをスポーン
                    local myChar = localPlayer.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        spawnSnowball(myHRP.Position + Vector3.new(0, 2, 0))
                    end
                end
            end
        end
    end)
    
    -- テレポートループ
    blobKickConnections.teleport = RunService.Heartbeat:Connect(function()
        for userId, target in pairs(TargetSystem.TargetList) do
            if target.Player and target.Player.Character then
                local humanoid = target.Player.Character:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent.Name == "CreatureBlobman" then
                    tpSnowballsToTarget(target.Player)
                end
            end
        end
        task.wait(0.1)
    end)
end

local function stopBlobKick()
    for _, conn in pairs(blobKickConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    blobKickConnections = {}
end

CombatTab:AddToggle({
    Name = "ブロブマンキック（選択したプレイヤー）",
    Default = false,
    Callback = function(value)
        blobKickEnabled = value
        
        if value then
            startBlobKick()
            
            OrionLib:MakeNotification({
                Name = "ブロブマンキック有効",
                Content = "選択したプレイヤーがブロブマンに乗ったらキックします",
                Time = 3
            })
        else
            stopBlobKick()
            
            OrionLib:MakeNotification({
                Name = "ブロブマンキック無効",
                Content = "停止しました",
                Time = 2
            })
        end
    end
})

CombatTab:AddSection({Name = "スーパーフリング"})

-- スーパーフリング（Ftap方式完全実装）
local FLING_VELOCITY_NAME = "FlingVelocity"
local superFlingEnabled = true
local flingStrength = 850

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "GrabParts" then
        local success, grabPart = pcall(function()
            return child:WaitForChild("GrabPart", 2):WaitForChild("WeldConstraint", 2).Part1
        end)
        
        if not success or not grabPart then
            return
        end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = FLING_VELOCITY_NAME
        bodyVelocity.Parent = grabPart
        
        local connection
        connection = child:GetPropertyChangedSignal("Parent"):Connect(function()
            if child.Parent == nil then
                if superFlingEnabled then
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Workspace.CurrentCamera.CFrame.LookVector * flingStrength
                    Debris:AddItem(bodyVelocity, 1)
                else
                    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
                    Debris:AddItem(bodyVelocity, 1)
                end
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end
end)

-- ==============================================
-- AF_Hub V3: 戦闘/キル/爆発タブ
-- ==============================================

CombatTab:AddToggle({
    Name = "スーパーフリング",
    Default = true,
    Callback = function(value)
        superFlingEnabled = value
    end
})

CombatTab:AddSlider({
    Name = "フリング強度",
    Min = 100, Max = 2000,
    Default = 850,
    Increment = 50,
    ValueName = "パワー",
    Callback = function(value)
        flingStrength = value
    end
})

-- 通知
OrionLib:MakeNotification({
    Name = "AF.Hub 究極完全版 V3.0",
    Content = "全機能準備完了！プレイヤー選択・バグ検出・自動リトライ対応",
    Time = 5
})

-- =============================
-- 爆発タブ
-- =============================
local V3ExplosionTab = Window:MakeTab({Name = "爆発", Icon = "rbxassetid://4483362458", PremiumOnly = false})

-- おもちゃの所有状態を取得
pcall(function()
    local toysFolder = localPlayer:WaitForChild("PlayerGui", 2):WaitForChild("MenuGui", 2):WaitForChild("Menu", 2):WaitForChild("TabContents", 2):WaitForChild("Toys", 2):WaitForChild("Contents", 2)
    for _, toy in pairs(toysFolder:GetChildren()) do
        if toy.Name ~= "UIGridLayout" then
            ownedToys[toy.Name] = true
        end
    end
end)

-- おもちゃフォルダを取得
local toyFolder = Workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
if not toyFolder then
    local success, result = pcall(function()
        return Workspace:WaitForChild(localPlayer.Name .. "SpawnedInToys", 5)
    end)
    if success and result then
        toyFolder = result
    else
        toyFolder = Instance.new("Folder")
        toyFolder.Name = "DummyToyFolder"
    end
end

-- おもちゃをスポーンする関数
local function spawnToy(toyName, cframe)
    task.spawn(function()
        if MenuToys then
            local spawnFunc = MenuToys:FindFirstChild("SpawnToyRemoteFunction")
            if spawnFunc then
                pcall(function()
                    spawnFunc:InvokeServer(toyName, cframe, Vector3.new(0, 0, 0))
                end)
            end
        end
    end)
end

-- 最寄りのプレイヤーを取得
local function getNearestPlayer()
    local nearestDist = math.huge
    local nearestPlayer = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = localPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local dist = (myHRP.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestPlayer = player
                    nearestDist = dist
                end
            end
        end
    end
    
    return nearestPlayer
end

V3ExplosionTab:AddSection({Name = "爆弾機能"})

-- 爆弾爆発（Bキー）
V3ExplosionTab:AddBind({
    Name = "爆弾爆発",
    Default = "B",
    Hold = false,
    Callback = function()
        if ownedToys.BombMissile then
            local myChar = localPlayer.Character
            if not myChar then return end
            
            local headCFrame = myChar:FindFirstChild("Head") and myChar.Head.CFrame or myChar.HumanoidRootPart.CFrame
            
            local bombSpawned = false
            local connection = toyFolder.ChildAdded:Connect(function(toy)
                if toy.Name == "BombMissile" and not bombSpawned then
                    bombSpawned = true
                    task.wait(0.1)
                    
                    local hitDetector = toy:FindFirstChild("PartHitDetector")
                    if hitDetector and SetNetworkOwner then
                        SetNetworkOwner:FireServer(hitDetector, hitDetector.CFrame)
                    end
                    
                    if ReplicatedStorage:FindFirstChild("BombEvents") then
                        local bombExplode = ReplicatedStorage.BombEvents:FindFirstChild("BombExplode")
                        if bombExplode then
                            local args = {
                                {
                                    Radius = 17.5,
                                    TimeLength = 2,
                                    Hitbox = hitDetector,
                                    ExplodesByFire = false,
                                    MaxForcePerStudSquared = 225,
                                    Model = toy,
                                    ImpactSpeed = 100,
                                    ExplodesByPointy = false,
                                    DestroysModel = false,
                                    PositionPart = toy.Body
                                },
                                toy.Body.Position
                            }
                            bombExplode:FireServer(unpack(args))
                        end
                    end
                end
            end)
            
            spawnToy("BombMissile", headCFrame)
            
            task.delay(2, function()
                connection:Disconnect()
            end)
        else
            OrionLib:MakeNotification({
                Name = "おもちゃなし",
                Content = "爆弾ミサイルおもちゃを所有していません",
                Time = 2
            })
        end
    end
})

-- 爆弾投げる（Cキー）
V3ExplosionTab:AddBind({
    Name = "爆弾投げる",
    Default = "C",
    Hold = false,
    Callback = function()
        if ownedToys.BombMissile then
            local myChar = localPlayer.Character
            if not myChar then return end
            
            local headCFrame = myChar:FindFirstChild("Head") and myChar.Head.CFrame or myChar.HumanoidRootPart.CFrame
            
            local bombSpawned = false
            local connection = toyFolder.ChildAdded:Connect(function(toy)
                if toy.Name == "BombMissile" and not bombSpawned then
                    bombSpawned = true
                    task.wait(0.1)
                    
                    local hitDetector = toy:FindFirstChild("PartHitDetector")
                    if hitDetector then
                        if SetNetworkOwner then
                            SetNetworkOwner:FireServer(hitDetector, hitDetector.CFrame)
                        end
                        
                        local bodyVelocity = Instance.new("BodyVelocity", hitDetector)
                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyVelocity.Velocity = Workspace.CurrentCamera.CFrame.LookVector * 500
                        Debris:AddItem(bodyVelocity, 10)
                    end
                end
            end)
            
            spawnToy("BombMissile", headCFrame)
            
            task.delay(2, function()
                connection:Disconnect()
            end)
        else
            OrionLib:MakeNotification({
                Name = "おもちゃなし",
                Content = "爆弾ミサイルおもちゃを所有していません",
                Time = 2
            })
        end
    end
})

-- 花火爆発（Nキー）
V3ExplosionTab:AddBind({
    Name = "花火爆発",
    Default = "N",
    Hold = false,
    Callback = function()
        if ownedToys.FireworkMissile then
            local myChar = localPlayer.Character
            if not myChar then return end
            
            local headCFrame = myChar:FindFirstChild("Head") and myChar.Head.CFrame or myChar.HumanoidRootPart.CFrame
            
            local fireworkSpawned = false
            local connection = toyFolder.ChildAdded:Connect(function(toy)
                if toy.Name == "FireworkMissile" and not fireworkSpawned then
                    fireworkSpawned = true
                    task.wait(0.1)
                    
                    local hitDetector = toy:FindFirstChild("PartHitDetector")
                    if hitDetector and SetNetworkOwner then
                        SetNetworkOwner:FireServer(hitDetector, hitDetector.CFrame)
                    end
                    
                    if ReplicatedStorage:FindFirstChild("BombEvents") then
                        local bombExplode = ReplicatedStorage.BombEvents:FindFirstChild("BombExplode")
                        if bombExplode then
                            local args = {
                                {
                                    Radius = 17.5,
                                    TimeLength = 2,
                                    Hitbox = hitDetector,
                                    ExplodesByFire = false,
                                    MaxForcePerStudSquared = 225,
                                    Model = toy,
                                    ImpactSpeed = 100,
                                    ExplodesByPointy = false,
                                    DestroysModel = false,
                                    PositionPart = toy.Body
                                },
                                toy.Body.Position
                            }
                            bombExplode:FireServer(unpack(args))
                        end
                    end
                end
            end)
            
            spawnToy("FireworkMissile", headCFrame)
            
            task.delay(2, function()
                connection:Disconnect()
            end)
        else
            OrionLib:MakeNotification({
                Name = "おもちゃなし",
                Content = "花火ミサイルおもちゃを所有していません",
                Time = 2
            })
        end
    end
})

V3ExplosionTab:AddSection({Name = "ミサイルキャッシュ"})

-- ミサイルキャッシュリロード（Qキー長押し）
local cacheReloadActive = false
local cacheReloadCoroutine = nil

V3ExplosionTab:AddBind({
    Name = "ミサイルキャッシュリロード",
    Default = "Q",
    Hold = true,
    Callback = function(isHolding)
        if isHolding then
            if not ownedToys[_G.ToyToLoad] then
                OrionLib:MakeNotification({
                    Name = "おもちゃなし",
                    Content = _G.ToyToLoad .. " を所有していません",
                    Time = 2
                })
                return
            end
            
            cacheReloadActive = true
            
            cacheReloadCoroutine = coroutine.create(function()
                local connection = toyFolder.ChildAdded:Connect(function(toy)
                    if toy.Name == _G.ToyToLoad then
                        task.wait(0.1)
                        
                        if SetNetworkOwner and toy:FindFirstChild("Body") then
                            SetNetworkOwner:FireServer(toy.Body, toy.Body.CFrame)
                        end
                        
                        -- ミサイルを固定位置に移動
                        for _, part in pairs(toy:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        
                        toy:SetPrimaryPartCFrame(CFrame.new(-72.9304581, -3.96906614, -265.543732))
                        task.wait(0.2)
                        
                        for _, part in pairs(toy:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        
                        table.insert(bombList, toy)
                        
                        toy.AncestryChanged:Connect(function()
                            if not toy.Parent then
                                for i, cached in ipairs(bombList) do
                                    if cached == toy then
                                        table.remove(bombList, i)
                                        break
                                    end
                                end
                            end
                        end)
                    end
                end)
                
                while cacheReloadActive do
                    local canSpawn = localPlayer:FindFirstChild("CanSpawnToy")
                    local myChar = localPlayer.Character
                    if canSpawn and canSpawn.Value and #bombList < _G.MaxMissiles and myChar and myChar:FindFirstChild("Head") then
                        spawnToy(_G.ToyToLoad, myChar.Head.CFrame or myChar.HumanoidRootPart.CFrame)
                    end
                    RunService.Heartbeat:Wait()
                end
                
                connection:Disconnect()
            end)
            
            coroutine.resume(cacheReloadCoroutine)
        else
            cacheReloadActive = false
            if cacheReloadCoroutine then
                coroutine.close(cacheReloadCoroutine)
                cacheReloadCoroutine = nil
            end
        end
    end
})

-- キャッシュミサイル爆発（Tキー）
V3ExplosionTab:AddBind({
    Name = "キャッシュミサイル爆発",
    Default = "T",
    Hold = false,
    Callback = function()
        if #bombList > 0 then
            local bomb = table.remove(bombList, 1)
            local myChar = localPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHRP and ReplicatedStorage:FindFirstChild("BombEvents") then
                local bombExplode = ReplicatedStorage.BombEvents:FindFirstChild("BombExplode")
                if bombExplode then
                    local args = {
                        {
                            Radius = 17.5,
                            TimeLength = 2,
                            Hitbox = bomb.PartHitDetector,
                            ExplodesByFire = false,
                            MaxForcePerStudSquared = 225,
                            Model = bomb,
                            ImpactSpeed = 100,
                            ExplodesByPointy = false,
                            DestroysModel = false,
                            PositionPart = myHRP
                        },
                        myHRP.Position
                    }
                    bombExplode:FireServer(unpack(args))
                end
            end
        else
            OrionLib:MakeNotification({
                Name = "爆弾なし",
                Content = "キャッシュに爆弾がありません",
                Time = 2
            })
        end
    end
})

-- 全キャッシュミサイル爆発（Yキー）
V3ExplosionTab:AddBind({
    Name = "全キャッシュミサイル爆発",
    Default = "Y",
    Hold = false,
    Callback = function()
        if #bombList > 0 then
            local myChar = localPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHRP and ReplicatedStorage:FindFirstChild("BombEvents") then
                local bombExplode = ReplicatedStorage.BombEvents:FindFirstChild("BombExplode")
                if bombExplode then
                    for i = #bombList, 1, -1 do
                        local bomb = table.remove(bombList, i)
                        local args = {
                            {
                                Radius = 17.5,
                                TimeLength = 2,
                                Hitbox = bomb.PartHitDetector,
                                ExplodesByFire = false,
                                MaxForcePerStudSquared = 225,
                                Model = bomb,
                                ImpactSpeed = 100,
                                ExplodesByPointy = false,
                                DestroysModel = false,
                                PositionPart = myHRP
                            },
                            myHRP.Position
                        }
                        bombExplode:FireServer(unpack(args))
                    end
                end
            end
        else
            OrionLib:MakeNotification({
                Name = "爆弾なし",
                Content = "キャッシュに爆弾がありません",
                Time = 2
            })
        end
    end
})

-- 最寄りプレイヤーに全ミサイル爆発（Uキー）
V3ExplosionTab:AddBind({
    Name = "最寄りプレイヤーに全ミサイル爆発",
    Default = "U",
    Hold = false,
    Callback = function()
        if #bombList > 0 then
            local nearest = getNearestPlayer()
            if nearest and nearest.Character then
                local targetHRP = nearest.Character:FindFirstChild("HumanoidRootPart")
                
                if targetHRP and ReplicatedStorage:FindFirstChild("BombEvents") then
                    local bombExplode = ReplicatedStorage.BombEvents:FindFirstChild("BombExplode")
                    if bombExplode then
                        for i = #bombList, 1, -1 do
                            local bomb = table.remove(bombList, i)
                            local args = {
                                {
                                    Radius = 17.5,
                                    TimeLength = 2,
                                    Hitbox = bomb.PartHitDetector,
                                    ExplodesByFire = false,
                                    MaxForcePerStudSquared = 225,
                                    Model = bomb,
                                    ImpactSpeed = 100,
                                    ExplodesByPointy = false,
                                    DestroysModel = false,
                                    PositionPart = targetHRP
                                },
                                targetHRP.Position
                            }
                            bombExplode:FireServer(unpack(args))
                        end
                    end
                end
            else
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "最寄りのプレイヤーが見つかりません",
                    Time = 2
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "爆弾なし",
                Content = "キャッシュに爆弾がありません",
                Time = 2
            })
        end
    end
})

V3ExplosionTab:AddSection({Name = "設定"})

V3ExplosionTab:AddDropdown({
    Name = "読み込むおもちゃ",
    Options = {"BombMissile", "FireworkMissile"},
    Default = "BombMissile",
    Callback = function(option)
        _G.ToyToLoad = option
    end
})

V3ExplosionTab:AddSlider({
    Name = "ミサイル数",
    Min = 1, Max = 50,
    Default = 9,
    Increment = 1,
    ValueName = "ミサイル",
    Callback = function(value)
        _G.MaxMissiles = value
    end
})

-- 最終通知
OrionLib:MakeNotification({
    Name = "完全統合完了",
    Content = "全機能準備完了！",
    Time = 3
})


-- ==============================================
-- V2固有機能: Fun Toys / Misc
-- ==============================================
local V2FunTab = Window:MakeTab({Name = "おもちゃ遊び", Icon = "rbxassetid://4483362458", PremiumOnly = false})

V2FunTab:AddButton({
    Name = "無重力モード (0キーでON/OFF)",
    Callback = function()
        game.Workspace.Gravity = 0
        local gravityActive = true
        local function disableGravity(part)
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            end
            for _, child in ipairs(part:GetChildren()) do
                disableGravity(child)
            end
        end
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Zero then
                gravityActive = not gravityActive
                if gravityActive then
                    game.Workspace.Gravity = 0
                    for _, v in ipairs(game.Workspace:GetDescendants()) do disableGravity(v) end
                else
                    game.Workspace.Gravity = 196.2
                end
            end
        end)
        OrionLib:MakeNotification({Name = "無重力", Content = "0キーでON/OFF切替", Time = 3})
    end
})

V2FunTab:AddButton({
    Name = "近くのオブジェクトを浮かす (Qキー)",
    Callback = function()
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Q then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        local bf = Instance.new("BodyForce")
                        bf.Force = Vector3.new(0, 2000, 0)
                        bf.Parent = v
                    end
                end
            end
        end)
        OrionLib:MakeNotification({Name = "浮遊", Content = "Qキーで周囲を浮かす", Time = 3})
    end
})

V2FunTab:AddButton({
    Name = "NPCを上に飛ばす (Jキー)",
    Callback = function()
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode.J then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.PrimaryPart then
                        v.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame + Vector3.new(0, 20, 0)
                    end
                end
            end
        end)
        OrionLib:MakeNotification({Name = "NPC飛ばし", Content = "Jキーで実行", Time = 3})
    end
})

V2FunTab:AddButton({
    Name = "マップ破壊 (5秒待機)",
    Callback = function()
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and not v:FindFirstChild("Humanoid") then
                v:BreakJoints()
                v:MoveTo(Vector3.new(math.random(-100,100), math.random(50,150), math.random(-100,100)))
            end
        end
        OrionLib:MakeNotification({Name = "マップ破壊", Content = "マップを破壊しました", Time = 3})
    end
})

V2FunTab:AddButton({
    Name = "リジョイン",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, localPlayer)
        end)
    end
})

-- Sigma Misc
local V2MiscTab = Window:MakeTab({Name = "その他", Icon = "rbxassetid://4483362458", PremiumOnly = false})

V2MiscTab:AddButton({
    Name = "FOVをデフォルトに戻す",
    Callback = function()
        workspace.CurrentCamera.FieldOfView = 80
    end
})

V2MiscTab:AddSlider({
    Name = "FOV変更",
    Min = 10,
    Max = 120,
    Default = 80,
    Increment = 1,
    ValueName = "度",
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})
OrionLib:Init()


print("ToyHub Integrated - Loaded Successfully")

