
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

AddCSLuaFile()

SWEP.Base = 'dbot_tf_fireaxe'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Pyro'
SWEP.PrintName = 'Third Degree'
SWEP.ViewModel = 'models/weapons/c_models/c_pyro_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_drg_thirddegree/c_drg_thirddegree.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.MissSoundsScript = 'Weapon_FireAxe.Miss'
SWEP.MissCritSoundsScript = 'Weapon_FireAxe.MissCrit'
SWEP.HitSoundsScript = 'Weapon_3rd_degree.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_3rd_degree.HitFlesh'
