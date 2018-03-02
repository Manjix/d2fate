modifier_double_spearmanship_active = class({})

function modifier_double_spearmanship_active:OnCreated(args)
	if IsServer() then
		self.ProcReady = true
		self.AttackSpeed = args.AttackSpeed
		CustomNetTables:SetTableValue("sync","double_spearmanship", { attack_speed = self.AttackSpeed })
		--self:StartIntervalThink(0.1)
	end
end

function modifier_double_spearmanship_active:OnRefresh(args)
	self:OnCreated(args)
end

function modifier_double_spearmanship_active:OnAttackLanded(args)
	if IsServer() then
		if args.attacker ~= self:GetParent() or self:GetParent():HasModifier("modifier_rampant_warrior") then 
			return 
		end
		local target = args.target
		local caster = self:GetParent()

		if self.ProcReady then
			self.ProcReady = false
			self:StartIntervalThink(0.1)
			caster:PerformAttack(target, true, true, true, true, false, false, false)
		end
	end
end

function modifier_double_spearmanship_active:OnIntervalThink()
	self.ProcReady = true
	self:StartIntervalThink(-1)
	print("active double attack cooldown")
end

function modifier_double_spearmanship_active:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return self.AttackSpeed
	elseif IsClient() then
		local attack_speed = CustomNetTables:GetTableValue("sync","double_spearmanship").attack_speed
        return attack_speed 
	end
end

function modifier_double_spearmanship_active:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
			 MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_double_spearmanship_active:IsHidden()
	return false
end

function modifier_double_spearmanship_active:RemoveOnDeath()
	return true
end

function modifier_double_spearmanship_active:GetTexture()
	return "custom/diarmuid_double_spearsmanship"
end