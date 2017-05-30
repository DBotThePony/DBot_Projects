
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

include 'shared.lua'
AddCSLuaFile 'shared.lua'

BaseClass = baseclass.Get('dbot_tf_weapon_base')

SWEP.Think = =>
    BaseClass.Think(@)
    if @isReloading and @reloadNext < CurTime()
        if @GetOwner()\IsPlayer() and @GetOwner()\GetAmmoCount(@Primary.Ammo) > 0
            @reloadNext = CurTime() + @ReloadTime
            oldClip = @Clip1()
            newClip = math.Clamp(oldClip + @ReloadBullets, 0, @GetMaxClip1())
            @SetClip1(newClip)
            @GetOwner()\RemoveAmmo(newClip - oldClip, @Primary.Ammo) if @GetOwner()\IsPlayer()
            @SendWeaponAnim(ACT_VM_RELOAD)
            if newClip == @GetMaxClip1()
                @isReloading = false
                @WaitForAnimation(ACT_RELOAD_FINISH, @ReloadFinishAnimTime, (-> @WaitForAnimation(ACT_VM_IDLE, @ReloadFinishAnimTimeIdle) if IsValid(@)))
        elseif @GetOwner()\IsPlayer() and @GetOwner()\GetAmmoCount(@Primary.Ammo) <= 0 or newClip == @GetMaxClip1()
            @isReloading = false
            @WaitForAnimation(ACT_RELOAD_FINISH, @ReloadFinishAnimTime, (-> @WaitForAnimation(ACT_VM_IDLE, @ReloadFinishAnimTimeIdle) if IsValid(@)))
    @NextThink(CurTime() + 0.1)
    return true
