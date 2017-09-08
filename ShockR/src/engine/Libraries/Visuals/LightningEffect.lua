-- Fractality

-- Returns a function that generates lightning.

--[[ Arguments:
	* start & stop	<2*Vector3>	The start and stop positions.
	* bfactor		<float>		Branch length relative to trunk length.
	* jaggedness	<float>		Maximum offset of each midpoint.
	* thickness		<float>		Segment thickness multiplier.
	* iterations	<integer>	Number of subdivisions or 'detail'. See below.
--]]


--[[ Boring stuff =]

		This runs in O(n)=3^n unmodified; 2^n if you remove branching.
	In other words, lag increases by a factor of three for each iteration.
	Try to keep the iterations argument below 8 (6561 parts); an
	appropriate value for real time generation (e.g. a weapon =]) is 4
	(81 parts).  Memory usage becomes an issue with anything over 9 (19683 parts).
	
		Lighting sources are relatively expensive, so someone might want to
	try adding invisible light source parts at an early interation while
	the actual segments get rendered later on (i.e. low-detail lights,
	high-detail segments).
	
	Good starting values for the last four args are 0.4, 0.3, 0.2, 5.
--]]


math.randomseed(tick())

local mlaser = script.Ref -- Template for the segments

local random, log, tau = math.random, math.log, math.pi*2

-- Render a segment
local function RenderSegment(start, stop, powar, parent)
	local len = (start - stop).magnitude
	local new = mlaser:clone()
	new.CFrame = CFrame.new((start + stop)/2, stop)*CFrame.Angles(math.pi/2, 0, 0)
	if len < 1 then
		new.Mesh.Scale = Vector3.new(powar, len, powar)
		new.Size = Vector3.new(0.5, 1, 0.5)
	else
		new.Mesh.Scale = Vector3.new(powar, 1, powar)
		new.Size = Vector3.new(0.5, len, 0.5)
	end
	new.Parent = parent
end

-- Generates lightning
local function Generate(start, stop, bfactor, jaggedness, thickness, iterations)
	local parent = Instance.new('Model', workspace)
	local theta = math.atan(2*jaggedness) -- Precompute the max angle to make sure there's no overlap (x*2 = x/0.5)
	local segmentList = {{start, stop}} -- Start with a straight line
	
	for i = 1, iterations do
		local _segmentList = segmentList
		segmentList = {}
		for _, v in ipairs(_segmentList) do
			-- Offset the midpoint randomly on the plane perpendicular to the current line
			local dist = (v[1] - v[2]).magnitude
			local midPoint = (v[1] + v[2])/2
			local dVect = CFrame.new(midPoint, v[2])
			midPoint = (dVect*CFrame.Angles(0, 0, random()*tau)*CFrame.new(0, random()*dist*jaggedness, 0)).p
			
			-- Generate branch
			local branchLen = bfactor*dist
			local direction = (dVect*(CFrame.Angles(0, 0, random()*tau)*CFrame.Angles(0, random()*theta, 0))).lookVector
			local branch = direction*branchLen + midPoint		

			if i ~= iterations then
				-- Save the path for next iteration
				segmentList[#segmentList + 1] = {v[1], midPoint}
				segmentList[#segmentList + 1] = {midPoint, v[2]}
				segmentList[#segmentList + 1] = {midPoint, branch}
			else
				-- We don't need to save after the final iteration; just render the segments
				-- Thick segments look bad. Apply log
				--local distl = log(dist + 1)*thickness
				local distl = dist*thickness
				RenderSegment(v[1], midPoint, distl, parent)
				RenderSegment(midPoint, v[2], distl, parent)
				RenderSegment(midPoint, branch, branchLen*thickness, parent)
			end
		end
	end
end

return Generate
