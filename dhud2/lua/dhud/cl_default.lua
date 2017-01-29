
--Default module

--[[
Copyright (C) 2016-2017 DBot

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

local Default = {}
DHUD2.Default = Default

local Var = DHUD2.GetVar
local SVar = DHUD2.SetVar
local Col = DHUD2.GetColor
local SimpleUpdate = DHUD2.SimpleUpdate

local function Percent(var1, var2)
	return function()
		if var2 == 0 then return 1 end
		local div = Var(var1) / Var(var2)
		if div ~= div then return 1 end --nan
		return math.Clamp(div, 0, 1)
	end
end	

SimpleUpdate('hp', 0, 'Health')
SimpleUpdate('mhp', 1, 'GetMaxHealth')
SimpleUpdate('armor', 0, 'Armor')
SimpleUpdate('lplayername', nil, 'Nick')
SimpleUpdate('lplayerteam', 0, 'Team')

DHUD2.CreateColor('hpbar', 'Health Bar', 230, 70, 70, 255)
DHUD2.CreateColor('hpbarlost', 'Health Bar (On lost)', 0, 0, 0, 255)
DHUD2.CreateColor('hptext', 'Health Counter', 255, 200, 200, 255)
DHUD2.CreateColor('armortext', 'Armor Counter', 185, 235, 255, 255)
DHUD2.CreateColor('armorbar', 'Armor Bar', 64, 130, 230, 255)
DHUD2.CreateColor('ammotext', 'Ammo text', 255, 255, 255, 255)
DHUD2.CreateColor('entitytext', 'Entity text', 255, 255, 255, 255)
DHUD2.CreateColor('playerinfo', 'Player Infos', 255, 255, 255, 255)

DHUD2.CreateColor('line1', 'Background line 1', 200, 200, 200, 25)
DHUD2.CreateColor('line2', 'Background line 2', 170, 170, 170, 25)

DHUD2.RegisterVar('hppercent', 0, Percent('hp', 'mhp'))
DHUD2.RegisterVar('maxarmor', 100)
DHUD2.RegisterVar('armorpercent', 0, Percent('armor', 'maxarmor'))

DHUD2.CreateWarning('hp', 'hp', 'mhp', 'Health', 0.4, 0.2)
DHUD2.CreateWarning('armor', 'armor', 'maxarmor', 'Armor level', 0.4, 0.2)

DHUD2.RegisterVar('lplayerteamname', nil, function(self, ply)
	local name = team.GetName(Var 'lplayerteam')
	local job = Var('job')
	
	if job and job ~= name then
		name = name .. ' (' .. job .. ')'
	end
	
	return name
end)

DHUD2.RegisterVar('lteamcolor', Color(255, 255, 255), function(self, ply)
	return team.GetColor(Var 'lplayerteam')
end)

DHUD2.RegisterVar('clip1', 0)
DHUD2.RegisterVar('clip2', 0)
DHUD2.RegisterVar('totalammo', 0)
DHUD2.RegisterVar('maxclip1', 0)
DHUD2.RegisterVar('maxclip2', 0)
DHUD2.RegisterVar('totalammo1', 0)
DHUD2.RegisterVar('totalammo2', 0)
DHUD2.RegisterVar('drawammo', false)
DHUD2.RegisterVar('weaponname')

local EntityExcludes = {
	prop_ragdoll = true,
	prop_physics = true,
}

DHUD2.EntityVar('entityname', false, function(self, ply, ent, isValid, isPlayer, dist)
	if ply:InVehicle() then return false end
	if not isValid then return false end
	if isPlayer then return false end
	if ent:IsNPC() then return false end
	if dist > 300 then return false end
	
	local class = ent:GetClass()
	if EntityExcludes[class] then return false end
	if ent.PrintName == '' then return false end
	
	return ent.PrintName or class
end)

DHUD2.RegisterVar('entityhealth', 0)
DHUD2.RegisterVar('entityhealthmax', 1)
DHUD2.RegisterVar('entityhealthpercent', 0, Percent('entityhealth', 'entityhealthmax'))

DHUD2.EntityVar('drawentityhealth', false, function(self, ply, ent, isValid, isPlayer, dist)
	if not isValid then return false end
	if isPlayer then return false end
	if ent:IsNPC() then return false end
	if dist > 300 then return false end
	
	local hp, mhp = ent:Health(), ent:GetMaxHealth()
	
	if mhp == 0 or hp == 0 then return false end
	
	SVar('entityhealth', hp)
	SVar('entityhealthmax', mhp)
	
	return true
end)

local DEFAULT_WIDTH = 500
local DEFAULT_HEIGHT = 100

DHUD2.DEFAULT_WIDTH = DEFAULT_WIDTH
DHUD2.DEFAULT_HEIGHT = DEFAULT_HEIGHT

DHUD2.DefinePosition('default', ScrW() / 2, ScrH() - DEFAULT_HEIGHT - 10)
DHUD2.DefinePosition('entitydisplay', ScrW() / 2, ScrH() / 2 + 40)
DHUD2.DefinePosition('npcbardisplay', ScrW() / 2, ScrH() / 2 + 40)
DHUD2.DefinePosition('entityhp', ScrW() / 2, ScrH() / 2 + 60)

Default.HPBAR_WIDTH = DEFAULT_WIDTH - 40
Default.HPBAR_HEIGHT = 20
Default.ARMORBAR_HEIGHT = 10

local ReallyBig = 2 ^ 30

function Default.DrawBars(x, y, RX, RY)
	local EBar = Col 'empty_bar'
	local HColor = Col 'hpbar'
	local HLColor = Col 'hpbarlost'
	local AColor = Col 'armorbar'
	
	y = y + DEFAULT_HEIGHT - 40
	x = x + 20
	
	DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Default.HPBAR_WIDTH, Default.HPBAR_HEIGHT, EBar)
	
	x = x + Default.HPBAR_WIDTH / 2
	
	DHUD2.SoftSkyrimBar(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Default.HPBAR_WIDTH * Var 'hppercent', Default.HPBAR_HEIGHT, HLColor, 'hplost', .05)
	DHUD2.SoftSkyrimBar(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Default.HPBAR_WIDTH * Var 'hppercent', Default.HPBAR_HEIGHT, HColor, 'hp', .2)
	DHUD2.SoftSkyrimBar(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift() + 10, Default.HPBAR_WIDTH * Var 'armorpercent', Default.ARMORBAR_HEIGHT, AColor, 'armor')
	
	local hp = Var 'hp'
	if hp > ReallyBig then hp = '> 2^30' end --Heh
	
	DHUD2.SimpleText(hp, nil, x + Default.HPBAR_WIDTH / 2 - surface.GetTextSize(hp) + DHUD2.GetDamageShift(), y - 20 + DHUD2.GetDamageShift(), Col 'hptext')
	
	if Var 'armor' > 0 then
		DHUD2.SimpleText(Var 'armor', nil, x - Default.HPBAR_WIDTH / 2 + DHUD2.GetDamageShift(), y + Default.HPBAR_HEIGHT + 2 + DHUD2.GetDamageShift(), Col 'armortext')
	end
end

function Default.DrawAmmo(x, y, RX, RY)
	y = y + 20
	x = x + DEFAULT_WIDTH - 20
	
	local AmmoString2 = ''
	
	local clip2 = Var 'clip2'
	local mclip2 = Var 'maxclip2'
	local totalammo2 = Var 'totalammo2'
	
	if clip2 ~= -1 or mclip2 ~= -1 then
		AmmoString2 = string.format('%s/%s (%s)', Var 'clip2', Var 'maxclip2', Var 'totalammo2')
	end
	
	if totalammo2 ~= -1 then
		AmmoString2 = AmmoString2 .. ' (' .. totalammo2 .. ')'
	end
	
	local DrawText = string.format('%s/%s (%s) | %s', Var 'clip1', Var 'maxclip1', Var 'totalammo1', AmmoString2)
	
	x = x - surface.GetTextSize(DrawText)
	
	DHUD2.SimpleText(DrawText, nil, x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Col 'ammotext')
end

function Default.DrawWeaponName(x, y)
	DHUD2.SimpleText(Var 'weaponname', nil, x + 20 + DHUD2.GetDamageShift(), y + 20 + DHUD2.GetDamageShift(), Col 'ammotext')
end

function Default.PlayerInfo(x, y)
	y = y + 5
	x = x + 20
	
	local name = Var 'lplayername'
	
	DHUD2.SimpleText(name, nil, x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Col 'playerinfo')
	x = x + surface.GetTextSize(name) + 5
	
	local tm = Var 'lplayerteamname'
	
	if tm ~= 'Unassigned' then
		DHUD2.SimpleText(tm, nil, x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Var 'lteamcolor')
		x = x + surface.GetTextSize(tm) + 5
	end
end

function Default.EntityDisplay()
	local x, y = DHUD2.GetPosition('entitydisplay')
	local t = Var 'entityname'
	local w, h = surface.GetTextSize(t)
	
	DHUD2.DrawBox(x - 3 - w / 2 + DHUD2.GetDamageShift(), y - 2 + DHUD2.GetDamageShift(), w + 6, h + 4, Col 'bg')
	DHUD2.SimpleText(t, nil, x - w / 2 + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Col 'entitytext')
end

DHUD2.RegisterVar('drawnhpbar', false)
DHUD2.RegisterVar('npchp', 0)
DHUD2.RegisterVar('npcmhp', 1)
DHUD2.RegisterVar('npcname')
DHUD2.RegisterVar('npcperc', 0, Percent('npchp', 'npcmhp'))

DHUD2.CreateColor('npctext', 'NPC name', 255, 255, 255, 255)
DHUD2.CreateColor('npchpbar', 'NPC HP bar', 0, 175, 0, 255)
DHUD2.CreateColor('npchpnumbs', 'NPC HP bar', 255, 255, 255, 255)

Default.NPC_HPBAR_WIDTH = 300

function Default.NPCBars()
	local x, y = DHUD2.GetPosition('npcbardisplay')
	local rx = x
	local name, hp, mhp, percent = Var 'npcname', Var 'npchp', Var 'npcmhp', Var 'npcperc'
	local w, h = surface.GetTextSize(name)
	x = x - 5 - (w + 10 + Default.NPC_HPBAR_WIDTH) / 2
	
	DHUD2.DrawBox(x, y - 2, w + 10 + Default.NPC_HPBAR_WIDTH, h + 4, Col 'bg')
	DHUD2.SimpleText(name, nil, x + 3 + DHUD2.GetDamageShift(), y - 1 + DHUD2.GetDamageShift(), Col 'npctext')
	
	x = x + w + 10
	DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + 1 + DHUD2.GetDamageShift(), Default.NPC_HPBAR_WIDTH - 5, h - 2, Col 'empty_bar')
	DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + 1 + DHUD2.GetDamageShift(), Default.NPC_HPBAR_WIDTH * percent - 5, h - 2, Col 'npchpbar')
	
	local t = string.format('%s/%s (%s%%)', hp, mhp, math.floor(percent * 100))
	local w2, h2 = surface.GetTextSize(t)
	x = rx + Default.NPC_HPBAR_WIDTH / 2 - w2
	DHUD2.SimpleText(t, nil, x + 3 + DHUD2.GetDamageShift(), y - 1 + DHUD2.GetDamageShift(), Col 'npctext')
