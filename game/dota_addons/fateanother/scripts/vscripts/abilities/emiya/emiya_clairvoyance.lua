emiya_clairvoyance = class({})

function emiya_clairvoyance:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local targetLoc = self:GetCursorPosition()

	local visiondummy = SpawnVisionDummy(caster, targetLoc, radius, self:GetSpecialValueFor("duration"), caster.IsEagleEyeAcquired)

	if caster.IsHruntingAcquired then
		caster:SwapAbilities("emiya_clairvoyance", "emiya_hrunting", false, true) 
		caster:AddNewModifier(caster, self, "modifier_hrunting_window", { Duration = 8 })
	end
	
	local circleFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_circle.vpcf", PATTACH_CUSTOMORIGIN, visiondummy )
	ParticleManager:SetParticleControl( circleFxIndex, 0, visiondummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( circleFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( circleFxIndex, 2, Vector( 8, 0, 0 ) )
	ParticleManager:SetParticleControl( circleFxIndex, 3, Vector( 100, 255, 255 ) )
	
	local dustFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_dust.vpcf", PATTACH_CUSTOMORIGIN, visiondummy )
	ParticleManager:SetParticleControl( dustFxIndex, 0, visiondummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
	
	visiondummy.circle_fx = circleFxIndex
	visiondummy.dust_fx = dustFxIndex
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
			
	-- Destroy particle after delay
	Timers:CreateTimer(self:GetSpecialValueFor("duration"), function()
		ParticleManager:DestroyParticle( circleFxIndex, false )
		ParticleManager:DestroyParticle( dustFxIndex, false )
		ParticleManager:ReleaseParticleIndex( circleFxIndex )
		ParticleManager:ReleaseParticleIndex( dustFxIndex )
		return nil
	end
	)

	EmitSoundOnLocationWithCaster(targetLoc, "Hero_KeeperOfTheLight.BlindingLight", visiondummy)
end