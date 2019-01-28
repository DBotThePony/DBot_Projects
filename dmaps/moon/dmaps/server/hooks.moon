
--
-- Copyright (C) 2017-2019 DBot
--
-- Licensed under the Apache License, Version 2.0 (the 'License');
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an 'AS IS' BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

import DMaps, hook, CreateConVar from _G

DISPLAY_DEATHS = CreateConVar('sv_dmaps_deathpoints', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable death points (players/NPCs)')
DISPLAY_DEATHS_FORCE_DIABLE = CreateConVar('sv_dmaps_deathpoints_fdisable', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Force disable of ANY death waypoints')
DISPLAY_DEATHS_NPC = CreateConVar('sv_dmaps_deathpoints_npc', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable NPCs death points')
DISPLAY_DEATHS_PLAYER = CreateConVar('sv_dmaps_deathpoints_player', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable Players death points')

netDMGTable = {
	DMG_BLAST
	DMG_BLAST_SURFACE
	DMG_SLASH
	DMG_CLUB
	DMG_ENERGYBEAM
	DMG_PLASMA
	DMG_DISSOLVE
	DMG_SHOCK
	DMG_GENERIC
	DMG_BULLET
	DMG_BUCKSHOT
	DMG_DIRECT
	DMG_CRUSH
	DMG_PHYSGUN
	DMG_BURN
	DMG_SLOWBURN
	DMG_DROWN
	DMG_DROWNRECOVER
	DMG_FALL
	DMG_PARALYZE
	DMG_NERVEGAS
	DMG_POISON
	DMG_ACID
	DMG_RADIATION
}

netDMGTableBackward = {v, k for k, v in pairs netDMGTable}

hook.Add 'OnNPCKilled', 'DMaps.Hooks', (npc = NULL, attacker = NULL, weapon = NULL) ->
	return if DISPLAY_DEATHS_FORCE_DIABLE\GetBool()
	return if not DISPLAY_DEATHS\GetBool()
	return if not DISPLAY_DEATHS_NPC\GetBool()
	return if not IsValid(npc)
	net.Start('DMaps.NPCDeath')
	net.WriteEntity(npc)
	net.Broadcast()

hook.Add 'PlayerEnteredVehicle', 'DMaps.Hooks', (ply = NULL, veh = NULL, role = 0) ->
	if not IsValid(ply) or not IsValid(veh) return
	veh\SetNWEntity('DMaps.Driver', ply)

hook.Add 'PlayerLeaveVehicle', 'DMaps.Hooks', (ply = NULL, veh = NULL) ->
	if not IsValid(ply) or not IsValid(veh) return
	veh\SetNWEntity('DMaps.Driver', NULL)

hook.Add 'DoPlayerDeath', 'DMaps.Hooks', (ply = NULL, attacker = NULL, dmg = DamageInfo()) ->
	return if not IsValid(ply)
	return if DISPLAY_DEATHS_FORCE_DIABLE\GetBool()
	if not DISPLAY_DEATHS\GetBool() or not DISPLAY_DEATHS_PLAYER\GetBool()
		net.Start('DMaps.PlayerDeath')
		net.WriteEntity(ply)
		net.WriteVector(ply\GetPos())
		net.Send(ply)
		return
	net.Start('DMaps.PlayerDeath')
	net.WriteEntity(ply)
	net.WriteVector(ply\GetPos())
	dmgType = netDMGTableBackward[dmg\GetDamageType() or DMG_GENERIC]
	net.WriteBool(dmgType ~= nil)
	net.WriteUInt(dmgType, 8) if dmgType
	net.Broadcast()
