
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

		tag\SetString('classname', ent.ClassOverride or ent\GetClass())

		if ent\CreatedByMap()
			tag\SetShort('map_id', ent\MapCreationID())

		@SerializePosition(ent, tag)
		@SerializeGeneric(ent, tag)
		@SerializeCombatState(ent, tag)
		@SerializeOwner(ent, tag)
		tag\SetTag('physics', @SerializePhysics(ent))

		tag\SetFloat('model_scale', ent\GetModelScale()) if ent\GetModelScale() ~= 1

		mins, maxs = ent\GetCollisionBounds()
		tag\SetVector('collision_mins', mins)
		tag\SetVector('collision_maxs', maxs)

		if bones = @SerializeBones(ent)
			tag\SetTag('bones', bones)

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

		if bones = tag\GetTag('bones')
			@DeserializeBones(ent, bones)

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializePreSpawn(ent, tag)

		if not tag\HasTag('map_id')
			ent\Spawn()
			ent\Activate()

		@DeserializeOwner(ent, tag)
		@DeserializePostSpawn(ent, tag)

		return ent

	DeserializePost: (ent, tag) =>
