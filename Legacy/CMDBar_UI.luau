if shared.CmdBarEvent then warn("CmdBar already loaded") return end
local function Debug(...) if rconsoleprint then rconsoleprint("[CMD Bar] "..table.concat({...}, " ")) else print("[CMD Bar] "..table.concat({...}, "")) end end
Debug("Loading CmdBar")
local CmdBar = Instance.new("TextBox")
local GUI = Instance.new("ScreenGui", game.CoreGui)
CmdBar.Parent = GUI

CmdBar.Size = UDim2.new(1, 0, 0.05, 0)
CmdBar.Position = UDim2.new()

local Signal = Instance.new("BindableEvent") -- because im too lazy to port a signal library to be executor compatible :)
shared.CmdBarEvent = Signal.Event

--shared.CmdBarEvent:Connect(function(input) Debug("input from cmd bar: "..input) end)

CmdBar.ClearTextOnFocus = false
CmdBar.TextScaled = true
CmdBar.FocusLost:Connect(function(E)
    if E then
        Signal:Fire(CmdBar.Text)
        CmdBar.Text = ""
        CmdBar:ReleaseFocus()
        CmdBar.Visible = false
        return
    end
    if CmdBar.Text:gsub(" ", "") == "" then
        CmdBar.Text = ""
        CmdBar:ReleaseFocus()
        CmdBar.Visible = false
        return
    end
end)
CmdBar.Visible = false
CmdBar.Text = ""
local CAS = game:GetService("ContextActionService")
CAS:BindAction(
    "OpenCmdBar",
    function(_, state)
        if state == Enum.UserInputState.Begin then
            task.wait(0.04)
            CmdBar.Visible = true
            CmdBar:CaptureFocus()
        end
    end,
    false,
    Enum.KeyCode.Semicolon
)

Debug("CmdBarEvent added to shared")
