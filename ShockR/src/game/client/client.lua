game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
game:GetService("StarterGui"):SetCore("TopbarEnabled", false)
local plabel = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("PingLabel")
local pingremote = game.ReplicatedStorage.Ping

local UseWeaponViewmodel = true

local hrpOffsetFromGround = 3
local MOUSE_MIN, MOUSE_MAX = math.rad(-80), math.rad(80) --down angle, up angle
local SENSITIVITY = Vector3.new(0.15, 0.15, 0) --horizontal, vertical, zoom?
local mouseAngles = Vector2.new()

local ConVars = {
	sv_accelerate = 200;
	sv_airaccelerate = 5;
	sv_max_velocity_ground = 200;
	sv_max_velocity_air = 1350; 
	sv_friction = 7.5;
}

local actualMouseHit = Vector3.new()
local accelDir = Vector3.new()
local playerVelocity = Vector3.new()
local prevVelocity = Vector3.new()
local pushVector = Vector3.new()
local movementKeysDown = {W = false; A = false; S = false; D = false; Space = false;}

local RAYMDL
local jumpedOnPrevFrame = false
local barrierUp = false
local charInvisible = false
local respawning = false
local events = game.ReplicatedStorage
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local cam = workspace.CurrentCamera
local mouse = player:GetMouse()
mouse.Icon = "rbxassetid://810062788"--http://www.roblox.com/asset/?id=810062788
local pickups = workspace.ItemPickups:GetChildren()
local clouds
local latency = 0
local CurrentSituation = ""
local PrevSituation = ""
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local assetLib = Orakel.LoadModule("AssetLib")
local weaponData = {}
local lastHurtSound = tick()
local ClientTime = 0

local chatMessageDisplayTime = 4.5

local VelOffset = Vector3.new()
local PlayerModels = {}
local canfire = true
local itemFloatHeight = 0.01
local equippedWeapon
local weaponCode
local firingWeapon = false
local lastShotFired = tick()
local chatlog = {}
local chatVisible = false
local AbilityIsInCooldown = false

local PlayerStats = {
	Weapons = {
		Machinegun = 	 {Ammo = 150; MaxAmmo = 150; Owned = true;};
		Shotgun =   	 {Ammo = 25; MaxAmmo = 25; Owned = false;};
		Grenade =        {Ammo = 25; MaxAmmo = 25; Owned = false;};
		RocketLauncher = {Ammo = 25; MaxAmmo = 25; Owned = false;};
		LightningGun =   {Ammo = 150; MaxAmmo = 150; Owned = false;};
		Railgun =        {Ammo = 25; MaxAmmo = 25; Owned = false;};
		PlasmaGun =      {Ammo = 150; MaxAmmo = 150; Owned = false;};
	};
	
	Health = 100;
	MaxHealth = 100;
	Armor = 15;
	MaxArmor = 100;
}

local WeaponIndexes = {
	"Machinegun";
	"Shotgun";
	"Grenade";
	"RocketLauncher";
	"LightningGun";
	"Railgun";
	"PlasmaGun";
}


function DrawLineDebug(a, b)
	local beam = Instance.new("Part")
	beam.Name = "BEAM"
	beam.BrickColor = BrickColor.new("Bright red")
	beam.Material = Enum.Material.Neon
	beam.Transparency = 0
	beam.Anchored = true
	beam.CanCollide = false
	
	local distance = (a - b).magnitude
	beam.Size = Vector3.new(0.3, 0.3, distance)
	beam.CFrame = CFrame.new(a, b) * CFrame.new(0, 0, -distance / 2)
	beam.Parent = workspace.Ignore
	--game:GetService("Debris"):AddItem(beam, 0.08)
	return beam
end


function GetWeaponIndex(wepname)
	for i = 1, #WeaponIndexes do
		if WeaponIndexes[i] == wepname then
			return i
		end
	end
	return 1
end


function GetWeaponName(index)
	if index > 7 then
		return "Machinegun"
	elseif index < 1 then
		return "PlasmaGun"
	end
	for i = 1, #WeaponIndexes do
		if i == index then
			return WeaponIndexes[i]
		end
	end
	return "Machinegun"
end

local CooldownReduction = 0

function UseAbility()
	local curAbility = "Barrier"
	local ability = require(game.ReplicatedStorage.Abilities[curAbility])

	if not AbilityIsInCooldown then
		AbilityIsInCooldown = true
		local frame = player.PlayerGui.HUD.SpecialAbility
		frame.AbilityFrame.Image = "http://www.roblox.com/asset/?id=847342696"
		frame.SkillIcon.Visible = false
		frame.AbilityUseLabel.Visible = false
		
		spawn(function()
			ability.FireClient(player, equippedWeapon, cam.CFrame.p, mouse.Hit.p)
			events.FireAbilityServer:FireServer(player, equippedWeapon.Name, cam.CFrame.p, mouse.Hit.p, curAbility)
		end)
		
		if ability.Duration then
			local t = ability.Duration
			frame.AbilityTimer.Text = mathLib.Round(t)
			frame.AbilityTimer.Visible = true
			while t > 0 do
				local dt = wait()
				t = t - dt
				frame.AbilityTimer.Text = mathLib.Round(t, 1)
			end
		end

		local t = ability.Cooldown
		frame.AbilityTimer.Text = mathLib.Round(t)
		frame.AbilityTimer.Visible = true
		while t > 0 do
			local dt = wait()
			t = t - dt - CooldownReduction
			CooldownReduction = 0
			if t < 10 then
				frame.AbilityTimer.Text = mathLib.Round(t, 1)
			else
				frame.AbilityTimer.Text = mathLib.Round(t)
			end
		end
		frame.AbilityFrame.Image = "rbxassetid://847342692"
		frame.AbilityTimer.Visible = false
		frame.SkillIcon.Visible = true
		frame.AbilityUseLabel.Visible = true
		AbilityIsInCooldown = false
		CooldownReduction = 0
	end
end




function UpdateJumpPadLogic(dt)
	local vel = Vector3.new()
	for _, pad in pairs(workspace.JumpPads:GetChildren()) do
		if (pad.JumpPad.Position - char.PrimaryPart.Position).magnitude < 5 then
			--playerVelocity = Vector3.new()
			vel = pad.JumpPad.JumpVelocity.Value
			sndLib.PlaySoundClient("global", "jumpPAD", "http://www.roblox.com/asset/?id=81116553", 0.3, 1, false, 1)
			sndLib.PlaySoundOtherClients("3d", "jumpPAD", "http://www.roblox.com/asset/?id=81116553", 0.3, 1, false, pad.JumpPad)
		end
	end
	VelOffset = vel
end

local lastFallDamage = tick()
local lastFallSound = tick()