end

Default.ENTITYHP_WIDTH = 300
Default.ENTITYHP_HEIGHT = 15

DHUD2.CreateColor('entityhealth', 'Entity Health Bar', 120, 160, 70, 255)

function Default.EntityHealth()
	local hp, mhp, perc = Var 'entityhealth', Var 'entityhealthmax', Var 'entityhealthpercent'
	local x, y = DHUD2.GetPosition('entityhp')
	x = x - Default.ENTITYHP_WIDTH / 2
	
	DHUD2.DrawBox(x - 5 + DHUD2.GetDamageShift(), y - 2 + DHUD2.GetDamageShift(), Default.ENTITYHP_WIDTH + 10, Default.ENTITYHP_HEIGHT + 4, Col 'bg')
	DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Default.ENTITYHP_WIDTH, Default.ENTITYHP_HEIGHT, Col 'empty_bar')
	DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Default.ENTITYHP_WIDTH * perc, Default.ENTITYHP_HEIGHT, Col 'entityhealth')
	
	DHUD2.SimpleText(string.format('%s/%s (%s%%)', hp, mhp, math.floor(perc * 100)), nil, x + 5 + DHUD2.GetDamageShift(), y - 1 + DHUD2.GetDamageShift(), Col 'entitytext')
end

local function DRAW(self, ply)
	local x, y = DHUD2.GetPosition('default')
	local RX, RY = x, y
	
	x = x - DEFAULT_WIDTH / 2
	
	local Back = Col 'bg'
	
	surface.SetFont('DHUD2.Default')
	
	DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), DEFAULT_WIDTH, DEFAULT_HEIGHT, Back)
	
	x = x + 30
	
	surface.SetDrawColor(Col 'line1')
	surface.DrawPoly{
		{x = x + 140, y = y},
		{x = x + 260, y = y},
		{x = x + 160, y = y + DEFAULT_HEIGHT},
		{x = x + 40, y = y + DEFAULT_HEIGHT},
	}
	
	surface.SetDrawColor(Col 'line2')
	surface.DrawPoly{
		{x = x + 260, y = y},
		{x = x + 300, y = y},
		{x = x + 200, y = y + DEFAULT_HEIGHT},
		{x = x + 160, y = y + DEFAULT_HEIGHT},
	}
	
	surface.SetDrawColor(Col 'line1')
	surface.DrawPoly{
		{x = x + 300, y = y},
		{x = x + 420, y = y},
		{x = x + 320, y = y + DEFAULT_HEIGHT},
		{x = x + 200, y = y + DEFAULT_HEIGHT},
	}
	
	x = x - 30
	
	Default.DrawBars(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), RX, RY)
	Default.PlayerInfo(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift())
	
	if Var 'drawammo' then
		Default.DrawAmmo(x, y, RX, RY)
	end
	
	if Var 'weaponname' ~= '???' then
		Default.DrawWeaponName(x, y)
	end
	
	if Var 'entityname' then
		Default.EntityDisplay()
	end
	
	if Var 'drawnhpbar' then
		Default.NPCBars()
	end
	
	if Var 'drawentityhealth' then
		Default.EntityHealth()
	end
	
	if DHUD2.DrawDarkRP then
		DHUD2.DrawDarkRP()
	end
