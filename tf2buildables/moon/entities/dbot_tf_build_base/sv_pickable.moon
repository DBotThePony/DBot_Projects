
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


net.pool('dtf2.movebuildable')

net.receive 'dtf2.movebuildable', (len, ply) ->
	ent = net.ReadEntity()
	return if not IsValid(ent)
	return if not ent.IsTF2Building
	return if not ent\CanBeMoved(ply)
	ent\SetIsMoving(true)
	ent\SetSolid(SOLID_NONE)
	ent\SetNoDraw(true)

	ply\SetNWEntity('dtf2_move', ent)
	wep = ply\GetWeapon('dbot_tf_buildpda')
	ply\SelectWeapon('dbot_tf_buildpda')

	if ply\GetActiveWeapon() ~= wep
		ply\SetActiveWeapon(wep)

	wep\SetIsMoving(true)
	wep\SetBuildStatus(ent.MoveCategory)
	wep\SetMovingEntity(ent)
	wep\SetBuildRotation(0)
	wep\UpdateModel()
	wep\SendWeaponSequence(wep.BoxDrawAnimation)
	wep\WaitForSequence(wep.BoxIdleAnimation, wep.BoxDrawTimeAnimation)

	timer.Simple 0.1, -> wep\SetBuildRotation(0) if wep\IsValid()

	ent\OnPlayerDoMove(ply, wep)

hook.Add 'DoPlayerDeath', 'DTF2.CarryBuildables', (attacker = NULL, dmg) =>
	return if not @IsPlayer()
	return if not IsValid(@GetNWEntity('dtf2_move'))
	ent = @GetNWEntity('dtf2_move')
	with dmg
		\SetDamage(math.pow(2, 31) - 1)
		\SetInflictor(@GetActiveWeapon())
		\SetDamageType(DMG_DIRECT\bor(DMG_BLAST, DMG_SLASH))
	ent\SetPos(@GetPos())
	ent\TakeDamageInfo(dmg)

hook.Add 'Think', 'DTF2.CarryBuildables', ->
	for self in *player.GetAll()
		ent = @GetNWEntity('dtf2_move')
		if IsValid(ent)
			wep = @GetActiveWeapon()
			if not IsValid(wep) or wep\GetClass() ~= 'dbot_tf_buildpda'
				with dmg = DamageInfo()
					\SetDamage(math.pow(2, 31) - 1)
					\SetAttacker(@)
					\SetInflictor(@)
					\SetDamageType(DMG_DIRECT\bor(DMG_BLAST, DMG_SLASH))
					ent\SetPos(@GetPos())
					ent\TakeDamageInfo(dmg)
