
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

util.AddNetworkString('GTools.AdminMessage')
util.AddNetworkString('GTools.PrintMessage')

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

--[[
	Select Sort Mode
	1: Unsorted
	2: Select the nearests to fire point first
	3: Select the far to fire point first
	4: Select x - X
	5: Select X - x
	6: Select y - Y
	7: Select Y - y

	8: Select x+y - X+Y
	9: Select X+Y - x+y
	10: Select x+Y - X+y
	11: Select X+y - x+Y
]]

function MultiTool_Sort(mode, pos, tab)
	if not mode or mode > 11 or mode <= 1 then return tab end
	
	local PosMem = {}
	
	for i, val in ipairs(tab) do
		PosMem[val] = val:GetPos()
	end
	
	if mode == 2 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1:DistToSqr(pos) > pos2:DistToSqr(pos)
		end)
	elseif mode == 3 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1:DistToSqr(pos) < pos2:DistToSqr(pos)
		end)
	elseif mode == 4 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.x > pos2.x
		end)
	elseif mode == 5 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.x < pos2.x
		end)
	elseif mode == 6 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.y > pos2.y
		end)
	elseif mode == 7 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.y < pos2.y
		end)
	elseif mode == 8 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.y + pos1.x > pos2.y + pos2.x
		end)
	elseif mode == 9 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.y + pos1.x < pos2.y + pos2.x
		end)
	elseif mode == 10 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.x > pos2.x and pos1.y < pos2.y
		end)
	elseif mode == 11 then
		table.sort(tab, function(a, b)
			local pos1, pos2 = PosMem[a], PosMem[b]
			
			return pos1.x < pos2.x and pos1.y > pos2.y
		end)
	end
	
	return tab
end

_G.MultiTool_Sort = MultiTool_Sort

function AdminPrint(...)
	Message(...)
	local filter = {}
	
	for k, v in ipairs(player.GetAll()) do
		if v:IsAdmin() then
			table.insert(filter, v)
		end
	end
	
	if #filter == 0 then return end
	
	net.Start('GTools.AdminMessage')
	net.WriteTable{...}
	net.Send(filter)
end

function PChatPrint(ply, ...)
	net.Start('GTools.PrintMessage')
	net.WriteTable{...}
	net.Send(ply)
end

AdminMessage = AdminPrint
