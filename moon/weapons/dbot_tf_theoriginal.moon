
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

BaseClass = baseclass.Get('dbot_tf_rocket_launcher')

SWEP.Base = 'dbot_tf_rocket_launcher'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Soldier'
SWEP.PrintName = 'The Original'
SWEP.ViewModel = 'models/weapons/c_models/c_soldier_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.FireOffset = Vector(0, 0, -12)

SWEP.ProjectileClass = 'dbot_tf_quake_rocket'

SWEP.FireSoundsScript = 'Weapon_QuakeRPG.Single'
SWEP.FireCritSoundsScript = 'Weapon_QuakeRPG.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_QuakeRPG.ClipEmpty'

SWEP.DrawAnimation = 'bet_draw'
SWEP.IdleAnimation = 'bet_idle'
SWEP.AttackAnimation = 'bet_fire'
SWEP.AttackAnimationCrit = 'bet_fire'
SWEP.ReloadStart = 'bet_reload_start'
SWEP.ReloadLoop = 'bet_reload_loop'
SWEP.ReloadEnd = 'bet_reload_finish'
