local Barrier = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local sndLib = Orakel.LoadModule("SoundLib")
local npcLib = Orakel.LoadModule("NpcLib")
local loopSnd

Barrier.Cooldown = 30
Barrier.Duration = 5
Barrier.FireSound = "rbxassetid://365805083"
Barrier.LoopSound = "rbxassetid://365805061"

function Barrier.HitEffect(hit, pos, norm, mat, char)

end

function Barrier.UseEffect(hit, pos, norm, mat, char)

end

function Barrier.FireServer(shooter, modelname, campos, tgtpos, processingPlr)
	sndLib.PlaySoundClient("global", "Barrier_fire", Barrier.FireSound, 0.3, 1, false, 1)
	loopSnd = sndLib.PlaySoundClient("global", "Barrier_loop", Barrier.LoopSound, 0.3, 1, true, -1)
end


function Barrier.FireClient(shooter, model, campos, tgtpos)
	local bup = false
	--sndLib.PlaySoundClient("global", "direorb_fire", DireOrb.FireSound, 0.3, 1, false, 1)
	--sndLib.PlaySoundOtherClients("3d", "direorb_fire", DireOrb.FireSound, 0.3, 1, false, shooter.Name)
	spawn(function()
		game.ReplicatedStorage.ToggleBarrierClient:Fire(true)
		bup = true
		local connection = game.ReplicatedStorage.WeaponFiredClient.Event:connect(function()
			game.ReplicatedStorage.ToggleBarrierClient:Fire(false)
			wait(0.65)
			if bup then
				game.ReplicatedStorage.ToggleBarrierClient:Fire(true)
			end
		end)
		
		wait(Barrier.Duration)
		bup = false
		game.ReplicatedStorage.ToggleBarrierClient:Fire(false)
		connection:disconnect()
		if loopSnd then
			loopSnd:Stop()
			loopSnd:Destroy()
		end
	end)
end







return Barrier
