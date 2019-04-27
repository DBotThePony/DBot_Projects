
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

class DTransitions.BuiltinSoftSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'builtin_logic'

	@SAVETABLE_IGNORANCE = {}

	@_HANDLE = {
		'env_sprite'
		'env_spritetrail'
		'env_ar2explosion'
		'env_shooter'
		'env_physimpact'
		'env_shake'
		'env_physexplosion'
		'env_rockettrail'
		'env_laserdot'
		'env_fire'
		'env_smoketrail'
		'env_firesource'
		'func_rot_button' -- partly working
		'env_lightglow'
		'func_brush'
		'env_tonemap_controller'

		'ally_speech_manager'

		'func_illusionary'
		'aiscripted_schedule'

		'relationship'

		'logic_relay'
		'logic_timer'
		'logic_auto'
		'logic_case'
		'logic_compare'
		'trigger_multiple'
		'trigger_once'
		'trigger_playermovement'
		'trigger_serverragdoll'
		'info_particle_system'
		'func_clip_vphysics'

		'math_remap'
		'momentary_rot_button'
		'point_velocitysensor'

		'point_template'

		'npc_maker'
		'npc_template_maker'
		'entityflame'

		'func_breakable'
		'func_physbox'
		--'func_breakable_surf'
		'filter_activator_name'
		'func_rotating'

		'npc_antlion_grub'
		'scripted_sequence'
	}

	@HANDLE = {v, v for v in *@_HANDLE}

	CanSerialize: (ent) => @@HANDLE[ent\GetClass()] ~= nil
	GetPriority: => 0

	Serialize: (ent) =>
		tag = super(ent, true)
		return if not tag

		if ent\GetClass() == 'entityflame'
			if kv = @SerializeKeyValues(ent)
				tag\SetTag('keyvalues', kv)

		if sv = @SerializeSavetable(ent, false)
			tag\SetTag('savetable', sv)

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag, true)
		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'), true)

		if sv = tag\GetTag('savetable')
			@DeserializeSavetable(ent, sv, true)

			if ent\GetClass() == 'entityflame' and IsValid(ent\GetParent()) and sv\HasTag('lifetime')
				ent\GetParent()\Ignite(sv\GetTagValue('lifetime'))

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
			--return if not IsValid(ent)
			--ent\Remove()
			--ent = ents.Create(tag\GetTagValue('classname'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))

		if not tag\HasTag('map_id')
			ent\Spawn()
			ent\Activate()

		if tag\GetTagValue('classname') == 'npc_antlion_grub'
			if sv = ent\GetSaveTable()
				sv.m_hGlowSprite\Remove() if IsValid(sv.m_hGlowSprite)

		return ent

class DTransitions.BuiltinSingleSerializer extends DTransitions.BuiltinSoftSerializer
	@SAVENAME = 'builtin_singleton'

	@SAVETABLE_IGNORANCE = {}

	@_HANDLE = {
		'scene_manager'
	}

	@HANDLE = {v, v for v in *@_HANDLE}

	DeserializePre: (tag) =>
		ent = ents.FindByClass(tag\GetTagValue('classname'))
		return if not IsValid(ent)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))

		if not tag\HasTag('map_id')
			ent\Spawn()
			ent\Activate()

		return ent


class DTransitions.BuiltinHardSerializer extends DTransitions.BuiltinSoftSerializer
	@SAVENAME = 'builtin_logic2'

	@SAVETABLE_IGNORANCE = {}

	@_HANDLE = {
		--'func_breakable'
		'func_breakable_surf'
	}

	@HANDLE = {v, v for v in *@_HANDLE}

	CanSerialize: (ent) => @@HANDLE[ent\GetClass()] ~= nil
	GetPriority: => 0

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
			return if not IsValid(ent)
			ent\Remove()
			ent = ents.Create(tag\GetTagValue('classname'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))

		if not tag\HasTag('map_id')
			ent\Spawn()
			ent\Activate()

		return ent

class DTransitions.ButtonSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'func_button'

	-- unstable, button functionality breaks, needs testing
	--CanSerialize: (ent) => ent\GetClass() == 'func_button'
	CanSerialize: (ent) => false
	GetPriority: => 10

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
		@DeserializeSavetable(ent, tag\GetTag('savetable'), true)

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
			return if not IsValid(ent)
			ent\Remove()
			ent = ents.Create(tag\GetTagValue('classname'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializePreSpawn(ent, tag)
		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))

		--if not tag\HasTag('map_id')
		ent\Spawn()
		ent\Activate()

		@DeserializePostSpawn(ent, tag)

		return ent

