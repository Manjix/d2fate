gawain_sun_of_galatine = class({})

LinkLuaModifier("modifier_sun_of_galatine_self", "abilities/gawain/modifiers/modifier_sun_of_galatine_self", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sun_of_galatine_slow", "abilities/gawain/modifiers/modifier_sun_of_galatine_slow", LUA_MODIFIER_MOTION_NONE)

function gawain_sun_of_galatine:GetAbilityDamageType()
    return DAMAGE_TYPE_MAGICAL
end

function gawain_sun_of_galatine:GetAOERadius()
    return self:GetSpecialValueFor("area_of_effect")
end

function gawain_sun_of_galatine:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local radius = self:GetAOERadius()
    local damage = (self:GetSpecialValueFor("burn_damage") / 10)

    caster:AddNewModifier(caster, self, "modifier_sun_of_galatine_self", {duration = self:GetSpecialValueFor("channel_dur")})
    caster.ChannelDuration = 0
    caster.SunExploded = false

    caster:EmitSound("Hero_Phoenix.SuperNova.Cast")

    local slow = self:GetSpecialValueFor("slow_perc")

    if caster.IsNoSAcquired then
        slow = slow - 40
    end


    Timers:CreateTimer(function()
        if caster:HasModifier("modifier_sun_of_galatine_self") then
            local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 

            for k,v in pairs(targets) do            
                DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
                if not IsImmuneToSlow(v) then 
                    v:AddNewModifier(caster, self, "modifier_sun_of_galatine_slow", { Duration = 1.0,
                                                                                      SlowPerc = slow})
                end
            end

            caster.ChannelDuration = caster.ChannelDuration + 0.1

            local fireFx = ParticleManager:CreateParticle("particles/custom/gawain/manjinx_gawain_e.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(fireFx, 0, caster:GetAbsOrigin())
            ParticleManager:SetParticleControl(fireFx, 1, Vector(0.5,0,0))

            return 0.1
        else 
            return
        end
    end)
end

function gawain_sun_of_galatine:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("area_of_effect_2")
    local ability = self
    local damage = ((self:GetSpecialValueFor("max_damage") - self:GetSpecialValueFor("min_damage")) * (caster.ChannelDuration / 2.5)) + self:GetSpecialValueFor("min_damage")
    
    caster:RemoveModifierByName("modifier_sun_of_galatine_self")
    StopSoundEvent("Hero_Phoenix.SuperNova.Cast", caster)

    local explosionFx = ParticleManager:CreateParticle("particles/custom/gawain/gawain_supernova_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(explosionFx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(explosionFx, 1, Vector(3,0,0))

    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do            
        DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        if caster.IsNoSAcquired then
            v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = caster.ChannelDuration})
        end     
    end 

    caster:EmitSound("Hero_Phoenix.SuperNova.Explode")
    --caster.SunExploded = true
end