
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

SWEP.Base = 'dbot_tf_rocket_launcher'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Soldier'
SWEP.PrintName = 'Liberty Launcher'
SWEP.ViewModel = 'models/weapons/c_models/c_soldier_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ProjectileClass = 'dbot_tf_llauncher_rocket'

SWEP.FireSoundsScript = 'Weapon_Liberty_Launcher.Single'
SWEP.FireCritSoundsScript = 'Weapon_Liberty_Launcher.SingleCrit'

SWEP.Primary = {
	['Ammo'] = 'RPG_Round',
	['ClipSize'] = 5,
	['DefaultClip'] = 20,
	['Automatic'] = true
}
