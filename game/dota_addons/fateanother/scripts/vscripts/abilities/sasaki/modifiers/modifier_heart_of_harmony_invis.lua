modifier_heart_of_harmony_invis = class({})

-----------------------------------------------------------------------------------

function modifier_heart_of_harmony_invis:GetEffectName()
    return "particles\units\heroes\hero_pugna\pugna_decrepify.vpcf"
end

function modifier_heart_of_harmony_invis:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_heart_of_harmony_invis:GetAttributes() 
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_heart_of_harmony_invis:IsHidden()
    return true
end

function modifier_heart_of_harmony_invis:IsPurgable()
    return false
end

function modifier_heart_of_harmony_invis:IsDebuff()
    return false
end

function modifier_heart_of_harmony_invis:RemoveOnDeath()
    return true
end

function modifier_heart_of_harmony_invis:GetTexture()
    return "custom/false_assassin_heart_of_harmony"
end
-----------------------------------------------------------------------------------
