local root = script.Parent
local Module = {}
local run = game:GetService("RunService")
local runService = run



Module.Configuration = {
  Version = "alpha build 0.1.0.1";
  SoloTestMode = game:FindService("NetworkServer") == nil and game:FindService("NetworkClient") == nil;
  PrintHeader = "Orakel |  ";
  WarnHeader = "Warning |  ";
  ErrorHeader = "Error |  ";
  Logo = {
    Full = "http://www.roblox.com/asset/?id=220270074";
    Symbol = "http://www.roblox.com/asset/?id=220270067";
    Text = "http://www.roblox.com/asset/?id=220270070";
  };
  Entities = root.Entities;
  GoogleAnalyticsModule = 153590792;
  GoogleTrackingId = ""; --IF BLANK, USES THE ID IN ServerScriptService/GoogleAnalytics.lua INSTEAD!
}


--Essentially this list defines what brushes are drawn invisible when compiled
Module.EntitiesToHide = {
  --string Entity, bool setInvis
  ["point_camera"] = true;
  ["info_player_start"] = true;
  ["func_button"] = true;
  ["func_water"] = true;
  ["func_trigger"] = true;
  ["trigger_hurt"] = true;
  ["nav_clip"] = true;
  ["func_precipitation"] = true;
}


Module.PartFaces = {
	Enum.NormalId.Top;
	Enum.NormalId.Bottom;	
	Enum.NormalId.Front;
	Enum.NormalId.Back;
	Enum.NormalId.Right;
	Enum.NormalId.Left;
}



Module.BarrierHitFX = function(hit, pos, norm, mat)
	local p = Instance.new("Part")
	p.Size = Vector3.new()
	p.Transparency = 1
	p.Anchored = true
	p.CanCollide = false
	p.Name = "Clip"
	p.CFrame = CFrame.new(pos, pos + norm)
	
	local e = game.ReplicatedStorage.Particles.BarrierHit:Clone()
	e.Parent = p
	p.Parent = workspace.Ignore
	e:Emit(10)
	Module.RemoveItem(p, 2)
end

Module.ToggleVisible = function(model, toggle, recursive, ignore)
	local ignore = ignore or {}
	if recursive then
		return Module.RecursiveSearch(model, 
		function(obj) --comparator
			return obj:IsA("BasePart") and not Module.TContainsValue(ignore, obj.Name) 
		end,
		function(obj) --callback
			obj.Transparency = toggle
		end)
	else
		for _, p in pairs(model:GetChildren()) do
			if p:IsA("BasePart") and not Module.TContainsValue(ignore, p.Name) then
				p.Transparency = toggle
			end
		end
	end
end


Module.RecursiveSearch = function(rootdir, comparatorf, callbackf)
	for i, obj in pairs(rootdir:GetChildren()) do
		if comparatorf(obj) then
			if not callbackf(obj) then
				break
			end
			Module.RecursiveSearch(obj, comparatorf, callbackf)
		else
			Module.RecursiveSearch(obj, comparatorf, callbackf)
		end
	end
end




Module.FindOrCreate = function(dir, name, type, recursive)
	local object = dir:FindFirstChild(name, recursive)
	if not object then
		local object = Instance.new(type, dir)
		object.Name = name
	end
	return object
end


