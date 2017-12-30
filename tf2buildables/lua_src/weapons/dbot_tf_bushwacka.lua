
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

DEFINE_BASECLASS('dbot_tf_machete')

SWEP.Base = 'dbot_tf_machete'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Sniper'
SWEP.PrintName = 'The Bushwacka'
SWEP.ViewModel = 'models/weapons/c_models/c_sniper_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_croc_knife/c_croc_knife.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false

function SWEP:OnHit(ent, tr, dmginfo)
	if self.incomingMiniCrit then
		self:ThatWasCrit()
	end

	return BaseClass.OnHit(self, ent, tr, dmginfo)
end

if SERVER then
	hook.Add('EntityTakeDamage', 'DTF2.Bushwacka', function(self, dmg)
		if self.GetActiveWeapon and self:GetActiveWeapon():IsValid() and self:GetActiveWeapon():GetClass() == 'dbot_tf_bushwacka' then
			dmg:ScaleDamage(1.2)
		end
	end)
end
