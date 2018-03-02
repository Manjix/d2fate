modifier_diarmuid_minds_eye = class({})

function modifier_diarmuid_minds_eye:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, 
			 MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_diarmuid_minds_eye:OnCreated(args)
	if IsServer() then
		self.MagicResist = args.MagicResist
		self.Armor = args.Armor

		CustomNetTables:SetTableValue("sync","diarmuid_minds_eye", { magic_resist = self.MagicResist,
																	 armor = self.Armor })
	end
end

function modifier_diarmuid_minds_eye:GetModifierMagicalResistanceBonus()
	if IsServer() then
		return self.MagicResist
	elseif IsClient() then
		local magic_resist = CustomNetTables:GetTableValue("sync","diarmuid_minds_eye").magic_resist
        return magic_resist 
	end
end

function modifier_diarmuid_minds_eye:GetModifierPhysicalArmorBonus()
	if IsServer() then
		return self.Armor
	elseif IsClient() then
		local armor = CustomNetTables:GetTableValue("sync","diarmuid_minds_eye").armor
        return armor 
	end
end

function modifier_diarmuid_minds_eye:IsHidden()
	return false 
end

function modifier_diarmuid_minds_eye:RemoveOnDeath()
	return true
end

function modifier_diarmuid_minds_eye:GetTexture()
	return "custom/diarmuid_attribute_minds_eye"
end