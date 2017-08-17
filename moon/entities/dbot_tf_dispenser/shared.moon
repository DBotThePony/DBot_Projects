
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

ENT.MAX_DISTANCE = 128 ^ 2

ENT.RESSUPLY_MULTIPLIER_1 = 1
ENT.RESSUPLY_MULTIPLIER_2 = 2
ENT.RESSUPLY_MULTIPLIER_3 = 3

ENT.MAS_RESSUPLY_1 = 300
ENT.MAS_RESSUPLY_2 = 400
ENT.MAS_RESSUPLY_3 = 500

ENT.AMMO_RESSUPLY_MAX_1 = 40
ENT.AMMO_RESSUPLY_MAX_2 = 50
ENT.AMMO_RESSUPLY_MAX_3 = 60

ENT.CHARGE_TIME_1 = 5
ENT.CHARGE_TIME_2 = 5
ENT.CHARGE_TIME_3 = 5

ENT.CHARGE_AMOUNT_1 = 40
ENT.CHARGE_AMOUNT_2 = 50
ENT.CHARGE_AMOUNT_3 = 60

ENT.AMMO_AMOUNT_1 = 40
ENT.AMMO_AMOUNT_2 = 50
ENT.AMMO_AMOUNT_3 = 60

ENT.Gibs = {
    'models/buildables/gibs/dispenser_gib1.mdl'
    'models/buildables/gibs/dispenser_gib2.mdl'
    'models/buildables/gibs/dispenser_gib3.mdl'
    'models/buildables/gibs/dispenser_gib4.mdl'
    'models/buildables/gibs/dispenser_gib5.mdl'
}

ENT.ExplosionSound = 'DTF2_Building_Dispenser.Explode'

ENT.GetRessuplyMultiplier = (level = @GetLevel()) =>
    switch level
        when 1
            @RESSUPLY_MULTIPLIER_1
        when 2
            @RESSUPLY_MULTIPLIER_2
        when 3
            @RESSUPLY_MULTIPLIER_3

ENT.GetMaxRessuply = (level = @GetLevel()) =>
    switch level
        when 1
            @MAS_RESSUPLY_1
        when 2
            @MAS_RESSUPLY_2
        when 3
            @MAS_RESSUPLY_3

ENT.GetAmmoRessuply = (level = @GetLevel()) =>
    switch level
        when 1
            @AMMO_RESSUPLY_MAX_1
        when 2
            @AMMO_RESSUPLY_MAX_2
        when 3
            @AMMO_RESSUPLY_MAX_3

ENT.GetChargeTime = (level = @GetLevel()) =>
    switch level
        when 1
            @CHARGE_TIME_1
        when 2
            @CHARGE_TIME_2
        when 3
            @CHARGE_TIME_3

ENT.GetChargeAmount = (level = @GetLevel()) =>
    switch level
        when 1
            @CHARGE_AMOUNT_1
        when 2
            @CHARGE_AMOUNT_2
        when 3
            @CHARGE_AMOUNT_3

ENT.GetAmmoToAmount = (level = @GetLevel()) =>
    switch level
        when 1
            @AMMO_AMOUNT_1
        when 2
            @AMMO_AMOUNT_2
        when 3
            @AMMO_AMOUNT_3

ENT.GetAvaliableForAmmo = (level = @GetLevel()) => math.Clamp(@GetAmmoRessuply(), 0, math.min(@GetRessuplyAmount(), @GetAmmoToAmount(level)))
ENT.GetAvaliablePercent = (level = @GetLevel()) => @GetRessuplyAmount() / @GetMaxRessuply()

ENT.SetupDataTables = =>
    @BaseClass.SetupDataTables(@)
    @NetworkVar('Int', 2, 'RessuplyAmount')

