modifier_heracles_berserk = class({})

if IsServer() then
	function modifier_heracles_berserk:OnCreated(args)
		self.LockedHealth = args.LockedHealth
		self:GetParent():SetRenderColor(255, 127, 127)
		self:StartIntervalThink(0.033)
	end

	function modifier_heracles_berserk:OnRefresh(args)
		self:OnCreated(args)
	end

	function modifier_heracles_berserk:OnDestroy()
		self:GetParent():SetRenderColor(255, 255, 255)
	end

	function modifier_heracles_berserk:OnIntervalThink()
		local parent = self:GetParent()

		parent:RemoveModifierByName("modifier_zabaniya_curse")

		if parent:HasModifier("modifier_gae_buidhe") then
			local stacks = parent:GetModifierStackCount("modifier_gae_buidhe", self:GetAbility())
			if parent:GetMaxHealth() - (stacks * 10) < self.LockedHealth then
				self.LockedHealth = parent:GetMaxHealth() - (stacks * 10) 
			end
		end

		parent:SetHealth(self.LockedHealth)
	end
end

function modifier_heracles_berserk:RemoveOnDeath()
	return true 
end

function modifier_heracles_berserk:GetTexture()
	return "custom/berserker_5th_berserk"
end

function modifier_heracles_berserk:GetEffectName()
	return "particles/custom/berserker/berserk/buff.vpcf"
end

function modifier_heracles_berserk:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end