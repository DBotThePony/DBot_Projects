
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
