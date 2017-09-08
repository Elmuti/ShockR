local eng = {}

eng.Million = 1000000
eng.Billion = 1000000000
eng.Trillion = 1000000000000
eng.Quadrillion = 1000000000000000

local math_pi = math.pi
local math_random = math.random
local math_floor = math.floor
local random=math.random
local cos=math.cos
local sin=math.sin
local v3=Vector3.new
local rad2deg = 180 / math_pi
local deg2rad = math_pi / 180


function eng.IntegerToNumeral(int)
	local _, dec = math.modf(int)
	assert(dec == 0, "tried to call IntegerToNumeral with a float as the parameter")
	
	local str = tostring(int)
	local finalNum = tonumber(str:sub(str:len(), str:len()))
	
	if int ~= 11 and int ~= 12 and int ~= 13 then
		if finalNum == 1 then
			return str.."st"
		elseif finalNum == 2 then
			return str.."nd"
		elseif finalNum == 3 then
			return str.."rd"
		end
	end
	return str.."th"
end


function eng.Clamp( n, min, max )
	return n > max and max or n < min and min or n
end

function eng.RandomFloat( min, max )
	return min + (max-min) * math_random()
end


function eng.RandomUnitVector(ang,dir)
	local s=1-(ang and 1-cos(ang) or 2)*random()
	local t=6.2831853071796*random()
	local rx=s
	local m=(1-s*s)^0.5
	local ry=m*cos(t)
	local rz=m*sin(t)
	if dir then
		local dx,dy,dz=dir.x,dir.y,dir.z
		local d=(dx*dx+dy*dy+dz*dz)^0.5
		if dx/d<-0.9999 then
			return v3(-rx,ry,rz)
		elseif dx/d<0.9999 then
			local coef1=(rx-dx*(dy*ry+dz*rz)/(dy*dy+dz*dz))/d
			local coef2=(dz*ry-dy*rz)/(dy*dy+dz*dz)
			return v3((dx*rx+dy*ry+dz*rz)/d,
				dy*coef1+dz*coef2,
				dz*coef1-dy*coef2)
		else
			return v3(rx,ry,rz)
		end
	else
		return v3(rx,ry,rz)
	end
end


function eng.RandomVector(ang,dir)
	local r=random()^(1/3)
	local s=1-(ang and 1-cos(ang) or 2)*random()
	local t=6.2831853071796*random()
	local m=(1-s*s)^0.5
	local rx=r*s
	local ry=r*m*cos(t)
	local rz=r*m*sin(t)
	if dir then
		local dx,dy,dz=dir.x,dir.y,dir.z
		local d=(dx*dx+dy*dy+dz*dz)^0.5
		if dx/d<-0.9999 then
			return v3(-rx,ry,rz)
		elseif dx/d<0.9999 then
			local coef1=(rx-dx*(dy*ry+dz*rz)/(dy*dy+dz*dz))/d
			local coef2=(dz*ry-dy*rz)/(dy*dy+dz*dz)
			return v3((dx*rx+dy*ry+dz*rz)/d,
				dy*coef1+dz*coef2,
				dz*coef1-dy*coef2)
		else
			return v3(rx,ry,rz)
		end
	else
		return v3(rx,ry,rz)
	end
end




function eng.Round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end


function eng.SecondsToTimerFormat(int)
	local prefix, suffix = "", ""
	local minutes = math.floor(int / 60)
	local seconds = math.floor(int % 60)
	if minutes < 10 then
		prefix = "0"
	end
	if seconds < 10 then
		suffix = "0"
	end
	return prefix..tostring(minutes)..":"..suffix..tostring(seconds)
end


function eng.Format(num, decimalPlaces)
	local idp = decimalPlaces or 4
	if num < math.huge then
		if num >= eng.Quadrillion then
			local f = num / eng.Quadrillion
			return tostring(eng.Round(f, idp).." quad")
		elseif num >= eng.Trillion then
			local f = num / eng.Trillion
			return tostring(eng.Round(f, idp).." tril")
		elseif num >= eng.Billion then
			local f = num / eng.Billion
			return tostring(eng.Round(f, idp).." b")
		elseif num >= eng.Million then
			local f = num / eng.Million
			return tostring(eng.Round(f, idp).." mil")
		elseif num >= 1000 then
			local f = num / 1000
			return tostring(eng.Round(f, idp).." k")
		end
	else
		return "infinite"
	end
end



return eng