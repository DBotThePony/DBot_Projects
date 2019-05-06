
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


AddCSLuaFile 'cl_init.lua'
AddCSLuaFile 'shared.lua'
include 'shared.lua'

util.AddNetworkString('DTF2.BuildRequest')

SWEP.CLASS_SENTRY = 'dbot_tf_sentry'
SWEP.CLASS_DISPENSER = 'dbot_tf_dispenser'
SWEP.CLASS_TELEPORT = 'dbot_tf_teleporter'

SWEP.SENTRY_BUILDUP = {'vo/engineer_autobuildingsentry01.mp3', 'vo/engineer_autobuildingsentry02.mp3'}
SWEP.DISPENSER_BUILDUP = {'vo/engineer_autobuildingdispenser01.mp3', 'vo/engineer_autobuildingdispenser02.mp3'}
SWEP.TELEPORTER_BUILDUP = {'vo/engineer_autobuildingteleporter01.mp3', 'vo/engineer_autobuildingteleporter02.mp3'}

DEFINE_BASECLASS('dbot_tf_weapon_base')

SWEP.OnRemove = =>
	BaseClass.OnRemove(@) if BaseClass.OnRemove
	moving = @GetMovingEntity()
	if IsValid(moving) and moving\Health() > 0
		with dmg = DamageInfo()
			\SetDamage(math.pow(2, 31) - 1)
			\SetAttacker(IsValid(@GetOwner()) and @GetOwner() or @)
			\SetInflictor(@)
			\SetDamageType(DMG_DIRECT\bor(DMG_BLAST, DMG_SLASH))
			moving\SetPos(IsValid(@GetOwner()) and @GetOwner()\GetPos() or @GetPos())
			moving\TakeDamageInfo(dmg)

net.Receive 'DTF2.BuildRequest', (len = 0, ply = NULL) ->
	return if not IsValid(ply)
	slot = net.ReadUInt(8)
	ent = net.ReadEntity()
	return if not IsValid(ply)
	return if ent\GetClass() ~= 'dbot_tf_buildpda'
	ent\TriggerBuildRequest(slot)

holster = (ply, wep) =>
	ply\SetActiveWeapon(wep)
	ply\SelectWeapon(wep)
	@Holster()

SWEP.SwitchToWrench = =>
	weapon_crowbar = false
	dbot_tf_wrench = false
	ply = @GetOwner()
	return false if not IsValid(ply) or not ply\IsPlayer()
	for _, wep in pairs ply\GetWeapons()
		switch wep\GetClass()
			when 'weapon_crowbar'
				weapon_crowbar = true
			when 'dbot_tf_wrench'
				dbot_tf_wrench = true
	if dbot_tf_wrench
		holster(@, ply, 'dbot_tf_wrench')
		return true
	elseif weapon_crowbar
		holster(@, ply, 'weapon_crowbar')
		return true
	return false

SWEP.TriggerBuild = =>
	status, tr = @CalcAndCheckBuildSpot()
	return false if not status
	return false if @GetBuildStatus() == @BUILD_NONE
	ply = @GetOwner()
	local ent
	status = @GetBuildStatus()
	switch status
		when @BUILD_SENTRY
			ent = ents.Create(@GetBuildSentryClass())
			ply\SetBuildedSentry(ent)
			ply\EmitSound(table.Random(@SENTRY_BUILDUP), 55, 100, 1)
		when @BUILD_DISPENSER
			ent = ents.Create(@CLASS_DISPENSER)
			ply\SetBuildedDispenser(ent)
			ply\EmitSound(table.Random(@DISPENSER_BUILDUP), 55, 100, 1)
		when @BUILD_TELE_IN
			ent = ents.Create(@CLASS_TELEPORT)
			ply\SetBuildedTeleporterIn(ent)
			ply\EmitSound(table.Random(@TELEPORTER_BUILDUP), 55, 100, 1)
		when @BUILD_TELE_OUT
			ent = ents.Create(@CLASS_TELEPORT)
			ply\SetBuildedTeleporterOut(ent)
			ply\EmitSound(table.Random(@TELEPORTER_BUILDUP), 55, 100, 1)
		when @MOVE_SENTRY, @MOVE_DISPENSER, @MOVE_TELE_IN, @MOVE_TELE_OUT
			ent = @GetMovingEntity()

			if not IsValid(ent)
				@SetBuildStatus(@BUILD_NONE)
				return NULL

			@GetOwner()\SetNWEntity('dtf2_move', NULL)
			@SetMovingEntity(NULL)

			ent\SetPos(tr.HitPos)
			ent\SetAngles(@GetBuildAngle())

			if not ent.InstantBuildableMove\GetBool()
				ent\SetAfterMove(true)
				ent\SetIsMovable(true)
				ent\SetIsMoving(false)

				ent\SetTargetLevel(ent\GetLevel())
				ent\SetLevel(1, false)
				ent\SetBuildStatus(true, true)

			ent\SetSolid(SOLID_BBOX)
			ent\SetNoDraw(false)
			ent\OnMoved(@GetOwner(), @)

			@SetBuildStatus(@BUILD_NONE)
			@UpdateModel()
			@SendWeaponSequence(@IdleAnimation)
			@SwitchToWrench()

			return true

	return false if not IsValid(ent)

	ang = @GetBuildAngle()
	ent\SetPos(tr.HitPos)
	ent\SetAngles(ang)
	ent\Spawn()
	ent\Activate()
	ent\SetAngles(ang)
	ent\SetTFPlayer(ply)
	ent\SetBuildStatus(true)
	ent\SetIsMovable(true)
	@SetBuildStatus(@BUILD_NONE)
	@UpdateModel()
	@SendWeaponSequence(@IdleAnimation)
	ent\CPPISetOwner(@GetOwner()) if ent.CPPISetOwner
	@SwitchToWrench()
	switch status
		when @BUILD_TELE_IN
			tele2 = ply\GetBuildedTeleporterOut()
			if IsValid(tele2)
				tele2\SetupAsExit(ent)
		when @BUILD_TELE_OUT
			tele2 = ply\GetBuildedTeleporterIn()
			if IsValid(tele2)
				tele2\SetupAsEntrance(ent)
	return ent
