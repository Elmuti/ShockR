local events = game.ReplicatedStorage
local itempickups = {}
local weaponData = {}

local ServerTime = 0

--Convar = {? VALUE, bool ISCHEAT, string DESCRIPTION [, {number RANGE_MIN, number RANGE_MAX} ] }
local ConVars = {
	sv_cheats = {false, true, "Turns cheats on"};
	sv_accelerate = {200, true, "Acceleration rate", {-math.huge, math.huge}};
	sv_airaccelerate = {5, true, "Air acceleration rate", {-math.huge, math.huge}};
	sv_max_velocity_ground = {200, true, "Maximum velocity on the ground", {-math.huge, math.huge}};
	sv_max_velocity_air = {1350, true, "Maximum velocity in the air", {-math.huge, math.huge}}; 
	sv_friction = {7.5, true, "Amount of friction on surfaces", {-math.huge, math.huge}};
	sv_motd = {"", true, "Server message of the day"};
	
	mp_gamemode = {"Deathmatch", true, "The current gamemode"};
	mp_dm_fraglimit = {10, true, "The frag limit to win the game", {1, math.huge}};
	mp_dm_timelimit = {300, true, "The time limit of the game", {1, math.huge}};
	
	mp_capturelimit = {5, true, "Flag capture limit", {1, math.huge}};

	cl_thirdperson = {false, true, "Third person camera toggle"};
	cl_autoswitch = {true, false, "Toggles auto-switching to picked up weapons"};
	cl_shellfadetime = {0.75, false, "", {0, 10}};
	cl_chathistorylength = {5, false, "", {1, 20}};
	cl_crosshairsize = {10, false, "", {-100, 100}};
	cl_crosshairgap = {2.5, false, "", {-100, 100}};
	cl_crosshairalpha = {255, false, "", {0, 255}};
	cl_footsteps = {true, false, "Toggles footstep sounds"};
	cl_drawping = {true, false, "Toggles ping counter"};
	cl_muzzleflash = {true, false, ""};
	
	cl_weaponbob_rate = {1, false, "Weapon bob animation frequency multiplier", {0, 2}};
	cl_weaponbob_amt = {1, false, "Weapon bob animation range multiplier", {0, 2}};
	cl_fov = {75, false, "", {20, 90}};
	cl_zoomfov = {20, false, "", {20, 90}};
	cl_sensitivity = {1, false, "Mouse sensitivity multiplier", {0, 100}};
	cl_zoomsensitivity = {0.85, false, "Mouse sensitivity multiplier", {0, 100}};
	cl_camera_orbit = {false, true, ""};
	cl_camera_orbit_offset = {6, true, ""};
}



local deathmatch = require(game.ReplicatedStorage.Gamemodes.Deathmatch)

local ItemSpawnCooldown = 8
local PowerupData = {
	Machinegun = {Ammo = 150, Sound = "http://www.roblox.com/asset/?id=81116815"};
	Shotgun = {Ammo = 10, Sound = "http://www.roblox.com/asset/?id=81116815"};
	Grenade = {Ammo = 10, Sound = "http://www.roblox.com/asset/?id=81116815"};
	RocketLauncher = {Ammo = 10, Sound = "http://www.roblox.com/asset/?id=81116815"};
	LightningGun = {Ammo = 100, Sound = "http://www.roblox.com/asset/?id=81116815"};
	Railgun = {Ammo = 10, Sound = "http://www.roblox.com/asset/?id=81116815"};
	PlasmaGun = {Ammo = 50, Sound = "http://www.roblox.com/asset/?id=81116815"};
	
	Machinegun_Ammo = {Ammo = 50, Sound = "http://www.roblox.com/asset/?id=81116781"};
	Shotgun_Ammo = {Ammo = 5, Sound = "http://www.roblox.com/asset/?id=81116781"};
	Grenade_Ammo = {Ammo = 5, Sound = "http://www.roblox.com/asset/?id=81116781"};
	RocketLauncher_Ammo = {Ammo = 5, Sound = "http://www.roblox.com/asset/?id=81116781"};
	LightningGun_Ammo = {Ammo = 50, Sound = "http://www.roblox.com/asset/?id=81116781"};
	Railgun_Ammo = {Ammo = 5, Sound = "http://www.roblox.com/asset/?id=81116781"};
	PlasmaGun_Ammo = {Ammo = 50, Sound = "http://www.roblox.com/asset/?id=81116781"};
	
	Health25 = {Health = 25, Sound = "http://www.roblox.com/asset/?id=81116912"};
	MegaHealth = {Health = 100, Sound = "http://www.roblox.com/asset/?id=81116912"};
	
	ArmorShard = {Armor = 5, Sound = "http://www.roblox.com/asset/?id=81116797"};
	YellowArmor = {Armor = 50, Sound = "http://www.roblox.com/asset/?id=81116806"};
	RedArmor = {Armor = 100, Sound = "http://www.roblox.com/asset/?id=81116806"};
	
	Hourglass = {Time = 2.5, Sound = "http://www.roblox.com/asset/?id=81116781"};
}

