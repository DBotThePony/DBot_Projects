
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

class DTransitions.SaveInstance
	@REMOVED_MAP_ENTITIES = {}

	new: =>
		@serializers = {}
		@entMapping = {}
		@RegisterSerializer(DTransitions.PlayerSerializer(@))
		@RegisterSerializer(DTransitions.PropSerializer(@))
		@RegisterSerializer(DTransitions.WeaponSerializer(@))
		@RegisterSerializer(DTransitions.GModNPCSerializer(@))
		@RegisterSerializer(DTransitions.BuiltinNPCSerializer(@))
		@RegisterSerializer(DTransitions.VehicleSerializer(@))
		@RegisterSerializer(DTransitions.DoorSerializer(@))
		@RegisterSerializer(DTransitions.FuncDoorRotatingSerializer(@))
		-- @RegisterSerializer(DTransitions.GenericBuiltinSerializer(@))
		@RegisterSerializer(DTransitions.BuiltinSoftSerializer(@))
		@RegisterSerializer(DTransitions.ButtonSerializer(@))
		@RegisterSerializer(DTransitions.WeaponProjectilesSerializer(@))
		@RegisterSerializer(DTransitions.TripmineSerializer(@))
		@RegisterSerializer(DTransitions.FragSerializer(@))
		@RegisterSerializer(DTransitions.BuiltinSerializer(@))
		@RegisterSerializer(DTransitions.BuiltinHardSerializer(@))
		@RegisterSerializer(DTransitions.BuiltinSingleSerializer(@))
		@RegisterSerializer(DTransitions.BuiltinFilterSerializer(@))

	RegisterSerializer: (serializer) =>
		table.insert(@serializers, serializer)
		return @

	SortSerializers: =>
		table.sort @serializers, (a, b) -> a\GetPriority() > b\GetPriority()
		@serializersMapping = {serializer.__class.SAVENAME, serializer for serializer in *@serializers}

	GetEntityID: (ent) => IsValid(ent) and ent\GetCreationID() or -1
	GetEntity: (id) => @entMapping[id] or NULL

	@ENT_BLACKLIST = {
		'network',
		'info_player_start',
		'worldspawn',
		'water_lod_control',
		'sky_camera',
		'soundent',
		'spotlight_end',
		'info_spotlight',
		'env_sun',
		'gmod_hands',
		'light',
		'player_manager',
		'predicted_viewmodel',
		'math_counter',
		'path_corner',
		'env_soundscape',
		'beam',
		'hint',
		'npc_barnacle_tongue_tip',

		'env_sprite', -- most entities recreate it by themselves

		'info_node_link',
		'info_node_link_controller',

		'func_areaportal',
		'func_usableladder',
		'func_smokevolume',
		'func_platrot',
		'func_areaportalwindow',
		'env_skypaint',
		'func_lod',
		'game_gib_manager',
		'env_hudhint',
		'color_correction',
		'changehitngroup',
		--'func_clip_vphysics',

		'info_landmark',
		'trigger_changelevel',
		'trigger_hurt', -- idk

		'_firesmoke', -- go away

		'env_smokestack',
		'ambient_generic',
		'gmod_gamerules', -- not sure

		'info_target',
		'info_ladder_dismount',
		'manipulate_bone',
		'manipulate_flex',

		'env_fog_controller', -- not sure
		'shadow_control', -- not sure

		-- 'env_fire', -- ?
		-- 'env_firesource', -- ?

		-- 'scene_manager',
		-- 'point_camera',
		-- 'point_viewcontrol',

		'info_target_command_point',
		'assault_assaultpoint',
		'assault_rallypoint',
	}

	Serialize: =>
		@SortSerializers()

		tag = NBT.TagCompound()
		@nbttag = tag
		entList = tag\AddTagList('entities', NBT.TYPEID.TAG_Compound)

		entListRemoved = tag\AddTagList('map_entities_removed', NBT.TYPEID.TAG_Short, @@REMOVED_MAP_ENTITIES)

		for serializer in *@serializers
			serializer\Ask(tag)

		noSerializers = {}
		counter = {}

		for ent in *ents.GetAll()
			classname = ent\GetClass()
			counter[classname] = (counter[classname] or 0) + 1
			if not table.qhasValue(@@ENT_BLACKLIST, classname)
				hit = false

				for serializer in *@serializers
					if serializer\CanSerialize(ent)
						status = ProtectedCall ->
							tag2 = serializer\Serialize(ent)
							if tag2
								entList\AddValue(tag2)
								tag2\SetString('__savename', serializer.__class.SAVENAME)
								tag2\SetInt('__creation_id', ent\GetCreationID())
								hit = true

						if not status
							DTransitions.MessageError('Serializer ', serializer.__class.__name, ' failed to serialize ', ent, '! This entity would not appear in save.')

						break

				noSerializers[classname] = true if not hit

		sortable = [ent for ent in pairs(noSerializers)]
		table.sort(sortable)
		DTransitions.MessageWarning(ent, ' lack a serializer.') for ent in *sortable

		ctag = tag\AddTagCompound('ent_count')

		for ent, c in pairs(counter)
			ctag\SetShort(ent, c)
