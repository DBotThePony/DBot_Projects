
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


DEFINE_BASECLASS('dbot_tf_clipbased')
AddCSLuaFile()

SWEP.Base = 'dbot_tf_clipbased'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Projectiled Weapon Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.SlotPos = 16
SWEP.DamageDegradation = false
SWEP.Slot = 3
SWEP.DefaultViewPunch = Angle(0, 0, 0)
SWEP.FireOffset = Vector(0, -10, 0)

SWEP.DrawAnimation = 'dh_draw'
SWEP.IdleAnimation = 'dh_idle'
SWEP.AttackAnimation = 'dh_fire'
SWEP.AttackAnimationCrit = 'dh_fire'
SWEP.ReloadStart = 'dh_reload_start'
SWEP.ReloadLoop = 'dh_reload_loop'
SWEP.ReloadEnd = 'dh_reload_finish'

SWEP.Primary = {
	'Ammo': 'RPG_Round'
	'ClipSize': 4
	'DefaultClip': 4
	'Automatic': true
}

SWEP.Secondary = {
	'Ammo': 'none'
	'ClipSize': -1
	'DefaultClip': 0
	'Automatic': false
}

SWEP.PreFireTrigger = =>
SWEP.PostFireTrigger = =>
SWEP.EmitMuzzleFlash = =>
SWEP.GetViewPunch = => @DefaultViewPunch
SWEP.Initialize = => BaseClass.Initialize(@)
SWEP.Holster = => BaseClass.Holster(@)
SWEP.HANDLE_FIRE_SOUND = true
SWEP.PlayFireSound = (isCrit = @incomingCrit) =>
	if not isCrit
		return @EmitSound('DTF2_' .. @FireSoundsScript) if @FireSoundsScript
		playSound = table.Random(@FireSounds) if @FireSounds
		@EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound
	else
		return @EmitSound('DTF2_' .. @FireCritSoundsScript) if @FireCritSoundsScript
		playSound = table.Random(@FireCritSounds) if @FireCritSounds
		@EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound

SWEP.PrimaryAttack = =>
	return false if @GetNextPrimaryFire() > CurTime()
	status = BaseClass.PrimaryAttack(@)
	return status if status == false

	@PlayFireSound() if @HANDLE_FIRE_SOUND
	@GetOwner()\ViewPunch(@GetViewPunch())

	if game.SinglePlayer() and SERVER
		@CallOnClient('EmitMuzzleFlash')
	if CLIENT and @GetOwner() == LocalPlayer() and @lastMuzzle ~= FrameNumber()
		@lastMuzzle = FrameNumber()
		@EmitMuzzleFlash()

	return true

SWEP.Think = => BaseClass.Think(@)
