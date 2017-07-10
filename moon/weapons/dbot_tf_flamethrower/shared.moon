
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

BaseClass = baseclass.Get('dbot_tf_clipbased')

SWEP.Base = 'dbot_tf_clipbased'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Pyro'
SWEP.PrintName = 'Flamethrower'
SWEP.ViewModel = 'models/weapons/c_models/c_pyro_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_flamethrower/c_flamethrower.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Slot = 4
SWEP.SingleCrit = false

SWEP.DrawAnimation = 'ft_draw'
SWEP.IdleAnimation = 'ft_idle'
SWEP.AttackAnimation = 'ft_fire'
SWEP.AttackAnimationCrit = 'ft_fire'
SWEP.AirBlastAnimationCrit = 'ft_alt_fire'

SWEP.Reloadable = false

SWEP.Initialize = =>
    BaseClass.Initialize(@)

SWEP.SetupDataTables = =>
    BaseClass.SetupDataTables(@)
    @NetworkVar('Bool', 16, 'IsAttacking')

SWEP.Primary = {
    'Ammo': 'ammo_tf_flame'
    'ClipSize': -1
    'DefaultClip': 200
    'Automatic': true
}

SWEP.Secondary = {
    'Ammo': 'ammo_tf_flame'
    'ClipSize': -1
    'DefaultClip': 0
    'Automatic': true
}

SWEP.FireTrigger = =>
SWEP.PrimaryAttack = =>
    status = BaseClass.PrimaryAttack(@)
    return status if status == false
    @incomingFire = false
    @SetIsAttacking(true)
    return true
