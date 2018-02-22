sasaki_heart_of_harmony = class({})

LinkLuaModifier("modifier_heart_of_harmony", "abilities/sasaki/modifiers/modifier_heart_of_harmony", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_exhausted", "abilities/sasaki/modifiers/modifier_exhausted", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_heart_of_harmony_linger", "abilities/sasaki/modifiers/modifier_heart_of_harmony_linger", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_heart_of_harmony_invis", "abilities/sasaki/modifiers/modifier_heart_of_harmony_invis", LUA_MODIFIER_MOTION_NONE)

function sasaki_heart_of_harmony:OnSpellStart()
	local caster = self:GetCaster()

	caster:SetMana(0)

	if caster.IsVitrificationAcquired then
		caster:RemoveModifierByName("modifier_exhausted")
	end

	caster:EmitSound("Hero_Abaddon.AphoticShield.Cast")
	caster:AddNewModifier(caster, self, "modifier_heart_of_harmony", { Duration = self:GetSpecialValueFor("duration"),
																	   DamageReduc = self:GetSpecialValueFor("damage_reduc"),
																	   ManaRegenBonus = self:GetSpecialValueFor("focus_regen"),
																	   SlashCount = self:GetSpecialValueFor("slash_count"),
																	   Threshold = self:GetSpecialValueFor("threshold"),
																	   StunDuration = self:GetSpecialValueFor("stun_duration"),
																	   ManaThreshold = self:GetSpecialValueFor("stun_threshold")})
	if caster.IsVitrificationAcquired then
		caster:AddNewModifier(caster, self, "modifier_heart_of_harmony_invis", {duration = self:GetSpecialValueFor("duration")})
	end
end

--[[function sasaki_heart_of_harmony:OnTakeDamage()
	local caster = self:GetCaster()
	local target = self:GetAttacker(0)
	local ability = self
	local damageTaken = self:GetSpecialValueFor("attack_damage")
	local threshold = self:GetSpecialValueFor("threshold")

	print("Ability side")

	if damageTaken > threshold and caster:GetHealth() ~= 0 and (caster:GetAbsOrigin()-target:GetAbsOrigin()):Length2D() < 3000 and not target:IsInvulnerable() and caster:GetTeam() ~= target:GetTeam() then

		local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
		local position = target:GetAbsOrigin() - diff*100
		FindClearSpaceForUnit(caster, position, true)		
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = self:GetSpecialValueFor("stun_duration")})

		caster:RemoveModifierByName("modifier_heart_of_harmony")
		caster:RemoveModifierByName("modifier_heart_of_harmony_invisible")

		caster:AddNewModifier(caster, self, "modifier_heart_of_harmony_speed", {duration = 3.0})
		caster:AddNewModifier(caster, self, "modifier_heart_of_harmony_linger", {duration = 0.5})

		caster:AddNewModifier(caster, caster, "modifier_camera_follow", {duration = 1.0})
		-- cooldown
		ReduceCooldown(caster:FindAbilityByName("false_assassin_gate_keeper"), 15)
		ReduceCooldown(caster:FindAbilityByName("false_assassin_windblade"), 15)
		ReduceCooldown(caster:FindAbilityByName("false_assassin_tsubame_gaeshi"), 15)

		local counter = 0
		Timers:CreateTimer(function()
			if counter == keys.AttackCount or not caster:IsAlive() then return end 
			caster:PerformAttack( target, true, true, true, true, false, false, false )
			caster:AddNewModifier(caster, caster, "modifier_camera_follow", {duration = 1.0})
			CreateSlashFx(caster, target:GetAbsOrigin()+RandomVector(500), target:GetAbsOrigin()+RandomVector(500))
			counter = counter+1
			return 0.1
		end)

		local cleanseCounter = 0
		Timers:CreateTimer(function()
			if cleanseCounter >= 10 then return end
			HardCleanse(caster)
			cleanseCounter = cleanseCounter + 1
			return 0.05
		end)


		target:EmitSound("FA.Omigoto")
		EmitGlobalSound("FA.Quickdraw")
	end
end]]