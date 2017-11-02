
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

AddCSLuaFile()

ENT.PrintName = 'Explosive Bullet'
ENT.Author = 'DBot'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Type = 'anim'
ENT.IS_BULLET = true
ENT.Base = 'dbot_physbullet'

DEFINE_BASECLASS('dbot_physbullet')

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetSkin(4)
	self.m_explodeRadius = self.m_explodeRadius or 70
end

function ENT:CanRicochet()
	return false
end

function ENT:CanPenetrate()
	return false
end

AccessorFunc(ENT, 'm_explodeRadius', 'ExplosionRadius')

function ENT:OnSurfaceHit(tr, guessPos)
	local dmginfo = self:DamageInfo()
	dmginfo:SetDamageType(DMG_BLAST)
	dmginfo:ScaleDamage(0.8)
	util.BlastDamageInfo(dmginfo, guessPos, self:GetExplosionRadius())
end
