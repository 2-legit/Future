repeat task.wait() until game:IsLoaded()
local Future = shared.Future
local GuiLibrary = Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")
local HTTPSERVICE = game:GetService("HttpService")
local COLLECTION = game:GetService("CollectionService")
local lplr = PLAYERS.LocalPlayer
local mouse = lplr:GetMouse()
local cam = WORKSPACE.CurrentCamera
local getcustomasset = --[[getsynasset or getcustomasset or]] GuiLibrary.getRobloxAsset
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
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
local bedwars = {} 
local Reach = {Enabled = false}
local ViewModel = {Enabled = false} 
local oldisnetworkowner = isnetworkowner
local isnetworkowner = isnetworkowner or function(part) 
    return gethiddenproperty(part, "NetworkOwnershipRule") == Enum.NetworkOwnership.Automatic
end
local printtable = printtable or print
local whitelisted = {}
local storedshahashes = {}
pcall(function()
	whitelisted = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/whitelists/main/whitelist2.json", true))
end)
local antivoidpart
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
    if req.StatusCode == 404 then error("404 Not Found") end
    return req.Body
end 
local shalib = loadstring(requesturl("lib/sha.lua"))()
local savedc0 = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Viewmodel"):WaitForChild("RightHand"):WaitForChild("RightWrist").C0
local setc0

local FakeRoot, RealRoot -- fake is client sided
local AnticheatAssist = {}
local AnticheatAssistConstants = {
    MaxDistance = 20,
    -- normal
    Delay = 0.125,
    Lerp = 0.39,
    TPDelay = 0.1,
    -- combat
    CombatDelay = 0.1,
    CombatLerp = 0.5,
    CombatTPDelay = 0,
}

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

local HeartbeatTable = {}
local RenderStepTable = {}
local SteppedTable = {}
local function isAlive(plr)
    local plr = plr or lplr
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid")) and (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) and (plr.Character:FindFirstChild("HumanoidRootPart")) and (plr.Character:FindFirstChild("Head"))) then
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
    GuiLibrary.CreateNotification("<font color='rgb(255, 10, 10)'>[ERROR]"..str.."</font>")
    error("[Future]"..str)
end

local function fwarn(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    warn("[Future]"..str)
    GuiLibrary.CreateNotification("<font color='rgb(255, 255, 10)'>[WARNING] "..str.."</font>")
end

local function fprint(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    print("[Future]"..str)
    GuiLibrary.CreateNotification("<font color='rgb(200, 200, 200)'>"..str.."</font>")
end

local function betterfind(tab, obj)
    for i,v in next, (tab) do
        if v == obj or type(v) == "table" and v.hash == obj then
            return v
        end
    end
    return nil
end

local function getconnectionproto(func, level, con) 
    local proto = debug.getproto(func, level)
    local info = debug.getinfo(proto)
    
    local old = getthreadidentityfunc and getthreadidentityfunc() or 8
    setthreadidentityfunc(2)
    for i,v in next, getconnections(con) do 
        local coninfo = debug.getinfo(v.Function)
        if v.Function and coninfo.src == info.src and coninfo.numparams == info.numparams and coninfo.currentline == info.currentline then 
            return v.Function
        end
    end
    setthreadidentityfunc(old)
end


local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end

local function getremote(t)
    for i,v in next, t do 
        if v == "Client" then 
            return t[i+1]
        end
    end
end

local function getPlrNear(max)
    local returning, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local diff = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if diff < nearestnum then 
                nearestnum = diff 
                returning = v
            end
        end
    end
    return returning
end

local function getLowestHpPlrNear(max) 
    local returning, lowestnum = nil, 9999999999
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local diff = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            local health = v.Character:GetAttribute("Health")
            if diff < max and health < lowestnum then 
                lowestnum = health 
                returning = v
            end
        end
    end
    return returning
end

local function getPlrNearMouse(max)
    local max = max or 99999999999999
    local nearestval, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local pos, vis = WORKSPACE.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if vis and pos then 
                local diff = (UIS:GetMouseLocation() - Vector2.new(pos.X, pos.Y)).Magnitude
                if diff < nearestnum then 
                    nearestnum = diff 
                    nearestval = v
                end
            end
        end
    end
    return nearestval
end

local function getAllPlrsNear(max)
    if not isAlive() then return {} end
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            if v.Character.HumanoidRootPart and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude <= max then 
                table.insert(t, v)
            end
        end
    end
    return t
end

local function canBeTargeted(plr, doTeamCheck) 
    return Future.canBeTargeted(plr)
end

local function getMoveDirection(plr) 
    if not isAlive(plr) then return Vector3.new() end
    local velocity = plr.Character.HumanoidRootPart:GetVelocityAtPosition(plr.Character.HumanoidRootPart.Position)
    local velocityDirection = velocity.Magnitude > 0 and velocity.Unit or Vector3.new()
    return velocityDirection
end

local function getwool()
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5.itemType:match("wool") then
			return v5.itemType, v5.amount
		end
	end	
	return nil
end

local function getwoolamt()
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5.itemType:match("wool") then
			return v5.amount
		end
	end	
	return 0
end

local function getblockitem() 
    for i5, v5 in pairs(bedwars.getInventory(lplr).items) do
        if v5.itemType:match("wool") or v5.itemType:match("grass") or v5.itemType:match("stone_brick") or v5.itemType:match("wood_plank") or v5.itemType:match("stone") or v5.itemType:match("bedrock") or v5.itemType:match("tnt") then
			return v5.itemType, v5.amount
		end
	end	
	return nil
end

local function getItem(itemName)
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5.itemType == itemName then
			return v5, i5
		end
	end
	return nil
end

local function getItemAmt(itemName)
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5.itemType == itemName then
			return v5.amount
		end
	end
	return 0
end

local function hashvector(vec)
	return {
		value = vec
	}
end

-- Huge thanks to 7granddad for this code, i dont see a point in writing this all my self when I know exactly what it does, it would just be alot of labour and work lel.

local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
repeat task.wait() until Flamework.isInitialized
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.controllers.game["block-break-controller"]).BlockBreakController.onEnable, 1)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
local OldClientGet = getmetatable(Client).Get
local OldClientWaitFor = getmetatable(Client).WaitFor
getmetatable(Client).Get = function(Self, remotename)
    if remotename == bedwars["AttackRemote"] then
        local res = OldClientGet(Self, remotename)
        return {
            ["instance"] = res["instance"],
            ["CallServer"] = function(Self, tab)
                if Reach["Enabled"] then
                    local mag = (tab.validate.selfPosition.value - tab.validate.targetPosition.value).magnitude
                    local newres = hashvector(tab.validate.selfPosition.value + (mag > 14.4 and (CFrame.lookAt(tab.validate.selfPosition.value, tab.validate.targetPosition.value).lookVector * 4) or Vector3.new(0, 0, 0)))
                    tab.validate.selfPosition = newres
                end
                local suc, plr = pcall(function() return PLAYERS:GetPlayerFromCharacter(tab.entityInstance) end)
                if suc and plr then
                    if plr and (bedwars["CheckWhitelisted"](plr) and bedwars["CheckWhitelisted"](lplr) == nil) then
                        return nil
                    end
                end
                return res:CallServer(tab)
            end
        }
    end
    return OldClientGet(Self, remotename)
end