--
--		history = tag\AddTagList('history', NBT.TYPEID.TAG_Compound)
--
--		for row in *DTransitions.TrackScene
--			tag2 = NBT.TagCompound()
--
--			tag2\SetInt('target', row.target)
--			tag2\SetInt('inflictor', row.inflictor)
--			tag2\SetInt('backtrace', row.backtrace)
--			tag2\SetString('funcName', row.funcName)
--
--			vpassed = NBT.TagCompound()
--			ttype = type(row.valuePassed)
--			vpassed\SetString('type', ttype)
--
--			switch ttype
--				when 'string'
--					vpassed\SetString('value', row.valuePassed)
--				when 'number'
--					if row.valuePassed\floor() ~= row.valuePassed
--						vpassed\SetDouble('value', row.valuePassed)
--					elseif row.valuePassed > -0x7F and row.valuePassed < 0x7F
--						vpassed\SetByte('value', row.valuePassed)
--					elseif row.valuePassed > -0x7FFF and row.valuePassed < 0x7FFF
--						vpassed\SetShort('value', row.valuePassed)
--					elseif row.valuePassed > -0x7FFFFFFF and row.valuePassed < 0x7FFFFFFF
--						vpassed\SetInt('value', row.valuePassed)
--					elseif row.valuePassed > -0x7FFFFFFFFFFFF and row.valuePassed < 0x7FFFFFFFFFF
--						vpassed\SetLong('value', row.valuePassed)
--				when 'table'
--					vpassed\SetString('value', util.TableToJSON(row.valuePassed) or '[]')
--				when 'Angle'
--					vpassed\SetAngle('value', row.valuePassed)
--				when 'Vector'
--					vpassed\SetVector('value', row.valuePassed)
--				when 'boolean'
--					vpassed\SetBool('value', row.valuePassed)
--				when 'Entity', 'Player', 'Vehicle', 'NextBot', 'Weapon', 'NPC'
--					vpassed\SetInt('value', @GetEntityID(row.valuePassed))
--				else
--					DTransitions.MessageWarning(row.funcName, ' received input typeof ', ttype, ', which is unknown to me. This input will not be registered in savefile.') if ttype ~= 'nil'
--
--			if vpassed\HasTag('value') or ttype == 'nil'
--				tag2\SetTag('valuePassed', vpassed)
--				history\AddValue(tag2)

		buff = DLib.BytesBuffer()
		tag\WriteFile(buff)

		fstream = file.Open('savetest.dat', 'wb', 'DATA')
		buff\ToFileStream(fstream)
		fstream\Close()

		return @

	WasEntityRemoved: (mapIndex) => @removedEnts and table.qhasValue(@removedEnts, mapIndex)

	Deserialize: =>
		@SortSerializers()

		error('No NBT tag specified!') if not @nbttag

		-- Shut The Fucking Up
		ent\Remove() for ent in *ents.FindByClass('point_viewcontrol')
		ent\Remove() for ent in *ents.FindByClass('env_zoom')

		game.CleanUpMap()

		@allents = ents.GetAll()

		@entMapping = {}
		@removedEnts = @nbttag\GetTagValue('map_entities_removed')

		for entID in *@removedEnts
			getent = ents.GetMapCreatedEntity(entID)
			getent\Remove() if IsValid(getent)

		for serializer in *@serializers
			serializer\Tell(@nbttag)

		entList = @nbttag\GetTag('entities')
		post = {}
		middle = {}

		for i, tag in entList\ipairs()
			if serializer = @serializersMapping[tag\GetTagValue('__savename')]
				status = ProtectedCall ->
					if ent = serializer\DeserializePre(tag)
						@entMapping[tag\GetTagValue('__creation_id')] = ent
						table.insert(post, {ent, serializer, tag})
						table.insert(middle, {ent, serializer, tag})
						return
					else
						table.insert(middle, {nil, serializer, tag})
						return

				if not status
					DTransitions.MessageError('Serializer ', serializer.__class.__name, ' failed to [pre] deserialize an entity!')

		for {ent, serializer, tag} in *middle
			status = ProtectedCall ->
				if ent
					serializer\DeserializeMiddle(ent, tag)
					return
				else
					if ent = serializer\DeserializeMiddle(ent, tag)
						@entMapping[tag\GetTagValue('__creation_id')] = ent
						table.insert(post, {ent, serializer, tag})
						return

			if not status
				DTransitions.MessageError('Serializer ', serializer.__class.__name, ' failed to [middle] deserialize an entity!')

		for {ent, serializer, tag} in *post
			status = ProtectedCall ->
				serializer\DeserializePost(ent, tag)
				return

			if not status
				DTransitions.MessageError('Serializer ', serializer.__class.__name, ' failed to [post] deserialize an entity!')
