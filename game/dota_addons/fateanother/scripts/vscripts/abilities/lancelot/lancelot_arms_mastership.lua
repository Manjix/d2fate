lancelot_arms_mastership = class({})

local revokes = {
    "modifier_enkidu_hold",
    "jump_pause",
    "pause_sealdisabled",
    "rb_sealdisabled",
    "revoked",
    "round_pause",
    "modifier_nss_shock"
}

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

	if not caster:HasModifier("modifier_eternal_arms_attribute") then
		return UF_FAIL_CUSTOM
	else
		for i = 1, #revokes do
			if caster:HasModifier(revokes[i]) then
				return UF_FAIL_CUSTOM
			end
		end
	end

	return UF_SUCCESS
end

function lancelot_arms_mastership:GetCustomCastError()
	return "#Cannot_Be_Used"
end