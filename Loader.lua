repeat task.wait() until game.Loaded

local StarterGui = game:GetService("StarterGui")

function SendNotification(Titles, Texts, Icona, Durationn, Button1s, Button2s, Callbackf)
    task.spawn(function()
        Titles = Titles or "Notification"
        Texts = Texts or "Hello!"
        Icona = Icona or "rbxassetid://123456789"
        Durationn = Durationn or 5
        Button1s = Button1s or "[Close]"
        Button2s = Button2s or nil
        Callbackf = Callbackf or function() end

         local bf = Instance.new("BindableFunction")
         bf.OnInvoke = function(r)
               Callbackf(r)
               bf:Destroy()
         end

        StarterGui:SetCore("SendNotification", {
            Title = Titles,
            Text = Texts,
            Icon = Icona,
            Duration = Durationn,
            Button1 = Button1s,
            Button2 = Button2s,
            Callback = bf
        })
    end)
end

function unc(n,f)
    if n and typeof(n) == "function" then
        return n
    else
        return f or nil
    end
end

waxwritefile, waxreadfile = writefile, readfile
writefile = unc("function", waxwritefile) and function(file, data, safe)
    if safe == true then return pcall(waxwritefile, file, data) end
    waxwritefile(file, data)
end
readfile = unc("function", waxreadfile) and function(file, safe)
    if safe == true then return pcall(waxreadfile, file) end
    return waxreadfile(file)
end
isfile = unc("function", isfile, readfile and function(file)
    local success, result = pcall(function()
        return readfile(file)
    end)
    return success and result ~= nil and result ~= ""
end)
makefolder = unc("function", makefolder)
isfolder = unc("function", isfolder)

everyClipboard = unc("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))

getconnections = unc("function", getconnections)
firesignal = unc("function", firesignal)

function toClipboard(txt)
    if everyClipboard then
        everyClipboard(tostring(txt))
    else
        return "Error"
    end
end

task.spawn(function()
    if not isfolder("NoobZLovesYou") then
        makefolder("NoobZLovesYou")
    end

    if not isfolder("NoobZLovesYou/Saved") then
        makefolder("NoobZLovesYou/Saved")
    end
end)

local Domain = "https://raw.githubusercontent.com"
local GitHub = "Noob-With-Z"
local Repository = "Games"

local Games = {
    [142823291] = "Z/mm2.lua", -- Murder Mystery 2
}

function GetScript()
    if Games[game.PlaceId] then
        return Games[game.PlaceId]
    else
        return "Unknown"
    end
end

task.spawn(function()
    local Script = GetScript()

    if Script == "Unknown" then
        SendNotification(
            "Script not found",
            "There's no script for this game. You can find some stuff on GitHub.",
            "",
            8,
            "Copy",
            "Ok",
            function(Response)
                if Response == "Copy" then
                    local result = toClipboard("https://github.com/Noob-With-Z")
                    if result == "Error" then
                        SendNotification(
                            "GitHub Link",
                            "Could not copy:\nhttps://github.com/Noob-With-Z",
                            "",
                            math.huge,
                            "[Close]"
                        )
                    end
                end
            end
        )
        return
    end

    local Compact = tostring(Domain .. "/" .. GitHub .. "/" .. Repository .. "/main/" .. Script)

    local Success, Result = pcall(function()
        return loadstring(game:HttpGet(Compact))()
    end)

    if not Success then
        SendNotification(
            "Failed to load script",
            "More info in console.",
            "",
            8,
            "Check",
            "Ok",
            function(Response)
                if Response == "Check" then
                    StarterGui:SetCore("DevConsoleVisible", true)

                    if getconnections then
                        local tbox = game:GetService("CoreGui").DevConsoleMaster.DevConsoleWindow.DevConsoleUI.MainView.UtilAndTab.SearchBarFrame.SearchBar.InputField.TextBox
                        tbox.Text = "NoobZ was here"
                        if getconnections(tbox.FocusLost) then
                            firesignal(tbox.FocusLost, true)
                        end
                    end
                end
            end
        )

        warn("// NoobZ was here //\n", "Error while loading script:", "\n", Result)
        return
    end
end)
