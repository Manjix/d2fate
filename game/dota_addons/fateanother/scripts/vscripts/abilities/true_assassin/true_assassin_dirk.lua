true_assassin_dirk = class({})

LinkLuaModifier("modifier_dirk_poison", "abilities/true_assassin/modifiers/modifier_dirk_poison", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weakening_venom", "abilities/true_assassin/modifiers/modifier_weakening_venom", LUA_MODIFIER_MOTION_NONE)

function true_assassin_dirk:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	local maxTarget = self:GetSpecialValueFor("max_target")

	--if IsSpellBlocked(keys.target) then return end

	local range = caster:GetRangeToUnit(target) + 200

	caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")
	
	local info = {
		Target = target,
		Source = caster, 
		Ability = ability,
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1800
	}
	ProjectileManager:CreateTrackingProjectile(info) 

	local targetCount = 1
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, range
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		--if v:CanEntityBeSeenByMyTeam(caster) then
		if v ~= target then
			targetCount = targetCount + 1
	        info.Target = v
	        ProjectileManager:CreateTrackingProjectile(info)
	    end 

        if targetCount == maxTarget then return end
    end
end

function true_assassin_dirk:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
    if hTarget == nil then
        return 
    end
    local ability = self
    local hCaster = self:GetCaster()
    local fDamage = self:GetSpecialValueFor("damage") 
    local fPoisonDamage = self:GetSpecialValueFor("poison_dot")
    
    if IsSpellBlocked(hTarget) then return end

    if not hCaster.IsWeakeningVenomAcquired then
    	fDamage = fDamage + (hCaster:GetAverageTrueAttackDamage(hCaster) * 0.75)    	
    else
    	fPoisonDamage = fPoisonDamage + (math.ceil(hCaster:GetAgility()) * 0.5)
    end

    hTarget:AddNewModifier(hCaster, ability, "modifier_dirk_poison", {	Duration = self:GetSpecialValueFor("duration"),
																		PoisonDamage = fPoisonDamage,
																		PoisonSlow = self:GetSpecialValueFor("poison_slow") })
    hTarget:EmitSound("Hero_PhantomAssassin.Dagger.Target")

	DoDamage(hCaster, hTarget, fDamage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)

	local stacks = 0
	if hTarget:HasModifier("modifier_weakening_venom") then 
		stacks = hTarget:GetModifierStackCount("modifier_weakening_venom", ability)
	end		

	hTarget:RemoveModifierByName("modifier_weakening_venom") 
	hTarget:AddNewModifier(hCaster, ability, "modifier_weakening_venom", { duration = 12 })	

	if hCaster.IsWeakeningVenomAcquired then
		hTarget:SetModifierStackCount("modifier_weakening_venom", ability, stacks + self:GetSpecialValueFor("venom_stacks"))
	else
		hTarget:SetModifierStackCount("modifier_weakening_venom", ability, stacks + 1)
	end
end