--
--		for i, tag2 in @nbttag\GetTag('history')\ipairs()
--			target = @GetEntity(tag2\GetTagValue('target'))
--
--			if IsValid(target)
--				inflictor = @GetEntity(tag2\GetTagValue('inflictor'))
--				backtrace = @GetEntity(tag2\GetTagValue('backtrace'))
--				funcName = tag2\GetTagValue('funcName')
--				valuePassed = tag2\GetTag('valuePassed')
--
--				switch valuePassed\GetTagValue('type')
--					when 'table'
--						valuePassed = util.JSONToTable(valuePassed\GetTagValue('value'))
--					when 'boolean'
--						valuePassed = valuePassed\GetTagValue('value') == 1
--					when 'Vector'
--						valuePassed = valuePassed\GetVector('value')
--					when 'Angle'
--						valuePassed = valuePassed\GetAngle('value')
--					when 'Entity', 'Player', 'Vehicle', 'NextBot', 'Weapon', 'NPC'
--						valuePassed = @GetEntity(valuePassed\GetTagValue('value'))
--					else
--						if valuePassed\HasTag('value')
--							valuePassed = valuePassed\GetTagValue('value')
--						else
--							valuePassed = nil
--
--				status = pcall(target.Input, target, funcName, inflictor, backtrace, valuePassed)
--				DTransitions.MessageError(target, ' rejected input ', funcName, ' from ', inflictor, ' called by ', backtrace, ' with param ', valuePassed) if not status

		return @

hook.Add 'EntityRemoved', 'DTransitions.RemovedMapEntities', (ent) ->
	return if not ent\CreatedByMap()
	table.insert(DTransitions.SaveInstance.REMOVED_MAP_ENTITIES, ent\MapCreationID()) if not table.qhasValue(DTransitions.SaveInstance.REMOVED_MAP_ENTITIES, ent\MapCreationID())

hook.Add 'PostCleanupMap', 'DTransitions.RemovedMapEntities', ->
	DTransitions.SaveInstance.REMOVED_MAP_ENTITIES = {}

DTransitions.TrackScene = DTransitions.TrackScene or {}

hook.Add 'AcceptInput', 'DTransitions.TrackScene', (target = NULL, funcName = '', inflictor = NULL, backtrace = NULL, valuePassed) ->
	target = -1 if not IsValid(target)
	target = target\GetCreationID() if IsValid(target)
	inflictor = -1 if not IsValid(inflictor)
	inflictor = inflictor\GetCreationID() if IsValid(inflictor)
	backtrace = -1 if not IsValid(backtrace)
	backtrace = backtrace\GetCreationID() if IsValid(backtrace)

	table.insert(DTransitions.TrackScene, {
		:target
		:funcName
		:inflictor
		:backtrace
		:valuePassed
	})

hook.Add 'PostCleanupMap', 'DTransitions.TrackScene', -> DTransitions.TrackScene = {}
