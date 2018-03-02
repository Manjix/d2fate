diarmuid_warrior_charge = class({})

function diarmuid_warrior_charge:CastFilterResultTarget(hTarget)
	local caster = self:GetCaster()
	local target_flag = DOTA_UNIT_TARGET_FLAG_NONE
	local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber())

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

function diarmuid_warrior_charge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if IsSpellBlocked(target) then return end -- Linken effect checker

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff * 100) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
    	DoDamage(caster, v, damage, DAMAGE_TYPE_PHYSICAL, 0, self, false)
	end

	target:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.5})
	caster:PerformAttack(target, true, true, true, true, false, false, false)

	if caster:HasModifier("modifier_doublespear_active") or caster:HasModifier("modifier_rampant_warrior") then 
		local doubleTarget = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(doubleTarget) do
	    	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
		end

		caster:PerformAttack(target, true, true, true, true, false, false, false)
	end

	--particle
	caster:EmitSound("Hero_Huskar.Life_Break")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
end

function diarmuid_warrior_charge:ReduceCooldown()
	local remainingCooldown = self:GetCooldownTimeRemaining()

	if remainingCooldown > 1 then		
		self:EndCooldown()
		self:StartCooldown(math.max(1, remainingCooldown - 1))
	end
end