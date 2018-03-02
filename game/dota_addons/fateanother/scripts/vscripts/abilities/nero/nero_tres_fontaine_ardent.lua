nero_tres_fontaine_ardent = class({})

LinkLuaModifier("modifier_tres_target_marker", "abilities/nero/modifiers/modifier_tres_target_marker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tres_fontaine_nero", "abilities/nero/modifiers/modifier_tres_fontaine_nero", LUA_MODIFIER_MOTION_NONE)

function nero_tres_fontaine_ardent:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_aestus_domus_aurea_nero") and caster:HasModifier("modifier_sovereign_attribute") then
		return self:GetSpecialValueFor("aestus_cooldown")
	else
		return self:GetSpecialValueFor("cooldown")
	end
end

function nero_tres_fontaine_ardent:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function nero_tres_fontaine_ardent:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local ability = self
	local damage = self:GetSpecialValueFor("damage")
	local delay = 0.2

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
			
	local soundType = math.random(1,2)
	local doSound = true
	if soundType == 1 then
		caster:EmitSound("Nero_Skill_" .. math.random(1,4))
		doSound = false
	end

	for i = 1, #targets do
		targets[i]:AddNewModifier(caster, ability, "modifier_tres_target_marker", { Duration = delay + 2})
		--[[Timers:CreateTimer(delay, function()
			if targets[i]:IsAlive() and targets[i]:GetName() ~= "npc_dota_ward_base" and caster:IsAlive() then
				caster:SetAbsOrigin(targets[i]:GetAbsOrigin() - targets[i]:GetForwardVector():Normalized() * 100)
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
				
				if caster.IsPTBAcquired then
					caster:PerformAttack(targets[i], true, true, true, true, false, false, false)
				end

				caster:PerformAttack(targets[i], true, true, true, true, false, false, false)
				if soundType == 2 then
					caster:EmitSound("Nero_Attack_" .. math.random(1,4))
				end
				StartAnimation(caster, {duration = 0.2, activity = ACT_DOTA_ATTACK, rate = 3})
				DoDamage(caster, targets[i], damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				CreateSlashFx(caster, targets[i]:GetAbsOrigin() + RandomVector(200), targets[i]:GetAbsOrigin() + RandomVector(200))
				targets[i]:RemoveModifierByName("modifier_tres_target_marker")
				caster:EmitSound("Hero_EmberSpirit.Attack")
			
			end

			return
		end)]]
		delay = delay + 0.2
	end

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", delay)
	caster:AddNewModifier(caster, nil, "modifier_phased", {duration = delay})

	caster:AddNewModifier(caster, ability, "modifier_tres_fontaine_nero", { Duration = delay,
																			DamageOnHit = self:GetSpecialValueFor("damage"),
																			PTBAvailable = caster:HasModifier("modifier_ptb_attribute"),
																			Radius = self:GetSpecialValueFor("max_range"),
																			AttackSound = doSound })

	--[[if caster.IsGloryAcquired and caster:HasModifier("modifier_aestus_domus_aurea_nero") then
		self:EndCooldown()
        self:StartCooldown(1)
    end]]
end