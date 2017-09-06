
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

DEFINE_BASECLASS('dbot_tf_machete')

SWEP.Base = 'dbot_tf_machete'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Sniper'
SWEP.PrintName = 'The Tribalmans Shiv'
SWEP.ViewModel = 'models/weapons/c_models/c_sniper_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_wood_machete/c_wood_machete.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false

SWEP.BulletDamage = 65 * 0.5

BLEED_DURATION = CreateConVar('tf_shiv_bleed', '6', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'The Tribalmans Shiv bleed duration')

if SERVER then
	function SWEP:OnHit(ent, tr, dmginfo)
		local bleed = ent:TF2Bleed(BLEED_DURATION:GetFloat())
		bleed:SetAttacker(self:GetOwner())
		bleed:SetInflictor(self)
		return BaseClass.OnHit(self, ent, tr, dmginfo)
	end
end