bedwars = {
    ["CheckWhitelisted"] = function(plr, ownercheck)
        local plrstr = bedwars["HashFunction"](plr.Name..plr.UserId)
        local localstr = bedwars["HashFunction"](lplr.Name..lplr.UserId)
        return ((ownercheck == nil and (betterfind(whitelisted.players, plrstr) or betterfind(whitelisted.owners, plrstr)) or ownercheck and betterfind(whitelisted.owners, plrstr))) and betterfind(whitelisted.owners, localstr) == nil and true or false
    end,
    ["CheckPlayerType"] = function(plr)
        local plrstr = bedwars["HashFunction"](plr.Name..plr.UserId)
        local playertype = "DEFAULT"
        if betterfind(whitelisted.players, plrstr) then
            playertype = "PRIVATE"
        end
        if betterfind(whitelisted.owners, plrstr) then
            playertype = "OWNER"
        end
        return playertype
    end,
    ["HashFunction"] = function(str)
        if storedshahashes[tostring(str)] == nil then
            storedshahashes[tostring(str)] = shalib.sha512(tostring(str).."SelfReport")
        end
        return storedshahashes[tostring(str)]
    end,
    ["IsPrivateIngame"] = function()
        for i,v in pairs(PLAYERS:GetChildren()) do 
            if bedwars["CheckPlayerType"](v) ~= "DEFAULT" then 
                return true
            end
        end
        return false
    end,
    ["AnimationUtil"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
    ["AngelUtil"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.kit.kits.angel["angel-kit"]),
    ["AppController"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
    ["BalloonController"] = KnitClient.Controllers.BalloonController,
    ["BlockController"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
    ["BlockController2"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
    ["BlockTryController"] = getrenv()._G[game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]],
    ["BlockEngine"] = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
    ["BlockEngineClientEvents"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
    ["BlockPlacementController"] = KnitClient.Controllers.BlockPlacementController,
    ["BedwarsKits"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.kit["bedwars-kit-shop"]).BedwarsKitShop,
    ["BlockBreaker"] = KnitClient.Controllers.BlockBreakController.blockBreaker,
    ["BowTable"] = KnitClient.Controllers.ProjectileController,
    ["ProjectileController"] = KnitClient.Controllers.ProjectileController,
    ["ChestController"] = KnitClient.Controllers.ChestController,
    ["ClickHold"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]).ClickHold,
    ["ClientHandler"] = Client,
    ["ClientHandlerDamageBlock"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.remotes).BlockEngineRemotes.Client,
    ["ClientStoreHandler"] = require(game.Players.LocalPlayer.PlayerScripts.TS.ui.store).ClientStore,
    ["ClientHandlerSyncEvents"] = require(lplr.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents,
    ["CombatConstant"] = require(game:GetService("ReplicatedStorage").TS.combat["combat-constant"]).CombatConstant,
    ["CombatController"] = KnitClient.Controllers.CombatController,
    ["ConsumeSoulRemote"] = getremote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
    ["ConstantManager"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]).ConstantManager,
    ["CooldownController"] = KnitClient.Controllers.CooldownController,
    ["SharedConstants"] = require(game:GetService("ReplicatedStorage").TS["shared-constants"]),
    ["damageTable"] = KnitClient.Controllers.DamageController,  
    ["DetonateRavenRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.RavenController).detonateRaven)),
    ["DefaultProjectileSourceController"] = require(lplr.PlayerScripts.TS.controllers.global.combat.projectile["default-projectile-source-controller"]).DefaultProjectileSourceController,
    ["DropItem"] = getmetatable(KnitClient.Controllers.ItemDropController).dropItemInHand,
    ["DropItemRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.ItemDropController).dropItemInHand)),
    ["EatRemote"] = getremote(debug.getconstants(debug.getproto(getmetatable(KnitClient.Controllers.ConsumeController).onEnable, 1))),
    ["EquipItemRemote"] = getremote(debug.getconstants(debug.getprotos(shared.oldequipitem or require(game:GetService("ReplicatedStorage").TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem)[3])),
    ["FishermanTable"] = KnitClient.Controllers.FishermanController,
    ["GameAnimationUtil"] = require(game:GetService("ReplicatedStorage").TS.animation["animation-util"]).GameAnimationUtil,
    ["GamePlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
    ["getEntityTable"] = require(game:GetService("ReplicatedStorage").TS.entity["entity-util"]).EntityUtil,
    ["getIcon"] = function(item, showinv)
        local itemmeta = bedwars["getItemMetadata"](item.itemType)
        if itemmeta and showinv then
            return itemmeta.image
        end
        return ""
    end,
    ["getInventory"] = function(plr)
        local plr = plr or lplr
        local suc, result = pcall(function() return InventoryUtil.getInventory(plr) end)
        return (suc and result or {
            ["items"] = {},
            ["armor"] = {},
            ["hand"] = nil
        })
    end,
    ["getItemMetadata"] = require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta,
    ["GrimReaperController"] = KnitClient.Controllers.GrimReaperController,
    ["GuitarHealRemote"] = getremote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
    ["HighlightController"] = KnitClient.Controllers.EntityHighlightController,
    ["ItemTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
    ["JuggernautRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getprotos(KnitClient.Controllers.JuggernautController.KnitStart)[1])[4])),
    ["KatanaController"] = KnitClient.Controllers.KatanaController,
    ["KatanaRemote"] = getremote(debug.getconstants(debug.getproto(KnitClient.Controllers.DaoController.onEnable, 4))),
    ["KnockbackTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1),
    ["KnockbackTable2"] = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,
    ["LobbyClientEvents"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"].lobby.out.client.events).LobbyClientEvents,
    ["MissileController"] = KnitClient.Controllers.GuidedProjectileController,
    ["MinerRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getproto(getmetatable(KnitClient.Controllers.MinerController).onKitEnabled, 1))[2])),
    ["MinerController"] = KnitClient.Controllers.MinerController,
    ["PickupRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.ItemDropController).checkForPickup)),
    ["PlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
    ["ProjectileMeta"] = require(game:GetService("ReplicatedStorage").TS.projectile["projectile-meta"]).ProjectileMeta,
    ["QueueMeta"] = require(game:GetService("ReplicatedStorage").TS.game["queue-meta"]).QueueMeta,
    ["QueryUtil"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
    ["prepareHashing"] = require(game:GetService("ReplicatedStorage").TS["remote-hash"]["remote-hash-util"]).RemoteHashUtil.prepareHashVector3,
    ["ProjectileRemote"] = getremote(debug.getconstants(debug.getupvalues(getmetatable(KnitClient.Controllers.ProjectileController)["launchProjectileWithValues"])[2])),
    ["ProjectileSourceController"] = require(lplr.PlayerScripts.TS.controllers.global.combat.projectile["projectile-source-controller"]).ProjectileSourceController,
    ["RavenTable"] = KnitClient.Controllers.RavenController,
    ["RespawnController"] = KnitClient.Controllers.BedwarsRespawnController,
    ["RespawnTimer"] = require(lplr.PlayerScripts.TS.controllers.games.bedwars.respawn.ui["respawn-timer"]).RespawnTimerWrapper,
    ["ResetRemote"] = getremote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
    ["Roact"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["roact"].src),
    ["RuntimeLib"] = require(game:GetService("ReplicatedStorage")["rbxts_include"].RuntimeLib),
    ["Shop"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
    ["TeamUpgrades"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.TeamUpgrades,
    ["ShopItems"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 2),
    ["ShopRight"] = require(lplr.PlayerScripts.TS.controllers.games.bedwars.shop.ui["item-shop"]["shop-left"]["shop-left"]).BedwarsItemShopLeft,
    ["SpawnRavenRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.RavenController).spawnRaven)),
    ["SoundManager"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
    ["SoundList"] = require(game:GetService("ReplicatedStorage").TS.sound["game-sound"]).GameSound,
    ["sprintTable"] = KnitClient.Controllers.SprintController,
    ["StopwatchController"] = KnitClient.Controllers.StopwatchController,
    ["SwingSword"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordAtMouse,
    ["SwingSwordRegion"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordInRegion,
    ["SwordController"] = KnitClient.Controllers.SwordController,
    ["TreeRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getprotos(KnitClient.Controllers.BigmanController.KnitStart)[2])[1])),
    ["TrinityRemote"] = getremote(debug.getconstants(debug.getproto(getmetatable(KnitClient.Controllers.AngelController).onKitEnabled, 1))),
    ["VictoryScreen"] = require(lplr.PlayerScripts.TS.controllers["game"].match.ui["victory-section"]).VictorySection,
    ["ViewmodelController"] = KnitClient.Controllers.ViewmodelController,
    ["WeldTable"] = require(game:GetService("ReplicatedStorage").TS.util["weld-util"]).WeldUtil,
    ["AttackRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])),
    ["VelocityUtil"]  = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["velocity-util"]).VelocityUtil, 
    ["ItemMeta"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
    ["PlayerVacuumRemote"] = getremote(debug.getconstants(debug.getproto(KnitClient.Controllers.PlayerVacuumController.onEnable, 4))),
    ["PingController"] = require(lplr.PlayerScripts.TS.controllers.game.ping["ping-controller"]).PingController,
    ["RaiseShieldRemote"] = getremote(debug.getconstants(KnitClient.Controllers.InfernalShieldController.constructor)),
}
local function getblock(pos)
	return bedwars["BlockController"]:getStore():getBlockAt(bedwars["BlockController"]:getBlockPosition(pos)), bedwars["BlockController"]:getBlockPosition(pos)
end

for i,v in pairs(debug.getupvalues(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])) do
    if tostring(v) == "AC" then
        bedwars["AttackHashTable"] = v
        for i2,v2 in pairs(v) do
            if i2:find("constructor") == nil and i2:find("__index") == nil and i2:find("new") == nil then
                bedwars["AttackHashFunction"] = v2
                bedwars["AttachHashText"] = i2
            end
        end
    end
end
local blocktable = bedwars["BlockController2"].new(bedwars["BlockEngine"], getwool())
bedwars["placeBlock"] = function(newpos, customblock)
    local placeblocktype = (customblock or getwool())
    blocktable.blockType = placeblocktype
    if bedwars["BlockController"]:isAllowedPlacement(lplr, placeblocktype, Vector3.new(newpos.X/3, newpos.Y/3, newpos.Z/3)) and getItem(placeblocktype) then
        return blocktable:placeBlock(Vector3.new(newpos.X/3, newpos.Y/3, newpos.Z/3))
    end
end

local function getBow()
	local bestsword, bestswordslot, bestswordnum = nil, nil, 0
	for i5, v5 in pairs(bedwars["getInventory"](lplr).items) do
		if v5.itemType:find("bow") then
			local tab = bedwars["ItemTable"][v5.itemType].projectileSource.ammoItemTypes
			local tab2 = tab[#tab]
			if bedwars["ProjectileMeta"][tab2].combat.damage > bestswordnum then
				bestswordnum = bedwars["ProjectileMeta"][tab2].combat.damage
				bestswordslot = i5
				bestsword = v5
			end
		end
	end
	return bestsword, bestswordslot
end

local function getItem(itemName)
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5.itemType == itemName then
			return v5, i5
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for i5, v5 in pairs(bedwars["ClientStoreHandler"]:getState().Inventory.observedInventory.hotbar) do
		if v5["item"] and v5["item"].itemType == itemName then
			return i5 - 1
		end
	end
	return nil
end

local function switchItem(tool, legit)
	if legit then
		bedwars["ClientStoreHandler"]:dispatch({
			type = "InventorySelectHotbarSlot", 
			slot = getHotbarSlot(tool.Name)
		})
	end
	pcall(function()
		lplr.Character.HandInvItem.Value = tool
	end)
	bedwars["ClientHandler"]:Get(bedwars["EquipItemRemote"]):CallServerAsync({
		hand = tool
	})
end

local function getBestTool(block)
    local tool = nil
	local toolnum = 0
	local blockmeta = bedwars["getItemMetadata"](block)
	local blockType = ""
	if blockmeta["block"] and blockmeta["block"]["breakType"] then
		blockType = blockmeta["block"]["breakType"]
	end
	for i,v in pairs(bedwars["getInventory"](lplr)["items"]) do
		local meta = bedwars["getItemMetadata"](v.itemType)
		if meta["breakBlock"] and meta["breakBlock"][blockType] then
			tool = v
			break
		end
	end
    return tool
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (isAlive() and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool["tool"]) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars["ClientStoreHandler"]:dispatch({
					type = "InventorySelectHotbarSlot", 
					slot = getHotbarSlot(tool.itemType)
				})
				task.wait(0.1)
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool["tool"])
		task.wait(0.1)
	end
end

local function getBeds() 
    local t = {}
    for i,v in next, COLLECTION:GetTagged("bed") do 
        if v.Name == "bed" then
            t[#t+1] = v
        end
    end
    return t
end

local function getotherbed(pos)
	local normalsides = {"Top", "Left", "Right", "Front", "Back"}
	for i,v in pairs(normalsides) do
		local bedobj = getblock(pos + (Vector3.FromNormalId(Enum.NormalId[v]) * 3))
		if bedobj and bedobj.Name == "bed" then
			return (pos + (Vector3.FromNormalId(Enum.NormalId[v]) * 3))
		end
	end
	return nil
end

local function isBlockCovered(pos)
    local normalsides = {"Top", "Left", "Right", "Front", "Back"}
	local coveredsides = 0
	for i, v in pairs(normalsides) do
		local blockpos = (pos + (Vector3.FromNormalId(Enum.NormalId[v]) * 3))
		local block = getblock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #normalsides
end

local function getallblocks(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getblock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock and extrablock.Parent ~= nil and (covered or covered == false and lastblock == nil) then
			if bedwars["BlockController"]:isBlockBreakable({["blockPosition"] = blockpos}, lplr) then
				table.insert(blocks, extrablock.Name)
			else
				table.insert(blocks, "unbreakable")
				break
			end
			lastfound = extrablock
			if covered == false then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getlastblock(pos, normal)
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getblock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock and extrablock.Parent ~= nil and (covered or covered == false and lastblock == nil) then
			lastfound = extrablock
			if covered == false then
				break
			end
		else
			break
		end
	end
	return lastfound
end

local function getbestside(pos)
	local softest = 1000000
	local softestside = Enum.NormalId.Top
	local normalsides = {"Top", "Left", "Right", "Front", "Back"}
	for i,v in pairs(normalsides) do
		local sidehardness = 0
		for i2,v2 in pairs(getallblocks(pos, v)) do	
			sidehardness = sidehardness + (((v2 == "unbreakable" or v2 == "bed") and 99999999 or bedwars["ItemTable"][v2]["block"] and bedwars["ItemTable"][v2]["block"]["health"]) or 10)
            if bedwars["ItemTable"][v2]["block"] and v2 ~= "unbreakable" and v2 ~= "bed" and v2 ~= "ceramic" then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars["ItemTable"][tool.itemType]["breakBlock"][bedwars["ItemTable"][v2]["block"]["breakType"]]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end
	end
	return softestside, softest
end

local healthbarblocktable = {
	["blockHealth"] = -1,
	["breakingBlockPosition"] = Vector3.new(0, 0, 0)
}
bedwars["breakBlock"] = function(pos, effects, normal, bypass)
    if lplr:GetAttribute("DenyBlockBreak") == true then
		return nil
	end
	local block = ((bypass == nil and getlastblock(pos, Enum.NormalId[normal])) or getblock(pos))
	local notmainblock = not ((bypass == nil and getlastblock(pos, Enum.NormalId[normal])))
    if block and bedwars["BlockController"]:isBlockBreakable({blockPosition = bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position))}, lplr) then
        if bedwars["BlockEngineClientEvents"].DamageBlock:fire(block.Name, bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position)), block):isCancelled() then
            return nil
        end
        local olditem = nil
		pcall(function()
			olditem = lplr.Character.HandInvItem.Value
		end)
        local blockhealthbarpos = {blockPosition = Vector3.new(0, 0, 0)}
        local blockdmg = 0
        if block and block.Parent ~= nil then
            switchToAndUseTool(block)
            blockhealthbarpos = {
                blockPosition = bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position))
            }
            if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
				local blockdata = bedwars["BlockController"]:getStore():getBlockData(blockhealthbarpos.blockPosition)
				if not blockdata then
					return nil
				end
				local blockhealth = blockdata:GetAttribute(lplr.Name .. "_Health")
				if blockhealth == nil then
					blockhealth = block:GetAttribute("Health");
				end
				healthbarblocktable.blockHealth = blockhealth
				healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
			end
            blockdmg = bedwars["BlockController"]:calculateBlockDamage(lplr, blockhealthbarpos)
            healthbarblocktable.blockHealth = healthbarblocktable.blockHealth - blockdmg
            if healthbarblocktable.blockHealth < 0 then
                healthbarblocktable.blockHealth = 0
            end
            bedwars["ClientHandlerDamageBlock"]:Get("DamageBlock"):CallServerAsync({
                blockRef = blockhealthbarpos, 
                hitPosition = (notmainblock and pos or block.Position), 
                hitNormal = Vector3.FromNormalId(Enum.NormalId[normal])
            }):andThen(function(p9)
				if p9 == "failed" then
					healthbarblocktable.blockHealth = healthbarblocktable.blockHealth + blockdmg
				end
			end)
            if effects then
				bedwars["BlockBreaker"]:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg)
                if healthbarblocktable.blockHealth <= 0 then
                    bedwars["BlockBreaker"].breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
                    bedwars["BlockBreaker"].healthbarMaid:DoCleaning()
                else
                    bedwars["BlockBreaker"].breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
                end
            end
        end
    end
end

local function isPointInMapOccupied(p)
    local region = Region3.new(p - Vector3.new(1, 1, 1), p + Vector3.new(1, 1, 1))
    local x = workspace:FindPartsInRegion3WithWhiteList(region, game:GetService("CollectionService"):GetTagged("block"))
    return (#x == 0)
end

local function get3Vector(p) 
    local x,y,z = p.X, p.Y,p.Z 
    x = math.floor((x) + 0.5)
    y = math.floor((y) + 0.5)
    z = math.floor((z) + 0.5)
    return Vector3.new(x,y,z)
end

local function getBestSword()
	local data, slot, bestdmg
    local items = bedwars.getInventory().items
	for i, v in next, items do
		if v.itemType:lower():find("sword") or v.itemType:lower():find("blade") then
			if bestdmg == nil or bedwars.ItemTable[v.itemType].sword.damage > bestdmg then
                data = v
				bestdmg = bedwars.ItemTable[v.itemType].sword.damage
				slot = i
			end
		end
	end
	return data, slot
end

local function state() 
    return bedwars["ClientStoreHandler"]:getState().Game.matchState
end
local states = {
    PRE = 0,
    RUNNING = 1,
    POST = 2
}

local function playsound(id, volume) 
    local sound = Instance.new("Sound")
    sound.Parent = workspace
    sound.SoundId = id
    sound.PlayOnRemove = true 
    if volume then 
        sound.Volume = volume
    end
    sound:Destroy()
end

local function playanimation(id) 
    if isAlive() then 
        local animation = Instance.new("Animation")
        animation.AnimationId = id
        local animatior = lplr.Character.Humanoid.Animator
        animatior:LoadAnimation(animation):Play()
    end
end

local nukerblocks = {}
local function getBlockNear(max, blocktab)
    local returning, nearestnum = nil, max
    for i,v in next, nukerblocks do 
        if isAlive() and table.find(blocktab, v.Name) and (v.Name=="bed" and v.Covers.BrickColor ~= lplr.TeamColor or v.Name~="bed") then
            local mag = (v.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            if mag < nearestnum then 
                nearestnum = mag
                returning = v
            end
        end
    end
    return returning
end

local removeNukerFunc, addNukerFunc = function(i,v) 
    local v = v==nil and i or v
    if v.Name == "bed" or v.Name:find("lucky_block") and table.find(nukerblocks, v) then 
        table.remove(nukerblocks, table.find(nukerblocks, v))
    end
end, function(i, v)
    local v = v==nil and i or v
    if v.Name == "bed" or v.Name:find("lucky_block") then 
        nukerblocks[#nukerblocks + 1] = v
    end
end
spawn(function()
    WORKSPACE:WaitForChild("Map")
    GuiLibrary.Connections[#GuiLibrary.Connections + 1] = COLLECTION:GetInstanceAddedSignal("block"):connect(addNukerFunc)
    GuiLibrary.Connections[#GuiLibrary.Connections + 1] = COLLECTION:GetInstanceRemovedSignal("block"):connect(removeNukerFunc)
    table.foreach(COLLECTION:GetTagged("block"), addNukerFunc)
end)

local function colorToRichText(color) 
    return " rgb("..tostring(color.R*255)..", "..tostring(color.G*255)..", "..tostring(color.B*255)..")"
end

local convertHealthToColor = function(health, maxHealth) 
    local percent = (health/maxHealth) * 100
    if percent < 70 then 
        return Color3.fromRGB(255, 196, 0)
    elseif percent < 45 then
        return Color3.fromRGB(255, 71, 71)
    end
    return Color3.fromRGB(96, 253, 48)
end

local function createAngleInc(Start, DefaultInc, Goal) 
	local i = Start or 0
	return function(Inc) 
		local Inc = Inc or DefaultInc or 1
		i = math.clamp(i + Inc, Start, Goal)
		return i
	end
end

local function circle(Self, Target, Radius, Delay, Speed, StopIf)
	local AngleInc = createAngleInc(0, Speed, 360)
	for i = 1, 360 / Speed do 
		local Angle = AngleInc(Speed)
		Self.CFrame = CFrame.new(Target.CFrame.p) * CFrame.Angles(0, math.rad(Angle), 0) * CFrame.new(0, 0.1, Radius)
		task.wait(Delay)
        if StopIf and StopIf() then
            return
        end
	end
end

local cancelViewmodel = false
local currentTarget
local isAuraTweening = false

-- // combat window

do 
    

    local AuraAnimationList = {

        Normal = {
            Animation = {
                {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
                {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.2}
            },  
            TweenTo = {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2}
		},

        Roll = {
            Animation = {
                {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
                {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(100)), Time = 0.2}
            },  
            TweenTo = {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2}
        },

        
        Shrink = {
            Animation = {
                {CFrame =  CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(360), math.rad(360), math.rad(360)), Time = 0.2},
                {CFrame =  CFrame.new(0.69, -0.71, 0.6), Time = 0.2},
            },  
            TweenTo = {CFrame =  CFrame.new(0.69, -0.71, 0.6), Time = 0.2},
        }

    }

    local AuraAnimations = {}
    for i,v in next, AuraAnimationList do 
        AuraAnimations[#AuraAnimations+1] = i
    end

    local AuraStrafe = {Enabled = false}
    local AuraShowTarget = {Enabled = false}
    local InstantKill = {Enabled = false}
    local AuraDistance = {Value = 18}
    local AuraAnimation = {Value = ""}
    local Aura = {Enabled = false}
    local TargetPart
    Aura = GuiLibrary.Objects.CombatWindow.API.CreateOptionsButton({
        Name = "Aura",
        Function = function(callback) 
            if callback then 
                TargetPart = TargetPart or Instance.new("Part")
                TargetPart.Color = Color3.fromRGB(200, 0, 0)
                TargetPart.Transparency = 0.6
                TargetPart.CanCollide = false
                TargetPart.Anchored = true

                spawn(function() -- Begin main attack loop
                    repeat task.wait()
                        if isAlive() then 
                            
                            local Root = RealRoot or lplr.Character.HumanoidRootPart

                            --[[local plrs = getAllPlrsNear(AuraDistance.Value-0.01)
                            if #plrs == 0 then
                                currentTarget = nil
                            end]]

                            local v = getLowestHpPlrNear(AuraDistance.Value - 0.01)
                            if not v then 
                                currentTarget = nil
                            end

                            --for i,v in next, plrs do 
                                if v and canBeTargeted(v) and not bedwars.CheckWhitelisted(v) then    
                                    currentTarget = v
                                    local weapon = getBestSword()
                                    local selfpos = Root.Position + (AuraDistance.Value > 14 and (Root.Position - v.Character.HumanoidRootPart.Position).magnitude > 14 and (CFrame.lookAt(Root.Position, v.Character.HumanoidRootPart.Position).lookVector * 4) or Vector3.new(0, 0, 0))
                                    local attackArgs = {
                                        ["weapon"] = weapon~=nil and weapon.tool,
                                        ["entityInstance"] = v.Character,
                                        ["validate"] = {
                                            ["raycast"] = {
                                                ["cameraPosition"] = hashvector(cam.CFrame.p), 
                                                ["cursorDirection"] = hashvector(Ray.new(cam.CFrame.p, v.Character.HumanoidRootPart.Position).Unit.Direction)
                                            },
                                            ["targetPosition"] = hashvector(v.Character.HumanoidRootPart.Position),
                                            ["selfPosition"] = hashvector(selfpos),
                                        }, 
                                        ["chargedAttack"] = {["chargeRatio"] = 1},
                                    }
                                    --spawn(function()
                                        local x = bedwars.ClientHandler:Get(bedwars["AttackRemote"]):CallServer(attackArgs)
                                        --print("Aura attack was successful:", x)
                                    --end)
                                    task.wait(1 / 3) -- was 0.03
                                end
                            --end
                        end
                    until not Aura.Enabled
                end)

                --[[
                spawn(function() 
                    repeat task.wait() 
                        if currentTarget then 
                            if AuraStrafe.Enabled then 
                                circle(lplr.Character.HumanoidRootPart, currentTarget.Character.HumanoidRootPart, 5, 0.5, 2, function() 
                                    if not Aura.Enabled or not AuraStrafe.Enabled then 
                                        return true
                                    end 
                                    if not currentTarget then 
                                        return true
                                    end
                                    return false
                                end)
                            end
                        end
                    until not Aura.Enabled
                end)]]

                spawn(function() -- Begin asynchronous background task loop
                    repeat task.wait()

                        setc0 = setc0 or savedc0

                        if currentTarget then

                            playanimation("rbxassetid://4947108314")

                            spawn(function() -- Animation asynchronous thread
                                cancelViewmodel = true

                                if not tweenedTo then 
                                    tweenedTo = true
                                    local v = AuraAnimationList[AuraAnimation.Value].TweenTo
                                    local Tween = game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = setc0 * v.CFrame})
                                    Tween:Play()
                                    task.wait(v.Time)
                                end

                                if not isAuraTweening then 
                                    isAuraTweening = true
                                    for i,v in next, AuraAnimationList[AuraAnimation.Value].Animation do 
                                        if not Aura.Enabled or not currentTarget then break end
                                        local Tween = game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = setc0 * v.CFrame})
                                        Tween:Play()
                                        task.wait(v.Time)
                                    end
                                    isAuraTweening = false
                                end
                            end)
                            
                            if currentTarget.Character then
                                pcall(function()
                                    GuiLibrary["TargetHUDAPI"].update(currentTarget, math.floor(currentTarget.Character:GetAttribute("Health")))
                                end)
                            end

                            if AuraShowTarget.Enabled then
                                local suc = pcall(function()
                                    TargetPart.Parent = workspace
                                    TargetPart.CFrame = currentTarget.Character:GetPrimaryPartCFrame()
                                    TargetPart.Size = currentTarget.Character:GetExtentsSize()
                                end)
                                if not suc then 
                                    TargetPart.Parent = nil
                                end
                            end

                        else
                            GuiLibrary["TargetHUDAPI"].clear()
                            TargetPart.Parent = nil
                            if tweenedTo then
                                cancelViewmodel = true
                                tweenedTo = false
                                local v = AuraAnimationList[AuraAnimation.Value].TweenTo
                                local Tween = game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = setc0})
                                Tween:Play()
                                task.wait(v.Time - 0.01)
                                cancelViewmodel = false
                            end
                        end

                    until not Aura.Enabled
                end)

            else
                local Tween = game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.2), {C0 = setc0})
                Tween:Play()
                tweenedTo = false
                isAuraTweening = false
                currentTarget = nil
            end
        end,
    })
    AuraDistance = Aura.CreateSlider({
        Name = "Range",
        Function = function(value) end,
        Min = 1,
        Max = 18,
        Default = 18,
        Round = 1,
    })
    AuraAnimation = Aura.CreateSelector({
        Name = "Anim",
        Function = function(value) end,
        List = AuraAnimations
    })
    AuraShowTarget = Aura.CreateToggle({
        Name = "ShowTarget",
        Function = function(value) end,
        Default = true,
    })
        --[===[
    InstantKill = Aura.CreateToggle({
        Name = "InstantKill",
        Function = function(value) end,
        Default = true, --:troll:
    })
    AuraStrafe = Aura.CreateToggle({
        Name = "Strafe",
        Function = function(value) end,
        Default = false,
    })]===]
end

do 
    local veloh, velov = {["Value"] = 0},{["Value"] = 0}
    local velocity = {["Enabled"] = false}
    local oldveloh, oldvelov, oldvelofunc = bedwars["KnockbackTable"]["kbDirectionStrength"], bedwars["KnockbackTable"]["kbUpwardStrength"], bedwars["VelocityUtil"].applyVelocity
    velocity = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        ["Name"] = "Velocity",
        ["Function"] = function(callback) 
            if callback then 
                bedwars["KnockbackTable"]["kbDirectionStrength"] = oldveloh * (veloh["Value"] / 100)
                bedwars["KnockbackTable"]["kbUpwardStrength"] = oldvelov * (velov["Value"] / 100)
                if veloh["Value"] == 0 and velov["Value"] == 0 then
                    bedwars["VelocityUtil"].applyVelocity = function(...) end
                else
                    bedwars["VelocityUtil"].applyVelocity = oldvelofunc
                end
            else
                bedwars["VelocityUtil"].applyVelocity = oldvelofunc
                bedwars["KnockbackTable"]["kbDirectionStrength"] = oldveloh
                bedwars["KnockbackTable"]["kbUpwardStrength"] = oldvelov
            end
        end,
        ArrayText = function() return "H"..tostring(veloh.Value).."%|V"..tostring(velov.Value).."%" end
    })
    veloh = velocity.CreateSlider({
        ["Name"] = "Horizontal",
        ["Function"] = function(value)
            if velocity["Enabled"] then 
                velocity.Toggle()
                velocity.Toggle()
            end
        end,
        ["Min"] = 0,
        ["Max"] = 100,
        ["Default"] = 0,
        ["Round"] = 1
    })
    velov = velocity.CreateSlider({
        ["Name"] = "Vertical",
        ["Function"] = function(value)
            if velocity["Enabled"] then 
                velocity.Toggle()
                velocity.Toggle()
            end
        end,
        ["Min"] = 0,
        ["Max"] = 100,
        ["Default"] = 0,
        ["Round"] = 1
    })
end

do 
    local old2 = bedwars.SharedConstants.CpsConstants.BLOCK_PLACE_CPS
    local old = getmetatable(bedwars["SwordController"]).isClickingTooFast
    local NoClickDelay = {["Enabled"] = false}
    NoClickDelay = GuiLibrary.Objects.CombatWindow.API.CreateOptionsButton({
        ["Name"] = "NoClickDelay",
        ["Function"] = function(callback) 
            if callback then 
                bedwars.SharedConstants.CpsConstants.BLOCK_PLACE_CPS = 9e9
                getmetatable(bedwars["SwordController"]).isClickingTooFast = function(...) 
                    return false
                end
            else
                bedwars.SharedConstants.CpsConstants.BLOCK_PLACE_CPS = old2
                getmetatable(bedwars["SwordController"]).isClickingTooFast = old
            end
        end
    })
end

-- TODO: make this work on tripleshot, and other projectiles

if setthreadidentityfunc and getconnections and debug.getproto and debug.getinfo then
    local oldMax = bedwars.ProjectileSourceController.onMaxCharge
    local AutoBowRelease = {}
    AutoBowRelease = GuiLibrary.Objects.CombatWindow.API.CreateOptionsButton({
        Name = "AutoBowRelease",
        Function = function(callback) 
            if callback then 
                bedwars.DefaultProjectileSourceController.onMaxCharge = function(...) 
                    local func = getconnectionproto(bedwars.ProjectileSourceController.onEnable, 4, UIS.InputEnded)
                    local func2 = getconnectionproto(bedwars.ProjectileSourceController.onEnable, 3, UIS.InputBegan)
                    func({
                        UserInputType = Enum.UserInputType.MouseButton1,
                    })
                    if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        func2({
                            UserInputType = Enum.UserInputType.MouseButton1,
                        })
                    end

                    return oldMax(...)
                end
            else
                bedwars.DefaultProjectileSourceController.onMaxCharge = oldMax
            end
        end 
    })
end

-- // exploits window 

do
    local old = {}
    local FastUse = {Enabled = false}
    local FastUseTicks = {Value = 0}
    FastUse = GuiLibrary.Objects.ExploitsWindow.API.CreateOptionsButton({
        Name = "FastUse",
        Function = function(callback) 
            if callback then 
                for i, v in next, bedwars["ItemMeta"] do 
                    if v.consumable then 
                        old[i] = old[i] or v.consumable.consumeTime
                        v.consumable.consumeTime = math.clamp(v.consumable.consumeTime * (FastUseTicks.Value/20), 0.1, 9999999)
                    end
                end
            else
                for i, v in next, bedwars["ItemMeta"] do 
                    if v.consumable and old[i] then 
                      v.consumable.consumeTime = old[i]
                    end
                end
            end
        end,
    })
    FastUseTicks = FastUse.CreateSlider({
        Name = "Ticks",
        Function = function() end,
        Min = 0,
        Max = 20,
        Round = 0
    })
end

do 
    
    local old = {}
    local func = debug.getupvalue(bedwars["BowTable"].launchProjectileWithValues, 2)
    local old2 =  debug.getupvalue(func, 10)
    local FastProjectile = {}
    FastProjectile = GuiLibrary.Objects.ExploitsWindow.API.CreateOptionsButton({
        Name = "FastProjectile",
        Function = function(callback) 
            if callback then 
                for i, v in next, bedwars["ItemMeta"] do 
                    if v.projectileSource then 
                        old[i] = old[i] or {multiShotChargeTime = v.projectileSource.multiShotChargeTime, fireDelaySec = v.projectileSource.fireDelaySec, maxStrengthChargeSec = v.projectileSource.maxStrengthChargeSec}
                        v.projectileSource.multiShotChargeTime = 0.0000000000000001
                        v.projectileSource.fireDelaySec = 0.6
                        v.projectileSource.maxStrengthChargeSec = 0.0000000000000001
                    end
                end
                debug.setupvalue(func, 10, {    
                    Client = {
                        WaitFor = function(self6, remote)
                            local res = Client:Get(remote)
                            return {
                                andThen = function(self5, func) 
                                    return func({
                                        CallServerAsync = function(self,shooting, proj, proj2, launchpos1, launchpos2, launchvelo,uid,tab, ...) 
                                            tab.drawDurationSeconds = 10
                                            return res:CallServerAsync(shooting, proj, proj2, launchpos1, launchpos2, launchvelo,uid,tab, ...)
                                        end
                                    })
                                end
                            }
                        end
                    }
                })
            else
                for i, v in next, bedwars["ItemMeta"] do 
                    if v.projectileSource and old[i] then 
                        v.projectileSource.multiShotChargeTime = old[i].multiShotChargeTime
                        v.projectileSource.fireDelaySec = old[i].fireDelaySec
                        v.projectileSource.maxStrengthChargeSec = old[i].maxStrengthChargeSec
                    end
                end
                debug.setupvalue(func, 10, old2)
            end
        end
    })
end

do 
    local reachConst1 = 14
    local reachConst2 = 18

    local old, old2 = debug.getconstant(bedwars["SwingSwordRegion"], reachConst1),debug.getconstant(bedwars["SwingSwordRegion"], reachConst2)
    local ReachValue = {["Value"] = 0.1}
    Reach = GuiLibrary.Objects.ExploitsWindow.API.CreateOptionsButton({
        ["Name"] = "Reach",
        ["Function"] = function(callback) 
            if callback then 
                debug.setconstant(bedwars["SwingSwordRegion"], reachConst1, old*(ReachValue["Value"]+1))
                debug.setconstant(bedwars["SwingSwordRegion"], reachConst2, old2*(ReachValue["Value"]+1))
            else
                debug.setconstant(bedwars["SwingSwordRegion"], reachConst1, old)
                debug.setconstant(bedwars["SwingSwordRegion"], reachConst2, old2)
            end
        end,
    })
    ReachValue = Reach.CreateSlider({
        ["Name"] = "HitboxAdd",
        ["Function"] = function(value) 
            if Reach["Enabled"] then 
                debug.setconstant(bedwars["SwingSwordRegion"], reachConst1, old*(value+1))
                debug.setconstant(bedwars["SwingSwordRegion"], reachConst2, old2*(value+1))
            end
        end,
        ["Min"] = 0,
        ["Max"] = 2,
        ["Round"] = 1,
        ["Default"] = 2
    })
end

do 
    local shopbypass = {["Enabled"] = false}
    local old = bedwars["ShopItems"]
    shopbypass = GuiLibrary.Objects.ExploitsWindow.API.CreateOptionsButton({
        ["Name"] = "ShopDisplayAll",
        ["Function"] = function(callback) 
            if callback then 
                for i,v in next, bedwars["ShopItems"] do 
                    v.nextTier = nil
                    v.tiered = nil
                end
            else
                bedwars["ShopItems"] = old
            end
        end,
    })
end

--[[
do
    local fastpickup = {}; fastpickup = GuiLibrary.Objects.ExploitsWindow.API.CreateOptionsButton({
        Name = "FastPickup",
        Function = function(callback) 
            if callback then 
                spawn(function() 
                    repeat task.wait() 
                        pcall(function()
                            for i,v in next, lplr.Character.InventoryFolder.Value:GetChildren() do 
                                if (v.Position - lplr.Character.HumanoidRootPart.Position).magnitude < 30 then 
                                    bedwars.ClientHandler:Get(bedwars.PickupRemote).instance:InvokeServer({
                                        ["itemDrop"] = v,
                                    })
                                end
                            end
                        end)
                    until not fastpickup.Enabled
                end)
            end
        end,
    })
end]]

do 
    local effect = game:GetService("ReplicatedStorage").Assets.Effects.InfernalShields
    local oldparent = effect.Parent
    local oldProto = debug.getproto(KnitClient.Controllers.InfernalShieldController.onEnable, 1)
    local FPSCrasher = {Enabled = false}
    FPSCrasher = GuiLibrary.Objects.ExploitsWindow.API.CreateOptionsButton({
        Name = "FPSCrashShield",
        Function = function(callback) 
            if callback then 

                if not getItem("infernal_shield") then return end

                effect.Parent = nil
                game:GetService("ContextActionService"):UnbindAction("infernal-shield-click")

                spawn(function() 
                    for i = 1, 300 do
                        spawn(function()
                            for i = 1,100000 do
                                task.wait()
                                if not FPSCrasher.Enabled then break end
                                bedwars.ClientHandler:Get(bedwars.RaiseShieldRemote).instance:FireServer({raised = true})
                            end
                        end)
                        if not FPSCrasher.Enabled then break end
                    end
                end)

            else
                game:GetService("ContextActionService"):BindAction("infernal-shield-click", oldProto, false, Enum.UserInputType.MouseButton1);
                effect.Parent = oldparent
            end
        end,
    })
end



--// misc window



GuiLibrary.RemoveObject("MiddleClickOptionsButton")
do 
    local function getPlayerFromPart(target) 
        if not target then return end
        for i,v in next, PLAYERS:GetPlayers() do 
            if isAlive(v) then 
                if target:IsDescendantOf(v.Character) then 
                    return v
                end
            end
        end
    end

    local old = debug.getproto(bedwars.PingController.onStart, 2)
    local oldkeys = {}
    for i,v in next, debug.getconstants(bedwars.PingController.constructor) do 
        if typeof(v) == "EnumItem" then
            oldkeys[#oldkeys+1] = v
        end
    end
    local mcp = {Enabled = true}
    local anti= {Enabled = true}
    local mcf = {Enabled = true}
    local inputconnection
    local MiddleClick = {Enabled = false}
    MiddleClick = GuiLibrary.Objects.MiscellaneousWindow.API.CreateOptionsButton({
        Name = "MiddleClick",
        Function = function(callback) 
            if callback then 
                if anti.Enabled then 
                    game:GetService("ContextActionService"):UnbindAction("ping-location")
                end
                inputconnection = UIS.InputBegan:connect(function(input) 
                    if input.UserInputType == Enum.UserInputType.MouseButton3 then 
                        local plr = getPlayerFromPart(mouse.Target)
                        if plr then 
                            if mcf.Enabled then 
                                Future.toggleFriend(plr.Name)
                                return
                            end
                        end
                        if isAlive() and mcp.Enabled then 
                            local tp = "telepearl"
                            if getItem(tp) then 
                                local telepearlInstance = lplr.Character.InventoryFolder.Value:FindFirstChild(tp)
                                local tpProjMeta = bedwars.getItemMetadata(tp).projectileSource
                                local fireInfo = {
                                    gravityMultiplier = 1,
                                    drawDurationSeconds = 10,
                                    projectile = "telepearl", 
                                    velocityMultiplier = 0.83108,
                                    fromPositionOffset = Vector3.new(0,2,0),
                                    getProjectileMeta = function() return bedwars.ProjectileMeta[tp] end,
                                }
                                bedwars["ProjectileController"]:launchProjectile(tp, tp, fireInfo, telepearlInstance, tpProjMeta)
                            end
                        end
                    end
                end)
            else
                if inputconnection then inputconnection:Disconnect(); inputconnection = nil; end
                game:GetService("ContextActionService"):BindAction("ping-location", old, false, Enum.UserInputType.MouseButton3, unpack(oldkeys))
            end
        end,
    })
    mcf = MiddleClick.CreateToggle({
        Name = "Friend",
        Function = function() end,
        Default = true,
    })
    mcp = MiddleClick.CreateToggle({
        Name = "Pearl", 
        Function = function() end,
        Default = true,
    })
    anti = MiddleClick.CreateToggle({
        Name = "AntiMarker",
        Function = function() end,
        Default = true,
    })
end

do
    local connections = {}
    local AutoToxic = {Enabled = false}
    local AutoToxicKillMessage = {Value = ""}
    local AutoToxicReplyMessage = {Value = ""}
    local AutoToxicDeathMessage = {Value = ""}
    local AutoToxicBedMessage = {Value = ""}
    local suffix = function() return math.random(1,2)==1 and " | futureclient.xyz" or " | d\240\144\140\145\240\144\140\145\240\144\140\145\240\144\140\145\240\144\140\145і\240\144\140\145s\240\144\140\145\240\144\140\145\240\144\140\145c\240\144\140\145\240\144\140\145\240\144\140\145\240\144\140\145\240\144\140\145\240\144\140\145\240\144\140\145\240\144\140\145\240\144\140\145o\240\144\140\145r\240\144\140\145d.gg/fxture" end
    local sensitives = {
        "hack",
        "exploit",
        "script",
        "speed",
        "aura", 
    }

    local function hasSensitiveMessage(msg) 
        for i,v in next, sensitives do 
            if msg:lower():find(v) then 
                return true
            end
        end
        return false
    end

    local function AutoToxicFunction(oftype, name) 
        spawn(function()
            task.wait(0.1)
            if AutoToxic.Enabled == false then return end
            if oftype == "Kill" then 
                local message = AutoToxicKillMessage.Value:gsub("<plr>", name)
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message..suffix(), "All")
            elseif oftype == "Death" then
                local message = AutoToxicDeathMessage.Value
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message..suffix(), "All")
            elseif oftype == "Reply" then
                local message = AutoToxicReplyMessage.Value:gsub("<plr>", name)
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message..suffix(), "All")
            elseif oftype == "Bed" then
                local message = AutoToxicBedMessage.Value:gsub("<team>", name)
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message..suffix(), "All")
            end
        end)
    end

    AutoToxic = GuiLibrary.Objects.MiscellaneousWindow.API.CreateOptionsButton({
        Name = "AutoToxic",
        Function = function(callback)
            if callback then 

                bedwars["ClientHandler"]:WaitFor("EntityDeathEvent"):andThen(function(p6)
                    connections[#connections+1] = p6:Connect(function(p7)
                        if p7.fromEntity and p7.fromEntity.Name == lplr.Name then 
                            AutoToxicFunction("Kill", p7.entityInstance.Name)
                        elseif p7.entityInstance.Name == lplr.Name then
                            AutoToxicFunction("Death")
                        end
                    end) 
                end)
                bedwars["ClientHandler"]:WaitFor("BedwarsBedBreak"):andThen(function(p6)
                    connections[#connections+1] = p6:Connect(function(p7)
                        if p7.player and p7.player.Name == lplr.Name then 
                            AutoToxicFunction("Bed", p7.brokenBedTeam.displayName)
                        end
                    end) 
                end)
                for i, v in next, PLAYERS:GetPlayers() do
                    if v ~= lplr then
                        connections[#connections+1] = v.Chatted:connect(function(msg) 
                            if msg:find("vxpe") then
                                --game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("vxpe < futureclient.xyz", "All")
                            end
                            if hasSensitiveMessage(msg) then
                                AutoToxicFunction("Reply", v.Name)
                            end
                        end)
                    end
                end
                connections[#connections+1] = PLAYERS.PlayerAdded:connect(function(v) 
                    if v ~= lplr then
                        connections[#connections+1] = v.Chatted:connect(function(msg) 
                            if msg:find("vxpe") then
                                --game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("vxpe < futureclient.xyz", "All")
                            end
                            if hasSensitiveMessage(msg) then
                                AutoToxicFunction("Reply", v.Name)
                            end
                        end)
                    end
                end)

            else

                for i,v in next, connections do 
                    v:Disconnect()
                    connections[i] = nil
                end

            end
        end
    })
    AutoToxicKillMessage = AutoToxic.CreateTextbox({
        Name = "Kill",
        Function = function() end,
        Default = "get pwned <plr>"
    })
    AutoToxicReplyMessage = AutoToxic.CreateTextbox({
        Name = "Reply",
        Function = function() end,
        Default = "cope <plr>"
    })
    AutoToxicDeathMessage = AutoToxic.CreateTextbox({
        Name = "Death",
        Function = function() end,
        Default = "my finger slipped."
    })
    AutoToxicBedMessage = AutoToxic.CreateTextbox({
        Name = "Bed",
        Function = function() end,
        Default = "i broke ur bed <team>"
    })
end

do
    local PlayerAddedConnection 
    local AutoLeaveStaffMode = {Value = "Destruct"}
    local AutoLeaveStateMode = {Value = "Requeue"}
    local AutoLeave = {Enabled = false} 

    local function AutoLeaveStaffFunction(plr) 

        if not AutoLeave.Enabled then return end
        pcall(function()
            if plr and plr:IsInGroup(5774246) and plr:GetRankInGroup(5774246) >= 100 then 
                if AutoLeaveStaffMode.Value == "Destruct" then 
                    repeat task.wait() until shared._FUTURECACHED
                    GuiLibrary.SaveConfig(GuiLibrary.CurrentConfig)
                    GuiLibrary.Signals.onDestroy:Fire()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = plr.Name.." is Staff!",
                        Text = "Future has detected a staff member.\nWe are destructing the client!"
                    })
                elseif AutoLeaveStaffMode.Value == "Requeue" then
                    local tpdata = game:GetService("TeleportService"):GetLocalPlayerTeleportData()
                    if tpdata and tpdata.match then 
                        tpdata = tpdata.match.queueType
                    end
                    if type(tpdata)~="table" then
                        game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = tpdata})
                    end
                elseif AutoLeaveStaffMode.Value == "Lobby" then
                    game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.TeleportToLobby:FireServer()
                end
            end
        end)
    end
    AutoLeave = GuiLibrary.Objects.MiscellaneousWindow.API.CreateOptionsButton({
        Name = "AutoLeave",
        Function = function(callback) 
            if callback then 
                spawn(function() 
                    repeat task.wait() until state() == states.POST
                    task.wait(2)
                    if AutoLeave.Enabled then 
                        local tpdata = game:GetService("TeleportService"):GetLocalPlayerTeleportData()
                        if tpdata and tpdata.match then 
                            tpdata = tpdata.match.queueType
                        end
                        if AutoLeaveStateMode.Value == "Requeue" and type(tpdata)~="table" then
                            game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = tpdata})
                        elseif AutoLeaveStateMode.Value == "Lobby" then
                            game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.TeleportToLobby:FireServer()
                        end
                    end
                end)
                spawn(function()
                    repeat task.wait(0.1) until pcall(function() return game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.TeleportToLobby end)
                    for i,v in next, PLAYERS:GetPlayers() do 
                        pcall(AutoLeaveStaffFunction, v)
                    end
                end)
                PlayerAddedConnection = PLAYERS.PlayerAdded:Connect(AutoLeaveStaffFunction)
            else
                PlayerAddedConnection:Disconnect()
                PlayerAddedConnection = nil
            end
        end,
    })
    AutoLeaveStateMode = AutoLeave.CreateSelector({
        Name = "End",
        List = {"Requeue", "Lobby", "None"},
        Function = function(callback) 
            
        end
    })
    AutoLeaveStaffMode = AutoLeave.CreateSelector({
        Name = "Staff",
        List = {"Destruct", "Requeue","Lobby", "None"},
        Function = function(callback) 
            
        end
    })
end


-- // movement window 


-- ac assist

local BodyPart = {
    R6 = {
        "Head",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
    }, 
    R15 = {
        "Head",
        "UpperTorso",
        "LowerTorso",
        "LeftUpperLeg",
        "LeftLowerLeg",
        "LeftFoot",
        "RightUpperLeg",
        "RightLowerLeg",
        "RightFoot",
        "LeftUpperArm",
        "LeftLowerArm",
        "LeftHand",
        "RightUpperArm",
        "RightLowerArm",
        "RightHand",
    }
}

do 
    local OldHipHeight
    local AnticheatAssistLastTick = 0
    local AnticheatAssistConnections = {}
    local AnticheatAssistTransparent = {}

    local function AnticheatAssistFunction(char) 
        spawn(function()
            if not isAlive() then repeat task.wait() until isAlive() end
            if not lplr.CharacterAppearanceLoaded then repeat task.wait() until lplr.CharacterAppearanceLoaded end
            local char = char or lplr.Character

            local Humanoid = char:WaitForChild("Humanoid", 15)
            local HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 15)
            local RigType = Humanoid.RigType
            local BodyParts = BodyPart[RigType.Name]
            for i,v in next, BodyParts do 
                char:WaitForChild(v, 10)
            end

            OldHipHeight = OldHipHeight or Humanoid.HipHeight
            Humanoid.HipHeight = OldHipHeight
            RealRoot = HumanoidRootPart
            char.Parent = game
            FakeRoot = RealRoot:Clone()
            FakeRoot.Parent = char
            RealRoot.Parent = cam
            FakeRoot.CFrame = RealRoot.CFrame
            char.PrimaryPart = FakeRoot
            char.Parent = workspace
            RealRoot.CanCollide = true
            RealRoot.Transparency = AnticheatAssistTransparent.Enabled and 1 or 0
            RealRoot.Color = Color3.fromRGB(71, 236, 50)
            RealRoot.Material = Enum.Material.Water

            

            for i,v in next, char:GetDescendants() do 
                if v:IsA("BodyVelocity") then 
                    v:Destroy() 
                end
                if v:IsA("Weld") or v:IsA("Motor6D") then 
                    if v.Part0 and v.Part0 == RealRoot then 
                        v.Part0 = FakeRoot
                    end
                    if v.Part1 and v.Part1 == RealRoot then 
                        v.Part1 = FakeRoot
                    end
                end
            end

            for i,v in next, RealRoot:GetDescendants() do 
                if v:IsA("BodyVelocity") then 
                    v:Destroy() 
                end
            end

            AnticheatAssistConnections["AttributeChanged"] = lplr:GetAttributeChangedSignal("LastTeleported"):Connect(function() 
                pcall(coroutine.wrap(function()
                    for i = 1, 10 do 
                        FakeRoot.CFrame = RealRoot.CFrame
                        task.wait()
                    end
                end))
            end)



            BindToStepped("AnticheatAssist", function()
                if RealRoot and FakeRoot then

                    local MoveDirection = Humanoid.MoveDirection * 20
                    local Velo = Vector3.new(MoveDirection.X, FakeRoot.Velocity.Y, MoveDirection.Z)
                    RealRoot.Velocity = Velo
                    RealRoot.RotVelocity = Vector3.zero
                    RealRoot.Transparency = AnticheatAssistTransparent.Enabled and 1 or 0

                    local Magnitude = (FakeRoot.Position - RealRoot.Position).Magnitude
                    if Magnitude > AnticheatAssistConstants.MaxDistance then
                        FakeRoot.CFrame = RealRoot.CFrame
                    end

                    local Delay = currentTarget ~= nil and AnticheatAssistConstants.CombatDelay or AnticheatAssistConstants.Delay
                    Delay = (not isnetworkowner(RealRoot)) and 0 or Delay
                    if tick() - AnticheatAssistLastTick > Delay then 
                        AnticheatAssistLastTick = tick()

                        if not currentTarget then
                            RealRoot.CFrame = RealRoot.CFrame:Lerp(FakeRoot.CFrame, AnticheatAssistConstants.Lerp)
                            task.wait(AnticheatAssistConstants.TPDelay)
                            if RealRoot and FakeRoot then
                                RealRoot.CFrame = FakeRoot.CFrame
                            end
                        else
                            RealRoot.CFrame = RealRoot.CFrame:Lerp(FakeRoot.CFrame, AnticheatAssistConstants.CombatLerp)
                            task.wait(AnticheatAssistConstants.CombatTPDelay)
                            if RealRoot and FakeRoot then
                                RealRoot.CFrame = FakeRoot.CFrame
                            end
                        end

                        --[[
                        for i,v in next, char:GetDescendants() do 
                            if v:IsA("Weld") or v:IsA("Motor6D") then 
                                if v.Part0 and v.Part0 == RealRoot then 
                                    v.Part0 = FakeRoot
                                end
                                if v.Part1 and v.Part1 == RealRoot then 
                                    v.Part1 = FakeRoot
                                end
                            end
                        end

                        if Humanoid then 
                            Humanoid.HipHeight = OldHipHeight
                        end]]

                    end
                end
            end)
        
        end)
    end

    local function DisableAnticheatAssist(char) 
        spawn(function()
            if not isAlive() then repeat task.wait() until isAlive() end
            local char = char or lplr.Character
            local Humanoid = char:FindFirstChildWhichIsA("Humanoid")
            UnbindFromStepped("AnticheatAssist")
            if AnticheatAssistConnections["AttributeChanged"] then
                AnticheatAssistConnections["AttributeChanged"]:Disconnect()
                AnticheatAssistConnections["AttributeChanged"] = nil
            end
            pcall(function() 
                char.Parent = game 
            end)
            if RealRoot and RealRoot.Parent ~= nil then
                RealRoot.Parent = char
                char.PrimaryPart = RealRoot
                RealRoot.Transparency = 1
            end
            if char.Parent ~= nil then
                char.Parent = workspace
            end
            for i,v in next, char:GetDescendants() do 
                if v:IsA("BodyVelocity") then 
                    v:Destroy() 
                end
                if v:IsA("Weld") or v:IsA("Motor6D") then 
                    if v.Part0 and v.Part0 == FakeRoot then 
                        v.Part0 = RealRoot
                    end
                    if v.Part1 and v.Part1 == FakeRoot then     
                        v.Part1 = RealRoot
                    end
                end
            end
            if FakeRoot then
                FakeRoot:Destroy()
                FakeRoot = nil
            end
            if Humanoid then 
                repeat
                    Humanoid.HipHeight = OldHipHeight
                    task.wait(1)
                until Humanoid.HipHeight == OldHipHeight
            end
        end)
    end

    AnticheatAssist = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        Name = "AnticheatAssist",
        Function = function(callback) 
            if callback then 

                AnticheatAssistConnections["CharacterRemoving"] = lplr.CharacterRemoving:Connect(function(char) 
                    DisableAnticheatAssist(char)
                end)

                AnticheatAssistConnections["CharacterAdded"] = lplr.CharacterAdded:Connect(function(char) 
                    AnticheatAssistFunction(char)
                end)

                AnticheatAssistConnections["TeamUpdate"] = lplr:GetPropertyChangedSignal("Team"):Connect(function() 
                    local char = lplr.Character
                    DisableAnticheatAssist(char)
                    AnticheatAssistFunction(char)
                end)

                if isAlive() then 
                    AnticheatAssistFunction(lplr.Character)
                end

                pcall(GuiLibrary.Objects.SpeedOptionsButtonSpeedSlider.Set, 64)

            else
                UnbindFromStepped("AnticheatAssist")

                for i,v in next, AnticheatAssistConnections do 
                    v:Disconnect()
                    AnticheatAssistConnections[i] = nil
                end

                if isAlive() then 
                    DisableAnticheatAssist(lplr.Character)
                end
            end
        end,
    })
    if shared.FutureDeveloper or shared.FutureAnticheatAssistConfig then
        for i,v in next, AnticheatAssistConstants do
            AnticheatAssist.CreateSlider({
                Name = i,
                Min = 0,
                Max = 1,
                Default = v,
                Function = function(val) 
                    AnticheatAssistConstants[i] = val
                end
            })
        end
    end
    AnticheatAssistTransparent = AnticheatAssist.CreateToggle({
        Name = "Transparent",
        Function = function() end
    })
end






GuiLibrary.RemoveObject("HighJumpOptionsButton")
do
    local Duration,Power = {Value = 50},{Value = 5}
    local HighJump = {}; HighJump = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        Name = "HighJump",
        Function = function(callback) 
            if callback then 
                spawn(function() 
                    if isAlive() then
                        for i = 1, Duration.Value do 
                            lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + Vector3.new(0, Power.Value, 0)
                            if not HighJump.Enabled then
                                break
                            end
                            task.wait()
                        end
                        if HighJump.Enabled then 
                            HighJump.Toggle()
                        end
                    end
                end)
            end
        end,
    })
    Duration = HighJump.CreateSlider({
        Name = "Duration",
        Function = function() end,
        Min = 1,
        Max = 500,
        Round = 1,
        Default = 50,
    })
    Power = HighJump.CreateSlider({
        Name = "Power",
        Function = function() end,
        Min = 1,
        Max = 6,
        Default = 5
    })
