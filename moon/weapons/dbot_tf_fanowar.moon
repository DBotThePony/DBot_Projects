

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

BaseClass = baseclass.Get('dbot_tf_bat')

SWEP.Base = 'dbot_tf_bat'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = "Fan O' War"
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shogun_warfan/c_shogun_warfan.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.BulletDamage = 35 * .25

SWEP.PreOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    @BaseClass.PreOnHit(@, hitEntity, tr, dmginfo)
    if IsValid(hitEntity) and hitEntity\IsMarkedForDeath()
        @ThatWasCrit(hitEntity, dmginfo)
    
    return if CLIENT
    if IsValid(hitEntity) and (hitEntity\IsNPC() or hitEntity\IsPlayer())
        if IsValid(@deathMark)
            if @deathMark\GetOwner() ~= hitEntity
                hitEntity\EmitSound('weapons/samurai/tf_marked_for_death_indicator.wav', 60, 100, 0.75)
                @deathMark\SetupOwner(hitEntity)
            @deathMark\UpdateDuration(15)
            return
        @deathMark = ents.Create('dbot_tf_logic_mcreciever')
        with @deathMark
            \SetPos(tr.HitPos)
            \Spawn()
            \Activate()
            \SetupOwner(hitEntity)
            \UpdateDuration(15)
            \EmitSound('weapons/samurai/tf_marked_for_death_indicator.wav', 60, 100, 0.75)