--Returns every descendant of "obj"
--@param obj Object.
Module.GetChildrenRecursive = function(obj)
  local children = obj:GetChildren()
  local list = {}
  for child = 1, #children do
    list[#list + 1] = children[child]
    local subChildren = Module.GetChildrenRecursive(children[child])
    for sc = 1, #subChildren do
      list[#list + 1] = subChildren[sc]
    end
  end
  return list
end


Module.PrintVersion = function()
  warn("Orakel "..Module.Configuration.Version.." up and running!")
end



Module.PrintStatus = function(origin)
  warn(Module.Configuration.PrintHeader..origin.." initialized")
end



Module.WaitRender = function()
  run.RenderStepped:wait()
end


Module.FindSound = function(name)
  local assetlib = Module.LoadModule("AssetLib")
  for _, stype in pairs(assetlib.Sounds) do
    for sname, snd in pairs(stype) do
      if sname == name then
        return snd
      end
    end
  end
  return nil
end

Module.FindEntity = function(name)
	local map = Module.GetMap()
	for _, v in pairs(map.Entities:GetChildren()) do
		if v:FindFirstChild("EntityName") then
			if v.EntityName.Value == name then
				return v
			end
		end
	end
	return nil
end


--Returns the current map
Module.GetMap = function()
  return workspace:FindFirstChild("Map")
end


function Module.RemoveItem(item, t0)
  spawn(function()
    wait(t0 or 1)
    item:Destroy()
  end)
end


function Module.TLength(t)
	assert(type(t) == "table", "Orakel.TLength only supports tables")
	local l = 0
	for k, v in pairs(t) do
		l = l + 1
	end
	return l
end

function Module.TRand(t)
	assert(type(t) == "table", "Orakel.TRand only supports tables")
	local ln = Module.TLength(t)
	local index = math.random(1, ln)
	local cur = 0
	for k, v in pairs(t) do
		cur = cur + 1
		if cur == index then
			return v
		end
	end
	return nil
end

Module.TContainsValue = function(t, n)
	assert(type(t) == "table", "Orakel.TContainsValue only supports tables")
	for k, v in pairs(t) do
		if typeof(v) == "Instance" then
			if v.Name == n then
				return true
			end
		else
			if v == n then
				return true
			end
		end
	end
	return false
end


Module.TContainsKey = function(t, n)
	assert(type(t) == "table", "Orakel.TContainsKey only supports tables")
	for k, v in pairs(t) do
		if typeof(k) == "Instance" then
			if k.Name == n then
				return true
			end
		else
			if k == n then
				return true
			end
		end
	end
	return false
end

Module.LoadModule = function(module)
  local root = script.Parent
  local found = root:FindFirstChild(module, true)
  if found then
    return require(found)
  else
    error(Module.Configuration.ErrorHeader.."Module '"..tostring(module).."' wasn't found!")
  end
end

Module.LoadData = function(module)
	local root = game.ServerStorage.ItemData
	local found = root:FindFirstChild(module, true)
	if found then
		return require(found)
	else
		error(Module.Configuration.ErrorHeader.."Module '"..tostring(module).."' wasn't found!")
	end
end


local function initEntity(ent, sc)
  --@ent Entity
  --@sc Module
  for _, c in pairs(ent:GetChildren()) do
	if c.ClassName == "RemoteEvent" or c.ClassName == "BindableEvent" then
		c:Destroy()
	end
  end
  local entCode
  local s,e = pcall(function()
	entCode = require(sc)()
  end)
  if not s then
	warn("Requested entity '"..tostring(sc).."' experienced an error while initializing")
	return nil
  end

  local kvals = entCode.KeyValues
  local inputs = entCode.Inputs
  local outputs = entCode.Outputs
  local defOuts = ent:FindFirstChild("Outputs")
  local update = entCode.Update
  local load = entCode.Load
  local updateRate = entCode.UpdateRate
  if load ~= nil then
    spawn(function()
      load(ent)
    end)
  end

  --print("initializing "..tostring(ent).." ...")
  
  if entCode.Inputs == nil then
    entCode.Inputs = {}
    inputs = entCode.Inputs
  end
  
  if entCode.Outputs == nil then
    entCode.Outputs = {}
    outputs = entCode.Outputs
  end
  
  --[[for num = 1, 4 do
    entCode.Outputs[#entCode.Outputs + 1] = "OnUser"..num
  end

  for num = 1, 4 do
    entCode.Inputs["FireUser"..num] = function(ent)
      Module.FireOutput(ent, "OnUser"..num)
    end
  end]]
  
  if inputs ~= nil then
    for input, func in pairs(inputs) do
      local newInp, reInp = Module.InitInput(ent, input)
      newInp.Event:connect(func)
	  if run:IsServer() then
	    reInp.OnServerEvent:connect(function(p, ...)
          func(...)
	    end)
	  end
    end
  else
    --warn(Module.Configuration.WarnHeader.."Entity '"..tostring(ent).."' has no inputs defined!!")
  end
  
  if outputs ~= nil then
    for _, output in pairs(outputs) do
      Module.InitOutput(ent, output)
    end
  else
    --warn(Module.Configuration.WarnHeader.."Entity '"..tostring(ent).."' has no outputs defined!!")
  end
  
  
  if defOuts ~= nil then
		for _, out in pairs(defOuts:GetChildren()) do
			spawn(function() 
				local myOutput = out.MyOutput.Value
				local tgtEnt = out.TargetEntity.Value
				local tgtInp = out.TargetInput.Value
				local param = out.ParamOverride.Value
				local once = out.OnceOnly.Value
				local tdelay = out.Delay.Value
				local tfired = out.TimesFired
				
				local outEvent = ent:FindFirstChild(myOutput)
				if outEvent then
					outEvent.Event:connect(function()
						if tfired.Value > 0 and once then
							--SET TO "ONCE ONLY", CANT RE-FIRE
						else
							tfired.Value = tfired.Value + 1
							wait(tdelay)
							Module.FireInput(Module.FindEntity(tgtEnt), tgtInp)
						end
					end)
				end
			end)
		end
    end
    entCode.Status = true
    if update ~= nil then
		local s,e = pcall(function()
		spawn(function()
			while true do
				wait(1 / updateRate)
				local success = update(ent)
				if not success then
					break
				end
			end
		end)
      end)
      if not s then
        --Error in the Entity code
        warn(Module.Configuration.PrintHeader.."INTERNAL ENTITY ERROR: "..e)
      end
    end
  --game.ReplicatedStorage.Events.MapChange.Event:connect(entCode.Kill)
end

--Initializes every entity in "map"
Module.InitEntities = function(map)
  warn("Orakel ["..Module.Configuration.Version.."] up and running.")
  warn("Initializing map entities")
  local numEnts = 0
  local ents = map.Entities:GetChildren()
  local eScripts = game.ReplicatedStorage.Orakel.Entities:GetChildren()
  for _, ent in pairs(ents) do
    for _, es in pairs(eScripts) do
      if es.Name == ent.Name then
        numEnts = numEnts + 1
        initEntity(ent, es)
      end
    end
  end
  print("Initialized "..numEnts.." entities")
end


Module.InitInput = function(ent, name)
  local be = Instance.new("BindableEvent")
  local re = Instance.new("RemoteEvent")
  be.Name = name
  re.Name = name
  re.Parent = ent
  be.Parent = ent
  return be, re
end


Module.InitOutput = function(ent, name)
  local be = Instance.new("BindableEvent")
  local re = Instance.new("RemoteEvent")
  be.Name = name
  re.Name = name
  re.Parent = ent
  be.Parent = ent
end

Module.RemoveTextures = function(obj)
  for _, c in pairs(obj:GetChildren()) do
    if c.ClassName == "Texture" then
      c:Destroy()
    else
      Module.RemoveTextures(c)
    end
  end
end

--Fire input "inp" of entity "ent" with parameters "..."
Module.FireInput = function(ent, inp, ...)
  --warn(Module.Configuration.PrintHeader.."Firing input '"..inp.."' of '"..tostring(ent).."'")
	local ex = ent:FindFirstChild(inp, true)
	for _, ex in pairs(Module.GetChildrenRecursive(ent)) do
		if ex.ClassName == "BindableEvent" and ex.Name == inp then
			ex:Fire(ent, ...)
		elseif ex.ClassName == "RemoteEvent" and ex.Name == inp then
			if run:IsClient() then
				ex:FireServer(ent, ...)
			else
				ex:FireAllClients(ent, ...)
			end
		end
	end
end

--Fire output "out" of entity "ent" with parameters "..."
Module.FireOutput = function(ent, out, ...)
  --warn(Module.Configuration.PrintHeader.."Firing output '"..out.."' of '"..tostring(ent).."'")
	for _, ex in pairs(Module.GetChildrenRecursive(ent)) do
		if ex.ClassName == "BindableEvent" and ex.Name == out then
			ex:Fire(ent, ...)
		elseif ex.ClassName == "RemoteEvent" and ex.Name == out then
			if run:IsClient() then
				ex:FireServer(ent, ...)
			else
				ex:FireAllClients(ent, ...)
			end
		end
	end
end


Module.GetKeyValue = function(ent, val)
  local ex = ent:FindFirstChild(val, true)
  if ex then
    return ex.Value
  end
  return nil
end


Module.SetKeyValue = function(ent, val, newVal)
  local ex = ent:FindFirstChild(val, true)
  if ex then
    ex.Value = newVal
  end
end

Module.TweenModel = function(CFrameInterp, model, goalCFrame, speed, applyVelocity, maxTime)
	--TweenModel(CFrameInterp module (stravants module), model, goalCFrame, speed in studs, applyVelocity, maxDuration)
	local originCFrame = model:GetPrimaryPartCFrame()
	local cfDist = (goalCFrame.p - originCFrame.p).magnitude
	local duration = cfDist / speed
	local now = tick()
	local angle, interpFunc = CFrameInterp(originCFrame, goalCFrame)
	local lastPos = model:GetPrimaryPartCFrame().p
	local lastTick = tick()
	local delta = runService.RenderStepped:wait()
	
	local alpha = 0 --CFrame alpha
	local timeElapsed = 0
	while true do
		local step = 1 / (duration * (1 / delta))
		alpha = alpha + step
		timeElapsed = timeElapsed + delta
		if alpha >= 1 or timeElapsed >= maxTime then
			break
		end
		local cf = interpFunc(alpha)
		model:SetPrimaryPartCFrame(cf)
		if applyVelocity then
			local velocity = (model:GetPrimaryPartCFrame().p - lastPos) / delta
			for _, part in pairs(model:GetChildren()) do
				if part:IsA("BasePart") then
					part.Anchored = false
					part.Velocity = Vector3.new(velocity.x, velocity.y, velocity.z)
					print(part.Velocity)
					part.Anchored = true
				end
			end
		end
		lastPos = model:GetPrimaryPartCFrame().p
		delta = runService.RenderStepped:wait()
	end
	if applyVelocity then
		for _, part in pairs(model:GetChildren()) do
			if part:IsA("BasePart") then
				part.Velocity = Vector3.new()
			end
		end
	end
	model:SetPrimaryPartCFrame(goalCFrame)
end

return Module
