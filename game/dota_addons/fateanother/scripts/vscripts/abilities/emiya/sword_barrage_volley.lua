function OnBarrageStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	--local duration = keys.Duration
	local frontward = caster:GetForwardVector()
	local casterloc = caster:GetAbsOrigin()	

	local gobWeapon = 
	{
		Ability = ability,
        EffectName = "particles/custom/archer/archer_sword_barrage_model_test.vpcf",
        vSpawnOrigin = Vector(0,0,0),
        fDistance = 1000,
        fStartRadius = 100,
        fEndRadius = 100,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 1.5,
		bDeleteOnHit = true,
		vVelocity = nil
	}

	--[[Timers:CreateTimer(0.5, function()
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:OnPhysicsFrame(nil)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end)]]

	local sword_count = keys.SwordCount
	local delay = 0.07
	for i=1, sword_count do
		Timers:CreateTimer(delay, function()	
			local projectile = gobWeapon
			local leftvec = Vector(-frontward.y, frontward.x, 0)
			local rightvec = Vector(frontward.y, -frontward.x, 0)
			local gobCount = 0

			local random1 = RandomInt(0, 150) -- position of weapon spawn
			local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

			if random2 == 0 then 
				projectile.vSpawnOrigin = casterloc + leftvec*random1
			else 
				projectile.vSpawnOrigin = casterloc + rightvec*random1
			end
			projectile.vVelocity = frontward * 1500
			ProjectileManager:CreateLinearProjectile(projectile)

			--ParticleManager:SetParticleControlEnt( caster.LatestGOBParticle, 0, caster.LatestGOB, PATTACH_ABSORIGIN, nil, caster.LatestGOB:GetAbsOrigin(), false )
			
			return
		end)
		delay = delay + 0.07
	end
end

function OnVolleyProjectileHit(keys)
	local target = keys.target
	local caster = keys.caster
	local damage = keys.Damage
	--[[if caster.IsSumerAcquired then
		damage = damage + caster:GetAttackDamage()*0.25
	end]]
	--if target:GetUnitName() == "gille_gigantic_horror" then damage = damage*2.5 end
	DoDamage(keys.caster, keys.target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	local particle = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_ABSORIGIN, keys.target)
	ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
	keys.target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
end


	--[[Timers:CreateTimer(function()
		if sword_count == 0 then return end

		local projectile = gobWeapon
		local leftvec = Vector(-frontward.y, frontward.x, 0)
		local rightvec = Vector(frontward.y, -frontward.x, 0)
		local gobCount = 0

		local random1 = RandomInt(0, 100) -- position of weapon spawn
		local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

		if random2 == 0 then 
			projectile.vSpawnOrigin = casterloc + leftvec*random1
		else 
			projectile.vSpawnOrigin = casterloc + rightvec*random1
		end
		projectile.vVelocity = frontward * 1500
		ProjectileManager:CreateLinearProjectile(projectile)

		ParticleManager:SetParticleControlEnt( caster.LatestGOBParticle, 0, caster.LatestGOB, PATTACH_ABSORIGIN, nil, caster.LatestGOB:GetAbsOrigin(), false )
		sword_count = sword_count - 1
		return 0.07
	end)]]


	



	--if caster:HasModifier("modifier_gob_thinker") then caster:RemoveModifierByName("modifier_gob_thinker") end
	--[[GilgaCheckCombo(caster, keys.ability)
	CreateGOB(keys, gobWeapon)
	
	caster:EmitSound("Gilgamesh.GOB")
	caster:EmitSound("Saber_Alter.Derange")
	caster:EmitSound("Archer.UBWAmbient")]]

--[[function CreateGOB(keys, proj)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local duration = keys.Duration
	local frontward = caster:GetForwardVector()
	local casterloc = caster:GetAbsOrigin()



	local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin() - 250 * frontward, false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:SetForwardVector(caster:GetForwardVector())
	
	local portalFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_gob.vpcf", PATTACH_CUSTOMORIGIN, dummy )
	ParticleManager:SetParticleControlEnt( portalFxIndex, 0, dummy, PATTACH_ABSORIGIN, nil, dummy:GetAbsOrigin(), false )
	--ParticleManager:SetParticleControl( portalFxIndex, 0, dummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( portalFxIndex, 1, Vector( 300, 300, 300 ) )

	dummy.GOBProjectile = proj
	dummy.GOBParticle = portalFxIndex
	caster.LatestGOB = dummy
	caster.LatestGOBParticle = portalFxIndex
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_gob_thinker", {})
end

function OnGOBEnd(keys)
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	ParticleManager:DestroyParticle( unit.GOBParticle, false )
	ParticleManager:ReleaseParticleIndex( unit.GOBParticle )
	unit:RemoveSelf()
end

function ToggleGOBOn(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ToggleAbility()
end
function OnGOBThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.target
	local origin = unit:GetAbsOrigin()
	local frontward = unit:GetForwardVector()
	local casterFrontWard = caster:GetForwardVector()
	local toggleAbil = caster:FindAbilityByName("gilgamesh_gate_of_babylon_toggle")
	if not caster:IsAlive() then
		unit:RemoveModifierByName("modifier_gob_thinker")
		return
	end
	if caster.IsSumerAcquired and unit == caster.LatestGOB then
		origin = caster:GetAbsOrigin()
		frontward = caster:GetForwardVector()
		caster.LatestGOB:SetAbsOrigin(caster:GetAbsOrigin() - caster:GetForwardVector() * 150)
		caster.LatestGOB:SetForwardVector( caster:GetForwardVector() )
		--ParticleManager:SetParticleControl( caster.LatestGOBParticle, 0, caster.LatestGOB:GetAbsOrigin() )
		--ParticleManager:SetParticleControlOrientation(caster.LatestGOBParticle, 0, Vector(1,0,0), Vector(0.5,1,0.5), Vector(1,0.5,0.5))
	end

	if caster:IsAlive() and (not caster.IsSumerAcquired or (caster.IsSumerAcquired and toggleAbil:GetToggleState())) then
		local projectile = unit.GOBProjectile
		local leftvec = Vector(-frontward.y, frontward.x, 0)
		local rightvec = Vector(frontward.y, -frontward.x, 0)
		local gobCount = 0

		local random1 = RandomInt(0, 300) -- position of weapon spawn
		local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

		if random2 == 0 then 
			projectile.vSpawnOrigin = origin + leftvec*random1
		else 
			projectile.vSpawnOrigin = origin + rightvec*random1
		end
		projectile.vVelocity = frontward * 3000
		ProjectileManager:CreateLinearProjectile(projectile)

		ParticleManager:SetParticleControlEnt( caster.LatestGOBParticle, 0, caster.LatestGOB, PATTACH_ABSORIGIN, nil, caster.LatestGOB:GetAbsOrigin(), false )
	end
end]]

