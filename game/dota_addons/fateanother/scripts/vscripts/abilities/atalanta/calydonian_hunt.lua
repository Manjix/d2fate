atalanta_calydonian_hunt = class({})
LinkLuaModifier("modifier_calydonian_hunt", "abilities/atalanta/modifier_calydonian_hunt", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_calydonian_hunt_root", "abilities/atalanta/modifier_calydonian_hunt_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_calydonian_hunt_root_block", "abilities/atalanta/modifiers/modifier_calydonian_hunt_root_block", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_calydonian_hunt_sight", "abilities/atalanta/modifiers/modifier_calydonian_hunt_sight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_calydonian_hunt_slow", "abilities/atalanta/modifiers/modifier_calydonian_hunt_slow", LUA_MODIFIER_MOTION_NONE)

function atalanta_calydonian_hunt:OnUpgrade()
    local caster = self:GetCaster()
    local ability = self

    if IsServer() and not caster.AddHuntStack then
        function caster:AddHuntStack(...)
            ability:AddStack(...)
        end
    end
end

function atalanta_calydonian_hunt:AddStack(target, count)
    local caster = self:GetCaster()

    local modifier = target:FindModifierByName("modifier_calydonian_hunt")
    local currentStack = modifier and modifier:GetStackCount() or 0
    local maxStacks = self:GetSpecialValueFor("max_stacks")

    --[[if caster.GoldenAppleAcquired then
        maxStacks = maxStacks + self:GetSpecialValueFor("attribute_stack_bonus")
    end]]

    if currentStack + 1 >= maxStacks then
        self:RootTarget(target)
    else
        target:RemoveModifierByName("modifier_calydonian_hunt")
        target:AddNewModifier(caster, self, "modifier_calydonian_hunt", {
            duration = self:GetDebuffDuration()
        })
        target:SetModifierStackCount("modifier_calydonian_hunt", self, math.min(maxStacks, currentStack + count))
    end
end

function atalanta_calydonian_hunt:RootTarget(target)
    local caster = self:GetCaster()
    local root_cooldown = self:GetSpecialValueFor("root_cooldown")

    if caster.HuntersMarkAcquired then
        root_cooldown = root_cooldown - 1
    end

    if not target:HasModifier("modifier_calydonian_hunt_root_block") and not target:IsMagicImmune() then
        target:RemoveModifierByName("modifier_calydonian_hunt")
        target:AddNewModifier(caster, self, "modifier_calydonian_hunt_sight", { duration = self:GetSpecialValueFor("root_duration") })

        giveUnitDataDrivenModifier(caster, target, "rooted", self:GetSpecialValueFor("root_duration"))
        target:EmitSound("Hero_NagaSiren.Ensnare.Cast")
        target:AddNewModifier(caster, self, "modifier_calydonian_hunt_root_block", { duration = root_cooldown })
    end
end

function atalanta_calydonian_hunt:GetDebuffDuration()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("debuff_duration")

    if caster.HuntersMarkAcquired then
        duration = duration + self:GetSpecialValueFor("attribute_bonus_duration")
    end

    return duration
end

