local eng = {}
local PathTimeEstimateFailSafe = 2
local V3 = Vector3.new

local Abyss = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Abyss.LoadModule("MathLib")


function eng.CreateDecal(cf, size, tex, face, edgeDetection, duration)
	local checkEdges = edgeDetection or false
	local canDraw = true
	if checkEdges then
		local edges = {
			cf.p + V3(-size.x / 2, 1, -size.z / 2);
			cf.p + V3(size.x / 2, 1, size.z / 2);
			cf.p + V3(-size.x / 2, 1, size.z / 2);
			cf.p + V3(size.x / 2, 1, -size.z / 2);
		}
		
		for edge = 1, #edges do
			local ray = Ray.new(edges[edge], Vector3.new(0, -1.5, 0))
			local hit = workspace:FindPartOnRayWithIgnoreList(ray, {workspace.Ignore})
			if hit == nil then
				canDraw = false
				break
			end
		end
	end
	
	if canDraw then
		local he = Instance.new("Part")
		he.Anchored = true
		he.Transparency = 1
		he.CanCollide = false
		he.FormFactor = Enum.FormFactor.Custom
		he.Size = size
		he.CFrame = cf
		local dc = Instance.new("Decal", he)
		dc.Face = face
		dc.Texture = tex
		he.Parent = workspace.Ignore
	
		game.Debris:AddItem(he, duration)
		return he
	end
	return nil
end


function eng.CreateDamageTable(p, f, c, l, ps, crit)
	return {
		Physical = p;
		Fire = f;
		Cold = c;
		Lightning = l;
		Poison = ps;
		CriticalStrike = crit;
	}
end

function eng.CalculateArmourMitigation(physDmg, armour)
	return armour / (armour + 10 * physDmg)
end

function eng.CalculateEvadeChance(accuracy, evasion)
	return mathLib.Clamp(1 - (accuracy / (accuracy + (evasion + (1/4)) ^ 0.8)), 5, 95)
end

function eng.CalculateDodgeChance(chanceToEvade, dodgeChance)
	return 1 - (1 - chanceToEvade) * (1 - dodgeChance)
end



function eng.TryDamage(attacker, target, damageTable, isSpell, targetChar)
	local totalDamage = damageTable.Physical + damageTable.Fire + damageTable.Cold + damageTable.Lightning + damageTable.Poison
	
	--EVASION AND DODGE
	local chanceToEvade = 0
	if not attacker:GetStat("HitsCantBeEvaded") and not target:GetStat("CannotEvade") then
		chanceToEvade = eng.CalculateEvadeChance(attacker:GetStat("Accuracy"), target:GetStat("Evasion"))
	end
	
	local chanceToDodge = eng.CalculateDodgeChance(chanceToEvade, target:GetStat("DodgeChance"))
	
	local dodgeDice = math.random()
	if dodgeDice > chanceToDodge or isSpell then
		--PHYSICAL MITIGATION
		damageTable.Physical = damageTable.Physical * eng.CalculateArmourMitigation(damageTable.Physical, target:GetStat("Armour"))
		
		--RESISTANCE MITIGATION
		damageTable.Fire = damageTable.Fire * (target:GetStat("FireResistance") + target:GetStat("ElementalResistances"))
		damageTable.Cold = damageTable.Cold * (target:GetStat("ColdResistance") + target:GetStat("ElementalResistances"))
		damageTable.Lightning = damageTable.Lightning * (target:GetStat("LightningResistance") + target:GetStat("ElementalResistances"))
		damageTable.Poison = damageTable.Poison * target:GetStat("PoisonResistance")
		
		eng.TakeDamage(attacker, target, damageTable, targetChar)
	end
end



