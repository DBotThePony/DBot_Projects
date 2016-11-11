
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

module('GTools', package.seeall)

DISABLE_PHYSGUN_SETUP_BY_ADMINS = CreateConVar('gtools_disable_physgun_config', '0', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Disable ability to modify physgun settings from superadmin clients')

local physgun = {
	'physgun_DampingFactor',
	'physgun_maxAngular',
	'physgun_maxAngularDamping',
	'physgun_maxrange',
	'physgun_maxSpeed',
	'physgun_maxSpeedDamping',
	'physgun_teleportDistance',
	'physgun_timeToArrive',
	'physgun_timeToArriveRagdoll',
}

for k, v in ipairs(physgun) do
	local cvar = GetConVar(v)
	
	if not cvar then continue end
	
	concommand.Add('_g_' .. v, function(ply, cmd, args)
		if DISABLE_PHYSGUN_SETUP_BY_ADMINS:GetBool() then return end
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		if not args[1] then return end
		local num = tonumber(args[1])
		if not num then return end
		
		if num == cvar:GetFloat() then return end
		
		RunConsoleCommand(v, args[1])
	end)
	
	cvars.AddChangeCallback(v, function()
		SetGlobalString(v, cvar:GetString())
	end, 'GTools')
	
	SetGlobalString(v, cvar:GetString())
end