function atalanta_calydonian_hunt:OnSpellStart()
    local caster = self:GetCaster()
    --local detonateDamagePerStack = self:GetSpecialValueFor("detonate_stack")

    caster:EmitSound("Hero_BountyHunter.Target")

    local casterFX = ParticleManager:CreateParticle("particles/econ/items/enchantress/enchantress_lodestar/ench_lodestar_death.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(casterFX, 0, caster:GetOrigin())

    Timers:CreateTimer(1, function()
        ParticleManager:ReleaseParticleIndex(casterFX)
    end)

    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    local sightDuration = self:GetSpecialValueFor("sight_duration") 
    
    if caster.HuntersMarkAcquired then
        sightDuration = sightDuration + self:GetSpecialValueFor("attribute_bonus_duration")

        local slowTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
        for _,v in pairs(slowTargets) do            
            if not IsImmuneToSlow(v) and not v:IsMagicImmune() then
                v:AddNewModifier(caster, self, "modifier_calydonian_hunt_slow", { duration = self:GetSpecialValueFor("slow_duration") })
            end
            --v:EmitSound("Hero_BountyHunter.Target")
        end
    end

    for _,v in pairs(targets) do
        if CanBeDetected(v) then
            v:AddNewModifier(caster, self, "modifier_calydonian_hunt_sight", { duration = self:GetSpecialValueFor("sight_duration") })
            v:EmitSound("Hero_BountyHunter.Target")
        end
    end

    --[[if v:HasModifier("modifier_calydonian_hunt") and (caster:CanEntityBeSeenByMyTeam(v) or caster.GoldenAppleAcquired) then
            v:AddNewModifier(caster, self, "modifier_calydonian_hunt_root", {
                duration = duration
            })
            local stacks = v:GetModifierStackCount("modifier_calydonian_hunt", caster)
            if caster.HuntersMarkAcquired then
                local detonateDamage = detonateDamagePerStack * stacks
                DoDamage(caster, v, detonateDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
                v:RemoveModifierByName("modifier_calydonian_hunt")
            end
        giveUnitDataDrivenModifier(caster, v, "rooted", duration)
        end]]

    --[[if caster.GoldenAppleAcquired and caster:FindAbilityByName("atalanta_golden_apple"):IsCooldownReady() then
        caster:SwapAbilities("atalanta_calydonian_hunt", "atalanta_golden_apple", false, true)
        Timers:CreateTimer(self:GetSpecialValueFor("attribute_swap_duration"), function()
            caster:SwapAbilities("atalanta_golden_apple", "atalanta_calydonian_hunt", false, true)
        end)
    end]]

    if caster:GetStrength() >= 19.1
        and caster:GetAgility() >= 19.1
        and caster:GetIntellect() >= 19.1
        --and caster:HasModifier("modifier_r_used")
        and caster:FindAbilityByName("atalanta_phoebus_catastrophe_snipe"):IsCooldownReady()
    then
        --local modifier = caster:FindModifierByName("modifier_r_used")
	local timeLeft = 4--modifier:GetRemainingTime()

	if timeLeft > 0 then
            if not caster.ComboTimer then
                --caster:SwapAbilities("atalanta_last_spurt", "atalanta_phoebus_catastrophe_barrage", false, true)
                caster:SwapAbilities("atalanta_calydonian_hunt", "atalanta_phoebus_catastrophe_snipe", false, true)
                caster.ComboTimer = Timers:CreateTimer(timeLeft, function()
                    if not caster:HasModifier("modifier_casting_phoebus") then
                        caster.ComboTimer = nil
                        --caster:SwapAbilities("atalanta_phoebus_catastrophe_barrage", "atalanta_last_spurt", false, true)
                        caster:SwapAbilities("atalanta_phoebus_catastrophe_snipe", "atalanta_calydonian_hunt", false, true)
                        return nil
                    else
                        return 0.1
                    end
                end)
            else
                Timers:RemoveTimer(caster.ComboTimer)
                caster.ComboTimer = Timers:CreateTimer(timeLeft, function()
                    if not caster:HasModifier("modifier_casting_phoebus") then
                        caster.ComboTimer = nil
                        --caster:SwapAbilities("atalanta_phoebus_catastrophe_barrage", "atalanta_last_spurt", false, true)
                        caster:SwapAbilities("atalanta_phoebus_catastrophe_snipe", "atalanta_calydonian_hunt", false, true)
                        return nil
                    else
                        return 0.1
                    end
                end)
            end
        end
    end
end

function atalanta_calydonian_hunt:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function atalanta_calydonian_hunt:GetAbilityTextureName()
    return "custom/atalanta_calydonian_hunt"
end