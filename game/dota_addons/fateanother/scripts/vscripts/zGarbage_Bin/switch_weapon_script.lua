function OnWeaponSwitch(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local ability = keys.ability     

    local a1 = caster:GetAbilityByIndex(0)
    local a2 = caster:GetAbilityByIndex(1)
    local a3 = caster:GetAbilityByIndex(2)
    --local a4 = caster:GetAbilityByIndex(3)
    --local a5 = caster:GetAbilityByIndex(4)
    --local a6 = caster:GetAbilityByIndex(5)   

    --caster:SwapAbilities("lancelot_close_spellbook", a5:GetName(), true,false) 
    
    if caster.IsMeleeForm then        
        caster:SwapAbilities("emiya_shoot_arrows", a1:GetName(), true, false)
        caster:SwapAbilities("archer_5th_broken_phantasm", a2:GetName(), true, false) 
        caster:SwapAbilities("archer_5th_hrunting", a3:GetName(), true, false) 

        caster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
        
        caster.IsMeleeForm = false
        caster.IsRangedForm = true
    else if caster.IsRangedForm then
        caster:SwapAbilities("archer_5th_kanshou_bakuya", a1:GetName(), true, false)        
        caster:SwapAbilities("archer_5th_sword_barrage_confine", a2:GetName(), true, false) 
        caster:SwapAbilities("archer_5th_overedge", a3:GetName(), true, false)

        caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK) 

        caster.IsMeleeForm = true
        caster.IsRangedForm = false
    end

    --[[if caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
        caster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    else
        caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK) 
    end]]
end