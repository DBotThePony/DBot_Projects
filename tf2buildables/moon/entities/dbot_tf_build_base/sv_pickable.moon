
--
-- Copyright (C) 2017-2018 DBot
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

net.pool('dtf2.movebuildable')

net.receive 'dtf2.movebuildable', (len, ply) ->
	ent = net.ReadEntity()
	return if not IsValid(ent)
	return if not ent.IsTF2Building
	return if not ent\CanBeMoved(ply)
	ent\SetIsMoving(true)
	ent\SetSolid(SOLID_NONE)
	ent\SetNoDraw(true)

	ply\SetDLibVar('dtf2_move', ent)
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
	return if not IsValid(@GetDLibVar('dtf2_move'))
	ent = @GetDLibVar('dtf2_move')
	with dmg
		\SetDamage(math.pow(2, 31) - 1)
		\SetInflictor(@GetActiveWeapon())
		\SetDamageType(DMG_DIRECT\bor(DMG_BLAST, DMG_SLASH))
	ent\SetPos(@GetPos())
	ent\TakeDamageInfo(dmg)

hook.Add 'Think', 'DTF2.CarryBuildables', ->
	for self in *player.GetAll()
		ent = @GetDLibVar('dtf2_move')
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
