local Knit = require(game:GetService('ReplicatedStorage').Packages.Knit)
local RemoteController = Knit.CreateController { Name = script.Name, Client = {} }
local Remote = game:GetService("ReplicatedStorage").Remote

local keys = nil
local keysPos= 1
local keysPosFunc = 1

local Remotes = {}

function RemoteController:OnClientEvent(RemoteName,Func)
	Remotes[RemoteName] = Func
end



local function OnClientEvent(RemoteName,Data)
	if Remotes[RemoteName] then
		Remotes[RemoteName](Data)
	end
end



local function ZipKey(RemoteKey,PlayerKey)
	local newKey = ""
	
	for i = 1, #RemoteKey do
		local RemoteChar = RemoteKey:sub(i, i)
		local PlayerChar = PlayerKey:sub(i, i)
		newKey = newKey .. (PlayerChar == "0" and (RemoteChar == "-" and "0" or "-") or RemoteChar)
		
	end
	return newKey
end



function RemoteController:FireServer(RemoteKey,data)
	local playerKey = keys[keysPos]
	local zipKey = ZipKey(RemoteKey,playerKey)
	
	keysPos+=1
	if keysPos > #keys then
		keysPos = 1
	end
	
	Remote:FireServer(zipKey,data)
end



function RemoteController:FireServerFunc(RemoteKey,data)
	local RemoteService = Knit.GetService("RemoteService")
	local playerKey = keys[keysPosFunc]
	local zipKey = ZipKey(RemoteKey,playerKey)
	
	keysPosFunc+=1
	if keysPosFunc > #keys then
		keysPosFunc = 1
	end
	
	return RemoteService:FireServerFunc(zipKey,data)
end



function RemoteController:GetRemote(RemoteName)
	return Knit.GetService("RemoteService"):GetRemote(RemoteName)
end



function RemoteController.KnitInit()
	local RemoteService = Knit.GetService("RemoteService")
	keys = RemoteService:GetKeys()
	
	Remote.OnClientEvent:Connect(OnClientEvent)
end

return RemoteController