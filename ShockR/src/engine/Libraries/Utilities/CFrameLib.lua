local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local CFrameInterp = Orakel.LoadModule("CFrameInterp")
local run = game:GetService("RunService")
local lib = {}


lib.TweenLinear = function(model, c0, c1, t0, applyVelocity, callBack)
  local children = Orakel.GetChildrenRecursive(model)
  local now = tick()
  local angle, interpFunc = CFrameInterp(c0, c1)
  local steps = t0 * 60
  local lastPos = model.PrimaryPart.Position
  local lastTick = tick()
  
  for f = 0, steps, 1 / steps do
    if f >= 1 then
      break
    end
    
    local cf = interpFunc(f)
    model:SetPrimaryPartCFrame(cf)
	if applyVelocity then
	    for i = 1, #children do
	      if children[i]:IsA("BasePart") then
	        local v = (model.PrimaryPart.Position - lastPos) / (lastTick - tick())
	        children[i].Velocity = Vector3.new(-v.x, -v.y, -v.z)
	      end
	    end
    end
    lastPos = model.PrimaryPart.Position
    lastTick = tick()
    run.RenderStepped:wait()
  end
  if applyVelocity then
	  for _, p in pairs(children) do
	    if p:IsA("BasePart") then
	      p.Velocity = Vector3.new(0, 0, 0)
	    end
	  end
  end
  model:SetPrimaryPartCFrame(c1)
  
  if callBack ~= nil then
    if type(callBack) == "function" then
      callBack()
    end
  end
  
  return true
end


lib.TweenLinearAsync = function(model, c0, c1, t0, applyVelocity, callBack)
	spawn(function()
		lib.TweenLinear(model, c0, c1, t0, applyVelocity, callBack)
	end)
end


return lib





