local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local BulletSpeed = 800
local AimbotEnabled = false

-- Crear GUI y botón
local gui = Instance.new("ScreenGui")
gui.Name = "AimbotUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 50)
button.Position = UDim2.new(0, 20, 1, -70)
button.Text = "Aimbot OFF"
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Parent = gui

button.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	button.Text = AimbotEnabled and "Aimbot ON" or "Aimbot OFF"
end)

-- Funciones auxiliares
local function getClosestEnemy()
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	local myPos = myChar.HumanoidRootPart.Position
	local closest, dist = nil, math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("Head") then
			local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local d = (plr.Character.Head.Position - myPos).Magnitude
				if d < dist then
					closest = plr
					dist = d
				end
			end
		end
	end

	return closest
end

local function predict(part, t)
	if not part then return Vector3.zero end
	return part.Position + part.Velocity * t
end

local function travelTime(toPos)
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return 0 end
	local dist = (toPos - root.Position).Magnitude
	return dist / BulletSpeed
end

-- Loop principal
RunService.Heartbeat:Connect(function()
	if not AimbotEnabled then return end
	local target = getClosestEnemy()
	if target and target.Character then
		local head = target.Character:FindFirstChild("Head")
		if head then
			local t = travelTime(head.Position)
			local predicted = predict(head, t)
			ReplicatedStorage:WaitForChild("Event"):FireServer("aim", {predicted})
		end
	end
end)
