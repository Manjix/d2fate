modifier_doublespear_attribute = class({})

function modifier_doublespear_attribute:IsHidden()
	return true
end

function modifier_doublespear_attribute:IsPermanent()
	return true
end

function modifier_doublespear_attribute:RemoveOnDeath()
	return false
end

function modifier_doublespear_attribute:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end