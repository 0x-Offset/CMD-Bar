This is the legacy version, i might fix some bugs but it wont be updated and nothing will be added to it, meant for backwards compatibility for some of my old projects that would be too much work to port over, or anything thats just better to use with the legacy command system (the command registration is quite different).

this version has chat compatibility, intially it was just called "CMD" and included CMD Bar to bypass the then-recently-added chat restrictions.

example how to use:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/0x-Offset/CMD-Bar/refs/heads/main/Legacy/CMD.luau", true))()
repeat task.wait() until getgenv().RegisterCommand ~= nil
loadstring(game:HttpGet("https://raw.githubusercontent.com/0x-Offset/CMD-Bar/refs/heads/main/Legacy/CMDBar_UI.luau", true))()

local Register = getgenv().RegisterCommand

Register("to", {"Player Name"}, function(PlayerName)
    local target = game.Players:FindFirstChild(PlayerName)
    if not target then
        return false, "That player does not exist."
    end
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position)
    return true
end, "Teleport to the given player.", "-force")
```
the -force tag can be used to reload commands, using it when registering a command when a different one with that name already exists will bypass the checks and overwrite the existing command (this will not work on core commands like the help command)
