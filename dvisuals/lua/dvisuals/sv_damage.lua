
-- Enhanced Visuals for GMod
-- Copyright (C) 2018-2019 DBot

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
local DMG_HEAT = DMG_BURN -- loal
local net = net
local CurTimeL = CurTimeL

net.pool('DVisuals.Explosions')
net.pool('DVisuals.Fires')
net.pool('DVisuals.Frost')

net.pool('DVisuals.Slash')
net.pool('DVisuals.SlashOther')
net.pool('DVisuals.Generic')
net.pool('DVisuals.GenericOther')

net.pool('DVisuals.Fall')

hook.Add('EntityTakeDamage', 'DVisuals.Explosions', function(self, dmg)
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	if not self:IsPlayer() then return end
	if dmg:GetDamageType():band(DMG_BLAST) == 0 then return end
	if dmg:GetDamage() < 4 then return end

	local score = dmg:GetDamage():sqrt():ceil():clamp(3, 16)
	net.Start('DVisuals.Explosions', true)
	net.WriteUInt(score, 4)
	net.Send(self)
end, -2)

hook.Add('EntityTakeDamage', 'DVisuals.Fires', function(self, dmg)
	if not DVisuals.ENABLE_FIRE() then return end
	if not self:IsPlayer() then return end
	if dmg:GetDamageType():band(DMG_HEAT) == 0 and dmg:GetDamageType():band(DMG_SLOWBURN) == 0 and dmg:GetDamageType():band(DMG_PLASMA) == 0 then return end
	if dmg:GetDamage() < 1 then return end
	local attacker = dmg:GetAttacker()

	if attacker:IsValid() and attacker:GetClass() == 'entityflame' then return end

	net.Start('DVisuals.Fires', true)
	net.WriteUInt((dmg:GetDamage() / 3):ceil():min(16), 4)
	net.Send(self)
end, -2)

local DMG_SONIC = DMG_SONIC
local DMG_PARALYZE = DMG_PARALYZE

hook.Add('EntityTakeDamage', 'DVisuals.FeelsFrozen', function(self, dmg)
	if not DVisuals.ENABLE_FROZEN() then return end
	if not self:IsPlayer() then return end
	if dmg:GetDamageType():band(DMG_SONIC) == 0 and dmg:GetDamageType():band(DMG_PARALYZE) == 0 then return end
	if dmg:GetDamage() < 1 then return end

	net.Start('DVisuals.Frost', true)
	net.WriteUInt((dmg:GetDamage() / 3):ceil():min(255), 8)
	net.Send(self)
end, -2)

local DMG_SLASH = DMG_SLASH
local DMG_BULLET = DMG_BULLET
local DMG_FALL = DMG_FALL
local NEXT_SPEED = 0
local NEXT_PLAYER = NULL

hook.Add('GetFallDamage', 'DVisuals.BloodHandler', function(self, speed)
	if not DVisuals.ENABLE_FALL() then return end
	NEXT_SPEED = speed
	NEXT_PLAYER = self
end, -10)

hook.AddPostModifier('GetFallDamage', 'DVisuals.BloodHandler', function(damage)
	if not DVisuals.ENABLE_FALL() then return damage end

	if damage > 0 and NEXT_PLAYER:IsValid() then
		net.Start('DVisuals.Fall', true)
		net.WriteUInt(NEXT_SPEED, 16)
		net.Send(NEXT_PLAYER)
		NEXT_PLAYER = NULL
		NEXT_SPEED = 0
	end

	return damage
end)

local player = player

hook.Add('EntityTakeDamage', 'DVisuals.BloodHandler', function(self, dmg)
	if not DVisuals.ENABLE_BLOOD() then return end

	if self:IsPlayer() then
		local bloodColor = self:GetBloodColor():max(0)

		if dmg:GetDamageType():band(DMG_SLASH) ~= 0 then
			local attacker = dmg:GetAttacker()

			if attacker:IsValid() and attacker:GetPos():Distance(self:GetPos()) < 256 then
				local diff = (attacker:GetPos() - self:EyePos()):Angle()
				local yaw = self:EyeAngles().yaw:angleDifference(diff.yaw)

				if yaw < 90 and yaw > -90 then
					net.Start('DVisuals.Slash', true)
					net.WriteUInt(dmg:GetDamage():ceil():min(255), 8)
					net.WriteInt(yaw:floor(), 8)
					net.WriteUInt(bloodColor, 4)
					net.Send(self)
				else
					net.Start('DVisuals.Generic', true)
					net.WriteUInt(dmg:GetDamage():ceil():min(255), 8)
					net.WriteUInt(bloodColor, 4)
					net.Send(self)
				end
			else
				net.Start('DVisuals.Generic', true)
				net.WriteUInt(dmg:GetDamage():ceil():min(255), 8)
				net.WriteUInt(bloodColor, 4)
				net.Send(self)
			end
		end

		if dmg:GetDamageType():band(DMG_BULLET) ~= 0 then
			net.Start('DVisuals.Generic', true)
			net.WriteUInt((dmg:GetDamage() / 3):ceil():min(255), 8)
			net.WriteUInt(bloodColor, 4)
			net.Send(self)
		end
	end

	local typ = type(self)

	if typ == 'NPC' or typ == 'Player' or typ == 'NextBot' then
		local bloodColor = self:GetBloodColor()

		if bloodColor ~= BLOOD_COLOR_MECH and bloodColor ~= DONT_BLEED then
			local lpos = self:GetPos()

			for i, ply in ipairs(player.GetAll()) do
				local dist = ply:EyePos():Distance(lpos)

				if ply:Alive() and ply ~= self then
					if dist < 192 then
						local diff = (self:GetPos() - ply:EyePos()):Angle()
						local yaw = ply:EyeAngles().yaw:angleDifference(diff.yaw)

						if yaw < 90 and yaw > -90 then
							net.Start('DVisuals.SlashOther', true)
							net.WriteUInt(dmg:GetDamage():ceil():min(255, self:GetMaxHealth()), 8)
							net.WriteInt(yaw:floor(), 8)
							net.WriteUInt(bloodColor, 4)
							net.Send(ply)
						else
							net.Start('DVisuals.GenericOther', true)
							net.WriteUInt(dmg:GetDamage():ceil():min(255, self:GetMaxHealth()), 8)
							net.WriteUInt(bloodColor, 4)
							net.Send(ply)
						end
					elseif dist < 256 then
						net.Start('DVisuals.GenericOther', true)
						net.WriteUInt(dmg:GetDamage():ceil():min(255, self:GetMaxHealth()), 8)
						net.WriteUInt(bloodColor, 4)
						net.Send(ply)
					end
				end
			end
		end
	end
end, -2)
