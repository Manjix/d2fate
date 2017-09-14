function OnUbwChantCast(keys)
    local caster = keys.caster
    local ability = keys.ability
    local currentStack = 0
    local modifier = caster:FindModifierByName("modifier_ubw_chant_count")
    
    print(caster:FindModifierByName("modifier_ubw_chant_count"))
    print(caster:HasModifier("modifier_ubw_chant_count"))

    if caster:HasModifier("modifier_ubw_chant_count") then
        print("broken shit")
        currentStack = modifier:GetStackCount()

        caster:RemoveModifierByName("modifier_ubw_chant_count")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_ubw_chant_count", {})

        caster:SetModifierStackCount("modifier_ubw_chant_count", caster, currentStack + 1)

        currentStack = currentStack + 1        
    else
        print("something")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_ubw_chant_count", {})
        caster:SetModifierStackCount("modifier_ubw_chant_count", caster, 1)
        currentStack = 1
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
    end   
end

function OnUbwChantExpired(keys)
    local caster = keys.caster

    local ubwSlot = caster:GetAbilityByIndex(5)

    if ubwSlot:GetName() == "archer_5th_ubw" then
        caster:SwapAbilities("emiya_chant_ubw", ubwSlot:GetName(), true, false) 
    end    
end