function Grounded()
	local ray = Ray.new(char.PrimaryPart.Position, Vector3.new(0, -(hrpOffsetFromGround + 0.1), 0))
	local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char, workspace.Ignore, workspace.PlayerSpawns, workspace.ItemPickups, workspace.ItemSpawns, workspace.Nodes})
	if hit then
		char:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0, hrpOffsetFromGround, 0)))
		
		local downvel = math.abs(playerVelocity.Y)
		--print(downvel)
		if downvel >= 20 and math.abs(tick() - lastFallSound) > 0.5 then
			sndLib.PlaySoundClient("global", "fall", "rbxassetid://821077662", 0.3, 1, false, 1)
			lastFallSound = tick()
		end
		
		if downvel >= 60 and math.abs(tick() - lastFallDamage) > 1 then
			local falldmg = (downvel - 60) * 1.5
			TakeDamage(falldmg, player)
			lastFallDamage = tick()
		end
		
		return true
	end
	return false
end


function Accelerate(accelDir, prevVelocity, accelerate, max_velocity, dt, grounded)
	local projVel = prevVelocity:Dot(accelDir)
	local accelVel = accelerate * dt
	
	--If necessary, truncate the accelerated velocity so the vector projection does not exceed max_velocity
	if projVel + accelVel > max_velocity then
		accelVel = max_velocity - projVel
	end
	
	return prevVelocity + accelDir * accelVel
end

function MoveGround(accelDir, prevVelocity, dt, grounded)
	local speed = prevVelocity.magnitude
	if speed ~= 0 then
		local drop = speed * ConVars.sv_friction * dt --calculate friction
		prevVelocity = prevVelocity * math.max(speed - drop, 0) / speed --friction affects velocity
	end
	
	return Accelerate(accelDir, prevVelocity, ConVars.sv_accelerate, ConVars.sv_max_velocity_ground, dt, grounded)
end

function MoveAir(accelDir, prevVelocity, dt, grounded)
	return Accelerate(accelDir, prevVelocity, ConVars.sv_airaccelerate, ConVars.sv_max_velocity_air, dt, grounded)
end


function SwitchWeapon(curwep, direction, indexOverride, playSound)
	local playSound = playSound or true
	if playSound then
		sndLib.PlaySoundClient("global", "wep_switch", "rbxassetid://823816849", 0.15, 1, false, 2)
	end
	equippedWeapon:Destroy()
	local curi = GetWeaponIndex(equippedWeapon.Name)
	local newname = GetWeaponName(indexOverride or (curi + -(direction)))
	local newGun = game.ReplicatedStorage.Models[newname]:Clone()
	newGun.Parent = char
	equippedWeapon = newGun
	if weaponCode.StopFire ~= nil then
		weaponCode.StopFire()
	end
	weaponCode.UnEquip()
	weaponCode = weaponData[equippedWeapon.Name]
	weaponCode.Equip()
	
	for _, frame in pairs(player.PlayerGui.HUD.WeaponsFrame:GetChildren()) do
		if frame.Name ~= newname then
			frame.BackgroundTransparency = 1
		end
	end
	player.PlayerGui.HUD.WeaponsFrame[newname].BackgroundTransparency = 0.45
end

function CreateViewmodel(char, mdl)
	local mdl = mdl:Clone()
	mdl.Name = "Viewmodel"
	mdl.Parent = char
	return mdl
end


function CreatePlayerModel(originalPlayer)
	local dir = workspace:FindFirstChild("Characters") or Instance.new("Model", workspace)
	if dir.Name ~= "Characters" then dir.Name = "Characters" end
	
	local char = game.ReplicatedStorage.Characters.PlayerModel:Clone()
	char.Name = originalPlayer.Name
	char["Left Arm"].Transparency = 1
	char["Right Arm"].Transparency = 1
	
	local arms = game.ReplicatedStorage.Characters.ArmsViewmodel:Clone()
	arms.Parent = char
	
	if player == originalPlayer then
		for _, p in pairs(arms:GetChildren()) do
			if p:IsA("BasePart") then
				p.Transparency = 1
			end
		end
	end
	
	char.Parent = dir
	char:MakeJoints()
	
	return char
end


function UpdatePlayermodels(dt)
	--create default values if InvokeServer fails for some reason
	local pos, mpos, yrot = Vector3.new(156, 3.5, -115), Vector3.new(265, 3.5, -115), 0
	local cwep = "Machinegun"
	
	local dir = workspace:FindFirstChild("Characters") or Instance.new("Model", workspace)
	if dir.Name ~= "Characters" then dir.Name = "Characters" end
	
	for _, plr in pairs(game.Players:GetPlayers()) do
		local mdl = dir:FindFirstChild(plr.Name) --Get the custom character of plr
		if mdl and mdl.PrimaryPart ~= nil then
			if mdl ~= nil and plr.Name ~= player.Name then
				pcall(function()
					pos, mpos, yrot = events.GetPlayerLocation:InvokeServer(plr)
					cwep = events.GetCurrentWeapon:InvokeServer(plr)
				end)
				if mdl.PrimaryPart ~= nil then
					mdl:SetPrimaryPartCFrame(CFrame.new(pos) * yrot) --set player CFrame
				end
				
				local wmdl = mdl:FindFirstChild(cwep)
				if not wmdl then --3rd person weapon model doesnt exist, create one
					wmdl = game.ReplicatedStorage.Models[cwep]:Clone()
					wmdl.Parent = mdl
					wmdl:MakeJoints()
				end
				local weaponCode = weaponData[cwep]
	
				--Delete any weapon viewmodels that arent the currently selected weapon
				for _, wm in pairs(mdl:GetChildren()) do
					if wm.ClassName == "Model" then
						for _, wname in pairs(WeaponIndexes) do
							if wm.Name == wname and wm.Name ~= cwep then
								wm:Destroy()
							end
						end
					end
				end

				local ghosting = false

				pcall(function()
					ghosting = events.GetPlayerGhosting:InvokeServer(plr)
				end)
				
				local arms = mdl:FindFirstChild("ArmsViewmodel")
				if ghosting then
					Orakel.RecursiveSearch(mdl.Head, function(obj) return (obj.ClassName == "Decal") end, function(obj) obj.Transparency = 1 end)
					Orakel.ToggleVisible(mdl, 1, false)
					Orakel.ToggleVisible(arms, 1, false, {"Part"})
					if not equippedWeapon.Name == "Machinegun" then
						Orakel.ToggleVisible(wmdl, 1, false, {"Muzzle", "Barrel"})
					else
						Orakel.ToggleVisible(wmdl, 1, false, {"Muzzle"})
					end
				else
					Orakel.RecursiveSearch(mdl.Head, function(obj) return (obj.ClassName == "Decal") end, function(obj) obj.Transparency = 0 end)
					Orakel.ToggleVisible(mdl, 0, false)
					Orakel.ToggleVisible(arms, 0, false, {"Part"})
					Orakel.ToggleVisible(wmdl, 0, false, {"Muzzle", "Barrel"})
				end

				local bup = false
				
				pcall(function()
					bup = events.GetPlayerBarrier:InvokeServer(plr)
				end)
				
				if bup and not mdl:FindFirstChild("Barrier") then
					local barrier = game.ReplicatedStorage.Particles.Barrier:Clone()
					barrier.Parent = mdl
				elseif not bup then
					local barrier = mdl:FindFirstChild("Barrier")
					if barrier then
						barrier:Destroy()
					end
				end
				
				local barrier = mdl:FindFirstChild("Barrier")
				if barrier then
					barrier:SetPrimaryPartCFrame(CFrame.new(mdl:GetPrimaryPartCFrame().p, mpos))
				end
				
				--Set 3rd person weapon model's CFrame
				wmdl:SetPrimaryPartCFrame(
					CFrame.new(pos, mpos) 
					* CFrame.new(weaponCode.ViewModel_3rdPerson.Offset.X or 0.4, weaponCode.ViewModel_3rdPerson.Offset.Y or 0.7, weaponCode.ViewModel_3rdPerson.Offset.Z or -2.15) 
					* CFrame.Angles(math.rad(weaponCode.ViewModel.Angle.X), math.rad(weaponCode.ViewModel.Angle.Y), math.rad(weaponCode.ViewModel.Angle.Z))
				)
				mdl.ArmsViewmodel:SetPrimaryPartCFrame(CFrame.new(pos, mpos) * CFrame.new(0.4, 0.7, -2.15))
				
			elseif mdl == nil and plr.Name ~= player.Name then --Character model doesnt exist, create one
				PlayerModels[plr.Name] = CreatePlayerModel(plr)
			end
		else
			--print("playermodel doesnt exist or hrp died")
			if PlayerModels[plr.Name] then
				PlayerModels[plr.Name]:Destroy()
			end
			PlayerModels[plr.Name] = CreatePlayerModel(plr)
		end
	end
