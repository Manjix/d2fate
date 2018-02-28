diarmuid_gae_buidhe =  class({})

function diarmuid_gae_buidhe:CastFilterResultTarget(hTarget)
end

function diarmuid_gae_buidhe:GetCastRange(vLocation, hTarget)
end

function diarmuid_gae_buidhe:OnAbilityPhaseStart()
	return true
end

function diarmuid_gae_buidhe:OnSpellStart()
	local ability = keys.ability
	local caster = keys.caster
	local target = self:GetCursorTarget()
	local ply = caster:GetPlayerOwner()
	local nStacks = keys.nStacks
	local unitReduction = 10
	local currentStack = target:GetModifierStackCount("modifier_gae_buidhe", ability)

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	if caster:HasModifier("modifier_rampant_warrior_combo") then
		ability:EndCooldown()
		ability:RefundManaCost()
		local modifier = caster:FindModifierByName("modifier_rampant_warrior_combo")
		local RWDuration = modifier:GetRemainingTime()
		local RW = caster:FindAbilityByName("diarmuid_rampant_warrior")
		local DurationPenalty = RW:GetSpecialValueFor("duration_penalty")
		caster:RemoveModifierByName("modifier_rampant_warrior_combo")
		caster:RemoveModifierByName("modifier_rampant_warrior")
		caster:FindAbilityByName("diarmuid_double_spearsmanship"):ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior_combo", {duration = RWDuration - DurationPenalty})
		caster:FindAbilityByName("diarmuid_rampant_warrior"):ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior", {duration = RWDuration - DurationPenalty})
	end

	local healthDiff = target:GetHealth()
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	healthDiff = healthDiff - target:GetHealth()
	nStacks = math.ceil(healthDiff / 10)	

	if target:GetHealth() > 0 and target:IsAlive() and caster:IsAlive() then	
		if caster.IsGoldenRoseAcquired then 
			target:AddNewModifier(caster, ability, "modifier_golden_rose", {Duration = ability:GetSpecialValueFor("bleed_duration")})
		end	
		target:RemoveModifierByName("modifier_gae_buidhe") 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_gae_buidhe", {}) 
		target:SetModifierStackCount("modifier_gae_buidhe", ability, currentStack + nStacks)
		if target:IsRealHero() then target:CalculateStatBonus() end
	end

	currentStack = target:GetModifierStackCount("modifier_gae_buidhe", ability) --refresh currentstack after debuff

  	if target:GetMaxHealth() < currentStack * unitReduction then -- for heroes that modifies maxHp like avenger with E
		target:Execute(ability, caster)
	elseif target:GetHealth() > (target:GetMaxHealth() - currentStack * unitReduction) then
		target:SetHealth(target:GetMaxHealth() - currentStack * unitReduction)
	end

	Timers:CreateTimer(function()
		if not target:HasModifier("modifier_gae_buidhe") then return end
		-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_symbol.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  --   	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() )
  		if target:GetMaxHealth() < currentStack * unitReduction then -- for heroes that modifies maxHp like avenger with E
			target:Execute(ability, caster)
		elseif target:GetHealth() > (target:GetMaxHealth() - currentStack * unitReduction) then
			target:SetHealth(target:GetMaxHealth() - currentStack * unitReduction)
		end
		return 0.033
		end
	)

	EmitGlobalSound("ZL.Gae_Buidhe")
	target:EmitSound("Hero_Lion.Impale")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_diarmuid_gae_buidhe_anim", {})
	PlayGaeEffect(target)
	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/custom/diarmuid/diarmuid_gae_buidhe.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:ReleaseParticleIndex( dagon_particle )
	end)

	if caster.IsDoubleSpearAcquired then
		local Duration = caster.MasterUnit2:FindAbilityByName("diarmuid_attribute_double_spear_strike"):GetSpecialValueFor("duration")
		caster:AddNewModifier(caster, caster, "modifier_doublespear_buidhe", {duration = Duration})
		caster:RemoveModifierByName("modifier_doublespear_dearg")
	end

	ability:SetOverrideCastPoint(keys.CastTime)
end