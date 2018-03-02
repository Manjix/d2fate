cu_chulain_stab_bolg = class({})

function cu_chulain_stab_bolg:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin())

	Timers:CreateTimer(1.5, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)

	caster:EmitSound("Lancer.GaeBolg")

	return true
end

function cu_chulain_stab_bolg:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	local damage = self:GetSpecialValueFor("damage")
	local hbThreshold = self:GetSpecialValueFor("heart_break")

	if IsSpellBlocked(target) then return end -- Linken effect checker
	
	if caster:HasModifier("modifier_heartseeker_attribute") then 
		local bonus_threshold = (caster:GetAttackDamage() * self:GetSpecialValueFor("bns_hbk_pct"))
		hbThreshold = hbThreshold + caster:GetAttackDamage() * ATTR_HEARTSEEKER_AD_RATIO 
	end

	giveUnitDataDrivenModifier(caster, target, "can_be_executed", 0.033)
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})

	if target:GetHealth() < keys.HBThreshold then
		PlayHeartBreakEffect(ability, caster, target)
	end  -- check for HB

	
	StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=3})
	
	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	target:EmitSound("Hero_Lion.Impale")
	PlayNormalGBEffect(target)
	-- Blood splat
	local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)

	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:DestroyParticle( splat, false )
	end)

	target:Execute(ability, killer, { bExecution = true })
end

function cu_chulain_stab_bolg:CreateStabFx(target)
	local culling_kill_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(culling_kill_particle)

	local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break_txt.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())

	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( culling_kill_particle, false )
		ParticleManager:DestroyParticle( hb, false )
	end)	
end