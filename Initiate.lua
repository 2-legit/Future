-- // credits to anyones code i used/looked at.
print("[Future] Loading!")
repeat task.wait() until game:IsLoaded()
if shared.Future~=nil then print("[Future] Detected future already executed, not executing!") return end
shared.futureStartTime = game:GetService("Workspace"):GetServerTimeNow()
shared._FUTUREVERSION = "1.1.7a2 revive | "..((shared.FutureDeveloper and "dev" or "release")).." build" -- // This is a cool thing yes
shared._FUTUREMOTD = "futureclient.xyz 🔥"
local startTime = shared.futureStartTime
shared.Future = {}
local Future = shared.Future
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HTTPSERVICE = game:GetService("HttpService")
local PLAYERS = game:GetService("Players")
local CONTENTPROVIDER = game:GetService("ContentProvider")
local COREGUI = game:GetService("CoreGui")
local lplr = PLAYERS.LocalPlayer
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local setthreadidentityfunc = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity
local getthreadidentityfunc = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity
local spawn = function(func) 
    return coroutine.wrap(func)()
end
local betterisfile = function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
Future.SignalLib = true

local function requesturl(url, bypass) 
    if betterisfile(url) and shared.FutureDeveloper then 
        return readfile(url)
    end
    local repourl = bypass and "https://raw.githubusercontent.com/joeengo/" or "https://raw.githubusercontent.com/joeengo/Future/main/"
    local url = url:gsub("Future/", "")
    local req = requestfunc({
        Url = repourl..url,
        Method = "GET"
    })
    if req.StatusCode ~= 200 then return req.StatusCode end
    return req.Body
end 


--shared.Future.entity = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Libraries/entityHandler.lua"))()

-- anti mobile skids:

(function() 
    local entity = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Libraries/entityHandler.lua"))()
end)()