local ChatHistory = {}
local Scoreboard = {}

	
function GetScoresFromPlayer(plr)
	--[[for _, scores in pairs(Scoreboard) do
		if scores.PlayerName == plr.Name then
			return scores
		end
	end]]
	return Scoreboard[plr.Name]
end

function GetPlayerPlacement(plr)
	
end

function GetHighestScore()
	
end


function CreateChatEntry(player, body)
	if body:len() > 0 and body:sub(1,1) == "/" then
		local cmd = body:sub(2, body:len())
		if cmd == "cleardecals" then
			events.ClearDecals:FireClient(player)
		elseif cmd == "debug" and (player.Name == "StealthKing95" or player.Name == "Player1") then
			events.SetPlayerLocation:FireClient(player, CFrame.new(Vector3.new(160, 5, -110)))
		end
	else
		body = string.gsub(body, "\n", "")
		--body = game:GetService("Chat"):FilterStringAsync(body, player, playerTo)
		table.insert(ChatHistory, {OriginalPlayer = player; Sender = player.Name; Body = body; GameInfo = false;})
		print(player.Name..": "..body)
	end
end


function ReplicateShootEffect(plr, pos, tgtpos)
	--local ray = Ray.new()
	--local _, hitpos, norm = workspace:FindPartOnRayWithIgnoreList(ray, {workspace.Nodes, workspace.PlayerSpawns, workspace.ItemSpawns, workspace.ItemPickups, workspace.Characters})
	--local dh = npcLib.CreateDecal(CFrame.new(pos, pos + norm), Vector3.new(0.5 ,0.5, 0.2), "http://www.roblox.com/asset/?id=22915150", "Front", false, 0)
end


function ReplicateHitEffect(wname, hit, pos, norm, mat)
	if wname ~= "RocketLauncher" and wname ~= "Grenade" then
		--weaponData[wname].HitEffect(hit, pos, norm, mat)
	end
end



function TryDamage(player, weaponName, shooter, campos, tgtpos, tgt, ray, splashDist)
	--local hit, pos, norm = workspace:FindPartOnRayWithIgnoreList(ray, {workspace.Ignore, shooter})
	--if hit then
		TakeDamage(player, tgt, weaponName, splashDist)
	--end
end


