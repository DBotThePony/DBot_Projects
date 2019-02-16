
--
-- Copyright (C) 2017-2019 DBot

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


DEFINE_BASECLASS('dbot_tf_weapon_base')
AddCSLuaFile()

SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Melee Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.SlotPos = 16
SWEP.DamageDegradation = false

SWEP.CritChance = 8
SWEP.CritExponent = 0.25
SWEP.CritExponentMax = 40
SWEP.SingleCrit = true
SWEP.CritsCooldown = 1

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
	'Automatic': true
}

SWEP.SetupDataTables = => BaseClass.SetupDataTables(@)
SWEP.Initialize = => BaseClass.Initialize(@)
SWEP.Think = => BaseClass.Think(@)
SWEP.PreFireTrigger = (...) => BaseClass.PreFireTrigger(@, ...)
SWEP.PrimaryAttack = (...) => BaseClass.PrimaryAttack(@, ...)
SWEP.SelectAttackAnimation = (...) => BaseClass.SelectAttackAnimation(@, ...)
SWEP.Deploy = => BaseClass.Deploy(@)

SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreFire = 0.24
SWEP.BulletRange = 78
SWEP.BulletDamage = 65
SWEP.BulletForce = 20
SWEP.BulletHull = 8

SWEP.PlayMissSound = =>
	if not @incomingCrit
		return @EmitSound('DTF2_' .. @MissSoundsScript) if @MissSoundsScript
		playSound = table.Random(@MissSounds)
		@EmitSound(playSound, 50, 100, 1, CHAN_WEAPON) if playSound
	else
		return @EmitSound('DTF2_' .. @MissCritSoundsScript) if @MissCritSoundsScript
		playSound = table.Random(@MissSoundsCrit)
		@EmitSound(playSound, 50, 100, 1, CHAN_WEAPON) if playSound

SWEP.PlayHitSound = =>
	return @EmitSound('DTF2_' .. @HitSoundsScript) if @HitSoundsScript
	playSound = table.Random(@HitSounds)
	@EmitSound(playSound, 50, 100, 1, CHAN_WEAPON) if playSound

SWEP.PlayFleshHitSound = =>
	return @EmitSound('DTF2_' .. @HitSoundsFleshScript) if @HitSoundsFleshScript
	playSound = table.Random(@HitSoundsFlesh)
	@EmitSound(playSound, 75, 100, 1, CHAN_WEAPON) if playSound

SWEP.OnMiss = =>
	@PlayMissSound()

SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
	BaseClass.OnHit(@, hitEntity, tr, dmginfo)
	if not IsValid(hitEntity)
		@PlayHitSound()
	else
		if hitEntity\IsPlayer() or hitEntity\IsNPC()
			@PlayFleshHitSound()
		else
			@PlayHitSound()
	dmginfo\SetDamageType(DMG_CLUB)
