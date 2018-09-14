
-- Copyright (C) 2018 DBot

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

sound.Add({
	name = 'DParkour.Hang',
	channel = CHAN_BODY,
	level = SNDLVL_50dB,
	sound = table.construct2(function(i) return 'physics/body/body_medium_impact_soft' .. i .. '.wav' end, 7),
	volume = 1,
	pitch = {85, 110},
})

sound.Add({
	name = 'DParkour.HangOver',
	channel = CHAN_BODY,
	level = SNDLVL_50dB,
	sound = table.construct2(function(i) return 'physics/cardboard/cardboard_box_impact_soft' .. i .. '.wav' end, 7),
	volume = 1,
	pitch = {85, 110},
})

sound.Add({
	name = 'DParkour.WallImpactHard',
	channel = CHAN_BODY,
	level = SNDLVL_50dB,
	sound = table.construct2(function(i) return 'physics/cardboard/cardboard_box_impact_hard' .. i .. '.wav' end, 7),
	volume = 1,
	pitch = {85, 110},
})
