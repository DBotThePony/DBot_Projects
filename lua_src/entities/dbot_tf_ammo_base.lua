
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
ENT.PrintName = 'Ammo Pickup Base'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Model = 'models/items/ammopack_medium.mdl'

ENT.AmmoWeight = 0

function ENT:OnUse(ply)
	if self.AmmoWeight > 0 then
		local simulate = DTF2.GiveAmmo(ply, self.AmmoWeight)
		if simulate > 0 then
			ply:EmitSound('items/gunpickup2.wav')
		else
			return false
		end
	end

	return true
end