end

local stopSpeed = false
GuiLibrary["RemoveObject"]("LongJumpOptionsButton")
do 
    local doRay = false
    local speedval, timeval,distance, delayval = {["Value"] = 0},{["Value"] = 0},{["Value"] = 0}, {["Value"] = 0}
    local LongJump = {["Enabled"] = false}; LongJump = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        ["Name"] = "LongJump",
        ["Function"] = function(callback) 
            if callback then
                if isAlive() then 
                    lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
                else
                    LongJump.Toggle()
                    return
                end
                task.delay(timeval["Value"], function() 
                    if LongJump.Enabled then
                        LongJump.Toggle()
                    end
                end)
                spawn(function()
                    repeat 
                        local dt = skipFrame()
                        if isAlive() then
                            stopSpeed = true
                            if doRay then
                                local params = RaycastParams.new()
                                params.FilterDescendantsInstances = {game:GetService("CollectionService"):GetTagged("block")}
                                params.FilterType = Enum.RaycastFilterType.Whitelist
                                local ray = WORKSPACE:Raycast(lplr.Character.HumanoidRootPart.Position, Vector3.new(0, -10, 0), params)
                                if ray and ray.Instance then 
                                    if LongJump.Enabled then
                                        LongJump.Toggle()
                                        stopSpeed = false
                                    end
                                    break
                                end
                            end

                            local moveDir = lplr.Character.Humanoid.MoveDirection ~= Vector3.zero and lplr.Character.Humanoid.MoveDirection or lplr.Character.HumanoidRootPart.CFrame.lookVector
                            local velo = moveDir * (speedval["Value"] - lplr.Character.Humanoid.WalkSpeed) * dt
                            velo = Vector3.new(velo.x, 0, velo.z)
                            lplr.Character:TranslateBy(velo)
                            --local velo2 = (movedir * speedval["Value"]) / speedsettings.velocitydivfactor
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 1, 0)
                        end
                    until not LongJump.Enabled
                    stopSpeed = false
                end)
                spawn(function() 
                    local num = delayval.Value

                    for i = 1, math.round(timeval["Value"]) * num do 
                        task.wait(1/num) 
                        if not LongJump.Enabled then break end
                        if isAlive() then 
                            local newCframe = lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -distance.Value)
                            local params = RaycastParams.new()
                            params.FilterDescendantsInstances = {game:GetService("CollectionService"):GetTagged("block")}
                            params.FilterType = Enum.RaycastFilterType.Whitelist
                            local ray = WORKSPACE:Raycast(lplr.Character.HumanoidRootPart.Position, CFrame.new(0, 0, -distance.Value).p, params)
                            if not (ray and ray.Instance) then
                                lplr.Character.HumanoidRootPart.CFrame = newCframe
                            else
                                lplr.Character.HumanoidRootPart.CFrame = CFrame.new(ray.Position)
                            end
                        end
                        if i-1 >= timeval["Value"] then doRay = true end
                    end
                end)
            else
                doRay = false
                stopSpeed = false
            end
        end,
    })
    speedval = LongJump.CreateSlider({
        ["Name"] = "Speed",
        ["Default"] = 42, 
        ["Min"] = 10,
        ["Round"] = 0,
        ["Max"] = 42,
        ["Function"] = function(value) end,
    })
    timeval = LongJump.CreateSlider({
        ["Name"] = "Duration",
        ["Default"] = 2, 
        ["Min"] = 1,
        ["Round"] = 1,
        ["Max"] = 3,
        ["Function"] = function(value) end,
    })
    distance = LongJump.CreateSlider({
        Name = "BypassDist",
        Default = 6,
        Min = 4,
        Round = 1,
        Max = 7,
        Function = function() end
    })
    delayval = LongJump.CreateSlider({
        Name = "BypassSpeed",
        Default = 4,
        Min = 1,
        Max = 10,
        Round = 0,
        Function = function() end, 
    })
