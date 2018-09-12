
--
-- Copyright (C) 2017-2018 DBot

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


AddCSLuaFile()

ENT.Base = 'dbot_tf_sentry'
ENT.Type = 'nextbot'
ENT.PrintName = 'Artilery Sentry gun'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.ROCKET_CLASS = 'dbot_asentry_rocket'

ENT.BuildModel1 = 'models/buildables/artilery_sentry/sentry1_heavy.mdl'
ENT.IdleModel1 = 'models/buildables/artilery_sentry/sentry1.mdl'
ENT.BuildModel2 = 'models/buildables/artilery_sentry/sentry2_heavy.mdl'
ENT.IdleModel2 = 'models/buildables/artilery_sentry/sentry2.mdl'
ENT.BuildModel3 = 'models/buildables/artilery_sentry/sentry3_heavy.mdl'
ENT.IdleModel3 = 'models/buildables/artilery_sentry/sentry3.mdl'

ENT.Gibs1Artilery = {
	'models/buildables/artilery_sentry/gibs/sentry1_gib1.mdl'
	'models/buildables/artilery_sentry/gibs/sentry1_gib2.mdl'
	'models/buildables/artilery_sentry/gibs/sentry1_gib3.mdl'
	'models/buildables/artilery_sentry/gibs/sentry1_gib4.mdl'
}

ENT.Gibs2Artilery = {
	'models/buildables/artilery_sentry/gibs/sentry2_gib1.mdl'
	'models/buildables/artilery_sentry/gibs/sentry2_gib2.mdl'
	'models/buildables/artilery_sentry/gibs/sentry2_gib3.mdl'
	'models/buildables/artilery_sentry/gibs/sentry2_gib4.mdl'
}

ENT.Gibs3Artilery = {
	'models/buildables/artilery_sentry/gibs/sentry2_gib1.mdl'
	'models/buildables/artilery_sentry/gibs/sentry2_gib2.mdl'
	'models/buildables/artilery_sentry/gibs/sentry2_gib3.mdl'
	'models/buildables/artilery_sentry/gibs/sentry2_gib4.mdl'
	'models/buildables/gibs/sentry3_gib1.mdl'
}

ENT.Gibs = (level = @GetLevel()) =>
	switch level
		when 1
			@Gibs1Artilery
		when 2
			@Gibs2Artilery
		when 3
			@Gibs3Artilery