function eng.TakeDamage(attacker, target, damageTable, targetChar)
	local totalDamage = damageTable.Physical + damageTable.Fire + damageTable.Cold + damageTable.Lightning + damageTable.Poison
	--STUN
	local stunThreshold = attacker:GetStat("ReducedEnemyStunThreshold")
	local stunChance = 200 * (totalDamage / (target:GetStat("MaximumLife") * stunThreshold))
	local stunDur = 0.35 * (attacker:GetStat("IncreasedEnemyStunDuration") - target:GetStat("IncreasedStunAndBlockRecovery"))
	
	local dice = math.random()
	if dice <= stunChance then
		--eng.ApplyStun(attacker, target, stunDur)
	end
	
	--IGNITE
	if damageTable.Fire > 0 then
		local ignChance = attacker:GetStat("ChanceToIgnite")
		local igniteDice = math.random()
		if igniteDice <= ignChance or damageTable.CriticalStrike then
			local igniteDur = 4 * (attacker:GetStat("IncreasedIgniteDuration") + attacker:GetStat("IncreasedSkillEffectDuration"))
			local igniteDPS = (damageTable.Fire * 0.2) * (attacker:GetStat("IncreasedFireDamage") + attacker:GetStat("IncreasedBurningDamage") + attacker:GetStat("IncreasedDamageOverTime"))
			--eng.ApplyIgnite(attacker, target, igniteDur, igniteDPS)
		end
	end
	
	--FREEZE AND CHILL
	if damageTable.Cold > 0 then
		local pctCold = math.floor(mathLib.Clamp(damageTable.Cold / target:GetStat("MaximumLife"), 0, 0.5) * 100)
		local chillDur = pctCold * 0.06
		
		if chillDur >= 0.3 then
			--eng.ApplyChill(attacker, target, chillDur * (attacker:GetStat("IncreasedChillDuration") + attacker:GetStat("IncreasedSkillEffectDuration")))
		end


		local freezeChance = attacker:GetStat("ChanceToFreeze")
		local dice = math.random()
		
		if dice <= freezeChance or damageTable.CriticalStrike then
			if chillDur >= 0.3 then
				--eng.ApplyFreeze(attacker, target, chillDur * (attacker:GetStat("IncreasedFreezeDuration") + attacker:GetStat("IncreasedSkillEffectDuration")))
			end
		end
	end
	
	--SHOCK
	if damageTable.Lightning > 0 then
		local pctLight = math.floor(mathLib.Clamp(damageTable.Lightning / target:GetStat("MaximumLife"), 0, 0.5) * 100)
		local shockDur = pctLight * 0.06
		
		if shockDur >= 0.3 or damageTable.CriticalStrike then
			--eng.ApplyFreeze(attacker, target, shockDur * (attacker:GetStat("IncreasedShockDuration") + attacker:GetStat("IncreasedSkillEffectDuration")))
		end
	end
	
	--POISON
	if damageTable.Poison > 0 then
		local poisonDur = 2 * attacker:GetStat("IncreasedSkillEffectDuration")
		local poisonDPS = ((damageTable.Physical + damageTable.Poison) * 0.08) * (attacker:GetStat("IncreasedDamageOverTime") + attacker:GetStat("IncreasedPoisonDamage"))
		--eng.ApplyPoison(attacker, target, poisonDur, poisonDPS)
	end
	
	target:SetStat("Life", target:GetStat("Life") - totalDamage)
	if target:GetStat("Life") <= 0 then
		print("killed from damage")
		targetChar.Humanoid.Health = 0
		for i = 1, math.ceil(math.random(1, 2) * (1 + attacker:GetStat("IIQ"))) do
			print("forcing an item drop jeez")
			lootLib.DropItem(attacker:GetStat("IIR"), attacker:GetStat("Level"))
		end
		--attacker.AwardKill()
	end
end




function eng.LineOfSight(a, b, dist, ignore)
	local pos1 = tostring(a):match(",") and a or a.Position
	local pos2 = b.Position
	local ray = Ray.new(pos1,(pos2-pos1).unit * dist)
	return workspace:FindPartOnRayWithIgnoreList(ray, ignore) == b
end



function eng.EstimatedPathTime(a, b, ws, fs)
	local dist = (a - b).magnitude
	return (dist / ws) + (fs or PathTimeEstimateFailSafe)
end





return eng