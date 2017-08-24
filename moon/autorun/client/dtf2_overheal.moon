
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

TRACKED_ENTITIES = {}
REBUILD_TRACKED_ENTS = -> TRACKED_ENTITIES = [ent for ent in *TRACKED_ENTITIES when ent\IsValid() and ent\Health() > ent\GetMaxHealth()]
hook.Add 'EntityRemoved', 'DTF2.OverhealRebuild', -> timer.Create 'DTF2.OverhealRebuild', 0, 1, REBUILD_TRACKED_ENTS

net.Receive 'DTF2.TrackOverhealEffect', ->
    self = net.ReadEntity()
    status = net.ReadBool()
    return if not IsValid(@)
    if status
        for ent in *TRACKED_ENTITIES
            return if ent == @
        table.insert(TRACKED_ENTITIES, @)
    else
        for i = 1, #TRACKED_ENTITIES
            if TRACKED_ENTITIES[i] == @
                table.remove(TRACKED_ENTITIES, i)
                return
        if IsValid(@DTF2_OverhealParticleSystem)
            @DTF2_OverhealParticleSystem\StopEmission()

hook.Add 'Think', 'DTF2.OverhealThink', ->
    hitUpdate = false
    cTime = CurTime()
    for self in *TRACKED_ENTITIES
        return REBUILD_TRACKED_ENTS() if not @IsValid()
        if @Health() > @GetMaxHealth()
            if not IsValid(@DTF2_OverhealParticleSystem)
                @DTF2_OverhealParticleSystem = CreateParticleSystem(@, 'overhealedplayer_red_pluses', PATTACH_ABSORIGIN_FOLLOW, 0)
        else
            if IsValid(@DTF2_OverhealParticleSystem)
                @DTF2_OverhealParticleSystem\StopEmission()
                @DTF2_OverhealParticleSystem = nil
            hitUpdate = true
        
    REBUILD_TRACKED_ENTS() if hitUpdate