function TakeDamage(shooter, tgt, weaponName, splashDist)
	local dmg = math.floor(weaponData[weaponName].Damage)
	if splashDist ~= nil then
		local aoe = weaponData[weaponName].AreaOfEffect
		local sdmg = weaponData[weaponName].SplashDamage
		local coef = 1 - (splashDist / aoe)
		dmg = math.floor(coef * sdmg)
	end
	
	--if tgt ~= nil and typeof(tgt) == "Instance" then
		--print("tgt: "..tostring(tgt).."typeof(tgt): "..typeof(tgt).." ("..tgt:GetFullName()..")")
	--elseif tgt ~= nil and typeof(tgt) ~= "Instance" then
		--print("tgt: "..tostring(tgt).."typeof(tgt): "..typeof(tgt).." (nil)")
	--end
	
	local plr = game.Players:FindFirstChild(tostring(tgt))
	if plr then
		game.ReplicatedStorage.TakeDamage:FireClient(plr, dmg, shooter)
		Scoreboard[shooter.Name].Damage = Scoreboard[shooter.Name].Damage + dmg
		if game.ReplicatedStorage.GetPlayerHealth:InvokeClient(plr) <= 0 and not plr:FindFirstChild("WasKilledRecently") then
			local bv = Instance.new("BoolValue", plr)
			bv.Name = "WasKilledRecently"
			bv.Value = true
			game.Debris:AddItem(bv, 4)
			game.ReplicatedStorage.CreateKillfeedEntry:FireAllClients(shooter.Name, weaponName, plr.Name)
			
			events.PlayerDied:FireAllClients(plr, weaponName)
			
			--dont award kills for suicides
			if shooter.Name ~= plr.Name then
				game.ReplicatedStorage.AwardFrag:FireClient(shooter, plr.Name)
				Scoreboard[shooter.Name].Kills = Scoreboard[shooter.Name].Kills + 1
				Scoreboard[shooter.Name].Score = Scoreboard[shooter.Name].Score + 10
			end
			Scoreboard[tgt].Deaths = Scoreboard[tgt].Deaths + 1
		end
	end
end


function TakePowerup(player, powerup)
	local receivedAmount = PowerupData[powerup.Name]
	game.ReplicatedStorage.PlaySoundClient:FireAllClients("3d", "powerupTake", receivedAmount.Sound, 0.5, 1, false, 3, powerup)
	
	if receivedAmount.Ammo ~= nil then
		game.ReplicatedStorage.GiveAmmo:FireClient(player, string.gsub(powerup.Name, "_Ammo", ""), receivedAmount.Ammo)
	end
	if receivedAmount.Health ~= nil then
		game.ReplicatedStorage.GiveHealth:FireClient(player, receivedAmount.Health)
	end
	if receivedAmount.Armor ~= nil then
		game.ReplicatedStorage.GiveArmor:FireClient(player, receivedAmount.Armor)
	end
	if receivedAmount.Time ~= nil then
		game.ReplicatedStorage.GiveTime:FireClient(player, receivedAmount.Time)
	end
end


function Init()
	local tn = workspace:FindFirstChild("GameThumbnail")
	if tn then
		tn:Destroy()
	end
	for _, wmodule in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
		weaponData[wmodule.Name] = require(wmodule)
	end
	
	events.ReplicateHitEffect.OnServerEvent:connect(ReplicateHitEffect)
	events.ReplicateShootEffect.OnServerEvent:connect(ReplicateShootEffect)
	events.TryDamage.OnServerEvent:connect(TryDamage)
	events.TakeDamage.OnServerEvent:connect(TakeDamage)
	events.SendMessage.OnServerEvent:connect(CreateChatEntry)
	events.PlaySoundOtherClients.OnServerEvent:connect(function(plr, ...)
		for _, p in pairs(game.Players:GetPlayers()) do
			if p ~= plr then
				game.ReplicatedStorage.PlaySoundClient:FireClient(p, ...)
			end
		end
	end)
	events.FireWeaponServer.OnServerEvent:connect(function(cplr, shooter, wname, campos, mpos)
		local wcode = weaponData[wname]
		if wcode then
			for _, plr in pairs(game.Players:GetPlayers()) do
				--if plr ~= cplr then
					events.FireWeaponClient:FireClient(plr, shooter, wname, campos, mpos, true)
				--end
			end
		end
	end)
	events.FireAbilityServer.OnServerEvent:connect(function(cplr, player, wepname, campos, mpos, ability)
		for _, plr in pairs(game.Players:GetPlayers()) do
			--if plr ~= cplr then
				events.FireAbilityClient:FireClient(plr, player, wepname, campos, mpos, ability)
			--end
		end
	end)
	events.Push.OnServerEvent:connect(function(callingPlr, pushableName, pushOrigin, pushForce)
		pcall(function()
			events.Push:FireClient(game.Players:FindFirstChild(pushableName), pushOrigin, pushForce)
		end)
	end)
	
end


