modifier_perfect_agony_penalty = class({})

--[[function modifier_perfect_agony_penalty:OnCreated(args)
	if IsServer() then
		--local caster = self:GetParent()
		--self.CasterAttackPenalty = caster:GetAverageTrueAttackDamage(caster) * -0.5

		--self:StartIntervalThink(1)
	end
end]]

function modifier_perfect_agony_penalty:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
	--,
	--		 MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_perfect_agony_penalty:GetModifierBaseDamageOutgoing_Percentage()
	if IsServer() then
		--local casterAttack = self.CasterAttackPenalty
		--CustomNetTables:SetTableValue("sync","perfect_agony_penalty", { penalty = casterAttack })

		return -50 --casterAttack 
	elseif IsClient() then
		--local penalty = CustomNetTables:GetTableValue("sync","perfect_agony_penalty").penalty
        return -50 --penalty 
	end
end

--[[function modifier_perfect_agony_penalty:OnAttackLanded()
	if IsServer() then
		local caster = self:GetParent()

		local ability = caster:FindAbilityByName("true_assassin_dirk")
	end
end]]

function modifier_perfect_agony_penalty:IsHidden()
	return false
end

function modifier_perfect_agony_penalty:IsDebuff()
	return false
end

function modifier_perfect_agony_penalty:RemoveOnDeath()
	return false
end

function modifier_perfect_agony_penalty:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_perfect_agony_penalty:GetTexture()
	return "custom/true_assassin_attribute_weakening_venom"
end