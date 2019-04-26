
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

class DTransitions.EntitySerializerBase
	new: (saveInstance) =>
		@saveInstance = saveInstance

	CanSerialize: (ent) => false
	GetPriority: => 0
	Serialize: (ent) => error('Not implemented')

	UnSerializePre: (tag) => error('Not implemented')
	UnSerializePost: (ent, tag) =>

	UnSerializeGeneric: (ent, tag) =>
		ent\SetRenderFX(tag\GetTagValue('fx')) if tag\HasTag('fx')
		ent\SetRenderMode(tag\GetTagValue('rmode')) if tag\HasTag('rmode')
		ent\SetColor(tag\GetColor('color'))if tag\HasTag('color')

	SerializeGeneric: (ent, tag) =>
		with ent
			fx = \GetRenderFX()
			rmode = \GetRenderMode()
			color = \GetColor()

			tag\SetByte('fx', fx) if fx
			tag\SetByte('rmode', rmode) if rmode
			tag\SetColor('color', color) if color

	SerializeCombatState: (ent, tag) =>
		with ent
			tag\SetInt('health', \Health())
			tag\SetInt('max_health', \GetMaxHealth())
			tag\SetInt('armor', \Armor()) if .Armor
			tag\SetInt('max_armor', \GetMaxArmor()) if .GetMaxArmor

	UnSerializeCombatState: (ent, tag) =>
		with ent
			\SetHealth(tag\GetTagValue('health')) if tag\HasTag('health') and .SetHealth
			\SetMaxHealth(tag\GetTagValue('max_health')) if tag\HasTag('max_health') and .SetMaxHealth
			\SetArmor(tag\GetTagValue('armor')) if tag\HasTag('armor') and .SetArmor
			\SetMaxArmor(tag\GetTagValue('max_armor')) if tag\HasTag('max_armor') and .SetMaxArmor

	UnSerializeMeta: (ent, tag) =>
		ent\SetOwner(@saveInstance\GetEntity(tag\GetTagValue('owner'))) if tag\HasTag('owner')
		ent\SetParent(@saveInstance\GetEntity(tag\GetTagValue('parent'))) if tag\HasTag('parent')

	SerializeMeta: (ent, tag) =>
		with ent
			owner = \GetOwner()
			parent = \GetParent()

			tag\SetShort('owner', @saveInstance\GetEntityID(owner)) if IsValid(owner)
			tag\SetShort('parent', @saveInstance\GetEntityID(parent)) if IsValid(parent)

	UnSerializePosition: (ent, tag) =>
		ent\SetPos(tag\GetVector('pos'))
		ent\SetAngles(tag\GetAngle('ang'))
		ent\SetEyeAngles(tag\GetAngle('eang')) if ent.SetEyeAngles and tag\HasTag('eang')

	SerializePosition: (ent, tag) =>
		with ent
			tag\SetVector('pos', \GetPos())
			tag\SetAngle('ang', \GetAngles())
			tag\SetAngle('eang', \EyeAngles()) if .EyeAngles

class DTransitions.PlayerSerializer extends DTransitions.EntitySerializerBase
	@SAVENAME = 'player'

	CanSerialize: (ent) => ent\IsPlayer()
	GetPriority: => 1000

	Serialize: (ply) =>
		tag = NBT.TagCompound()
		@SerializePosition(ply, tag)
		@SerializeGeneric(ply, tag)
		@SerializeCombatState(ply, tag)

		tag\SetString('steamid', ply\SteamID())

		return tag

	UnSerializePre: (tag) =>
		ply = player.GetBySteamID(tag\GetTagValue('steamid'))
		return NULL if not ply

		@UnSerializePosition(ply, tag)
		@UnSerializeGeneric(ply, tag)
		@UnSerializeCombatState(ply, tag)

		return ply
