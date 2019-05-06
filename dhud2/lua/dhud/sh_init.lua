
--DHUD2 v2.0

--[[
Copyright (C) 2016-2019 DBotThePony


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

]]

DHUD2 = DHUD2 or {}
dhud2 = DHUD2
DHud2 = DHUD2

DHUD2.CONVAR_UNSETUP = 'DHUD2.CONVAR_UNSETUP'

DHUD2.Config = DHUD2.Config or {}

if SERVER then
	include('sv_init.lua')
end

function DHUD2.CreateVar(name, data)
	data.help = data.help or ''

	data.bool = data.type == 'bool'
	data.int = data.type == 'int'
	data.float = data.type == 'float'

	DHUD2.Config[name] = data

	local obj = CreateConVar('dhud_sv_' .. name, data.value, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, data.help)

	if SERVER then
		DHUD2.SVars[name] = obj
		SetGlobalString('dhud_sv_' .. name, obj:GetString())
		cvars.AddChangeCallback('dhud_sv_' .. name, DHUD2.ConVarChanged, 'DHUD2')
	end
end

function DHUD2.ServerConVar(name)
	local t = DHUD2.Config[name]

	local var

	if CLIENT then
		var = GetGlobalBool('dhud_sv_' .. name, t.value)
	else
		var = DHUD2.SVars[name]:GetString()
	end

	local num = tonumber(var) or t.value

	if t.bool then
		return tobool(var)
	elseif t.int then
		return math.ceil(num)
	elseif t.float then
		return num
	end

	return var
end

function DHUD2.pointInsideBox(point, mins, maxs)
	return
		mins.x < point.x and point.x < maxs.x and
		mins.y < point.y and point.y < maxs.y and
		mins.z < point.z and point.z < maxs.z
end


if SERVER then
	AddCSLuaFile()
else
	include('cl_init.lua')
end

DHUD2.CreateVar('minimap', {
	type = 'bool',
	value = '1',
	help = 'Enable DHUD2 minimap',
})

DHUD2.CreateVar('radar', {
	type = 'bool',
	value = '1',
	help = 'Enable DHUD2 radar',
})

DHUD2.CreateVar('freecam', {
	type = 'bool',
	value = '1',
	help = 'Enable DHUD2 freecam',
})

DHUD2.CreateVar('highlight', {
	type = 'bool',
	value = '1',
	help = 'Enable DHUD2 highlight',
})

DHUD2.CreateVar('smoothview', {
	type = 'bool',
	value = '1',
	help = 'Enable DHUD2 smooth view. Disabling this WILL affect other features.',
})

DHUD2.CreateVar('allowdisable', {
	type = 'bool',
	value = '1',
	help = 'Allow players to diable DHUD2',
})

DHUD2.CreateVar('pickuphistory', {
	type = 'bool',
	value = '1',
	help = 'Enable pickup history',
})

DHUD2.CreateVar('killfeed', {
	type = 'bool',
	value = '1',
	help = 'Enable killfeed',
})

DHUD2.CreateVar('crosshairs', {
	type = 'bool',
	value = '1',
	help = 'Enable crosshairs',
})

DHUD2.CreateVar('shift', {
	type = 'bool',
	value = '1',
	help = 'Enable shifting',
})

DHUD2.CreateVar('speedmeter', {
	type = 'bool',
	value = '1',
	help = 'Enable speedmeter',
})

DHUD2.CreateVar('playericon', {
	type = 'bool',
	value = '1',
	help = 'Enable player icon',
})

DHUD2.CreateVar('damage', {
	type = 'bool',
	value = '1',
	help = 'Enable damage hitnumbers',
})

DHUD2.CreateVar('voice', {
	type = 'bool',
	value = '1',
	help = 'Enable voice panels',
})

hook.Run('RegisterDHUD2Vars')
