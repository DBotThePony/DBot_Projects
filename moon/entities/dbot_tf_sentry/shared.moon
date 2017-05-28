
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

ENT.BuildTime = 5

ENT.SENTRY_ANGLE_CHANGE_MULT = 50
ENT.SENTRY_SCAN_YAW_MULT = 30
ENT.SENTRY_SCAN_YAW_CONST = 30

ENT.SetupDataTables = =>
    @BaseClass.SetupDataTables(@)
    @NetworkVar('Int', 2, 'AimPitch')
    @NetworkVar('Int', 3, 'AimYaw')
