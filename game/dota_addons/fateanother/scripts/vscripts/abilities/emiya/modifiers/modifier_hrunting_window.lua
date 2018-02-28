modifier_hrunting_window = class({})

function modifier_hrunting_window:OnDestroy()
	if IsServer() then
		local hero = self:GetParent()
		hero:FindAbilityByName("emiya_unlimited_bladeworks"):SwitchAbilities(false)
	end
end

function modifier_hrunting_window:IsHidden()
	return true 
end

function modifier_hrunting_window:RemoveOnDeath()
	return true
end