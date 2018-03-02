sasaki_gatekeeper = class({})

LinkLuaModifier("modifier_gatekeeper", "abilities/sasaki/modifiers/modifier_gatekeeper", LUA_MODIFIER_MOTION_NONE)

function sasaki_gatekeeper:OnSpellStart()
	local caster = self:GetCaster()

	caster:EmitSound("Hero_TemplarAssassin.Refraction")
	caster:RemoveModifierByName("modifier_gatekeeper")

	caster:EmitSound("Sasaki_Gatekeeper_1")

	local gkdummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	local gkdummypassive = gkdummy:FindAbilityByName("dummy_unit_passive")
	gkdummypassive:SetLevel(1)

	local radius = self:GetSpecialValueFor("leash_range")

	local circleFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_circle.vpcf", PATTACH_CUSTOMORIGIN, gkdummy )
	ParticleManager:SetParticleControl( circleFxIndex, 0, gkdummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( circleFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( circleFxIndex, 2, Vector( self:GetSpecialValueFor("duration"), 0, 0 ) )
	ParticleManager:SetParticleControl( circleFxIndex, 3, Vector( 255, 1, 255 ) )

	if caster.IsEyeOfSerenityAcquired then caster.IsEyeOfSerenityActive = true end

	caster:AddNewModifier(caster, self, "modifier_gatekeeper", { Anchor = caster:GetAbsOrigin(),
																 LeashDistance = self:GetSpecialValueFor("leash_range"),
																 BonusAttack = self:GetSpecialValueFor("bonus_damage"),
																 Duration = self:GetSpecialValueFor("duration")--,
																 --EyeOfSerenity = caster.IsEyeOfSerenityAcquired
																 --,
																 --CircleDummy = gkdummy,
																 --CircleFx = circleFxIndex
	})

	Timers:CreateTimer(function()
		if not caster:HasModifier("modifier_gatekeeper") or not caster:IsAlive() then
			ParticleManager:DestroyParticle(circleFxIndex, false)
		    ParticleManager:ReleaseParticleIndex(circleFxIndex)
			gkdummy:RemoveSelf()
			caster.IsEyeOfSerenityActive = false

			return 
		end	

		return 0.25
	end)

	if caster.IsQuickdrawAcquired then 
		caster:SwapAbilities("sasaki_gatekeeper", "sasaki_quickdraw", false, true) 
		Timers:CreateTimer(5, function() return caster:SwapAbilities("sasaki_gatekeeper", "sasaki_quickdraw", true, false) end)
	end

	self:CheckCombo()
end

function sasaki_gatekeeper:CheckCombo()
	local caster = self:GetCaster()
	if caster:GetStrength() >= 24.1 and caster:GetAgility() >= 24.1 
	and caster:FindAbilityByName("sasaki_heart_of_harmony"):IsCooldownReady() 
	and caster:FindAbilityByName("false_assassin_tsubame_mai"):IsCooldownReady() then
		caster:SwapAbilities("sasaki_heart_of_harmony", "false_assassin_tsubame_mai", false, true) 

		Timers:CreateTimer(3.0, function()
			local ability = caster:GetAbilityByIndex(1)
			if (ability:GetName() ~= "sasaki_heart_of_harmony") or not caster:IsAlive() then
				caster:SwapAbilities("sasaki_heart_of_harmony", "false_assassin_tsubame_mai", true, false) 
			end				
		end)
	end
end