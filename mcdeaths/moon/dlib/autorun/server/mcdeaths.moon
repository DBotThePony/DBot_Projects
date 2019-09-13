
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

MCDeaths = MCDeaths
MCDeaths.DMG_ATTACK = DMG_CRUSH\bor(DMG_BULLET, DMG_SLASH, DMG_VEHICLE, DMG_BLAST, DMG_SHOCK, DMG_SONIC)
MCDeaths.DMG_ANY = 0xFFFFFFFF - DMG_DROWNRECOVER - DMG_REMOVENORAGDOLL - DMG_PREVENT_PHYSICS_FORCE - DMG_NEVERGIB - DMG_ALWAYSGIB

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

return
