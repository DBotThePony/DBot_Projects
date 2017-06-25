
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

export DTF2
DTF2 = DTF2 or {}

DTF2.TableRandom = (tab, id = 'dtf2_prediction') ->
    valids = [val for val in *tab when type(val) ~= 'table']
    return nil if #valids == 0
    rand = math.floor(util.SharedRandom('dtf2', 1, #valids * 100, CurTime()) / 100 + 0.5)
    return valids[rand]

DTF2.ApplyVelocity = (ent, vel) ->
    if not ent\IsPlayer() and not ent\IsNPC()
        for i = 0, ent\GetPhysicsObjectCount() - 1
            phys = ent\GetPhysicsObjectNum(i)
            phys\AddVelocity(vel) if IsValid(phys)
    else
        ent\SetVelocity(vel + Vector(0, 0, 100))

DTF2.PlayCritEffect = (hitEntity) ->
    mins, maxs = hitEntity\GetRotatedAABB(hitEntity\OBBMins(), hitEntity\OBBMaxs())
    pos = hitEntity\GetPos()
    newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
    pos.z = newZ

    effData = EffectData()
    effData\SetOrigin(pos)
    util.Effect('dtf2_critical_hit', effData)
    hitEntity\EmitSound('DTF2_TFPlayer.CritHit')

DTF2.PlayMiniCritEffect = (hitEntity) ->
    mins, maxs = hitEntity\GetRotatedAABB(hitEntity\OBBMins(), hitEntity\OBBMaxs())
    pos = hitEntity\GetPos()
    newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
    pos.z = newZ

    effData = EffectData()
    effData\SetOrigin(pos)
    util.Effect('dtf2_minicrit', effData)
    hitEntity\EmitSound('DTF2_TFPlayer.CritHitMini')