function GenerateItempickups()
	itempickups = {}
	for _, s in pairs(workspace.ItemSpawns:GetChildren()) do
		s.Transparency = 1
		s.BillboardGui:Destroy()
		local mdl = game.ReplicatedStorage.Models:FindFirstChild(s.Item.Value)
		if mdl then
			mdl = mdl:Clone()
			
			if mdl.ClassName == "Model" then
				mdl:SetPrimaryPartCFrame(CFrame.new(s.CFrame.p + Vector3.new(0, 2, 0)))
				mdl:SetPrimaryPartCFrame(mdl:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(90), 0, 0))
			else
				mdl.CFrame = CFrame.new(s.CFrame.p + Vector3.new(0, 1.5, 0))
				mdl.CFrame = mdl.CFrame * CFrame.Angles(math.rad(90), 0, 0)
			end
			
			
			table.insert(itempickups, mdl)
			mdl.Parent = workspace.ItemPickups
			
			spawn(function()
				local total = 0
				while true do
					local dt = wait(1/20)
					total = total + dt
					for _, plr in pairs(game.Players:GetPlayers()) do
						local ppos, mpos, yrot
						pcall(function()
							ppos = events.GetPlayerLocation:InvokeClient(plr)
						end)
						if ppos then
							if mdl.ClassName == "Model" then
								if (ppos - mdl:GetPrimaryPartCFrame().p).magnitude < 4 and mdl:GetChildren()[1].Transparency < 1 then
									TakePowerup(plr, mdl)
									spawn(function()
										for _, p in pairs(mdl:GetChildren()) do
											if p:IsA("BasePart") then
												local pt = p:FindFirstChild("NumberValue") or Instance.new("NumberValue", p)
												pt.Name = "PrevTransparency"
												pt.Value = p.Transparency
												p.Transparency = 1
											end
										end
										
										if mdl.Name == "MegaHealth" or mdl.Name == "RedArmor" or mdl.Name == "YellowArmor" then
											wait(30)
										else
											wait(ItemSpawnCooldown)
										end
										for _, p in pairs(mdl:GetChildren()) do
											if p:IsA("BasePart") then
												if p:FindFirstChild("PrevTransparency") then
													p.Transparency = p.PrevTransparency.Value
												else
													p.Transparency = 0
												end
											end
										end
									end)
								end
							else
								if (ppos - mdl.Position).magnitude < 4 and mdl.Transparency < 1 then
									TakePowerup(plr, mdl)
									spawn(function()
										mdl.Transparency = 1
										if mdl.Name == "MegaHealth" or mdl.Name == "RedArmor" or mdl.Name == "YellowArmor" then
											wait(30)
										else
											wait(ItemSpawnCooldown)
										end
										mdl.Transparency = 0
									end)
								end
							end
						end
					end
				end
			end)
			
		else
			warn(s.Item.Value.." not a valid item pickup")
		end
	end
end


--function game.ReplicatedStorage.GetPickup.OnServerInvoke(player, pickup)
--
--end

GenerateItempickups()
Init()

function events.GetServerChat.OnServerInvoke(player)
	--return ChatHistory
	local copy = {}
	
	for i, msg in pairs(ChatHistory) do
		if msg.OriginalPlayer ~= nil then
			pcall(function()
				copy[i] = {
					OriginalPlayer = msg.OriginalPlayer;
					Sender = msg.Sender;
					Body = game:GetService("Chat"):FilterStringAsync(msg.Body, msg.OriginalPlayer, player);
					GameInfo = msg.GameInfo;
				}
			end)
		end
	end
	
	return copy
end

function events.GetSCVars.OnServerInvoke(player)
	return ConVars
end

function events.GetServerTime.OnServerInvoke(player)
	return tick()
end

function events.GetServerRoundTime.OnServerInvoke(player)
	return ServerTime
end

function events.GetPlayerLocation.OnServerInvoke(player, plrToGetFrom)
	return events.GetPlayerLocation:InvokeClient(plrToGetFrom)
end

function events.GetCurrentWeapon.OnServerInvoke(player, playerToGetFrom)
	return events.GetCurrentWeapon:InvokeClient(playerToGetFrom)
