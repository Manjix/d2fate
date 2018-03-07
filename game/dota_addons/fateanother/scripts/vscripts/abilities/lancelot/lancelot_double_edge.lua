lancelot_double_edge = class({})

LinkLuaModifier("modifier_double_edge", "abilities/lancelot/modifiers/modifier_double_edge", LUA_MODIFIER_MOTION_NONE)

function lancelot_double_edge:OnSpellStart()
	local caster = self:GetCaster()

	caster:EmitSound("Hero_Sven.WarCry")

	caster:AddNewModifier(caster, self, "modifier_double_edge", { Duration = self:GetSpecialValueFor("duration"),
																  AttackSpeed = self:GetSpecialValueFor("base_att_spd"),
																  Movespeed = self:GetSpecialValueFor("base_mov_spd"),
																  DamageAmp = self:GetSpecialValueFor("base_dmg_amp"),
																  MaxAttackSpeed = self:GetSpecialValueFor("max_att_spd"),
																  MaxMovespeed = self:GetSpecialValueFor("max_mov_spd"),
																  MaxDamageAmp = self:GetSpecialValueFor("max_dmg_amp") })
end