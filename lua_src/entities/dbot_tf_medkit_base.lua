
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

ENT.Type = 'anim'
ENT.Base = 'dbot_pickup_base'
ENT.PrintName = 'Medkit Base'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.Model = 'models/items/medkit_medium.mdl'
ENT.Heal = .5

function ENT:OnUse(ply)
	local hp, mhp = ply:Health(), ply:GetMaxHealth()
	
	if hp >= mhp then return false end
	local new = math.Clamp(hp + mhp * self.Heal, 0, mhp)
	ply:SetHealth(new)
	hook.Run('PlayerPickupMedkit', ply, self, self.Heal, new - hp)
	
	ply:EmitSound('items/smallmedkit1.wav')
	
	return true
end

