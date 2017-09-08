local Railgun = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")
local snd

Railgun.ViewModel = {
	Offset = Vector3.new(1.25, -1.25, 0);
	Angle = Vector3.new(-90, 180, -90);
}
Railgun.ViewModel_3rdPerson = {
	Offset = Vector3.new(0.6, 0.35, -1.5);
}

Railgun.Name = "Railgun"
Railgun.Damage = 100
Railgun.RateOfFire = 45

Railgun.FireSound = "http://www.roblox.com/asset?id=81116761"
Railgun.HitSound = ""
Railgun.MissSound = ""
Railgun.EquipLoop = "rbxassetid://821078224"



function Railgun.TryDamageTarget(...)
	sndLib.PlaySoundClient("global", "hitsound", "rbxassetid://821077013", 0.2, 1, false, 1)
	game.ReplicatedStorage.TryDamage:FireServer(...)
end

function Railgun.Equip()
	snd = sndLib.PlaySoundClient("global", "hum", "rbxassetid://821078224", 0.2, 1, true, -1)
end

function Railgun.UnEquip()
	snd:Stop()
	snd:Destroy()
end

function Railgun.Update(dt, model, isFiring)

end


function Railgun.HitEffect(hit, pos, norm, mat)
	--sndLib.PlaySoundClient("3d", "mg_hit", Railgun.MissSound, 0.2, 1, false, 1, pos)
	--sndLib.PlaySoundOtherClients("3d", "mg_hit", Railgun.MissSound, 0.2, 1, false, 1, pos)
	
	local dh = npcLib.CreateDecal(CFrame.new(pos, pos + norm), Vector3.new(0.5 ,0.5, 0.2), "http://www.roblox.com/asset/?id=22915150", "Front", false, 8)
	local pe = game.ReplicatedStorage.Particles.BulletSparkEmitter:Clone()
	pe.Parent = dh
	spawn(function()
		pe:Emit(10)
	end)
end

function Railgun.ShootEffect(model, tgtpos)
	local beam = game.ReplicatedStorage.Particles.Rail:Clone()
	local dist = (tgtpos - model.Handle.Position).magnitude
	beam.Size = Vector3.new(0.1, 0.1, dist)
	beam.CFrame = CFrame.new(model.Handle.Position, tgtpos) * CFrame.new(0, 0, -dist / 2)
	beam.Parent = workspace.Ignore
	spawn(function()
		beam.ParticleEmitter:Emit(100)
		wait(0.1)
		while beam.Transparency < 1 do
			local dt = game:GetService("RunService").Heartbeat:wait()
			beam.Transparency = beam.Transparency + dt
		end
		beam:Destroy()
	end)
end

function Railgun.Fire(shooter, model, campos, tgtpos, char)
	game.ReplicatedStorage.ReplicateShootEffect:FireServer(model, tgtpos)
	--[[spawn(function()
		for _, gui in pairs(model.Muzzle:GetChildren()) do
			gui.Enabled = true
		end
		wait(0.04)
		for _, gui in pairs(model.Muzzle:GetChildren()) do
			gui.Enabled = false
		end
	end)]]
	spawn(function()
		--model.Muzzle.Flash:Emit(1)
		--model.Muzzle.Smoke:Emit(25)
		--model.Handle.ShellEmitter:Emit(1)
	end)
	
	sndLib.PlaySoundClient("global", "rg_fire", Railgun.FireSound, 0.3, 1, false, 1)
	sndLib.PlaySoundOtherClients("3d", "rg_fire", Railgun.FireSound, 0.3, 1, false, shooter.Name)
	
	local ray = Ray.new(campos, (tgtpos - campos).unit * 999)
	local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, {shooter, model, workspace.Ignore, char, workspace.ItemSpawns, workspace.ItemPickups, workspace.Clip})
	
	local beam = game.ReplicatedStorage.Particles.Rail:Clone()
	local dist = (tgtpos - model.Handle.Position).magnitude
	beam.Size = Vector3.new(0.1, 0.1, dist)
	beam.CFrame = CFrame.new(model.Handle.Position, tgtpos) * CFrame.new(0, 0, -dist / 2)
	beam.Parent = workspace.Ignore
	
	spawn(function()
		beam.ParticleEmitter:Emit(100)
		wait(0.1)
		while beam.Transparency < 1 do
			local dt = game:GetService("RunService").RenderStepped:wait()
			beam.Transparency = beam.Transparency + dt
		end
		beam:Destroy()
	end)

	if hit then
		if hit.Parent:FindFirstChild("Humanoid") then
			Railgun.TryDamageTarget(Railgun.Name, shooter, campos, tgtpos, hit.Parent.Name, ray)
		else
			if hit.Parent.Name == "Barrier" then
				Orakel.BarrierHitFX(hit, pos, norm, mat)
			elseif hit:IsA("BasePart") and hit.CanCollide and hit.Name ~= "Clip" then
				Railgun.HitEffect(hit, pos, norm, mat)
				game.ReplicatedStorage.ReplicateHitEffect:FireServer("Railgun", hit, pos, norm, mat)
			end
		end
	end
end




return Railgun
