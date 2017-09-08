local Machinegun = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")

Machinegun.ViewModel = {
	Offset = Vector3.new(1.25, -1.25, -0.25);
	Angle = Vector3.new(0, -90, 0);
	ShotSway = Vector3.new();
}

Machinegun.ViewModel_3rdPerson = {
	Offset = Vector3.new(0.4, 0.7, 0);
}

Machinegun.Name = "Machinegun"
Machinegun.Damage = 6
Machinegun.RateOfFire = 600
Machinegun.Spread = 0.5

Machinegun.FireSound = "http://www.roblox.com/asset/?id=81116839"
Machinegun.HitSound = ""
Machinegun.MissSound = {"http://www.roblox.com/asset/?id=81116827", "http://www.roblox.com/asset/?id=81116877", "http://www.roblox.com/asset/?id=81116886", "http://www.roblox.com/asset/?id=81116898"}
Machinegun.EquipLoop = ""

local MaxBarrelSpinRate = 720
local SpinRateDecay = 360
local CurrentBarrelSpinRate = 0

function Machinegun.Equip()
	
end

function Machinegun.UnEquip()
	
end

function Machinegun.TryDamageTarget(...)
	sndLib.PlaySoundClient("global", "hitsound", "rbxassetid://821077013", 0.2, 1, false, 1)
	game.ReplicatedStorage.TryDamage:FireServer(...)
end


function Machinegun.Update(dt, model, isFiring)
	if isFiring then
		CurrentBarrelSpinRate = MaxBarrelSpinRate
	else
		CurrentBarrelSpinRate = mathLib.Clamp(CurrentBarrelSpinRate - (SpinRateDecay * dt), 0, MaxBarrelSpinRate)
	end
	
	model.Barrel.CFrame = model.Barrel.CFrame * CFrame.Angles(math.rad(CurrentBarrelSpinRate * dt), 0, 0)
end


function Machinegun.HitEffect(hit, pos, norm, mat)
	sndLib.PlaySoundClient("3d", "mg_hit", Machinegun.MissSound[math.random(1, #Machinegun.MissSound)], 0.2, 1, false, 1, pos)
	sndLib.PlaySoundOtherClients("3d", "mg_hit", Machinegun.MissSound[math.random(1, #Machinegun.MissSound)], 0.2, 1, false, 1, pos)
	
	local dh = npcLib.CreateDecal(CFrame.new(pos, pos + norm), Vector3.new(0.5 ,0.5, 0.2), "http://www.roblox.com/asset/?id=22915150", "Front", false, 8)
	local pe = game.ReplicatedStorage.Particles.BulletSparkEmitter:Clone()
	pe.Parent = dh
	spawn(function()
		pe:Emit(10)
	end)
end

function Machinegun.ShootEffect(model)
	spawn(function()
		model.Muzzle.Flash:Emit(1)
		model.Muzzle.Smoke:Emit(25)
		model.Handle.ShellEmitter:Emit(1)
	end)
end

function GetSpread()
	return math.rad(mathLib.RandomFloat(-Machinegun.Spread, Machinegun.Spread))
end


function Machinegun.Fire(shooter, model, campos, tgtpos, char)
	game.ReplicatedStorage.ReplicateShootEffect:FireServer(model, tgtpos)
	spawn(function()
		model.Muzzle.Flash:Emit(1)
		model.Muzzle.Smoke:Emit(25)
		model.Handle.ShellEmitter:Emit(1)
	end)
	
	sndLib.PlaySoundClient("global", "mg_fire", Machinegun.FireSound, 0.3, 1, false, 1)
	sndLib.PlaySoundOtherClients("3d", "mg_fire", Machinegun.FireSound, 0.3, 1, false, shooter.Name)
	
	local mainray = Ray.new(campos, (tgtpos - campos).unit * 999)
	local ray = Ray.new(mainray.Origin, CFrame.Angles(GetSpread(), GetSpread(), GetSpread()) * mainray.Direction)
	local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, {shooter.Character, model, workspace.Ignore, char, workspace.ItemSpawns, workspace.ItemPickups, workspace.Clip})
	if hit then
		if hit.Parent:FindFirstChild("Humanoid") then
			Machinegun.TryDamageTarget(Machinegun.Name, shooter, campos, tgtpos, hit.Parent.Name, ray)
		else
			if hit.Parent.Name == "Barrier" then
				Orakel.BarrierHitFX(hit, pos, norm, mat)
			elseif hit:IsA("BasePart") and hit.CanCollide and hit.Name ~= "Clip" then
				game.ReplicatedStorage.ReplicateHitEffect:FireServer("Machinegun", hit, pos, norm, mat)
				Machinegun.HitEffect(hit, pos, norm, mat)
			end
		end
	end
end




return Machinegun
