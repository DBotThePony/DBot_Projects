
-- Copyright (C) 2019 DBot

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

import NBT from DLib
import luatype from _G

class DTransitions.PlayerSerializer extends DTransitions.EntitySerializerBase
	@SAVENAME = 'player'

	CanSerialize: (ent) => ent\IsPlayer()
	GetPriority: => 1000

	BuildAmmoTypes: =>
		@ammoTypesRaw = {}
		i = 1
		ammotype = game.GetAmmoName(i)

		while ammotype
			@ammoTypesRaw[i] = ammotype
			i += 1
			ammotype = game.GetAmmoName(i)

		@maxAmmoTypes = i - 1


	Tell: (tag) =>
		@BuildAmmoTypes()
		@ammoMapping = {}
		return if not tag\HasTag('ammotypes')

		for name, index in pairs(tag\GetTagValue('ammotypes'))
			for index2, name2 in ipairs(@ammoTypesRaw)
				if name2 == name
					@ammoMapping[index] = index2
					break

	Ask: (tag) =>
		@BuildAmmoTypes()
		list = NBT.TagCompound()

		for id, name in ipairs(@ammoTypesRaw)
			list\SetShort(name, id)

		tag\AddTag('ammotypes', list)

	@PLAYER_STRUCT = {
		{'AllowFullRotation', 'Bool'}
		{'AllowWeaponsInVehicle', 'Bool'}
		{'AvoidPlayers', 'Bool'}
		{'CanWalk', 'Bool'}
		{'CanZoom', 'Bool'}
		{'FOV', 'Short', nil, 0}
		{'EntityInUse', 'Entity'}
		{'DrivingEntity', 'Entity'}
		{'DrivingMode', 'Byte'}
		{'JumpPower', 'Short'}
		{'LaggedMovementValue', 'Float'}
		{'ObserverMode', 'Byte'}
		{'ObserverTarget', 'Entity'}
		{'PlayerColor', 'Vector'}
		{'StepSize', 'Short'}
		{'ViewEntity', 'Entity'}
		{'ViewModel', 'Entity'}
		{'ViewOffset', 'Vector'}
		{'ViewOffsetDucked', 'Vector'}
		{'ViewPunchAngles', 'Angle'}
		{'WeaponColor', 'Vector'}
	}

	Serialize: (ply) =>
		tag = NBT.TagCompound()
		@SerializePosition(ply, tag)
		@SerializeGeneric(ply, tag)
		@SerializeCombatState(ply, tag)

		tag\SetString('steamid', ply\SteamID())

		tag\SetShort('team', ply\Team())
		tag\SetShort('frags', ply\Frags())
		tag\SetShort('deaths', ply\Deaths())
		tag\SetByte('alive', ply\Alive() and 1 or 0)
		tag\SetByte('suit', ply\IsSuitEquipped() and 1 or 0)
		tag\SetBool('godmode', ply\HasGodMode())

		tag\SetShort('walk_speed', ply\GetWalkSpeed())
		tag\SetShort('walk_speed_duck', ply\GetCrouchedWalkSpeed())
		tag\SetShort('run_speed', ply\GetRunSpeed())
		tag\SetInt('active_weapon', @saveInstance\GetEntityID(ply\GetActiveWeapon())) if IsValid(ply\GetActiveWeapon())

		tag\SetInt('vehicle', @saveInstance\GetEntityID(ply\GetVehicle())) if IsValid(ply\GetVehicle())

		mins, maxs = ply\GetHull()
		tag\SetVector('hull_mins', mins)
		tag\SetVector('hull_maxs', maxs)

		mins, maxs = ply\GetHullDuck()
		tag\SetVector('hull_duck_mins', mins)
		tag\SetVector('hull_duck_maxs', maxs)

		tag\SetVector('velocity', ply\GetVelocity())

		ammo = tag\AddTagList('ammo', NBT.TYPEID.TAG_Short)
		ammo\AddValue(ply\GetAmmoCount(i)) for i = 1, @maxAmmoTypes

		@QuickSerializeObj(tag, ply, @@PLAYER_STRUCT)

		return tag

	DeserializePre: (tag) =>
		ply = player.GetBySteamID(tag\GetTagValue('steamid'))
		return NULL if not ply

		if tag\GetTagValue('alive') == 0 and ply\Alive()
			ply\StripAmmo()
			ply\StripWeapons()
			ply\Kill()
		elseif tag\GetTagValue('alive') == 1 and not ply\Alive()
			ply\Spawn()

		ply\StripAmmo()
		ply\StripWeapons()

		for i, ammoAmount in ipairs(tag\GetTagValue('ammo'))
			if realAmmoID = @ammoMapping[i]
				ply\GiveAmmo(ammoAmount, realAmmoID, true)

		@DeserializePosition(ply, tag)
		@DeserializeGeneric(ply, tag)
		@DeserializeCombatState(ply, tag)

		ply\SetTeam(tag\GetTagValue('team'))
		ply\SetFrags(tag\GetTagValue('frags'))
		ply\SetDeaths(tag\GetTagValue('deaths'))
		ply\SetDeaths(tag\GetTagValue('deaths'))

		ply\EquipSuit() if tag\GetTagValue('suit') == 1
		ply\RemoveSuit() if tag\GetTagValue('suit') == 0

		ply\GodEnable() if tag\GetTagValue('godmode') == 1
		ply\GodDisable() if tag\GetTagValue('godmode') == 0

		ply\SetWalkSpeed(tag\GetTagValue('walk_speed'))
		ply\SetCrouchedWalkSpeed(tag\GetTagValue('walk_speed_duck'))
		ply\SetRunSpeed(tag\GetTagValue('run_speed'))

		ply\SetHull(tag\GetVector('hull_mins'), tag\GetVector('hull_maxs'))
		ply\SetHullDuck(tag\GetVector('hull_duck_mins'), tag\GetVector('hull_duck_maxs'))

		ply\SetVelocity(tag\GetVector('velocity') - ply\GetVelocity())

		@QuickDeserializeObj(tag, ply, @@PLAYER_STRUCT, false)

		return ply

	DeserializePost: (ply, tag) =>
		if tag\HasTag('vehicle')
			vehicle = @saveInstance\GetEntity(tag\GetTagValue('vehicle'))
			ply\EnterVehicle(vehicle) if IsValid(vehicle)

		if tag\HasTag('active_weapon')
			active_weapon = @saveInstance\GetEntity(tag\GetTagValue('active_weapon'))
			ply\SelectWeapon(active_weapon\GetClass()) if IsValid(active_weapon)

		@QuickDeserializeObj(tag, ply, @@PLAYER_STRUCT, true)
