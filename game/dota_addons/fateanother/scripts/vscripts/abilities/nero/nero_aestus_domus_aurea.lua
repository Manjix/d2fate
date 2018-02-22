nero_aestus_domus_aurea = class({})

LinkLuaModifier("modifier_aestus_domus_aurea_enemy", "abilities/nero/modifiers/modifier_aestus_domus_aurea_enemy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aestus_domus_aurea_ally", "abilities/nero/modifiers/modifier_aestus_domus_aurea_ally", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aestus_domus_aurea_nero", "abilities/nero/modifiers/modifier_aestus_domus_aurea_nero", LUA_MODIFIER_MOTION_NONE)

function nero_aestus_domus_aurea:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local soundQueue = math.random(1,3)

	caster:EmitSound("Nero.NP1." .. soundQueue)

	return true
end

function nero_aestus_domus_aurea:CastFilterResult()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_aestus_domus_aurea_nero") then
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function nero_aestus_domus_aurea:GetCustomCastError()
	return "#Aestus_Domus_is_Active"
end

function nero_aestus_domus_aurea:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	local ability = self	

	Timers:CreateTimer(delay, function()
		if caster:IsAlive() then
			EmitGlobalSound("Nero.NP2.1")
			local radius = ability:GetSpecialValueFor("radius")

			caster.CircleDummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
			caster.CircleDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			
			--ability:DestroyFx()	

			caster.TheatreRingFx = ParticleManager:CreateParticle("particles/custom/nero/nero_domus_ring_border.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.CircleDummy)
			ParticleManager:SetParticleControl(caster.TheatreRingFx, 1, Vector(radius,0,0))	

			caster.BannerTable = ability:CreateBannerInCircle(caster, caster:GetAbsOrigin(), radius)

			local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for i = 1, #enemies do
				if enemies[i]:IsAlive() then
					enemies[i]:AddNewModifier(caster, ability, "modifier_aestus_domus_aurea_enemy", { ResistReduc = ability:GetSpecialValueFor("resist_reduc"),
																									  ArmorReduc = ability:GetSpecialValueFor("armor_reduc"),
																									  MovespeedReduc = ability:GetSpecialValueFor("movespeed_reduc"),
																									  TheatreCenterX = caster:GetAbsOrigin().x,
																									  TheatreCenterY = caster:GetAbsOrigin().y,
																									  TheatreCenterZ = caster:GetAbsOrigin().z,
																									  TheatreSize = radius,
																									  Duration = ability:GetSpecialValueFor("duration")})
				end
			end

			for i = 1, #allies do
				if allies[i]:IsAlive() and allies[i] ~= caster then
					print(allies[i]:GetName())
					allies[i]:AddNewModifier(caster, ability, "modifier_aestus_domus_aurea_ally", { TheatreCenterX = caster:GetAbsOrigin().x,
																									TheatreCenterX = caster:GetAbsOrigin().y,
																									TheatreCenterX = caster:GetAbsOrigin().z,
																									TheatreSize = radius,
																									Duration = ability:GetSpecialValueFor("duration")})
				end
			end

			caster:AddNewModifier(caster, ability, "modifier_aestus_domus_aurea_nero", { Resist = ability:GetSpecialValueFor("resist_reduc") * -1,
																						 Armor = ability:GetSpecialValueFor("armor_reduc") * -1,
																						 Movespeed = ability:GetSpecialValueFor("movespeed_reduc") * -1,
																						 TheatreCenterX = caster:GetAbsOrigin().x,
																						 TheatreCenterY = caster:GetAbsOrigin().y,
																						 TheatreCenterZ = caster:GetAbsOrigin().z,
																					  	 TheatreSize = radius,
																					  	 Duration = ability:GetSpecialValueFor("duration")})
		else 
			return
		end
	end)
end

function nero_aestus_domus_aurea:OnOwnerDied()
	self:DestroyFx()
end

function nero_aestus_domus_aurea:DestroyFx()
	local caster = self:GetCaster()
	if caster.BannerTable ~= nil then
		local banners = caster.BannerTable

		for i=1, #banners do
			banners[i]:RemoveSelf()
		end
	end

	FxDestroyer(caster.TheatreRingFx, false)

	if IsValidEntity(caster.CircleDummy) then
		caster.CircleDummy:RemoveSelf()
	end
end

function nero_aestus_domus_aurea:CreateBannerInCircle(handle, center, multiplier)
	local bannerTable = {}
	for i=1, 8 do
		local x = math.cos(i*math.pi/4) * multiplier
		local y = math.sin(i*math.pi/4) * multiplier
		local banner = CreateUnitByName("nero_banner", Vector(center.x + x, center.y + y, 0), true, nil, nil, handle:GetTeamNumber())

		local diff = (handle:GetAbsOrigin() - banner:GetAbsOrigin())
    	banner:SetForwardVector(diff:Normalized()) 
    	banner.Diff = diff
		table.insert(bannerTable, banner)
	end
	return bannerTable
end