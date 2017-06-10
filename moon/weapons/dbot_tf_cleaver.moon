

--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

AddCSLuaFile()

BaseClass = baseclass.Get('dbot_tf_weapon_base')

SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Flying Guillotine'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.CleaverRestoreTime = 10

SWEP.IdleAnimation = 'ed_idle'
SWEP.DrawAnimation = 'ed_draw'
SWEP.AttackAnimation = 'ed_throw'
SWEP.AttackAnimationCrit = 'ed_throw'

SWEP.AttackAnimationDuration = 1

SWEP.CleaverIsReady = => @GetCleaverReady() >= @CleaverRestoreTime
SWEP.PreDrawViewModel = (vm) => @vmModel = vm

SWEP.SetupDataTables = =>
    @BaseClass.SetupDataTables(@)
    @NetworkVar('Float', 16, 'CleaverReady')
    @NetworkVar('Float', 17, 'HideCleaver') -- fuck singleplayer
    @NetworkVar('Entity', 16, 'TF2BallModel')

SWEP.Initialize = =>
    @BaseClass.Initialize(@)
    @SetCleaverReady(@CleaverRestoreTime)
    @lastCleaverThink = CurTime()
    @lastCleaverStatus = true
    @SetHideCleaver(0)

SWEP.Think = =>
    @BaseClass.Think(@)
    if SERVER
        delta = CurTime() - @lastCleaverThink
        @lastCleaverThink = CurTime()
        if @GetCleaverReady() < @CleaverRestoreTime
            @SetCleaverReady(math.Clamp(@GetCleaverReady() + delta, 0, @CleaverRestoreTime))
    
    old = @lastCleaverStatus
    newStatus = @CleaverIsReady()

    @vmModel\SetNoDraw(not newStatus and @GetHideCleaver() < CurTime()) if IsValid(@vmModel)

    if old ~= newStatus
        @lastCleaverStatus = newStatus
        if newStatus
            @SendWeaponSequence(@DrawAnimation)
            @WaitForSequence(@IdleAnimation, @AttackAnimationDuration)

SWEP.DrawHUD = => DTF2.DrawCenteredBar(@GetCleaverReady() / @CleaverRestoreTime, 'Cleaver')
SWEP.PrimaryAttack = =>
    return false if not @CleaverIsReady()
    incomingCrit = @CheckNextCrit()
    @SetCleaverReady(0)
    @lastCleaverStatus = false
    @SendWeaponSequence(@AttackAnimation)
    @WaitForSequence(@IdleAnimation, @AttackAnimationDuration)
    @SetHideCleaver(CurTime() + @AttackAnimationDuration)
    return if CLIENT
    timer.Simple 0, ->
        return if not IsValid(@) or not IsValid(@GetOwner())
        with ents.Create('dbot_cleaver_projectile')
            \SetPos(@GetOwner()\EyePos())
            \Spawn()
            \Activate()
            \SetIsCritical(incomingCrit)
            \SetOwner(@GetOwner())
            \SetAttacker(@GetOwner())
            \SetInflictor(@)
            \SetDirection(@GetOwner()\GetAimVector())
