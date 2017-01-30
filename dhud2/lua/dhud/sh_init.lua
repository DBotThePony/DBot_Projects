
--DHUD2 v2.0

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
