modifier_perfect_agony_penalty = class({})

function modifier_perfect_agony_penalty:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_perfect_agony_penalty:GetModifierBaseDamageOutgoing_Percentage()
	if IsServer() then
		return -100
	elseif IsClient() then
        return -100 
	end
end

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