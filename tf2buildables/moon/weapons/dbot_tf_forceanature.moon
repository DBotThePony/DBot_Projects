
--
-- Copyright (C) 2017-2018 DBot

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
SWEP.PrintName = 'Force-A-Nature'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_double_barrel.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.SingleCrit = true

SWEP.MuzzleAttachment = 'muzzle'

SWEP.BulletDamage = 5.4
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

SWEP.Think = => BaseClass.Think(@)

SWEP.CooldownTime = 0.3
SWEP.ReloadDeployTime = 1.4
SWEP.DrawAnimation = 'db_draw'
SWEP.IdleAnimation = 'db_idle'
SWEP.AttackAnimation = 'db_fire'
SWEP.AttackAnimationCrit = 'db_fire'
SWEP.ReloadStart = 'db_reload'
SWEP.SingleReloadAnimation = true

SWEP.SetupDataTables = => BaseClass.SetupDataTables(@)

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
