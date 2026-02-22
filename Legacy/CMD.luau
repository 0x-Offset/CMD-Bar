
local Version = 13
repeat task.wait() until game:IsLoaded()
if getgenv().CMDLoaded then
	if rconsolewarn then
		rconsolewarn("[CMD]: CMD is already loaded, if you wish to reload CMD please run ?killcmd to unload CMD first.")
	end
	error("[CMD]: CMD is already loaded, if you wish to reload CMD please run ?killcmd to unload CMD first.",0)
end
getgenv().CMDLoaded = true

local ListenerType = "null"
local Listener = nil
if rconsoleclear then
	rconsoleclear()
end
if rconsolename and getinstanceaddress then
	rconsolename(tostring(getinstanceaddress(game.Players.LocalPlayer, true)))
end
local function Debug(Type, ...)
	if Type == "info" then
		if rconsoleinfo then
			rconsoleinfo("[CMD]: " .. table.concat({...}, " "))
		else
			print("[CMD]:", ...)
		end
	elseif Type == "warn" then
		if rconsolewarn then
			rconsolewarn("[CMD]: " .. table.concat({...}, " "))
		else
			warn("[CMD]:", ...)
		end
	else
		if rconsoleprint then
			rconsoleprint("[CMD]: " .. table.concat({...}, " "))
		else
			print("[CMD]: " .. table.concat({...}, " "))
		end
	end
end
Debug("info", "Starting setup process...")
local Channel = game.TextChatService:WaitForChild("TextChannels", 20):WaitForChild("RBXSystem", 20)
if not Channel then
	getgenv().CMDLoaded = false
	Debug("warn", "Failed to get RBXSystem chat channel.")
	error("[CMD]: Failed to get RBXSystem chat channel.",0)
end
Debug("info", "Got RBXSystem chat channel.")

