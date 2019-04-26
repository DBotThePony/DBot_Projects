
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

class DTransitions.EntitySerializerBase
	new: (saveInstance) =>
		@saveInstance = saveInstance

	CanSerialize: (ent) => false
	GetPriority: => 0
	Serialize: (ent) => error('Not implemented')

	DeserializePre: (tag) => error('Not implemented')
	DeserializePost: (ent, tag) =>

	DeserializeGeneric: (ent, tag) =>
		ent\SetRenderFX(tag\GetTagValue('fx')) if tag\HasTag('fx')
		ent\SetRenderMode(tag\GetTagValue('rmode')) if tag\HasTag('rmode')
		ent\SetColor(tag\GetColor('color')) if tag\HasTag('color')
		ent\SetModel(tag\GetString('model'))

	SerializeGeneric: (ent, tag) =>
		with ent
			fx = \GetRenderFX()
			rmode = \GetRenderMode()
			color = \GetColor()

			tag\SetByte('fx', fx) if fx
			tag\SetByte('rmode', rmode) if rmode
			tag\SetColor('color', color) if color

			tag\SetString('model', \GetModel())

	SerializeCombatState: (ent, tag) =>
		with ent
			tag\SetInt('health', \Health())
			tag\SetInt('max_health', \GetMaxHealth())
			tag\SetInt('armor', \Armor()) if .Armor
			tag\SetInt('max_armor', \GetMaxArmor()) if .GetMaxArmor

	DeserializeCombatState: (ent, tag) =>
		with ent
			\SetHealth(tag\GetTagValue('health')) if tag\HasTag('health') and .SetHealth
			\SetMaxHealth(tag\GetTagValue('max_health')) if tag\HasTag('max_health') and .SetMaxHealth
			\SetArmor(tag\GetTagValue('armor')) if tag\HasTag('armor') and .SetArmor
			\SetMaxArmor(tag\GetTagValue('max_armor')) if tag\HasTag('max_armor') and .SetMaxArmor

	DeserializeMeta: (ent, tag) =>
		ent\SetOwner(@saveInstance\GetEntity(tag\GetTagValue('owner'))) if tag\HasTag('owner')
		ent\SetParent(@saveInstance\GetEntity(tag\GetTagValue('parent'))) if tag\HasTag('parent')

	SerializeMeta: (ent, tag) =>
		with ent
			owner = \GetOwner()
			parent = \GetParent()

			tag\SetShort('owner', @saveInstance\GetEntityID(owner)) if IsValid(owner)
			tag\SetShort('parent', @saveInstance\GetEntityID(parent)) if IsValid(parent)

	DeserializePosition: (ent, tag) =>
		ent\SetPos(tag\GetVector('pos'))
		ent\SetAngles(tag\GetAngle('ang'))
		ent\SetEyeAngles(tag\GetAngle('eang')) if ent.SetEyeAngles and tag\HasTag('eang')

	SerializePosition: (ent, tag) =>
		with ent
			tag\SetVector('pos', \GetPos())
			tag\SetAngle('ang', \GetAngles())
			tag\SetAngle('eang', \EyeAngles()) if .EyeAngles

	SerializePhysObject: (physobj) =>
		tag = NBT.TagCompound()

		if not IsValid(physobj)
			tag\SetByte('valid', 0)
			return tag

		tag\SetByte('valid', 1)

		tag\SetByte('asleep', physobj\IsAsleep() and 1 or 0)
		tag\SetByte('collisions', physobj\IsCollisionEnabled() and 1 or 0)
		tag\SetByte('drag', physobj\IsDragEnabled() and 1 or 0)
		tag\SetByte('gravity', physobj\IsGravityEnabled() and 1 or 0)
		tag\SetByte('motion', physobj\IsMotionEnabled() and 1 or 0)
		tag\SetByte('moveable', physobj\IsMoveable() and 1 or 0)
		tag\SetByte('penetrating', physobj\IsPenetrating() and 1 or 0)
		tag\SetShort('mass', physobj\GetMass() - 30000)

		tag\SetLong('contents', physobj\GetContents())

		tag\SetVector('pos', physobj\GetPos())
		tag\SetVector('velocity', physobj\GetVelocity())
		tag\SetAngle('angle', physobj\GetAngles())

		l, a = physobj\GetDamping()
		tag\SetShort('damping_linear', l)
		tag\SetShort('damping_angular', a)

		return tag

	SerializePhysics: (ent) =>
		return NBT.TagList(NBT.TYPEID.TAG_Compound, [ent\GetPhysicsObjectNum(i) for i = 0, ent\GetPhysicsObjectCount() - 1])

	DeserializePhysObject: (physobj, tag) =>
		return if not tag
		return if not IsValid(physobj)
		return if tag\GetTagValue('valid') == 0

		physobj\EnableCollisions(tag\GetTagValue('collisions') == 1)
		physobj\EnableDrag(tag\GetTagValue('drag') == 1)
		physobj\EnableGravity(tag\GetTagValue('gravity') == 1)
		physobj\EnableMotion(tag\GetTagValue('motion') == 1)
		physobj\SetMass(tag\GetTagValue('mass') + 30000)
		physobj\SetContents(tag\GetTagValue('contents'))
		physobj\SetPos(tag\GetVector('pos'))
		physobj\SetVelocity(tag\GetVector('velocity'))
		physobj\SetAngles(tag\GetAngle('angle'))
		physobj\SetDamping(tag\GetTagValue('damping_linear'), tag\GetTagValue('damping_angular'))

		physobj\Sleep() if tag\GetTagValue('asleep') == 1
		physobj\Wake() if tag\GetTagValue('asleep') == 0

	DeserializePhysics: (ent, taglist) =>
		@DeserializePhysObject(ent\GetPhysicsObjectNum(i), taglist\ExtractValue(i + 1)) for i = 0, ent\GetPhysicsObjectCount() - 1

