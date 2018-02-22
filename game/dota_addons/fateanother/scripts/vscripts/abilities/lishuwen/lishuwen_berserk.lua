lishuwen_berserk = class({})

LinkLuaModifier("modifier_berserk","abilities/lishuwen/modifiers/modifier_berserk", LUA_MODIFIER_MOTION_NONE)

function lishuwen_berserk:OnSpellStart()
	local caster = self:GetCaster()	
    local ability = self

    --print("Start Berserk Concha")
    
    HardCleanse(caster)
    caster:EmitSound("Hero_Sven.WarCry")
    local dispel = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( dispel, 1, caster:GetAbsOrigin())
    -- Destroy particle after delay
    Timers:CreateTimer( 2.0, function()
        ParticleManager:DestroyParticle( dispel, false )
        ParticleManager:ReleaseParticleIndex( dispel )
    end)

	caster:AddNewModifier(caster, ability, "modifier_berserk", { Duration = self:GetSpecialValueFor("duration"),
															     CCImmuneDuration = self:GetSpecialValueFor("immune_duration")
															})
end

--[[function lishuwen_berserk:CastFilterResult()
    local caster = self:GetCaster()   

    if IsRevoked(caster) then
        --SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end]]

function lishuwen_berserk:GetCustomCastError()
    return "#Cannot_Be_Cast_Now"
end

function lishuwen_berserk:GetAbilityTextureName()
    return "custom/lishuwen_berserk"
end

--[[function lishuwen_berserk:IsRevoked(target)
    for i=1, #revokes do
        if target:HasModifier(revokes[i]) then return true end
    end
    return false
end]]