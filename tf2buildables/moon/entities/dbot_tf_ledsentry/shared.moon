
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

DEFINE_BASECLASS('dbot_tf_sentry')
AddCSLuaFile()

ENT.Base = 'dbot_tf_sentry'
ENT.Type = 'nextbot'
ENT.PrintName = 'LED Sentry gun'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'

ENT.BuildModel1 = 'models/buildables/led_sentry/sentry1_heavy.mdl'
ENT.IdleModel1 = 'models/buildables/led_sentry/sentry1.mdl'
ENT.BuildModel2 = 'models/buildables/led_sentry/sentry2_heavy.mdl'
ENT.IdleModel2 = 'models/buildables/led_sentry/sentry2.mdl'
ENT.BuildModel3 = 'models/buildables/led_sentry/sentry3_heavy.mdl'
ENT.IdleModel3 = 'models/buildables/led_sentry/sentry3.mdl'

ENT.Gibs1LED = {
	'models/buildables/led_sentry/gibs/sentry1_gib1.mdl'
	'models/buildables/led_sentry/gibs/sentry1_gib2.mdl'
	'models/buildables/led_sentry/gibs/sentry1_gib3.mdl'
	'models/buildables/led_sentry/gibs/sentry1_gib4.mdl'
}

ENT.Gibs2LED = {
	'models/buildables/led_sentry/gibs/sentry2_gib1.mdl'
	'models/buildables/led_sentry/gibs/sentry2_gib2.mdl'
	'models/buildables/led_sentry/gibs/sentry2_gib3.mdl'
	'models/buildables/led_sentry/gibs/sentry2_gib4.mdl'
}

ENT.Gibs3LED = {
	'models/buildables/led_sentry/gibs/sentry2_gib1.mdl'
	'models/buildables/led_sentry/gibs/sentry2_gib2.mdl'
	'models/buildables/led_sentry/gibs/sentry2_gib3.mdl'
	'models/buildables/led_sentry/gibs/sentry2_gib4.mdl'
	'models/buildables/led_sentry/gibs/sentry3_gib1.mdl'
}

ENT.Gibs = (level = @GetLevel()) =>
	switch level
		when 1
			@Gibs1LED
		when 2
			@Gibs2LED
		when 3
			@Gibs3LED
