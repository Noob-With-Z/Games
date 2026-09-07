--[[

Game: NPCs Are Becoming Smart
Script: Roblox "chat enabler" if not age-checked

]]

repeat task.wait() until game.Loaded

-- // Services & internal executors functions

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
getconnections = missing("function", getconnections)
firesignal = missing("function", firesignal)

-- // Safe Service objects
Players = cloneref(game:GetService("Players"))
UserInputService = cloneref(game:GetService("UserInputService"))
StarterGui = cloneref(game:GetService("StarterGui"))
CoreGui = cloneref(game:GetService("CoreGui"))
ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
RunService = cloneref(game:GetService("RunService"))
TextService = cloneref(game:GetService("TextService"))

-- // Cool stuff under this
local plr = Players.LocalPlayer

function Notify(...)
	return StarterGui:SetCore("SendNotification", ...)
end

if game.PlaceId ~= 6813414321 then
	Notify({
		Title = "Well...",
		Text = "This is not NPCs Are Becoming Smart.",
		Duration = 5
	})
	return
end

-- // Before, we need to check if the user really don't have the chat access
local isPlayerAgeChecked = plr.AgeChecked == Enum.AgeCheckStatus.Checked

local RobloxChatGUI =
	CoreGui:WaitForChild("ExperienceChat"):FindFirstChild("appLayout"):FindFirstChild("chatInputRow"):FindFirstChild("fillArea")
local ChatButton = RobloxChatGUI:FindFirstChild("enableChatButton")
local ChatInput = RobloxChatGUI:FindFirstChild("chatInputBar")
local TextContainer = 
	ChatInput:FindFirstChildWhichIsA("Frame"):FindFirstChildWhichIsA("Frame"):FindFirstChildWhichIsA("Frame"):FindFirstChild("TextContainer")

local ChatRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ChatUAE")

local isChatDisabled = (ChatButton and ChatButton.Visible and not ChatInput.Visible) and true or false

-- // Simple debug to check if everything ok
print(isPlayerAgeChecked, RobloxChatGUI, ChatButton, ChatInput, isChatDisabled)

if isPlayerAgeChecked and not isChatDisabled then
	Notify({
		Title = "Wth?",
		Text = "You already have the chat access (??)",
		Duration = 5
	})
	return
end

local TextBoxContainer = Instance.new("Frame")
local TextBox = Instance.new("TextBox")

TextBoxContainer.Name = "TextBoxContainer"
TextBoxContainer.Parent = TextContainer
TextBoxContainer.AnchorPoint = Vector2.new(1, 0)
TextBoxContainer.BackgroundTransparency = 1.000
TextBoxContainer.Position = UDim2.new(1, 0, 0, 0)
TextBoxContainer.Size = UDim2.new(1, -8, 0, 0)

TextBox.Parent = TextBoxContainer
TextBox.BackgroundTransparency = 1.000
TextBox.SelectionImageObject =
	CoreGui:FindFirstChild("ExperienceChat"):FindFirstChild("FoundationCursorContainer"):FindFirstChild("0 0 3 3 Color")
TextBox.Size = UDim2.new(1, 0, 1, 0)
TextBox.ZIndex = 2
TextBox.ClearTextOnFocus = false
TextBox.Font = Enum.Font.BuilderSansMedium
TextBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
TextBox.PlaceholderText = "To chat click here or press ; key"
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 18.000
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.TextYAlignment = Enum.TextYAlignment.Top

TextBox.FocusLost:Connect(function(enter)
	if enter and TextBox.Text ~= "" then
		ChatRemote:FireServer(TextBox.Text)
		TextBox.Text = ""
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Slash and not TextBox:IsFocused() then
		TextBox:CaptureFocus()
	end
end)

local MIN_HEIGHT = 24
local MAX_HEIGHT = 120
local MAX_CHARACTERS = 200

function getCharacterCount(text)
	return utf8.len(text) or #text
end

function limitText(text)
	if getCharacterCount(text) <= MAX_CHARACTERS then
		return text
	end

	return utf8.sub(text, 1, MAX_CHARACTERS) or ""
end

function updateHeight()
	local width = math.max(TextBox.AbsoluteSize.X, 1)

	local text = TextBox.Text

	if text == "" then
		TextBoxContainer.Size = UDim2.new(
			TextBoxContainer.Size.X.Scale,
			TextBoxContainer.Size.X.Offset,
			0,
			MIN_HEIGHT
		)
		return
	end

	local bounds = TextService:GetTextSize(
		text,
		TextBox.TextSize,
		TextBox.Font,
		Vector2.new(width, math.huge)
	)

	local height = math.clamp(
		bounds.Y + 6,
		MIN_HEIGHT,
		MAX_HEIGHT
	)

	TextBoxContainer.Size = UDim2.new(
		TextBoxContainer.Size.X.Scale,
		TextBoxContainer.Size.X.Offset,
		0,
		height
	)
end

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	local limited = limitText(TextBox.Text)

	if limited ~= TextBox.Text then
		TextBox.Text = limited
	end

	updateHeight()
end)

TextBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateHeight)

TextBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed then
		return
	end

	local message = TextBox.Text

	if message == "" then
		return
	end
	
	ChatRemote:FireServer(message)

	TextBox.Text = ""
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Slash
		or input.KeyCode == Enum.KeyCode.Semicolon then

		if not TextBox:IsFocused() then
			TextBox:CaptureFocus()
		end
	end
end)

updateHeight()

TextBoxContainer:GetPropertyChangedSignal("Parent"):Connect(function()
	if TextBoxContainer.Parent == nil then
		TextBoxContainer.Parent = TextContainer
	end
end)
TextBox:GetPropertyChangedSignal("Parent"):Connect(function()
	if TextBox.Parent == nil then
		TextBox.Parent = TextBoxContainer
	end
end)

RunService.RenderStepped:Connect(function()
ChatButton.Visible = false; ChatInput.Visible = true
TextContainer:FindFirstChildWhichIsA("TextLabel").Visible = false
end)

local Chat = CoreGui:FindFirstChild("TopBarApp"):FindFirstChild("TopBarApp"):FindFirstChild("UnibarLeftFrame"):FindFirstChild("UnibarMenu")["2"]["3"]:FindFirstChild("chat")
local ChatButtonMe = Chat:FindFirstChild("IconHitArea_chat")
local ChatIconTopBar : TextLabel = Chat:FindFirstChild("IntegrationIconFrame"):FindFirstChild("IntegrationIcon")

-- // They use BuilderIcons font as Topbar icons. We can use this to check if chat is open or not: Bold: Chat open, Regular: Chat closed
-- (yea, they use TextLabels as icons, it's kinda funny)
local ChatActivated = ChatIconTopBar.FontFace.Weight == Enum.FontWeight.Bold

-- // Chat open on press to focus textbox (same system as they use basically)
TextBox.Focused:Connect(function()
	if not ChatActivated then
		ChatActivated = true
		if getconnections and firesignal then
			if getconnections(ChatButtonMe.Activated) then
				firesignal(ChatButtonMe.Activated)
			end
		end
	end
end)

Notify({
		Title = "Yo yo!",
		Text = "Thanks for using this!\nMuch love, NoobZ.",
		Duration = 5
	})
