emiya_hrunting = class({})

function emiya_hrunting:GetCastRange(vLocation, hTarget)
    --if  then
    return self:GetSpecialValueFor("cast_range") + ((self:GetCaster().IsEagleEyeAcquired and self:GetSpecialValueFor("bonus_range")) or 0) 
end

function emiya_hrunting:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function emiya_hrunting:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local hPlayer = hCaster:GetPlayerOwner()
    self.hTarget = hTarget

    self:EndCooldown()
    hCaster:GiveMana(self:GetManaCost(-1))

    self.pcMarker = ParticleManager:CreateParticleForTeam("particles/custom/archer/archer_broken_phantasm/archer_broken_phantasm_crosshead.vpcf", PATTACH_OVERHEAD_FOLLOW, hTarget, hCaster:GetTeamNumber())
    ParticleManager:SetParticleControl(self.pcMarker, 0, hTarget:GetAbsOrigin() + Vector(0,0,100)) 
    ParticleManager:SetParticleControl(self.pcMarker, 1, hTarget:GetAbsOrigin() + Vector(0,0,100))

    self.hrunting_particle = ParticleManager:CreateParticle( "particles/econ/events/ti4/teleport_end_ti4.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster )
    ParticleManager:SetParticleControl( hCaster.hrunting_particle, 2, Vector( 255, 0, 0 ) )
    ParticleManager:SetParticleControlEnt(hCaster.hrunting_particle, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", hCaster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(hCaster.hrunting_particle, 3, hCaster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", hCaster:GetAbsOrigin(), true)

    if IsValidEntity(hPlayer) and not hPlayer:IsNull() then
        if hTarget:IsHero()then
            Say(hPlayer, "Hrunting targets " .. FindName(hTarget:GetName()) .. ".", true)
        end
    end
end

function emiya_hrunting:OnChannelFinish(bInterrupted)
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local hPlayer = hCaster:GetPlayerOwner()

    ParticleManager:DestroyParticle(self.pcMarker, false)
    ParticleManager:ReleaseParticleIndex(self.pcMarker)
    ParticleManager:DestroyParticle(self.hrunting_particle, false)
    ParticleManager:ReleaseParticleIndex(self.hrunting_particle)

    if IsValidEntity(hPlayer) and not hPlayer:IsNull() then
        if bInterrupted or not hCaster:CanEntityBeSeenByMyTeam(hTarget) or hCaster:GetRangeToUnit(hTarget) > 4500 or hCaster:GetMana() < self:GetManaCost(-1) or not IsInSameRealm(hCaster:GetAbsOrigin(), hTarget:GetAbsOrigin()) then 
            Say(hPlayer, "Hrunting failed.", true)
            return
        end
    end

    self:StartCooldown(self:GetCooldown(self:GetLevel()))
    hCaster:SpendMana(self:GetManaCost(-1), self)

    local tProjectile = {
        Target = hTarget,
        Source = hCaster,
        Ability = self,
        EffectName = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf",
        iMoveSpeed = 3000,
        vSourceLoc = hCaster:GetAbsOrigin(),
        bDodgeable = true,
        bIsAttack = true,
        flExpireTime = GameRules:GetGameTime() + 10,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
    }
    ProjectileManager:CreateTrackingProjectile(tProjectile)
end

function emiya_hrunting:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
    if hTarget == nil then
        return 
    end
    local hCaster = self:GetCaster()
    local fTargetDamage = self:GetSpecialValueFor("target_damage")
    local fSplashDamage = self:GetSpecialValueFor("splash_damage")
    local fRadius = self:GetSpecialValueFor("radius")
    local fStun = self:GetSpecialValueFor("stun_duration")
    
    if IsSpellBlocked(hTarget) then return end

    local pcExplosion = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
    ParticleManager:SetParticleControl(pcExplosion, 3, hTarget:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pcExplosion)
    
    hTarget:EmitSound("Misc.Crash")
    DoDamage(hCaster, hTarget, fTargetDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
    if not hTarget:IsMagicImmune() then
        hTarget:AddNewModifier(hCaster, hTarget, "modifier_stunned", {Duration = fStun})
    end
    local tTargets = FindUnitsInRadius(hCaster:GetTeam(), hTarget:GetAbsOrigin(), nil, fRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    for k,v in pairs(tTargets) do
        DoDamage(hCaster, v, fSplashDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
    end
end