end

-- 


GuiLibrary["RemoveObject"]("SpeedOptionsButton")
do
    local speedval = {["Value"] = 40}
    local speedmode = {["Value"] = "Velocity"}
    local speed = {["Enabled"] = false}
    local hop = {Enabled = false}
    local hopattack = {Enabled = false}
    speed = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        ["Name"] = "Speed",
        ["ArrayText"] = function() return speedval["Value"].."|"..speedmode["Value"] end,
        ["Function"] = function(callback)
            if callback then
                BindToHeartbeat("Speed", function(dt)
                    if isAlive() and not stopSpeed then
                        
                        local Factor = (speedval.Value) + (currentTarget and 4 or 0) - (((speedmode.Value == "CFrame") and lplr.Character.Humanoid.WalkSpeed) or -5) 
                        local MoveDirection = lplr.Character.Humanoid.MoveDirection * Factor
                        
                        if speedmode.Value == "CFrame" then 
                            local Move = MoveDirection * dt
                            lplr.Character:TranslateBy( Vector3.new(Move.X, 0, Move.Z) )
                        elseif speedmode.Value == "Velocity" then 
                            local Move = Vector3.new(MoveDirection.X, lplr.Character.HumanoidRootPart.Velocity.Y, MoveDirection.Z) 
                            lplr.Character.HumanoidRootPart.AssemblyLinearVelocity = Move
                        elseif speedmode.Value == "Developer" then
                            local Move = Vector3.new(MoveDirection.X, 0, MoveDirection.Z)
                        end

                        if hop.Enabled and (currentTarget or not hopattack.Enabled) then 
                            if lplr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Running and lplr.Character.Humanoid.MoveDirection ~= Vector3.new() then 
                                lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end

                        --local velo2 = (lplr.Character.Humanoid.MoveDirection * speedval["Value"]) / speedsettings.velocitydivfactor
                        --lplr.Character.HumanoidRootPart.Velocity = Vector3.new(velo2.X, lplr.Character.HumanoidRootPart.Velocity.Y, velo2.Z)
                    end
                end)

                if not GuiLibrary.Objects.AutoReportOptionsButton.API.Enabled then 
                    GuiLibrary.Objects.AutoReportOptionsButton.API.Toggle()
                end
            else
                UnbindFromHeartbeat("Speed")
            end
        end
    })
    speedmode = speed.CreateSelector({
        Name = "Mode",
        List = {"Velocity", "CFrame"},
        Function = function() end,
        Default = "Velocity"
    })
    speedval = speed.CreateSlider({
        ["Name"] = "Speed",
        ["Min"] = 1,
        ["Max"] = 41.5,
        ["Default"] = 41.5,
        ["Round"] = 1,
        ["Function"] = function() end,
	    RealMax = 100
    })
    hop = speed.CreateToggle({
        Name = "Hop",
        Function = function(callback) 
            hopattack.Instance.Visible = callback
        end,
    })
    hopattack = speed.CreateToggle({
        Name = "HopTargetCheck",
        Function = function() end,
    })
    hopattack.Instance.Visible = hop.Enabled
end


GuiLibrary["RemoveObject"]("FlightOptionsButton")
do
    local flyup
    local flydown
    local flydownconnection
    local flyupconnection
    local vertspeed = {["Value"] = 40}
    local verttoggle = {["Enabled"] = false}
    local vertbind = {["Value"] = "LShift"}
    local flyspeed = {["Value"] = 40}
    local flyglide = {["Value"] = 0}
    local fly = {["Enabled"] = false}
    local flymode = {["Value"] = "Velo"}
    fly = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Flight",
        ["Function"] = function(callback)
            if callback then
                BindToStepped("Fly", function(time,dt)
                    if isAlive() then
                        local dt = flymode.Value == "Velo" and 1 or dt
                        local updirection = 0 - flyglide["Value"]
                        if UIS:GetFocusedTextBox()==nil then
                            updirection = (flyup and vertspeed["Value"] or flydown and -vertspeed["Value"] or 0 - flyglide["Value"])*dt
                        end
                        local MoveDirection = lplr.Character.Humanoid.MoveDirection * (flyspeed["Value"]*dt)
                        if flymode.Value == "Velo" then
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(MoveDirection.X, verttoggle["Enabled"] and (updirection) or 0 - flyglide["Value"], MoveDirection.Z)
                        elseif flymode.Value == "CFrame" then
                            lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(MoveDirection.X, verttoggle["Enabled"] and (updirection) or 0 - flyglide["Value"], MoveDirection.Z)
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new()
                        end
                    end
                end)
                flyupconnection = UIS.InputBegan:connect(function(input)
                    if input.KeyCode == Enum.KeyCode.Space then
                        flyup = true
                    end
                    if input.KeyCode == (vertbind.Value == "LShift" and Enum.KeyCode.LeftShift or Enum.KeyCode.LeftControl) then
                        flydown = true
                    end
                end)
                flydownconnection = UIS.InputEnded:connect(function(input)
                    if input.KeyCode == Enum.KeyCode.Space then
                        flyup = false
                    end
                    if input.KeyCode == (vertbind.Value == "LShift" and Enum.KeyCode.LeftShift or Enum.KeyCode.LeftControl) then
                        flydown = false
                    end
                end)
            else
                flyup = false
                flydown = false
                UnbindFromStepped("Fly")
                if flyupconnection then
                    flyupconnection:Disconnect()
                end
                if flydownconnection then
                    flydownconnection:Disconnect()
                end
            end
        end
    })
    flymode = fly.CreateSelector({
        Name = "Mode", 
        Function = function() end,
        List = {"Velocity", "CFrame"}
    })
    flyspeed = fly.CreateSlider({
        ["Name"] = "Speed",
        ["Min"] = 1,
        ["Max"] = 22.36,
        ["Function"] = function() end
    })
    verttoggle = fly.CreateToggle({
        ["Name"] = "Vertical",
        ["Function"] = function() end
    })
    vertbind = fly.CreateSelector({
        ["Name"] = "VBind",
        ["Function"] = function() end,
        ["List"] = {"LShift", "LCtrl"},
    })
    vertspeed = fly.CreateSlider({
        ["Name"] = "VSpeed",
        ["Min"] = 1,
        ["Max"] = 50,
        ["Function"] = function() end
    })
    flyglide = fly.CreateSlider({
        ["Name"] = "Glide",
        ["Min"] = -100,
        ["Default"] = 0,
        ["Max"] = 100,
        ["Function"] = function() end
    })
