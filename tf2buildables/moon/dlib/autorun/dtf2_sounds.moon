
--
-- Copyright (C) 2017-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

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
