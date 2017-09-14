modifier_ubw_chant_count = class({})

--[[function modifier_ubw_chant_count:OnRefresh()
    local hero = self:GetParent()
    if IsServer() then
        self:SetStackCount(self:GetStackCount() + 1)
    end    
end]]

-----------------------------------------------------------------------------------

function modifier_ubw_chant_count:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
 
    return funcs
end

-----------------------------------------------------------------------------------

function modifier_ubw_chant_count:OnDestroy()
    local hero = self:GetParent()
    local ability = hero:GetAbilityByIndex(5)
    if ability:GetName() == "archer_5th_ubw" then
        hero:SwapAbilities("archer_5th_ubw", "emiya_chant_ubw", false, true)
    end
end

-----------------------------------------------------------------------------------

function modifier_ubw_chant_count:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

-----------------------------------------------------------------------------------

function modifier_ubw_chant_count:IsPurgable()
    return false
end

-----------------------------------------------------------------------------------

function modifier_ubw_chant_count:IsDebuff()
    return false
end

-----------------------------------------------------------------------------------

function modifier_ubw_chant_count:RemoveOnDeath()
    return true
end

-----------------------------------------------------------------------------------

function modifier_ubw_chant_count:GetTexture()
    return "custom/archer_5th_ubw"
end

-----------------------------------------------------------------------------------
