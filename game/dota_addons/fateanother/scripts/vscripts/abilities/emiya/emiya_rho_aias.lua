emiya_rho_aias = class({})

LinkLuaModifier("modifier_rho_aias", "abilities/emiya/modifiers/modifier_rho_aias", LUA_MODIFIER_MOTION_NONE)

local rhoTarget = nil

function emiya_rho_aias:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local ability = self
	local ply = caster:GetPlayerOwner()
	
	rhoTarget = target 
	target.rhoShieldAmount = self:GetSpecialValueFor("shield_amount")

	caster:EmitSound("Archer.RhoAias" ) 
	caster:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")

	target:AddNewModifier(caster, self, "modifier_rho_aias", { Duration = self:GetSpecialValueFor("duration") })
end