end

GuiLibrary["RemoveObject"]("StepOptionsButton")
do 
    local xzdiv = {["Value"] = 1}
    local Stepval = {["Value"] = 40}
    local Step = {["Enabled"] = false}
    Step = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        ["Name"] = "Step",
        ["ArrayText"] = function() return Stepval["Value"] end,
        ["Function"] = function(callback)
            if callback then
                BindToStepped("Step", function(time, dt)
                    if isAlive() then
                        local param = RaycastParams.new()
                        param.FilterDescendantsInstances = {game:GetService("CollectionService"):GetTagged("block")}
                        param.FilterType = Enum.RaycastFilterType.Whitelist
                        local ray = WORKSPACE:Raycast(lplr.Character.Head.Position-Vector3.new(0, 3, 0), lplr.Character.Humanoid.MoveDirection*3, param)
                        local ray2 = WORKSPACE:Raycast(lplr.Character.Head.Position, lplr.Character.Humanoid.MoveDirection*3, param)
                        if ray or ray2 then
                            local velo = Vector3.new(0, Stepval["Value"] / 100, 0)
                            lplr.Character:TranslateBy(velo)
                            local old = lplr.Character.HumanoidRootPart.Velocity
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(old.X, velo.Y*70, old.Z)
                        end
                    end
                end)
            else
                UnbindFromStepped("Step")
            end
        end
    })
    Stepval = Step.CreateSlider({
        ["Name"] = "Speed",
        ["Min"] = 1,
        ["Max"] = 50,
        ["Default"] = 45,
        ["Round"] = 0,
        ["Function"] = function() end
    })
    xzdiv = Step.CreateSlider({
        ["Name"] = "XZDivision",
        ["Min"] = 1,
        ["Max"] = 10,
        ["Default"] = 5,
        ["Round"] = 0,
        ["Function"] = function() end
    })
end

do 
    local nofall = {["Enabled"] = false}
    nofall = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        ["Name"] = "NoFall",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    repeat task.wait(1) 
                        if WORKSPACE:FindFirstChild("Map") and isAlive() then
                            game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.GroundHit:FireServer(WORKSPACE.Map,999999999999999.00069)
                        end
                    until nofall.Enabled == false
                end)
            end
        end,
        ArrayText = function() return "Packet" end
    })
end

do
    local Sprint = {Enabled = false}
    Sprint = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        Name = "Sprint",
        Function = function(callback) 
            if callback then 
                BindToHeartbeat("Sprint", function() 
                    bedwars["sprintTable"]:startSprinting()
                end)
            else
                bedwars["sprintTable"]:stopSprinting()
                UnbindFromHeartbeat("Sprint")
            end
        end,
        ArrayText = function() return "Legit" end
    })
end

-- // render window 
if oldisnetworkowner~=nil then do 
    local textlabel
    local LagBackNotify = {["Enabled"] = false}
    local notifyfunc
    notifyfunc = function() 
        if not isAlive() then repeat task.wait() until isAlive() end
        repeat task.wait() until not lplr.Character:FindFirstChild("HumanoidRootPart") or not isnetworkowner(lplr.Character.HumanoidRootPart) or not isAlive()
        if isAlive() and LagBackNotify["Enabled"] and lplr.Character:FindFirstChild("HumanoidRootPart") then 
            textlabel = textlabel or Instance.new("TextLabel")
            textlabel.Size = UDim2.new(1, 0, 0, 36)
            textlabel.RichText = true
            textlabel.Text = "Lagback detected!"
            textlabel.BackgroundTransparency = 1
            textlabel.TextStrokeTransparency = 0.5
            textlabel.TextSize = 25
            textlabel.Font = GuiLibrary.Font
            textlabel.TextColor3 = Color3.fromRGB(255, 174, 0)
            textlabel.Position = UDim2.new(0, 0, 0, -70)
            textlabel.Parent = GuiLibrary["ScreenGui"]
            local Tween = TS:Create(textlabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0), {Position = UDim2.new(0, 0, 0, 0)})
            Tween:Play()
            repeat task.wait() until not isAlive() or isnetworkowner(lplr.Character.HumanoidRootPart) 
            if textlabel then
                local Tween = TS:Create(textlabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0), {Position = UDim2.new(0, 0, 0, -70)})
                Tween:Play()
            end
        end
        notifyfunc()
    end
    LagBackNotify = GuiLibrary.Objects.RenderWindow.API.CreateOptionsButton({
        ["Name"] = "LagbackNotifier",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    notifyfunc()
                end)
            else
                if textlabel then
                    textlabel:Destroy()
                    textlabel = nil
                end
            end
        end,
    })
end end

local BedESP = {["Enabled"] = false}
do
    local BedESPFolder = Instance.new("Folder", GuiLibrary["ScreenGui"]) 
    BedESPFolder.Name = "BedESP"
    local function refresh(boolean) 
        if boolean then
            BedESPFolder:ClearAllChildren()
        end
        for i,v in next, getBeds() do 
            for i2,v2 in next, v:GetDescendants() do
                if v2:IsA("BasePart") and v2.Name ~= "EggSpot" then
                    local bhd = Instance.new("BoxHandleAdornment", BedESPFolder)
                    bhd.Size = v2.Size + Vector3.new(0.01, 0.01, 0.01)
                    bhd.CFrame = CFrame.new()
                    bhd.Color3 = v2.Color
                    bhd.Visible = true
                    bhd.Adornee = v2
                    bhd.ZIndex = 10
                    bhd.Transparency = v2.Transparency
                    bhd.AlwaysOnTop = true
                end
            end
        end
    end
    local connection, connection2
    BedESP = GuiLibrary.Objects.RenderWindow.API.CreateOptionsButton({
        ["Name"] = "BedESP",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    local connection2 = COLLECTION:GetInstanceRemovedSignal("bed"):Connect(function(v) 
                        refresh(true)
                    end)
                    for i,v in next, getBeds() do 
                        for i2,v2 in next, v:GetChildren() do
                            refresh(false)   
                        end
                    end
                    bedwars["ClientHandler"]:WaitFor("BedwarsBedBreak"):andThen(function(p13)
                        connection = p13:Connect(function(p14) 
                            refresh(true)
                        end)
                    end)
                end)
            else
                if connection then 
                    connection:Disconnect()
                    connection = nil
                end
                if connection2 then 
                    connection2:Disconnect()
                    connection2 = nil
                end
                BedESPFolder:ClearAllChildren()
            end
        end 
    })
end

do
    local OrigEgg = game:GetObjects("rbxassetid://9627800970")[1]
    local function addegg(bed) 
        if bed:FindFirstChild("Egg") then 
            return
        end
        local children = bed:GetChildren()
        for i,v in next, children do 
            if v:IsA("BasePart") and v.Name ~= "Egg" then 
                v.Transparency = 1
            end
        end
        local egg = OrigEgg:Clone()
        egg.Parent = bed
        egg.PrimaryPart = egg:FindFirstChild("EggLayer2")
        local pos = bed.Covers.CFrame
        egg:SetPrimaryPartCFrame(pos-Vector3.new(0, 0.8, 0))
        egg.Name = "Egg"
    end
    local function deleteegg(bed) 
        if bed:FindFirstChild("Egg") then
            bed:FindFirstChild("Egg"):Destroy()
        end
        local children = bed:GetChildren()
        for i,v in next, children do 
            if v:IsA("BasePart") and v.Name ~= "Egg" then 
                v.Transparency = 0
            end
        end
    end
    local connection, connection2
    local eggwars = {["Enabled"] = false}
    eggwars = GuiLibrary.Objects.RenderWindow.API.CreateOptionsButton({
        ["Name"] = "EggWars",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    local connection2 = COLLECTION:GetInstanceRemovedSignal("bed"):Connect(function(v) 
                        if v.Name ~= "bed" then 
                            return nil
                        end
                        deleteegg(v)
                    end)
                    for i,v in next, getBeds() do 
                        addegg(v)
                    end
                end)
            else
                for i,v in next, getBeds() do 
                    deleteegg(v)   
                end
                if connection then 
                    connection:Disconnect()
                    connection = nil
                end
                if connection2 then 
                    connection2:Disconnect()
                    connection2 = nil
                end
            end
            if BedESP.Enabled then 
                BedESP.Toggle()
                BedESP.Toggle()
            end
        end 
    })
end

GuiLibrary["RemoveObject"]("ESPOptionsButton")
do 
    local lastUpdate = os.clock()
    local renderRate = {Value = 60}
    local doRenderRate = {Enabled = false}
    local esphealth = {Enabled = false}
    local esp = {["Enabled"] = false}
    local espfolder = GuiLibrary["ScreenGui"]:FindFirstChild("ESP") or Instance.new("Folder", GuiLibrary["ScreenGui"])
    espfolder.Name = "ESP"
    local espnames= {["Enabled"] = false}
    local espdisplaynames= {["Enabled"] = false}
    esp = GuiLibrary.Objects.RenderWindow.API.CreateOptionsButton({
        ["Name"] = "ESP",
        ["Function"] = function(callback) 
            if callback then 
                BindToStepped("ESP", function() 

                    if doRenderRate.Enabled then
                        if (os.clock() - lastUpdate < 1 / renderRate.Value) then
                            return
                        end
                        lastUpdate = os.clock()
                    end

                    for i,v in next, PLAYERS:GetPlayers() do 
                        if v~=lplr and isAlive(v) then
                            local plrespframe
                            if espfolder:FindFirstChild(v.Name) then 
                                plrespframe = espfolder:FindFirstChild(v.Name)
                                plrespframe.line2.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line1.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line3.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line4.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe:FindFirstChild("name").TextColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe:FindFirstChild("name").Visible = espnames["Enabled"]
                                local text = espdisplaynames["Enabled"] and v.DisplayName or v.Name
                                plrespframe:FindFirstChild("name").Text = "<stroke color='#000000' thickness='1'>"..text..(esphealth["Enabled"] and (" [<font color='#"..(convertHealthToColor(v.Character:GetAttribute("Health"),  v.Character:GetAttribute("MaxHealth")):ToHex()).."'>"..tostring(math.round(v.Character:GetAttribute("Health"))).."</font>]") or "").."</stroke>"
                            else
                                plrespframe = Instance.new("Frame", espfolder)
                                plrespframe.BackgroundTransparency = 1
                                plrespframe.Visible = false
                                plrespframe.Name = v.Name
                                plrespframe.BorderSizePixel = 0
                                local line1 = Instance.new("Frame", plrespframe)
                                line1.BorderSizePixel = 0
                                line1.Name = "line1"
                                line1.ZIndex = 99
                                line1.Size = UDim2.new(1, -2, 0, 1)
                                line1.Position = UDim2.new(0, 1, 0, 1)
                                line1.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line1.Parent = plrespframe
                                local line2 = Instance.new("Frame", plrespframe)
                                line2.BorderSizePixel = 0
                                line2.Name = "line2"
                                line2.ZIndex = 99
                                line2.Size = UDim2.new(1, -2, 0, 1)
                                line2.Position = UDim2.new(0, 1, 1, -2)
                                line2.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line2.Parent = plrespframe
                                local line3 = Instance.new("Frame", plrespframe)
                                line3.BorderSizePixel = 0
                                line3.Name = "line3"
                                line3.ZIndex = 99
                                line3.Size = UDim2.new(0, 1, 1, -2)
                                line3.Position = UDim2.new(0, 1, 0, 1)
                                line3.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line3.Parent = plrespframe
                                local line4 = Instance.new("Frame", plrespframe)
                                line4.BorderSizePixel = 0
                                line4.Name = "line4"
                                line4.ZIndex = 99
                                line4.Size = UDim2.new(0, 1, 1, -2)
                                line4.Position = UDim2.new(1, -2, 0, 1)
                                line4.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line4.Parent = plrespframe
                                local name = Instance.new("TextLabel", plrespframe)
                                local text = espdisplaynames["Enabled"] and v.DisplayName or v.Name
                                name.TextColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                name.BackgroundTransparency = 1
                                name.Size = UDim2.new(0, 1, 1, 2)
                                name.Position = UDim2.new(0.5, 0, -0.95, 0)
                                name.AnchorPoint = Vector2.new(0.5, 0)
                                name.RichText = true
                                name.Text = "<stroke color='#000000' thickness='1'>"..text..(esphealth["Enabled"] and (" [<font color='#"..(convertHealthToColor(v.Character:GetAttribute("Health"),  v.Character:GetAttribute("MaxHealth")):ToHex()).."'>"..tostring(v.Character:GetAttribute("Health")).."</font>]") or "").."</stroke>"
                                name.Visible = espnames["Enabled"]
                                name.Name = "name"
                                name.TextSize = 15
                                name.Font = GuiLibrary.Font
                            end

                            local rootPos, rootVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
							local rootSize = (v.Character.HumanoidRootPart.Size.X * 1200) * (WORKSPACE.CurrentCamera.ViewportSize.X / 1920)
							local headPos, headVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position + Vector3.new(0, 1 + v.Character.Humanoid.HipHeight, 0))
							local legPos, legVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position - Vector3.new(0, 1 + v.Character.Humanoid.HipHeight, 0))
                            plrespframe.Visible = rootVis
                            plrespframe.name.Visible = espnames["Enabled"]
                            if rootVis then
                                local rootSize = rootSize * 0.75
                                plrespframe.Size = UDim2.new(0, rootSize / rootPos.Z, 0, (headPos.Y - legPos.Y))
                                plrespframe.Position = UDim2.new(0, rootPos.X - plrespframe.Size.X.Offset / 2, 0, (rootPos.Y - plrespframe.Size.Y.Offset / 2) - 36)
                            end
                        end
                    end
                    for i,v in next, espfolder:GetChildren() do 
                        if not PLAYERS:FindFirstChild(v.Name) or not isAlive(PLAYERS:FindFirstChild(v.Name)) then
                            v:Destroy()
                        end
                    end
                end)
            else
                UnbindFromStepped("ESP")
                espfolder:ClearAllChildren()
            end
        end
    })

    espnames = esp.CreateToggle({
        ["Name"] = "Names",
        ["Function"] = function() end,
    })

    espdisplaynames = esp.CreateToggle({
        ["Name"] = "UseDisplayNames",
        ["Function"] = function() end,
    })
    esphealth = esp.CreateToggle({
        ["Name"] = "Health",
        ["Function"] = function() end,
    })
    doRenderRate = esp.CreateToggle({
        Name = "RenderRate",
        Function = function() end
    })
    renderRate = esp.CreateSlider({
        Name = "RenderRate",
        Function = function() end,
        Min = 10,
        Max = 240,
        Default = 60,
    })
end

