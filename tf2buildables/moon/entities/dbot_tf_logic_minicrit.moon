
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
ENT.PrintName = 'Minicrit Logic'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER

with ENT
	.SetupDataTables = =>
		@NetworkVar('Int', 0, 'Range')
		@NetworkVar('Bool', 0, 'EnableBuff')
		@NetworkVar('Bool', 1, 'AffectNPCs')
		@NetworkVar('Bool', 2, 'AffectNextBots')
		@NetworkVar('Bool', 3, 'AffectEverything')

	.Initialize = =>
		@SetNoDraw(true)
		@SetNotSolid(true)
		@BuffedTargets = {}
		return if CLIENT
		@SetMoveType(MOVETYPE_NONE)

	.Think = =>
		owner = @GetOwner()
		oldTargets = @BuffedTargets
		@BuffedTargets = {}
		table.insert(@BuffedTargets, owner) if @GetEnableBuff() and IsValid(owner)
		if @GetEnableBuff() and @GetRange() and @GetRange() > 0
			everything = @GetAffectEverything()
			npcs = @GetAffectNPCs()
			nextbots = @GetAffectNextBots()
			for ent in *ents.FindInSphere(@GetPos(), @GetRange())
				if ent\IsPlayer()
					table.insert(@BuffedTargets, ent) if ent\Alive()
				elseif everything
					table.insert(@BuffedTargets, ent)
				elseif npcs and ent\IsNPC()
					table.insert(@BuffedTargets, ent)
				elseif nextbots and ent.Type == 'nextbot'
					table.insert(@BuffedTargets, ent)
		for oldTarget in *oldTargets
			hit = false
			for newTarget in *@BuffedTargets
				if oldTarget == newTarget
					hit = true
					break
			if not hit
				oldTarget\RemoveMiniCritBuffer()
				oldTarget\UpdateMiniCritBuffers()

		for newTarget in *@BuffedTargets
			hit = false
			for oldTarget in *oldTargets
				if oldTarget == newTarget
					hit = true
					break
			if not hit
				newTarget\AddMiniCritBuffer()
				newTarget\UpdateMiniCritBuffers()

		@NextThink(CurTime() + .25)
		return true

	.OnRemove = =>
		for newTarget in *@BuffedTargets
			newTarget\RemoveMiniCritBuffer()
			newTarget\UpdateMiniCritBuffers()

	.Draw = => false
