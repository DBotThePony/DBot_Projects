
-- Enhanced Visuals for GMod
-- Copyright (C) 2018 DBot

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local DVisuals = DVisuals
local DMG_BLAST = DMG_BLAST
local net = net

net.pool('DVisuals.Explosions')

hook.Add('EntityTakeDamage', 'DVisuals.Explosions', function(self, dmg)
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	if not self:IsPlayer() then return end
	if dmg:GetDamageType():band(DMG_BLAST) == 0 then return end
	if dmg:GetDamage() < 4 then return end

	net.Start('DVisuals.Explosions')
	net.WriteUInt(dmg:GetDamage():sqrt():ceil():clamp(3, 16), 4)
	net.Send(self)
end, -2)
