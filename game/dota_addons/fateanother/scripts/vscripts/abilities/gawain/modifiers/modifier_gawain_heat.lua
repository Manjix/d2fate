modifier_gawain_heat = class({})

LinkLuaModifier("modifier_gawain_heat_stack", "abilities/gawain/modifiers/modifier_gawain_heat_stack", LUA_MODIFIER_MOTION_NONE)

function modifier_gawain_heat:OnCreated(args)
	self.BurnDamage = args.BurnDamage
  	self.AttackSpeed = args.AttackSpeed
  	self.StackDamage = args.StackDamage
  	self.Radius = args.Radius

  	if IsServer() then
  		self:StartIntervalThink(0.2)
	end
end

--function modifier_gawain_heat:OnDestroy()
	--self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
--end

function modifier_gawain_heat:GetModifierAttackSpeedBonus_Constant()
	return self.AttackSpeed
end

function modifier_gawain_heat:OnAttackLanded(args)
	local caster = self:GetParent()
	local target = args.target

	if caster ~= args.attacker then return end
	if IsServer() then
		local modifier = target:FindModifierByName("modifier_gawain_heat_stack")
		local damage = self.StackDamage
		local stacks = 0

		if modifier then
			stacks = modifier:GetStackCount()
		end

		damage = damage + (damage * stacks)
		DoDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, 0, self:GetAbility(), false)

		target:AddNewModifier(caster, self:GetAbility(), "modifier_gawain_heat_stack", { Duration = 3.0 })
		target:SetModifierStackCount("modifier_gawain_heat_stack", caster, stacks + 1)
	end
end

function modifier_gawain_heat:DeclareFunctions()
	local Funcs = {	MODIFIER_EVENT_ON_ATTACK_LANDED,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }

	return Funcs
end

function modifier_gawain_heat:OnIntervalThink()	
	local caster = self:GetCaster()

	if caster ~= nil then
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, self.Radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	        DoDamage(caster, v, self.BurnDamage * 0.2, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
	    end
	end
end

function modifier_gawain_heat:IsHidden()
	return false
end

function modifier_gawain_heat:IsPurgable()
	return false
end

function modifier_gawain_heat:IsDebuff()
	return false
end

function modifier_gawain_heat:RemoveOnDeath()
	return true
end

function modifier_gawain_heat:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_gawain_heat:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function modifier_gawain_heat:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_gawain_heat:GetTexture()
	return "custom/gawain_meltdown"
end
