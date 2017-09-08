local DireOrb = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")

DireOrb.Cooldown = 20
DireOrb.ProjSpeed = 100
DireOrb.FireSound = "rbxassetid://160772554"

function DireOrb.HitEffect(hit, pos, norm, mat, char)
	local p = Instance.new("Part")
	p.Size = Vector3.new()
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.CFrame = CFrame.new(pos, norm)
	
	local top = game.ReplicatedStorage.Particles.DireOrbUp:Clone()
	local bot = game.ReplicatedStorage.Particles.DireOrbDown:Clone()
	top.Parent = p
	bot.Parent = p
	p.Parent = workspace.Ignore
	spawn(function()
		wait()
		top:Emit(10)
		bot:Emit(10)
		wait(4)
		p:Destroy()
	end)
end

function DireOrb.UseEffect(hit, pos, norm, mat, char)
	local top = game.ReplicatedStorage.Particles.DireOrbUp:Clone()
	top.Parent = char:FindFirstChild("Torso")
	top.EmissionDirection = Enum.NormalId.Front
	spawn(function()
		wait()
		top:Emit(10)
	end)
end

function DireOrb.FireServer(shooter, model, campos, tgtpos, processingPlr)
	sndLib.PlaySoundClient("global", "direorb_fire", DireOrb.FireSound, 0.3, 1, false, 1)
	local msl = game.ReplicatedStorage.Particles.DireOrb:Clone()
	msl.Parent = workspace
	msl.CFrame = CFrame.new(campos, tgtpos)
	
	spawn(function()
		local hasHit = false
		while not hasHit do
			local dt = game:GetService("RunService").Heartbeat:wait()
			hasHit = DireOrb.UpdateOrb(msl, shooter, (tgtpos - campos).unit * 999, dt, tgtpos, processingPlr)
		end
		msl:Destroy()
	end)
end


function DireOrb.UpdateOrb(msl, shooter, dir, dt, tgtpos, processingPlr)
	local char = workspace.Characters:FindFirstChild(shooter.Name)
	local char2 = workspace.Characters:FindFirstChild(processingPlr.Name)
	
	msl.CFrame = CFrame.new(msl.CFrame.p + dir.unit * DireOrb.ProjSpeed * dt, tgtpos)
	
	local ray = Ray.new(msl.CFrame.p, dir.unit * 2)
	local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, {msl, char, char2, workspace.Ignore, workspace.ItemPickups, workspace.ItemSpawns})
	if hit then
		print(tostring(hit))
		DireOrb.HitEffect(hit, pos, norm, mat, char)
		
		local normal = ray.Direction.unit
		local reflectedNormal = (normal - (2 * normal:Dot(norm) * norm))
		local reflectedpos = reflectedNormal * 5
		
		char:SetPrimaryPartCFrame(CFrame.new(pos + reflectedpos))
		return true
	end
	return false
end

function DireOrb.FireClient(shooter, model, campos, tgtpos)
	--sndLib.PlaySoundClient("global", "direorb_fire", DireOrb.FireSound, 0.3, 1, false, 1)
	--sndLib.PlaySoundOtherClients("3d", "direorb_fire", DireOrb.FireSound, 0.3, 1, false, shooter.Name)
end







return DireOrb
