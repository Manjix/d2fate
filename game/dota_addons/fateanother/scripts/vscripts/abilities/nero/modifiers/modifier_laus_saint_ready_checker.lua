modifier_laus_saint_ready_checker = class({})

function modifier_laus_saint_ready_checker:IsHidden()
	return true 
end

function modifier_laus_saint_ready_checker:OnCreated(args)
	if IsServer() then
		local caster = self:GetParent()

		if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
	    	if caster:FindAbilityByName("nero_laus_saint_claudius"):IsCooldownReady() and caster:IsAlive() then	    		
	    		caster:SwapAbilities("nero_laus_saint_claudius", "nero_aestus_domus_aurea", true, false)	    		
	    	end
	    end
	end
end

function modifier_laus_saint_ready_checker:OnRefresh(args)
	self:OnCreated(args)
end

function modifier_laus_saint_ready_checker:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()

		if caster:GetAbilityByIndex(5):GetName() ~= "nero_aestus_domus_aurea" then
			caster:SwapAbilities("nero_laus_saint_claudius", "nero_aestus_domus_aurea", false, true)
		end
	end
end

function modifier_laus_saint_ready_checker:RemoveOnDeath()
	return true
end

function modifier_laus_saint_ready_checker:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end