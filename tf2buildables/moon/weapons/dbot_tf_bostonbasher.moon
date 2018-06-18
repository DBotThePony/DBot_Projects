

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

DEFINE_BASECLASS('dbot_tf_bat')

SWEP.Base = 'dbot_tf_bat'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Boston Basher'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_boston_basher/c_boston_basher.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.MissSoundsScript = 'BostonBasher.Impact'
SWEP.MissCritSoundsScript = 'BostonBasher.ImpactCrit'
SWEP.HitSoundsScript = 'BostonBasher.HitWorld'
SWEP.HitSoundsFleshScript = 'BostonBasher.Impact'

if SERVER
	SWEP.OnMiss = =>
		@BaseClass.OnMiss(@)
		ent = @GetOwner()\TF2Bleed(5)
		ent\SetAttacker(@GetOwner())
		ent\SetInflictor(@)

	SWEP.OnHit = (hitEntity = NULL, ...) =>
		@BaseClass.OnHit(@, hitEntity, ...)
		if IsValid(hitEntity) and (hitEntity\IsNPC() or hitEntity\IsPlayer())
			ent = hitEntity\TF2Bleed(5)
			ent\SetAttacker(@GetOwner())
			ent\SetInflictor(@)