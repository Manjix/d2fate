lancelot_arms_mastership = class({})

function lancelot_arms_mastership:OnSpellStart()
	local caster = self:GetCaster()
    local ability = self

    caster:EmitSound("Hero_Abaddon.AphoticShield.Cast")
    HardCleanse(caster)
    local dispel = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( dispel, 1, caster:GetAbsOrigin())

    Timers:CreateTimer( 2.0, function()
        ParticleManager:DestroyParticle( dispel, false )
        ParticleManager:ReleaseParticleIndex( dispel )
    end)
end

function lancelot_arms_mastership:CastFilterResult()
	local caster = self:GetCaster()

	if IsServer() then
		if not caster.IsEternalImproved then
			return UF_FAIL_CUSTOM
		elseif IsRevoked(caster) then
			return UF_FAIL_CUSTOM
		else
			return UF_SUCCESS
		end
	end
end

function lancelot_arms_mastership:GetCustomCastError()
	return "#Cannot_Be_Used"
end