GuiLibrary.RemoveObject("NametagsOptionsButton")
do 
    local lastUpdate = os.clock()
    local renderRate = {Value = 60}
    local doRenderRate = {Enabled = false}
    local nametags = {["Enabled"] = false}
    local NametagsFolder = Instance.new("Folder", GuiLibrary["ScreenGui"])
    NametagsFolder.Name = "Nametags"
    local tagsarmor = {["Enabled"] = false}
    local tagsitemname = {["Enabled"] = false}
    local tagshealth = {["Enabled"] = false}
    local tagsscale = {Value = 1}
    nametags = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Nametags",
        ["Function"] = function(callback) 
            if callback then 

                if doRenderRate.Enabled then
                    if (os.clock() - lastUpdate < 1 / renderRate.Value) then
                        return
                    end
                    lastUpdate = os.clock()
                end

                BindToStepped("Nametags", function() 
                    for i,v in next, PLAYERS:GetPlayers() do 
                        if lplr~=v and isAlive(v) then
                            local frame
                            local MainText
                            local UIScale
                            local ItemContainer
                            local ImageContainer
                            local ItemName
                            local raw = v.DisplayName..(tagshealth.Enabled and ' '..tostring(math.round(v.Character.Humanoid.Health)) or '')
                            local blue = "2a96fa"
                            local default = "ffffff"
                            local teamcolor = (v.Team and v.TeamColor.Color:ToHex())
                            local text = '<font color="#'..(Future.isFriend(v) and blue or (teamcolor or default))..'">'..v.DisplayName..'</font>'..(tagshealth.Enabled and ' <font color="#'..(convertHealthToColor(v.Character.Humanoid.Health, v.Character.Humanoid.MaxHealth):ToHex())..'">'..tostring(math.round(v.Character.Humanoid.Health))..'</font>' or '')
                            if NametagsFolder:FindFirstChild(v.Name) then 
                                frame = NametagsFolder:FindFirstChild(v.Name)
                                ImageContainer = frame:FindFirstChild("ItemContainer"):FindFirstChild("ImageContainer")
                                ItemContainer = frame:FindFirstChild("ItemContainer")
                                MainText = frame:FindFirstChild("MainText")
                                MainText.Text = text
                                UIScale = frame:FindFirstChild("UIScale")
                                UIScale.Scale = tagsscale.Value
                            else
                                frame = Instance.new("Frame")
                                local Nametag = frame
                                MainText = Instance.new("TextLabel")
                                UIScale = Instance.new("UIScale", Nametag)
                                UIScale.Scale = tagsscale.Value
                                Nametag.Name = v.Name
                                Nametag.Parent = NametagsFolder
                                Nametag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                Nametag.BackgroundTransparency = 0.500
                                Nametag.BorderSizePixel = 0
                                Nametag.Position = UDim2.new(0, 0, 0, 0)
                                Nametag.AnchorPoint = Vector2.new(0,0)
                                Nametag.Size = UDim2.new(0, 300, 0, 30)
                                Nametag.ZIndex = -1
                                MainText.Name = "MainText"
                                MainText.RichText = true
                                MainText.Parent = Nametag
                                MainText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                MainText.BackgroundTransparency = 1.000
                                MainText.Position = UDim2.new(0.5, 0, 0.5, 0)
                                MainText.AnchorPoint = Vector2.new(0.5,0.5)
                                MainText.Size = UDim2.new(0, 300, 0, 30)
                                MainText.Font = GuiLibrary.Font
                                MainText.Text = text
                                MainText.TextSize = (18)
                                MainText.TextColor3 = Color3.fromRGB(255, 255, 255)
                                MainText.ZIndex = -1
                                ItemContainer = Instance.new("Frame")
                                ImageContainer = Instance.new("Frame")
                                local UIListLayout = Instance.new("UIListLayout")
                                local Item = Instance.new("Frame")
                                local Image = Instance.new("ImageLabel")
                                local Helmet = Instance.new("Frame")
                                local Image_2 = Instance.new("ImageLabel")
                                local Chestplate = Instance.new("Frame")
                                local Image_3 = Instance.new("ImageLabel")
                                local Boots = Instance.new("Frame")
                                local Image_4 = Instance.new("ImageLabel")
                                ItemName = Instance.new("TextLabel")
                                ItemContainer.Name = "ItemContainer"
                                ItemContainer.Parent = frame
                                ItemContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                ItemContainer.BackgroundTransparency = 1.000
                                --ItemContainer.Position = UDim2.new(0, 0.3, 0, 0)
                                ItemContainer.Size = UDim2.new(0, 300, 0, 100)
                                ImageContainer.Name = "ImageContainer"
                                ImageContainer.Parent = ItemContainer
                                ImageContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                ImageContainer.BackgroundTransparency = 1.000
                                ImageContainer.BorderSizePixel = 0
                                ImageContainer.Position = UDim2.new(0, 0, 0.150000006, 0)
                                ImageContainer.Size = UDim2.new(0, 300, 0, 85)
                                UIListLayout.Parent = ImageContainer
                                UIListLayout.FillDirection = Enum.FillDirection.Horizontal
                                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                                Item.Name = "Item"
                                Item.Parent = ImageContainer
                                Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Item.BackgroundTransparency = 1.000
                                Item.Position = UDim2.new(0.389999986, 0, -0.0759493634, 0)
                                Item.Size = UDim2.new(0, 47.1, 0, 60)
                                local Amount = Instance.new("TextLabel")
                                Amount.Name = "Amount"
                                Amount.Parent = Item
                                Amount.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Amount.BackgroundTransparency = 1.000
                                Amount.Position = UDim2.new(0.590909123, 0, 0.761904776, 0)
                                Amount.Size = UDim2.new(0, 21, 0, 21)
                                Amount.ZIndex = 10
                                Amount.Font = GuiLibrary.Font
                                Amount.Text = ""
                                Amount.TextColor3 = Color3.fromRGB(255, 255, 255)
                                Amount.TextSize = 16.000
                                Amount.TextStrokeTransparency = 0.000
                                Amount.TextWrapped = true
                                Image.Name = "Image"
                                Image.Parent = Item
                                Image.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Image.BackgroundTransparency = 1.000
                                Image.BorderSizePixel = 0
                                Image.Position = UDim2.new(0, 0, 0.225274742, 0)
                                Image.Size = UDim2.new(0, 47.1, 0, 47.1)
                                Image.Image = ""
                                Image.ImageColor3 = Color3.fromRGB(255, 255, 255)
                                Helmet.Name = "Helmet"
                                Helmet.Parent = ImageContainer
                                Helmet.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Helmet.BackgroundTransparency = 1.000
                                Helmet.Position = UDim2.new(0.389999986, 0, -0.0759493634, 0)
                                Helmet.Size = UDim2.new(0, 47.1, 0, 60)
                                Image_2.Name = "Image"
                                Image_2.Parent = Helmet
                                Image_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Image_2.BackgroundTransparency = 1.000
                                Image_2.BorderSizePixel = 0
                                Image_2.Position = UDim2.new(0, 0, 0.225274742, 0)
                                Image_2.Size = UDim2.new(0, 47.1, 0, 47.1)
                                Image_2.Image = ""
                                Image_2.ImageColor3 = Color3.fromRGB(255, 255, 255)
                                Chestplate.Name = "Chestplate"
                                Chestplate.Parent = ImageContainer
                                Chestplate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Chestplate.BackgroundTransparency = 1.000
                                Chestplate.Position = UDim2.new(0.389999986, 0, -0.0759493634, 0)
                                Chestplate.Size = UDim2.new(0, 47.1, 0, 60)
                                Image_3.Name = "Image"
                                Image_3.Parent = Chestplate
                                Image_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Image_3.BackgroundTransparency = 1.000
                                Image_3.BorderSizePixel = 0
                                Image_3.Position = UDim2.new(0, 0, 0.225274742, 0)
                                Image_3.Size = UDim2.new(0, 47.1, 0, 47.1)
                                Image_3.Image = ""
                                Image_3.ImageColor3 = Color3.fromRGB(255, 255, 255)
                                Boots.Name = "Boots"
                                Boots.Parent = ImageContainer
                                Boots.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Boots.BackgroundTransparency = 1.000
                                Boots.Position = UDim2.new(0.389999986, 0, -0.0759493634, 0)
                                Boots.Size = UDim2.new(0, 47.1, 0, 60)
                                Image_4.Name = "Image"
                                Image_4.Parent = Boots
                                Image_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Image_4.BackgroundTransparency = 1.000
                                Image_4.BorderSizePixel = 0
                                Image_4.Position = UDim2.new(0, 0, 0.225274742, 0)
                                Image_4.Size = UDim2.new(0, 47.1, 0, 47.1)
                                Image_4.Image = ""
                                Image_4.ImageColor3 = Color3.fromRGB(255, 255, 255)
                                ItemName.Name = "ItemName"
                                ItemName.Parent = ItemContainer
                                ItemName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                ItemName.BackgroundTransparency = 1.000
                                ItemName.Position = UDim2.new(0.389999986, 0, 0.150000006, 0)
                                ItemName.Size = UDim2.new(0, 66, 0, 18)
                                ItemName.Font = GuiLibrary.Font
                                ItemName.Text = "Diamond Sword"
                                ItemName.TextColor3 = Color3.fromRGB(255, 255, 255)
                                ItemName.TextSize = 14.000
                                ItemName.TextStrokeTransparency = 0.000
                            end

                            local inv = bedwars.getInventory(v)
                            if inv.hand then
                                ImageContainer.Item.Visible = true
                                ImageContainer.Item.Image.Image =  bedwars.getIcon(inv.hand, tagsarmor.Enabled)
                                ImageContainer.Item.Amount.Text = tostring(inv.hand.amount)
                            else
                                ImageContainer.Item.Visible = false
                            end
                            if inv.armor[4] then 
                                ImageContainer.Helmet.Visible = true
                                ImageContainer.Helmet.Image.Image =  bedwars.getIcon(inv.armor[4], tagsarmor.Enabled)
                            else
                                ImageContainer.Helmet.Visible = false
                            end
                            if inv.armor[5] then 
                                ImageContainer.Chestplate.Visible = true
                                ImageContainer.Chestplate.Image.Image =  bedwars.getIcon(inv.armor[5], tagsarmor.Enabled)
                            else
                                ImageContainer.Chestplate.Visible = false
                            end
                            if inv.armor[6] then 
                                ImageContainer.Boots.Visible = true
                                ImageContainer.Boots.Image.Image =  bedwars.getIcon(inv.armor[6], tagsarmor.Enabled)
                            else
                                ImageContainer.Boots.Visible = false
                            end
                            if tagsitemname.Enabled then 
                                if inv.hand and inv.hand.itemType then 
                                    local meta = bedwars.getItemMetadata(inv.hand.itemType)
                                    ItemContainer.ItemName.Text = meta.displayName
                                else
                                    ItemContainer.ItemName.Text = ""
                                end
                            else
                                ItemContainer.ItemName.Text = ""
                            end

                            ItemContainer.AnchorPoint = Vector2.new(0.5, 0)

                            ItemContainer.Position = UDim2.new(0.5, 0, -4.3, 0)

                            local tsize = game:GetService("TextService"):GetTextSize(raw, MainText.TextSize, MainText.Font, MainText.AbsoluteSize)
                            frame.Size = UDim2.new(0, tsize.X + 10, 0, tsize.Y)
                            local rootPos, rootVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
							local headPos, headVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position + Vector3.new(0, 1 + v.Character.Humanoid.HipHeight, 0))
                            frame.Visible = rootVis
                            if rootVis then 
                                frame.Position = UDim2.new(0, (rootPos.X - frame.Size.X.Offset / 2* UIScale.Scale), 0, (headPos.Y - frame.Size.Y.Offset / 2) - 42)
                            end
                        end
                    end
                    for i,v in next, NametagsFolder:GetChildren() do 
                        if not PLAYERS:FindFirstChild(v.Name) or not isAlive(PLAYERS:FindFirstChild(v.Name)) then
                            v:Destroy()
                        end
                    end
                end)
            else
                UnbindFromStepped("Nametags")
                NametagsFolder:ClearAllChildren()
            end
        end
    })

    tagsscale = nametags.CreateSlider({
        Name = "Scale",
        Min = 0.8,
        Max = 1.5,
        Round = 1,
        Default = 1,
        Function = function() end,
    })
    tagsarmor = nametags.CreateToggle({
        ["Name"] = "Armor",
        ["Function"] = function() end,
    })
    tagsitemname = nametags.CreateToggle({
        ["Name"] = "ItemName",
        ["Function"] = function() end,
    })
    tagshealth = nametags.CreateToggle({
        ["Name"] = "Health",
        ["Function"] = function() end,
    })
    doRenderRate = nametags.CreateToggle({
        Name = "RenderRate",
        Function = function() end
    })
    renderRate = nametags.CreateSlider({
        Name = "RenderRate",
        Function = function() end,
        Min = 10,
        Max = 240,
        Default = 60,
    })
end

do 
    local onspawn
    local NoNameTag = {Enabled = false}
    NoNameTag = GuiLibrary.Objects.RenderWindow.API.CreateOptionsButton({
        Name = "NoNametag",
        Function = function(callback) 
            if callback then
                spawn(function() 
                    if not isAlive() then repeat task.wait() until isAlive() end
                    lplr.Character:WaitForChild("Head"):WaitForChild("StatusEffectTagBillboard"):Destroy()
                    lplr.Character:WaitForChild("Head"):WaitForChild("Nametag"):Destroy()
                end)
                onspawn = lplr.CharacterAdded:Connect(function(char)
                    char:WaitForChild("Head"):WaitForChild("StatusEffectTagBillboard"):Destroy()
                    char:WaitForChild("Head"):WaitForChild("Nametag"):Destroy()
                end)
            else
                onspawn:Disconnect()
                onspawn = nil
            end
        end
    })
end

do 
    local mult = function(val) 
        if setc0 then 
            return setc0 * val
        end
    end
    local val = function(x,y,z,xr,yr,zr) 
        return CFrame.new(Vector3.new(x,y,z)) * CFrame.Angles(-math.rad(xr), -math.rad(yr), -math.rad(zr))
    end
    local true_scale = function(x,y,z) 
        local x = x<0 and (1/-x) or x
        local y = y<0 and (1/-y) or y
        local z = z<0 and (1/-z) or z

        return Vector3.new(x,y,z)
    end
    local original_scale = function(name) 
        if game:GetService("ReplicatedStorage").Items:FindFirstChild(name) and game:GetService("ReplicatedStorage").Items:FindFirstChild(name):FindFirstChildOfClass("MeshPart") then 
            return game:GetService("ReplicatedStorage").Items:FindFirstChild(name):FindFirstChildOfClass("MeshPart").Size
        end
    end
    local original_id = function(name) 
        if game:GetService("ReplicatedStorage").Items:FindFirstChild(name) and game:GetService("ReplicatedStorage").Items:FindFirstChild(name):FindFirstChildOfClass("MeshPart") then 
            return game:GetService("ReplicatedStorage").Items:FindFirstChild(name):FindFirstChildOfClass("MeshPart").TextureID
        end
    end
    local X = {Value = 0}
    local Y = {Value = 0}
    local Z = {Value = 0}
    local Xr = {Value = 0}
    local Yr = {Value = 0}
    local Zr = {Value = 0}
    local Xs = {Value = 0}
    local Ys = {Value = 0}
    local Zs = {Value = 0}
    local Colored = {Enabled = false}
    ViewModel = GuiLibrary.Objects.RenderWindow.API.CreateOptionsButton({
        Name = "ViewModel",
        Function = function(callback) 
            if callback then 
                spawn(function()
                    BindToStepped("ViewModel", function()
                        if isAlive() and cam~=nil and cam:FindFirstChild("Viewmodel") and cam.Viewmodel:FindFirstChildWhichIsA("Accessory") then 
                            if not setc0 then 
                                setc0 = savedc0
                            end
                            if not cancelViewmodel then
                                pcall(function()
                                    local toset = savedc0 * val(X.Value, Y.Value, Z.Value, Xr.Value, Yr.Value, Zr.Value)
                                    cam.Viewmodel.RightHand.RightWrist.C0 = toset
                                    setc0 = toset
                                    cam.Viewmodel:FindFirstChildWhichIsA("Accessory"):FindFirstChildOfClass("MeshPart").Size = original_scale(cam.Viewmodel:FindFirstChildWhichIsA("Accessory").Name) * true_scale(Xs.Value+1, Ys.Value+1, Zs.Value+1)
                                end)
                            end
                            pcall(function() 
                                if not Colored.Enabled then  
                                    cam.Viewmodel:FindFirstChildWhichIsA("Accessory"):FindFirstChildOfClass("MeshPart").TextureID = original_id(cam.Viewmodel:FindFirstChildWhichIsA("Accessory").Name) 
                                    return "Returned" 
                                end
                                cam.Viewmodel:FindFirstChildWhichIsA("Accessory"):FindFirstChildOfClass("MeshPart").Color = GuiLibrary["GetColor"]()
                                cam.Viewmodel:FindFirstChildWhichIsA("Accessory"):FindFirstChildOfClass("MeshPart").TextureID = ""
                            end)
                        end
                    end)
                end)
            else
                UnbindFromStepped("ViewModel")
                cam.Viewmodel.RightHand.RightWrist.C0 = savedc0
                if cam.Viewmodel:FindFirstChildWhichIsA("Accessory") then 
                    cam.Viewmodel:FindFirstChildWhichIsA("Accessory"):FindFirstChildOfClass("MeshPart").TextureID = original_id(cam.Viewmodel:FindFirstChildWhichIsA("Accessory").Name)
                    cam.Viewmodel:FindFirstChildWhichIsA("Accessory"):FindFirstChildWhichIsA("MeshPart").Size = original_scale(cam.Viewmodel:FindFirstChildWhichIsA("Accessory").Name)
                end
            end
        end,
    })
    X = ViewModel.CreateSlider({
        Name = "X",
        Function = function() end,
        Min = -10,
        Max = 10,
        Round = 1,
        Default = 0
    })
    Y = ViewModel.CreateSlider({
        Name = "Y",
        Function = function() end,
        Min = -10,
        Max = 10,
        Round = 1,
        Default = 0
    })
    Z = ViewModel.CreateSlider({
        Name = "Z",
        Function = function() end,
        Min = -10,
        Max = 10,
        Round = 1,
        Default = 0
    })
    Xr = ViewModel.CreateSlider({
        Name = "XRot",
        Function = function() end,
        Min = 0,
        Max = 360,
        Round = 1,
    })
    Yr = ViewModel.CreateSlider({
        Name = "YRot",
        Function = function() end,
        Min = 0,
        Max = 360,
        Round = 1,
    })
    Zr = ViewModel.CreateSlider({
        Name = "ZRot",
        Function = function() end,
        Min = 0,
        Max = 360,
        Round = 1,
    })
    Xs = ViewModel.CreateSlider({
        Name = "XScale",
        Function = function() end,
        Min = -10,
        Max = 10,
        Round = 1,
        Default = 0
    })
    Ys = ViewModel.CreateSlider({
        Name = "YScale",
        Function = function() end,
        Min = -10,
        Max = 10,
        Round = 1,
        Default = 0
    })
    Zs = ViewModel.CreateSlider({
        Name = "ZScale",
        Function = function() end,
        Min = -10,
        Max = 10,
        Round = 1,
        Default = 0
    })
    Colored = ViewModel.CreateToggle({
        Name = "Colored",
        Function = function() end
    })
end

-- world window

do 
    local ChestStealer = {["Enabled"] = false}
	local ChestStealerDistance = {["Value"] = 1}
	local ChestStealDelay = tick()
	ChestStealer = GuiLibrary.Objects.MiscellaneousWindow.API.CreateOptionsButton({
		["Name"] = "ChestStealer",
		["Function"] = function(callback)
			if callback then
				BindToRenderStep("ChestStealer", function()
					if ChestStealDelay <= tick() and isAlive() then
						ChestStealDelay = tick() + 0.2
						local rootpart = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
						for i,v in pairs(game:GetService("CollectionService"):GetTagged("chest")) do
							if rootpart and (rootpart.Position - v.Position).magnitude <= ChestStealerDistance["Value"] and v:FindFirstChild("ChestFolderValue") then
								local chest = v.ChestFolderValue.Value
								local chestitems = chest and chest:GetChildren() or {}
								if #chestitems > 0 then
									bedwars["ClientHandler"]:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
									for i3,v3 in pairs(chestitems) do
										if v3:IsA("Accessory") then
											bedwars["ClientHandler"]:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
										end
									end
									bedwars["ClientHandler"]:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
								end
							end
						end
					end
				end)
			else
				UnbindFromRenderStep("ChestStealer")
			end
		end,
		["HoverText"] = "Grabs items from near chests."
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		["Name"] = "Distance",
		["Min"] = 0,
		["Max"] = 18,
		["Function"] = function() end,
		["Default"] = 18
	})
end

