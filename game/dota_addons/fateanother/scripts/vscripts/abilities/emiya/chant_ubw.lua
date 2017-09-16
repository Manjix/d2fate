emiya_chant_ubw = class({})
LinkLuaModifier("modifier_ubw_chant_count", "abilities/emiya/modifier_ubw_chant_count", LUA_MODIFIER_MOTION_NONE)

function emiya_chant_ubw:OnUpgrade()
    local caster = self:GetCaster()
    local ability = self

    --if IsServer() and not caster.AddUBWCastCount then
    --    function caster:AddUBWCastCount(...)
    --    ability:AddUbwCast(...)
    --    end
    --end
end

function emiya_chant_ubw:GetCooldownToSet()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("cooldown_set")

    return duration
end

---------------------------------------------------------------------------------------------------------------

function emiya_chant_ubw:GetBuffDuration()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    return duration
end

---------------------------------------------------------------------------------------------------------------

function emiya_chant_ubw:GetUBWCastCount()
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName("modifier_ubw_chant_count")
    local currentStack = modifier and modifier:GetStackCount() or 0

    return currentStack
end

---------------------------------------------------------------------------------------------------------------

function emiya_chant_ubw:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local effect = "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf"
    local currentStack = 0
    local modifier = caster:FindModifierByName("modifier_ubw_chant_count") 

    if modifier then
        currentStack = modifier:GetStackCount()

        caster:RemoveModifierByName("modifier_ubw_chant_count")
        caster:AddNewModifier(caster, self, "modifier_ubw_chant_count", {duration = self:GetBuffDuration()})

        caster:SetModifierStackCount("modifier_ubw_chant_count", self, currentStack + 1)

        currentStack = currentStack + 1        
    else
        caster:AddNewModifier(caster, self, "modifier_ubw_chant_count", {duration = self:GetBuffDuration()})
        caster:SetModifierStackCount("modifier_ubw_chant_count", self, 1)
        currentStack = 1
    end

    local bpCd = caster:GetAbilityByIndex(1):GetCooldownTimeRemaining()    
    local oeCd = caster:GetAbilityByIndex(2):GetCooldownTimeRemaining()

    caster:GetAbilityByIndex(0):EndCooldown()    
    caster:GetAbilityByIndex(1):EndCooldown()
    caster:GetAbilityByIndex(2):EndCooldown()

    caster:GetAbilityByIndex(0):StartCooldown(1)

    if bpCd - self:GetCooldownToSet() > 1 then
        caster:GetAbilityByIndex(1):StartCooldown(bpCd - self:GetCooldownToSet())
    else
        caster:GetAbilityByIndex(1):StartCooldown(1)
    end

    if oeCd - self:GetCooldownToSet() > 1 then
        caster:GetAbilityByIndex(2):StartCooldown(oeCd - self:GetCooldownToSet())
    else
        caster:GetAbilityByIndex(2):StartCooldown(1)
    end
        
    if currentStack == 1 then 
        caster:EmitSound("emiya_ubw1")
    elseif currentStack == 2 then 
        caster:EmitSound("emiya_ubw2")
    elseif currentStack == 3 then 
        caster:EmitSound("emiya_ubw3")
    elseif currentStack == 4 then 
        caster:EmitSound("emiya_ubw4")
    elseif currentStack == 5 then 
        caster:EmitSound("emiya_ubw5")
    elseif currentStack == 6 then 
        caster:EmitSound("emiya_ubw6") 
        local ability_slot = caster:GetAbilityByIndex(5)

        if ability_slot:GetName() == "emiya_chant_ubw" then
            caster:SwapAbilities("emiya_chant_ubw", "archer_5th_ubw", false, true) 
            caster:FindAbilityByName("archer_5th_ubw"):StartCooldown(4)
        end        
    end    
end

function emiya_chant_ubw:OnUpgrade()
    local caster = self:GetCaster()
    local ability = self
    
    caster:FindAbilityByName("archer_5th_sword_barrage_retreat_shot"):SetLevel(self:GetLevel())    
    caster:FindAbilityByName("archer_5th_sword_barrage_confine"):SetLevel(self:GetLevel())
    caster:FindAbilityByName("emiya_gae_bolg"):SetLevel(self:GetLevel())
    caster:FindAbilityByName("archer_5th_nine_lives"):SetLevel(self:GetLevel())
    caster:FindAbilityByName("archer_5th_sword_barrage"):SetLevel(self:GetLevel())
    caster:FindAbilityByName("archer_5th_ubw"):SetLevel(self:GetLevel())
end


function emiya_chant_ubw:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function emiya_chant_ubw:GetIntrinsicModifierName()
    return "modifier_ubw_chant_count"
end

function emiya_chant_ubw:GetAbilityTextureName()
    return "custom/archer_5th_ubw"
end