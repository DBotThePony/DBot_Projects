
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
export SCP_CreateNPCTargets
export SCP_IsValidTarget

SCP_NoKill = false

SCP_Ignore = {
	bullseye_strider_focus: true
	npc_bullseye: true
	ai_relationship: true
}

SCP_HaveZeroHP = {
	npc_rollermine: true
}

SCP_INSANITY_ATTACK_PLAYERS = CreateConVar('sv_scpi_players', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Whatever attack players')
SCP_INSANITY_ATTACK_NADMINS = CreateConVar('sv_scpi_not_admins', '0', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Whatever to NOT to attack admins')
SCP_INSANITY_ATTACK_NSUPER_ADMINS = CreateConVar('sv_scpi_not_superadmins', '0', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Whatever to NOT to attack superadmins')
VALID_NPCS = {}

SCP_IsValidTarget = (ent) ->
	return false unless IsValid(ent)
	return false if SCP_Ignore[ent\GetClass()]
	return true

UpdateNPCs = ->
	VALID_NPCS = for ent in *ents.GetAll()
		nclass = ent\GetClass()
		if not nclass continue
		if not ent\IsNPC() continue
		if ent\GetNPCState() == NPC_STATE_DEAD continue
		if SCP_Ignore[nclass] continue
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

SCP_CreateNPCTargets = =>
	mins, maxs, center = @OBBMins(), @OBBMaxs(), @OBBCenter()

	box = {
		Vector(0, 0, mins.z)
		Vector(0, 0, maxs.z)

		Vector(mins.x, center.y, center.z)
		Vector(-mins.x, center.y, center.z)

		Vector(center.x, mins.y, center.z)
		Vector(center.x, -mins.y, center.z)
	}

	if @bullseyes
		for eye in *@bullseyes
			eye\Remove() if IsValid(eye)

	nclass = "#{@GetClass()}_bullseye"
	@bullseyes = for vec in *box
		with ents.Create('npc_bullseye')
			\SetKeyValue('targetname', nclass)
			\SetPos(@LocalToWorld(vec))
			\Spawn()
			\Activate()
			\SetParent(@)
			--\SetNotSolid(true)
			\SetHealth(2 ^ 31 - 1)


concommand.Add 'scpi_reset173', (ply) ->
	if not ply\IsAdmin() return
	v.SCP_Killed = nil for v in *player.GetAll()

timer.Create 'SCPInsanity.UpdateNPCs', 1, 0, UpdateNPCs
hook.Add('OnNPCKilled', 'DBot.SCPInsanity', OnNPCKilled)
hook.Add('PlayerDeath', 'DBot.SCPInsanity', PlayerDeath)

for ship in *ents.FindByClass('ai_relationship')
 	ship\Remove() if ship.SCP_INSANITY

SCP_INSANITY_RELATIONSHIPS = {}

-- 1 - Hate D_HT
-- 2 - Fear D_FR
-- 3 - Like D_LI
-- 4 - Neutral D_NU
TO_ATTACK = {
	{'173', D_FR}
	{'689', D_FR}
	{'522', D_FR}
}

OnEntityCreated = =>
	timer.Simple 0, ->
		return if not IsValid(@)
		return if not @IsNPC()
		entClass = @GetClass()
		return if SCP_INSANITY_RELATIONSHIPS[entClass]
		return if SCP_Ignore[entClass]
		
		SCP_INSANITY_RELATIONSHIPS[entClass] = for {scp, relation} in *TO_ATTACK
			with ents.Create('ai_relationship')
				\SetKeyValue('subject', entClass)
				\SetKeyValue('target', "dbot_scp#{scp}_bullseye")
				\SetKeyValue('StartActive', '1')
				\SetKeyValue('Disposition', "#{relation}")
				\SetKeyValue('Reciprocal', '1')
				\Spawn()
				\Activate()
				\Fire('ApplyRelationship', '', 0)
				.SCPName = "dbot_scp#{scp}"
				.NPCName = entClass
				.SCP_INSANITY = true

OnEntityCreated(ent) for ent in *ents.GetAll()
hook.Add 'OnEntityCreated', 'SCPInsanity.Relationships', OnEntityCreated

hook.Add 'ACF_BulletDamage', 'DBot.SCPInsanity', (Activated, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun) ->
	if Entity\GetClass()\find('scp') return false
