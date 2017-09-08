local Grenade = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")

local friction = 5

Grenade.ViewModel = {
	Offset = Vector3.new(1.25, -1.25, -0.25);
	Angle = Vector3.new(0, -90, 0);
}
Grenade.ViewModel_3rdPerson = {
	Offset = Vector3.new(0.4, 0.7, 0);
}


Grenade.Name = "Grenade"
Grenade.Damage = 100
Grenade.RocketPushForce = 40
Grenade.AreaOfEffect = 14
Grenade.SplashDamage = 84
Grenade.RateOfFire = 75
Grenade.ProjSpeed = 100
Grenade.FuseTime = 2.5

Grenade.FireSound = "rbxassetid://821076547"
Grenade.HitSound = "rbxassetid://81116747"
Grenade.MissSound = "rbxassetid://821076837"
Grenade.EquipLoop = ""


function Grenade.TryDamageTarget(...)
	game.ReplicatedStorage.TryDamage:FireServer(...)
end


function Grenade.Update(dt, model, isFiring)

end

function Grenade.Equip()
	
end

function Grenade.UnEquip()
	
end

function Grenade.HitEffect(hit, pos, norm, mat, msl)
	sndLib.PlaySoundClient("3d", "mg_hit", Grenade.HitSound, 0.5, 1, false, 1, pos)
	--sndLib.PlaySoundOtherClients("3d", "mg_hit", Grenade.MissSound[math.random(1, #Grenade.MissSound)], 0.2, 1, false, 1, pos)
	
	local xp = Instance.new("Explosion")
	xp.Position = msl.Position
	xp.BlastRadius = Grenade.AreaOfEffect
	xp.BlastPressure = 0
	xp.Parent = workspace
	msl.PointLight.Enabled = true
	msl.Smoke.Enabled = false
	spawn(function()
		wait(0.08)
		msl:Destroy()
	end)
end

function Grounded(msl, char, model)
	local ray = Ray.new(msl.CFrame.p, Vector3.new(0, -1, 0))
	local hit, pos, norm = workspace:FindPartOnRayWithIgnoreList(ray, {char, model, workspace.Ignore, workspace.ItemPickups, workspace.ItemSpawns})
	if hit then
		return true
	end
	return false
end

function Grenade.UpdateMissile(msl, shooter, dir, dt, tgtpos, processingPlr, velocity, model, char)
	local char = workspace.Characters:FindFirstChild(shooter.Name)
	local grounded = Grounded(msl, shooter, model)
	
	--if grounded then
		local fd = friction * dt
		velocity = velocity - Vector3.new(fd, fd, fd)
	--else
		velocity = velocity - Vector3.new(0, (workspace.Gravity / 2) * dt, 0)
	--end

	local collisionRay = Ray.new(msl.CFrame.p, velocity * dt)
	local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(collisionRay, {char, msl, shooter, model, workspace.Ignore, workspace.ItemPickups, workspace.ItemSpawns})
	if hit then
		if hit.Parent:FindFirstChild("Humanoid") and shooter == processingPlr then
			--print("grenade hit humanoid")
			Grenade.HitEffect(hit, pos, norm, mat, msl)
			Grenade.TryDamageTarget("Grenade", shooter, msl.CFrame.p, pos, hit.Parent.Name, collisionRay)
			return true, velocity
		end
		if velocity.magnitude > 1 then
			--print("grenade bouncing off")
			sndLib.PlaySoundClient("3d", "mg_hit", Grenade.MissSound, 0.5, 1, false, 1, pos)
			local normal = collisionRay.Direction.unit
			local reflectedNormal = (normal - (2 * normal:Dot(norm) * norm))
			velocity = reflectedNormal * velocity.magnitude
			velocity = velocity * 0.5
		end
	end
	
	msl.CFrame = CFrame.new(msl.CFrame.p + velocity * dt)

	return false, velocity
end


function Grenade.ShootEffect(model)
	spawn(function()
		model.Barrel.Flash:Emit(1)
		model.Barrel.Smoke:Emit(25)
	end)
end

function Grenade.FireServer(shooter, model, campos, tgtpos, processingPlr)
	local msl = game.ReplicatedStorage.Particles.Grenade:Clone()
	msl.Parent = workspace
	
	local char = workspace.Characters:FindFirstChild(tostring(shooter))
	
	local ray = Ray.new(campos, (tgtpos - campos).unit * 2)
	local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char, shooter, model, workspace.Ignore, workspace.ItemPickups, workspace.ItemSpawns})
	
	msl.CFrame = CFrame.new(pos, tgtpos)
	
	spawn(function()
		local hasHit = false
		local velocity = ((tgtpos - campos).unit * 55) + Vector3.new(0, 15, 0)
		local flytime = 0
		while not hasHit and flytime < Grenade.FuseTime do
			local dt = game:GetService("RunService").Heartbeat:wait()
			flytime = flytime + dt
			--print(velocity)
			hasHit, velocity = Grenade.UpdateMissile(msl, shooter, (tgtpos - campos).unit * 999, dt, tgtpos, processingPlr, velocity, model, char)
		end
		if not hasHit then
			Grenade.HitEffect(msl, msl.CFrame.p, Vector3.new(), Enum.Material.Neon, msl)
			for _, c in pairs(workspace.Characters:GetChildren()) do
				local dist = (c.PrimaryPart.Position - msl.CFrame.p).magnitude
				if dist <= Grenade.AreaOfEffect then
					Grenade.TryDamageTarget("Grenade", shooter, msl.CFrame.p, msl.CFrame.p, c.Name, Ray.new(msl.CFrame.p, Vector3.new(0, 1, 0)), dist)
					game.ReplicatedStorage.Push:FireServer(c.Name, msl.CFrame.p, Grenade.RocketPushForce)
				end
			end
		end
		msl:Destroy()
	end)
end

function Grenade.Fire(shooter, model, campos, tgtpos)
	spawn(function()
		model.Barrel.Smoke:Emit(25)
		--model.Handle.ShellEmitter:Emit(1)
	end)
	
	sndLib.PlaySoundClient("global", "gren_fire", Grenade.FireSound, 0.3, 1, false, 1)
	sndLib.PlaySoundOtherClients("3d", "gren_fire", Grenade.FireSound, 0.3, 1, false, shooter.Name)
end




return Grenade
