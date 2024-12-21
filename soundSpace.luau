---@diagnostic disable: undefined-global

local workspace = game:GetService("Workspace")
local teleport = game:GetService("TeleportService")
local players = game:GetService("Players")

local localPlayer = players.LocalPlayer

local function notify(text: string, duration: number)
	task.spawn(function()
		local message = Instance.new("Message")
		
		message.Parent = workspace
		message.Text = text
		
		task.wait(duration)
		
		message:Destroy()
	end)
end

if getgenv().MrBot then
	local placeId = game.PlaceId

	queue_on_teleport(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/mr-suno/Script-Dump/refs/heads/main/soundSpace.luau"))()
	end)

	notify("Mr. Boot has already been loaded,\n\nrejoining the game and relaunching Mr. Bot", 3)

	task.wait(2)

	teleport:Teleport(placeId, localPlayer)
end
getgenv().MrBot = true

if not game.PlaceId == 2677609345 then
	notify("You must be in Sound Space to use this script", 4)
else
	local version = 1
	
	local client: Folder = workspace:FindFirstChild("Client")
	local game: Folder = client:FindFirstChild("Game")
	
	local function move(x: number, y: number)
		mousemoverel(x, y)
	end
	
	local function findCursor()
		local game: Folder = client:FindFirstChild("Game")
		local cursor = nil
		
		if game then
			for index, pair in pairs(game:GetChildren()) do
				if pair:IsA("Part") and #pair:GetChildren() == 0 then
					cursor = pair
				end
			end
		end
		
		return cursor
	end

	local function closeMap()
		keypress(0x52) do
			task.wait(3)
		end
		
		keyrelease(0x52)
	end

	local function findCubes()
		local game: Folder = client:FindFirstChild("Game")
		
		local closestCube = nil
		local shortestDistance = math.huge
		
		if game then
			for index, block in pairs(game:GetChildren()) do
				if block:IsA("Part") and block.Name == "Cube_Mesh" then
					local cursor = findCursor()
					local distance = (block.Position - cursor.Position).Magnitude
					
					if distance < shortestDistance then
						shortestDistance = distance
						closestCube = block
					end
				end
			end
		end
		
		return closestCube
	end
	
	--[[
		 _______________________________________________________________________
		|																	                                      |
		|  [1]: X = 2, Y = 5   ||	[2]: X = 0, Y = 5   ||  [3]: X = -2, Y = 5    |
		| 																                                      |
		|  [4]: X = 2, Y = 3   ||	[5]: X = 0, Y = 3   ||  [6]: X = -2, Y = 3    |
		| 																                                      |
		|  [7]: X = 2, Y = 1   ||	[8]: X = 0, Y = 1   ||  [9]: X = -2, Y = 1    |
		|_______________________________________________________________________|
		
	--]]
	
	local function format(inputNode)
		if (typeof(inputNode) ~= "table") then print("i don't wanna dump a " .. typeof(inputNode) .. "~") end
		
		local nodeCache, nodeStack, outputTable = {},{},{}
		local nodeDepth = 1
		local outputString = "{"
		
		while true do
			local nodeSize = 0
			
			for currentKey, currentValue in pairs(inputNode) do
				nodeSize = nodeSize + 1
			end
			
			local currentIndex = 1
			for currentKey, currentValue in pairs(inputNode) do
				if (nodeCache[inputNode] == nil) or (currentIndex >= nodeCache[inputNode]) then
					if (string.find(outputString,"}",outputString:len())) then
						outputString = outputString .. ","
					end
					
					if type(currentKey) == "number" and currentKey == currentIndex then
						if (type(currentValue) == "number" or type(currentValue) == "boolean") then
							outputString = outputString .. tostring(currentValue)
						elseif (type(currentValue) == "string") then
							outputString = outputString .. "'" .. tostring(currentValue) .. "'"
						elseif (type(currentValue) == "table") then
							outputString = outputString .. format(currentValue)
						end
					else
						local formattedKey
						if (type(currentKey) == "number" or type(currentKey) == "boolean") then
							formattedKey = "[" .. tostring(currentKey) .. "]"
						else
							formattedKey = "['" .. tostring(currentKey) .. "']"
						end
						
						if (type(currentValue) == "number" or type(currentValue) == "boolean") then
							outputString = outputString .. formattedKey .. " = " .. tostring(currentValue)
						elseif (type(currentValue) == "string") then
							outputString = outputString .. formattedKey .. " = '" .. tostring(currentValue) .. "'"
						elseif (type(currentValue) == "table") then
							outputString = outputString .. formattedKey .. " = " .. format(currentValue)
						end
					end
					
					if (currentIndex < nodeSize) then
						outputString = outputString .. ","
					end
				end
				
				currentIndex = currentIndex + 1
			end
			
			outputString = outputString .. "}"
			
			break
		end
		
		return outputString
	end
	
	local function moveToGridSpace(point)
		move(999, 999)
		
		task.wait(math.random(0.05, 0.08))
		point = format(point)
		
		if point == "{2,5}" then
			move(-999, -999)
		elseif point == "{0,5}" then
			move(-420, -999)
		elseif point == "{-2,5}" then
			move(999, -999)
		elseif point == "{2,3}" then
			move(-999, -420)
		elseif point == "{0,3}" then
			move(-420, -420)
		elseif point == "{-2,3}" then
			move(999, -420)
		elseif point == "{2,1}" then
			move(-999, 999)
		elseif point == "{0,1}" then
			move(-420, 999)
		elseif point == "{-2,1}" then
			move(999, 999)
		else
			return
		end
	end

	local hasMovedToGridSpace = false
	local nextCube = nil
	
	task.spawn(function()
		while task.wait() do
			local game: Folder = client:FindFirstChild("Game")

			if game then
				local spectators: TextLabel = game:FindFirstChild("Spectators"):FindFirstChild("SurfaceGui"):FindFirstChild("TitleLabel")
				local text = spectators.Text

				if text ~= "SPECTATORS [0]" then
					closeMap()
				end

				local currentCube = findCubes()

				if currentCube == nextCube then
					continue
				end
				
				if currentCube and not hasMovedToGridSpace then
					print(currentCube)
					print(hasMovedToGridSpace)

					local position = {currentCube.Position.Z, currentCube.Position.Y}

					moveToGridSpace(position)
					hasMovedToGridSpace = true
					
					local destroyConnection
					destroyConnection = currentCube.Destroying:Connect(function()
						hasMovedToGridSpace = false
						currentCube = nextCube
						destroyConnection:Disconnect()
					end)
				end
			end
		end
	end)
	
	notify(`Mr. Bot has loaded (Auto Player) -> Version {version}\n\nfrick you Sound Space for banning me`, 3)
end