end

DHUD2.DrawHook('default', DRAW)

local ToHide = {
	CHudAmmo = false,
	CHudBattery = false,
	CHudSecondaryAmmo = false,
	CHudHealth = false,
}

hook.Add('HUDShouldDraw', 'DHUD2.ShouldDraw', function(s)
	if not DHUD2.IsEnabled() then return end
	return ToHide[s]
end)

local HaveAmmo = false
local LastHaveAmmo = false

DHUD2.CreateWarning('ammo', 'clip1', 'maxclip1', {'Better reload'}, 0.2)
DHUD2.CreateWarningCustom('totalammo1', {'Few Ammunition left!', 'Ammunition depleted'}, 20, 0, function()
	return LastHaveAmmo
end)

function Default.UpdateAmmo(self, ply)
	local weapon = ply:GetActiveWeapon()
	
	if not IsValid(weapon) then
		SVar('drawammo', false)
		LastHaveAmmo = false
		HaveAmmo = false
		SVar('weaponname', '???')
		return
	end
	
	local name = weapon:GetPrintName()
	SVar('weaponname', name)
	
	local c1 = weapon:Clip1()
	local c2 = weapon:Clip2()
	local cm1 = weapon:GetMaxClip1()
	local cm2 = weapon:GetMaxClip2()
	local AmmoID1 = weapon:GetPrimaryAmmoType()
	local AmmoID2 = weapon:GetSecondaryAmmoType()
	
	local totalAmmo1 = ply:GetAmmoCount(AmmoID1)
	local totalAmmo2 = ply:GetAmmoCount(AmmoID2)
	
	SVar('clip1', c1)
	SVar('clip2', c2)
	SVar('maxclip1', cm1)
	SVar('maxclip2', cm2)
	SVar('totalammo1', totalAmmo1)
	SVar('totalammo2', totalAmmo2)
	
	if AmmoID1 == -1 then
		HaveAmmo = false
		LastHaveAmmo = false
	end
	
	if c1 > 0 or c2 > 0 or cm1 > 0 or cm2 > 0 or totalAmmo1 > 0 or totalAmmo2 > 0 or weapon.DrawAmmo then
		SVar('drawammo', true)
		LastHaveAmmo = HaveAmmo
		HaveAmmo = true
	else
		SVar('drawammo', false)
		LastHaveAmmo = HaveAmmo
		HaveAmmo = false
	end
end

function Default.UpdateNPCBar(self, ply, ent, isValid, isPlayer, Distance)
	if not isValid then
		SVar('drawnhpbar', false)
		return
	end
	
	if isPlayer then
		SVar('drawnhpbar', false)
		return
	end
	
	if not ent:IsNPC() then
		SVar('drawnhpbar', false)
		return
	end
	
	if Distance > 200 then
		SVar('drawnhpbar', false)
		return
	end
	
	local hp = ent:Health()
	local mhp = ent:GetMaxHealth()
	local npcname = ent.PrintName or ent:GetClass()
	
	SVar('npchp', hp)
	SVar('npcmhp', mhp)
	SVar('npcname', npcname)
	
	SVar('drawnhpbar', true)
end

DHUD2.VarHook('ammo', Default.UpdateAmmo)
DHUD2.VarHook('npcbars', Default.UpdateNPCBar)
