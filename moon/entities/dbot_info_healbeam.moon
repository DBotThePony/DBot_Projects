
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
        if IsValid(@particleEffect)
            with @GetDummyTarget()
                \SetNoDraw(true)
                \DrawShadow(false)
                \SetModelScale(0.01)
                \SetMaterial('!DTF2_Translucent_Beam')
            return
        return if not IsValid(@GetDummyTarget())

        @GetDummyTarget()\SetNoDraw(true)
        @GetDummyTarget()\DrawShadow(false)
        @GetDummyTarget()\SetModelScale(0.01)
        @GetDummyTarget()\SetMaterial('!DTF2_Translucent_Beam')

        pointOne = {
            'entity': @
            'attachtype': PATTACH_ABSORIGIN_FOLLOW
        }

        pointTwo = {
            'entity': @GetDummyTarget()
            'attachtype': PATTACH_ABSORIGIN_FOLLOW
        }

        @particleEffect = @CreateParticleEffect(@GetBeamType() and 'dispenser_heal_blue' or 'dispenser_heal_red', {pointOne, pointTwo})
