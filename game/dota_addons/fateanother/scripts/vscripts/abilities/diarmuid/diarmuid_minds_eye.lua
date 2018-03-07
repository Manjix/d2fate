diarmuid_minds_eye = class({})

LinkLuaModifier("modifier_diarmuid_minds_eye", "abilities/diarmuid/modifiers/modifier_diarmuid_minds_eye", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_minds_eye_attribute", "abilities/diarmuid/modifiers/modifier_minds_eye_attribute", LUA_MODIFIER_MOTION_NONE)

function diarmuid_minds_eye:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_diarmuid_minds_eye", { Duration = self:GetSpecialValueFor("duration"),
																		 MagicResist = self:GetSpecialValueFor("magic_res"),
																		 ArmorBonus = self:GetSpecialValueFor("armor")})
end

function diarmuid_minds_eye:OnOwnerSpawned()
	self:GrantMindsEyeModifier()
end

function diarmuid_minds_eye:OnUpgrade()
	self:GrantMindsEyeModifier()
end

function diarmuid_minds_eye:GrantMindsEyeModifier()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_minds_eye_attribute") then
		caster:AddNewModifier(caster, self, "modifier_minds_eye_attribute", { Radius = self:GetSpecialValueFor("radius"),
																			  VisionDuration = self:GetSpecialValueFor("duration") })
	end
end

--[[function diarmuid_minds_eye:GetIntrinsicModifierName()
	return "modifier_minds_eye_attribute"
end]]