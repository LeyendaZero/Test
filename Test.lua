warn("Loaded Turret Auto Aim (Headshot)")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local BulletVelocity = 800

local function getClosestEnemy()
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local myPos = character.HumanoidRootPart.Position
	local closestPlayer, shortestDistance = nil, math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
			local enemyChar = player.Character
			if enemyChar and enemyChar:FindFirstChild("Head") and enemyChar:FindFirstChild("HumanoidRootPart") then
				local distance = (enemyChar.Head.Position - myPos).Magnitude
				local humanoid = enemyChar:FindFirstChildOfClass("Humanoid")
				if distance < shortestDistance and humanoid and humanoid.Health > 0 then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end

local function predictPosition(part, time)
	local velocity = part and part.Velocity or Vector3.zero
	return part.Position + velocity * time
end

local function getTimeToTarget(targetPos)
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return 0 end
	local origin = character.HumanoidRootPart.Position
	local distance = (targetPos - origin).Magnitude
	return distance / BulletVelocity
end

game:GetService("RunService").Heartbeat:Connect(function()
	local target = getClosestEnemy()
	if target and target.Character then
		local head = target.Character:FindFirstChild("Head")
		local hrp = target.Character:FindFirstChild("HumanoidRootPart")
		if head and hrp then
			local timeToTarget = getTimeToTarget(head.Position)
			local predictedHeadPos = predictPosition(head, timeToTarget)
			game:GetService("ReplicatedStorage"):WaitForChild("Event"):FireServer("aim", {predictedHeadPos})
		end
	end
end)
