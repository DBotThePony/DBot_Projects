
--
-- Copyright (C) 2017-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


AddCSLuaFile()

DEFINE_BASECLASS('dbot_tf_ranged')

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
		DTF2.ApplyVelocity(ent, vel)
	@EmitSound('DTF2_Player.ScoutShove')
	@SetNextSecondaryFire(CurTime() + 1)
	return true