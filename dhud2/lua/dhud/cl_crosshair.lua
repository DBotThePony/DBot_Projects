
--Crossharirs!

--[[
Copyright (C) 2016-2018 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local ENABLE = CreateConVar('dhud_crosshairs', '1', FCVAR_ARCHIVE, 'Enable custom crosshairs')
DHUD2.AddConVar('dhud_crosshairs', 'Enable custom crosshairs', ENABLE)

DHUD2.Crasshairs = DHUD2.Crasshairs or {}
local Crasshairs = DHUD2.Crasshairs

Crasshairs.Funcs = {
	default = function(ply, hitpos, tr, x, y)
		surface.DrawLine(x, y - 15, x, y - 5)
		surface.DrawLine(x, y + 5, x, y + 15)

		surface.DrawLine(x - 15, y, x - 5, y)
		surface.DrawLine(x + 5, y, x + 15, y)
	end,

	weapon_crossbow = function(ply, hitpos, tr, x, y)
		surface.DrawLine(x, y - 15, x, y - 5)
		surface.DrawLine(x, y + 5, x, y + 15)

		surface.DrawLine(x - 15, y, x - 5, y)
		surface.DrawLine(x + 5, y, x + 15, y)

		surface.DrawLine(x - 1, y, x + 1, y) --Point
	end,

	weapon_physgun = function(ply, hitpos, tr, x, y)
		surface.DrawLine(x + 10, y - 10, x - 10, y - 10)
		surface.DrawLine(x + 10, y + 10, x - 10, y + 10)
		surface.DrawLine(x + 10, y + 10, x + 10, y - 10)
		surface.DrawLine(x - 10, y + 10, x - 10, y - 10)
	end,

	weapon_crowbar = function(ply, hitpos, tr, x, y)
		surface.DrawLine(x, y - 7, x, y + 7)
		surface.DrawLine(x - 15, y, x + 15, y)
	end,
}

Crasshairs.Funcs.weapon_physcannon = Crasshairs.Funcs.weapon_physgun
Crasshairs.Funcs.weapon_stunstick = Crasshairs.Funcs.weapon_crowbar
Crasshairs.Funcs.weapon_fists = Crasshairs.Funcs.weapon_crowbar
Crasshairs.Funcs.weapon_medkit = Crasshairs.Funcs.weapon_crowbar

local bypass = false

DHUD2.CreateColor('crosshair', 'Crosshair', 142, 220, 180, 255)

local function Draw()
	if not ENABLE:GetBool() then return end
	if not DHUD2.IsEnabled() then return end
	if not DHUD2.ServerConVar('crosshairs') then return end

	local ply = DHUD2.SelectPlayer()
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end
	if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end

	if wep.HUDShouldDraw and wep:HUDShouldDraw('CHudCrosshair') == false then return end
	if wep.DrawCrosshair == false then return end

	local tr = ply:GetEyeTrace()
	local d = tr.HitPos:ToScreen()
	local x, y = math.ceil(d.x / 1.1) * 1.1, math.ceil(d.y / 1.1) * 1.1 --Prevent shaking
	
	if wep.DoDrawCrosshair then
		local status = wep:DoDrawCrosshair(x, y)
		if status == true then return end
	end

	bypass = true
	local can = hook.Run('HUDShouldDraw', 'CHudCrosshair')
	bypass = false

	if can == false then return end

	local color = DHUD2.GetColor('crosshair')

	if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
		color = team.GetColor(tr.Entity:Team())
	end

	surface.SetDrawColor(color)

	if not Crasshairs.Funcs[wep:GetClass()] then
		Crasshairs.Funcs.default(ply, tr.HitPos, tr, x, y)
	else
		Crasshairs.Funcs[wep:GetClass()](ply, tr.HitPos, tr, x, y)
	end
end

DHUD2.DrawHook('crosshairs', Draw)

hook.Add('HUDShouldDraw', 'DHUD2.Crosshair', function(s)
	if s ~= 'CHudCrosshair' then return end
	if not DHUD2.IsEnabled() then return end
	if not bypass and ENABLE:GetBool() then return false end
end, 4)
