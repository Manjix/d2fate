function StartHeat(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_gawain_heat_radiance",{})

	GawainCheckCombo(caster, ability)
end

function StopSound(keys)
	StopSoundEvent( "Hero_EmberSpirit.FlameGuard.Loop", keys.target )
end

function StackHeatDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local stacks = 0
	local damage = keys.Damage

	if caster.IsBeltAcquired then
		--print("Bob")
		damage = damage + 10
	end

	if target:HasModifier("modifier_gawain_heat_stack_damage") then
		stacks = target:GetModifierStackCount("modifier_gawain_heat_stack_damage", keys.ability)
		target:RemoveModifierByName("modifier_gawain_heat_stack_damage") 		
	end

	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_gawain_heat_stack_damage", {duration=3.0}) 
	target:SetModifierStackCount("modifier_gawain_heat_stack_damage", keys.ability, stacks + 1)

	DoDamage(caster, target, damage * (stacks + 1), DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
	--target:EmitSound("Hero_Phoenix.ColdSnap")
end

function RadianceBurnEnemiesThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage

	--print(damage)
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        DoDamage(caster, v, damage * 0.5, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    end
end

function GawainCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("gawain_heat") 
			and caster:FindAbilityByName("gawain_excalibur_galatine"):IsCooldownReady() 
			and caster:FindAbilityByName("gawain_excalibur_galatine_combo"):IsCooldownReady() 
			and caster:HasModifier("modifier_blade_of_the_devoted")
			then

			caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_combo", false, true) 
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_combo", true, false) 
			end
			})			
		end
	end
end
