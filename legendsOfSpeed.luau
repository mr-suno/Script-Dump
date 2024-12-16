-- Requires: `firetouchinterest` support on your executor

-- Written on 12/16/2024
-- This file will not be maintained

--[[

  Features:

  - Auto Collect Orbs
  - Auto Collect Gems
  - Auto Rebirth
  - Auto Collect Hoops

]]

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart")

local orbs = workspace:FindFirstChild("orbFolder")
local hoops = workspace:FindFirstChild("Hoops")

if rootPart and orbs then
	task.spawn(function()
		while task.wait(1) do
			local args = {
			    [1] = "rebirthRequest"
			}
			
			game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("rebirthEvent"):FireServer(unpack(args))		
		end
	end)

	while task.wait() do
		for index, orb in pairs(orbs:GetDescendants()) do
			if orb.Name == "outerOrb" or orb.Name == "outerGem" then
				firetouchinterest(rootPart, orb, 0)
				firetouchinterest(rootPart, orb, 1)
			end
		end
		
		for index, hoop in pairs(hoops:GetChildren()) do
			firetouchinterest(rootPart, hoop, 0)
			firetouchinterest(rootPart, hoop, 1)
		end
	end
end
