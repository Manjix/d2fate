modifier_gatekeeper = class({})

function modifier_gatekeeper:OnCreated(keys)
	self.Anchor = self:GetParent():GetAbsOrigin()
	self.LeashDistance = keys.LeashDistance
	self.BonusAttack = keys.BonusAttack
	--self.CircleDummy = keys.CircleDummy
	--self.CircleFx = keys.CircleFx

	if IsServer() then
		CustomNetTables:SetTableValue("sync","gatekeeper", { bonus_damage = self.BonusAttack })
	end
end

function modifier_gatekeeper:OnRefresh(args)
	self:OnCreated(args)
end

function modifier_gatekeeper:GetModifierMoveSpeed_Absolute()
	return 550
end

function modifier_gatekeeper:GetModifierPreAttack_BonusDamage()
	if IsServer() then
		return self.BonusAttack
	elseif IsClient() then
		local bonus_damage = CustomNetTables:GetTableValue("sync","gatekeeper").bonus_damage
        return bonus_damage 
	end
end

function modifier_gatekeeper:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_EVENT_ON_ATTACK_LANDED,
					MODIFIER_EVENT_ON_UNIT_MOVED }

	return funcs
end

function modifier_gatekeeper:OnUnitMoved()
	if IsServer() then
		local caster = self:GetParent()

		if math.abs((caster:GetAbsOrigin() - self.Anchor):Length2D()) > self.LeashDistance then
			self:Destroy()
		end
	end
end

function modifier_gatekeeper:OnAttackLanded(args)
	if IsServer() then
		if args.attacker ~= self:GetParent() then return end

		local caster = self:GetParent()

		caster:Heal(self.BonusAttack, caster)

		if caster.IsMindsEyeAcquired then
			caster:GiveMana(10)
		end
	end
end

--[[function modifier_gatekeeper:OnDestroy()
	if IsServer() then
		if IsValidEntity(self.CircleDummy) then
			ParticleManager:DestroyParticle( self.CircleFx, false )
            ParticleManager:ReleaseParticleIndex( self.CircleFx )
			self.CircleDummy:RemoveSelf()
		end
	end
end]]

------------------------------------------------------------------------------------

function modifier_gatekeeper:IsHidden()
	return false
end

function modifier_gatekeeper:IsDebuff()
	return false
end

function modifier_gatekeeper:RemoveOnDeath()
	return true
end

function modifier_gatekeeper:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_gatekeeper:GetTexture()
	return "custom/false_assassin_gate_keeper"
end

------------------------------------------------------------------------------------