local PlasmaGun = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")

PlasmaGun.ViewModel = {
	Offset = Vector3.new(1.5, -1.2, -2.5);
	Angle = Vector3.new(180, 180, 180);
	ShotSway = Vector3.new(0, 0, -0.25);
}
PlasmaGun.ViewModel_3rdPerson = {
	Offset = Vector3.new(0.6, 1, -2);
}

PlasmaGun.Name = "PlasmaGun"
PlasmaGun.Damage = 20
PlasmaGun.RocketPushForce = 15
PlasmaGun.AreaOfEffect = 6
PlasmaGun.SplashDamage = 14
PlasmaGun.RateOfFire = 600
PlasmaGun.ProjSpeed = 200

PlasmaGun.FireSound = "rbxassetid://821077162"
PlasmaGun.HitSound = ""
PlasmaGun.MissSound = ""
PlasmaGun.EquipLoop = ""
PlasmaGun.FlyLoop = ""

function PlasmaGun.TryDamageTarget(...)
	game.ReplicatedStorage.TryDamage:FireServer(...)
end


function PlasmaGun.Update(dt, model, isFiring)

end

function PlasmaGun.Equip()
	
end

function PlasmaGun.UnEquip()
	
end

function PlasmaGun.HitEffect(hit, pos, norm, mat, grenade)
	--sndLib.PlaySoundClient("3d", "mg_hit", PlasmaGun.HitSound, 0.5, 1, false, 1, pos)
	--sndLib.PlaySoundOtherClients("3d", "mg_hit", PlasmaGun.MissSound[math.random(1, #PlasmaGun.MissSound)], 0.2, 1, false, 1, pos)
	local p = game.ReplicatedStorage.Models.PlasmaGun.Barrel.Flash:Clone()
	p.Lifetime = NumberRange.new(0.5, 0.7)
	p.Parent = grenade
	npcLib.CreateDecal(CFrame.new(pos, pos + norm), Vector3.new(3, 3, 0.2), "http://www.roblox.com/asset/?id=22915150", "Front", false, 8)
	spawn(function()
		p:Emit(1)
		wait(1)
		grenade:Destroy()
	end)
end

function PlasmaGun.UpdateMissile(msl, shooter, dir, dt, tgtpos, flytime, processingPlr)
	if flytime > 0.025 then
		msl.Flash.Enabled = true
	end
	msl.CFrame = CFrame.new(msl.CFrame.p + dir.unit * PlasmaGun.ProjSpeed * dt, tgtpos)
	local ray = Ray.new(msl.CFrame.p, dir.unit * 5)
	local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, {shooter, workspace.Ignore, workspace.ItemPickups, workspace.PlayerSpawns})
	if hit then
		msl.CFrame = CFrame.new(pos, tgtpos)
		
		if hit.Parent.Name == "Barrier" then
			Orakel.BarrierHitFX(hit, pos, norm, mat)
		elseif hit.Name ~= "Clip" then
			PlasmaGun.HitEffect(hit, pos, norm, mat, msl)
		end
	
		if hit.Parent:FindFirstChild("Humanoid") and shooter == processingPlr then
			PlasmaGun.TryDamageTarget("PlasmaGun", shooter, msl.CFrame.p, pos, hit.Parent.Name, ray)
		end
		
		for _, c in pairs(workspace.Characters:GetChildren()) do
			local dist = (c.PrimaryPart.Position - pos).magnitude
			if dist <= PlasmaGun.AreaOfEffect then
				PlasmaGun.TryDamageTarget("PlasmaGun", shooter, msl.CFrame.p, pos, c.Name, ray, dist)
				game.ReplicatedStorage.Push:FireServer(c.Name, pos, PlasmaGun.RocketPushForce)
			end
		end

		return true
	end
	return false
end

function PlasmaGun.ShootEffect(model, tgtpos)
	spawn(function()
		model.Barrel.Flash:Emit(1)
		model.Barrel.PointLight.Enabled = true
		wait(0.04)
		model.Barrel.PointLight.Enabled = false
	end)
end


function PlasmaGun.FireServer(shooter, model, campos, tgtpos, processingPlr)
	local msl = game.ReplicatedStorage.Particles.Plasma:Clone()
	msl.Parent = workspace
	msl.CFrame = CFrame.new(campos, tgtpos)
	
	spawn(function()
		local hasHit = false
		local flytime = 0
		while not hasHit do
			local dt = game:GetService("RunService").Heartbeat:wait()
			flytime = flytime + dt
			hasHit = PlasmaGun.UpdateMissile(msl, shooter, (tgtpos - campos).unit * 999, dt, tgtpos, flytime, processingPlr)
		end
	end)
end

function PlasmaGun.Fire(shooter, model, campos, tgtpos)
	sndLib.PlaySoundClient("global", "mg_fire", PlasmaGun.FireSound, 0.3, 1, false, 1)
	sndLib.PlaySoundOtherClients("3d", "mg_fire", PlasmaGun.FireSound, 0.3, 1, false, shooter.Name)
end




return PlasmaGun
