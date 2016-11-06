
--[[
Copyright (C) 2016 DBot

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

if not DarkRP then return end

local Var = DHUD2.GetVar
local HungerExists = false

local Register = {
	havelicense = {
		def = false,
		func = function(self, ply)
			return ply:getDarkRPVar('HasGunlicense')
		end,
	},
	
	iswanted = {
		def = false,
		func = function(self, ply)
			if not ply.isWanted then return false end
			return ply:isWanted() or false
		end,
	},
	
	money = {
		def = 0,
		func = function(self, ply)
			return ply:getDarkRPVar('money') or 0
		end,
	},
	
	salary = {
		def = 0,
		func = function(self, ply)
			return ply:getDarkRPVar('salary') or 0
		end,
	},
	
	job = {
		def = '',
		func = function(self, ply)
			return ply:getDarkRPVar('job') or '%darkrpjob%'
		end,
	},
	
	fmoney = {
		def = '',
		func = function(self, ply)
			return 'Money: ' .. DarkRP.formatMoney(Var('money'))
		end,
	},
	
	fsalary = {
		def = '',
		func = function(self, ply)
			return 'Salary: ' .. DarkRP.formatMoney(Var('salary'))
		end,
	},
	
	hunger = {
		def = 0,
		func = function(self, ply)
			local val = ply:getDarkRPVar('Energy')
			HungerExists = val and true or false
			return val or 0
		end,
	},
}

DHUD2.CreateColor('hungerbar', 'DarkRP Hunger Bar', 220, 172, 38, 255)

function DHUD2.DrawDarkRP()
	surface.SetFont('DHUD2.Default')
	local x, y = DHUD2.GetPosition('default')
	
	x = x + DHUD2.DEFAULT_WIDTH / 2 - 20
	y = y + 20
	
	local money = Var('fmoney')
	local salary = Var('fsalary')
	local hunger = Var('hunger')
	
	surface.SetTextColor(DHUD2.GetColor('playerinfo'))
	
	local w, h = surface.GetTextSize(money)
	surface.SetTextPos(x - w + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift())
	surface.DrawText(money)
	
	local w, h = surface.GetTextSize(salary)
	surface.SetTextPos(x - w + DHUD2.GetDamageShift(), y - h + DHUD2.GetDamageShift())
	surface.DrawText(salary)
	
	y = y + h
	x = x - 100
	
	if HungerExists then
		DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), 100, 5, DHUD2.GetColor('empty_bar'))
		DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), hunger, 5, DHUD2.GetColor('hungerbar'))
	end
	
	local haveLicense = Var('havelicense')
	local iswanted = Var('iswanted')
	
	x, y = DHUD2.GetPosition('default')
	
	local toDraw = {}
	
	if haveLicense then
		table.insert(toDraw, 'Have gun license')
	end
	
	if iswanted then
		table.insert(toDraw, 'Wanted')
	end
	
	surface.SetTextPos(x - DHUD2.DEFAULT_WIDTH / 2 + 20, y + 35)
	surface.DrawText(table.concat(toDraw, ', '))
end

for k, v in pairs(Register) do
	DHUD2.RegisterVar(k, v.def, v.func)
end

local Hide = {
	['DarkRP_LocalPlayerHUD'] = true,
	['DarkRP_Hungermod'] = true,
}

hook.Add('HUDShouldDraw', 'DHUD2.DarkRPHide', function(name)
	if Hide[name] then return false end
end)
