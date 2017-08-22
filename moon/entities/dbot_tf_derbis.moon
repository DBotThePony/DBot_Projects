
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

ENT.PrintName = 'Building derbis'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

DERBIS_REMOVE_TIME = CreateConVar('tf_derbis_remove_timer', '45', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Derib removal timer') if SERVER

AccessorFunc(ENT, 'm_DerbisValue', 'DerbisValue')
AccessorFunc(ENT, 'm_dissolveAt', 'DissolveAt')

ENT.Initialize = =>
    @SetDerbisValue(15)
    -- @RealSetModel('models/buildables/gibs/sentry1_gib2.mdl')
    return if CLIENT
    @SetDissolveAt(CurTime() + DERBIS_REMOVE_TIME\GetInt())

ENT.RealSetModel = (mdl = 'models/buildables/gibs/sentry1_gib2.mdl') =>
    @SetModel(mdl)
    return if CLIENT
    @SetMoveType(MOVETYPE_VPHYSICS)
    @PhysicsInit(SOLID_VPHYSICS)
    @SetSolid(SOLID_VPHYSICS)
    @SetCollisionGroup(COLLISION_GROUP_WEAPON)
    with @phys = @GetPhysicsObject()
        \Wake() if \IsValid()

ENT.Shake = =>
    return if not IsValid(@phys)
    ang = AngleRand()
    ang.p = math.Clamp(ang.p, -180, 0)
    @phys\SetVelocity(ang\Forward() * math.random(160, 400))
    @SetAngles(ang)

ENT.Think = =>
    return false if CLIENT
    return @Remove() if not @GetDissolveAt() or @GetDissolveAt() < CurTime()
    pos = @GetPos()
    minDist = 99999
    for ply in *player.GetAll()
        dist = ply\GetPos()\Distance(pos)
        minDist = dist if minDist > dist
        if dist < 60 and DTF2.GiveAmmo(ply, @GetDerbisValue()) > 0
            @Remove()
            return false

    if minDist >= 512
        @NextThink(CurTime() + 0.75)
    else
        @NextThink(CurTime() + 0.1)

    return true
