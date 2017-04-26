
--
-- Copyright (C) 2017 DBot
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
DISPLAY_DEATHS_NPC = CreateConVar('sv_dmaps_deathpoints_npc', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable NPCs death points')
DISPLAY_DEATHS_PLAYER = CreateConVar('sv_dmaps_deathpoints_player', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable Players death points')

hook.Add 'OnNPCKilled', 'DMaps.Hooks', (npc = NULL, attacker = NULL, weapon = NULL) ->
	return if not DISPLAY_DEATHS\GetBool()
	return if not DISPLAY_DEATHS_NPC\GetBool()
	return if not IsValid(npc)
	net.Start('DMaps.NPCDeath')
	net.WriteEntity(npc)
	net.Broadcast()

hook.Add 'PlayerDeath', 'DMaps.Hooks', (ply = NULL, weapon = NULL, attacker = NULL) ->
	return if not DISPLAY_DEATHS\GetBool()
	return if not DISPLAY_DEATHS_PLAYER\GetBool()
	return if not IsValid(ply)
	net.Start('DMaps.PlayerDeath')
	net.WriteEntity(ply)
	net.WriteVector(ply\GetPos())
	net.Broadcast()
