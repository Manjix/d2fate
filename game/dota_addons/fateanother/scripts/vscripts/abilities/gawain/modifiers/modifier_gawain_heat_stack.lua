modifier_gawain_heat_stack = class({})

function modifier_gawain_heat_stack:IsHidden()
	return true
end

function modifier_gawain_heat_stack:IsPurgable()
	return false
end

function modifier_gawain_heat_stack:IsDebuff()
	return true
end

function modifier_gawain_heat_stack:RemoveOnDeath()
	return true
end

function modifier_gawain_heat_stack:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end