class DTransitions.PlayerSerializer extends DTransitions.EntitySerializerBase
	@SAVENAME = 'player'

	CanSerialize: (ent) => ent\IsPlayer()
	GetPriority: => 1000

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

		tag\SetShort('walk_speed', ply\GetWalkSpeed())
		tag\SetShort('walk_speed_duck', ply\GetCrouchedWalkSpeed())
		tag\SetShort('run_speed', ply\GetRunSpeed())
		tag\SetShort('active_weapon', @saveInstance\GetEntityID(ply\GetActiveWeapon())) if IsValid(ply\GetActiveWeapon())

		tag\SetShort('vehicle', @saveInstance\GetEntityID(ply\GetVehicle())) if IsValid(ply\GetVehicle())

		mins, maxs = ply\GetHull()
		tag\SetVector('hull_mins', mins)
		tag\SetVector('hull_maxs', maxs)

		mins, maxs = ply\GetHullDuck()
		tag\SetVector('hull_duck_mins', mins)
		tag\SetVector('hull_duck_maxs', maxs)

		tag\SetVector('velocity', ply\GetVelocity())

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

		@DeserializePosition(ply, tag)
		@DeserializeGeneric(ply, tag)
		@DeserializeCombatState(ply, tag)

		ply\SetTeam(tag\GetTagValue('team'))
		ply\SetFrags(tag\GetTagValue('frags'))
		ply\SetDeaths(tag\GetTagValue('deaths'))
		ply\SetDeaths(tag\GetTagValue('deaths'))

		ply\EquipSuit() if tag\GetTagValue('suit') == 1
		ply\RemoveSuit() if tag\GetTagValue('suit') == 0

		ply\SetWalkSpeed(tag\GetTagValue('walk_speed'))
		ply\SetCrouchedWalkSpeed(tag\GetTagValue('walk_speed_duck'))
		ply\SetRunSpeed(tag\GetTagValue('run_speed'))

		ply\SetHull(tag\GetVector('hull_mins'), tag\GetVector('hull_maxs'))
		ply\SetHullDuck(tag\GetVector('hull_duck_mins'), tag\GetVector('hull_duck_maxs'))

		ply\SetVelocity(tag\GetVector('velocity'))

		return ply

	DeserializePost: (ply, tag) =>
		if tag\HasTag('vehicle')
			vehicle = @saveInstance\GetEntity(tag\GetTagValue('vehicle'))
			ply\EnterVehicle(vehicle) if IsValid(vehicle)

		if tag\HasTag('active_weapon')
			active_weapon = @saveInstance\GetEntity(tag\GetTagValue('active_weapon'))
			ply\SelectWeapon(active_weapon) if IsValid(active_weapon)

class DTransitions.PropSerializer extends DTransitions.EntitySerializerBase
	@SAVENAME = 'props'

	CanSerialize: (ent) =>
		switch ent\GetClass()
			when 'prop_physics', 'prop_dynamic', 'prop_ragdoll'
				return true
			else
				return false

	GetPriority: => 800

	Serialize: (ent) =>
		tag = NBT.TagCompound()

		tag\SetString('classname', ent\GetClass())

		if ent\CreatedByMap()
			tag\SetShort('map_id', ent\MapCreationID())

		@SerializePosition(ent, tag)
		@SerializeGeneric(ent, tag)
		@SerializeCombatState(ent, tag)
		tag\SetTag('physics', @SerializePhysics(ent))

		return tag

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
		else
			ent = ents.Create(tag\GetString('classname'))

		return if not IsValid(ent)

		@DeserializePosition(ply, tag)
		@DeserializeGeneric(ply, tag)
		@DeserializeCombatState(ply, tag)

		ent\Spawn()
		ent\Activate()

		@DeserializePhysics(ent, tag\GetTag('physics'))

		return ent

	DeserializePost: (ent, tag) =>
