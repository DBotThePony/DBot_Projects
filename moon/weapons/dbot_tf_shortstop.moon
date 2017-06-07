
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
SWEP.PrintName = 'Shortstop'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shortstop/c_shortstop.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.SingleCrit = true

SWEP.MuzzleAttachment = 'muzzle'

SWEP.BulletDamage = 12
SWEP.BulletsAmount = 4
SWEP.ReloadBullets = 4
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.05

SWEP.DefaultViewPunch = Angle(-3, 0, 0)

SWEP.FireSoundsScript = 'Weapon_Short_Stop.Single'
SWEP.FireCritSoundsScript = 'Weapon_Short_Stop.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Short_Stop.Empty'

SWEP.Primary = {
    'Ammo': 'Buckshot'
    'ClipSize': 4
    'DefaultClip': 4
    'Automatic': true
}

SWEP.CooldownTime = 0.35
SWEP.ReloadDeployTime = 1.3
SWEP.DrawAnimation = 'ss_draw'
SWEP.IdleAnimation = 'ss_idle'
SWEP.AttackAnimation = 'ss_fire'
SWEP.AttackAnimationCrit = 'ss_fire'
SWEP.ReloadStart = 'ss_reload'
SWEP.SingleReloadAnimation = true

SWEP.SecondaryAttack = =>
    trace = @GetOwner()\GetEyeTrace()
    lpos = @GetOwner()\GetPos()
    return if not IsValid(trace.Entity) or trace.Entity\GetPos()\Distance(lpos) > 130
    if SERVER
        ent = trace.Entity
        dir = ent\GetPos() - lpos
        dir\Normalize()
        
        vel = dir * 300 + Vector(0, 0, 200)
        if not ent\IsPlayer() and not ent\IsNPC()
            for i = 0, ent\GetPhysicsObjectCount() - 1
                phys = ent\GetPhysicsObjectNum(i)
                phys\AddVelocity(vel) if IsValid(phys)
        else
            ent\SetVelocity(vel + Vector(0, 0, 100))
    @EmitSound('Player.ScoutShove')
    @SetNextSecondaryFire(CurTime() + 1)
    return true