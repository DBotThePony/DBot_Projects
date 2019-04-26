
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

class DTransitions.EntitySerializerBase
	new: (saveInstance) =>
		@saveInstance = saveInstance

	CanSerialize: (ent) => false
	GetPriority: => 0
	Serialize: (ent) => error('Not implemented')

	DeserializePre: (tag) => error('Not implemented')
	DeserializePost: (ent, tag) =>

	Ask: (tag) =>

	DeserializeGeneric: (ent, tag) =>
		with ent
			\SetRenderFX(tag\GetTagValue('fx')) if tag\HasTag('fx')
			\SetRenderMode(tag\GetTagValue('rmode')) if tag\HasTag('rmode')
			\SetColor(tag\GetColor('color')) if tag\HasTag('color')
			\SetModel(tag\GetString('model'))
			\SetFlexScale(tag\GetTagValue('flex_scale'))

			flex = tag\GetTag('flex')
			\SetFlexWeight(i, flex\ExtractValue(i)) for i = 0, \GetFlexNum() when flex\ExtractValue(i)

			if bodygroups = tag\GetTag('bodygroups')
				if bg = ent\GetBodyGroups()
					for data in *bg
						\SetBodygroup(data.id, bodygroups\GetTagValue(data.name)) if bodygroups\HasTag(data.name)

	SerializeGeneric: (ent, tag) =>
		with ent
			fx = \GetRenderFX()
			rmode = \GetRenderMode()
			color = \GetColor()

			tag\SetByte('fx', fx) if fx
			tag\SetByte('rmode', rmode) if rmode
			tag\SetColor('color', color) if color
			tag\SetShort('skin', \GetSkin())
			tag\SetFloat('flex_scale', \GetFlexScale())

			tag\AddTagList('flex', NBT.TYPEID.TAG_Float, [\GetFlexWeight(i) for i = 0, \GetFlexNum()])

			if bg = ent\GetBodyGroups()
				tag\AddTagCompound('bodygroups', {data.name, \GetBodygroup(data.id) for data in *bg})

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

	SerializeBones: (ent) =>
		return if not ent\HasBoneManipulations()
		tag = NBT.TagCompound()

		for boneid = 0, ent\GetBoneCount() - 1
			tag2 = NBT.TagCompound()
			tag2\SetVector('scale', ent\GetManipulateBoneScale(boneid))
			tag2\SetVector('pos', ent\GetManipulateBonePosition(boneid))
			tag2\SetAngle('ang', ent\GetManipulateBoneAngles(boneid))
			tag\SetTag(ent\GetBoneName(boneid), tag2)

		return tag

	DeserializeBones: (ent, tag) =>
		for boneid = 0, ent\GetBoneCount() - 1
			if tag2 = tag\GetTag(ent\GetBoneName(boneid))
				ent\ManipulateBoneScale(tag2\GetVector('scale'))
				ent\ManipulateBonePosition(tag2\GetVector('pos'))
				ent\ManipulateBoneAngles(tag2\GetAngle('ang'))

	SerializeGNetVars: (ent) =>
		return if not ent.GetNetworkVars
		if vars = ent\GetNetworkVars()
			tag = NBT.TagCompound()

			for k, v in pairs(vars)
				switch type(v)
					when 'number'
						if v % 1 == 0
							tag\SetInt(k, v)
						else
							tag\SetFloat(k, v)
					when 'string'
						tag\SetString(k, v)
					when 'boolean'
						tag\SetByte(k, v and 1 or 0)
					when 'Vector'
						tag\SetVector(k, v)
					when 'Angle'
						tag\SetAngle(k, v)
					when 'Entity'
						tag\SetShort(k, @saveInstance\GetEntityID(v)) if IsValid(v)
					else
						error('GetNetworkVars returned unknown value type: ' .. type(v) .. ' at index ' .. k)

			return tag

	DeserializeGNetVars: (ent, tag, state = true) =>
		return if not tag
		return if not ent.dt
		meta = getmetatable(ent.dt)
		return if not meta
		return if not meta.__index

		i = 1
		upvalueName, upvalue = debug.getupvalue(meta.__index, i)

		while upvalueName
			if upvalueName == 'datatable'
				break

			i += 1
			upvalueName, upvalue = debug.getupvalue(meta.__index, i)

		return if upvalueName ~= 'datatable'
		for k, data in pairs(upvalue)
			if tag\HasTag(k)
				if state
					switch data.typename
						when 'Int', 'Float', 'String'
							ent['Set' .. k](ent, tag\GetTagValue(k))
						when 'Bool'
							ent['Set' .. k](ent, tag\GetTagValue(k) == 1)
						when 'Angle'
							ent['Set' .. k](ent, tag\GetAngle(k))
						when 'Vector'
							ent['Set' .. k](ent, tag\GetVector(k))
				else
					switch data.typename
						when 'Entity'
							ent['Set' .. k](ent, @saveInstance\GetEntity(tag\GetTagValue(k)))

class DTransitions.PlayerSerializer extends DTransitions.EntitySerializerBase
	@SAVENAME = 'player'

	CanSerialize: (ent) => ent\IsPlayer()
	GetPriority: => 1000

	Ask: (tag) =>
		@ammoTypesRaw = {}
		i = 1
		ammotype = game.GetAmmoName(i)

		while ammotype
			@ammoTypesRaw[i] = ammotype
			i += 1
			ammotype = game.GetAmmoName(i)

		@maxAmmoTypes = i - 1

		list = NBT.TagCompound()

		for id, name in ipairs(@ammoTypesRaw)
			list\SetShort(name, id)

		tag\AddTag('ammotypes', list)

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

		ammo = tag\AddTagList('ammo', NBT.TYPEID.TAG_Short)
		ammo\AddValue(ply\GetAmmoCount(i)) for i = 1, @maxAmmoTypes

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

		tag\SetFloat('model_scale', ent\GetModelScale()) if ent\GetModelScale() ~= 1

		mins, maxs = ent\GetCollisionBounds()
		tag\SetVector('collision_mins', mins)
		tag\SetVector('collision_maxs', maxs)

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

		mins, maxs = tag\GetVector('collision_mins'), tag\GetVector('collision_maxs')
		ent\SetCollisionBounds(mins, maxs)

		ent\SetModelScale(tag\GetTagValue('model_scale')) if tag\HasTag('model_scale')

		@DeserializePhysics(ent, tag\GetTag('physics'))

		return ent

	DeserializePost: (ent, tag) =>

class DTransitions.WeaponSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'weapons'

	CanSerialize: (ent) => ent\IsWeapon()
	GetPriority: => 900

	Serialize: (ent) =>
		tag = super(ent)

		tag\SetShort('clip1', ent\Clip1())
		tag\SetShort('clip2', ent\Clip2())
		tag\SetString('holdtype', ent\GetHoldType())

		tag2 = @SerializeGNetVars(ent)
		tag\SetTag('dt', tag2) if tag2

		return tag

	DeserializePost: (tag) =>
		@DeserializeGNetVars(ent, tag\GetTag('dt'), false)

	DeserializePre: (tag) =>
		ent = super(tag)

		ent\SetClip1(tag\GetTagValue('clip1'))
		ent\SetClip2(tag\GetTagValue('clip2'))
		ent\SetHoldType(tag\GetTagValue('holdtype'))

		@DeserializeGNetVars(ent, tag\GetTag('dt'), true)

		return ent

	DeserializePost: (ent, tag) =>
