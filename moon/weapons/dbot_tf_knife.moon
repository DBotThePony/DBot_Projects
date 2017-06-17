
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

BaseClass = baseclass.Get('dbot_tf_melee')

SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Spy'
SWEP.PrintName = 'Knife'
SWEP.ViewModel = 'models/weapons/c_models/c_spy_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_knife/c_knife.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false

SWEP.MissSoundsScript = 'Weapon_Knife.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Knife.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Knife.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Knife.HitFlesh'

SWEP.DrawAnimation = 'knife_draw'
SWEP.IdleAnimation = 'knife_idle'
SWEP.AttackAnimation = 'knife_stab_a'
SWEP.AttackAnimationTable = {'knife_stab_a', 'knife_stab_b'}
SWEP.AttackAnimationCrit = 'knife_stab_c'

SWEP.BackstabAnimation = 'knife_backstab'
SWEP.BackstabAnimationTime = 1
SWEP.BackstabAnimationUp = 'knife_backstab_up'
SWEP.BackstabAnimationUpTime = 0.6
SWEP.BackstabAnimationDown = 'knife_backstab_down'
SWEP.BackstabAnimationDownTime = 0.6
SWEP.BackstabAnimationIdle = 'knife_backstab_idle'

SWEP.BulletDamage = 40
SWEP.DefaultBulletDamage = 40
SWEP.BulletForce = 5
SWEP.CooldownTime = 0.8
SWEP.PreFire = 0.1

SWEP.SelectAttackAnimation = => not @isOnBack and @BaseClass.SelectAttackAnimation(@) or @BackstabAnimation

SWEP.Initialize = =>
    @BaseClass.Initialize(@)
    @isOnBack = false
    @backstabAnimActive = false
    @knifeEntityLookup = NULL
    @ignoreKnifeAnim = 0

SWEP.PreFireTrigger = =>
    @BaseClass.PreFireTrigger(@)
    if @isOnBack
        @BulletDamage = @knifeEntityLookup\Health() * 2
        @incomingCrit = true
        @isOnBack = false
        @backstabAnimActive = false
        @ModifyWaitSequence(@IdleAnimation)
        @ignoreKnifeAnim = CurTime() + @BackstabAnimationTime
    else
        @BulletDamage = @DefaultBulletDamage

SWEP.Think = =>
    mins, maxs = @GetBulletHullVector()
    tr = util.TraceHull({
        start: @GetBulletOrigin()
        endpos: @GetBulletOrigin() + @GetBulletDirection() * @GetBulletRange()
        :mins, :maxs
        filter: {@, @GetOwner()}
    })

    validTarget = IsValid(tr.Entity) and (tr.Entity\IsPlayer() or tr.Entity\IsNPC()) and @AttackingAtSpine(tr.Entity)

    if validTarget
        @knifeEntityLookup = tr.Entity
        if not @isOnBack
            @isOnBack = true
            if @ignoreKnifeAnim < CurTime()
                @backstabAnimActive = true
                @SendWeaponSequence(@BackstabAnimationUp)
                @WaitForSequence(@BackstabAnimationIdle, @BackstabAnimationUpTime)
    else
        @knifeEntityLookup = NULL
        if @isOnBack
            @isOnBack = false
            if @ignoreKnifeAnim < CurTime()
                @backstabAnimActive = false
                @SendWeaponSequence(@BackstabAnimationDown)
                @WaitForSequence(@IdleAnimation, @BackstabAnimationDownTime)
        
        if @ignoreKnifeAnim < CurTime() and @backstabAnimActive
            @backstabAnimActive = false
            @SendWeaponSequence(@BackstabAnimationDown)
            @WaitForSequence(@IdleAnimation, @BackstabAnimationDownTime)
    
    @BaseClass.Think(@)
    return true
