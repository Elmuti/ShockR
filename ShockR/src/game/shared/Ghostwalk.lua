local GhostWalk = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")

GhostWalk.Cooldown = 40
GhostWalk.Duration = 5
GhostWalk.FireSound = "rbxassetid://160772554"

function GhostWalk.HitEffect(hit, pos, norm, mat, char)

end

function GhostWalk.UseEffect(hit, pos, norm, mat, char)

end

function GhostWalk.FireServer(shooter, modelname, campos, tgtpos, processingPlr)
	sndLib.PlaySoundClient("global", "GhostWalk_fire", GhostWalk.FireSound, 0.3, 1, false, 1)
	local wep = "Machinegun"
	local char = workspace.Characters:FindFirstChild(shooter.Name)
	
	
	local top = game.ReplicatedStorage.Particles.GhostWalkUp:Clone()
	local bot = game.ReplicatedStorage.Particles.GhostWalkDown:Clone()
	top.Parent = char.PrimaryPart
	bot.Parent = char.PrimaryPart
	top:Emit(10)
	bot:Emit(10)
	
	spawn(function()
		wait(3)
		top:Destroy()
		bot:Destroy()
	end)
	
	
	if shooter ~= processingPlr then

	end
end


function GhostWalk.FireClient(shooter, model, campos, tgtpos)
	--sndLib.PlaySoundClient("global", "direorb_fire", DireOrb.FireSound, 0.3, 1, false, 1)
	--sndLib.PlaySoundOtherClients("3d", "direorb_fire", DireOrb.FireSound, 0.3, 1, false, shooter.Name)
	spawn(function()
		game.ReplicatedStorage.ToggleInvisibilityClient:Fire(true)
		game.Lighting.Ghostwalk.Enabled = true
		wait(GhostWalk.Duration)
		game.Lighting.Ghostwalk.Enabled = false
		game.ReplicatedStorage.ToggleInvisibilityClient:Fire(false)
	end)
end







return GhostWalk
