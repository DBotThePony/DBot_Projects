

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

SWEP.ProjectileRestoreTime = 10

SWEP.IdleAnimation = 'ed_idle'
SWEP.DrawAnimation = 'ed_draw'
SWEP.AttackAnimation = 'ed_throw'
SWEP.AttackAnimationCrit = 'ed_throw'

SWEP.AttackAnimationDuration = 1
SWEP.ProjectileClass = 'dbot_cleaver_projectile'

SWEP.ProjectileIsReady = => @GetProjectileReady() >= @ProjectileRestoreTime
SWEP.PreDrawViewModel = (vm) => @vmModel = vm

SWEP.Primary = {
    'Ammo': 'none'
    'ClipSize': -1
    'DefaultClip': 0
    'Automatic': true
}

SWEP.Secondary = {
    'Ammo': 'none'
    'ClipSize': -1
    'DefaultClip': 0
    'Automatic': false
}

SWEP.SetupDataTables = =>
    BaseClass.SetupDataTables(@)
    @NetworkVar('Float', 16, 'ProjectileReady')
    @NetworkVar('Float', 17, 'HideProjectile') -- fuck singleplayer

SWEP.Initialize = =>
    BaseClass.Initialize(@)
    @SetProjectileReady(@ProjectileRestoreTime)
    @lastProjectileThink = CurTime()
    @lastProjectileStatus = true
    @SetHideProjectile(0)

SWEP.Think = =>
    BaseClass.Think(@)
    if SERVER
        delta = CurTime() - @lastProjectileThink
        @lastProjectileThink = CurTime()
        if @GetProjectileReady() < @ProjectileRestoreTime
            @SetProjectileReady(math.Clamp(@GetProjectileReady() + delta, 0, @ProjectileRestoreTime))
    
    old = @lastProjectileStatus
    newStatus = @ProjectileIsReady()

    @vmModel\SetNoDraw(not newStatus and @GetHideProjectile() < CurTime()) if IsValid(@vmModel)

    if old ~= newStatus
        @lastProjectileStatus = newStatus
        if newStatus
            @SendWeaponSequence(@DrawAnimation)
            @WaitForSequence(@IdleAnimation, @AttackAnimationDuration)

SWEP.DrawHUD = => DTF2.DrawCenteredBar(@GetProjectileReady() / @ProjectileRestoreTime, 'Cleaver')
SWEP.PrimaryAttack = =>
    return false if not @ProjectileIsReady()
    incomingCrit = @CheckNextCrit()
    @SetProjectileReady(0)
    @lastProjectileStatus = false
    @SendWeaponSequence(@AttackAnimation)
    @WaitForSequence(@IdleAnimation, @AttackAnimationDuration)
    @SetHideProjectile(CurTime() + @AttackAnimationDuration)
    return if CLIENT
    timer.Simple 0, ->
        return if not IsValid(@) or not IsValid(@GetOwner())
        with ents.Create(@ProjectileClass)
            \SetPos(@GetOwner()\EyePos())
            \Spawn()
            \Activate()
            \SetIsCritical(incomingCrit)
            \SetOwner(@GetOwner())
            \SetAttacker(@GetOwner())
            \SetInflictor(@)
            \SetDirection(@GetOwner()\GetAimVector())
