local Knit = require(game:GetService('ReplicatedStorage').Packages.Knit)
local RemoteService = Knit.CreateService { Name = script.Name, Client = {} }

local Remote = game:GetService("ReplicatedStorage").Remote

local Remotes = {}
local RemoteFunctions = {}
local PlayerKeys = {}

local function simpleHash(input)
	local hash = ""
	repeat
		input = input .. tostring(math.random(1,10000000))
		local chars = "-0"
		local charsLength = #chars
		hash = ""
		local seed = 0
		for i = 1, #input do
			seed = seed + string.byte(input, i) * i
		end
		math.randomseed(seed)
		for _ = 1, 20 do
			local index = math.random(1, charsLength)
			hash = hash .. string.sub(chars, index, index)
		end
		local unique = true
		for i, v in pairs(Remotes) do
			if i == hash then
				unique = false
			end
		end
	until unique
	return hash
end



function simpleKey()
	local charset = "-0"
	local randomString = ""

	for i = 1, 20 do
		local randomIndex = math.random(1, #charset)
		randomString = randomString .. string.sub(charset, randomIndex, randomIndex)
	end

	return randomString
end



function UnZipKey(RemoteZip,PlayerKey)
	local newKey = ""

	for i = 1, #RemoteZip do
		local RemoteChar = RemoteZip:sub(i, i)
		local PlayerChar = PlayerKey:sub(i, i)
		newKey = newKey .. (PlayerChar == "0" and (RemoteChar == "-" and "0" or "-") or RemoteChar)

	end
	return newKey
end



function RemoteService:FireClient(Player,RemoteName,Data)
	Remote:FireClient(Player,RemoteName,Data)
end

function RemoteService:OnServerEvent(RemoteName,Func)
	local RemoteKey = simpleHash(RemoteName)
	local Template = {
		key = RemoteKey,
		players = {},
	}
	RemoteFunctions[RemoteKey] = Func
	Remotes[RemoteName] = Template
end



local function OnServerEvent(Player,RemoteZip,Data)
	local BanService = Knit.GetService("BanService")
	if typeof(RemoteZip) ~= "string" then
		BanService:Ban(Player,"DONT EXPLOID PLZ")
	end
	if #RemoteZip ~= 20 then
		BanService:Ban(Player,"DONT EXPLOID PLZ")
	end
	
	
	local KeyPos = PlayerKeys[Player.UserId]["keyPos"]
	local PlayerKey = PlayerKeys[Player.UserId]["keys"][KeyPos]
	local RemoteKey = UnZipKey(RemoteZip,PlayerKey)
	
	PlayerKeys[Player.UserId]["keyPos"]+=1
	if PlayerKeys[Player.UserId]["keyPos"] > #PlayerKeys[Player.UserId]["keys"] then
		PlayerKeys[Player.UserId]["keyPos"] = 1
	end
	
	if not RemoteFunctions[RemoteKey] then
		BanService:Ban(Player,"Noob")
	end
	
	RemoteFunctions[RemoteKey](Player,Data)
end



function RemoteService.Client:FireServerFunc(Player,RemoteZip,Data)
	local BanService = Knit.GetService("BanService")
	if typeof(RemoteZip) ~= "string" then
		BanService:Ban(Player,"DONT EXPLOID PLZ")
	end
	if #RemoteZip ~= 20 then
		BanService:Ban(Player,"DONT EXPLOID PLZ")
	end
	
	local KeyPos = PlayerKeys[Player.UserId]["keyPosFunc"]
	local PlayerKey = PlayerKeys[Player.UserId]["keys"][KeyPos]
	local RemoteKey = UnZipKey(RemoteZip,PlayerKey)
	
	PlayerKeys[Player.UserId]["keyPosFunc"]+=1
	if PlayerKeys[Player.UserId]["keyPosFunc"] > #PlayerKeys[Player.UserId]["keys"] then
		PlayerKeys[Player.UserId]["keyPosFunc"] = 1
	end
	
	return RemoteFunctions[RemoteKey](Player,Data)
end



function RemoteService.Client:GetKeys(player)
	local BanService = Knit.GetService("BanService")
	local PlayerData = nil
	repeat
		PlayerData = PlayerKeys[player.UserId]
		task.wait(.2)
	until PlayerData
	
	if PlayerData["hasKeys"] then
		BanService:Ban(player,"NOOB!!!!")
	end
	PlayerData["hasKeys"] = true
	
	return PlayerData["keys"]
end



function RemoteService.Client:GetRemote(player,RemoteName)
	local BanService = Knit.GetService("BanService")
	if not Remotes[RemoteName] then
		return
	end
	if Remotes[RemoteName]["players"][player.UserId] then
		BanService:Ban(player,"Dude Really")
	end
	
	Remotes[RemoteName]["players"][player.UserId] = true
	
	return Remotes[RemoteName]["key"]
end



function RemoteService.PlayerAdded(Player)
	local playerData = {
		hasKeys = false,
		keyPos = 1,
		keyPosFunc = 1,
		keys = {}
	}
	
	for i = 1,15 do
		playerData.keys[i] = simpleKey()
	end
	
	PlayerKeys[Player.UserId] = playerData
end



function RemoteService.PlayerRemoving(Player)
	PlayerKeys[Player.UserId] = nil
	for _, v in Remotes do
		v["players"][Player.UserId] = nil
	end
end



function RemoteService:KnitStart()
	Remote.OnServerEvent:Connect(OnServerEvent)
end



return RemoteService