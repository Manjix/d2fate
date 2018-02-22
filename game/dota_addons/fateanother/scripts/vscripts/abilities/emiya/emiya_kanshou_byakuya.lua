emiya_kanshou_byakuya = class({})

function emiya_kanshou_byakuya:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local ability = self

	local ply = caster:GetPlayerOwner()
	local forward = ( keys.target_points[1] - caster:GetOrigin() ):Normalized()
	local origin = keys.caster:GetOrigin()
	local target_destination = keys.target_points[1]

	local forwardVec = caster:GetForwardVector()
	local leftVec = Vector(-forwardVec.y, forwardVec.x, 0)
	local rightVec = Vector(forwardVec.y, -forwardVec.x, 0)

	-- Defaults the crossing point to 600 range in front of where Emiya is facing
	if (math.abs(target_destination.x - origin.x) < 500) and (math.abs(target_destination.y - origin.y) < 500) then
		target_destination = caster:GetForwardVector() * 900 + origin
	end

	local lsword_origin = origin + leftVec * 75		-- Set left sword spawn location 75 distance to his left
	--lsword_origin.z = origin.z
	local left_forward = (Vector(target_destination.x, target_destination.y, 0) - lsword_origin):Normalized()
	left_forward.z = origin.z
	local rsword_origin = origin + rightVec * 75	-- and the right sword 75 to his right
	--rsword_origin.z = origin.z
	local right_forward = (Vector(target_destination.x, target_destination.y, 0) - rsword_origin):Normalized()	
	right_forward.z = origin.z

end

function emiya_kanshou_byakuya:FireSword(args)
    local projectileTable = {
        EffectName = keys.Effect,
        Ability = self,
        vSpawnOrigin = keys.Origin,
        vVelocity = keys.Facing * keys.Speed,
        fDistance = keys.Range,
        fStartRadius = keys.AoE,
        fEndRadius = keys.AoE,
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bProvidesVision = false,
    }
    self.bFirstHit = true
    ProjectileManager:CreateLinearProjectile(projectileTable)
end



function emiya_kanshou_byakuya:Dummy()
	local lsword ={
		Ability = keys.ability,
		EffectName = "",
		iMoveSpeed = 1350,
		vSpawnOrigin = lsword_origin,
		fDistance = 900,
		Source = caster,
		fStartRadius = 100,
        fEndRadius = 100,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 3,
		bDeleteOnHit = false,
		vVelocity = left_forward * 1350,
	}

	local rsword = {
		Ability = keys.ability,		
		iMoveSpeed = 1350,
		EffectName = "",
		vSpawnOrigin = rsword_origin,
		fDistance = 900,
		Source = caster,
		fStartRadius = 100,
        fEndRadius = 100,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 3,
		bDeleteOnHit = false,
		vVelocity = right_forward * 1350,
	}

	local bonusSwords = 0
	if caster.IsOveredgeAcquired then
		bonusSwords = 1
	end
	
	-- Fire the projectile left and right swords
	local timeL = 0.05
	for i = 1, 1+bonusSwords do		
		Timers:CreateTimer(timeL, function()
			local lprojectile = ProjectileManager:CreateLinearProjectile( lsword )		
			local projectileDurationL = lsword.fDistance / lsword.iMoveSpeed 
			local dmyLLoc = lsword_origin --+ left_forward * (lsword.fDistance + 50) --Vector(left_forward.x, left_forward.y, 0) * lsword.fDistance
			local dummyL = CreateUnitByName("dummy_unit", dmyLLoc, false, caster, caster, caster:GetTeamNumber())
			dummyL:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummyL:SetForwardVector(left_forward)

			local fxIndex1 = ParticleManager:CreateParticle( "particles/custom/archer/emiya_kb_swords.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummyL )
			ParticleManager:SetParticleControl( fxIndex1, 0, dummyL:GetAbsOrigin() )

			Timers:CreateTimer(function()
				if IsValidEntity(dummyL) then
					dmyLLoc = dmyLLoc + (lsword.iMoveSpeed * 0.05) * Vector(left_forward.x, left_forward.y, 0)
					dummyL:SetAbsOrigin(dmyLLoc)
					--print("still moving")
					return 0.05
				else
					return nil
				end
			end)		

			Timers:CreateTimer(projectileDurationL, function()
				ParticleManager:DestroyParticle( fxIndex1, false )
				ParticleManager:ReleaseParticleIndex( fxIndex1 )			
				Timers:CreateTimer(0.05, function()
					dummyL:RemoveSelf()
					--print("dummy removed....")
					return nil
				end)

				return nil
			end)
		end)
		timeL = timeL + 0.4
		lsword.fDistance = lsword.fDistance + 50
		lsword.fExpireTime = GameRules:GetGameTime() + 3 + timeL
	end

	-- Right Sword
	local timeR = 0.25
	for j = 1, 1+bonusSwords do		
		Timers:CreateTimer(timeR, function()
			local rprojectile = ProjectileManager:CreateLinearProjectile( rsword )	
			local projectileDurationR = rsword.fDistance / rsword.iMoveSpeed 
			local dmyRLoc = rsword_origin --+ right_forward * (rsword.fDistance + 50)
			local dummyR = CreateUnitByName("dummy_unit", dmyRLoc, false, caster, caster, caster:GetTeamNumber())
			dummyR:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummyR:SetForwardVector(right_forward)	

			local fxIndex2 = ParticleManager:CreateParticle( "particles/custom/archer/emiya_kb_swords.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummyR )
			ParticleManager:SetParticleControl( fxIndex2, 0, dummyR:GetAbsOrigin() )

			Timers:CreateTimer(function()
				if IsValidEntity(dummyR) then
					dmyRLoc = dmyRLoc + (lsword.iMoveSpeed * 0.05) * Vector(right_forward.x, right_forward.y, 0)
					--dummyR:GetForwardVector()					
					dummyR:SetAbsOrigin(dmyRLoc)
					return 0.05
				else
					return nil
				end
			end)
			
			Timers:CreateTimer(projectileDurationR, function()
				ParticleManager:DestroyParticle( fxIndex2, false )
				ParticleManager:ReleaseParticleIndex( fxIndex2 )

				Timers:CreateTimer(0.05, function()
				--print("Removing particle and dummy")
					dummyR:RemoveSelf()
					return nil
				end)

				return nil
			end)
		end)

		timeR = timeR + 0.4
		rsword.fDistance = rsword.fDistance + 50
		rsword.fExpireTime = GameRules:GetGameTime() + 3 + timeR
	end

	if caster.IsOveredgeAcquired then
		local stacks = 0

		if caster:HasModifier("modifier_kanshou_byakuya_stock") then
			stacks = caster:GetModifierStackCount("modifier_kanshou_byakuya_stock", keys.ability)
			caster:RemoveModifierByName("modifier_kanshou_byakuya_stock") 		
		end

		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_kanshou_byakuya_stock", {duration=10.0}) 
		if stacks >= 4 then 
			caster:SetModifierStackCount("modifier_kanshou_byakuya_stock", keys.ability, 4)
		else	
			caster:SetModifierStackCount("modifier_kanshou_byakuya_stock", keys.ability, stacks + 1)
		end
	end	
end