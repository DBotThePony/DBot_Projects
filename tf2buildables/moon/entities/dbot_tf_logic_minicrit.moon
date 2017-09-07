
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

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
