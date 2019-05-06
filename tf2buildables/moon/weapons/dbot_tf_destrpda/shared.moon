
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

DEFINE_BASECLASS('dbot_tf_weapon_base')

SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Engineer'
SWEP.PrintName = 'Destruction PDA'
SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_pda_engineer/c_pda_engineer.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.DrawAnimation = 'pda_draw'
SWEP.IdleAnimation = 'pda_idle'

SWEP.SLOT_SENTRY = 1
SWEP.SLOT_DISPENSER = 2
SWEP.SLOT_TELE_IN = 3
SWEP.SLOT_TELE_OUT = 4

SWEP.DrawTimeAnimation = 0.9
SWEP.BoxDrawTimeAnimation = 0.9

SWEP.Initialize = =>
	BaseClass.Initialize(@)
	@__InputCache = {} if CLIENT

SWEP.GetBuildAngle = =>
	ply = @GetOwner()
	ang = ply\EyeAngles()
	angReturn = Angle(0, ang.y, 0)
	angReturn.y += @GetBuildRotation() * 90
	return angReturn

SWEP.CheckBuildableAvaliability = (slot = @SLOT_SENTRY) =>
	with @GetOwner()
		switch slot
			when @SLOT_SENTRY
				return not IsValid(\GetBuildedSentry())
			when @SLOT_DISPENSER
				return not IsValid(\GetBuildedDispenser())
			when @SLOT_TELE_IN
				return not IsValid(\GetBuildedTeleporterIn())
			when @SLOT_TELE_OUT
				return not IsValid(\GetBuildedTeleporterOut())

SWEP.TriggerDestructionRequest = (requestType = @SLOT_SENTRY) =>
	ply = @GetOwner()
	return false if not IsValid(ply) or not ply\IsPlayer()
	return false if @CheckBuildableAvaliability(requestType)

	if CLIENT
		net.Start('DTF2.DestroyRequest')
		net.WriteUInt(requestType, 8)
		net.WriteEntity(@)
		net.SendToServer()
		return true

	switch requestType
		when @SLOT_SENTRY
			ply\GetBuildedSentry()\TriggerDestruction()
		when @SLOT_DISPENSER
			ply\GetBuildedDispenser()\TriggerDestruction()
		when @SLOT_TELE_IN
			ply\GetBuildedTeleporterIn()\TriggerDestruction()
		when @SLOT_TELE_OUT
			ply\GetBuildedTeleporterOut()\TriggerDestruction()

	@SwitchToWrench()
	return true

SWEP.PrimaryAttack = => false
SWEP.SecondaryAttack = => false