end


function events.GetMouseHit.OnServerInvoke(player, playerToGetFrom)
	if playerToGetFrom ~= nil then
		return events.GetMouseHit:InvokeClient(playerToGetFrom)
	end
	return Vector3.new()
end

function events.Ping.OnServerInvoke(player)
	return tick()
end


function events.GetClientPing.OnServerInvoke(_, plrToGetFrom)
	return events.GetClientPing:InvokeClient(plrToGetFrom)
end


function events.GetPlayerScores.OnServerInvoke(_, plr)
	return Scoreboard
end

function events.GetPlayerGhosting.OnServerInvoke(caller, plr)
	if plr ~= nil then
		return events.GetPlayerGhosting:InvokeClient(plr)
	end
	return false
end

function events.GetPlayerBarrier.OnServerInvoke(caller, plr)
	if plr ~= nil then
		return events.GetPlayerBarrier:InvokeClient(plr)
	end
	return false
end

events.GetPlayerPlacement.OnServerInvoke = GetPlayerPlacement


game.Players.PlayerRemoving:connect(function(player)
	for _, p in pairs(game.Players:GetPlayers()) do
		if p ~= player then
			events.PlayerRemoving:FireClient(p, player.Name)
		end
	end
	
	table.insert(ChatHistory, {OriginalPlayer = player; Sender = player.Name; Body = player.Name.." has left the game."; GameInfo = true;})
	
	local i = 0
	for _, scores in pairs(Scoreboard) do
		i = i + 1
		if scores.PlayerName == player.Name then
			--table.remove(Scoreboard, i)
			local newscores = {}
			for k, v in pairs(Scoreboard) do
				if k ~= player.Name then
					newscores[k] = v
				end
			end
			Scoreboard = newscores
			break
		end
	end
end)

function ClearScoreboard()
	for _, scores in pairs(Scoreboard) do
		for key, value in pairs(scores) do
			if key ~= "PlayerName" then
				scores[key] = 0
			end
		end
	end
end

game.Players.PlayerAdded:connect(function(plr)
	events.PlayerAdded:FireAllClients(plr)
	table.insert(ChatHistory, {OriginalPlayer = plr; Sender = plr.Name; Body = plr.Name.." has joined the game."; GameInfo = true;})
	
	Scoreboard[plr.Name] = {
		PlayerName = plr.Name;
		Score = 0;
		Kills = 0;
		Deaths = 0;
		Damage = 0;
		Time = 0;
		Ping = 0;
	}
	
	plr.CharacterAdded:connect(function(char)
		wait()
		if not plr:FindFirstChild("JoinedAlready") then
			local spawns = workspace.PlayerSpawns:GetChildren()
			local cspawn = spawns[math.random(1, #spawns)]
			--char:SetPrimaryPartCFrame(cspawn.CFrame)
			events.SetPlayerLocation:FireClient(plr, cspawn.CFrame)
			
			char.Humanoid.WalkSpeed = 32
			char.Humanoid.JumpPower = 50
			char.Head.Mesh:Destroy()
			
			for _, cmesh in pairs(game.ReplicatedStorage.Characters.Circuit:GetChildren()) do
				if cmesh.ClassName == "CharacterMesh" then
					local nm = cmesh:Clone()
					nm.Parent = char
				else
					local nm = cmesh:Clone()
					nm.Parent = char.Head
				end
			end
			
			local jv = Instance.new("BoolValue")
			jv.Name = "JoinedAlready"
			jv.Parent = plr
		end
	end)
end)


while true do
	local dt = wait(1/10)
	ServerTime = ServerTime + dt
	local gameover, winner = deathmatch.GetStatus(ServerTime, ConVars, Scoreboard)
	if gameover then
		wait(1)
		for _, plr in pairs(game.Players:GetPlayers()) do
			if plr.name == winner then
				events.GameEnded:FireClient(plr, 16.5, true)
			else
				events.GameEnded:FireClient(plr, 16.5, false)
			end
		end
		wait(16.5)
		ClearScoreboard()
		ServerTime = 0
	end
end