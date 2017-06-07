
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
    
    .Initialize = =>
        @SetNoDraw(true)
        @SetNotSolid(true)
        @BuffedTargets = {}
        return if CLIENT
        @SetMoveType(MOVETYPE_NONE)

    .Think = =>
        owner = @GetOwner()
    
    .Draw = => false
