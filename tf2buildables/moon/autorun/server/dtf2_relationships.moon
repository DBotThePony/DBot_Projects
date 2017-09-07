
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

CLASS_SCIENTIST = 27
CLASS_ENEMY_GRUNT = 28
CLASS_ALIEN_ARMY = 29
CLASS_XEN_ANIMALS = 30
CLASS_XEN_ANIMALS_HEADCRAB = 31
CLASS_XEN_ANIMALS_HOSTILE = 32
CLASS_XEN_BUG = 33
CLASS_SNARK = 35

ATTACK_PLAYERS = CreateConVar('tf_attack_players', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Sentries attacks players')

ENTMETA = FindMetaTable('Entity')
NPCMETA = FindMetaTable('NPC')
ENT_OBBCENTER = ENTMETA.OBBCenter
ENT_GETCLASS = ENTMETA.GetClass
NPC_CLASSIFY = NPCMETA.Classify

DTF2.IS_ENEMY_CLASS = (entClass, def = false) ->
	entClass = ENT_GETCLASS(entClass) if type(entClass) ~= 'string'
	switch entClass
		when 'replicator_queen_hive', 'replicator_queen', 'replicator_worker'
			return true
		else
			return def

DTF2.IsAlly = (ent, def = false, checkForPly = true) ->
	return not ATTACK_PLAYERS\GetBool() if checkForPly and type(ent) == 'Player'
	return true if not checkForPly and type(ent) == 'Player'
	return IS_ENEMY_CLASS(ent, def) if type(ent) ~= 'NPC'
	classify = NPC_CLASSIFY(ent)
	return classify == CLASS_PLAYER_ALLY or
			classify == CLASS_PLAYER_ALLY_VITAL or
			classify == CLASS_PLAYER_ALLY_VITAL or
			classify == CLASS_CITIZEN_PASSIVE or
			classify == CLASS_HACKED_ROLLERMINE or
			classify == CLASS_SCIENTIST or
			classify == CLASS_EARTH_FAUNA or
			classify == CLASS_VORTIGAUNT or
			classify == CLASS_CITIZEN_REBEL

DTF2.IsEnemy = (ent, def = true, checkForPly = true) ->
	return ATTACK_PLAYERS\GetBool() if checkForPly and type(ent) == 'Player'
	return false if not checkForPly and type(ent) == 'Player'
	return IS_ENEMY_CLASS(ent, def) if type(ent) ~= 'NPC'
	classify = NPC_CLASSIFY(ent)
	return classify == CLASS_COMBINE_HUNTER or
			classify == CLASS_ALIEN_ARMY or
			classify == CLASS_XEN_ANIMALS or
			classify == CLASS_XEN_ANIMALS_HOSTILE or
			classify == CLASS_XEN_ANIMALS_HEADCRAB or
			classify == CLASS_SNARK or
			classify == CLASS_XEN_BUG or
			classify == CLASS_ENEMY_GRUNT or
			classify == CLASS_SCANNER or
			classify == CLASS_ZOMBIE or
			classify == CLASS_PROTOSNIPER or
			classify == CLASS_STALKER or
			classify == CLASS_MILITARY or
			classify == CLASS_METROPOLICE or
			classify == CLASS_MANHACK or
			classify == CLASS_HEADCRAB or
			classify == CLASS_COMBINE_GUNSHIP or
			classify == CLASS_BARNACLE or
			classify == CLASS_ANTLION or
			classify == CLASS_NONE or
			classify == CLASS_COMBINE
