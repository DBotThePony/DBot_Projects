
--
-- Copyright (C) 2017-2018 DBot
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

SWEP.Base = 'dbot_tf_shotgun'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Pyro'
SWEP.PrintName = 'Reserve Shooter'
SWEP.ViewModel = 'models/weapons/c_models/c_pyro_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.FireSoundsScript = 'Weapon_Reserve_Shooter.Single'
SWEP.FireCritSoundsScript = 'Weapon_Reserve_Shooter.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Reserve_Shooter.Empty'

SWEP.DrawAnimation = 'draw'
SWEP.IdleAnimation = 'idle'
SWEP.AttackAnimation = 'fire'
SWEP.AttackAnimationCrit = 'fire'
SWEP.ReloadStart = 'reload_start'
SWEP.ReloadLoop = 'reload_loop'
SWEP.ReloadEnd = 'reload_end'

SWEP.PreOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
	if IsValid(hitEntity) and (hitEntity\IsNPC() or hitEntity\IsPlayer()) and not hitEntity\OnGround() and not @GetIncomingCrit()
		@SetSuppressEffects(false)
		@ThatWasMinicrit() if SERVER

SWEP.Primary = {
	'Ammo': 'Buckshot'
	'ClipSize': 4
	'DefaultClip': 32
	'Automatic': true
}
