local RocketLauncher = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")

RocketLauncher.ViewModel = {
	Offset = Vector3.new(1.25, -1.25, 1.25);
	Angle = Vector3.new(-90, 180, -90);
}
RocketLauncher.ViewModel_3rdPerson = {
	Offset = Vector3.new(0.4, 0.7, -1.15);
}


RocketLauncher.Name = "RocketLauncher"
RocketLauncher.Damage = 100
RocketLauncher.RocketPushForce = 75
RocketLauncher.AreaOfEffect = 14
RocketLauncher.SplashDamage = 84
RocketLauncher.RateOfFire = 75
RocketLauncher.ProjSpeed = 100

RocketLauncher.FireSound = "http://www.roblox.com/asset/?id=81116734"
RocketLauncher.HitSound = "http://www.roblox.com/asset/?id=81116747"
RocketLauncher.MissSound = ""
RocketLauncher.EquipLoop = ""
RocketLauncher.FlyLoop = "http://www.roblox.com/asset/?id=81116722"

function RocketLauncher.TryDamageTarget(...)
	print("dmging to server")
	game.ReplicatedStorage.TryDamage:FireServer(...)
end


function RocketLauncher.Update(dt, model, isFiring)

end

function RocketLauncher.Equip()
	
end

function RocketLauncher.UnEquip()
	
end

function RocketLauncher.HitEffect(hit, pos, norm, mat, msl)
	sndLib.PlaySoundClient("3d", "mg_hit", RocketLauncher.HitSound, 0.5, 1, false, 1, pos)
	--sndLib.PlaySoundOtherClients("3d", "mg_hit", RocketLauncher.MissSound[math.random(1, #RocketLauncher.MissSound)], 0.2, 1, false, 1, pos)
	
	local xp = Instance.new("Explosion")
	xp.Position = msl.PrimaryPart.Position
	xp.BlastRadius = RocketLauncher.AreaOfEffect
	xp.BlastPressure = 0
	xp.Parent = workspace
	msl.Rocket.Transparency = 1
	msl.Flare.Transparency = 1
	msl.Flare.Flash.Enabled = false
	spawn(function()
		wait(0.08)
		msl:Destroy()
	end)
end

function RocketLauncher.UpdateMissile(msl, shooter, dir, dt, tgtpos, processingPlr)
	msl:SetPrimaryPartCFrame(CFrame.new(msl:GetPrimaryPartCFrame().p + dir.unit * RocketLauncher.ProjSpeed * dt, tgtpos))
	local ray = Ray.new(msl:GetPrimaryPartCFrame().p, dir.unit * 2)
	local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, {shooter.Character, workspace.Ignore})
	if hit then
		RocketLauncher.HitEffect(hit, pos, norm, mat, msl)
		
		if hit.Parent:FindFirstChild("Humanoid") and shooter == processingPlr then
			RocketLauncher.TryDamageTarget("RocketLauncher", shooter, msl:GetPrimaryPartCFrame().p, pos, hit.Parent.Name, ray)
		end
		
		for _, c in pairs(workspace.Characters:GetChildren()) do
			local dist = (c.PrimaryPart.Position - pos).magnitude
			if dist <= RocketLauncher.AreaOfEffect then
				RocketLauncher.TryDamageTarget("RocketLauncher", shooter, msl:GetPrimaryPartCFrame().p, pos, c.Name, ray, dist)
				game.ReplicatedStorage.Push:FireServer(c.Name, pos, RocketLauncher.RocketPushForce)
			end
		end
		return true
	end
	return false
end

function RocketLauncher.ShootEffect(model)
	spawn(function()
		model.Barrel.Smoke:Emit(25)
	end)
end

function RocketLauncher.FireServer(shooter, model, campos, tgtpos, processingPlr)
	local msl = game.ReplicatedStorage.Particles.Missile:Clone()
	msl.Parent = workspace
	msl:SetPrimaryPartCFrame(CFrame.new(campos, tgtpos))
	
	spawn(function()
		local hasHit = false
		while not hasHit do
			local dt = game:GetService("RunService").Heartbeat:wait()
			hasHit = RocketLauncher.UpdateMissile(msl, shooter, (tgtpos - campos).unit * 999, dt, tgtpos, processingPlr)
		end
	end)
end

function RocketLauncher.Fire(shooter, model, campos, tgtpos)
	spawn(function()
		model.Barrel.Smoke:Emit(25)
		--model.Handle.ShellEmitter:Emit(1)
	end)
	
	sndLib.PlaySoundClient("global", "mg_fire", RocketLauncher.FireSound, 0.3, 1, false, 1)
	sndLib.PlaySoundOtherClients("3d", "mg_fire", RocketLauncher.FireSound, 0.3, 1, false, shooter.Name)
end




return RocketLauncher
