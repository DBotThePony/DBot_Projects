
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

		--if ent\GetClass() == 'npc_barnacle' and ent\Health() < 1
		--	if kv = tag\GetTag('keyvalues')
		--		kv\SetInt('spawnflags', tag\GetTagValue('spawnflags')\bor(65536))

		--	if sv = tag\GetTag('savetable')
		--		sv\SetInt('spawnflags', tag\GetTagValue('spawnflags')\bor(65536))

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag)

		@QuickDeserializeObj(tag, ent, @@NPC_ACTIVITY, true)
		@DeserializeGNetVars(ent, tag\GetTag('dt'), false)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'), true)

	DeserializePre: (tag) =>
		return if tag\GetTagValue('classname') == 'npc_barnacle' and tag\GetTagValue('health') < 1
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))
		@DeserializePreSpawn(ent, tag)

		if not tag\HasTag('map_id')
			ent\Spawn()
			ent\Activate()

		@DeserializePostSpawn(ent, tag)
		@QuickDeserializeObj(tag, ent, @@NPC_ACTIVITY)
		@DeserializeGNetVars(ent, tag\GetTag('dt'), true)

		return ent
