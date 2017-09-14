

	--caster:RemoveModifierByName("modifier_blade_of_the_devoted")
	--GenerateArtificialSun(caster, target:GetAbsOrigin())

	--[[if target:GetTeamNumber() == caster:GetTeamNumber() then
		-- process team effect
		target:SetHealth(target:GetHealth() + keys.Damage + caster:GetAttackDamage())
		if caster.IsSunlightAcquired then
			target:SetMana(target:GetMana() + keys.Damage)
			for i=0, 15 do 
				local ability = target:GetAbilityByIndex(i)
				if ability ~= nil then
					local remainingCD = ability:GetCooldownTimeRemaining()
					ability:EndCooldown()
					ability:StartCooldown(remainingCD-15)
				else 
					break
				end
			end

			--Lower the remaining cooldown duration of the Master 2 (Rin)
			local masterComboAbility = target.MasterUnit2:GetAbilityByIndex(5)									--Get the target's Master's combo ability
			local masterComboCooldownRemaining = masterComboAbility:GetCooldownTimeRemaining()					--Get the remaining cooldown time
			masterComboAbility:EndCooldown()	
			masterComboAbility:StartCooldown(masterComboCooldownRemaining-15)
			--Refreshing the cooldown modifiers, including non-combos.
			for i = 1, #modifierList do
				if target:HasModifier(modifierList[i]) then
					cdRemaining = target:FindModifierByName(modifierList[i]):GetRemainingTime()
					target:RemoveModifierByName(modifierList[i])
					keys.ability:ApplyDataDrivenModifier(caster, target, modifierList[i], {duration = cdRemaining-15})		
				end
			end	
		end
	else]]
	-- process enemy effect
	
	--target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.25})
	--end

	--[[if caster.IsEclipseAcquired then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_blade_of_the_devoted_eclispe",{})
		caster.CurrentDevoteDamage = keys.Damage/2
	end]]