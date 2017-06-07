
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

BaseClass = baseclass.Get('dbot_tf_ranged')

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Force-A-Nature'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_double_barrel.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.SingleCrit = true

SWEP.MuzzleAttachment = 'muzzle'

SWEP.BulletDamage = 5,4
SWEP.BulletsAmount = 12
SWEP.ReloadBullets = 2
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.07

SWEP.DefaultViewPunch = Angle(-5, 0, 0)

SWEP.FireSoundsScript = 'Weapon_Scatter_Gun_Double.Single'
SWEP.FireCritSoundsScript = 'Weapon_Scatter_Gun_Double.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Scatter_Gun_Double.Empty'

SWEP.Primary = {
    'Ammo': 'Buckshot'
    'ClipSize': 2
    'DefaultClip': 2
    'Automatic': true
}

SWEP.CooldownTime = 0.3
SWEP.ReloadDeployTime = 1.4
SWEP.DrawAnimation = 'db_draw'
SWEP.IdleAnimation = 'db_idle'
SWEP.AttackAnimation = 'db_fire'
SWEP.AttackAnimationCrit = 'db_fire'
SWEP.ReloadStart = 'db_reload'
SWEP.SingleReloadAnimation = true

SWEP.AfterFire = (bulletData) =>
    BaseClass.AfterFire(bulletData)
    Dir = bulletData.Dir
    DTF2.ApplyVelocity(@GetOwner(), -Dir * 300) if not @GetOwner()\OnGround()

SWEP.OnHit = (ent, ...) =>
    BaseClass.OnHit(@, ent, ...)
    if SERVER and IsValid(ent)
        pos = ent\GetPos()
        lpos = @GetOwner()\GetPos()
        dir = pos - lpos
        dir\Normalize()
        vel = dir * 200 + Vector(0, 0, 30)
        vel *= 10000 / pos\DistToSqr(lpos)
        DTF2.ApplyVelocity(ent, vel)

SWEP.ReloadCall = =>
    oldClip = @Clip1()
    newClip = 2
    if SERVER
        @SetClip1(2)
        @GetOwner()\RemoveAmmo(2, @Primary.Ammo) if @GetOwner()\IsPlayer()
    return oldClip, newClip
