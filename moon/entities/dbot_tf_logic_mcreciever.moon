

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
ENT.PrintName = 'Minicrit receiver'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER

entMeta = FindMetaTable('Entity')
entMeta.IsMarkedForDeath = => @GetNWInt('DTF2.MarksForDeath') > 0

with ENT
    .SetupDataTables = =>
        @NetworkVar('Entity', 0, 'MarkOwner')
    
    .Initialize = =>
        @SetNoDraw(true)
        @SetNotSolid(true)
        return if CLIENT
        @markStart = CurTime()
        @duration = 4
        @markEnd = @markStart + 4
        @SetMoveType(MOVETYPE_NONE)
    
    .UpdateDuration = (newtime = 0) =>
        return if @markEnd - CurTime() > newtime
        @duration = newtime
        @markEnd = CurTime() + newtime
    
    .SetupOwner = (owner) =>
        @SetPos(owner\GetPos())
        return if owner == @GetOwner()
        if IsValid(@GetOwner())
            @GetOwner()\SetNWInt('DTF2.MarksForDeath', @GetOwner()\GetNWInt('DTF2.MarksForDeath') - 1)
        @SetOwner(owner)
        @SetParent(owner)
        owner\SetNWInt('DTF2.MarksForDeath', owner\GetNWInt('DTF2.MarksForDeath') + 1)

    .Think = =>
        return if CLIENT
        return @Remove() if @markEnd < CurTime()
        return @Remove() if not IsValid(@GetOwner())
    
    .OnRemove = =>
        owner = @GetOwner()
        return if not IsValid(owner)
        owner\SetNWInt('DTF2.MarksForDeath', owner\GetNWInt('DTF2.MarksForDeath') - 1)
    .Draw = => false
