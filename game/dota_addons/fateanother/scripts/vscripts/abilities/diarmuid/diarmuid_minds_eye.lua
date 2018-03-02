diarmuid_minds_eye = class({})

LinkLuaModifier("modifier_diarmuid_minds_eye", "abilities/diarmuid/modifiers/modifier_diarmuid_minds_eye", LUA_MODIFIER_MOTION_NONE)

function diarmuid_minds_eye:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_diarmuid_minds_eye", { Duration = 1,
																		 MagicResist = self:GetSpecialValueFor("magic_res"),
																		 ArmorBonus = self:GetSpecialValueFor("armor")})
end