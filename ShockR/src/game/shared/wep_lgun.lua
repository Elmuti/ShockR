local LightningGun = {Fired = false}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")
local snd

LightningGun.ViewModel = {
	Offset = Vector3.new(1.25, -1.25, -0.8);
	Angle = Vector3.new(0, -90, 0);
}
LightningGun.ViewModel_3rdPerson = {
	Offset = Vector3.new(0.4, 0.7, -2.15);
}

LightningGun.Name = "LightningGun"
LightningGun.Damage = 6
LightningGun.RateOfFire = 1200
LightningGun.Range = 75

LightningGun.FireSound = "rbxassetid://821077996"
LightningGun.FireLoop = "rbxassetid://821077832"
LightningGun.HitSound = ""
LightningGun.MissSound = ""
LightningGun.EquipLoop = ""

local variation = 6

function LightningTrail(origin, target, parent)
	local difference = target - origin --Vector pointing from origin to target
	local distance = difference.magnitude --The distance between target and origin
	local points = {origin} --The start point - it's an array so we can store the other points more easily
	local numSegments = 8 --The amount of segments (parts) the spark should consist of
	local count --Temporary value
	local LASTPOINT
	for count = 1, numSegments-1 do
		local point = origin + difference * (count/numSegments) --Calculate a point along the way
		point = point + Vector3.new(math.random(-variation,variation),math.random(-variation,variation),math.random(-variation,variation)) * (distance / 400)
		table.insert(points,point)
		LASTPOINT = point
	end
	table.insert(points,target)
	local arcMdl = Instance.new("Model")
	--Now draw the arc:
	for count = 1, numSegments do
		local p1 = points[count] --Get the first point in the line segment
		local p2 = points[count+1] --Get the second point in the line segment
		local partPosition = (p1+p2) / 2 --The position of the part
		local part = game.ReplicatedStorage.Particles.LG_Arc:Clone() --Create new part
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Transparency = 0.3
		part.Anchored = true --Anchor it
		part.formFactor = "Custom" --Set the formFactor to Custom
		part.Size = Vector3.new(0.2,0.2,(p1-p2).magnitude) --Set the part size so it is a thin, long part (and has the correct length)
		part.CFrame = CFrame.new(partPosition,p2) --Set its position to partPosition and make it face towards p2
		part.Parent = arcMdl --Parent it to workspace to make it visible.
	end
	arcMdl.Parent = parent
	return arcMdl
end

function LightningGun.Equip()
	
end

function LightningGun.UnEquip()
	LightningGun.Fired = false
end

function LightningGun.TryDamageTarget(...)
	sndLib.PlaySoundClient("global", "hitsound", "rbxassetid://821077013", 0.2, 1, false, 1)
	game.ReplicatedStorage.TryDamage:FireServer(...)
end


function LightningGun.Update(dt, model, isFiring)

end

function LightningGun.ShootEffect(model, tgtpos)
	for _, pe in pairs(model.Barrel:GetChildren()) do
		pe:Emit(1)
	end
	local arcMdl = LightningTrail(model.Barrel.Position, tgtpos, model)
	game.Debris:AddItem(arcMdl, 0.06)
end


function LightningGun.HitEffect(hit, pos, norm, mat)
	--sndLib.PlaySoundClient("3d", "lg_hit", LightningGun.MissSound[math.random(1, #LightningGun.HitSound)], 0.2, 1, false, 1, pos)
	--sndLib.PlaySoundOtherClients("3d", "lg_hit", LightningGun.MissSound[math.random(1, #LightningGun.HitSound)], 0.2, 1, false, 1, pos)
	
	npcLib.CreateDecal(CFrame.new(pos, pos + norm), Vector3.new(3, 3, 0.2), "http://www.roblox.com/asset/?id=22915150", "Front", false, 8)
end

function LightningGun.StopFire()
	if snd then
		snd:Stop()
		snd:Destroy()
	end
	LightningGun.Fired = false
end

function LightningGun.FireOnce(shooter)
	snd = sndLib.PlaySoundClient("global", "hum", LightningGun.FireLoop, 0.2, 1, true, -1)
	sndLib.PlaySoundClient("global", "mg_fire", LightningGun.FireSound, 0.3, 1, false, 2)
	sndLib.PlaySoundOtherClients("3d", "mg_fire", LightningGun.FireSound, 0.3, 1, false, 2, shooter.Name)
end

function LightningGun.Fire(shooter, model, campos, tgtpos, char)
	--sndLib.PlaySoundClient("global", "mg_fire", LightningGun.FireSound, 0.3, 1, false, 1)
	--sndLib.PlaySoundOtherClients("3d", "mg_fire", LightningGun.FireSound, 0.3, 1, false, model)
	
	
	game.ReplicatedStorage.ReplicateShootEffect:FireServer(model, tgtpos)
	for _, pe in pairs(model.Barrel:GetChildren()) do
		pe:Emit(1)
	end
	
	local ray = Ray.new(campos, (tgtpos - campos).unit * LightningGun.Range)
	local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, {shooter.Character, model, workspace.Ignore, char, workspace.ItemSpawns, workspace.ItemPickups, workspace.Clip})
	
	local arcMdl = LightningTrail(model.Barrel.Position, pos, model)
	game.Debris:AddItem(arcMdl, 0.06)
	
	if hit then
		if hit.Parent:FindFirstChild("Humanoid") then
			LightningGun.TryDamageTarget(LightningGun.Name, shooter, campos, tgtpos, hit.Parent.Name, ray)
		else
			if hit.Parent.Name == "Barrier" then
				Orakel.BarrierHitFX(hit, pos, norm, mat)
			elseif hit:IsA("BasePart") and hit.CanCollide and hit.Name ~= "Clip" then
				LightningGun.HitEffect(hit, pos, norm, mat)
				game.ReplicatedStorage.ReplicateHitEffect:FireServer("LightningGun", hit, pos, norm, mat)
			end
		end
	end
end




return LightningGun