local Commands = {}; local function CountCommands() local Count = 0 for _ in pairs(Commands) do Count = Count + 1 end return Count end
local Binds = {}
local CAS = game:GetService("ContextActionService")
Commands = {
	["help"] = {
		["Args"] = {"Command name"},
		["Function"] = function(CommandName)
			if not CommandName then
				local List = {}
				for Name, Data in pairs(Commands) do
					List[#List + 1] = Name .. " - " .. (Data.Description or "N/A")
				end
				table.sort(List)
				return true, "Registered commands:\n" .. table.concat(List, "\n")
			end
			local Command = false
			for Name, Data in pairs(Commands) do
				if Name:lower() == CommandName:lower() then
					Command = Data
					break
				end
			end
			if not Command then
				return false, "Invalid command."
			end
			return true, ("-"):rep(#CommandName + 8) .. "\nName: " .. CommandName .. "\nArguments:\n- " .. table.concat(Command.Args, "\n- ") .. "\nDescription: " .. (Command.Description or "N/A") .. "\n" .. ("-"):rep(#CommandName + 8)
		end,
		["Description"] = "Shows information about a command."
	},
	["killcmd"] = {
		["Args"] = {},
		["Function"] = function()
			if ListenerType == "null" then
				Debug("warn", "killcmd called but ListenerType is null, this is REAALLY bad lol")
			elseif ListenerType == "SendAsync" then
				Debug("info", "[killcmd] Restoring old game namecall metamethod to disconnect listener...")
				hookmetamethod(game, "__namecall", Listener)
			elseif ListenerType == "Chatted" then
				Debug("info", "[killcmd] Disconnecting Chatted connection...")
				Listener:Disconnect()
			end
			Debug("info", "[killcmd] Removing RegisterCommand from global environment...")
			getgenv().RegisterCommand = false
			Debug("info", "[killcmd] Clearing command table...")
			table.clear(Commands)
			Debug("info", "[killcmd] Successfully cleaned up CMD, removing CMDLoaded indicator.")
			getgenv().CMDLoaded = false
			ListenerType = "unloaded"
			Listener = nil
			task.wait()
			if ListenerType == "unloaded" and Listener == nil and getgenv().RegisterCommand == false and getgenv().CMDLoaded == false and next(Commands) == nil then
				return true, "CMD has been unloaded."
			end
			Debug("warn", "Failed to unload properly, environment variables: \n[\nVersion: "..Version.."\nListenerType: "..ListenerType.."\nListener: "..tostring(typeof(Listener)).."\nRegisterCommand: "..(getgenv().RegisterCommand and "active" or "inactive")..", "..(getgenv().RegisterCommand and type(getgenv().RegisterCommand) or "N/A").."\nCMDLoaded: "..tostring(getgenv().CMDLoaded).."\nCommands: "..CountCommands().."\n]\n")
			pcall(game.Players.LocalPlayer.Kick, game.Players.LocalPlayer, "[CMD FATAL ERR]\n\nCMD encountered a fatal error while unloading.\nCheck your exploit's debug console for more information about CMD's environment variables.")
		end,
		["Description"] = "Unloads and removes CMD from the game."
	},
	["bind"] = {
		["Args"] = {"Key", "CMD string"},
		["Function"] = function(Key, ...)
			if typeof(Key) ~= "string" or #Key < 1 then return false, "Invalid key" end
    		local CMDString = table.concat({...}, " ")
    		local IsValidKey, KeyCode = pcall(function() return Enum.KeyCode[Key] end)
    		if not IsValidKey then
    		    local Check = pcall(function() return Enum.KeyCode[string.upper(Key)] end)
    		    return false, `Invalid key{Check and ` (did you mean "{string.upper(Key)}"?)` or ""}`
    		end
    		if table.find(Binds, Key) then return false, "That key is already bound" end
    		CAS:BindAction(
    		    "CMDBindTo"..Key,
    		    function(actionName, inputState, inputObject)
    		        if inputState == Enum.UserInputState.Begin then
    		            getgenv().CMDRunString(CMDString)
    		            return Enum.ContextActionResult.Sink
    		        end
    		        return Enum.ContextActionResult.Pass
    		    end,
    		    false,
    		    KeyCode
    		)
    		table.insert(Binds, Key)
		    return true, "Bound "..Key.." to \""..CMDString.."\""
		end,
		["Description"] = "Bind a key to a CMD command string"
	},
	["unbind"] = {
		["Args"] = {"Key"},
		["Function"] = function(Key)
			if typeof(Key) ~= "string" or #Key < 1 then return false, "Invalid key" end
    		local IsValidKey, KeyCode = pcall(function() return Enum.KeyCode[Key] end)
    		if not IsValidKey then
    		    local Check = pcall(function() return Enum.KeyCode[string.upper(Key)] end)
    		    return false, `Invalid key{Check and ` (did you mean "{string.upper(Key)}"?)` or ""}`
    		end
    		if not table.find(Binds, Key) then return false, "That key is not bound" end
    		CAS:UnbindAction("CMDBindTo"..Key)
    		table.remove(Binds, table.find(Binds, Key))
		    return true, "Unbound "..Key
		end,
		["Description"] = "Unbind a key"
	}
}
local ReservedCommands = {"help", "killcmd", "bind", "unbind"}
Debug("info", "Defined and reserved core commands.")

local function RegisterCommand(Name, Args, Function, Description, Flags)
    if not Name then
        Debug("warn", "Command Registration: required parameter 'Name' missing, denying registration.")
        return false, "Name Args and Function are required."
    end

    Name = tostring(Name)
    Name = Name:match("^%s*(.-)%s*$") or ""
    Name = Name:gsub("%z", ""):lower()

    if Name == "" then
        Debug("warn", "Command Registration: command name is empty after sanitization, denying registration.")
        return false, "Invalid command name."
    end
    if Name:find("%s") then
        Debug("warn", "Command Registration: command name \""..Name.."\" contains whitespace, denying registration.")
        return false, "Command names may not contain spaces."
    end
    if not Name:match("^[%w_%-]+$") then
        Debug("warn", "Command Registration: command name \""..Name.."\" contains invalid characters, denying registration.")
        return false, "Command name contains invalid characters. Use letters, numbers, underscore or dash."
    end
    if table.find(ReservedCommands, Name) then
        Debug("warn", "Command Registration: attempted to register reserved command name \""..Name.."\", denying registration.")
        return false, "The command name \""..Name.."\" is reserved."
    end
    if not islclosure(Function) then
        Debug("warn", "Command Registration: function is not a lua closure, denying registration.")
        return false, "Function must be a lua closure."
    end
    if not Args or not Function then
        Debug("warn", "Command Registration: required parameters missing, denying registration.")
        return false, "Name Args and Function are required."
    end
    if Commands[Name] and not (Flags and Flags:find("-force")) then
        Debug("warn", "Command Registration: command with the given name already exists, denying registration.")
        return false, "A command with that name already exists, include \"-force\" in flags to overwrite."
    end

    Debug("info", "Command Registration: checks passed, registering command \""..Name.."\"")
    Commands[Name] = {
        ["Args"] = Args,
        ["Function"] = Function,
        ["Description"] = Description or "No description provided."
    }
    return true
end
local Delay = game:GetService("RunService").RenderStepped
local function ChatReply(NoCMD, ...)
	local T = {...}
	if T[1] == nil then return end
	if NoCMD then
		Channel:DisplaySystemMessage(table.concat({...}, ""))
	else
		Channel:DisplaySystemMessage("<b>[CMD]</b> > " .. table.concat({...}, " "))
	end
	Delay:wait()
end

local function CleanArgs(Args)
	local T = {}
	for _, V in ipairs(Args) do
		if V and V ~= "" then
			table.insert(T, V)
		end
	end
	return T
end

local function ParseArguments(Str)
    local Args = {}
    if not Str or Str == "" then return Args end
    local i = 1
    local Len = #Str
    while i <= Len do
        while i <= Len and Str:sub(i,i):match("%s") do i = i + 1 end
        if i > Len then break end
        local c = Str:sub(i,i)
        if c == '"' then
            local j = i + 1
            local Found = false
            while j <= Len do
                if Str:sub(j,j) == '"' then
                    table.insert(Args, Str:sub(i+1, j-1))
                    i = j + 1
                    Found = true
                    break
                end
                j = j + 1
            end
            if not Found then
                table.insert(Args, Str:sub(i+1))
                break
            end
        else
            local j = i
            while j <= Len and not Str:sub(j,j):match("%s") do j = j + 1 end
            table.insert(Args, Str:sub(i, j-1))
            i = j
        end
    end
    return Args
end

local function Handler(Message)
	if #Message > 1 and Message:sub(1, 1) == "?" and Message:sub(1, 2) ~= "??" and Message:sub(1, 2) ~= "?!" and Message:sub(1, 2) ~= "? " then
		local CmdString = Message:sub(2)
		Debug("info", "Got command string \""..CmdString.."\"")

		local Keys = ParseArguments(CmdString)
		local Cmd = Keys[1]:lower()
		table.remove(Keys, 1)
		local Args = CleanArgs(Keys)

		Debug("info", "Parsed command: "..Cmd.." | Args: "..table.concat(Args, ", "))

		for Name, Data in pairs(Commands) do
			if Name:lower() == Cmd then
				Debug("info", "Found command "..Name..", executing function...")
				ChatReply(false, Message:sub(2))
				task.wait()
				task.spawn(function()
					local OK, Result = pcall(function()
						return table.pack(Data.Function(table.unpack(Args)))
					end)

					if not OK then
						ChatReply(true, "[ERROR] " .. tostring(Result))
						Debug("warning", "Error while executing command \""..Name.."\": "..tostring(Result))
						return
					end

					local Success = Result[1]
					local Output = table.pack(table.unpack(Result, 2))

					if Success then
						if #Output > 0 then
							local OK2, Output = pcall(function()
								return table.concat(Output, " | ")
							end)
							if OK2 and Output then
								ChatReply(true, Output)
							end
						end
					else
						ChatReply(true, "[ERROR] " .. tostring(Output[1]))
					end
				end)
				return
			end
		end

		ChatReply(true, "[ERROR] Invalid command. Type ?help [command] for help with a command.")
	end
end
Debug("info", "Defined internal functions.")
if shared.CmdBarEvent then
	shared.CmdBarEvent:Connect(function(input) Handler(input) end)
	Debug("info", "Connected to CmdBar.")
	ChatReply(true, "CMD has connected to CmdBar! You can now use CmdBar as input to CMD by prefixing your command with \"?\"")
else
	Debug("warn", "CmdBar is not active in current environment, can not connect handler.")
	task.spawn(function()
		ChatReply(true, "CmdBar is currently not active, CMD will check for CmdBar periodically, if you load it please wait 5 to 10 seconds for CMD to check again and connect the handler, a message will be displayed when it is connected.")
		while task.wait(10) do
			if shared.CmdBarEvent then
				shared.CmdBarEvent:Connect(function(input) Handler(input) end)
				Debug("info", "Connected to CmdBar.")
				ChatReply(true, "CMD has connected to CmdBar! You can now use CmdBar as input to CMD by prefixing your command with \"?\"")
				break
			end
		end
	end)
end

getgenv().CMDRunString = function(CMDString)
	if typeof(CMDString) ~= "string" or #CMDString < 2 then return end
	if CMDString:sub(1,1) ~= "?" then CMDString = "?"..CMDString end
	Handler(CMDString)
end
Debug("info", "Added CMDRunString function to global environment.")

Debug("info", "Spawning listener for chat commands...")
if hookmetamethod then
	local OldNamecall
	OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
		local Method = getnamecallmethod()
		local Args = {...}
		if checkcaller() and Self == Channel and Method == "SendAsync" then
			local Message = Args[1]
			Handler(Message)
			return
		end
		return OldNamecall(Self, ...)
	end))
	ListenerType = "SendAsync"
	Listener = OldNamecall
else
	Debug("warn", "hookmetamethod unavailable, using alternative listener.")
	ChatReply(true, "Your exploit is missing important features.\nCMD is using an alternative listener, which means your messages will not be blocked.\n<b>Others can see your commands if ran in chat !</b>")
	Listener = game.Players.LocalPlayer.Chatted:Connect(function(Message)
		Handler(Message)
	end)
	ListenerType = "Chatted"
end

Debug("info", "Spawned listener.")
getgenv().RegisterCommand = RegisterCommand
Debug("info", "Loaded RegisterCommand into the global environment.\n")
Debug("info", "Current state of CMD environment variables:\n[\nVersion: "..Version.."\nListenerType: "..ListenerType.."\nListener: "..tostring(typeof(Listener)).."\nRegisterCommand: "..(getgenv().RegisterCommand and "active" or "inactive")..", "..(getgenv().RegisterCommand and type(getgenv().RegisterCommand) or "N/A").."\nCMDLoaded: "..tostring(getgenv().CMDLoaded).."\nCommands: "..CountCommands().."\n]\n")
Debug("info", "Setup completed.\n")
