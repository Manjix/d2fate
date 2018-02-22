modifier_zabaniya_curse = class({})

function modifier_zabaniya_curse:GetTexture()
	return "custom/true_assassin_zabaniya"
end

function modifier_zabaniya_curse:RemoveOnDeath()
	return true
end

function modifier_zabaniya_curse:IsPermanent()
	return false 
end

function modifier_zabaniya_curse:IsDebuff()
	return true
end

function modifier_zabaniya_curse:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail_circle.vpcf"
end

function modifier_zabaniya_curse:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end