end


function SendCurrentBody()
	if string.len(player.PlayerGui.HUD.Chat.InputFrame.TextBox.Text) > 0 then
		events.SendMessage:FireServer(player.PlayerGui.HUD.Chat.InputFrame.TextBox.Text)
		--print("sending:    "..player.PlayerGui.HUD.Chat.InputFrame.TextBox.Text)
	end
end

function GetOldestMessage()
	local messages = player.PlayerGui.HUD.Chat.Messages:GetChildren()
	local oldest
	for i = 1, #messages do
		local curmsg = messages[i]
		if curmsg.Name == "ChatMessage" or curmsg.Name == "SystemChatMessage" then
			if oldest == nil then
				oldest = curmsg
			else
				if curmsg.Time.Value < oldest.Time.Value then
					oldest = curmsg
				end
			end
		end
	end
	return oldest
end

function ToggleChatWindow()
	chatVisible = not chatVisible
	player.PlayerGui.HUD.Chat.HelpFrame.Visible = not player.PlayerGui.HUD.Chat.HelpFrame.Visible
	player.PlayerGui.HUD.Chat.InputFrame.Visible = not player.PlayerGui.HUD.Chat.InputFrame.Visible
	if chatVisible then
		player.PlayerGui.HUD.Chat.InputFrame.TextBox:CaptureFocus()
	else
		--player.PlayerGui.HUD.Chat.InputFrame.TextBox:ReleaseFocus()
		player.PlayerGui.HUD.Chat.InputFrame.TextBox.Text = ""
	end
end


function ToggleScoreboard()
	player.PlayerGui.HUD.Scoreboard.Visible = not player.PlayerGui.HUD.Scoreboard.Visible
end


function FindHighestScore(t, sortBy)
	local highestscore = t[1]
	for i = 2, #t do
		if t[i][sortBy] > highestscore[sortBy] then
			highestscore = t[i]
		end
	end
	return highestscore.PlayerName
end


function SortScoreboardBy(scoreboard, sortBy)
	local t = {}
	for plrname, scores in pairs(scoreboard) do
		table.insert(t, scores)
	end
	
	local ret = {}
	while #t > 0 do
		local highest = FindHighestScore(t, sortBy)
		table.insert(ret, highest)
		for i, data in pairs(t) do
			if data.PlayerName == highest then
				table.remove(t, i)
			end
		end
	end
	
	return ret
end

function GetMyPlacing(sortedNames)
	for i = 1, #sortedNames do
		if sortedNames[i] == player.Name then
			return i
		end
	end
end

function UpdateScoreboard(dt)
	local playerframes = player.PlayerGui.HUD.Scoreboard.Main.PlayerList:GetChildren()
	local scoreboard = {}
	
	pcall(function()
		scoreboard = events.GetPlayerScores:InvokeServer()
	end)
	
	
	local sortedNames = SortScoreboardBy(scoreboard, "Score")
	
	local p1 = sortedNames[1]
	local p2 = sortedNames[2]
	PrevSituation = CurrentSituation
	--print("prev sit: "..PrevSituation.."  cur sit: "..CurrentSituation)
	if #sortedNames > 1 then
		if p1 == player.Name and not (scoreboard[p1].Score == scoreboard[p2].Score) then
			CurrentSituation = "LEAD"
		elseif p1 ~= player.Name and not (p2 == player.Name and scoreboard[p1].Score == scoreboard[p2].Score) then
			CurrentSituation = "NOT_LEADING_OR_TIED"
		elseif scoreboard[p1].Score == scoreboard[p2].Score and (p1 == player.Name or p2 == player.Name) then
			CurrentSituation = "TIED"
		end
	else
		CurrentSituation = "LEAD"
	end
	if CurrentSituation ~= PrevSituation then
		if CurrentSituation == "TIED" then
			sndLib.PlaySoundClient("global", "tied_for_the_lead", "rbxassetid://822279510", 0.3, 1, false, 4)
		elseif CurrentSituation == "LEAD" then
			sndLib.PlaySoundClient("global", "taken_the_lead", "rbxassetid://822279334", 0.3, 1, false, 4)
		elseif CurrentSituation == "NOT_LEADING_OR_TIED" then
			sndLib.PlaySoundClient("global", "lost_the_lead", "rbxassetid://822279169", 0.3, 1, false, 4)
		end
	end
	
	for i, plrname in pairs(sortedNames) do
		local scores = scoreboard[plrname]
		local plr = game.Players:FindFirstChild(plrname)
		if plr then
			spawn(function()
				local f = player.PlayerGui.HUD.Scoreboard.Main.PlayerList:FindFirstChild(plr.Name)
				if not f then
					f = game.ReplicatedStorage.PlayerFrame:Clone()
					f.Size = UDim2.new(1, 0, 0.1, 0)
					f.Name = plr.Name
					f.Position = UDim2.new(0, 0, 0.1 * i, 0)
					f.BackgroundTransparency = 1
					f.Parent = player.PlayerGui.HUD.Scoreboard.Main.PlayerList
					f.Icon.Image = game:GetService("Players"):GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end
	
				player.PlayerGui.HUD.Scoreboard.Placing.Text = mathLib.IntegerToNumeral(GetMyPlacing(sortedNames))
				if CurrentSituation == "TIED" then
					player.PlayerGui.HUD.Scoreboard.PlacingFrags.Text = "  place with "..tostring(scores.Kills).." (TIED)"
				else
					player.PlayerGui.HUD.Scoreboard.PlacingFrags.Text = "  place with "..tostring(scores.Kills)
				end
				f.Position = UDim2.new(0, 0, 0.1 * i, 0)
				f.PlayerName.Text = plr.Name
				f.Score.Text = scores.Score
				f.Time.Text = mathLib.SecondsToTimerFormat(ClientTime)
				pcall(function()
					f.Ping.Text = events.GetClientPing:InvokeServer(plr).."ms"
				end)
				f.KD.Text = scores.Kills.." / "..scores.Deaths
				f.DMG.Text = scores.Damage
			end)
		end
	end
