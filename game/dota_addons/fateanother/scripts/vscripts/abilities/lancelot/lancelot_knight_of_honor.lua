lancelot_knight_of_honor = class({})

local tStandardAbilities = {
    "lancelot_vortigern",
    "lancelot_gae_bolg",
    "lancelot_nine_lives",
    "lancelot_rule_breaker",
    "lancelot_knight_of_honor_close",
    "lancelot_tsubame_gaeshi",
    "attribute_bonus_custom"
}

local tGobAbilities = {
    "lancelot_durandal",
    "lancelot_vajra",
    "lancelot_harpe",
    "lancelot_hrunt_naeg",
    "lancelot_knight_of_honor_close",
    "lancelot_minigun",
    "attribute_bonus_custom"
}

local tStandardProxy = {
    "lancelot_durandal",
    "fate_empty1",
    "fate_empty2",
    "fate_empty3",
    "lancelot_knight_of_honor_close",
    "fate_empty4",
    "attribute_bonus_custom"
}

local tGobProxy = {
    "lancelot_vortigern",
    "fate_empty1",
    "fate_empty2",
    "fate_empty3",
    "lancelot_knight_of_honor_close",
    "fate_empty4",
    "attribute_bonus_custom"
}

function lancelot_knight_of_honor:OnUpgrade()
    local hCaster = self:GetCaster()
    local hAbility = hCaster:FindAbilityByName("lancelot_knight_of_honor")
    local abilityLevel = 1
    if hCaster.KnightLevel then
        abilityLevel = abilityLevel + hCaster.KnightLevel
    end   

    for i = 1, self:GetLevel() do
        if not hCaster:HasAbility(tStandardAbilities[i]) then
            local abil = hCaster:AddAbility(tStandardAbilities[i])
            abil:SetLevel(abilityLevel)
            abil:SetHidden(true)

            if i > 1 then hCaster:RemoveAbility("fate_empty"..tostring(i - 1)) end
        end

        --[[if not hCaster:HasAbility(tGobAbilities[i]) then
            local abil = hCaster:AddAbility(tGobAbilities[i])
            abil:SetLevel(1)
            abil:SetHidden(true)
        end]]

        if i == 5 then
            if not hCaster:HasAbility(tStandardAbilities[6]) then
                local abil = hCaster:AddAbility(tStandardAbilities[6])
                abil:SetLevel(abilityLevel)
                abil:SetHidden(true)
            end

            --[[if not hCaster:HasAbility(tGobAbilities[6]) then
                local abil = hCaster:AddAbility(tGobAbilities[6])
                abil:SetLevel(1)
                abil:SetHidden(true)
            end]]
        end
    end
end

function lancelot_knight_of_honor:OnSpellStart()
    local hCaster = self:GetCaster()
    local iLevel = self:GetLevel()
    local t = {}
    local tAbilities = {}
    local tProxy = {}
    local abilityLevel = 1
    if hCaster.KnightLevel then
        abilityLevel = abilityLevel + hCaster.KnightLevel
    end

    --[[if hCaster:HasModifier("modifier_double_edge") then
        tAbilities = tGobAbilities
        tProxy = tGobProxy
    else]]

    tAbilities = tStandardAbilities
    tProxy = tStandardProxy
    --end

    for i = 1, #tAbilities do
        if not hCaster:HasAbility(tAbilities[i]) then
            t[i] = tProxy[i]
        else
            t[i] = tAbilities[i]
        end

        local abil = hCaster:FindAbilityByName(t[i])
        if abil:GetName() ~= "attribute_bonus_custom" then            
            abil:SetLevel(abilityLevel)
        end
    end

    UpdateAbilityLayout(hCaster, t)

    self:BandaidHotkeySwap()
end

function lancelot_knight_of_honor:BandaidHotkeySwap()
    local caster = self:GetCaster()

    caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), caster:GetAbilityByIndex(3):GetName(), true, true)
end

------------------------------------------------------------------------------

function lancelot_knight_of_honor:CastFilterResult()
    if self:GetCaster():HasModifier("modifier_arondite") then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function lancelot_knight_of_honor:GetCustomCastError()
    return "#Cannot_Be_Cast_Now"
end

function lancelot_knight_of_honor:GetAbilityTextureName()
    --local caster = self:GetCaster()

    --[[if caster:HasModifier("modifier_double_edge") then
        return "custom/lancelot_attribute_improve_knight_of_honor"
    else]]
    return "custom/lancelot_knight_of_honor"
    --end
end

------------------------------------------------------------------------------