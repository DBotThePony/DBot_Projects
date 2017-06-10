

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
SWEP.PrintName = 'Sun on a Stick'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_rift_fire_mace/c_rift_fire_mace.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.BulletDamage = 35 * .75

SWEP.PreOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    @BaseClass.PreOnHit(@, hitEntity, tr, dmginfo)
    if IsValid(hitEntity) and hitEntity\IsTF2Burning()
        @ThatWasCrit(hitEntity, dmginfo)
if SERVER
    hook.Add 'EntityTakeDamage', 'DTF2.SunOnAStick', (ent, dmg) ->
        return unless ent\IsPlayer()
        wep = ent\GetWeapon('dbot_tf_sunonstick')
        return if not IsValid(wep)
        dmg\ScaleDamage(.75)
