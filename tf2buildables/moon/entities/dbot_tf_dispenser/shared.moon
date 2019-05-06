
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


DEFINE_BASECLASS 'dbot_tf_build_base'
AddCSLuaFile()

ENT.Base = 'dbot_tf_build_base'
ENT.Type = 'nextbot'
ENT.PrintName = 'Dispenser'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'

ENT.HEAL_SPEED_MULT = 10

ENT.BuildModel1 = 'models/buildables/dispenser.mdl'
ENT.BuildModel2 = 'models/buildables/dispenser_lvl2.mdl'
ENT.BuildModel3 = 'models/buildables/dispenser_lvl3.mdl'

ENT.IdleModel1 = 'models/buildables/dispenser_light.mdl'
ENT.IdleModel2 = 'models/buildables/dispenser_lvl2_light.mdl'
ENT.IdleModel3 = 'models/buildables/dispenser_lvl3_light.mdl'

ENT.BuildingMins = Vector(-18, -16, 0)
ENT.BuildingMaxs = Vector(18, 16, 64)

ENT.BuildTime = 20
ENT.IDLE_ANIM = 'ref'

ENT.MAX_DISTANCE = CreateConVar('tf_dbg_disp_range', '128', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser range')

ENT.RESSUPLY_MULTIPLIER_1 = CreateConVar('tf_dbg_disp_mult1', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Ressuply speed multiplier on lvl 1')
ENT.RESSUPLY_MULTIPLIER_2 = CreateConVar('tf_dbg_disp_mult2', '2', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Ressuply speed multiplier on lvl 2')
ENT.RESSUPLY_MULTIPLIER_3 = CreateConVar('tf_dbg_disp_mult3', '3', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Ressuply speed multiplier on lvl 3')

ENT.MAS_RESSUPLY_1 = CreateConVar('tf_disp_ammo1', '400', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Maximal amount of lvl 1 dispenser ammo')
ENT.MAS_RESSUPLY_2 = CreateConVar('tf_disp_ammo2', '400', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Maximal amount of lvl 2 dispenser ammo')
ENT.MAS_RESSUPLY_3 = CreateConVar('tf_disp_ammo3', '400', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Maximal amount of lvl 3 dispenser ammo')

ENT.AMMO_RESSUPLY_MAX_1 = CreateConVar('tf_disp_resupply1', '40', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal resupply on lvl 1')
ENT.AMMO_RESSUPLY_MAX_2 = CreateConVar('tf_disp_resupply2', '50', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal resupply on lvl 2')
ENT.AMMO_RESSUPLY_MAX_3 = CreateConVar('tf_disp_resupply3', '60', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal resupply on lvl 3')

ENT.AMMO_AMOUNT_1 = CreateConVar('tf_disp_amount1', '40', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser ammo amount on lvl 1')
ENT.AMMO_AMOUNT_2 = CreateConVar('tf_disp_amount2', '50', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser ammo amount on lvl 2')
ENT.AMMO_AMOUNT_3 = CreateConVar('tf_disp_amount3', '60', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser ammo amount on lvl 3')

ENT.CHARGE_AMOUNT_1 = CreateConVar('tf_disp_charge1', '40', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal charge on lvl 1')
ENT.CHARGE_AMOUNT_2 = CreateConVar('tf_disp_charge2', '50', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal charge on lvl 2')
ENT.CHARGE_AMOUNT_3 = CreateConVar('tf_disp_charge3', '60', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal charge on lvl 3')

ENT.CHARGE_TIME_1 = CreateConVar('tf_dbg_disp_charge1', '5', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal charge timer on lvl 1')
ENT.CHARGE_TIME_2 = CreateConVar('tf_dbg_disp_charge2', '5', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal charge timer on lvl 2')
ENT.CHARGE_TIME_3 = CreateConVar('tf_dbg_disp_charge3', '5', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Dispenser metal charge timer on lvl 3')

ENT.Gibs = {
	'models/buildables/gibs/dispenser_gib1.mdl'
	'models/buildables/gibs/dispenser_gib2.mdl'
	'models/buildables/gibs/dispenser_gib3.mdl'
	'models/buildables/gibs/dispenser_gib4.mdl'
	'models/buildables/gibs/dispenser_gib5.mdl'
}

ENT.GibsValue = CreateConVar('tf_dispenser_gibs', '15', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Gibs value for dispenser')

ENT.ExplosionSound = 'DTF2_Building_Dispenser.Explode'

ENT.GetRessuplyMultiplier = (level = @GetLevel()) =>
	switch level
		when 1
			DTF2.GrabInt(@RESSUPLY_MULTIPLIER_1)
		when 2
			DTF2.GrabInt(@RESSUPLY_MULTIPLIER_2)
		when 3
			DTF2.GrabInt(@RESSUPLY_MULTIPLIER_3)

ENT.GetMaxRessuply = (level = @GetLevel()) =>
	switch level
		when 1
			DTF2.GrabInt(@MAS_RESSUPLY_1)
		when 2
			DTF2.GrabInt(@MAS_RESSUPLY_2)
		when 3
			DTF2.GrabInt(@MAS_RESSUPLY_3)

ENT.GetAmmoRessuply = (level = @GetLevel()) =>
	switch level
		when 1
			DTF2.GrabInt(@AMMO_RESSUPLY_MAX_1)
		when 2
			DTF2.GrabInt(@AMMO_RESSUPLY_MAX_2)
		when 3
			DTF2.GrabInt(@AMMO_RESSUPLY_MAX_3)

ENT.GetChargeTime = (level = @GetLevel()) =>
	switch level
		when 1
			DTF2.GrabInt(@CHARGE_TIME_1)
		when 2
			DTF2.GrabInt(@CHARGE_TIME_2)
		when 3
			DTF2.GrabInt(@CHARGE_TIME_3)

ENT.GetChargeAmount = (level = @GetLevel()) =>
	switch level
		when 1
			DTF2.GrabInt(@CHARGE_AMOUNT_1)
		when 2
			DTF2.GrabInt(@CHARGE_AMOUNT_2)
		when 3
			DTF2.GrabInt(@CHARGE_AMOUNT_3)

ENT.GetAmmoToAmount = (level = @GetLevel()) =>
	switch level
		when 1
			DTF2.GrabInt(@AMMO_AMOUNT_1)
		when 2
			DTF2.GrabInt(@AMMO_AMOUNT_2)
		when 3
			DTF2.GrabInt(@AMMO_AMOUNT_3)

ENT.GetAvaliableForAmmo = (level = @GetLevel()) => math.Clamp(@GetAmmoRessuply(), 0, math.min(@GetRessuplyAmount(), @GetAmmoToAmount(level)))
ENT.GetAvaliablePercent = (level = @GetLevel()) => @GetRessuplyAmount() / @GetMaxRessuply()

ENT.SetupDataTables = =>
	@BaseClass.SetupDataTables(@)
	@NetworkVar('Int', 2, 'RessuplyAmount')

