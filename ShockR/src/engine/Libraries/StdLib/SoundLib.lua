local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local assetLib = Orakel.LoadModule("AssetLib")
local sndLib = {}
local player, pgui
local MAX_AUDIBLE_RANGE = 9000


if game.Players.LocalPlayer ~= nil then
	player = game.Players.LocalPlayer
	pgui = player.PlayerGui
else
	warn("not using SoundLib from client")
end


function sndLib.CreateSound(name, id, vol, ptc, looped)
	local gVol = _G.volume or 1
	local s = Instance.new("Sound")
	s.Name = name
	s.Looped = looped
	s.SoundId = id
	s.Volume = vol * gVol
	s.Pitch = ptc
	return s
end


function sndLib.PlayMusicClient(name, id, vol, ptc, looped, len)
	local s = sndLib.CreateSound(name, id, vol, ptc, looped)
	s.Parent = pgui.Music 
	s:Play()
	coroutine.resume(coroutine.create(function()
		wait(len)
		s:Stop()
		wait(1)
		s:Destroy()
	end))
	return s
end

function sndLib.PlaySoundClientEvent(stype, name, id, vol, ptc, looped, len, v3)
	return sndLib.PlaySoundClient(stype, name, id, vol, ptc, looped, len, v3)
end

local Sheet = {
	["button1"] = {SoundId = ""; Start = 0; Duration = 0.18;};
}

function FindSheetFromTrack(name)
	for sheetName, sheet in pairs(assetLib.Soundsheets) do
		for track, _ in pairs(sheet.Tracks) do
			if track == name then
				return sheetName, sheet
			end
		end
	end
	warn("track '"..name.."' not found in soundsheets")
end

function sndLib.PlaySoundFromSheetClient(stype, name, trackName, vol, ptc, looped, len, v3)
	if stype == nil or name == nil or vol == nil then
		error("Invalid sound request")
	end
	local sheetName, sheet = FindSheetFromTrack(trackName)
	local track = sheet.Tracks[trackName]
	local s = sndLib.CreateSound(name, sheet.SoundId, vol, ptc, looped)
	
	if stype == "global" then
		s.Parent = pgui.Sounds
		Orakel.RemoveItem(s, len)
	elseif stype == "3d" then
		local c
		if pcall(function() local abc = v3.x end) then
			c = Instance.new("Part", workspace)
			c.Name = "ambient_generic"
			c.Transparency = 1
			c.formFactor = "Custom"
			c.Size = Vector3.new(0.2,0.2,0.2)
			c.CanCollide = false
			c.Anchored = true
			c.CFrame = CFrame.new(v3.x, v3.y, v3.z)
		else
			c = v3
		end
		if c ~= nil then
			s.Parent = c
			if pcall(function() local abc = v3.x end) then
				if len > 0 then
					Orakel.RemoveItem(c, len)
				end
			else
				if len > 0 then
					Orakel.RemoveItem(s, len)
				end
			end
			return s
		else
			error("Invalid sound position")
		end
	end
	
	
	spawn(function()
		local t = 0
		s.TimePosition = track.Start
		s:Play()
		game:GetService("RunService").Heartbeat:connect(function(dt)
			t = t + dt
			--if s.TimePosition >= track.Start + track.Duration then
			if s.TimePosition >= track.Duration then --<- old shit for testing
				if looped then
					s:Pause()
					s.TimePosition = track.Start
					s:Play()
				else
					return
				end
			end
		end)
	end)
	return nil
end


function sndLib.PlaySoundOtherClients(...)
	game.ReplicatedStorage.PlaySoundOtherClients:FireServer(...)
end


function sndLib.PlaySoundClient(stype, name, id, vol, ptc, looped, len, v3)
	--stype:  "global", "3d"
	--id: assetID
	--vol: Volume 0-1
	--ptc: Pitch 0-1
	--len: Length in seconds
	--v3: Vector3
	if id == nil or stype == nil or name == nil or vol == nil then
		error("Invalid sound request")
	end
	
	
	if stype == "global" or stype == "Global" then
		local s = sndLib.CreateSound(name, id, vol, ptc, looped)
		if name == "soundscape" then
		  s.Parent = pgui.AmbientSounds
		elseif name == "music" then
		  s.Parent = pgui.Music
		else
		  s.Parent = pgui.Sounds
	  end
		s:Play()
		return s
	elseif stype == "3d" then
		local c
		if typeof(v3) == "string" then
			c = workspace.Characters:FindFirstChild(v3).PrimaryPart
		elseif pcall(function() local abc = v3.x end) then
			c = Instance.new("Part", workspace)
			c.Name = "ambient_generic"
			c.Transparency = 1
			c.formFactor = "Custom"
			c.Size = Vector3.new(0.2,0.2,0.2)
			c.CanCollide = false
			c.Anchored = true
			c.CFrame = CFrame.new(v3.x, v3.y, v3.z)
		else
			c = v3
		end

		if c ~= nil then
			local s = sndLib.CreateSound(name, id, vol, ptc, looped)
			s.Parent = c
			s:Play()
			if pcall(function() local abc = v3.x end) then
				if len > 0 then
					--print("removing "..tostring(s).." from soundLib")
					Orakel.RemoveItem(c, len)
				end
			else
				if len > 0 then
					--print("removing "..tostring(s).." from soundLib")
					Orakel.RemoveItem(s, len)
				end
			end
			return s
		else
			warn("Invalid sound position")
		end
		return nil
	end
end


function sndLib.PlaySoundClientAsync(stype, name, id, vol, ptc, looped, len, v3)
  local s
	spawn(function()
		s = sndLib.PlaySoundClient(stype, name, id, vol, ptc, looped, len, v3)
	end)
	return s
end

function sndLib.StopSoundClient(sndname)
	local s = pgui.Sounds:findFirstChild(sndname)
	if s then
		s:Stop()
		s:Destroy()
	end
end


function sndLib.StopAllSoundsClient()
	local snd = pgui.Sounds:GetChildren()
	for _, s in pairs(snd) do
		s:Stop()
		s:Destroy()
	end
end


function sndLib.FadeSound(snd, endVolume, fadeDuration)
	local gVol = _G.volume or 1
	endVolume = endVolume * gVol
	local vol = snd.Volume
	local fps = 20
	local steps = fadeDuration * fps
	for i = 1, steps do
		snd.Volume = snd.Volume - (vol - endVolume) / steps
		wait(1 / fps)
	end
end













return sndLib