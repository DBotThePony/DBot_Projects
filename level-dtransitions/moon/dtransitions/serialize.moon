
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
		@RegisterSerializer(DTransitions.NPCSerializer(@))
		@RegisterSerializer(DTransitions.VehicleSerializer(@))
		@RegisterSerializer(DTransitions.DoorSerializer(@))
		@RegisterSerializer(DTransitions.FuncDoorRotatingSerializer(@))
		-- @RegisterSerializer(DTransitions.GenericBuiltinSerializer(@))
		@RegisterSerializer(DTransitions.BuiltinSoftSerializer(@))
		@RegisterSerializer(DTransitions.ButtonSerializer(@))

	RegisterSerializer: (serializer) =>
		table.insert(@serializers, serializer)
		return @

	SortSerializers: =>
		table.sort @serializers, (a, b) -> a\GetPriority() > b\GetPriority()
		@serializersMapping = {serializer.__class.SAVENAME, serializer for serializer in *@serializers}

	GetEntityID: (ent) => ent\GetCreationID()
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
		'beam',

		'func_areaportal',
		'func_usableladder',
		'func_smokevolume',
		'func_platrot',
		'env_skypaint',

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

		for ent in *ents.GetAll()
			classname = ent\GetClass()
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

		buff = DLib.BytesBuffer()
		tag\WriteFile(buff)

		fstream = file.Open('savetest.dat', 'wb', 'DATA')
		buff\ToFileStream(fstream)
		fstream\Close()

		return @

	Deserialize: =>
		@SortSerializers()

		error('No NBT tag specified!') if not @nbttag

		game.CleanUpMap()

		@entMapping = {}

		for entID in *@nbttag\GetTagValue('map_entities_removed')
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

		return @

hook.Add 'EntityRemoved', 'DTransitions.RemovedMapEntities', (ent) ->
	return if not ent\CreatedByMap()
	table.insert(DTransitions.SaveInstance.REMOVED_MAP_ENTITIES, ent\MapCreationID()) if not table.qhasValue(DTransitions.SaveInstance.REMOVED_MAP_ENTITIES, ent\MapCreationID())

hook.Add 'PostCleanupMap', 'DTransitions.RemovedMapEntities', ->
	DTransitions.SaveInstance.REMOVED_MAP_ENTITIES = {}
