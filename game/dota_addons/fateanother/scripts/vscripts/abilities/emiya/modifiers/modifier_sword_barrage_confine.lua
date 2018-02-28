modifier_sword_barrage_confine = class({})

function modifier_sword_barrage_confine:IsDebuff()
	return true 
end

function modifier_sword_barrage_confine:RemoveOnDeath()
	return true
end

function modifier_sword_barrage_confine:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_weave_circle_trace.vpcf"
end

function modifier_sword_barrage_confine:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end