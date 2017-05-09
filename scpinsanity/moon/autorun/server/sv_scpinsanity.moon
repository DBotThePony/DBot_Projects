
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

import CreateConVar from _G
import timer from _G
import concommand from _G
import IsValid from _G
import scripted_ents from _G
import hook from _G
import table from _G
import ents from _G
import player from _G

export SCP_NoKill, SCP_Ignore, SCP_HaveZeroHP, SCP_INSANITY_ATTACK_PLAYERS, SCP_GetTargets, SCP_INSANITY_ATTACK_NADMINS
export SCP_INSANITY_ATTACK_NSUPER_ADMINS

SCP_NoKill = false
SCP_Ignore = {
	bullseye_strider_focus: true
}
SCP_HaveZeroHP = {
	npc_rollermine: true
}

SCP_INSANITY_ATTACK_PLAYERS = CreateConVar('sv_scpi_players', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Whatever attack players')
SCP_INSANITY_ATTACK_NADMINS = CreateConVar('sv_scpi_not_admins', '0', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Whatever to NOT to attack admins')
SCP_INSANITY_ATTACK_NSUPER_ADMINS = CreateConVar('sv_scpi_not_superadmins', '0', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Whatever to NOT to attack superadmins')
VALID_NPCS = {}

concommand.Add 'scpi_reset173', (ply) ->
	if not ply\IsAdmin() return
	v.SCP_Killed = nil for v in *player.GetAll()

timer.Create 'SCPInsanity.UpdateNPCs', 1, 0, ->
	VALID_NPCS = for ent in *ents.GetAll()
		if not ent\IsNPC() continue
		if ent\GetNPCState() == NPC_STATE_DEAD continue
        if SCP_Ignore[ent\GetClass()] continue
        ent

SCP_GetTargets = ->
	reply = for ent in *VALID_NPCS
		if not IsValid(ent) continue
		if ent.SCP_SLAYED continue
		if ent.SCP_Killed continue
		ent
    
	if SCP_INSANITY_ATTACK_PLAYERS\GetBool()
		for ply in *player.GetAll()
			if ply\HasGodMode() continue
			if ply.SCP_Killed continue
			if SCP_INSANITY_ATTACK_NADMINS\GetBool() and ply\IsAdmin() continue
			if SCP_INSANITY_ATTACK_NSUPER_ADMINS\GetBool() and ply\IsSuperAdmin() continue
			table.insert(reply, ply)
	
	return reply

ENT = {}
ENT.PrintName = 'MAGIC'
ENT.Author = 'DBot'
ENT.Type = 'point'

scripted_ents.Register(ENT, 'dbot_scp173_killer')

hook.Add('OnNPCKilled', 'DBot.SCPInsanity', OnNPCKilled)
hook.Add('PlayerDeath', 'DBot.SCPInsanity', PlayerDeath)

hook.Add 'ACF_BulletDamage', 'DBot.SCPInsanity', (Activated, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun) ->
	if Entity\GetClass()\find('scp') return false
