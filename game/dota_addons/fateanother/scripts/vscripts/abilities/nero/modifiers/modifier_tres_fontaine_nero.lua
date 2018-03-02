modifier_tres_fontaine_nero = class({})

function modifier_tres_fontaine_nero:OnCreated(args)
	if IsServer() then
		self.DamageOnHit = args.DamageOnHit
		self.PTBAvailable = args.PTBAvailable
		self.Radius = args.Radius
		self.AttackSound = args.AttackSound
		self:StartIntervalThink(0.2)
	end
end

function modifier_tres_fontaine_nero:OnIntervalThink()
	local caster = self:GetParent()
	local target_search = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

	local continue_possible = true

	for i = 1, #target_search do
		if target_search[i]:HasModifier("modifier_tres_target_marker") then
			local diff = target_search[i]:GetAbsOrigin() - caster:GetAbsOrigin()
			caster:SetAbsOrigin(target_search[i]:GetAbsOrigin() - diff:Normalized() * 100)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			
			if self.PTBAvailable then
				caster:PerformAttack(target_search[i], true, true, true, true, false, false, false)
			end

			caster:PerformAttack(target_search[i], true, true, true, true, false, false, false)
			if self.AttackSound then
				caster:EmitSound("Nero_Attack_" .. math.random(1,4))
			end
			StartAnimation(caster, {duration = 0.2, activity = ACT_DOTA_ATTACK, rate = 3})
			DoDamage(caster, target_search[i], self.DamageOnHit, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
			CreateSlashFx(caster, target_search[i]:GetAbsOrigin() + RandomVector(200), target_search[i]:GetAbsOrigin() + RandomVector(200))
			target_search[i]:RemoveModifierByName("modifier_tres_target_marker")
			caster:EmitSound("Hero_EmberSpirit.Attack")
			break
		elseif i == #target_search then
			continue_possible = false
		end
	end

	if not continue_possible then
		self:Destroy()
	end
end

function modifier_tres_fontaine_nero:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()

		caster:RemoveModifierByName("jump_pause")
		caster:RemoveModifierByName("modifier_phased")
	end
end


function modifier_tres_fontaine_nero:IsHidden()
	return true 
end

function modifier_tres_fontaine_nero:RemoveOnDeath()
	return true
end

function modifier_tres_fontaine_nero:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end