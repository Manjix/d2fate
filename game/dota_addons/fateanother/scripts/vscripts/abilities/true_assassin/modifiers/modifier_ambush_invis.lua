modifier_ambush_invis = class({})

function modifier_ambush_invis:OnCreated(table)
    --[[local caster = self:GetParent()

    if caster ~= self:GetParent() then return end]]

    --[[if caster.IsPCImproved then
    	self.state = { MODIFIER_STATE_INVISIBLE, 
                       MODIFIER_STATE_NO_UNIT_COLLISION,
                     }
    else
    	self.state = {}
    end]]

    if IsServer() then
        self.fixedMoveSpeed = table.fixedMoveSpeed
        CustomNetTables:SetTableValue("sync","ambush_movement", {movespeed_bonus = self.fixedMoveSpeed})
        self.bonusDamage = table.bonusDamage

        self:StartIntervalThink(table.fadeDelay)
    end
end

function modifier_ambush_invis:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
             MODIFIER_EVENT_ON_ATTACK,
             MODIFIER_EVENT_ON_ATTACK_LANDED,
             MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
end

function modifier_ambush_invis:OnIntervalThink()
    if IsServer() then
    	local caster = self:GetParent()

        self.fixedMoveSpeed = 100
        if caster.IsPCImproved then
    		self.state = { [MODIFIER_STATE_INVISIBLE] = true,
    					   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    					   [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
    					 }
    	else
    		self.state = { [MODIFIER_STATE_INVISIBLE] = true,
    					   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    					 }
    	end
        
        self:StartIntervalThink(-1)
    end
end

--[[function modifier_ambush_invis:OnAttack(keys)
    self.state = { [MODIFIER_STATE_INVISIBLE] = false,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = false,
                    [MODIFIER_STATE_TRUESIGHT_IMMUNE] = false,
                     }
    --self:Destroy()
end]]

function modifier_ambush_invis:OnAttackLanded(args)	
    --[[print("----------------------------All bullshit----------------------------")
    for k,v in pairs(args) do print(k,v) end
    print("----------------------------Target----------------------------")
    for k,v in pairs(args.target) do print(k,v) end
    print("----------------------------Attacker----------------------------")
    for k,v in pairs(args.attacker) do print(k,v) end

    print("----------------------------Client Server----------------------------")
    print("IsClient", IsClient(), "IsServer", IsServer())]]

    if IsServer() then
        local caster = self:GetParent()

        if args.attacker ~= self:GetParent() then return end

        local target = args.target
        if caster == target then return end

        DoDamage(caster, target, self.bonusDamage, DAMAGE_TYPE_PHYSICAL, 0, self, false)
        target:EmitSound("Hero_TemplarAssassin.Meld.Attack")
        self:Destroy()
    end
end

function modifier_ambush_invis:OnAbilityFullyCast(args)
    --[[if IsServer() then
        print("----------------------------All bullshit----------------------------")
        for k,v in pairs(args) do print(k,v) end
        print("----------------------------Target----------------------------")
        for k,v in pairs(self:GetParent()) do print(k,v) end
        print("----------------------------Unit triggering----------------------------")
        for k,v in pairs(args.unit) do print(k,v) end
        --print("----------------------------Attacker----------------------------")
        --for k,v in pairs(args.attacker) do print(k,v) end
    end]]

    if IsServer() then
        if args.unit == self:GetParent() then
            if args.ability:GetName() ~= "true_assassin_ambush" then
                self:Destroy()
            end
        end
    end
	--print(table)
end

function modifier_ambush_invis:CheckState()
	return self.state
end

function modifier_ambush_invis:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then       
        return self.fixedMoveSpeed
    elseif IsClient() then
        local ambush_movement = CustomNetTables:GetTableValue("sync","ambush_movement").movespeed_bonus
        return ambush_movement 
    end
end

-----------------------------------------------------------------------------------
function modifier_ambush_invis:GetEffectName()
    return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_ambush_invis:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ambush_invis:GetAttributes() 
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_ambush_invis:IsPurgable()
    return true
end

function modifier_ambush_invis:IsDebuff()
    return false
end

function modifier_ambush_invis:RemoveOnDeath()
    return true
end

function modifier_ambush_invis:GetTexture()
    return "custom/true_assassin_ambush"
end
-----------------------------------------------------------------------------------
