modifier_gae_buidhe = class({})

function modifier_gae_buidhe:OnCreated(args)
	if IsServer() then
		self:SetStackCount(args.StackCount)
		self:StartIntervalThink(0.03)
	end
end

function modifier_gae_buidhe:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local max_health = target:GetMaxHealth() - (10 * self:GetStackCount())

		if target:GetHealth() > max_health then
			target:SetHealth(max_health)
		end
	end
end

function modifier_gae_buidhe:OnDestroy()
	self:StartIntervalThink(-1)
end

function modifier_gae_buidhe:IsHidden()
	return false
end

function modifier_gae_buidhe:IsDebuff()
	return true
end

function modifier_gae_buidhe:RemoveOnDeath()
	return true
end

function modifier_gae_buidhe:IsPurgable()
	return false
end

function modifier_gae_buidhe:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_gae_buidhe:GetTexture()
	return "custom/diarmuid_gae_buidhe"
end