end


function CreateChatMessage(sender, msg, ypos, isSystemMessage)
	local f = game.ReplicatedStorage.ChatMessage:Clone()
	
	f.Sender.Text = sender..":"
	f.Body.Text = msg
	
	if isSystemMessage then
		f:Destroy()
		f = game.ReplicatedStorage.SystemChatMessage:Clone()
		f.Body.Text = msg
		f.Sender.Text = ""
	end
	
	print(f.Sender.Text .. f.Body.Text)
	
	for _, msg in pairs(player.PlayerGui.HUD.Chat.Messages:GetChildren()) do
		if msg.Name == "ChatMessage" or msg.Name == "SystemChatMessage" then
			msg.Position = UDim2.new(msg.Position.X.Scale, msg.Position.X.Offset, msg.Position.Y.Scale - 0.1, 0)
		end
	end
	
	if #player.PlayerGui.HUD.Chat.Messages:GetChildren() >= 7 then
		local o = GetOldestMessage()
		o:Destroy()
	end
	
	f.Position = UDim2.new(0, 0, 0.7, 0)
	local x = game:GetService("TextService"):GetTextSize(f.Sender.Text, f.Sender.TextSize, f.Sender.Font, f.Sender.AbsoluteSize).X
	f.Body.Position = UDim2.new(0, x + 18, 0, 0)
	f.Parent = player.PlayerGui.HUD.Chat.Messages
	sndLib.PlaySoundClient("global", "chatnotification", "rbxassetid://821076180", 0.4, 1, false, 2)
	f.Time.Value = ClientTime
end

