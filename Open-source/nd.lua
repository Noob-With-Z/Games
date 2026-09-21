--[[

Game: Natural Disaster

(this script was made for the event only)

working until:
28/09/2026 - The Hunt: Roblox 20 end
(Day/Month/Year)

]]

repeat task.wait() until game:IsLoaded()

local function missing(t, f, fallback)
	if type(f) == t then
		return f
	end
	return fallback
end

cloneref = missing("function", cloneref, function(...)
	return ...
end)

fireproximityprompt = missing("function", fireproximityprompt)
firetouchinterest = missing("function", firetouchinterest)

sethiddenproperty = missing("function", sethiddenproperty, function(obj, prop, val)
	pcall(function()
		obj[prop] = val
	end)
end)

local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local function Notify(...)
	return StarterGui:SetCore("SendNotification", ...)
end

local VaehzLib = loadstring(
	game:HttpGet(
		"https://raw.githubusercontent.com/Noob-With-Z/Libraries/refs/heads/main/Vaehz%20Library/Vaehzlib.lua"
	)
)()

local ___size

local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

if game.PlaceId ~= 189707 then
	warn("Wrong game! This script can only be used in the game 'Natural Disaster'")
	Notify({
		Title = "Wrong game!",
		Text = "This script can only be used in the game 'Natural Disaster'",
		Duration = 10,
	})
	return
end

local thisday, thismonth, thisyear = os.date("%d/%m/%Y"):match("(%d+)/(%d+)/(%d+)")
local limitedtime = "28/09/2026"

local today = os.time({
	day = tonumber(thisday),
	month = tonumber(thismonth),
	year = tonumber(thisyear)
})

local d, m, y = limitedtime:match("(%d+)/(%d+)/(%d+)")

local limit = os.time({
	day = tonumber(d),
	month = tonumber(m),
	year = tonumber(y)
})

if today > limit then
	Notify({
		Title = "Expired",
		Text = "The R20 event has ended. Badge obtainment is unavailable.",
		Duration = 10,
	})
	return
end

local IsMobile = false

xpcall(function()
	IsMobile = table.find(
		{Enum.Platform.Android, Enum.Platform.IOS},
		UserInputService:GetPlatform()
	) ~= nil
end, function()
	IsMobile = UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
end)

if IsMobile then
	___size = UDim2.new(0, 532, 0.7, 0)
else
	___size = UDim2.new(0, 532, 0.45, 0)
end

local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

plr.CharacterAdded:Connect(function(newChar)
	char = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart")
	hum = newChar:WaitForChild("Humanoid")
end)

local SafeFolder = Instance.new("Folder")
SafeFolder.Name = "NoobZ Stuff"
SafeFolder.Parent = CoreGui

function Touch(part)
	if not part then return end
	
	local touch = part:FindFirstChildWhichIsA("TouchTransmitter")
	firetouchinterest(hrp, touch, 1, task.wait() and firetouchinterest(hrp, touch, 0))
end

function HasBadge(BadgeID)
	return game:GetService("BadgeService"):UserHasBadgeAsync(plr.UserId, BadgeID)
end

local Window = VaehzLib:CreateWindow({
	Title = "NoobZ Hub | Natural Disaster",
	Size = ___size,
	Accent = Color3.fromRGB(100, 160, 255),
	ToggleKey = Enum.KeyCode.H,
	Social = {
		YT = "",
		DC = "",
		DCCode = ""
	}
})

local Settings = {
	R20 = {
		AutoRescueAnimals = false,
		AutoGrabHats = false
	}
}

local AnimalsFolder = workspace:WaitForChild("NPCs")
local HatsFolder = workspace:WaitForChild("RescueEventObjects")

local R20Tab = Window:CreateTab({
	Name = "The Hunt 20",
})

R20Tab:CreateToggle({
	Name = "Auto Rescue Animals",
	Default = Settings.R20.AutoRescueAnimals,
	Callback = function(value)
		Settings.R20.AutoRescueAnimals = value
	end,
})

R20Tab:CreateToggle({
	Name = "Auto Grab Hats",
	Default = Settings.R20.AutoGrabHats,
	Callback = function(value)
		if not HasBadge(1950450904039809) then
			Notify({
				Title = "Missing Badge",
				Text = "You do not have the badge required for this feature.",
				Duration = 7,
			})
			return
		end
		Settings.R20.AutoGrabHats = value
	end,
})

local Connections = {}

function ConnectEvent(Event, Name, Callback)
	if Event and typeof(Event) == "RBXScriptSignal" then
		Connections[Name] = Event:Connect(Callback)
	end
end

function DisconnectEvent(Name)
	if Connections[Name] and Connections[Name].Connected then
		Connections[Name]:Disconnect()
		Connections[Name] = nil
	end
end

function DisconnectAll()
	for _, Connection in Connections do
		if Connection and Connection.Connected then
			Connection:Disconnect()
		end
	end
	table.clear(Connections)
end

ConnectEvent(RunService.Heartbeat, "Heartbeat", function()
	if not plr or not plr.Parent then
		return
	end
	pcall(function()
		sethiddenproperty(
			plr,
			"SimulationRadius",
			99999
		)
	end)
	
	pcall(function()
		if Settings.R20.AutoRescueAnimals then
			Touch(workspace:WaitForChild("RescueEventWorld"):WaitForChild("LobbyPen"):WaitForChild("Hitbox"))
			
			for _, animal in AnimalsFolder:GetChildren() do
				if animal:IsA("Model") and animal:FindFirstChild("HumanoidRootPart") then
					local animalhrp = animal:WaitForChild("HumanoidRootPart")
					if animalhrp:FindFirstChildWhichIsA("TouchTransmitter") then
						Touch(animalhrp)
					end
				end
			end
		end
		
		if Settings.R20.AutoGrabHats then
			ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RescueEvent2026"):FireServer("SetCode", "true")
			
			fireproximityprompt(workspace:WaitForChild("RescueEventWorld"):WaitForChild("HatBox"):WaitForChild("Deposite"):FindFirstChildWhichIsA("ProximityPrompt"))
			
			for _, hat in HatsFolder:GetChildren() do
				if hat:IsA("Model")
				and hat:FindFirstChildWhichIsA("BasePart")
				and not hat:FindFirstChildWhichIsA("BasePart"):FindFirstChildWhichIsA("TouchTransmitter")
				then
					Touch(hat:FindFirstChildWhichIsA("BasePart"))
				end
			end
		end
	end)
end)
