function OnChannelStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.Radius
	local damage = (keys.BurnDamage / 10)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sun_of_galatine_self", {})
	caster.ChannelDuration = 0
	caster.SunExploded = false

	caster:EmitSound("Hero_Phoenix.SuperNova.Cast")

	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_sun_of_galatine_self") then
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 

			for k,v in pairs(targets) do			
	        	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        	if not IsImmuneToSlow(v) then ability:ApplyDataDrivenModifier(caster, v, "modifier_sun_of_galatine_slow", {}) end
	    	end

	    	caster.ChannelDuration = caster.ChannelDuration + 0.1

	    	--Some path to the fire particle
	    	--local fireFx = ParticleManager:CreateParticle("particles/custom/ruler/gods_resolution/gods_resolution_active_circle.vpcf", PATTACH_CUSTOMORIGIN, nil)
			--ParticleManager:SetParticleControl( purgeFx, 0, caster:GetAbsOrigin())

			local fireFx = ParticleManager:CreateParticle("particles/custom/gawain/manjinx_gawain_e.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(fireFx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fireFx, 1, Vector(0.5,0,0))

			return 0.1
		else 
			return
		end
    end)
end


function OnChannelEnd(keys)
	local caster = keys.caster
	local radius = keys.Radius
	local ability = keys.ability
	local damage = ((keys.MaxDamage - keys.MinDamage) * (caster.ChannelDuration / 2.5)) + keys.MinDamage

	if caster.SunExploded then return end

	--print(damage)
	--print(keys.Interrupted)
	
	caster:RemoveModifierByName("modifier_sun_of_galatine_self")
	StopSoundEvent("Hero_Phoenix.SuperNova.Cast", caster)

	local explosionFx = ParticleManager:CreateParticle("particles/custom/gawain/gawain_supernova_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(explosionFx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(explosionFx, 1, Vector(3,0,0))

	--Timers:CreateTimer(2.0, function()
	--	ParticleManager:DestroyParticle( explodeFx1, false )
	--	ParticleManager:ReleaseParticleIndex( explodeFx1 )
	--	ParticleManager:DestroyParticle( explodeFx2, false )
	--	ParticleManager:ReleaseParticleIndex( explodeFx2 )
	--end)

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do			
	    DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	    if caster.ChannelDuration > 2.0 and caster.IsNoSAcquired then
	    	v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 1.0})
	    end	    
	end	

	caster:EmitSound("Hero_Phoenix.SuperNova.Explode")
	caster.SunExploded = true
end
