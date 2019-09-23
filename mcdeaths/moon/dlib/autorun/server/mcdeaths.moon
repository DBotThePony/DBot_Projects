
-- Copyright (C) 2019 DBotThePony

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

import type from _G

_G.MCDeaths = MCDeaths or {}

net.pool('mcdeaths_death')
net.pool('mcdeaths_npcdeath')

MCDeaths = MCDeaths
MCDeaths.DMG_ATTACK = DMG_CRUSH\bor(DMG_BULLET, DMG_SLASH, DMG_VEHICLE, DMG_BLAST, DMG_SHOCK, DMG_SONIC)
MCDeaths.DMG_ANY = 0xFFFFFFFF - DMG_DROWNRECOVER - DMG_REMOVENORAGDOLL - DMG_PREVENT_PHYSICS_FORCE - DMG_NEVERGIB - DMG_ALWAYSGIB

MCDeaths.ENABLED = CreateConVar('sv_mcdeaths', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable Minecraft Styled Death Messages')

-- damage entries can have at least one of types of each test in chain
MCDeaths.CHAIN_TEST_WEAK = 0
-- damage entries must have exact type in each test in chain
MCDeaths.CHAIN_TEST_EXACT = 1
-- damage entries before last - MCDeaths.CHAIN_TEST_WEAK, rest - MCDeaths.CHAIN_TEST_EXACT
MCDeaths.CHAIN_TEST_MAYBE = 2
-- damage entries before last - MCDeaths.CHAIN_TEST_EXACT, rest - MCDeaths.CHAIN_TEST_WEAK
MCDeaths.CHAIN_TEST_LAST = 3

MCDeaths.IsFigher = => IsValid(@) and (@IsNPC() or @IsPlayer() or type(@) == 'NextBot')

include 'mcdeaths/hooks.lua'
include 'mcdeaths/tracker.lua'
include 'mcdeaths/strategies.lua'

MUTE_DEFAULT_MESSAGES = CreateConVar('sv_mcdeaths_mute', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Mute default death messages (one which occur inside GM:PlayerDeath)')

emptyfn = () ->

loaded = () ->
	fn = GAMEMODE and GAMEMODE.PlayerDeath
	return if not fn
	fenv = getfenv(fn)

	if type(fenv) == 'table'
		if meta = getmetatable(fenv)
			if fn2 = meta.__index
				if info = debug.getinfo(fn2)
					if info.short_src\find('server/mcdeaths', 1, true)
						return

	setfenv(fn, setmetatable({}, {
		__index: (key) =>
			return emptyfn if MUTE_DEFAULT_MESSAGES\GetBool() and MCDeaths.DISPLAY_PLAYER_DEATHS\GetBool() and MCDeaths.ENABLED\GetBool() and (key == 'Msg' or key == 'MsgC' or key == 'MsgN' or key == 'MsgAll')
			return fenv[key]

		__newindex: (key, value) =>
			fenv[key] = value
	}))

if AreEntitiesAvailable()
	loaded()
else
	hook.Add 'Initialize', 'MCDeaths.Mute', loaded

return