-- AntiPreloadAsync:
local suc, err = pcall(function()
    if not shared.AntiPreloadAsync then
        shared.AntiPreloadAsync = true
        local oldnamecall, oldPreloadAsync; do 
            oldnamecall = hookmetamethod(game, "__namecall", function(self, tab, ...) 
                local namecallmethod = string.lower(getnamecallmethod())
                
                if self ~= CONTENTPROVIDER then 
                    return oldnamecall(self, tab, ...)
                end

                if not ((namecallmethod == 'preload' or namecallmethod == 'preloadasync') and (type(tab)=='table' and table.find(tab, COREGUI))) then 
                    return oldnamecall(self, tab, ...)
                end
                
                local returnTable = {}
                for i,v in next, tab do 
                    local assets; CONTENTPROVIDER.PreloadAsync(CONTENTPROVIDER, {v}, function(a) assets=a end)
                    repeat task.wait() until assets
                    if v == COREGUI then 
                        for i2,v2 in next, assets do 
                            if v2:match("rbxassetid://") then 
                                assets[i2] = "rbxasset://textures/ui/Vehicle/SpeedBar.png"
                            end    
                        end
                    end
                    returnTable[#returnTable+1] = unpack(assets)
                end
                
                return oldnamecall(self, tab, ...)
            end)

            oldPreloadAsync = hookfunction(CONTENTPROVIDER.PreloadAsync, function(tab) 
                if not (type(tab)=='table' and table.find(tab, COREGUI)) then 
                    return oldPreloadAsync(tab)
                end
                
                local returnTable = {}
                for i,v in next, tab do 
                    local assets; oldPreloadAsync(CONTENTPROVIDER, {v}, function(a) assets=a end)
                    if v == COREGUI then 
                        for i2,v2 in next, assets do 
                            if v2:match("rbxassetid://") then 
                                assets[i2] = "rbxasset://textures/ui/Vehicle/SpeedBar.png"
                            end    
                        end
                    end
                    returnTable[#returnTable+1] = unpack(assets)
                end

                return returnTable
            end)    
        end
    end
end)

if not suc then 
    warn("[Future] AntiPreloadAsync failed to load: "..err)
end

if game:GetService("CoreGui"):FindFirstChild("RobloxVRGui") then 
    game:GetService("CoreGui"):FindFirstChild("RobloxVRGui"):Destroy()
end

local GuiLibrary = loadstring(requesturl("Future/GuiLibrary.lua"))()

shared.Future.GuiLibrary = GuiLibrary
local getcustomasset = --[[getsynasset or getcustomasset or]] GuiLibrary["getRobloxAsset"]
GuiLibrary["LoadOnlyGuiConfig"]()


local HeartbeatTable = {}
local RenderStepTable = {}
local SteppedTable = {}
local function isAlive(plr)
    local plr = plr or lplr
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid")) and (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) and (plr.Character:FindFirstChild("HumanoidRootPart"))) then
        return true
    end
end

local function BindToHeartbeat(name, func)
    if HeartbeatTable[name] == nil then
        HeartbeatTable[name] = game:GetService("RunService").Heartbeat:connect(func)
    end
end
local function UnbindFromHeartbeat(name)
    if HeartbeatTable[name] then
        HeartbeatTable[name]:Disconnect()
        HeartbeatTable[name] = nil
    end
end
local function BindToRenderStep(name, func)
	if RenderStepTable[name] == nil then
		RenderStepTable[name] = game:GetService("RunService").RenderStepped:connect(func)
	end
end
local function UnbindFromRenderStep(name)
	if RenderStepTable[name] then
		RenderStepTable[name]:Disconnect()
		RenderStepTable[name] = nil
	end
end
local function BindToStepped(name, func)
	if SteppedTable[name] == nil then
		SteppedTable[name] = game:GetService("RunService").Stepped:connect(func)
	end
end
local function UnbindFromStepped(name)
	if SteppedTable[name] then
		SteppedTable[name]:Disconnect()
		SteppedTable[name] = nil
	end
end

local function skipFrame() 
    return game:GetService("RunService").Heartbeat:Wait()
end

local function ferror(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    GuiLibrary["CreateNotification"]("<font color='rgb(255, 10, 10)'>[ERROR]"..str.."</font>")
    error("[Future]"..str)
end

local function fwarn(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    warn("[Future]"..str)
    GuiLibrary["CreateNotification"]("<font color='rgb(255, 255, 10)'>[WARNING] "..str.."</font>")
end

local function fprint(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    print("[Future]"..str)
    GuiLibrary["CreateNotification"]("<font color='rgb(170, 170, 170)'>"..str.."</font>")
end

local function getasset(path)
	if not betterisfile(path) then
		local req = requestfunc({
			Url = "https://raw.githubusercontent.com/joeengo/Future/main/"..path:gsub("Future/assets", "assets"),
			Method = "GET"
		})
        print("[Future] downloading "..path.." asset.")
		writefile(path, req.Body)
        repeat task.wait() until betterisfile(path)
        print("[Future] downloaded "..path.." asset successfully!")
	end
	return getcustomasset(path) 
end

local function getscript(id) 
    local id = id or shared.FuturePlaceId or game.PlaceId
    id = tostring(id)
    local req = requesturl("Future/scripts/"..id..".lua")
    if type(req) == "string" then
        return loadstring(req)()
    else
        --fwarn("[Future] invalid script (error "..tostring(req)..")") -- game is not supported
    end
end

local function getplusscript(id) -- future plus moment
    local id = id or shared.FuturePlaceId or game.PlaceId
    id = tostring(id)
    if not betterisfile("Future/plus/"..id..".fp") then return end
    local req = readfile("Future/plus/"..id..".fp")
    if type(req) == "string" then
        return loadstring(req)()
    else
        --fwarn("[Future] invalid script (error "..tostring(req)..")") -- game is not supported
    end
end

local function getcustomscripts(id) 
    local id = id or shared.FuturePlaceId or game.PlaceId
    id = tostring(id)
    if not isfolder("Future/custom-scripts/"..id) then 
        return
    end
    local files = listfiles("Future/custom-scripts/"..id)
    for i,v in next, files do 
        local req = readfile(v)
        if type(req) == "string" then
            print("[Future] Loading script ", v)
            loadstring(req)()
        end
    end
end

GuiLibrary["LoadOnlyGuiConfig"]()


local friendstab = {pcall(function() HTTPSERVICE:JSONDecode(readfile("Future/Friends.json")) end)}
Future.Friends = friendstab[1] and friendstab[2] or {}

Future.isFriend = function(plr) 
    return Future.Friends[plr.Name:lower()] and true or false
end

Future.addFriend = function(plrname) 
    if not Future.Friends[plrname:lower()] then
        Future.Friends[plrname:lower()] = true
        GuiLibrary.CreateNotification("Successfully added "..plrname.." to your friends list!")
    end
end

Future.delFriend = function(plrname) 
    if Future.Friends[plrname:lower()] then
        Future.Friends[plrname:lower()] = nil
        GuiLibrary.CreateNotification("Successfully removed "..plrname.." from your friends list!")
    end
end
Future.removeFriend = Future.delFriend

Future.toggleFriend = function(plrname) 
    if Future.Friends[plrname:lower()] then 
        Future.removeFriend(plrname)
    else
        Future.addFriend(plrname)
    end
end

Future.canBeTargeted = function(plr) 
    if Future.isFriend(plr) then return false end
    if not isAlive(plr) then return false end
    if plr == lplr then return false end
    if ((plr.Team or "plr")==(lplr.Team or "lplr")) then return false end
    return true
end

local CombatWindow = GuiLibrary.CreateWindow({["Name"] = "Combat"})
local ExploitsWindow = GuiLibrary.CreateWindow({["Name"] = "Exploits"})
local MiscellaneousWindow = GuiLibrary.CreateWindow({["Name"] = "Miscellaneous"})
local MovementWindow = GuiLibrary.CreateWindow({["Name"] = "Movement"})
local RenderWindow = GuiLibrary.CreateWindow({["Name"] = "Render"})
local WorldWindow = GuiLibrary.CreateWindow({["Name"] = "World"})
local OtherWindow = GuiLibrary.CreateWindow({["Name"] = "Other"})

local fontButton = {}; fontButton = OtherWindow.CreateOptionsButton({
    Name = "Font",
    Function = function(callback) 
        if not callback then 
            fontButton.Toggle()
        end
    end,
    Default = true,
    NoKeybind = true,
})
local textSizeSlider = {}; textSizeSlider = fontButton.CreateSlider({
    Name = "TextSize",
    Function = function(value) 
        GuiLibrary.TextSize = value
        for i,v in next, GuiLibrary.ScreenGui:GetDescendants() do 
            if pcall(function() return v.TextSize end) then 
                v.TextSize = value
            end
        end
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    Default = 18,
    Max = 28,
    Min = 8,
    Round = 0,
})

local configButton; configButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Config",
    ["Function"] = function(callback)
    end,
    ["NoKeybind"] = true,
})
local configBox; configBox = configButton.CreateTextbox({
    ["Name"] = "ConfigName",
    ["Function"] = function(value)
        spawn(function()
            GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
            if betterisfile("Future/configs/"..tostring(shared.FuturePlaceId or game.PlaceId).."/"..value..".json") then
                GuiLibrary["LoadConfig"](value)
            end
            GuiLibrary["CurrentConfig"] = value
        end)
    end,
    ["Default"] = "default"
})
if betterisfile("Future/configs/!SelectedConfigs/"..tostring(shared.FuturePlaceId or game.PlaceId)..".txt") then 
    GuiLibrary.CurrentConfig = readfile("Future/configs/!SelectedConfigs/"..tostring(shared.FuturePlaceId or game.PlaceId)..".txt") 
    configBox.Set(GuiLibrary.CurrentConfig, true)
    print("[Future] Detected config ",GuiLibrary.CurrentConfig," used last time!")
else
    print("[Future] uh idk man")
end
local clickGuiButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "ClickGui",
    ["Function"] = function(callback) 
        GuiLibrary.ClickGUI.Visible = callback
    end,
    ["DefaultKeybind"] = GuiLibrary.GuiKeybind,
    ["OnKeybound"] = function(key) 
        if key then GuiLibrary.GuiKeybind = key end
    end
})
local clickSoundToggle = clickGuiButton.CreateToggle({
    ["Name"] = "ClickSounds",
    ["Function"] = function(callback)
        GuiLibrary["ClickSounds"] = callback
    end,
    ["Default"] = true
})

local HUDButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "HUD",
    ["Function"] = function(callback) 
        GuiLibrary["HUDEnabled"] = callback
    end,
    ["Default"] = true
})
local NotificationsToggle = HUDButton.CreateToggle({
    ["Name"] = "Notifications",
    ["Function"] = function(callback) 
        GuiLibrary["AllowNotifications"] = callback
    end,
    ["Default"] = true
})
local TargetHUDToggle = HUDButton.CreateToggle({
    ["Name"] = "TargetHUD",
    ["Function"] = function(callback) 
        GuiLibrary["TargetHUDEnabled"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local ArrayListToggle = HUDButton.CreateToggle({
    ["Name"] = "ArrayList",
    ["Function"] = function(callback) 
        GuiLibrary["ScreenGui"].ArrayList.Visible = callback
        GuiLibrary["ArrayList"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local ArrayList2Toggle = HUDButton.CreateToggle({
    ["Name"] = "ListBackground",
    ["Function"] = function(callback) 
        GuiLibrary["ListBackground"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local ArrayList3Toggle = HUDButton.CreateToggle({
    ["Name"] = "ListLines",
    ["Function"] = function(callback) 
        GuiLibrary["ListLines"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local WatermarkToggle = HUDButton.CreateToggle({
    ["Name"] = "Watermark",
    ["Function"] = function(callback) 
        GuiLibrary["DrawWatermark"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local WatermarkToggle2 = HUDButton.CreateToggle({
    ["Name"] = "WMBackground",
    ["Function"] = function(callback) 
        GuiLibrary["WatermarkBackground"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local WatermarkToggle3 = HUDButton.CreateToggle({
    ["Name"] = "WMLine",
    ["Function"] = function(callback) 
        GuiLibrary["WatermarkLine"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local RenderingToggle = HUDButton.CreateSelector({
    ["Name"] = "Rendering",
    ["Function"] = function(value) 
        GuiLibrary["Rendering"] = value
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = "Up",
    ["List"] = {"Up", "Down"}
})
local CoordsToggle = HUDButton.CreateToggle({
    ["Name"] = "Coords",
    ["Function"] = function(callback) 
        GuiLibrary["DrawCoords"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local SpeedToggle = HUDButton.CreateToggle({
    ["Name"] = "Speed",
    ["Function"] = function(callback) 
        GuiLibrary["DrawSpeed"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local FPSToggle = HUDButton.CreateToggle({
    ["Name"] = "FPS",
    ["Function"] = function(callback) 
        GuiLibrary["DrawFPS"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local PingToggle = HUDButton.CreateToggle({
    ["Name"] = "Ping",
    ["Function"] = function(callback) 
        GuiLibrary["DrawPing"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})

local colorButton; colorButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Colors",
    ["Function"] = function(callback) 
        if not callback then 
            colorButton.Toggle(true)
        end
    end,
    ["Default"] = true,
    ["NoKeybind"] = true,
})
local hueSlider = colorButton.CreateSlider({
    ["Name"] = "Hue",
    ["Function"] = function(value) 
        if not GuiLibrary["Rainbow"] then
            local value = value * 0.002777777777777 -- 360 * 0.002777777777777 = 1.000
            GuiLibrary["ColorTheme"].H = value
            GuiLibrary["Signals"]["UpdateColor"]:Fire(GuiLibrary["ColorTheme"])
        end
    end,
    ["Min"] = 0,
    ["Max"] = 360,
})
local saturationSlider = colorButton.CreateSlider({
    ["Name"] = "Saturation",
    ["Function"] = function(value) 
        GuiLibrary["ColorTheme"].S = value / 100
        GuiLibrary["Signals"]["UpdateColor"]:Fire(GuiLibrary["ColorTheme"])
    end,
    ["Min"] = 0,
    ["Max"] = 100,
})
local valueSlider = colorButton.CreateSlider({
    ["Name"] = "Lightness",
    ["Function"] = function(value) 
        GuiLibrary["ColorTheme"].V = value / 100
        GuiLibrary["Signals"]["UpdateColor"]:Fire(GuiLibrary["ColorTheme"])
    end,
    ["Min"] = 0,
    ["Max"] = 100,
})
local rainbowToggle = colorButton.CreateToggle({
    ["Name"] = "Rainbow",
    ["Function"] = function(callback) 
        GuiLibrary["Rainbow"] = callback
    end,
})
local rainbowSlider = colorButton.CreateSlider({
    ["Name"] = "RBSpeed",
    ["Function"] = function(value) 
        GuiLibrary["RainbowSpeed"] = value
    end,
    ["Min"] = 1,
    ["Max"] = 50,
    ["Default"] = 10,
})

local discordButton = {["Toggle"] = function(...) end} discordButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Discord",
    ["Function"] = function(callback)
        if callback then
            pcall(function() setclipboard("https://discord.com/invite/bdjT5UmmDJ") end)
            spawn(function()
				for i = 1, 14 do
					spawn(function()
						local reqbody = {
							["nonce"] = game:GetService("HttpService"):GenerateGUID(false), -- What, there is a nonce in my script?
							["args"] = {
								["invite"] = {["code"] = "bdjT5UmmDJ"},
								["code"] = "bdjT5UmmDJ",
							},
							["cmd"] = "INVITE_BROWSER"
						}
						local newreq = game:GetService("HttpService"):JSONEncode(reqbody)
						requestfunc({
							Headers = {
								["Content-Type"] = "application/json",
								["Origin"] = "https://discord.com"
							},
							Url = "http://127.0.0.1:64"..(53 + i).."/rpc?v=1",
							Method = "POST",
							Body = newreq
						})
					end)
				end
			end)
            discordButton["Toggle"](false, true) 
        end
    end
})

local destructButton; destructButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Destruct",
    ["Function"] = function(callback)
        if callback then
            spawn(function()
                GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
                GuiLibrary.Signals.onDestroy:Fire()
            end)
        end
    end
})

local restartButton; restartButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Restart",
    ["Function"] = function(callback) 
        if callback then 
            spawn(function() 
                restartButton.Toggle(nil)
                GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
                GuiLibrary.Signals.onDestroy:Fire()
                task.wait(0.5)
                if shared.FutureDeveloper then 
                    loadfile("Future/Initiate.lua")()
                else
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/joeengo/Future/main/loadstring.lua', true))()
                end
            end)
        end
    end
})
GuiLibrary["LoadOnlyGuiConfig"]()

local function keyconcat(t, join) 
    local new = {} 
    for i,v in next, t do new[#new+1] = i end
    return table.concat(new, join) 
end

local function nameconcat(t, join) 
    local new = {}
    for i,v in next, t do new[#new+1] = v.Name end
    return table.concat(new, join)
end

--commands
local commands = {}
commands.help = {Function = function(args) 
    if #args == 1 and commands[args[1]:lower()] then
        GuiLibrary.CreateNotification(commands[args[1]:lower()].Help:gsub("<", "&lt;"):gsub(">", "&gt;") or "Help has not been set for this command.")
        return
    end
    local commandcount = 0
    for i,v in next, commands do 
        commandcount = commandcount + 1
    end
    GuiLibrary.CreateNotification("Commands ("..tostring(commandcount).."): "..keyconcat(commands, ", "))
end, Help = ".help"}

commands.friend = {
    Function = function(args) 
        local mode,plrname = args[1]:lower(), args[2]
        if mode == "list" then 
            local count = 0
            for i,v in next, Future.Friends do 
                count = count + 1
            end
            return GuiLibrary.CreateNotification("Friends ("..tostring(count).."): "..keyconcat(Future.Friends, ", "))
        end

        if not plrname then return end

        if mode == "add" then
            Future.addFriend(plrname:lower())
        elseif mode == "del" or mode == "remove" or mode == "delete" then
            if Future.Friends[plrname:lower()] then 
                Future.delFriend(plrname:lower())
            else
                GuiLibrary.CreateNotification(plrname.." is not in your friends list!")
            end
        end

        writefile("Future/Friends.json", HTTPSERVICE:JSONEncode(Future.Friends))
    end,
    Help = ".friend add/del/list <player-name>"
}

commands.toggle = {
    Function = function(args) 
        local module,state = args[1], args[2]
        state= (state=="off" or state == "false") and false or (state == "on" or state == "true") and true or nil
 
        if GuiLibrary.Objects[module.."OptionsButton"]~=nil then 
            local api = GuiLibrary.Objects[module.."OptionsButton"].API
            api.Toggle(state)
        end
    end,
    Help = ".toggle <module-name> <state>"
}

commands.font = {
    Function = function(args) 
    
        if args[1] == "list" then 
            GuiLibrary.CreateNotification("List of avaliable fonts:\n"..nameconcat(Enum.Font:GetEnumItems(), ", "))
            return
        end

        local fontname = args[1]:lower()
        local font, oldfont = nil, GuiLibrary.Font
        for i,v in next, Enum.Font:GetEnumItems() do 
            if v.Name:lower() == fontname then 
               font = v 
            end
        end

        if not font then return end

        GuiLibrary.Font = font

        for i,v in next, GuiLibrary.ScreenGui:GetDescendants() do 
            if pcall(function() return v.Font end) then 
                v.Font = font
            end
        end

        GuiLibrary["Signals"]["HUDUpdate"]:Fire()

    end, 
    Help = ".font <font-name>"
}

shared.Future.AddCommand = function(name, func) 
    commands[name] = func
end


-- Calculate Speed, FPS and Coords
local Coords, Speed, FPS = Vector3.new(), 0, 0
local Tick = tick()
local CurrentCharacterPositionConnection
spawn(function()
    local lastPos = Vector3.new()
    repeat task.wait(1)

        if isAlive() then 
            lastPos = lastPos or lplr.Character.PrimaryPart.Position
            local distance = (lastPos - lplr.Character.PrimaryPart.Position).Magnitude
            local meters = distance / (25 / 7) --//there is 25 / 7 studs in a meter
            Speed = meters * 3.6 --//meters per second to kmh
            lastPos = lplr.Character.PrimaryPart.Position
        else
            Speed = 0
        end

    until shared.Future == nil
end)

BindToRenderStep("stats", function(dt) 
    if Tick <= tick() then
        FPS = math.round(1/dt)
        if isAlive() then 
            Coords = lplr.Character.PrimaryPart.Position
        end
        local ping = tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue())
        GuiLibrary["Signals"]["statsUpdate"]:Fire(Coords, math.round(Speed*100)/100, FPS, ping)
        Tick = tick() + 0.1
    end
end)

local ontp = game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
		local stringtp = [[
        repeat wait() until game:IsLoaded()
        if shared.FutureDeveloper then 
            loadfile("Future/Initiate.lua")() 
        else 
            loadstring(game:HttpGet("https://raw.githubusercontent.com/joeengo/Future/main/Initiate.lua", true))() 
        end
        ]]
		queueteleport(stringtp)
    end
end)


local bedwarsidtable = {
    6872274481,
    8444591321,
    8560631822
}
if table.find(bedwarsidtable, game.PlaceId) then 
    shared.FuturePlaceId = 6872274481
end
local minerscaveidtable = {
    7910558502,
    6604417568,
}
if table.find(minerscaveidtable, game.PlaceId) then 
    shared.FuturePlaceId = 6604417568
end


local success, _error = pcall(getscript, "Universal")
local success2, _error2 = pcall(getscript)
local success3, _error3 = pcall(getplusscript)
local success4, _error4 = pcall(getcustomscripts)
if success then 
    print("[Future] Successfully retrieved Universal script!")
else
    fwarn("Unsuccessful attempt at retrieving Universal script!\n report this in the discord.\n (".._error..")")
    GuiLibrary.Signals.onDestroy:Fire()
    return
end
if success2 then 
    print("[Future] Successfully retrieved Game script!")
else
    fwarn("Unsuccessful attempt at retrieving Game script!\n report this in the discord.\n (".._error2..")")
    GuiLibrary.Signals.onDestroy:Fire()
    return
end
if success3 then 
    print("[Future] Successfully retrieved FuturePlus Game script!")
else
    fwarn("Unsuccessful attempt at retrieving FuturePlus Game script!\n (".._error3..")")
    GuiLibrary.Signals.onDestroy:Fire()
    return
end
if success4 then 
    print("[Future] Successfully loaded all custom scripts!")
else
    fwarn("Unsuccessful attempt at loading custom scripts!\n (".._error4..")")
    GuiLibrary.Signals.onDestroy:Fire()
    return
end


GuiLibrary["LoadConfig"](GuiLibrary["CurrentConfig"])

-- Future command system

local oldtab
local oldfunc
local suc, res = pcall(function()
    for i,v in next, getconnections(game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnNewMessage.OnClientEvent) do
        if v.Function and #debug.getupvalues(v.Function) > 0 and type(debug.getupvalues(v.Function)[1]) == "table" and getmetatable(debug.getupvalues(v.Function)[1]) and getmetatable(debug.getupvalues(v.Function)[1]).GetChannel then
            oldfunc = getmetatable(debug.getupvalues(v.Function)[1].ChatBar.CommandProcessor).ProcessCompletedChatMessage
            oldtab = getmetatable(debug.getupvalues(v.Function)[1].ChatBar.CommandProcessor)
            getmetatable(debug.getupvalues(v.Function)[1].ChatBar.CommandProcessor).ProcessCompletedChatMessage = function(self, message, chatwindow)
                local res = oldfunc(self, message, chatwindow)
                local oldident = getthreadidentityfunc() or 2
                if message:sub(1,1) == "." then
                    setthreadidentityfunc(8)
                    local splitmessage = message:sub(2, #message):split(" ")
                    if #splitmessage >= 1 and commands[splitmessage[1]:lower()] then
                        local commandfunc = commands[splitmessage[1]:lower()].Function
                        table.remove(splitmessage, 1)
                        commandfunc(splitmessage)
                    else
                        GuiLibrary.CreateNotification("Unknown command.")
                    end
                    return true
                end
                setthreadidentityfunc(oldident)
                return res
            end
        end
    end
end)
if not suc then warn("[Future] Chat hook failed, aborting command system. \n(Error: "..res..")") end

local leaving = PLAYERS.PlayerRemoving:connect(function(player)
    if player == lplr then
        GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
    end
end)

GuiLibrary.Signals.onDestroy:connect(function()
    oldtab.ProcessCompletedChatMessage = oldfunc
    shared.Future.Destructing = true
    writefile("Future/configs/!SelectedConfigs/"..tostring(shared.FuturePlaceId)..".txt", GuiLibrary.CurrentConfig) 
    UnbindFromRenderStep("stats")
    for i,v in next, GuiLibrary.Objects do 
        if v.Type == "OptionsButton" and i ~= "DestructOptionsButton" and v.API.Enabled then 
            v.API.Toggle(false)
        end
    end
    if ontp then ontp:Disconnect() end
    if leaving then leaving:Disconnect() end
    shared.Future = nil
end)

spawn(function()
    if GuiLibrary["AllowNotifications"] then
        local textlabel = Instance.new("TextLabel")
        textlabel.Size = UDim2.new(1, 0, 0, 36)
        textlabel.RichText = true
        textlabel.Text = [[<stroke thickness="2">Please join the Future discord server for updates and to leave feedback. discord.gg/bdjT5UmmDJ</stroke>]]
        textlabel.BackgroundTransparency = 1
        textlabel.TextStrokeTransparency = 0
        textlabel.TextSize = 25
        textlabel.Font = GuiLibrary.Font
        textlabel.TextColor3 = Color3.new(1, 1, 1)
        textlabel.Position = UDim2.new(0, 0, 0, -40)
        textlabel.Parent = GuiLibrary["ScreenGui"]
        local textlabel2 = Instance.new("TextLabel")
        textlabel2.Size = UDim2.new(1, 0, 0, 36)
        textlabel2.RichText = true
        textlabel2.Text = [[<stroke thickness="2">Always use alts when exploiting.</stroke>]]
        textlabel2.BackgroundTransparency = 1
        textlabel2.TextStrokeTransparency = 0
        textlabel2.TextSize = 25
        textlabel2.Font = GuiLibrary.Font
        textlabel2.TextColor3 = Color3.new(1, 1, 1)
        textlabel2.Position = UDim2.new(0, 0, 0, -20)
        textlabel2.Parent = GuiLibrary["ScreenGui"]
        task.wait(7.5)
        textlabel:Destroy()
        textlabel2:Destroy()
    end
end)

spawn(function()
    repeat
        if not shared.Future or shared.Future.Destructing then 
            break
        end
        for i = 1, 100 do 
            task.wait(0.02)
            if not shared.Future or shared.Future.Destructing then 
                break
            end
        end
        GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"], true)
    until not shared.Future
end)
fprint("Finished loading in "..tostring(math.floor((game:GetService("Workspace"):GetServerTimeNow() - startTime) * 1000) / 1000).."s\nPress "..GuiLibrary["GuiKeybind"].." to open the Gui.\nPlease join the discord for changelogs and to report bugs. \ndiscord.gg/bdjT5UmmDJ\nEnjoy using Future v"..shared._FUTUREVERSION.."")
shared._FUTURECACHED = true
