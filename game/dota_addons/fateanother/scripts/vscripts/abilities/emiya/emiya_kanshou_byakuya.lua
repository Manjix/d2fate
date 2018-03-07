emiya_kanshou_byakuya = class({})

LinkLuaModifier("modifier_overedge_attribute", "abilities/emiya/modifiers/modifier_overedge_attribute", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overedge_charge", "abilities/emiya/modifiers/modifier_overedge_charge", LUA_MODIFIER_MOTION_NONE)

function emiya_kanshou_byakuya:OnSpellStart()
	local caster = self:GetCaster()
	local target_destination = self:GetCursorPosition()
	local ability = self
	local bonusSwords = 0

	local ply = caster:GetPlayerOwner()
	local forward = (target_destination - caster:GetOrigin()):Normalized()
	local origin = caster:GetOrigin()

	local forwardVec = caster:GetForwardVector()
	local leftVec = Vector(-forwardVec.y, forwardVec.x, 0)
	local rightVec = Vector(forwardVec.y, -forwardVec.x, 0)

	-- Defaults the crossing point to 600 range in front of where Emiya is facing
	if (math.abs(target_destination.x - origin.x) < 500) and (math.abs(target_destination.y - origin.y) < 500) then
		target_destination = caster:GetForwardVector() * 900 + origin
	end

	local lsword_origin = origin + leftVec * 75	
	local left_forward = (Vector(target_destination.x, target_destination.y, 0) - lsword_origin):Normalized()
	left_forward.z = origin.z
	local rsword_origin = origin + rightVec * 75	
	local right_forward = (Vector(target_destination.x, target_destination.y, 0) - rsword_origin):Normalized()	
	right_forward.z = origin.z

	if caster:HasModifier("modifier_overedge_attribute") then
		bonusSwords = 1
	end

	local timeL = 0.05
	for i = 1, 1 + bonusSwords do		
		Timers:CreateTimer(timeL, function()
			self:FireSword(lsword_origin, left_forward)
			local projectileDurationL = 900 / 1350
			local dmyLLoc = lsword_origin 
			local dummyL = CreateUnitByName("dummy_unit", dmyLLoc, false, caster, caster, caster:GetTeamNumber())
			dummyL:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummyL:SetForwardVector(left_forward)

			local fxIndex1 = ParticleManager:CreateParticle( "particles/custom/archer/emiya_kb_swords.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummyL )
			ParticleManager:SetParticleControl( fxIndex1, 0, dummyL:GetAbsOrigin() )

			Timers:CreateTimer(function()
				if IsValidEntity(dummyL) then
					dmyLLoc = dmyLLoc + (1350 * 0.05) * Vector(left_forward.x, left_forward.y, 0)
					dummyL:SetAbsOrigin(GetGroundPosition(dmyLLoc, nil))
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
					return nil
				end)

				return nil
			end)
		end)
		timeL = timeL + 0.4		
	end

	-- Right Sword
	local timeR = 0.25
	for j = 1, 1 + bonusSwords do		
		Timers:CreateTimer(timeR, function()
			self:FireSword(rsword_origin, right_forward)
			local projectileDurationR = 900 / 1350
			local dmyRLoc = rsword_origin 
			local dummyR = CreateUnitByName("dummy_unit", dmyRLoc, false, caster, caster, caster:GetTeamNumber())
			dummyR:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummyR:SetForwardVector(right_forward)	

			local fxIndex2 = ParticleManager:CreateParticle( "particles/custom/archer/emiya_kb_swords.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummyR )
			ParticleManager:SetParticleControl( fxIndex2, 0, dummyR:GetAbsOrigin() )

			Timers:CreateTimer(function()
				if IsValidEntity(dummyR) then
					dmyRLoc = GetGroundPosition(dmyRLoc + (1350 * 0.05) * Vector(right_forward.x, right_forward.y, 0), nil)								
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
					dummyR:RemoveSelf()
					return nil
				end)
				return nil
			end)
		end)

		timeR = timeR + 0.4		
	end

	self:CheckOveredge()	
end

function emiya_kanshou_byakuya:FireSword(origin, forwardVec)
	local aoe = self:GetSpecialValueFor("sword_aoe")
	local range = self:GetSpecialValueFor("range")	

	forwardVec = GetGroundPosition(forwardVec, nil)

    local projectileTable = {
		Ability = self,
		--EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		iMoveSpeed = 1350,
		vSpawnOrigin = origin,
		fDistance = range,
		Source = self:GetCaster(),
		fStartRadius = aoe,
        fEndRadius = aoe,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 3,
		bDeleteOnHit = false,
		vVelocity = forwardVec * 1350,
	}

    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)

    self:GetCaster():EmitSound("Hero_Luna.Attack")
end

function emiya_kanshou_byakuya:CheckOveredge()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_overedge_attribute") then
		local stacks = caster:GetModifierStackCount("modifier_overedge_charge", self) or 0
		caster:AddNewModifier(caster, self, "modifier_overedge_charge", { Duration = self:GetSpecialValueFor("overedge_duration"),
																		  OnHitDamage = self:GetSpecialValueFor("overedge_damage"),
																		  ChargeAttackSpeed = self:GetSpecialValueFor("overedge_aspd") })
	end	
end

function emiya_kanshou_byakuya:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	if hTarget == nil then return end

	local caster = self:GetCaster()
	local KBHitFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(KBHitFx, 0, hTarget:GetAbsOrigin()) 
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( KBHitFx, false )
		ParticleManager:ReleaseParticleIndex( KBHitFx )
	end)

	DoDamage(caster, hTarget, self:GetSpecialValueFor("damage"), DAMAGE_TYPE_MAGICAL, 0, self, false)
	hTarget:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
end