true_assassin_selfmod = class({})

LinkLuaModifier("modifier_true_assassin_selfmod", "abilities/true_assassin/modifiers/modifier_true_assassin_selfmod", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_selfmod_agility", "abilities/true_assassin/modifiers/modifier_selfmod_agility", LUA_MODIFIER_MOTION_NONE)

function true_assassin_selfmod:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local fHeal = self:GetSpecialValueFor("heal_amount")

	caster:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
	caster:Heal(fHeal, caster)
	caster:AddNewModifier(caster, ability, "modifier_true_assassin_selfmod", {	Duration = self:GetSpecialValueFor("duration"),
																			 	HealAmt = self:GetSpecialValueFor("actual_heal_over_time"),
																			 	BonusStats = self:GetSpecialValueFor("bonus_stats")
																			 })

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	-- Destroy particle after delay
	Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
			return nil
	end)

	if caster.ShaytanArmAcquired then
		local casterStr = math.ceil(caster:GetStrength()) 
		local casterAgi = math.ceil(caster:GetAgility())
		local casterInt = math.ceil(caster:GetIntellect())

		if casterStr == casterAgi and casterStr == casterInt then
			--print("Tied Mod")
			self:ReduceZabaniyaCooldown(true)
			if not caster.IsWeakeningVenomAcquired then
				caster:AddNewModifier(caster, ability, "modifier_selfmod_agility", { Duration = self:GetSpecialValueFor("duration"),
																					 AttackBonus = casterAgi
																					})
			end
			caster:Heal(casterInt * 6.5, caster)
			caster:GiveMana(casterInt * 6.5)
		elseif casterStr >= casterAgi and casterStr >= casterInt then
			--print("Strength Highest Mod")
			self:ReduceZabaniyaCooldown(false)
		elseif casterAgi > casterStr and casterAgi >= casterInt then
			--print("Agi Highest Mod")
			if not caster.IsWeakeningVenomAcquired then
				caster:AddNewModifier(caster, ability, "modifier_selfmod_agility", { Duration = self:GetSpecialValueFor("duration"),
																					 AttackBonus = casterAgi * 2
																					 })
			end
		elseif casterInt > casterStr and casterInt > casterAgi then
			--print("Int Highest Mod")
			caster:Heal(casterInt * 13, caster)
			caster:GiveMana(casterInt * 13)		
		end
	end
end

function true_assassin_selfmod:ReduceZabaniyaCooldown(halfEfficiency)
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("true_assassin_zabaniya")
	local cooldownPerStr = 0.5
	local casterStr = math.floor(caster:GetStrength()) 

	if halfEfficiency then cooldownPerStr = 0.25 end

	if not ability:IsCooldownReady() then
		local cooldown = ability:GetCooldownTimeRemaining()
		cooldown = cooldown - casterStr * cooldownPerStr
		ability:EndCooldown()
		if cooldown > 0 then
			ability:StartCooldown(cooldown)
		end
	end
end