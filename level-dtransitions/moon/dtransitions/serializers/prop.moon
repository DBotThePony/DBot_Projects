
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

class DTransitions.PropSerializer extends DTransitions.AbstractSerializer
	@SAVENAME = 'props'

	@KEY_VALUES_IGNORANCE = {
		'classname',
		'velocity',
		'avelocity',
		'basevelocity',
	}

	@SAVETABLE_IGNORANCE = [value for value in *@KEY_VALUES_IGNORANCE]

	CanSerialize: (ent) =>
		switch ent\GetClass()
			when 'prop_physics', 'prop_dynamic', 'prop_ragdoll'
				return true
			else
				return false

	GetPriority: => 500

	Serialize: (ent) =>
		tag = super(ent, true)
		return if not tag

		if kv = @SerializeKeyValues(ent)
			tag\SetTag('keyvalues', kv) -- ?

		if sv = @SerializeSavetable(ent)
			tag\SetTag('savetable', sv)

		tag\SetTag('physics', @SerializePhysics(ent))

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag, true)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'), true)

		if sv = tag\GetTag('savetable')
			@DeserializeSavetable(ent, sv, true)

			if ent\GetClass() == 'entityflame' and IsValid(ent\GetParent()) and sv\HasTag('lifetime')
				ent\GetParent()\Ignite(sv\GetTagValue('lifetime'))

		ent\Spawn()
		ent\Activate()

		@DeserializePhysics(ent, tag\GetTag('physics'))

	DeserializePre: (tag) =>
		ent = @GetEntityReplace(tag)
		return if not IsValid(ent)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))

		return ent
