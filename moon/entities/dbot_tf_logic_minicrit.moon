
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
        table.insert(@BuffedTargets, owner) if @GetEnableBuff() IsValid(owner)
        if @GetEnableBuff() @GetRange() and @GetRange() > 0
            everything = @GetAffectEverything()
            npcs = @GetAffectNPCs()
            for ent in *ents.FindInSphere(@GetPos(), @GetRange())
                if everything
                    table.insert(@BuffedTargets, ent)
                elseif ent\IsPlayer()
                    table.insert(@BuffedTargets, ent)
                elseif npcs and ent\IsNPC()
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
    
    .OnRemove = => newTarget\AddMiniCritBuffer() for newTarget in *@BuffedTargets
    
    .Draw = => false
