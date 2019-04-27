
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

class DTransitions.EntitySerializerBase extends DTransitions.SerializerBase
	new: (...) =>
		super(...)
		@keyValuesTypes = {}
		@saveTableTypes = {}

	@KEY_VALUES_IGNORANCE = {
		'classname',
		'rendercolor',
		'renderfx',
		'rendermode',
		'velocity',
		'waterlevel',
		'health',
		'max_health',
		'avelocity',
		'basevelocity',
		-- 'parentname',
	}

	@SAVETABLE_IGNORANCE = [value for value in *@KEY_VALUES_IGNORANCE]
	table.insert(@SAVETABLE_IGNORANCE, 'm_flTimePlayerStare')
	table.insert(@SAVETABLE_IGNORANCE, 'm_flStopMoveShootTime')

-- 	{
-- 		AlwaysTransition       =     0,
-- 		DontPickupWeapons      =     0,
-- 		DontUseSpeechSemaphore =     0,
-- 		ExpressionOverride     = "",
-- 		GameEndAlly            =     0,
-- 		LightingOrigin         = "",
-- 		LightingOriginHack     = "",
-- 		Relationship           = "",
-- 		ResponseContext        = "",
-- 		SetBodyGroup           =     0,
-- 		TeamNum                =     0,
-- 		additionalequipment    = "weapon_smg1",
-- 		ammoamount             =     0,
-- 		ammosupply             = "",
-- 		avelocity              = Vector (    0               ,     0               ,     0               ),
-- 		basevelocity           = Vector (    0               ,     0               ,     0               ),
-- 		body                   =     0,
-- 		citizentype            =     3,
-- 		classname              = "npc_citizen",
-- 		cycle                  =     0.25630095601082,
-- 		damagefilter           = "",
-- 		denycommandconcept     = "",
-- 		effects                =     0,
-- 		enemyfilter            = "",
-- 		expressiontype         =     1,
-- 		fademaxdist            =     0,
-- 		fademindist            =     0,
-- 		fadescale              =     0,
-- 		friction               =     1,
-- 		globalname             = "",
-- 		gravity                =     1,
-- 		hammerid               =     0,
-- 		health                 =    40,
-- 		hintgroup              = "",
-- 		hintlimiting           =     0,
-- 		hitboxset              =     0,
-- 		ignoreunseenenemies    =     0,
-- 		ltime                  =     0,
-- 		max_health             =    40,
-- 		modelindex             =     0,
-- 		modelscale             =     1,
-- 		neverleaveplayersquad  =     0,
-- 		notifynavfailblocked   =     0,
-- 		parentname             = "",
-- 		physdamagescale        =     1,
-- 		playbackrate           =     1,
-- 		rendercolor            = "255 255 255 255",
-- 		renderfx               =     0,
-- 		rendermode             =     0,
-- 		sequence               =     2,
-- 		shadowcastdist         =     0,
-- 		skin                   =     0,
-- 		sleepstate             =     0,
-- 		spawnflags             =  1536,
-- 		speed                  =     0,
-- 		squadname              = "resistance",
-- 		target                 = "",
-- 		texframeindex          =     0,
-- 		velocity               = Vector (    0               ,     0               ,     0               ),
-- 		view_ofs               = Vector (-   0               ,     0               ,    70               ),
-- 		wakeradius             =     0,
-- 		wakesquad              =     0,
-- 		waterlevel             =     0
-- 	}

	CanSerialize: (ent) => false
	GetPriority: => 0

	-- When saving
	Ask: (tag) =>
		super(tag)
		@keyValuesTypesNBT = tag\AddTagCompound(@@SAVENAME .. '_keyvalue_types')
		@saveTableTypesNBT = tag\AddTagCompound(@@SAVENAME .. '_savetable_types')

	-- When loading
	Tell: (tag) =>
		super(tag)
		@keyValuesTypesNBT = tag\GetTag(@@SAVENAME .. '_keyvalue_types')
		@saveTableTypesNBT = tag\GetTag(@@SAVENAME .. '_savetable_types')
		@ReadKeyValueTypes()
		@ReadSavetableTypes()

	ReadKeyValueTypes: =>
		if not @keyValuesTypesNBT
			@keyValuesTypes = {}
			return

		@keyValuesTypes = @keyValuesTypesNBT\GetValue()

	ReadSavetableTypes: =>
		if not @saveTableTypesNBT
			@saveTableTypes = {}
			return

		@saveTableTypes = @saveTableTypesNBT\GetValue()

	WriteKeyValueTypes: =>
		return if not @keyValuesTypesNBT

		for key, ttype in pairs(@keyValuesTypes)
			@keyValuesTypesNBT\SetString(key, ttype)

	WriteSavetableTypes: =>
		return if not @saveTableTypesNBT

		for key, ttype in pairs(@saveTableTypes)
			@saveTableTypesNBT\SetString(key, ttype)

	DeserializeKeyValues: (ent, tag, allowEnts = false) =>
		return if not tag

		for key, value in tag\pairs()
			if allowEnts
				if @keyValuesTypes[key] == 'Entity'
					ent2 = @saveInstance\GetEntity(value\GetValue())

					if IsValid(ent2)
						ent\SetKeyValue(key, ent2\EntIndex())
					else
						ent\SetKeyValue(key, '')
			else
				switch @keyValuesTypes[key]
					when 'Vector'
						ent\SetKeyValue(key, tostring(tag\GetVector(key)))
					when 'Angle'
						ent\SetKeyValue(key, tostring(tag\GetAngle(key)))
					when 'boolean'
						ent\SetKeyValue(key, value\GetValue() == 1)
					else
						ent\SetKeyValue(key, value\GetValue()) if @keyValuesTypes[key] ~= 'Entity'

	DeserializeSavetable: (ent, tag, allowEnts = false) =>
		return if not tag

		for key, value in tag\pairs()
			if allowEnts
				if @saveTableTypes[key] == 'Entity'
					ent2 = @saveInstance\GetEntity(value\GetValue())

					if IsValid(ent2)
						ent\SetSaveValue(key, ent2\EntIndex())
					else
						ent\SetSaveValue(key, '')
			else
				switch @saveTableTypes[key]
					when 'Vector'
						ent\SetSaveValue(key, tostring(tag\GetVector(key)))
					when 'Angle'
						ent\SetSaveValue(key, tostring(tag\GetAngle(key)))
					when 'boolean'
						ent\SetSaveValue(key, value\GetValue() == 1)
					else
						ent\SetSaveValue(key, value\GetValue()) if @saveTableTypes[key] ~= 'Entity'

	SerializeKeyValues: (ent) =>
		kv = ent\GetKeyValues()
		return if not kv
		tag = NBT.TagCompound()

		for key, value in pairs(kv)
			if not table.qhasValue(@@KEY_VALUES_IGNORANCE, key)
				switch type(value)
					when 'Entity'
						error('ambiguous KeyValue type : got Entity when expected ' .. @keyValuesTypes[key]) if @keyValuesTypes[key] and @keyValuesTypes[key] ~= 'Entity'

						if not @keyValuesTypes[key]
							@keyValuesTypes[key] = 'Entity'
							@WriteKeyValueTypes()

						tag\SetInt(key, @saveInstance\GetEntityID(value)) if IsValid(value)
					when 'Vector'
						error('ambiguous KeyValue type : got Vector when expected ' .. @keyValuesTypes[key]) if @keyValuesTypes[key] and @keyValuesTypes[key] ~= 'Vector'

						if not @keyValuesTypes[key]
							@keyValuesTypes[key] = 'Vector'
							@WriteKeyValueTypes()

						tag\SetVector(key, value)
					when 'Angle'
						error('ambiguous KeyValue type : got Angle when expected ' .. @keyValuesTypes[key]) if @keyValuesTypes[key] and @keyValuesTypes[key] ~= 'Angle'

						if not @keyValuesTypes[key]
							@keyValuesTypes[key] = 'Angle'
							@WriteKeyValueTypes()

						tag\SetAngle(key, value)
					when 'boolean'
						error('ambiguous KeyValue type : got boolean when expected ' .. @keyValuesTypes[key]) if @keyValuesTypes[key] and @keyValuesTypes[key] ~= 'boolean'

						if not @keyValuesTypes[key]
							@keyValuesTypes[key] = 'boolean'
							@WriteKeyValueTypes()

						tag\SetBool(key, value)
					when 'number'
						if value\floor() ~= value
							tag\SetDouble(key, value)
						elseif value < -0x7F and value > 0x7F
							tag\SetByte(key, value)
						elseif value < -0x7FFF and value > 0x7FFF
							tag\SetShort(key, value)
						elseif value < -0x7FFFFFFF and value > 0x7FFFFFFF
							tag\SetInt(key, value)
						else
							tag\SetLong(key, value)
					when 'string'
						tag\SetString(key, value)
					else
						error('Unknown type for KeyValues table : ' .. type(value))

		return tag

	__SerializeSavetableValue: (ent, kv, tag, key, value) =>
		return if table.qhasValue(@@SAVETABLE_IGNORANCE, key)

		if kv
			kvValue = kv[key\lower()]

			switch type(value)
				when 'boolean'
					return if (kvValue == true or kvValue == 1) == value
				else
					return if kvValue == value

		return if key\startsWith('m_GMOD')

		switch type(value)
			when 'Entity', 'Weapon', 'Vehicle', 'NPC', 'NextBot', 'Player'
				error('ambiguous Savetable type : got Entity when expected ' .. @saveTableTypes[key]) if @saveTableTypes[key] and @saveTableTypes[key] ~= 'Entity'

				if not @saveTableTypes[key]
					@saveTableTypes[key] = 'Entity'
					@WriteSavetableTypes()

				tag\SetInt(key, @saveInstance\GetEntityID(value)) if IsValid(value)
				return
			when 'Vector'
				error('ambiguous Savetable type : got Vector when expected ' .. @saveTableTypes[key]) if @saveTableTypes[key] and @saveTableTypes[key] ~= 'Vector'

				if not @saveTableTypes[key]
					@saveTableTypes[key] = 'Vector'
					@WriteSavetableTypes()

				tag\SetVector(key, value)
				return
			when 'Angle'
				error('ambiguous Savetable type : got Angle when expected ' .. @saveTableTypes[key]) if @saveTableTypes[key] and @saveTableTypes[key] ~= 'Angle'

				if not @saveTableTypes[key]
					@saveTableTypes[key] = 'Angle'
					@WriteSavetableTypes()

				tag\SetAngle(key, value)
				return
			when 'boolean'
				error('ambiguous Savetable type : got boolean when expected ' .. @saveTableTypes[key]) if @saveTableTypes[key] and @saveTableTypes[key] ~= 'boolean'

				if not @saveTableTypes[key]
					@saveTableTypes[key] = 'boolean'
					@WriteSavetableTypes()

				tag\SetBool(key, value)
				return
			when 'number'
				if value\floor() ~= value
					tag\SetDouble(key, value)
					return
				elseif value > -0x7F and value < 0x7F
					tag\SetByte(key, value)
					return
				elseif value > -0x7FFF and value < 0x7FFF
					tag\SetShort(key, value)
					return
				elseif value > -0x7FFFFFFF and value < 0x7FFFFFFF
					tag\SetInt(key, value)
					return
				elseif value > -0x7FFFFFFFFFFFF and value < 0x7FFFFFFFFFF
					--DTransitions.MessageError(key, ' savevalue has value of ', value, '. Give up on life')
					tag\SetLong(key, value)
					return
			when 'string'
				tag\SetString(key, value)
				return
			else
				error('Unknown type for Savetable table : ' .. type(value)) if type(value) ~= 'table'
				return

	SerializeSavetable: (ent, lookupKeyValues = true) =>
		savetable = ent\GetSaveTable()
		return if not savetable
		local kv

		if lookupKeyValues
			kv = ent\GetKeyValues() or {}
			kv = {key\lower(), value for key, value in pairs(kv)}

		tag = NBT.TagCompound()
		@__SerializeSavetableValue(ent, kv, tag, key, value) for key, value in pairs(savetable)
		return tag

	DeserializeGeneric: (ent, tag, setmodel = true) =>
		with ent
			\SetRenderFX(tag\GetTagValue('fx')) if tag\HasTag('fx')
			\SetRenderMode(tag\GetTagValue('rmode')) if tag\HasTag('rmode')
			\SetColor(tag\GetColor('color')) if tag\HasTag('color')
			\SetModel(tag\GetTagValue('model')) if setmodel
			\SetFlexScale(tag\GetTagValue('flex_scale'))
			\SetSolid(tag\GetTagValue('solid'))
			\SetMoveType(tag\GetTagValue('movetype'))

			flex = tag\GetTag('flex')
			\SetFlexWeight(i, flex\ExtractValue(i)\GetValue()) for i = 0, \GetFlexNum() when flex\ExtractValue(i)

			if bodygroups = tag\GetTag('bodygroups')
				if bg = ent\GetBodyGroups()
					for data in *bg
						\SetBodygroup(data.id, bodygroups\GetTagValue(data.name)) if bodygroups\HasTag(data.name)

			if tag\HasTag('entitymods')
				ent.EntityMods = util.JSONToTable(tag\GetTagValue('entitymods'))

				for mtype, mfunc in pairs(duplicator.EntityModifiers)
					if ent.EntityMods[mtype]
						status = ProtectedCall -> mfunc(ply, ent, ent.EntityMods[mtype])
						DTransitions.MessageError('Unable to restore ', mtype, ' entity modifier from duplicator table. ', DTransitions.textcolor, 'Maybe this modificator expect actual player? (since we cant provide one.)') if not status

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
			tag\SetByte('movetype', \GetMoveType())
			tag\SetByte('solid', \GetSolid())

			tag\AddTagList('flex', NBT.TYPEID.TAG_Float, [\GetFlexWeight(i) for i = 0, \GetFlexNum()])

			if bg = ent\GetBodyGroups()
				tag2 = tag\AddTagCompound('bodygroups')
				tag2\SetInt(data.name, \GetBodygroup(data.id)) for data in *bg

			tag\SetString('model', \GetModel())

			if .EntityMods
				tag\SetString('entitymods', util.TableToJSON(.EntityMods) or '[]')

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

			tag\SetInt('owner', @saveInstance\GetEntityID(owner)) if IsValid(owner)
			tag\SetInt('parent', @saveInstance\GetEntityID(parent)) if IsValid(parent)

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
		return NBT.TagList(NBT.TYPEID.TAG_Compound, [@SerializePhysObject(ent\GetPhysicsObjectNum(i)) for i = 0, ent\GetPhysicsObjectCount() - 1])

	DeserializePhysObject: (physobj, tag) =>
		return if not tag
		return if not IsValid(physobj)
		return if tag\GetTagValue('valid') == 0

		physobj\EnableCollisions(tag\GetTagValue('collisions') == 1)
		physobj\EnableDrag(tag\GetTagValue('drag') == 1)
		physobj\EnableGravity(tag\GetTagValue('gravity') == 1)
		physobj\EnableMotion(tag\GetTagValue('motion') == 1)
		physobj\SetMass(tag\GetTagValue('mass') + 30000)
		--physobj\SetContents(tag\GetTagValue('contents'))
		physobj\SetPos(tag\GetVector('pos'))
		physobj\SetVelocity(tag\GetVector('velocity'))
		physobj\SetAngles(tag\GetAngle('angle'))
		--physobj\SetDamping(tag\GetTagValue('damping_linear'), tag\GetTagValue('damping_angular'))

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
						tag\SetInt(k, @saveInstance\GetEntityID(v)) if IsValid(v)
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

		ply\SetWalkSpeed(tag\GetTagValue('walk_speed'))
		ply\SetCrouchedWalkSpeed(tag\GetTagValue('walk_speed_duck'))
		ply\SetRunSpeed(tag\GetTagValue('run_speed'))

		ply\SetHull(tag\GetVector('hull_mins'), tag\GetVector('hull_maxs'))
		ply\SetHullDuck(tag\GetVector('hull_duck_mins'), tag\GetVector('hull_duck_maxs'))

		ply\SetVelocity(tag\GetVector('velocity') - ply\GetVelocity())

		return ply

	DeserializePost: (ply, tag) =>
		if tag\HasTag('vehicle')
			vehicle = @saveInstance\GetEntity(tag\GetTagValue('vehicle'))
			ply\EnterVehicle(vehicle) if IsValid(vehicle)

		if tag\HasTag('active_weapon')
			active_weapon = @saveInstance\GetEntity(tag\GetTagValue('active_weapon'))
			ply\SelectWeapon(active_weapon\GetClass()) if IsValid(active_weapon)

