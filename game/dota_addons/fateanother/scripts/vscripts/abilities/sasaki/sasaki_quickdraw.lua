sasaki_quickdraw = class({})

LinkLuaModifier("modifier_quickdraw_cd_block", "abilities/sasaki/modifiers/modifier_quickdraw_cd_block", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_quickdraw_empowered_tracker", "abilities/sasaki/modifiers/modifier_quickdraw_empowered_tracker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_exhausted", "abilities/sasaki/modifiers/modifier_exhausted", LUA_MODIFIER_MOTION_NONE)

function sasaki_quickdraw:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local qdProjectile = 
	{
		Ability = ability,
        EffectName = "particles/custom/false_assassin/fa_quickdraw.vpcf",
        iMoveSpeed = 1500,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = 750,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1500
	}

	caster:RemoveModifierByName("modifier_quickdraw_empowered_tracker")

	if caster:GetMana() > 99 then
		caster:AddNewModifier(caster, self, "modifier_quickdraw_empowered_tracker", { Duration = 2 })
	end

	caster:AddNewModifier(caster, self, "modifier_exhausted", { Duration = self:GetSpecialValueFor("exhausted_duration") })

	local projectile = ProjectileManager:CreateLinearProjectile(qdProjectile)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.4)
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	local sin = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*1500)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("quickdraw_dash", {
		endTime = 0.5,
		callback = function()
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("quickdraw_dash")
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	end)
end

function sasaki_quickdraw:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	if hTarget == nil then return end

	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("base_damage") + (caster:GetAverageTrueAttackDamage(caster) * self:GetSpecialValueFor("atk_ratio") / 100)
	DoDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)

	if caster:HasModifier("modifier_quickdraw_empowered_tracker") then
		local counter = 0
		local slashcount = self:GetSpecialValueFor("focus_attacks")
		Timers:CreateTimer(function()
			if counter == slashcount or not caster:IsAlive() then return end 
			caster:PerformAttack( hTarget, true, true, true, true, false, false, false )
			CreateSlashFx(caster, hTarget:GetAbsOrigin() + RandomVector(500), hTarget:GetAbsOrigin() + RandomVector(500))
			counter = counter + 1
			--target:EmitSound("soundname")
			return 0.1
		end)
	end

	if not caster:HasModifier("modifier_quickdraw_cd_block") and caster:HasModifier("modifier_quickdraw_empowered_tracker") then
		for i = 0, 5 do
			local ability = caster:GetAbilityByIndex(i)
			local remainingCooldown = ability:GetCooldownTimeRemaining()
			if not ability:IsCooldownReady() then
				ability:EndCooldown()
				ability:StartCooldown(remainingCooldown * (self:GetSpecialValueFor("focus_cdr") / 100))
			end
		end
	end

	caster:AddNewModifier(caster, self, "modifier_quickdraw_cd_block", {Duration = 2 })

	local firstImpactIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl(firstImpactIndex, 0, hTarget:GetAbsOrigin())
    ParticleManager:SetParticleControl(firstImpactIndex, 1, Vector(800,0,150))
    ParticleManager:SetParticleControl(firstImpactIndex, 2, Vector(0.3,0,0))
end