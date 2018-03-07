nero_rosa_ichthys = class({})

LinkLuaModifier("modifier_rosa_slow", "abilities/nero/modifiers/modifier_rosa_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rosa_buffer", "abilities/nero/modifiers/modifier_rosa_buffer", LUA_MODIFIER_MOTION_NONE)

function nero_rosa_ichthys:GetCastRange(vLocation, hTarget)
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_aestus_domus_aurea_nero") then
		return self:GetSpecialValueFor("aestus_range")
	else
		return self:GetSpecialValueFor("range")
	end
end

function nero_rosa_ichthys:CastFilterResultTarget(hTarget)
	local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())

	if(filter == UF_SUCCESS) then
		if hTarget:GetName() == "npc_dota_ward_base" then 
			return UF_FAIL_CUSTOM 
		else
			return UF_SUCCESS
		end
	else
		return filter
	end
end

function nero_rosa_ichthys:GetCustomCastError()
    return "#Invalid_Target"
end

function nero_rosa_ichthys:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_aestus_domus_aurea_nero") and caster:HasModifier("modifier_sovereign_attribute") then
		return self:GetSpecialValueFor("aestus_cooldown")
	else
		return self:GetSpecialValueFor("cooldown")
	end
end

function nero_rosa_ichthys:GetManaCost(iLevel)
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_aestus_domus_aurea_nero") then
		return 100
	else
		return 400
	end
end

function nero_rosa_ichthys:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	--caster:EmitSound("Nero.Skill1")

	return true
end

function nero_rosa_ichthys:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetSpecialValueFor("damage")

	local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
	caster:EmitSound("Nero.Skill1")
	CreateSlashFx(caster, caster:GetAbsOrigin(), caster:GetAbsOrigin() + diff:Normalized() * diff:Length2D())
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff:Normalized() * 100)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	StartAnimation(caster, {duration = 0.4, activity = ACT_DOTA_ATTACK_EVENT, rate = 3})	
	caster:MoveToTargetToAttack(target)

	if IsSpellBlocked(target) then return end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
	if not target:HasModifier("modifier_rosa_buffer") then
		target:AddNewModifier(caster, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("stun_duration") })
	--else
	--	target:AddNewModifier(caster, self, "modifier_stunned", {Duration = 0.05 })
	end
	
	
	target:EmitSound("Hero_Lion.FingerOfDeath")

	if caster:HasModifier("modifier_ptb_attribute") then
		target:AddNewModifier(caster, target, "modifier_rosa_slow", {Duration = 3})
	end

	local slashFx = ParticleManager:CreateParticle("particles/custom/nero/nero_scorched_earth_child_embers_rosa.vpcf", PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl( slashFx, 0, target:GetAbsOrigin() + Vector(0,0,300))

	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( slashFx, false )
		ParticleManager:ReleaseParticleIndex( slashFx )
	end)

	if caster:HasModifier("modifier_sovereign_attribute") and caster:HasModifier("modifier_aestus_domus_aurea_nero") then               
        if not target:HasModifier("modifier_rosa_buffer") then
        	target:AddNewModifier(caster, self, "modifier_rosa_buffer", { Duration = 5 })
        end
    end

    -- Too dumb to make particles, just call cleave function 4head
    DoCleaveAttack(caster, target, self, 0, 200, 400, 500, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf")

    self.Target = target

    local slash = 
	{
		Ability = self,
        EffectName = "",
        iMoveSpeed = 99999,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 500,
        fStartRadius = 200,
        fEndRadius = 400,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 500
	}

	local projectile = ProjectileManager:CreateLinearProjectile(slash)
end

function nero_rosa_ichthys:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	if hTarget == nil or hTarget == self.Target then return end

	local damage = self:GetSpecialValueFor("damage")
	local caster = self:GetCaster()

	if not caster.IsPTBAcquired then
		damage = damage / 2
	end

	DoDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
	hTarget:AddNewModifier(caster, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("stun_duration") })
	--hTarget:AddNewModifier(caster, self, "modifier_rosa_buffer", { Duration = 5 })
end