class DTransitions.PropSerializer extends DTransitions.EntitySerializerBase
	@SAVENAME = 'props'

	CanSerialize: (ent) =>
		switch ent\GetClass()
			when 'prop_physics', 'prop_dynamic', 'prop_ragdoll'
				return true
			else
				return false

	GetPriority: => 500

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

	DeserializePreSpawn: (ent, tag) =>
		@DeserializePosition(ent, tag)
		@DeserializeGeneric(ent, tag)

	DeserializePostSpawn: (ent, tag) =>
		@DeserializeCombatState(ent, tag)

		mins, maxs = tag\GetVector('collision_mins'), tag\GetVector('collision_maxs')
		ent\SetCollisionBounds(mins, maxs)

		ent\SetModelScale(tag\GetTagValue('model_scale')) if tag\HasTag('model_scale')

		@DeserializePhysics(ent, tag\GetTag('physics'))

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializePreSpawn(ent, tag)

		ent\Spawn()
		ent\Activate()

		@DeserializePostSpawn(ent, tag)

		return ent

	DeserializePost: (ent, tag) =>

class DTransitions.WeaponSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'weapons'

	CanSerialize: (ent) => ent\IsWeapon()
	GetPriority: => 900

	Serialize: (ent) =>
		tag = super(ent)
		owner = ent\GetOwner()

		if IsValid(owner)
			tag\SetInt('weapon_owner', @saveInstance\GetEntityID(owner))
			tag\SetString('player_owner', owner\SteamID()) if owner\IsPlayer()

		tag\SetShort('clip1', ent\Clip1())
		tag\SetShort('clip2', ent\Clip2())
		tag\SetString('holdtype', ent\GetHoldType())

		tag2 = @SerializeGNetVars(ent)
		tag\SetTag('dt', tag2) if tag2

		return tag

	DeserializePost: (ent, tag) =>
		@DeserializeGNetVars(ent, tag\GetTag('dt'), false)
		super(ent, tag)

	DeserializeMiddle: (ent, tag) =>
		return if not tag\HasTag('weapon_owner')
		npc = @saveInstance\GetEntity(tag\GetTagValue('weapon_owner'))
		return if not IsValid(npc)
		ent = npc\Give(tag\GetTagValue('classname'))
		return if not IsValid(ent)

		@DeserializeGeneric(ent, tag, false)
		@DeserializeCombatState(ent, tag)

		ent\SetModelScale(tag\GetTagValue('model_scale')) if tag\HasTag('model_scale')

		@DeserializeGNetVars(ent, tag\GetTag('dt'), true)

		return ent

	DeserializePre: (tag) =>
		if tag\HasTag('player_owner')
			ply = player.GetBySteamID(tag\GetTagValue('player_owner'))
			return if not ply
			ent = ply\Give(tag\GetTagValue('classname'), false)
			--ent = ents.Create(tag\GetTagValue('classname'))
			return if not IsValid(ent)

			@DeserializeGeneric(ent, tag, false)
			@DeserializeCombatState(ent, tag)

			ent\SetModelScale(tag\GetTagValue('model_scale')) if tag\HasTag('model_scale')

			ent\SetClip1(tag\GetTagValue('clip1'))
			ent\SetClip2(tag\GetTagValue('clip2'))
			ent\SetHoldType(tag\GetTagValue('holdtype'))

			@DeserializeGNetVars(ent, tag\GetTag('dt'), true)

			return ent

		return if tag\HasTag('weapon_owner')

		ent = super(tag)

		ent\SetClip1(tag\GetTagValue('clip1'))
		ent\SetClip2(tag\GetTagValue('clip2'))
		ent\SetHoldType(tag\GetTagValue('holdtype'))

		@DeserializeGNetVars(ent, tag\GetTag('dt'), true)

		return ent

