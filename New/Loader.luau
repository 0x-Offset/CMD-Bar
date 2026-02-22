local Loaded, Library = pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/0x-Offset/other/refs/heads/main/CMDBar_UI.luau", true)))

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

--TODO: implement cross-script command registration
