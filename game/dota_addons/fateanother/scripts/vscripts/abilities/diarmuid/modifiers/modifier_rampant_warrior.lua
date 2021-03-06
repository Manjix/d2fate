modifier_rampant_warrior = class({})

function modifier_rampant_warrior:OnCreated(args)
	if IsServer() then
		--print("Rampant Warrior created")
		self.HitDamage = args.HitDamage
		self.ProcReady = true
		self.AttackSpeed = args.AttackSpeed

		--print("Synching net table stats")
		CustomNetTables:SetTableValue("sync","rampant_warrior", { attack_speed = self.AttackSpeed })

		--print("Stats Sync")
		--self:StartIntervalThink(0.1)
	end
end

function modifier_rampant_warrior:OnRefresh(args)
	if IsServer() then
		self:OnCreated(args)
	end
end

function modifier_rampant_warrior:OnAttackLanded(args)
	if IsServer() then
		if args.attacker ~= self:GetParent() then 
			return 
		end
		local target = args.target
		local caster = self:GetParent()

		if self.ProcReady then
			self.ProcReady = false			
			--print("performing double attack")
			caster:PerformAttack(target, true, true, true, true, false, false, false)
			DoDamage(caster, target, self.HitDamage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
			DoDamage(caster, target, self.HitDamage, DAMAGE_TYPE_PURE, 0, self:GetAbility(), false)

			if caster:HasModifier("modifier_doublespear_attribute") then
				local chargeAbility = caster:FindAbilityByName("diarmuid_warrior_charge")
				chargeAbility:ReduceCooldown()
			end
			
			self:StartIntervalThink(0.1)
		end
	end
end

function modifier_rampant_warrior:OnIntervalThink()
	self.ProcReady = true
	self:StartIntervalThink(-1)
	--print("rampant warrior cooldown")
end

function modifier_rampant_warrior:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return self.AttackSpeed
	elseif IsClient() then
		--print("client getting attack speed")
		local attack_speed = CustomNetTables:GetTableValue("sync","rampant_warrior").attack_speed
		--print("client attack speed")
        return attack_speed 
	end
end

function modifier_rampant_warrior:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
			 MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_rampant_warrior:IsHidden()
	return false 
end

function modifier_rampant_warrior:RemoveOnDeath()
	return true
end

function modifier_rampant_warrior:GetTexture()
	return "custom/diarmuid_rampant_warrior"
end