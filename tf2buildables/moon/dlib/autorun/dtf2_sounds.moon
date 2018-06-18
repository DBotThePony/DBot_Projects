
--
-- Copyright (C) 2017-2018 DBot
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

RequiredFiles = {
	'dtf2_sounds'
	'dtf2_sounds_mvm'
	'dtf2_sounds_passtime'
	'dtf2_sounds_physics'
	'dtf2_sounds_player'
	'dtf2_sounds_taunt_workshop'
	'dtf2_sounds_weapons'
}

if SERVER
	AddCSLuaFile("tf2scripts/#{fil}.lua") for fil in *RequiredFiles
file.CreateDir('dtf2sounds')

return if DTF2.LOAD_SOUNDS
DTF2.LOAD_SOUNDS = true

file.Write("dtf2sounds/#{fil}.txt", CompileFile("tf2scripts/#{fil}.lua")()) for fil in *RequiredFiles
sound.AddSoundOverrides("data/dtf2sounds/#{fil}.txt") for fil in *RequiredFiles
