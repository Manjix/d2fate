sasaki_tsubame_gaeshi = class({})

LinkLuaModifier("modifier_exhausted", "abilities/sasaki/modifiers/modifier_exhausted", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ganryu_armor_shred", "abilities/sasaki/modifiers/modifier_ganryu_armor_shred", LUA_MODIFIER_MOTION_NONE)

function sasaki_tsubame_gaeshi:CastFilterResultTarget(hTarget)
	local caster = self:GetCaster()
	local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())

	if(filter == UF_SUCCESS) then
		if hTarget:GetName() == "npc_dota_ward_base" then 
			return UF_FAIL_CUSTOM 
		else
			return UF_SUCCESS
		end
	else
		return filter
	end
end

function sasaki_tsubame_gaeshi:GetCustomCastErrorTarget()
    return "#Invalid_Target"
end

function sasaki_tsubame_gaeshi:OnAbilityPhaseStart()
	local caster = self:GetCaster()	
	local target = self:GetCursorTarget()

	EmitGlobalSound("FA.TGReady")

	local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local firstImpactIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl(firstImpactIndex, 0, caster:GetAbsOrigin() + diff/2)
    ParticleManager:SetParticleControl(firstImpactIndex, 1, Vector(600,0,150))
    ParticleManager:SetParticleControl(firstImpactIndex, 2, Vector(0.4,0,0))

    return true
end

function sasaki_tsubame_gaeshi:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local enhanced = false
	local delay = 0.5
	local delay_per_slash = 0.2
	local split_damage = self:GetSpecialValueFor("damage_split")
	local final_damage = self:GetSpecialValueFor("damage_final")
	local combined_damage = self:GetSpecialValueFor("damage_combined")

	if caster:GetMana() > 99 then
		enhanced = true
	end
	caster:AddNewModifier(caster, self, "modifier_exhausted", { Duration = self:GetSpecialValueFor("exhausted_duration") })

	if caster.IsGanryuAcquired then		
		giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.7)		
		delay = 0.3

		if not enhanced then
			split_damage = split_damage + caster:GetAverageTrueAttackDamage(caster)
			final_damage = final_damage + caster:GetAverageTrueAttackDamage(caster)
		else
			combined_damage = combined_damage + caster:GetAverageTrueAttackDamage(caster) * 3.0
		end
	end

	caster:SetMana(0)
	EmitGlobalSound("FA.TG")

	caster:AddNewModifier(caster, nil, "modifier_phased", {duration = 1.0})
	giveUnitDataDrivenModifier(caster, caster, "dragged", 1.0)
	giveUnitDataDrivenModifier(caster, caster, "revoked", 1.0)

	local particle = ParticleManager:CreateParticle("particles/custom/false_assassin/tsubame_gaeshi/slashes.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 

	Timers:CreateTimer(delay, function()  
		if caster:IsAlive() and target:IsAlive() then
			StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_ATTACK, rate=2})
			if enhanced then
				self:PerformSlash(caster, target, 1, 3)
			else
				self:PerformSlash(caster, target, split_damage, 2)
			end
		else
			ParticleManager:DestroyParticle(particle, true)
		end
	return end)

	delay = delay + delay_per_slash

	Timers:CreateTimer(delay, function()  
		if caster:IsAlive() and target:IsAlive() then
			StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_ATTACK2, rate=2})
			if enhanced then
				self:PerformSlash(caster, target, 1, 3)
			else
				self:PerformSlash(caster, target, split_damage, 2)
			end
		else
			ParticleManager:DestroyParticle(particle, true)
		end
	return end)

	delay = delay + delay_per_slash

	Timers:CreateTimer(delay, function()  
		if caster:IsAlive() and target:IsAlive() then
			StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_ATTACK_EVENT, rate=2})
			if enhanced then				
				self:PerformSlash(caster, target, combined_damage, 1)
				target:AddNewModifier(caster, self, "modifier_stunned", { Duration = 1.5 })
			else
				self:PerformSlash(caster, target, final_damage, 2)
			end
		else
			ParticleManager:DestroyParticle(particle, true)
		end

		target:RemoveModifierByName("modifier_ganryu_armor_shred")
		return 
	end)
end

function sasaki_tsubame_gaeshi:PerformSlash(caster, target, damage, soundQueue)
	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff * 100) 

	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
	ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))

	if soundQueue == 1 then 
		target:EmitSound("Hero_TemplarAssassin.Meld.Attack")
	elseif soundQueue == 2 then
		target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
	else
		target:EmitSound("Hero_Juggernaut.PreAttack")
	end

	if IsSpellBlocked(target) then return end

	if caster.IsGanryuAcquired then
		target:AddNewModifier(caster, self, "modifier_ganryu_armor_shred", { Duration = 1})
		--print(target:GetPhysicalArmorValue())
		DoDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self, false)
	else 
		DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self, false)
	end	
end