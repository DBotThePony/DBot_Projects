
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

class DTransitions.GenericBuiltinSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'generic'
	@BLACKLIST = {
		'_firesmoke'
	}

	CanSerialize: (ent) =>
		return false if ent\IsScripted()
		classname = ent\GetClass()
		return false if table.qhasValue(@@BLACKLIST, classname)
		return not classname\startsWith('manipulate_')

	GetPriority: => -10000

	-- GetKeyValuesTypeName: => @@SAVENAME .. '_keyvalue_types'
	-- GetSavetableTypeName: => @@SAVENAME .. '_savetable_types'

	Serialize: (ent) =>
		tag = super(ent)
		return if not tag

		if kv = @SerializeKeyValues(ent)
			tag\SetTag('keyvalues', kv)

		if sv = @SerializeSavetable(ent)
			tag\SetTag('savetable', sv)

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag)
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

		if not tag\HasTag('map_id')
			ent\Spawn()
			ent\Activate()

		@DeserializePostSpawn(ent, tag)

		return ent

