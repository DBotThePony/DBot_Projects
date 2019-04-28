
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

class DTransitions.BuiltinSoftSerializer extends DTransitions.AbstractSerializer
	@SAVENAME = 'builtin_logic'

	@SAVETABLE_IGNORANCE = {}

	@_HANDLE = {
		'env_explosion'
		'env_fade'
		'env_projectedtexture'
		'env_spark'
		'env_steam'
		'env_zoom'
		'env_citadel_energy_core'

		-- 'env_sprite' -- it is getting recreated by many entities
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

		'func_illusionary'
		'aiscripted_schedule'

		'relationship'

		'logic_relay'
		'logic_timer'
		'logic_auto'
		'logic_case'
		'logic_compare'
		'info_particle_system'
		'func_clip_vphysics'

		'math_remap'
		'math_colorblend'
		'momentary_rot_button'
		'point_velocitysensor'

		'point_template'

		'npc_maker'
		'npc_template_maker'
		'entityflame'

		'func_breakable'
		'func_physbox'
		'func_tracktrain'
		'func_tracktrain'
		--'func_breakable_surf'
		'filter_activator_name'
		'func_rotating'

		'npc_antlion_grub'
		'scripted_sequence'
		'script_conditions'
		'script_intro'

		'goal_assault'
		'goal_follow'
		'goal_lead'

		'light_dynamic'
		'light_spot'

		'material_modify_control'

		'game_text'

		'func_monitor'
		'func_occluder'
		'func_multi'

		'point_viewcontrol'

		'trigger_multiple'
		'trigger_once'
		'trigger_playermovement'
		'trigger_serverragdoll'
		'trigger_push'

		'npc_antlion_template_maker'
		'npc_eventresponsesystem'
		'point_camera'
		'point_spotlight'
		'point_teleport'
		'path_track'
		'player_speedmod'
		"instanced_scripted_scene"
	}

	@HANDLE = {v, v for v in *@_HANDLE}

	CanSerialize: (ent) => @@HANDLE[ent\GetClass()] ~= nil
	GetPriority: => 0

	Serialize: (ent) =>
		tag = super(ent, true)
		return if not tag

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
		ent = @GetEntityPersistent(tag)
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
		'ally_speech_manager'
		'ally_manager'
		'game_ragdoll_manager'
	}

	@HANDLE = {v, v for v in *@_HANDLE}

	DeserializePre: (tag) =>
		ent = ents.FindByClass(tag\HasTag('real_classname') and tag\GetTagValue('real_classname') or tag\GetTagValue('classname'))
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

		'filter_activator_name'
		'filter_enemy'
		'filter_activator_class'

		'filter_enemy'
		'filter_activator_class'
	}

	@HANDLE = {v, v for v in *@_HANDLE}

	CanSerialize: (ent) => @@HANDLE[ent\GetClass()] ~= nil
	GetPriority: => 0

	DeserializePost: (ent, tag) =>
		super(ent, tag)
		ent\Spawn()
		ent\Activate()

	DeserializePre: (tag) =>
		ent = @GetEntityReplace(tag)
		return if not IsValid(ent)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))

		return ent

class DTransitions.BuiltinFilterSerializer extends DTransitions.BuiltinHardSerializer
	@SAVENAME = 'builtin_filter'

	@_HANDLE = {
		'filter_multi'
	}

	@HANDLE = {v, v for v in *@_HANDLE}

	SerializeSavetableValue: (ent, kv, tag, key, value) =>
		return super(ent, kv, tag, key, value) if key ~= 'm_hFilter'
		list = tag\AddIntArray('m_hFilter')

		for ent in *value
			if IsValid(ent)
				list\AddValue(@GetEntityID(ent))
			else
				list\AddValue(-1)

	DeserializeSavetableValue: (ent, tag, entsNow, key, value) =>
		return super(ent, tag, entsNow, key, value) if not entsNow or key ~= 'm_hFilter'
		tab = [@GetEntity(id\GetValue()) for i, id in value\ipairs()]
		ent\SetSaveValue(key, tab)
		return

class DTransitions.ButtonSerializer extends DTransitions.AbstractSerializer
	@SAVENAME = 'func_button'

	-- unstable, button functionality breaks, needs testing
	--CanSerialize: (ent) => ent\GetClass() == 'func_button'
	CanSerialize: (ent) => false
	GetPriority: => 10

	Serialize: (ent) =>
		tag = super(ent)
		return if not tag

		if sv = @SerializeSavetable(ent)
			tag\SetTag('savetable', sv)

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag)
		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'), true)
		@DeserializeSavetable(ent, tag\GetTag('savetable'), true)

		ent\Spawn()
		ent\Activate()

		@DeserializePostSpawn(ent, tag)

	DeserializePre: (tag) =>
		ent = @GetEntityReplace(tag)
		return if not IsValid(ent)

		@DeserializePreSpawn(ent, tag)
		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))

		return ent

