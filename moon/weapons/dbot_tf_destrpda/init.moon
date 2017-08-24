
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

AddCSLuaFile 'cl_init.lua'
include 'shared.lua'

util.AddNetworkString('DTF2.DestroyRequest')

DEFINE_BASECLASS('dbot_tf_weapon_base')

net.Receive 'DTF2.DestroyRequest', (len = 0, ply = NULL) ->
    return if not IsValid(ply)
    slot = net.ReadUInt(8)
    ent = net.ReadEntity()
    return if not IsValid(ply)
    return if ent\GetClass() ~= 'dbot_tf_destrpda'
    ent\TriggerDestructionRequest(slot)

holster = (ply, wep) =>
    ply\SetActiveWeapon(wep)
    ply\SelectWeapon(wep)
    @Holster()

SWEP.SwitchToWrench = =>
    weapon_crowbar = false
    dbot_tf_wrench = false
    ply = @GetOwner()
    return false if not IsValid(ply) or not ply\IsPlayer()
    for wep in *ply\GetWeapons()
        switch wep\GetClass()
            when 'weapon_crowbar'
                weapon_crowbar = true
            when 'dbot_tf_wrench'
                dbot_tf_wrench = true
    if dbot_tf_wrench
        holster(@, ply, 'dbot_tf_wrench')
        return true
    elseif weapon_crowbar
        holster(@, ply, 'weapon_crowbar')
        return true
    return false
