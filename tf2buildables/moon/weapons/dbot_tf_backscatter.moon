
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

DEFINE_BASECLASS('dbot_tf_scattergun')

SWEP.Base = 'dbot_tf_scattergun'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Back Scatter'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/workshop/weapons/c_models/c_scatterdrum/c_scatterdrum.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false

SWEP.DefaultSpread = Vector(1, 1, 0) * 0.055

SWEP.PreOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
	@BaseClass.PreOnHit(@, hitEntity, tr, dmginfo)
	if hitEntity\IsValid() and hitEntity\GetPos()\Distance(@GetOwner()\GetPos()) < 500 and @AttackingAtSpine(hitEntity)
		@ThatWasMinicrit(hitEntity, dmginfo)

SWEP.FireSoundsScript = 'Weapon_Back_Scatter.Single'
SWEP.FireCritSoundsScript = 'Weapon_Back_Scatter.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Back_Scatter.Empty'

SWEP.Primary = {
	'Ammo': 'Buckshot'
	'ClipSize': 4
	'DefaultClip': 4
	'Automatic': true
}