do 
    local priolist = {
        [1] = {
            "leather_chestplate",
            "iron_chestplate",
            "diamond_chestplate",
            "void_chestplate", -- void is worse then emerald
            "emerald_chestplate",
        },
        [2] = {
            "stone_sword",
            "iron_sword",
            "diamond_sword",
            "emerald_sword",
        },
        [3] = {
            "stone_pickaxe",
            "iron_pickaxe",
            "diamond_pickaxe",
        },
        [4] = {
            "wood_axe",
            "stone_axe",
            "iron_axe",
            "diamond_axe"
        },  
        [5] = {
            "wool_white"
        },
    }

    local teampriolist = {
        --"armory",
        "damage",
        "armor"
    }

    local WoolCap = {Value = 16}
    local AutoBuy = {Enabled = false}
    local ABArmor = {Enabled = false}
    local ABSwords = {Enabled = false}
    local ABPickaxes = {Enabled = false}
    local ABAxes = {Enabled = false}
    local ABTeamUpgrades = {Enabled = false}
    local ABWool = {Enabled = false}

    local function getShopItem(_type) 
        for i,v in next, bedwars.ShopItems do 
            if v.itemType and v.itemType == _type then 
                return v
            end
        end
    end

    local function getTeamUpgrade(id) 
        for i,v in next, bedwars.TeamUpgrades do 
            if v.id and v.id == id then 
                return v
            end
        end
    end

    local function buy(item)
        if item==nil then return end
        local i = item.itemType
        if table.find(priolist[1], i) and not ABArmor.Enabled then return end
        if table.find(priolist[2], i) and not ABSwords.Enabled then return end
        if table.find(priolist[3], i) and not ABPickaxes.Enabled then return end
        if table.find(priolist[4], i) and not ABAxes.Enabled then return end
        if table.find(priolist[5], i) and not ABWool.Enabled then return end
        spawn(function()
            game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.BedwarsPurchaseItem:InvokeServer({shopItem = item})
        end)
    end

    local function upgrade(id, tier) 
        local tier = tier or 0
        if not ABTeamUpgrades.Enabled then return end
        spawn(function() 
            game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.BedwarsPurchaseTeamUpgrade:InvokeServer({["upgradeId"] = id,["tier"] = tier})
        end)
    end

    local function getCurrentItem(t) 
        local best
        for i,v in next, t do
            if getItem(v) then 
                best = v
            end
        end
        return getShopItem(best)
    end

    local childadded
    local tu = {}
    local is = {}
    AutoBuy = GuiLibrary.Objects.MiscellaneousWindow.API.CreateOptionsButton({
        Name = "AutoBuy",
        Function = function(callback) 
            if callback then 
                for i,v in next, WORKSPACE:GetChildren() do 
                    if v.Name == "item_shop" then 
                        is[#is+1] = v
                    elseif v.Name:find("upgrade_shop") then
                        tu[#tu+1] = v
                    end
                end
                childadded = WORKSPACE.ChildAdded:Connect(function(v) 
                    if v.Name == "item_shop" then 
                        is[#is+1] = v
                    elseif v.Name:find("upgrade_shop") then
                        tu[#tu+1] = v
                    end
                end)
                spawn(function()
                    repeat task.wait(0.1)
                        local currentTeamUpgrades = bedwars["ClientStoreHandler"]:getState().Bedwars.teamUpgrades
                        --printtable(currentTeamUpgrades)
                        if isAlive() then
                            for i,v in next, is do
                                local mag = (lplr.Character.HumanoidRootPart.Position - v.Position).magnitude
                                if mag <= 15 then 
                                    for b,a in ipairs(priolist) do 
                                        local buyme
                                        for i,v in next, a do
                                            local item = getShopItem(v)
                                            local amt = getItemAmt(item.currency)
                                            local currentItem = getCurrentItem(a) or {itemType = "placeholder"}
                                            --print(amt, item, item.price, amt >= item.price, (i > (table.find(a, currentItem.itemType) or 0)))
                                            if amt and item and item.price and amt >= item.price and (i > (table.find(a, currentItem.itemType) or 0)) then
                                                if item.itemType=="diamond_sword" or item.itemType=="emerald_sword" then 
                                                    if currentTeamUpgrades.armory ~= nil then 
                                                        buyme = item
                                                    end
                                                else
                                                    buyme = item 
                                                end
                                                --print("can buy "..item.itemType)
                                            end
                                        end
                                        if buyme and not getItem(buyme.itemType) then
                                            if buyme.itemType=="wool_white" and getwoolamt() < WoolCap.Value then
                                                buy(buyme)
                                            elseif buyme.itemType ~= "wool_white" then
                                                buy(buyme)
                                            end
                                        end
                                    end
                                end
                            end
                            for i,v in next, tu do
                                local mag = (lplr.Character.HumanoidRootPart.Position - v.Position).magnitude
                                if mag <= 15 then 
                                    for a,b in ipairs(teampriolist) do
                                        local upgradetab = getTeamUpgrade(b)
                                        local currentTier = currentTeamUpgrades[b] or -1
                                        if currentTier+1 ~= #upgradetab.tiers then
                                            for i,v in next, upgradetab.tiers do
                                                --print("upgrade",b,i)
                                                upgrade(b, i-1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    until not AutoBuy.Enabled
                end)
            else
                childadded:Disconnect()
                table.clear(is)
                table.clear(tu)
            end
        end,
    })
    WoolCap = AutoBuy.CreateSlider({
        Name = "WoolCap",
        Function = function() end,
        Min = 1,
        Max = 128,
        Round = 0,
        Default = 16
    })
    ABWool = AutoBuy.CreateToggle({
        Name = "Wool",
        Function = function() end,
        Default = true,
    })
    ABArmor = AutoBuy.CreateToggle({
        Name = "Armor",
        Function = function() end,
        Default = true,
    })
    ABSwords = AutoBuy.CreateToggle({
        Name = "Swords",
        Function = function() end,
        Default = true,
    })
    ABPickaxes = AutoBuy.CreateToggle({
        Name = "Pickaxes",
        Function = function() end,
        Default = false,
    })
    ABAxes = AutoBuy.CreateToggle({
        Name = "Axes",
        Function = function() end,
        Default = false,
    })
    ABTeamUpgrades = AutoBuy.CreateToggle({
        Name = "TeamUpgrades",
        Function = function() end,
        Default = false,
    })
end

do 
    local beds, luckyblocks = {Enabled = false}, {Enabled = false}
    local bedaura = {["Enabled"] = false}; bedaura = GuiLibrary.Objects.WorldWindow.API.CreateOptionsButton({
        ["Name"] = "Nuker",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    repeat task.wait(0.3) 
                        local blocktab = {(beds.Enabled and "bed" or nil), (luckyblocks.Enabled and "lucky_block" or nil), (luckyblocks.Enabled and "purple_lucky_block" or nil)}
                        local block = getBlockNear(40, blocktab)
                        if block then 
                            local bestSide = getbestside(block.Position)
                            if bestSide then
                                bedwars["breakBlock"](block.Position, true, bestSide)
                            end
                        end
                    until bedaura["Enabled"] == false
                end)
            end
        end
    })
    beds = bedaura.CreateToggle({
        Name = "Beds",
        Function = function() end,
        Default = true,
    })
    luckyblocks = bedaura.CreateToggle({
        Name = "LuckyBlocks",
        Function = function() end,
        Default = true,
    })
end

do
    local lowestY = 9999999999999
    spawn(function() 
        for i,v in next, WORKSPACE:WaitForChild("Map"):WaitForChild("Blocks"):GetChildren() do 
            local Y = v.CFrame.p.Y
            if Y < lowestY then
                lowestY = Y
            end
        end
    end)

    local connection 
    local AntiVoid = {Enabled = false}; 
    AntiVoid = GuiLibrary.Objects.WorldWindow.API.CreateOptionsButton({
        Name = "Avoid",
        Function = function(callback)
            if callback then 
                spawn(function()
                      local antivoidpart = Instance.new("Part", Workspace)
            antivoidpart.Name = "AntiVoid"
            antivoidpart.Size = Vector3.new(2100, 0.5, 2000)
            antivoidpart.Position = Vector3.new(160.5, 25, 247.5)
            antivoidpart.Transparency = 0.4
            antivoidpart.Anchored = true
            antivoidpart.Touched:connect(function(dumbcocks)
                if dumbcocks.Parent:WaitForChild("Humanoid") and dumbcocks.Parent.Name == lplr.Name then
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                    wait(0.2)
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                    wait(0.2)
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                end
            end)
            end
        end,
    })
end


do
    local scaffold = {["Enabled"] = false}
    scaffold = GuiLibrary.Objects.WorldWindow.API.CreateOptionsButton({
        ["Name"] = "Scaffold",
        ["Function"] = function(callback) 
            if callback then 
                BindToStepped("Scaffold", function()
                    if isAlive() and lplr.Character:FindFirstChild("Humanoid") ~= nil then
                        local block = getblockitem()
                        --printtable(block)
                        local newpos = lplr.Character.HumanoidRootPart.Position
                        newpos = get3Vector( Vector3.new(newpos.X, lplr.Character.HumanoidRootPart.Position.Y - 4, newpos.Z) )
                        local movedir = lplr.Character:FindFirstChild("Humanoid").MoveDirection
                        if movedir.X==0 and movedir.Z==0 and lplr.Character:FindFirstChild("Humanoid").Jump==true  then 
                            local velo = lplr.Character.HumanoidRootPart.Velocity
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(velo.X, 25, velo.Z)
                        end
                        if not isPointInMapOccupied(newpos) then
                            bedwars["placeBlock"](newpos, block)
                        end

                        local expandpos = lplr.Character.HumanoidRootPart.Position + ((lplr.Character.Humanoid.MoveDirection.Unit))
                        expandpos = get3Vector( Vector3.new(expandpos.X, lplr.Character.HumanoidRootPart.Position.Y-4, expandpos.Z) )
                        if not isPointInMapOccupied(expandpos) then
                            bedwars["placeBlock"](expandpos)
                        end

                        local expandpos2 = lplr.Character.HumanoidRootPart.Position + ((lplr.Character.Humanoid.MoveDirection.Unit*2))
                        expandpos2 = get3Vector( Vector3.new(expandpos2.X, lplr.Character.HumanoidRootPart.Position.Y-4, expandpos2.Z) )
                        if not isPointInMapOccupied(expandpos2) then
                            bedwars["placeBlock"](expandpos2)
                        end
                    end
                end)
            else
                UnbindFromStepped("Scaffold")
            end
        end
    })
end


-- other window 



-- junk basically:

local function PrepareSessionInfo() 
    local api = {}

    local posTable = {
        ["X"] = {
            ["Scale"] = 0.790697575, 
            ["Offset"] = 0,
        },
        ["Y"] = {
            ["Scale"] = 0.539999962,
            ["Offset"] = 0
        }
    }
    if betterisfile("Future/configs/SessionInfo.json") then 
        local suc, value = pcall(function() 
            return HTTPSERVICE:JSONDecode(readfile("Future/configs/SessionInfo.json"))
        end)
        if suc then 
            posTable = value
        end
    end

    local SessionInfo = Instance.new("Frame")
    local Topbar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local MainContainer = Instance.new("Frame")
    local Playtime = Instance.new("TextLabel")
    local UIGridLayout = Instance.new("UIGridLayout")
    local Lagbacks = Instance.new("TextLabel")
    local Kills = Instance.new("TextLabel")
    local Wins = Instance.new("TextLabel")
    local PlaytimeValue = Instance.new("TextLabel")
    local LagbacksValue = Instance.new("TextLabel")
    local KillsValue = Instance.new("TextLabel")
    local WinsValue = Instance.new("TextLabel")

    local p = posTable
    SessionInfo.Name = "SessionInfo"
    SessionInfo.Parent = GuiLibrary["ScreenGui"]
    SessionInfo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SessionInfo.BackgroundTransparency = 0.250
    SessionInfo.BorderSizePixel = 0
    SessionInfo.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset)
    SessionInfo.Size = UDim2.new(0, 204, 0, 98)

    Topbar.Name = "Topbar"
    Topbar.Parent = SessionInfo
    Topbar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Topbar.BackgroundTransparency = 0.600
    Topbar.BorderSizePixel = 0
    Topbar.Size = UDim2.new(0, 204, 0, 23)

    Title.Name = "Title"
    Title.Parent = Topbar
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.0500000007, 0, 0.5, 0)
    Title.Size = UDim2.new(0, 10, 0, 23)
    Title.Font = GuiLibrary.Font
    Title.Text = "Session Info"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14.000
    Title.TextXAlignment = Enum.TextXAlignment.Left

    MainContainer.Name = "MainContainer"
    MainContainer.Parent = SessionInfo
    MainContainer.AnchorPoint = Vector2.new(0.5, 0)
    MainContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainContainer.BackgroundTransparency = 1.000
    MainContainer.BorderSizePixel = 0
    MainContainer.Position = UDim2.new(0.5, 0, 0.244681045, 0)
    MainContainer.Size = UDim2.new(0, 192, 0, 72)

    Playtime.Name = "Playtime"
    Playtime.Parent = MainContainer
    Playtime.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Playtime.BackgroundTransparency = 1.000
    Playtime.Position = UDim2.new(0.0343137085, 0, -0.0584415607, 0)
    Playtime.Size = UDim2.new(0, 10, 0, 23)
    Playtime.Font = GuiLibrary.Font
    Playtime.Text = "Playtime"
    Playtime.TextColor3 = Color3.fromRGB(255, 255, 255)
    Playtime.TextSize = 14.000
    Playtime.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    Playtime.TextXAlignment = Enum.TextXAlignment.Left

    UIGridLayout.Parent = MainContainer
    UIGridLayout.FillDirection = Enum.FillDirection.Vertical
    UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
    UIGridLayout.CellSize = UDim2.new(0, 98, 0, 18)
    UIGridLayout.FillDirectionMaxCells = 5

    Lagbacks.Name = "Lagbacks"
    Lagbacks.Parent = MainContainer
    Lagbacks.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Lagbacks.BackgroundTransparency = 1.000
    Lagbacks.Position = UDim2.new(0.0343137085, 0, -0.0584415607, 0)
    Lagbacks.Size = UDim2.new(0, 10, 0, 23)
    Lagbacks.Font = GuiLibrary.Font
    Lagbacks.Text = "Lagbacks"
    Lagbacks.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lagbacks.TextSize = 14.000
    Lagbacks.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    Lagbacks.TextXAlignment = Enum.TextXAlignment.Left

    Kills.Name = "Kills"
    Kills.Parent = MainContainer
    Kills.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Kills.BackgroundTransparency = 1.000
    Kills.Position = UDim2.new(0.0343137085, 0, -0.0584415607, 0)
    Kills.Size = UDim2.new(0, 10, 0, 23)
    Kills.Font = GuiLibrary.Font
    Kills.Text = "Kills"
    Kills.TextColor3 = Color3.fromRGB(255, 255, 255)
    Kills.TextSize = 14.000
    Kills.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    Kills.TextXAlignment = Enum.TextXAlignment.Left

    Wins.Name = "Wins"
    Wins.Parent = MainContainer
    Wins.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Wins.BackgroundTransparency = 1.000
    Wins.Position = UDim2.new(0.0343137085, 0, -0.0584415607, 0)
    Wins.Size = UDim2.new(0, 10, 0, 23)
    Wins.Font = GuiLibrary.Font
    Wins.Text = "Wins"
    Wins.TextColor3 = Color3.fromRGB(255, 255, 255)
    Wins.TextSize = 14.000
    Wins.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    Wins.TextXAlignment = Enum.TextXAlignment.Left

    PlaytimeValue.Name = "PlaytimeValue"
    PlaytimeValue.Parent = MainContainer
    PlaytimeValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlaytimeValue.BackgroundTransparency = 1.000
    PlaytimeValue.Position = UDim2.new(0.53125, 0, 0, 0)
    PlaytimeValue.Size = UDim2.new(0, 96, 0, 18)
    PlaytimeValue.Font = GuiLibrary.Font
    PlaytimeValue.Text = "0d 0h 0m 0s"
    PlaytimeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlaytimeValue.TextSize = 14.000
    PlaytimeValue.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    PlaytimeValue.TextXAlignment = Enum.TextXAlignment.Right

    LagbacksValue.Name = "LagbacksValue"
    LagbacksValue.Parent = MainContainer
    LagbacksValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LagbacksValue.BackgroundTransparency = 1.000
    LagbacksValue.Position = UDim2.new(0.53125, 0, 0, 0)
    LagbacksValue.Size = UDim2.new(0, 96, 0, 18)
    LagbacksValue.Font = GuiLibrary.Font
    LagbacksValue.Text = shared.FutureSavedSessionInfo and shared.FutureSavedSessionInfo.lagbacks or "0"
    LagbacksValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    LagbacksValue.TextSize = 14.000
    LagbacksValue.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    LagbacksValue.TextXAlignment = Enum.TextXAlignment.Right

    KillsValue.Name = "KillsValue"
    KillsValue.Parent = MainContainer
    KillsValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KillsValue.BackgroundTransparency = 1.000
    KillsValue.Position = UDim2.new(0.53125, 0, 0, 0)
    KillsValue.Size = UDim2.new(0, 96, 0, 18)
    KillsValue.Font = GuiLibrary.Font
    KillsValue.Text = shared.FutureSavedSessionInfo and shared.FutureSavedSessionInfo.kills or "0"
    KillsValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    KillsValue.TextSize = 14.000
    KillsValue.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    KillsValue.TextXAlignment = Enum.TextXAlignment.Right

    WinsValue.Name = "WinsValue"
    WinsValue.Parent = MainContainer
    WinsValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WinsValue.BackgroundTransparency = 1.000
    WinsValue.Position = UDim2.new(0.53125, 0, 0, 0)
    WinsValue.Size = UDim2.new(0, 96, 0, 18)
    WinsValue.Font = GuiLibrary.Font
    WinsValue.Text = shared.FutureSavedSessionInfo and shared.FutureSavedSessionInfo.wins or "0"
    WinsValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    WinsValue.TextSize = 14.000
    WinsValue.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    WinsValue.TextXAlignment = Enum.TextXAlignment.Right

    local _i_i = GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
        Topbar.BackgroundColor3 = GuiLibrary["GetColor"]()
    end)

    table.insert(GuiLibrary["Connections"], _i_i)

    GuiLibrary["DragGUI"](SessionInfo, Topbar)

    function api.draw() 
        SessionInfo.Visible = true
    end

    function api.undraw() 
        SessionInfo.Visible = false
    end

    api.kills = KillsValue
    api.wins = WinsValue
    api.lagbacks = LagbacksValue
    api.playtime = PlaytimeValue
    api.Instance = SessionInfo

    return api
end

local SessionInfoAPI = PrepareSessionInfo()
local SessionInfoToggle = GuiLibrary["Objects"]["HUDOptionsButton"]["API"].CreateToggle({
    ["Name"] = "SessionInfo",
    ["Function"] = function(callback)
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
        if callback then 
            SessionInfoAPI.draw() 
        else
            SessionInfoAPI.undraw() 
        end
    end,
})
if GuiLibrary["HUDEnabled"] then 
    if SessionInfoToggle["Enabled"] then 
        SessionInfoAPI.draw() 
    else
        SessionInfoAPI.undraw()
    end
else
    SessionInfoAPI.undraw()
end


local detectLagback
detectLagback = function() 
    spawn(function() 
        if state() == 0 then repeat task.wait() until state() ~= states.PRE end
        if not isAlive() then repeat task.wait() until isAlive() end 
        repeat task.wait() until not isAlive() or not isnetworkowner(lplr.Character.HumanoidRootPart)
        if isAlive() then 
            SessionInfoAPI.lagbacks.Text = tostring(tonumber(SessionInfoAPI.lagbacks.Text) + 1)
        end
        repeat task.wait() until not isAlive() or isnetworkowner(lplr.Character.HumanoidRootPart)
        detectLagback()
    end)
end
detectLagback()

local ontp = game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        local api = SessionInfoAPI
		local stringtp = "shared.FutureSavedSessionInfo = {startTime ="..tostring(shared.futureStartTime)..", kills = "..api.kills.Text..", wins = "..api.wins.Text..", lagbacks = "..api.lagbacks.Text.."}"
		queueteleport(stringtp)
    end
end)

bedwars["ClientHandler"]:WaitFor("EntityDeathEvent"):andThen(function(p6)
    toDisconnect = p6:Connect(function(p7)
        if p7.fromEntity and p7.fromEntity.Name == lplr.Name then 
            SessionInfoAPI.kills.Text = tostring(tonumber(SessionInfoAPI.kills.Text) + 1)
        end
    end) 
    table.insert(GuiLibrary["Connections"], toDisconnect)
end)

spawn(function() 
    repeat task.wait() until state() == states.POST
    if state() == states.POST and isAlive() then 
        SessionInfoAPI.wins.Text = tostring(tonumber(SessionInfoAPI.wins.Text) + 1)
    end
end)

spawn(function()
    repeat task.wait(0.5) 

        local t = math.round(WORKSPACE:GetServerTimeNow()) - math.round((shared.FutureSavedSessionInfo and tonumber(shared.FutureSavedSessionInfo.startTime)) or shared.futureStartTime)
        local seconds = tostring(t % 60)
        local minutes = tostring(math.floor(t / 60) % 60)
        local hours = tostring(math.floor(t / 3600) % 24)
        local days = tostring(math.floor(t / 86400))
        seconds = tostring(seconds)
        minutes = tostring(minutes)
        hours = tostring(hours)
        days = tostring(days)
        
        local formattedPlaytime = ("%sd %sh %sm %ss"):format(days, hours, minutes, seconds)

        SessionInfoAPI.playtime.Text = formattedPlaytime
    until not shared.Future
end)

GuiLibrary["Signals"]["HUDUpdate"]:connect(function() 
    if GuiLibrary["HUDEnabled"] then 
        if SessionInfoToggle["Enabled"] then 
            SessionInfoAPI.draw() 
        else
            SessionInfoAPI.undraw()
        end
    else
        SessionInfoAPI.undraw()
    end
end)

GuiLibrary.Signals.onDestroy:connect(function()
    local api = SessionInfoAPI
    shared.FutureSavedSessionInfo = {startTime = tostring(shared.futureStartTime), kills = api.kills.Text, wins = api.wins.Text, lagbacks = api.lagbacks.Text}
    local si = SessionInfoAPI.Instance.Position

    local posTable = {
        ["X"] = {
            ["Scale"] = si.X.Scale, 
            ["Offset"] = si.X.Offset,
        },
        ["Y"] = {
            ["Scale"] = si.Y.Scale,
            ["Offset"] = si.Y.Offset
        }
    }

    local suc, value = pcall(function()
        return HTTPSERVICE:JSONEncode(posTable)
    end)
    if suc then 
        if betterisfile("Future/configs/SessionInfo.json") then 
            delfile("Future/configs/SessionInfo.json")
        end
        writefile("Future/configs/SessionInfo.json", value)
    else
        error(value)
    end

    getmetatable(Client).Get = OldClientGet
    getmetatable(Client).WaitFor = OldClientWaitFor
end)


local priolist = {
	["DEFAULT"] = 0,
	["PRIVATE"] = 1,
	["OWNER"] = 2
}
local clients = {
	ChatStrings1 = {
		["KVOP25KYFPPP4"] = "vape",
		["IO12GP56P4LGR"] = "future"
	},
	ChatStrings2 = {
		["vape"] = "KVOP25KYFPPP4",
		["future"] = "IO12GP56P4LGR"
	},
	ClientUsers = {}
}
local alreadysaidlist = {}

local function findplayers(arg)
	local temp = {}
	local continuechecking = true

	if arg == "default" and continuechecking and bedwars["CheckPlayerType"](lplr) == "DEFAULT" then table.insert(temp, lplr) continuechecking = false end
	if arg == "private" and continuechecking and bedwars["CheckPlayerType"](lplr) == "PRIVATE" then table.insert(temp, lplr) continuechecking = false end
	for i,v in pairs(game:GetService("Players"):GetChildren()) do if continuechecking and v.Name:lower():sub(1, arg:len()) == arg:lower() then table.insert(temp, v) continuechecking = false end end
	return temp
end

local commands = {
	["kill"] = function(args)
		if isAlive() then
			lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			lplr.Character.Humanoid.Health = 0
			bedwars["ClientHandler"]:Get(bedwars["ResetRemote"]):SendToServer()
		end
	end,
	["lagback"] = function(args)
		if isAlive() then
			lplr.Character.HumanoidRootPart.Velocity = Vector3.new(9999999, 9999999, 9999999)
		end
	end,
	["jump"] = function(args)
		if isAlive() and lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
			lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end,
	["sit"] = function(args)
		if isAlive() then
			lplr.Character.Humanoid.Sit = true
		end
	end,
	["unsit"] = function(args)
		if isAlive() then
			lplr.Character.Humanoid.Sit = false
		end
	end,
	["freeze"] = function(args)
		if isAlive() then
			lplr.Character.HumanoidRootPart.Anchored = true
		end
	end,
	["unfreeze"] = function(args)
		if isAlive() then
			lplr.Character.HumanoidRootPart.Anchored = false
		end
	end,
	["deletemap"] = function(args)
		for i,v in pairs(game:GetService("CollectionService"):GetTagged("block")) do
			v:Remove()
		end
	end,
	["void"] = function(args)
		if isAlive() then
			spawn(function()    
				repeat
					task.wait(0.2)
					lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, -10, 0)
				until not isAlive()
			end)
		end
	end,
	--[[["scare"] = function(args)
		local image = Instance.new("ImageLabel")
		image.ZIndex = 10
		image.Image = "http://www.roblox.com/asset/?id=7473973347"
		image.Size = UDim2.new(0, 0, 0, 0)
		image.Position = UDim2.new(0, 0, 0, -36)
		image.BackgroundTransparency = 1
		image.Parent = GuiLibrary["MainGui"]
		local sound = Instance.new("Sound")
		sound.Volume = 10
		sound.SoundId = "rbxassetid://2557531797"
		sound.Parent = workspace
		spawn(function()
			repeat task.wait() until image.IsLoaded and sound.IsLoaded
			image.Size = UDim2.new(1, 0, 1, 36)
			sound:Play()
			game:GetService("Debris"):AddItem(sound, 0.3)
			game:GetService("Debris"):AddItem(image, 0.3)
		end)
	end,]]
	["framerate"] = function(args)
		if #args >= 1 then
			if setfpscap then
				setfpscap(tonumber(args[1]) ~= "" and math.clamp(tonumber(args[1]), 1, 9999) or 9999)
			end
		end
	end,
	["crash"] = function(args)
		setfpscap(100000000)
    	print(game:GetObjects("h29g3535")[1])
	end,
--[[["playsound"] = function(args)
		if #args >= 1 then
			local function convertletter(let)
				return string.byte(let) - 96
			end
			local str = args[1]
			local newstr = ""
			for i = 1, str:len() do
				newstr = newstr..convertletter(str:sub(i, i))
			end
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://"..newstr
			sound.Parent = workspace
			sound:Play()
		end
	end,]]
	["chipman"] = function(args)
		local function funnyfunc(v)
			if v:IsA("ImageLabel") or v:IsA("ImageButton") then
				v.Image = "http://www.roblox.com/asset/?id=6864086702"
				v:GetPropertyChangedSignal("Image"):connect(function()
					v.Image = "http://www.roblox.com/asset/?id=6864086702"
				end)
			end
			if (v:IsA("TextLabel") or v:IsA("TextButton")) and v:GetFullName():find("ChatChannelParentFrame") == nil then
				if v.Text ~= "" then
					v.Text = "chips"
				end
				v:GetPropertyChangedSignal("Text"):connect(function()
					if v.Text ~= "" then
						v.Text = "chips"
					end
				end)
			end
			if v:IsA("Texture") or v:IsA("Decal") then
				v.Texture = "http://www.roblox.com/asset/?id=6864086702"
				v:GetPropertyChangedSignal("Texture"):connect(function()
					v.Texture = "http://www.roblox.com/asset/?id=6864086702"
				end)
			end
			if v:IsA("MeshPart") then
				v.TextureID = "http://www.roblox.com/asset/?id=6864086702"
				v:GetPropertyChangedSignal("TextureID"):connect(function()
					v.TextureID = "http://www.roblox.com/asset/?id=6864086702"
				end)
			end
			if v:IsA("SpecialMesh") then
				v.TextureID = "http://www.roblox.com/asset/?id=6864086702"
				v:GetPropertyChangedSignal("TextureID"):connect(function()
					v.TextureID = "http://www.roblox.com/asset/?id=6864086702"
				end)
			end
			if v:IsA("Sky") then
				v.SkyboxBk = "http://www.roblox.com/asset/?id=6864086702"
				v.SkyboxDn = "http://www.roblox.com/asset/?id=6864086702"
				v.SkyboxFt = "http://www.roblox.com/asset/?id=6864086702"
				v.SkyboxLf = "http://www.roblox.com/asset/?id=6864086702"
				v.SkyboxRt = "http://www.roblox.com/asset/?id=6864086702"
				v.SkyboxUp = "http://www.roblox.com/asset/?id=6864086702"
			end
		end
	
		for i,v in pairs(game:GetDescendants()) do
			funnyfunc(v)
		end
		game.DescendantAdded:connect(funnyfunc)
	--[[	local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://6516015896"
		sound.Parent = workspace
		sound.Looped = true
		sound:Play()]]
	end,
	["rickroll"] = function(args)
		local function funnyfunc(v)
			if v:IsA("ImageLabel") or v:IsA("ImageButton") then
				v.Image = "http://www.roblox.com/asset/?id=7083449168"
				v:GetPropertyChangedSignal("Image"):connect(function()
					v.Image = "http://www.roblox.com/asset/?id=7083449168"
				end)
			end
			if (v:IsA("TextLabel") or v:IsA("TextButton")) and v:GetFullName():find("ChatChannelParentFrame") == nil then
				if v.Text ~= "" then
					v.Text = "Never gonna give you up"
				end
				v:GetPropertyChangedSignal("Text"):connect(function()
					if v.Text ~= "" then
						v.Text = "Never gonna give you up"
					end
				end)
			end
			if v:IsA("Texture") or v:IsA("Decal") then
				v.Texture = "http://www.roblox.com/asset/?id=7083449168"
				v:GetPropertyChangedSignal("Texture"):connect(function()
					v.Texture = "http://www.roblox.com/asset/?id=7083449168"
				end)
			end
			if v:IsA("MeshPart") then
				v.TextureID = "http://www.roblox.com/asset/?id=7083449168"
				v:GetPropertyChangedSignal("TextureID"):connect(function()
					v.TextureID = "http://www.roblox.com/asset/?id=7083449168"
				end)
			end
			if v:IsA("SpecialMesh") then
				v.TextureID = "http://www.roblox.com/asset/?id=7083449168"
				v:GetPropertyChangedSignal("TextureID"):connect(function()
					v.TextureID = "http://www.roblox.com/asset/?id=7083449168"
				end)
			end
			if v:IsA("Sky") then
				v.SkyboxBk = "http://www.roblox.com/asset/?id=7083449168"
				v.SkyboxDn = "http://www.roblox.com/asset/?id=7083449168"
				v.SkyboxFt = "http://www.roblox.com/asset/?id=7083449168"
				v.SkyboxLf = "http://www.roblox.com/asset/?id=7083449168"
				v.SkyboxRt = "http://www.roblox.com/asset/?id=7083449168"
				v.SkyboxUp = "http://www.roblox.com/asset/?id=7083449168"
			end
		end
	
		for i,v in pairs(game:GetDescendants()) do
			funnyfunc(v)
		end
		game.DescendantAdded:connect(funnyfunc)
	--[[	local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://516046413"
		sound.Parent = workspace
		sound.Looped = true
		sound:Play()]]
	end,
	["gravity"] = function(args)
		workspace.Gravity = tonumber(args[1]) or 192.6
	end,
	["kick"] = function(args)
		local str = ""
		for i,v in pairs(args) do
			str = str..v..(i > 1 and " " or "")
		end
		lplr:Kick(str)
	end,
	["uninject"] = function(args)
		spawn(function() 
            GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
            GuiLibrary.Signals.onDestroy:Fire()
        end)
	end,
	["disconnect"] = function(args)
		lplr:Kick()
	end,
	["togglemodule"] = function(args)
		if #args >= 1 then
			local module = GuiLibrary["Objects"][args[1].."OptionsButton"]
			if module then
				if args[2] == "true" then
					if module["API"]["Enabled"] == false then
						module["API"]["Toggle"]()
					end
				else
					if module["API"]["Enabled"] then
						module["API"]["Toggle"]()
					end
				end
			end
		end
	end,
}

