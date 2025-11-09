local success, result = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Noob-With-Z/Games/refs/heads/main/PrisonLife/Main.lua"))()
end)

if not success then
	warn("// Error while loading script: \n" .. result .. "\nIf it keeps to happen contact the developer of script.")
end
