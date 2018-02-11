
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

ENT.Type = 'anim'
ENT.PrintName = 'Solid Border'
ENT.Author = 'DBotThePony'
ENT.Base = 'func_border'

local SERVER = SERVER
local BaseClass = baseclass.Get('func_border')

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar('Bool', 6, 'DrawInner')

	if SERVER then
		self:SetCollisionMins(Vector(-50, -50, 0))
		self:SetCollisionMaxs(Vector(50, 50, 50))
		self:SetDrawInner(true)
	end

	self.DrawInner = self.GetDrawInner
end
