
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

ENT.Type = 'anim'

ENT.BuildModel1 = 'models/buildables/dispenser.mdl'
ENT.BuildModel2 = 'models/buildables/dispenser_lvl2.mdl'
ENT.BuildModel3 = 'models/buildables/dispenser_lvl3.mdl'

ENT.IdleModel1 = 'models/buildables/dispenser_light.mdl'
ENT.IdleModel2 = 'models/buildables/dispenser_lvl2_light.mdl'
ENT.IdleModel3 = 'models/buildables/dispenser_lvl3_light.mdl'

ENT.HealthLevel1 = 150
ENT.HealthLevel2 = 180
ENT.HealthLevel3 = 216

ENT.BuildTime = 2

ENT.BuildingMins = Vector(-16, -16, 0)
ENT.BuildingMaxs = Vector(16, 16, 48)

ENT.Author = 'DBot'
ENT.PrintName = 'TF2 Buildable base'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IDLE_ANIM = 'ref'
ENT.UPGRADE_TIME_2 = 1.16
ENT.UPGRADE_TIME_3 = 1.16

ENT.SetupDataTables = =>
    @NetworkVar('Float', 0, 'HP')
    @NetworkVar('Float', 1, 'MHP')
    @NetworkVar('Bool', 0, 'IsBuilding')
    @NetworkVar('Bool', 2, 'IsUpgrading')
    @NetworkVar('Bool', 1, 'BuildSpeedup')
    @NetworkVar('Int', 1, 'nwLevel')
    @NetworkVar('Entity', 0, 'Player')
