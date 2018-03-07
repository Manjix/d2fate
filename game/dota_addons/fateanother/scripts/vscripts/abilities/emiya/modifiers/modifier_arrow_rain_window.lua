modifier_arrow_rain_window = class({})

function modifier_arrow_rain_window:OnDestroy()
	if IsServer() then
		local hero = self:GetParent()
		hero:FindAbilityByName("emiya_unlimited_bladeworks"):SwitchAbilities(hero:HasModifier("modifier_unlimited_bladeworks"))		
	end
end

function modifier_arrow_rain_window:IsHidden()
	return true
end

function modifier_arrow_rain_window:RemoveOnDeath()
	return true 
end