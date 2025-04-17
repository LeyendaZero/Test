warn("Loaded Turret Auto Aim (Mobile Button Toggle)")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local BulletSpeed = 800
local AimbotEnabled = false

-- Crear botón en pantalla
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "AimbotToggleUI"

local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 100, 0, 40)
Button.Position = UDim2.new(0, 10, 0.85, 0)
Button.Text = "Aimbot OFF"
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextScaled = true
Button.BorderSizePixel = 0
Button.BackgroundTransparency = 0.2
Button.ZIndex = 10

Button.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	Button.Text = AimbotEnabled and "Aimbot ON" or "Aimbot OFF"
end)

-- Función para detectar al enemigo más cercano
local function getClosestEnemy()
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	local myPos = myChar.HumanoidRootPart.Position

	local closest, shortestDistance = nil, math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
			local char = player.Character
			if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					local dist = (char.Head.Position - myPos).Magnitude
					if dist < shortestDistance then
						closest = player
						shortestDistance = dist
					end
				end
			end
		end
	end

	return closest
end

-- Predicción de disparo
local function getTravelTime(targetPosition)
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return 0 end
	local origin = char.HumanoidRootPart.Position
	local distance = (targetPosition - origin).Magnitude
	return distance / BulletSpeed
end

local function predictPosition(part, travelTime)
	local velocity = part and part.Velocity or Vector3.zero
	return part.Position + velocity * travelTime
end

-- Loop principal del aimbot
RunService.Heartbeat:Connect(function()
	if not AimbotEnabled then return end

	local target = getClosestEnemy()
	if target and target.Character then
		local head = target.Character:FindFirstChild("Head")
		if head then
			local travelTime = getTravelTime(head.Position)
			local predictedPosition = predictPosition(head, travelTime)
			ReplicatedStorage:WaitForChild("Event"):FireServer("aim", {predictedPosition})
		end
	end
end)
