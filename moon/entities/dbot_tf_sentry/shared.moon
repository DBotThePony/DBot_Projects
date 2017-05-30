
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
ENT.PrintName = 'Sentry gun'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'

ENT.BuildModel1 = 'models/buildables/sentry1_heavy.mdl'
ENT.IdleModel1 = 'models/buildables/sentry1.mdl'
ENT.BuildModel2 = 'models/buildables/sentry2_heavy.mdl'
ENT.IdleModel2 = 'models/buildables/sentry2.mdl'
ENT.BuildModel3 = 'models/buildables/sentry3_heavy.mdl'
ENT.IdleModel3 = 'models/buildables/sentry3.mdl'

ENT.BuildTime = 10

ENT.SENTRY_ANGLE_CHANGE_MULT = 50
ENT.SENTRY_SCAN_YAW_MULT = 30
ENT.SENTRY_SCAN_YAW_CONST = 30

ENT.IDLE_ANIM = 'idle_off'

ENT.MAX_DISTANCE = 1024 ^ 2

ENT.MAX_AMMO_1 = 150
ENT.MAX_AMMO_2 = 250
ENT.MAX_AMMO_3 = 250
ENT.MAX_ROCKETS = 30
ENT.AMMO_RESTORE_ON_HIT = 40
ENT.ROCKETS_RESTORE_ON_HIT = 5

ENT.BULLET_DAMAGE = 12
ENT.BULLET_RELOAD_1 = 0.3
ENT.BULLET_RELOAD_2 = 0.1
ENT.BULLET_RELOAD_3 = 0.1

ENT.GetMaxAmmo = (level = @GetLevel()) =>
    switch level
        when 1
            @MAX_AMMO_1
        when 2
            @MAX_AMMO_2
        when 3
            @MAX_AMMO_3

ENT.SetupDataTables = =>
    @BaseClass.SetupDataTables(@)
    @NetworkVar('Int', 2, 'AimPitch')
    @NetworkVar('Int', 3, 'AimYaw')
    @NetworkVar('Int', 4, 'AmmoAmount')
    @NetworkVar('Int', 5, 'Rockets')

ENT.UpdateSequenceList = =>
    @BaseClass.UpdateSequenceList(@)
    @fireSequence = @LookupSequence('fire')
    @muzzle = @LookupAttachment('muzzle')
    @muzzle_l = @LookupAttachment('muzzle_l')
    @muzzle_r = @LookupAttachment('muzzle_r')

ENT.CustomRepair = (thersold = 200, simulate = CLIENT) =>
    return 0 if thersold == 0
    weight = 0
    rockets = 0
    ammo = 0
    ammo = math.Clamp(math.min(@GetMaxAmmo() - @GetAmmoAmount(), @AMMO_RESTORE_ON_HIT), 0, thersold - weight)
    rockets = math.Clamp(math.min(@MAX_ROCKETS - @GetRockets(), @ROCKETS_RESTORE_ON_HIT) * 2, 0, thersold - weight) if @GetLevel() == 3
    rockets -= 1 if math.floor(rockets / 2) ~= rockets / 2
    weight += ammo
    weight += rockets
    @SetAmmoAmount(@GetAmmoAmount() + ammo) if not simulate
    @SetRockets(@GetRockets() + rockets / 2) if not simulate
    return weight
