modifier_blade_devoted_self = class({})

function modifier_blade_devoted_self:OnCreated(args)
	--if IsServer()
	self.MovespeedBonus = args.MovespeedBonus
	self.StunDuration = args.StunDuration
	self.Damage = args.Damage
	self.SubDamage = args.SubDamage
	self.FirstHit = true
	--end
end

function modifier_blade_devoted_self:OnRefresh(args)
	self:OnCreated(args)
end

function modifier_blade_devoted_self:GetModifierMoveSpeedBonus_Percentage()
	if IsServer() then
		CustomNetTables:SetTableValue("sync","blade_devoted_movement", {movespeed_bonus = self.MovespeedBonus})
	 	return self.MovespeedBonus
 	end
 	if IsClient() then
 		local movespeed_bonus = CustomNetTables:GetTableValue("sync","blade_devoted_movement").movespeed_bonus
 		return movespeed_bonus 
 	end
end

function modifier_blade_devoted_self:DeclareFunctions() 
	local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED, 
				    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
				} 
    return funcs
end

function modifier_blade_devoted_self:OnAttackLanded(args)
	if IsServer() then
		if args.attacker ~= self:GetParent() then return end

		local caster = self:GetParent()
		local target = args.target
		local ability = caster:FindAbilityByName("gawain_blade_of_the_devoted")

	
		DoDamage(caster, target, self.Damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = self.StunDuration})

		if caster.IsBeltAcquired then
			local aoeTargets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

	        for k, v in pairs(aoeTargets) do
	        	if v ~= target then
	        		DoDamage(caster, v, self.Damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = self.StunDuration})
	        	end
	        end 
		end

		if self.FirstHit then
			local soundQueue = math.random(1,3)
			target:EmitSound("Hero_Invoker.ColdSnap")
			caster:EmitSound("Gawain_Attack" .. soundQueue)
			self.Damage = self.SubDamage
			self.StunDuration = 0.01
			self.FirstHit = false
		else
			target:EmitSound("Hero_Invoker.ColdSnap.Freeze")
		end	
		
		local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:SetParticleControl( lightFx1, 0, target:GetAbsOrigin())
		local flameFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:SetParticleControl( flameFx1, 0, target:GetAbsOrigin())
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( lightFx1, false )
			ParticleManager:ReleaseParticleIndex( lightFx1 )
			ParticleManager:DestroyParticle( flameFx1, false )
			ParticleManager:ReleaseParticleIndex( flameFx1 )
		end)
	end

		--if caster == target then return end

	--[[print(IsServer())
	print(IsClient())

	for k,v in pairs(args.attacker) do print(k,v) end
	print("-----------------------")
	for k,v in pairs(args.target) do print(k,v) end
	print("-----------------------")
	for k,v in pairs(self:GetCaster()) do print(k,v) end
	print("-----------------------")
	for k,v in pairs(self:GetParent()) do print(k,v) end]]
	--if IsClient() then
		--
		
	--end
end

-----------------------------------------------------------------------------------

function modifier_blade_devoted_self:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_blade_devoted_self:IsPurgable()
    return true
end

function modifier_blade_devoted_self:IsDebuff()
    return false
end

function modifier_blade_devoted_self:RemoveOnDeath()
    return true
end

function modifier_blade_devoted_self:GetTexture()
    return "custom/gawain_blade_of_the_devoted"
end

-----------------------------------------------------------------------------------
