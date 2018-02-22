modifier_weakening_venom = class({})

function modifier_weakening_venom:OnCreated(table)
	self:SetStackCount(table.PoisonStackCount)
end

function modifier_weakening_venom:OnRefresh(table)
	Self:OnCreated(table)
end

function modifier_weakening_venom:GetAttributes()
  return MODIFIER_ATTRIBUTE_NONE
end

function modifier_weakening_venom:IsDebuff()
	return true 
end

function modifier_weakening_venom:RemoveOnDeath()
	return true 
end

function modifier_weakening_venom:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_poison_debuff.vpcf"
end

function modifier_calydonian_hunt:GetTexture()
    return "custom/true_assassin_dirk"
end

function modifier_weakening_venom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end