class DTransitions.NPCSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'npcs'

	@KEY_VALUES_IGNORANCE = [v for v in *DTransitions.PropSerializer.KEY_VALUES_IGNORANCE]
	table.insert(@KEY_VALUES_IGNORANCE, 'additionalequipment')

	CanSerialize: (ent) => ent\IsNPC()
	GetPriority: => 800

	@NPC_ACTIVITY = {
		--{'ActiveWeapon', 'Entity'}
		{'Activity', 'Short'}
		--{'AimVector', 'Vector'}
		{'ArrivalActivity', 'Short'}
		{'ArrivalSequence', 'Short'}
		{'BlockingEntity', 'Entity'}
		{'CurrentSchedule', 'Short'}
		{'CurrentWeaponProficiency', 'Byte'}
		{'Enemy', 'Entity'}
		{'Expression', 'String'}
		{'HullType', 'Byte'}
		{'MovementActivity', 'Short'}
		{'MovementSequence', 'Short'}
		{'NPCState', 'Byte'}
		{'PathDistanceToGoal', 'Short'}
		{'PathTimeToGoal', 'Int'}
		--{'ShootPos', 'Vector'}
		{'Target', 'Entity'}
	}

	Serialize: (ent) =>
		tag = super(ent)
		return if not tag

		@QuickSerializeObj(tag, ent, @@NPC_ACTIVITY)

		if kv = @SerializeKeyValues(ent)
			tag\SetTag('keyvalues', kv)

		if sv = @SerializeSavetable(ent)
			tag\SetTag('savetable', sv)

		if dt = @SerializeGNetVars(ent)
			tag\SetTag('dt', dt)

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag)

		@QuickDeserializeObj(tag, ent, @@NPC_ACTIVITY, true)
		@DeserializeGNetVars(ent, tag\GetTag('dt'), false)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'), true)

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))
		@DeserializePreSpawn(ent, tag)

		ent\Spawn()
		ent\Activate()

		@DeserializePostSpawn(ent, tag)
		@QuickDeserializeObj(tag, ent, @@NPC_ACTIVITY)
		@DeserializeGNetVars(ent, tag\GetTag('dt'), true)

		return ent
