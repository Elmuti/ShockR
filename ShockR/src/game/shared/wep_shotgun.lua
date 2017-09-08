local Shotgun = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")

Shotgun.ViewModel = {
	Offset = Vector3.new(1.25, -1, 0.4);
	Angle = Vector3.new(-90, 180, -90);
	ShotSway = Vector3.new(0, 0, -0.3);
}
Shotgun.ViewModel_3rdPerson = {
	Offset = Vector3.new(0.4, 0.7, -1);
}


Shotgun.Name = "Shotgun"
Shotgun.Damage = 5
Shotgun.RateOfFire = 60
Shotgun.Spread = 4
Shotgun.ShotsPerShell = 20


Shotgun.FireSound = "http://www.roblox.com/asset/?id=81116710"
Shotgun.HitSound = ""
Shotgun.MissSound = {"http://www.roblox.com/asset/?id=81116827", "http://www.roblox.com/asset/?id=81116877", "http://www.roblox.com/asset/?id=81116886", "http://www.roblox.com/asset/?id=81116898"}
Shotgun.EquipLoop = ""

local MaxBarrelSpinRate = 720
local SpinRateDecay = 360
local CurrentBarrelSpinRate = 0

function Shotgun.Equip()
	
end

function Shotgun.UnEquip()
	
end


function Shotgun.TryDamageTarget(...)
	sndLib.PlaySoundClient("global", "hitsound", "rbxassetid://821077013", 0.2, 1, false, 1)
	game.ReplicatedStorage.TryDamage:FireServer(...)
end


function Shotgun.Update(dt, model, isFiring)

end


function Shotgun.HitEffect(hit, pos, norm, mat)
	sndLib.PlaySoundClient("3d", "mg_hit", Shotgun.MissSound[math.random(1, #Shotgun.MissSound)], 0.2, 1, false, 1, pos)
	sndLib.PlaySoundOtherClients("3d", "mg_hit", Shotgun.MissSound[math.random(1, #Shotgun.MissSound)], 0.2, 1, false, 1, pos)
	
	local dh = npcLib.CreateDecal(CFrame.new(pos, pos + norm), Vector3.new(0.5 ,0.5, 0.2), "http://www.roblox.com/asset/?id=22915150", "Front", false, 8)
	local pe = game.ReplicatedStorage.Particles.BulletSparkEmitter:Clone()
	pe.Parent = dh
	spawn(function()
		pe:Emit(10)
	end)
end


function GetSpread()
	return math.rad(mathLib.RandomFloat(-Shotgun.Spread, Shotgun.Spread))
end

function Shotgun.ShootEffect(model)
	spawn(function()
		model.Muzzle.Flash:Emit(1)
		model.Muzzle.Smoke:Emit(25)
		model.Handle.ShellEmitter:Emit(1)
	end)
end

function Shotgun.Fire(shooter, model, campos, tgtpos, char)
	game.ReplicatedStorage.ReplicateShootEffect:FireServer(model, tgtpos)
	spawn(function()
		model.Muzzle.Flash:Emit(1)
		model.Muzzle.Smoke:Emit(25)
		model.Handle.ShellEmitter:Emit(1)
	end)
	sndLib.PlaySoundClient("global", "mg_fire", Shotgun.FireSound, 0.3, 1, false, 1)
	sndLib.PlaySoundOtherClients("3d", "mg_fire", Shotgun.FireSound, 0.3, 1, false, shooter.Name)
	
	local mainray = Ray.new(campos, (tgtpos - campos).unit * 999)
	for i = 1, Shotgun.ShotsPerShell do
		local ray = Ray.new(mainray.Origin, CFrame.Angles(GetSpread(), GetSpread(), GetSpread()) * mainray.Direction)
		local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, {shooter.Character, model, workspace.Ignore, char, workspace.ItemSpawns, workspace.ItemPickups, workspace.Clip})
		if hit then
			if hit.Parent:FindFirstChild("Humanoid") then
				Shotgun.TryDamageTarget(Shotgun.Name, shooter, campos, tgtpos, hit.Parent.Name, ray)
			else
				if hit.Parent.Name == "Barrier" then
					Orakel.BarrierHitFX(hit, pos, norm, mat)
				elseif hit:IsA("BasePart") and hit.CanCollide and hit.Name ~= "Clip" then
					Shotgun.HitEffect(hit, pos, norm, mat)
					game.ReplicatedStorage.ReplicateHitEffect:FireServer("Shotgun", hit, pos, norm, mat)
				end
			end
		end
	end
end




return Shotgun
