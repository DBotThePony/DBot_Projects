
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

include 'shared.lua'
AddCSLuaFile 'shared.lua'

ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @healing = {}
    @beams = {}

ENT.HealTarget = (ent = NULL, delta = 1) =>
    return if not IsValid(ent)
    hp = ent\Health()
    mhp = ent\GetMaxHealth()
    if hp < mhp
        healAdd = math.Clamp(mhp - hp, 0, delta * @GetRessuplyMultiplier() * @HEAL_SPEED_MULT)
        ent\SetHealth(hp + healAdd)
    return if not ent\IsPlayer()

ENT.BehaveUpdate = (delta) =>
    @UpdateRelationships()
    if not @IsAvaliable()
        @currentTarget = NULL
        return
    
    @healing = @GetAlliesVisible()
    beam.__isValid = false for ply, beam in pairs @beams

    for ply in *@healing
        if not @beams[ply]
            @beams[ply] = ents.Create('dbot_info_healbeam')
            with @beams[ply]
                \SetBeamType(@GetTeamType())
                \SetEntityTarget(ply)
                \SetPos(@GetPos() + @OBBCenter())
                \Spawn()
                \Activate()
                \SetParent(@)
                \UpdateDummy()
        @beams[ply].__isValid = true

    for ply, beam in pairs @beams
        if not beam.__isValid
            beam\Remove()
            @beams[ply] = nil

    @HealTarget(ply, delta) for ply in *@healing
ENT.Think = =>
    @NextThink(CurTime() + 0.1)
    return true
