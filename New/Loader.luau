repeat task.wait() until game:IsLoaded()
-- if you make a custom wrapper, make sure to include this (especially if ure gonna have ur script in auto-exec)

local Loaded, Library = pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/0x-Offset/CMD-Bar/refs/heads/main/New/CMDBar_UI.luau", true)))

if not Loaded then
    error("[CMD Bar] UI library failed to load: "..tostring(Library))
end

local Window = Library:CreateWindow({
    Name = 'CMD Bar',
    IntroText = 'CMD Command Bar',
    IntroBlur = false,
    Theme = Library.Themes.cmdbar,
    Position = "bottom",
    Draggable = true,
    Prefix = ';'
})

Window:AddCommand('SetPrefix', {'New Prefix'}, 'Changes The Prefix.', function(Arguments, Speaker)
    Window:ChangePrefix(Arguments[1])
end)

Window:AddCommand('SetTheme', {'New Theme'}, 'Changes The Theme.', function(Arguments, Speaker)
    Window:ChangeTheme(Arguments[1])
end)

shared.RegisterCMD = function(Name:string, ArgumentDescriptions:{string}, Description:string, Function:Function)
    local Success, Error = pcall(Window.AddCommand, Window, Name, ArgumentDescriptions, Description, Function)
    if not Success then return error(Error) end
    return true
end
