
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

BaseClass = baseclass.Get('dbot_tf_weapon_base')

SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Reloadable Weapon Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.SlotPos = 16
SWEP.Slot = 3

SWEP.DrawAnimation = 'dh_draw'
SWEP.IdleAnimation = 'dh_idle'
SWEP.AttackAnimation = 'dh_fire'
SWEP.AttackAnimationCrit = 'dh_fire'
SWEP.ReloadStart = 'dh_reload_start'
SWEP.ReloadLoop = 'dh_reload_loop'
SWEP.ReloadEnd = 'dh_reload_finish'

SWEP.TakeBulletsOnFire = 1
SWEP.ProjectileClass = 'dbot_tf_rocket_projectile'
SWEP.ReloadBullets = 1
SWEP.ReloadTime = 1
SWEP.ReloadDeployTime = 1
SWEP.ReloadFinishAnimTimeIdle = 1
SWEP.ReloadLoopRestart = true
SWEP.ReloadPlayExtra = false
SWEP.SingleReloadAnimation = false

SWEP.Primary = {
    'Ammo': 'SMG1'
    'ClipSize': 40
    'DefaultClip': 160
    'Automatic': true
}

SWEP.Secondary = {
    'Ammo': 'none'
    'ClipSize': -1
    'DefaultClip': 0
    'Automatic': false
}

AccessorFunc(SWEP, 'isReloading', 'IsReloading')
AccessorFunc(SWEP, 'reloadNext', 'NextReload')

SWEP.Initialize = =>
    BaseClass.Initialize(@)
    @isReloading = false
    @reloadNext = 0

SWEP.Reload = =>
    return false if @Clip1() == @GetMaxClip1()
    return false if @isReloading
    return false if @GetNextPrimaryFire() > CurTime()
    return false if @GetOwner()\IsPlayer() and (@Primary.Ammo ~= 'none' and @GetOwner()\GetAmmoCount(@Primary.Ammo) <= 0)
    @isReloading = true
    @reloadNext = CurTime() + @ReloadDeployTime
    @SendWeaponSequence(@ReloadStart)
    @ClearTimeredAnimation()
    return true

SWEP.ReloadCall = =>
    oldClip = @Clip1()
    newClip = math.Clamp(oldClip + @ReloadBullets, 0, @GetMaxClip1())
    if SERVER
        @SetClip1(newClip)
        @GetOwner()\RemoveAmmo(newClip - oldClip, @Primary.Ammo) if @GetOwner()\IsPlayer() and @Primary.Ammo ~= 'none'
    return oldClip, newClip

SWEP.Think = =>
    BaseClass.Think(@)
    if (SERVER or @GetOwner() == LocalPlayer()) and @isReloading and @reloadNext < CurTime()
        if @GetOwner()\IsPlayer() and (@Primary.Ammo == 'none' or @GetOwner()\GetAmmoCount(@Primary.Ammo) > 0)
            @reloadNext = CurTime() + @ReloadTime
            oldClip, newClip = @ReloadCall()
            if not @SingleReloadAnimation
                if @ReloadLoopRestart
                    @SendWeaponSequence(@ReloadLoop)
                else
                    @SendWeaponSequence(@ReloadLoop) if not @reloadLoopStart
                    @reloadLoopStart = true
            if newClip == @GetMaxClip1()
                @isReloading = false
                @reloadLoopStart = false
                if not @SingleReloadAnimation
                    if @ReloadLoopRestart
                        if @ReloadPlayExtra
                            @WaitForSequence(@ReloadLoop, @ReloadTime,
                                (-> if IsValid(@) then @WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime,
                                    (-> if IsValid(@) then @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)))))
                        else
                            @WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime,
                                (-> if IsValid(@) then @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)))
                    else
                        @WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime, (-> @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle) if IsValid(@)))
                else
                    @SendWeaponSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)
        elseif @GetOwner()\IsPlayer() and (@Primary.Ammo ~= 'none' and @GetOwner()\GetAmmoCount(@Primary.Ammo) <= 0) or newClip == @GetMaxClip1()
            @isReloading = false
            @reloadLoopStart = false
            if not @SingleReloadAnimation
                if @ReloadLoopRestart
                    @WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime,
                        (-> if IsValid(@) then @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)))
                else
                    @WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime, (-> @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle) if IsValid(@)))
            else
                @SendWeaponSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)
    @NextThink(CurTime() + 0.1)
    return true

SWEP.Deploy = =>
    BaseClass.Deploy(@)
    @isReloading = false
    @lastEmptySound = 0
    return true

SWEP.OnHit = (...) => BaseClass.OnHit(@, ...)
SWEP.OnMiss = => BaseClass.OnMiss(@)

SWEP.PrimaryAttack = =>
    return false if @GetNextPrimaryFire() > CurTime()
    if @Clip1() <= 0
        @Reload()
        return false
    
    status = BaseClass.PrimaryAttack(@)
    return status if status == false
    
    @isReloading = false
    @TakePrimaryAmmo(@TakeBulletsOnFire)
    
    return true