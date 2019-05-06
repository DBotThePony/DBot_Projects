
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

DEFINE_BASECLASS('dbot_tf_clipbased')

SWEP.Base = 'dbot_tf_clipbased'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Ranged Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.Slot = 2
SWEP.SlotPos = 16

SWEP.Primary = {
	'Ammo': 'SMG1'
	'ClipSize': 15
	'DefaultClip': 40
	'Automatic': true
}

SWEP.Secondary = {
	'Ammo': 'none'
	'ClipSize': -1
	'DefaultClip': 0
	'Automatic': false
}

SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreFire = 0.05
SWEP.ReloadDeployTime = 0.4
SWEP.ReloadTime = 0.5
SWEP.ReloadFinishAnimTime = 0.3
SWEP.ReloadFinishAnimTimeIdle = 0.96
SWEP.ReloadBullets = 15
SWEP.TakeBulletsOnFire = 1
SWEP.CooldownTime = 0.7
SWEP.BulletDamage = 12
SWEP.DefaultSpread = Vector(0, 0, 0)
SWEP.BulletsAmount = 1

SWEP.DefaultViewPunch = Angle(0, 0, 0)

SWEP.MuzzleAttachment = 'muzzle'

SWEP.CritChance = 2
SWEP.CritExponent = 0.05
SWEP.CritExponentMax = 10
SWEP.SingleCrit = false

SWEP.SetupDataTables = => BaseClass.SetupDataTables(@)

AccessorFunc(SWEP, 'lastEmptySound', 'LastEmptySound')

SWEP.Initialize = =>
	BaseClass.Initialize(@)
	@lastEmptySound = 0

SWEP.Deploy = =>
	BaseClass.Deploy(@)
	@lastEmptySound = 0
	return true

SWEP.GetBulletSpread = => @DefaultSpread
SWEP.GetBulletAmount = => @BulletsAmount
SWEP.GetViewPunch = => @DefaultViewPunch

SWEP.Think = => BaseClass.Think(@)

SWEP.ClientBulletOriginShift = Vector(0, 0, 10)

SWEP.GetBulletOrigin = =>
	if SERVER
		return @GetOwner()\EyePos()
	else
		viewModel = @GetTF2WeaponModel()
		if muzzle = viewModel\GetAttachment(viewModel\LookupAttachment(@MuzzleAttachment))
			{:Pos, :Ang} = muzzle
			Pos += @ClientBulletOriginShift
			return Pos

SWEP.GetBulletDirection = =>
	if SERVER
		@GetOwner()\GetAimVector()
	else
		viewModel = @GetTF2WeaponModel()
		if muzzle = viewModel\GetAttachment(viewModel\LookupAttachment(@MuzzleAttachment))
			{:Pos, :Ang} = muzzle
			Pos += @ClientBulletOriginShift
			dir = @GetOwner()\GetEyeTrace().HitPos - Pos
			dir\Normalize()
			return dir

SWEP.UpdateBulletData = (bulletData = {}) =>
	bulletData.Spread = @GetBulletSpread()
	bulletData.Num = @GetBulletAmount()

SWEP.PlayFireSound = (isCrit = @incomingCrit) =>
	if not isCrit
		return @EmitSound('DTF2_' .. @FireSoundsScript) if @FireSoundsScript
		playSound = table.Random(@FireSounds) if @FireSounds
		@EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound
	else
		return @EmitSound('DTF2_' .. @FireCritSoundsScript) if @FireCritSoundsScript
		playSound = table.Random(@FireCritSounds) if @FireCritSounds
		@EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound

SWEP.EmitMuzzleFlash = =>
	viewModel = @GetTF2WeaponModel()
	{:Pos, :Ang} = viewModel\GetAttachment(viewModel\LookupAttachment(@MuzzleAttachment))
	emmiter = ParticleEmitter(Pos, false)
	return if not emmiter
	for i = 1, math.random(3, 5)
		with emmiter\Add('effects/muzzleflash' .. math.random(1, 4), Pos)
			\SetDieTime(0.1)
			size = math.random(20, 60) / 6
			\SetStartSize(size)
			\SetEndSize(size)
			\SetColor(255, 255, 255)
			\SetRoll(math.random(-180, 180))
	emmiter\Finish()

SWEP.OnHit = (...) => BaseClass.OnHit(@, ...)
SWEP.OnMiss = => BaseClass.OnMiss(@)
SWEP.AfterFire = (bulletData = {}) =>

SWEP.PrimaryAttack = =>
	return false if @GetNextPrimaryFire() > CurTime()
	status = BaseClass.PrimaryAttack(@)
	return status if status == false

	@PlayFireSound()

	@GetOwner()\ViewPunch(@GetViewPunch())

	if game.SinglePlayer() and SERVER
		@CallOnClient('EmitMuzzleFlash')
	if CLIENT and @GetOwner() == LocalPlayer() and @lastMuzzle ~= FrameNumber()
		@lastMuzzle = FrameNumber()
		@EmitMuzzleFlash()

	return true
