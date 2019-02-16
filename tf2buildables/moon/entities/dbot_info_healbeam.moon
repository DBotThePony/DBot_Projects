
--
-- Copyright (C) 2017-2019 DBot

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


AddCSLuaFile()

ENT.Type = 'anim'
ENT.Base = 'base_anim'
ENT.PrintName = 'Beam effect'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.SetupDataTables = =>
	@NetworkVar('Bool', 0, 'BeamType')
	@NetworkVar('Entity', 0, 'EntityTarget')
	@NetworkVar('Entity', 1, 'DummyTarget')

ENT.Initialize = =>
	if SERVER
		@SetModel('models/props_junk/popcan01a.mdl')
		@DrawShadow(false)
		@SetSolid(SOLID_NONE)
		@SetMoveType(MOVETYPE_NONE)
	else
		@SetModel('models/props_junk/popcan01a.mdl')
		@DrawShadow(false)
		@beamSound = CreateSound(@, 'weapons/dispenser_heal.wav')
		@beamSound\ChangeVolume(0.75)
		@beamSound\SetSoundLevel(60)
		@beamSound\Play()

ENT.UpdateDummy = =>
	return if not IsValid(@GetEntityTarget())
	@dummyTarget\Remove() if IsValid(@dummyTarget)
	@dummyTarget = ents.Create('prop_dynamic')
	@dummyTarget\SetModel('models/props_junk/popcan01a.mdl')
	@dummyTarget\SetPos(@GetEntityTarget()\GetPos() + @GetEntityTarget()\OBBCenter() + Vector(0, 0, 20))
	@dummyTarget\SetParent(@GetEntityTarget())
	@dummyTarget\Spawn()
	@dummyTarget\Activate()
	@dummyTarget\DrawShadow(false)
	@SetDummyTarget(@dummyTarget)

ENT.OnRemove = =>
	@particleEffect\StopEmission() if IsValid(@particleEffect)
	@dummyTarget\Remove() if IsValid(@dummyTarget)
	@beamSound\Stop() if @beamSound

if CLIENT
	translucentMaterual = CreateMaterial('DTF2_Translucent_Beam', 'VertexLitGeneric', {
		'$translucent': '1'
		'$alpha': '0'
		'$color': '[0 0 0]'
	})

	ENT.Draw = =>
		return if not IsValid(@GetDummyTarget())
		if IsValid(@particleEffect)
			with @GetDummyTarget()
				\SetNoDraw(true)
				\DrawShadow(false)
				\SetModelScale(0.01)
				\SetMaterial('!DTF2_Translucent_Beam')
			return

		with @GetDummyTarget()
				\SetNoDraw(true)
				\DrawShadow(false)
				\SetModelScale(0.01)
				\SetMaterial('!DTF2_Translucent_Beam')

		pointOne = {
			'entity': @
			'attachtype': PATTACH_ABSORIGIN_FOLLOW
		}

		pointTwo = {
			'entity': @GetDummyTarget()
			'attachtype': PATTACH_ABSORIGIN_FOLLOW
		}

		@particleEffect = @CreateParticleEffect(@GetBeamType() and 'dispenser_heal_blue' or 'dispenser_heal_red', {pointOne, pointTwo})

	ENT.Think = ENT.Draw