local connection1 = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:connect(function(tab, channel)
	local plr = PLAYERS:FindFirstChild(tab["FromSpeaker"])
	local args = tab.Message:split(" ")
	local client = clients.ChatStrings1[#args > 0 and args[#args] or tab.Message]
	if plr and bedwars["CheckPlayerType"](lplr) ~= "DEFAULT" and tab.MessageType == "Whisper" and client ~= nil and alreadysaidlist[plr.Name] == nil then
		alreadysaidlist[plr.Name] = true
		spawn(function()
			local connection
			for i,newbubble in pairs(game:GetService("CoreGui").BubbleChat:GetDescendants()) do
				if newbubble:IsA("TextLabel") and newbubble.Text:find(clients.ChatStrings2[client]) then
					newbubble.Parent.Parent.Visible = false
					repeat task.wait() until newbubble.Parent.Parent.Parent == nil or newbubble.Parent.Parent.Parent.Parent == nil
					if connection then
						connection:Disconnect()
					end
				end
			end
			connection = game:GetService("CoreGui").BubbleChat.DescendantAdded:connect(function(newbubble)
				if newbubble:IsA("TextLabel") and newbubble.Text:find(clients.ChatStrings2[client]) then
					newbubble.Parent.Parent.Visible = false
					repeat task.wait() until newbubble.Parent.Parent.Parent == nil or  newbubble.Parent.Parent.Parent.Parent == nil
					if connection then
						connection:Disconnect()
					end
				end
			end)
		end)
		GuiLibrary.CreateToast("Future", plr.Name.." is using "..client.."!", 60)
		clients.ClientUsers[plr.Name] = client:upper()..' USER'
	end
	local args = tab.Message:split(" ")
	--priolist[bedwars["CheckPlayerType"](plr)] > 0 and plr ~= lplr and priolist[bedwars["CheckPlayerType"](plr)] > priolist[bedwars["CheckPlayerType"](lplr)]
	if priolist[bedwars["CheckPlayerType"](lplr)] > 0 and plr == lplr then
		if tab.Message:len() >= 5 and tab.Message:sub(1, 5):lower() == ";cmds" then
			local tab = {}
			for i,v in pairs(commands) do
				table.insert(tab, i)
			end
			table.sort(tab)
			local str = ""
			for i,v in pairs(tab) do
				str = str..";"..v.."\n"
			end
			game.StarterGui:SetCore("ChatMakeSystemMessage",{
                Text = 	str,
            })
		end
	end
	if plr and priolist[bedwars["CheckPlayerType"](plr)] > 0 and plr ~= lplr and priolist[bedwars["CheckPlayerType"](plr)] > priolist[bedwars["CheckPlayerType"](lplr)] and #args > 1 then
		table.remove(args, 1)
		local chosenplayers = findplayers(args[1])
		if table.find(chosenplayers, lplr) then
			table.remove(args, 1)
			for i,v in pairs(commands) do
				if tab.Message:len() >= (i:len() + 1) and tab.Message:sub(1, i:len() + 1):lower() == ";"..i:lower() then
				--	print("hahahah")
					v(args)
					break
				end
			end
		end
	end
end)

local connection2 = lplr.PlayerGui:WaitForChild("Chat").Frame.ChatChannelParentFrame["Frame_MessageLogDisplay"].Scroller.ChildAdded:connect(function(text)
	local textlabel2 = text:WaitForChild("TextLabel")
	if bedwars["IsPrivateIngame"]() then
		local args = textlabel2.Text:split(" ")
		local client = clients.ChatStrings1[#args > 0 and args[#args] or tab.Message]
		if client then
			if textlabel2.Text:find(clients.ChatStrings2[client]) or textlabel2.Text:find("You are now chatting") or textlabel2.Text:find("You are now privately chatting") then
				text.Size = UDim2.new(0, 0, 0, 0)
				text:GetPropertyChangedSignal("Size"):connect(function()
					text.Size = UDim2.new(0, 0, 0, 0)
				end)
			end
		end
		textlabel2:GetPropertyChangedSignal("Text"):connect(function()
			local args = textlabel2.Text:split(" ")
			local client = clients.ChatStrings1[#args > 0 and args[#args] or tab.Message]
			if client then
				if textlabel2.Text:find(clients.ChatStrings2[client]) or textlabel2.Text:find("You are now chatting") or textlabel2.Text:find("You are now privately chatting") then
					text.Size = UDim2.new(0, 0, 0, 0)
					text:GetPropertyChangedSignal("Size"):connect(function()
						text.Size = UDim2.new(0, 0, 0, 0)
					end)
				end
			end
		end)
	end
end)

local function fun(plr) 
    if lplr ~= plr and bedwars["CheckPlayerType"](lplr) == "DEFAULT" and bedwars["CheckPlayerType"](plr) ~= "DEFAULT" then
        spawn(function()
            repeat task.wait() until isAlive(plr)
            repeat task.wait() until plr.Character.HumanoidRootPart.Velocity ~= Vector3.new(0, 0, 0)
            task.wait(4)
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..plr.Name.." "..clients.ChatStrings2.future, "All")
            spawn(function()
                local connection
                for i,newbubble in pairs(game:GetService("CoreGui").BubbleChat:GetDescendants()) do
                    if newbubble:IsA("TextLabel") and newbubble.Text:find(clients.ChatStrings2.future) then
                        pcall(function()
                            newbubble.Parent.Parent.Visible = false
                            repeat task.wait() until newbubble.Parent.Parent.Parent.Parent == nil
                            if connection then
                                connection:Disconnect()
                            end
                        end)
                    end
                end
                connection = game:GetService("CoreGui").BubbleChat.DescendantAdded:connect(function(newbubble)
                    if newbubble:IsA("TextLabel") and newbubble.Text:find(clients.ChatStrings2.future) then
                        pcall(function()
                            newbubble.Parent.Parent.Visible = false
                            repeat task.wait() until newbubble.Parent.Parent.Parent.Parent == nil
                            if connection then
                                connection:Disconnect()
                            end
                        end)
                    end
                end)
            end)
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Wait()
            task.wait(0.2)
            if getconnections then
                for i,v in pairs(getconnections(game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnNewMessage.OnClientEvent)) do
                    if v.Function and #debug.getupvalues(v.Function) > 0 and type(debug.getupvalues(v.Function)[1]) == "table" and getmetatable(debug.getupvalues(v.Function)[1]) and getmetatable(debug.getupvalues(v.Function)[1]).GetChannel then
                        debug.getupvalues(v.Function)[1]:SwitchCurrentChannel("all")
                    end
                end
            end
        end)
    end
end

local connection3 = PLAYERS.PlayerAdded:connect(fun)
for i,v in pairs(PLAYERS:GetPlayers()) do 
    fun(v)
end
table.insert(GuiLibrary["Connections"], connection1)
table.insert(GuiLibrary["Connections"], connection2)
table.insert(GuiLibrary["Connections"], connection3)