function UpdateChat(dt)
	local newchatlog = {}

	pcall(function()
		newchatlog = events.GetServerChat:InvokeServer()
	end)
	
	if #newchatlog > #chatlog then
		--print("new messages found")
		local numNewMessages = #newchatlog - #chatlog
		--print(numNewMessages.." new messages")
		if numNewMessages > 0 then
			for i = #newchatlog, 1, -1 do
				if i <= #newchatlog - numNewMessages then
					break
				end
				--print("working on message #"..i)
				local msg = newchatlog[i]

				if msg.GameInfo == true then
					CreateChatMessage(msg.Sender, msg.Body, 0.7 - (0.1 * #newchatlog), true)
				else
					--print("creating the message")
					CreateChatMessage(msg.Sender, msg.Body, 0.7 - (0.1 * #newchatlog), false)
				end
			end
			--print("done fetching")
			chatlog = newchatlog
			--local msg = newchatlog[#newchatlog]
			--CreateChatMessage(msg.Sender, msg.Body, 0.7 - (0.1 * #newchatlog))
			--chatlog = newchatlog
		end
	end
	
	for _, msg in pairs(player.PlayerGui.HUD.Chat.Messages:GetChildren()) do
		if msg.Name == "ChatMessage" or msg.Name == "SystemChatMessage" then
			if math.abs(ClientTime - msg.Time.Value) > chatMessageDisplayTime and chatVisible then
				msg.Body.TextTransparency = 0
				msg.Sender.TextTransparency = 0
			elseif math.abs(ClientTime - msg.Time.Value) > chatMessageDisplayTime and not chatVisible then
				msg.Body.TextTransparency = 1
				msg.Sender.TextTransparency = 1
			else
				msg.Body.TextTransparency = 0
				msg.Sender.TextTransparency = 0
			end
		end
	end
end

function UpdateCamera(dt)
	if char.PrimaryPart ~= nil then
		local xRot = CFrame.Angles(-mouseAngles.Y, 0, 0)
		local yRot = CFrame.Angles(0, -mouseAngles.X, 0)
		local pos = char.PrimaryPart.Position + Vector3.new(0, 2, 0)
		cam.CFrame = CFrame.new(pos) * yRot * xRot
	end
end


function UpdateRender(dt)
	local actualMouseRay = Ray.new(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 999)
	local hit, pos, norm = workspace:FindPartOnRayWithWhitelist(actualMouseRay, {})
	actualMouseHit = pos

	local hitwall = false
	for _, p in pairs(char:GetChildren()) do
		if p:IsA("BasePart") then
			p.Transparency = 1
		end
	end
	
	if RAYMDL ~= nil then
		RAYMDL:Destroy()
	end
	--RAYMDL = DrawLineDebug(char:GetPrimaryPartCFrame().p, char:GetPrimaryPartCFrame().p + char:GetPrimaryPartCFrame().lookVector * 5)
	
	local grounded = Grounded()
	accelDir = Vector3.new()
	
	if PlayerStats.Health > 0 and not player.PlayerGui.HUD.Chat.InputFrame.Visible then
		if movementKeysDown.W then
			accelDir = accelDir + CFrame.Angles(0, math.rad(0), 0) * (cam.CFrame.lookVector * Vector3.new(1,0,1)).unit
		end
		if movementKeysDown.S then
			accelDir = accelDir + CFrame.Angles(0, math.rad(-180), 0) * (cam.CFrame.lookVector * Vector3.new(1,0,1)).unit
		end
		if movementKeysDown.A then
			accelDir = accelDir + CFrame.Angles(0, math.rad(90), 0) * (cam.CFrame.lookVector * Vector3.new(1,0,1)).unit
		end
		if movementKeysDown.D then
			accelDir = accelDir + CFrame.Angles(0, math.rad(-90), 0) * (cam.CFrame.lookVector * Vector3.new(1,0,1)).unit
		end
	end

	if grounded and not jumping then
		player.PlayerGui.HUD.SpeedTypeLabel.Text = "MoveGround"
		playerVelocity = MoveGround(accelDir, playerVelocity, dt, grounded) + VelOffset + pushVector
	else
		if jumpedOnPrevFrame then
			jumpedOnPrevFrame = false
		end
		player.PlayerGui.HUD.SpeedTypeLabel.Text = "MoveAir"
		playerVelocity = MoveAir(accelDir, playerVelocity, dt, grounded)
		playerVelocity = playerVelocity + (Vector3.new(0, -workspace.Gravity / 2, 0) * dt) + pushVector
	end

	if movementKeysDown.Space and not jumping and PlayerStats.Health > 0 and grounded and not player.PlayerGui.HUD.Chat.InputFrame.Visible then
		jumpedOnPrevFrame = true
		jumping = true
		sndLib.PlaySoundClient("global", "jump", "rbxassetid://821077345", 0.3, 1, false, 1)
		spawn(function()
			while not Grounded() do
				wait()
			end
			wait()
			jumping = false
		end)
		playerVelocity = playerVelocity + Vector3.new(0, 32.5, 0)
	end
	
	player.PlayerGui.HUD.SpeedLabel.Text = math.abs(math.floor(playerVelocity.magnitude))
	
	prevVelocity = playerVelocity
	--print(playerVelocity)
	
	local function raycast(orig, dir)
		return workspace:FindPartOnRayWithIgnoreList(Ray.new(orig, dir), {char, workspace.Ignore, workspace.PlayerSpawns, workspace.ItemPickups, workspace.ItemSpawns, workspace.Nodes})
	end
	
	-- Radius of player's hitbox:
	local playerRadius = 2.95
	
	-- STEP 1: cast forward into movement direction to find initial collision with wall:
	-- (i.e. so you dont teleport the player into wall to begin with)
	
	local origin = char:GetPrimaryPartCFrame().p				-- player's current position
	local movement = playerVelocity * dt						-- player's movement vector
	local movement_xz_unit = (playerVelocity * Vector3.new(1,0,1)).unit
	local hitboxadjust = movement_xz_unit * playerRadius -- offset to be applied to take into account hitbox as well

	-- Check for hit within movement vector:
	local hit, hitpos = raycast(origin, movement)
	if hit then
		-- Hit found, so move to the wall position and move back from wall by hitboxadjust:
		hitwall = true
		origin = hitpos - hitboxadjust
	else
		-- No hit, simply move to the position:
		origin = origin + movement
	end
	
	-- STEP 2: cast in a fan to check for collisions:
	-- (i.e. making sure a player is approximately playerRadius away from any objects in any direction)
	
	-- Precalculate direction vectors for angle-pairs:
	local directionVector = {}
	for i = -180, -0.1, 22.5 do
		directionVector[i] = CFrame.Angles(0,math.rad(i),0) * hitboxadjust
	end
	
	-- Which angle-pairs have been done:
	local done = {}
	
	-- Do 8 rounds of correction (one for each angle-pair):
	for _ = 1,8 do
		
		-- Running variables:
		local m = .001	-- Magnitude of maximum displacement
		local n = nil	-- Maximum displacement
		local o = nil	-- Angle of maximum displacement
		
		-- Loop over all angle-pairs:
		for i = -180, -0.1, 22.5 do
			
			-- If we have corrected at this angle-pair already then we won't correct again this frame:
			if not done[i] then
				
				-- Raycast positive/negative angle (these rays are opposite):
				local hit1, pos1 = raycast(origin, directionVector[i])
				local hit2, pos2 = raycast(origin, -directionVector[i])
				
				-- Determine offset in this angle-pair:
				local off = Vector3.new(0,0,0)
				if hit1 then
					-- For negative angle:
					hitwall = true
					off = (directionVector[i] - (pos1 - origin))
				end
				if hit2 then
					-- For positive angle:
					hitwall = true
					off = off + (-directionVector[i] - (pos2 - origin))
				end
				
				-- Check if displacement is greater than the tracked displacement:
				if off.magnitude > m then
					-- It's bigger, so update running variables:
					m = off.magnitude
					n = off
					o = i
				end
			end
		end
		
		-- Check if a maximum displacement was found:
		if o then
			-- Apply the displacement for angle-pair 'o':
			origin = origin - n
			-- This angle-pair is now done:
			done[o] = true
		else
			-- No displacement in any direction, so just stop:
			break
		end
	end
	
	char:SetPrimaryPartCFrame(CFrame.new(origin) * CFrame.Angles(0, -mouseAngles.X, 0))
	
	if hitwall and not grounded then
		--playerVelocity = Vector3.new(0, playerVelocity.Y, 0)
	end
	
	if char.PrimaryPart.Position.Y < -900 and not falldeath then
		TakeDamage(9000, player)
		falldeath = true
		playerVelocity = Vector3.new()
		spawn(function()
			wait(4)
			falldeath = false
		end)
	elseif char.PrimaryPart.Position.Y < -900 and falldeath then
		playerVelocity = Vector3.new()
	end
	
	pushVector = Vector3.new()
	
	clouds.CFrame = CFrame.new(char.Torso.Position.X, 67, char.Torso.Position.Z) * CFrame.Angles(math.rad(180), 0, 0)

	for _, tex in pairs(clouds.SurfaceGui:GetChildren()) do
		tex.Position = tex.Position + UDim2.new(0.05 * dt, 0, 0, 0)
		if tex.Position.X.Scale > 2 then
			tex.Position = UDim2.new(-2, 0, 0, 0)
		end
	end
	
	if equippedWeapon then
		if UseWeaponViewmodel then
			equippedWeapon:SetPrimaryPartCFrame(
				CFrame.new(cam.CFrame.p, mouse.Hit.p) 
				* CFrame.new(weaponCode.ViewModel.Offset.X, weaponCode.ViewModel.Offset.Y, weaponCode.ViewModel.Offset.Z) 
				* CFrame.Angles(math.rad(weaponCode.ViewModel.Angle.X), math.rad(weaponCode.ViewModel.Angle.Y), math.rad(weaponCode.ViewModel.Angle.Z))
			)
		else
			equippedWeapon:SetPrimaryPartCFrame(
				CFrame.new(cam.CFrame.p, mouse.Hit.p) 
				* CFrame.new(script.Offset.Value.X, script.Offset.Value.Y, script.Offset.Value.Z) 
				* CFrame.Angles(math.rad(script.Angle.Value.X), math.rad(script.Angle.Value.Y), math.rad(script.Angle.Value.Z))
			)
		end
	end
	
	if barrierUp and not workspace.Ignore:FindFirstChild("Barrier") then
		local barrier = game.ReplicatedStorage.Particles.Barrier:Clone()
		barrier.Parent = workspace.Ignore
	elseif not barrierUp then
		local barrier = workspace.Ignore:FindFirstChild("Barrier")
		if barrier then
			barrier:Destroy()
		end
	end
	
	local barrier = workspace.Ignore:FindFirstChild("Barrier")
	if barrier then
		--barrier:SetPrimaryPartCFrame(equippedWeapon:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(script.Angle.Value.X), math.rad(script.Angle.Value.Y), math.rad(script.Angle.Value.Z)))
		barrier:SetPrimaryPartCFrame(CFrame.new(char:GetPrimaryPartCFrame().p, actualMouseHit))
	end
end


local falldeath = false

function TakeDamage(damage, damageGiver)
	if not falldeath then
		local dmg = damage
		if PlayerStats.Armor > 0 then
			local armourCanAbsorb = math.min(math.floor(dmg*(2/3)), PlayerStats.Armor)
			dmg = dmg - armourCanAbsorb
			PlayerStats.Armor = math.clamp(PlayerStats.Armor - armourCanAbsorb, 0, 9000)
		end
		PlayerStats.Health = math.clamp(PlayerStats.Health - dmg, 0, 9000)
		
		--spawn blood on screen
		local blood = Instance.new("ImageLabel")
		blood.BackgroundTransparency = 1
		blood.Size = UDim2.new(0.259, 0, 0.5, 0)
		blood.Position = UDim2.new(math.random(), 0, math.random(), 0)
		blood.Image = "rbxassetid://313082863"
		blood.Rotation = math.random() * 360
		blood.Parent = player.PlayerGui.HUD.HurtFrame
		spawn(function()
			wait(3)
			local t = 0
			while t <= 2 do
				local dt = game:GetService("RunService").RenderStepped:wait()
				t = t + dt
				blood.ImageTransparency = blood.ImageTransparency + (dt * 2)
			end
			blood:Destroy()
		end)
	
		--hurt sounds
		if PlayerStats.Health <= 0 then
			--death sound
			sndLib.PlaySoundClient("global", "die", Orakel.TRand(assetLib.HurtSounds.DieHuman), 0.4, 1, false, 2)
			lastHurtSound = tick() + 20
			player.PlayerGui.HUD.Scoreboard.Visible = true
			player.PlayerGui.HUD.Scoreboard.Fraggedby.Text = "Fragged by "..damageGiver.Name
			player.PlayerGui.HUD.Scoreboard.Fraggedby.Visible = true
		elseif PlayerStats.Health > 0 and math.abs(tick() - lastHurtSound) > 1 then
			--hurt sound
			sndLib.PlaySoundClient("global", "hurt", Orakel.TRand(assetLib.HurtSounds.HurtHuman), 0.4, 1, false, 2)
			lastHurtSound = tick()
		end
	end
end

local jumping = false
function UpdateHeartbeat(dt)
	ClientTime = ClientTime + dt

	spawn(function()
		UpdatePlayermodels(dt)
	end)
	
	for _, plr in pairs(game.Players:GetPlayers()) do
		local mdl = workspace.Characters:FindFirstChild(plr.Name)
		if mdl then
			local hrp = mdl:FindFirstChild("HumanoidRootPart")
			if hrp then
				if hrp.Position.Y <= -30 then
					print("HRP FALLIN OUT OF MAP")
				end
			end
		end
	end

	
	--Update ui health labels and health bars
	player.PlayerGui.HUD.VitalsFrame.Health.TextLabel.Text = math.ceil(PlayerStats.Health).."/"..PlayerStats.MaxHealth
	player.PlayerGui.HUD.VitalsFrame.Health.Bar.Filler.Size = UDim2.new(PlayerStats.Health / PlayerStats.MaxHealth, 0, 1, 0)
	player.PlayerGui.HUD.VitalsFrame.Armor.TextLabel.Text = math.ceil(PlayerStats.Armor).."/"..PlayerStats.MaxArmor
	player.PlayerGui.HUD.VitalsFrame.Armor.Bar.Filler.Size = UDim2.new(PlayerStats.Armor / PlayerStats.MaxArmor, 0, 1, 0)
	
	--adjust ui health bar colours
	if PlayerStats.Health > PlayerStats.MaxHealth then
		player.PlayerGui.HUD.VitalsFrame.Health.Bar.Filler.BackgroundColor3 = Color3.new(0, 243/255, 1)
	else
		player.PlayerGui.HUD.VitalsFrame.Health.Bar.Filler.BackgroundColor3 = Color3.new(0, 1, 93/255)
	end
	if PlayerStats.Armor > PlayerStats.MaxArmor then
		player.PlayerGui.HUD.VitalsFrame.Armor.Bar.Filler.BackgroundColor3 = Color3.new(0, 243/255, 1)
	else
		player.PlayerGui.HUD.VitalsFrame.Armor.Bar.Filler.BackgroundColor3 = Color3.new(0, 1, 93/255)
	end
	
	--Update ammo values and weapon icons on UI
	for _, frame in pairs(player.PlayerGui.HUD.WeaponsFrame:GetChildren()) do
		frame.Ammo.Text = tostring(PlayerStats.Weapons[frame.Name].Ammo)
	end
	player.PlayerGui.HUD.AmmoFrame.ImageLabel.Image = player.PlayerGui.HUD.WeaponsFrame[equippedWeapon.Name].Icon.Image
	player.PlayerGui.HUD.AmmoFrame.TextLabel.Text = tostring(PlayerStats.Weapons[equippedWeapon.Name].Ammo)
	
	--Lose health and armor constantly if n > 100
	if PlayerStats.Health > PlayerStats.MaxHealth then
		PlayerStats.Health = PlayerStats.Health - 0.6 * dt
	end
	if PlayerStats.Armor > PlayerStats.MaxArmor then
		PlayerStats.Armor = PlayerStats.Armor - 0.6 * dt
	end
	--Die in roblox
	if PlayerStats.Health <= 0 and not respawning then
		respawning = true
		spawn(function()
			char.Humanoid.WalkSpeed = 0
			canfire = false
			wait(4)
			playerVelocity = Vector3.new()
			SwitchWeapon(equippedWeapon, 1, 1, false)
			canfire = true
			char.Humanoid.WalkSpeed = 32
			player.PlayerGui.HUD.Scoreboard.Visible = false
			player.PlayerGui.HUD.Scoreboard.Fraggedby.Visible = false
			--char.Humanoid.Health = 0
			PlayerStats.Health = 100
			PlayerStats.Armor = 15
			PlayerStats.Weapons.Machinegun.Ammo = 100
			local spawns = workspace.PlayerSpawns:GetChildren()
			local cspawn = spawns[math.random(1, #spawns)]
			char:SetPrimaryPartCFrame(cspawn.CFrame)
			respawning = false
		end)
	end
	
	--Fire weapon, TODO: implement single-fire instead of always-auto?
	if m1down and PlayerStats.Weapons[equippedWeapon.Name].Ammo > 0 then
		local ps = weaponCode.RateOfFire / 60
		local rof = 1 / ps
		
		if tick() - lastShotFired >= rof and canfire then
			game.ReplicatedStorage.WeaponFiredClient:Fire()
			PlayerStats.Weapons[equippedWeapon.Name].Ammo = PlayerStats.Weapons[equippedWeapon.Name].Ammo - 1
			weaponCode.Fire(player, equippedWeapon, cam.CFrame.p, mouse.Hit.p, char)
			events.FireWeaponServer:FireServer(player, equippedWeapon.Name, cam.CFrame.p, mouse.Hit.p)

			if weaponCode.Fired ~= nil then
				if not weaponCode.Fired then
					weaponCode.FireOnce(player)
					weaponCode.Fired = true
				end
			end
			lastShotFired = tick()
		end
		weaponCode.Update(dt, equippedWeapon, true)
	else
		weaponCode.Update(dt, equippedWeapon, false) --only necessary for the machinegun's barrel spin
		if weaponCode.StopFire ~= nil then
			weaponCode.StopFire()
		end
	end

	for _, item in pairs(pickups) do
		if item.ClassName == "Model" then
			item:SetPrimaryPartCFrame(item:GetPrimaryPartCFrame() * CFrame.new(0, 0, itemFloatHeight * math.sin(tick() % 10000)) * CFrame.Angles(0, 0, math.rad(180 * dt)))
		else
			--item.CFrame = item.CFrame * CFrame.Angles(0, 0, math.rad(180 * dt))
			
			item.CFrame = item.CFrame * CFrame.new(0, 0, itemFloatHeight * math.sin(tick() % 10000)) * CFrame.Angles(0, 0, math.rad(180 * dt))
			
			--local ypos = itemFloatHeight * math.sin(tick() % 10000)
		end
	end

	local arms = char:FindFirstChild("ArmsViewmodel")

	if charInvisible then
		Orakel.RecursiveSearch(char.Head, function(obj) return (obj.ClassName == "Decal") end, function(obj) obj.Transparency = 1 end)
		Orakel.ToggleVisible(char, 1, false)
		Orakel.ToggleVisible(arms, 1, false, {"Part"})
		if not equippedWeapon.Name == "Machinegun" then
			Orakel.ToggleVisible(equippedWeapon, 1, false, {"Muzzle", "Barrel"})
		else
			Orakel.ToggleVisible(equippedWeapon, 1, false, {"Muzzle"})
		end
	else
		Orakel.RecursiveSearch(char.Head, function(obj) return (obj.ClassName == "Decal") end, function(obj) obj.Transparency = 0 end)
		Orakel.ToggleVisible(char, 0, false)
		Orakel.ToggleVisible(arms, 0, false, {"Part"})
		Orakel.ToggleVisible(equippedWeapon, 0, false, {"Muzzle", "Barrel"})
	end
	
	
	player.PlayerGui.HUD.ScoreFrame.RoundTimer.Text = mathLib.SecondsToTimerFormat(game.ReplicatedStorage.GetServerRoundTime:InvokeServer())
end

function InputBegan(io)
	if io.UserInputType == Enum.UserInputType.MouseButton1 then
		m1down = true
	--elseif io.UserInputType == Enum.UserInputType.MouseWheel then
		--print("mwheel")
		--SwitchWeapon(equippedWeapon, io.Position.Z)
	elseif io.UserInputType == Enum.UserInputType.MouseButton2 then
		cam.FieldOfView = 20
	elseif io.UserInputType == Enum.UserInputType.Keyboard then
		for key,_ in pairs(movementKeysDown) do
			if key == io.KeyCode.Name then
				movementKeysDown[key] = true
			end
		end

		if io.KeyCode == Enum.KeyCode.T and not chatVisible then
			ToggleChatWindow()
		end
		
		if io.KeyCode == Enum.KeyCode.F and PlayerStats.Health > 0 then
			UseAbility()
		end
		
		if io.KeyCode == Enum.KeyCode.Return and chatVisible then
			SendCurrentBody()
			ToggleChatWindow()
		end
		
		if io.KeyCode == Enum.KeyCode.Tab and PlayerStats.Health > 0 then
			ToggleScoreboard()
		end
	elseif io.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = math.rad(1) * io.Delta * SENSITIVITY
		local clampedY = math.clamp(mouseAngles.Y + delta.Y, MOUSE_MIN, MOUSE_MAX)

		mouseAngles = Vector2.new(mouseAngles.X + delta.X, clampedY)
	end
end

function InputChanged(io)
	if io.UserInputType == Enum.UserInputType.MouseWheel then
		SwitchWeapon(equippedWeapon, io.Position.Z)
	end
	
	if io.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = math.rad(1) * io.Delta * SENSITIVITY
		local clampedY = math.clamp(mouseAngles.Y + delta.Y, MOUSE_MIN, MOUSE_MAX)

		mouseAngles = Vector2.new(mouseAngles.X + delta.X, clampedY)
	end
end

function InputEnded(io)
	if io.UserInputType == Enum.UserInputType.MouseButton1 then
		m1down = false
	elseif io.UserInputType == Enum.UserInputType.MouseButton2 then
		cam.FieldOfView = 70
	elseif io.UserInputType == Enum.UserInputType.Keyboard then
		for key,_ in pairs(movementKeysDown) do
			if key == io.KeyCode.Name then
				movementKeysDown[key] = false
			end
		end
		
		if io.KeyCode == Enum.KeyCode.Tab and PlayerStats.Health > 0 then
			ToggleScoreboard()
		end	
	elseif io.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = math.rad(1) * io.Delta * SENSITIVITY
		local clampedY = math.clamp(mouseAngles.Y + delta.Y, MOUSE_MIN, MOUSE_MAX)

		mouseAngles = Vector2.new(mouseAngles.X + delta.X, clampedY)
	end
end

function Init()
	wait(.5)
	mouse.TargetFilter = workspace.Ignore
	cam.CameraType = Enum.CameraType.Scriptable
	game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
	wait()
	for _, wmodule in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
		weaponData[wmodule.Name] = require(wmodule)
	end
	
	local dir = workspace:FindFirstChild("Characters") or Instance.new("Model", workspace)
	if dir.Name ~= "Characters" then dir.Name = "Characters" end
	dir.ChildAdded:connect(function(c)
		c.ChildRemoved:connect(function(c)
			print(tostring(c))
		end)
	end)
	
	
	local mychar = CreatePlayerModel(player)
	char = mychar
	PlayerModels[player.Name] = mychar
	wait()
	
	player.PlayerGui:WaitForChild("Music"):Play()
	clouds = game.ReplicatedStorage.Clouds:Clone()
	clouds.CFrame = CFrame.new(char.Torso.Position.X, 67, char.Torso.Position.Z)
	clouds.Parent = workspace.Ignore
	
	local mg = game.ReplicatedStorage.Models.Machinegun:Clone()
	mg.Parent = char
	equippedWeapon = mg
	weaponCode = require(game.ReplicatedStorage.Weapons[equippedWeapon.Name])
	weaponCode.Equip()
	--[[
	local la = mg:FindFirstChild("Left Arm")
	local ra = mg:FindFirstChild("Right Arm")
	if la and ra then
		la.Transparency = 1
		ra.Transparency = 1
	end]]
	
	game:GetService("RunService").Heartbeat:connect(UpdateHeartbeat)
	game:GetService("RunService").RenderStepped:connect(UpdateRender)
	game:GetService("RunService").RenderStepped:connect(UpdateCamera)
	game:GetService("UserInputService").InputBegan:connect(InputBegan)
	game:GetService("UserInputService").InputEnded:connect(InputEnded)
	game:GetService("UserInputService").InputChanged:connect(InputChanged)
	game.ReplicatedStorage.PlaySoundClient.OnClientEvent:connect(sndLib.PlaySoundClient)
	game.ReplicatedStorage.TakeDamage.OnClientEvent:connect(TakeDamage)
	
	game.ReplicatedStorage.GiveAmmo.OnClientEvent:connect(function(wname, amt)
		--print("taking "..amt.." ammo for "..wname)
		PlayerStats.Weapons[wname].Ammo = math.clamp(PlayerStats.Weapons[wname].Ammo + amt, 0, PlayerStats.Weapons[wname].MaxAmmo)
	end)
	
	game.ReplicatedStorage.GiveHealth.OnClientEvent:connect(function(amt)
		--print("taking "..amt.." health")
		if amt >= 100 then
			PlayerStats.Health = math.clamp(PlayerStats.Health + amt, 0, 200)
		else
			if PlayerStats.Health + amt < 100 then
				PlayerStats.Health = math.clamp(PlayerStats.Health + amt, 0, PlayerStats.MaxHealth)
			else
				PlayerStats.Health = math.clamp(PlayerStats.Health + amt, 0, 200)
			end
		end
	end)
	
	game.ReplicatedStorage.GiveArmor.OnClientEvent:connect(function(amt)
		--print("taking "..amt.." armor")
		if amt >= 100 then
			PlayerStats.Armor = math.clamp(PlayerStats.Armor + amt, 0, 200)
		else
			if PlayerStats.Armor + amt < 100 then
				PlayerStats.Armor = math.clamp(PlayerStats.Armor + amt, 0, PlayerStats.MaxArmor)
			else
				PlayerStats.Armor = math.clamp(PlayerStats.Armor + amt, 0, 200)
			end
		end
	end)
	
	game.ReplicatedStorage.GiveTime.OnClientEvent:connect(function(amt)
		CooldownReduction = CooldownReduction + amt
	end)
	
	game.ReplicatedStorage.PlayerRemoving.OnClientEvent:connect(function(plrname)
		print(plrname.. "left the game")
		PlayerModels[plrname]:Destroy()
		for _, frame in pairs(player.PlayerGui.HUD.Scoreboard.Main.PlayerList:GetChildren()) do
			if frame.Name == plrname then
				frame:Destroy()
			end
		end
	end)
	
	game.ReplicatedStorage.PlayerAdded.OnClientEvent:connect(function(plr)
		if plr ~= nil then
			if plr.Name ~= player.Name then
				PlayerModels[plr.Name] = CreatePlayerModel(plr)
			end
		end
	end)
	
	game.ReplicatedStorage.SetPlayerLocation.OnClientEvent:connect(function(cframe)
		local cf = CFrame.new(cframe.p + Vector3.new(0, 3.5, 0))
		playerVelocity = Vector3.new()
		char:SetPrimaryPartCFrame(cf)
		playerVelocity = Vector3.new()
	end)
	
	game.ReplicatedStorage.CreateKillfeedEntry.OnClientEvent:connect(function(killer, weapon, victim)
		print(killer.." killed "..victim.." with "..weapon)
		local kf = game.ReplicatedStorage.Killframe:Clone()
		kf.Icon.Image = player.PlayerGui.HUD.WeaponsFrame[weapon].Icon.Image
		kf.Killer.Text = killer
		kf.Victim.Text = victim
		local existingEntries = player.PlayerGui.HUD.Killfeed:GetChildren()
		kf.Position = kf.Position + UDim2.new(0, 0, 0.15 * #existingEntries, 0)
		spawn(function()
			wait(3.5)
			local t = 0
			while t <= 1 do
				local dt = game:GetService("RunService").RenderStepped:wait()
				t = t + dt
				kf.Killer.TextTransparency = kf.Killer.TextTransparency + dt
				kf.Victim.TextTransparency = kf.Victim.TextTransparency + dt
				kf.Icon.ImageTransparency = kf.Icon.ImageTransparency + dt
				kf.Icon.BackgroundTransparency = kf.Icon.BackgroundTransparency + dt
			end
			kf:Destroy()
		end)
		kf.Parent = player.PlayerGui.HUD.Killfeed
	end)
	
	game.ReplicatedStorage.AwardFrag.OnClientEvent:connect(function(killedplayer)
		--print("awarded frag of "..killedplayer)
		player.PlayerGui.HUD.FragLabel.Text = "You Fragged "..killedplayer
		player.PlayerGui.HUD.FragLabel.Visible = true
		wait(3)
		player.PlayerGui.HUD.FragLabel.Visible = false
	end)
	
	game.ReplicatedStorage.FireWeaponClient.OnClientEvent:connect(function(shooter, wname, campos, mpos, runserverfire)
		local w = weaponData[wname]
		local pm = workspace.Characters:FindFirstChild(shooter.Name)
		local wm = pm:FindFirstChild(wname)
		if w and pm and wm then
			if w.ShootEffect ~= nil and shooter.Name ~= player.Name then
				w.ShootEffect(wm, mpos)
			end
			if w.FireServer ~= nil then
				w.FireServer(shooter, wm, campos, mpos, player)
			end
		end
	end)
	
	game.ReplicatedStorage.FireAbilityClient.OnClientEvent:connect(function(shooter, wname, campos, mpos, ability)
		local ab = require(game.ReplicatedStorage.Abilities[ability])
		ab.FireServer(shooter, wname, campos, mpos, player)
	end)
	
	game.ReplicatedStorage.Push.OnClientEvent:connect(function(pushorigin, pushforce)
		pushVector = (char.PrimaryPart.Position - pushorigin).unit * pushforce
	end)
	
	game.ReplicatedStorage.ToggleInvisibilityClient.Event:connect(function(enabled)
		charInvisible = enabled
	end)
	
	game.ReplicatedStorage.ToggleBarrierClient.Event:connect(function(enabled)
		barrierUp = enabled
	end)
end

function events.GetCurrentWeapon.OnClientInvoke(player, playerToGetFrom)
	if equippedWeapon ~= nil then
		return equippedWeapon.Name
	end
	return "Machinegun"
end

function events.GetPlayerHealth.OnClientInvoke()
	return PlayerStats.Health
end

function events.GetMouseHit.OnClientInvoke(player, playerToGetFrom)
	return mouse.Hit.p
end

function events.GetClientPing.OnClientInvoke()
	return latency
end

function events.GetPlayerLocation.OnClientInvoke()
	return char.Torso.Position, actualMouseHit, CFrame.Angles(0, -mouseAngles.X, 0)
end

function events.GetPlayerGhosting.OnClientInvoke()
	return charInvisible
end

function events.GetPlayerBarrier.OnClientInvoke()
	return barrierUp
end

Init()

spawn(function()
	while true do
		local dt = wait(1/2)
		local now = ClientTime
		ConVars = events.GetSCVars:InvokeServer()
		latency = math.abs(mathLib.Round((now - ClientTime) * 1000, 0))
		plabel.Text = "Ping: "..latency.."ms"
		if latency >= 110 then
			plabel.TextColor3 = Color3.new(1, 0, 0)
		else
			plabel.TextColor3 = Color3.new(1, 1, 1)
		end
		
		UpdateChat(dt)
	end
end)

while true do
	local dt = wait(1/6)
	--ClientTime = ClientTime + dt
	--UpdateChat(dt)
	UpdateScoreboard(dt)
	UpdateJumpPadLogic(dt)
end