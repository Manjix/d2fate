modifier_rho_aias = class({})

function modifier_rho_aias:OnTakeDamage(args)	
	if IsServer() then
		if args.unit ~= self:GetParent() then return end
		local rhoTarget = self:GetParent()
		local currentHealth = rhoTarget:GetHealth() 

		-- Create particles
		local onHitParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit_sphere.vpcf", PATTACH_CUSTOMORIGIN, rhoTarget )
		ParticleManager:SetParticleControl( onHitParticleIndex, 2, rhoTarget:GetAbsOrigin() )
		
		Timers:CreateTimer( 0.5, function()
			ParticleManager:DestroyParticle( onHitParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( onHitParticleIndex )
		end)

		rhoTarget.rhoShieldAmount = rhoTarget.rhoShieldAmount - args.damage
		if rhoTarget.rhoShieldAmount <= 0 then
			if currentHealth + rhoTarget.rhoShieldAmount <= 0 then
				rhoTarget:RemoveModifierByName("modifier_rho_aias_shield")
				rhoTarget:SetHealth(currentHealth + args.damage + rhoTarget.rhoShieldAmount)
				rhoTarget.rhoShieldAmount = 0
			end
		else			
			rhoTarget:SetHealth(currentHealth + args.damage)
		end
	end
end

function modifier_rho_aias:CheckState()
	return { [MODIFIER_STATE_ROOTED] = true }
end

function modifier_rho_aias:OnCreated(args)
	if IsServer() then
		self.rhoShieldParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_rhoaias_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:StartIntervalThink(0.1)
	end
end

function modifier_rho_aias:OnRefresh(args)
	self:OnDestroy()
	self:OnCreated(args)
end

function modifier_rho_aias:OnIntervalThink()
	local target = self:GetParent()
	ParticleManager:SetParticleControl( self.rhoShieldParticleIndex, 0, target:GetAbsOrigin() )
			
	local origin = self:GetParent():GetAbsOrigin()
	local forwardVec = self:GetParent():GetForwardVector()
	local rightVec = self:GetParent():GetRightVector()

	-- Hard coded value, these values have to be adjusted manually for core and end point of each petal
	ParticleManager:SetParticleControl( self.rhoShieldParticleIndex, 1, Vector( origin.x + 150 * forwardVec.x, origin.y + 150 * forwardVec.y, origin.z + 225 ) ) -- petal_core, center of petals
	ParticleManager:SetParticleControl( self.rhoShieldParticleIndex, 2, Vector( origin.x - 30 * forwardVec.x, origin.y - 30 * forwardVec.y, origin.z + 375 ) ) -- petal_a
	ParticleManager:SetParticleControl( self.rhoShieldParticleIndex, 3, Vector( origin.x + 150 * forwardVec.x, origin.y + 150 * forwardVec.y, origin.z ) ) -- petal_d
	ParticleManager:SetParticleControl( self.rhoShieldParticleIndex, 4, Vector( origin.x + 150 * rightVec.x, origin.y + 150 * rightVec.y, origin.z + 300 ) ) -- petal_b
	ParticleManager:SetParticleControl( self.rhoShieldParticleIndex, 5, Vector( origin.x - 150 * rightVec.x, origin.y - 150 * rightVec.y, origin.z + 300 ) ) -- petal_c
	ParticleManager:SetParticleControl( self.rhoShieldParticleIndex, 6, Vector( origin.x + 150 * rightVec.x + 60 * forwardVec.x, origin.y + 150 * rightVec.y + 60 * forwardVec.y, origin.z + 25 ) ) -- petal_e
	ParticleManager:SetParticleControl( self.rhoShieldParticleIndex, 7, Vector( origin.x - 150 * rightVec.x + 60 * forwardVec.x, origin.y - 150 * rightVec.y + 60 * forwardVec.y, origin.z + 25 ) ) -- petal_f
end

function modifier_rho_aias:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle( self.rhoShieldParticleIndex, false )
		ParticleManager:ReleaseParticleIndex( self.rhoShieldParticleIndex)
	end
end

function modifier_rho_aias:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_rho_aias:RemoveOnDeath()
	return true 
end

function modifier_rho_aias:GetTexture()
	return "custom/archer_5th_rho_aias"
end