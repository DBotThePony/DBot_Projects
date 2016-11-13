
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

local CURRENT_TOOL_MODE = 'multitool_nocollide'

local HALP = 'Controls:\nLeft Click - select-unselect\nRight Click - apply\nReload - clear selection\nReload + USE - clear colors or selected entities and unselect them.\nLeft Click + USE - auto-select'

if SERVER then
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Select')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.MultiSelect')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Clear')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.MultiClear')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Apply')
else
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', 'Multi-NoCollide')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'Make props no-collide with each other')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.0', '')
	
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left', 'Left Click - select-unselect')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left_use', 'USE + Left Click - auto-select')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right', 'Right Click - apply')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload', 'Reload - clear selection')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload_use', 'USE + Reload - clear all no-collides between selected entities and unselect them (broken for now)')
end

TOOL.Information = {
	{name = 'left'},
	{name = 'right'},
	{name = 'left_use'},
	{name = 'reload'},
	{name = 'reload_use'},
}

local SelectTable = {}

TOOL.Name = 'Multi-NoCollide'
TOOL.Category = 'Multitool'

TOOL.ClientConVar = {
	select_r = 0,
	select_g = 255,
	select_b = 255,
}

GTools.AddAutoSelectConVars(TOOL.ClientConVar)

local PANEL
local RebuildPanel

function RebuildPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	PANEL = Panel
	
	GTools.AutoSelectOptions(Panel, CURRENT_TOOL_MODE)
	GTools.GenericSelectPicker(Panel, CURRENT_TOOL_MODE)
end

local function CanUse(ply, ent)
	if not IsValid(ent) then return false end
	if ent:IsPlayer() then return false end
	if ent:IsWeapon() then return false end
	if ent.CPPICanTool and not ent:CPPICanTool(ply, CURRENT_TOOL_MODE) then return false end
	if ent:GetSolid() == SOLID_NONE then return false end
	if IsValid(ent:GetOwner()) then return false end
	
	return true
end

function TOOL:CanUseEntity(ent)
	return CanUse(self:GetOwner(), ent)
end

function TOOL:DrawHUD()
	if #SelectTable == 0 then return end
	
	surface.SetTextColor(200, 50, 50)
	surface.SetFont('MultiTool.ScreenHeader')
	
	local w = surface.GetTextSize('Unsaved changes')
	
	surface.SetTextPos(ScrW() / 2 - w / 2, 180)
	surface.DrawText('Unsaved changes')
end

if CLIENT then
	local cvar = {}
	
	for k, v in pairs(TOOL.ClientConVar) do
		cvar[k] = CreateConVar(CURRENT_TOOL_MODE .. '_' .. k, tostring(v), {FCVAR_ARCHIVE, FCVAR_USERINFO}, '')
	end
	
	net.Receive(CURRENT_TOOL_MODE .. '.Select', function()
		local newEnt = net.ReadEntity()
		
		for k, v in ipairs(SelectTable) do
			if v == newEnt then
				table.remove(SelectTable, k)
				return
			end
		end
		
		table.insert(SelectTable, newEnt)
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.Clear', function()
		SelectTable = {}
		GTools.ChatPrint('Selection Cleared!')
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.Apply', function()
		GTools.GenericTableClear(SelectTable)
		
		net.Start(CURRENT_TOOL_MODE .. '.Apply')
		net.WriteTable(SelectTable)
		net.SendToServer()
		
		SelectTable = {}
		GTools.ChatPrint('Selection is about to be Applied!')
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.MultiClear', function()
		net.Start(CURRENT_TOOL_MODE .. '.MultiClear')
		net.WriteTable(SelectTable)
		net.SendToServer()
		
		SelectTable = {}
		GTools.ChatPrint('Clearing all no-collide constraints and select table')
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.MultiSelect', function()
		local read = GTools.ReadEntityList()
		
		for i, newEnt in ipairs(read) do
			local hit = false
			
			for k, v in ipairs(SelectTable) do
				if v == newEnt then
					if cvar.select_invert:GetBool() then
						table.remove(SelectTable, k)
					end
					
					hit = true
					break
				end
			end
			
			if not hit then
				table.insert(SelectTable, newEnt)
			end
		end
		
		GTools.ChatPrint('Auto-Selected ' .. #read .. ' entities!')
		
		if cvar.select_print:GetBool() then
			GTools.ChatPrint('Look into console for the list')
			
			for k, v in ipairs(read) do
				GTools.PrintEntity(v)
			end
		end
	end)
	
	hook.Add('PostDrawWorldToolgun', CURRENT_TOOL_MODE, function(ply, weapon, mode)
		if mode ~= CURRENT_TOOL_MODE then return end
		
		GTools.GenericTableClear(SelectTable)
		
		local r = cvar.select_r:GetInt() / 255
		local g = cvar.select_g:GetInt() / 255
		local b = cvar.select_b:GetInt() / 255
		
		for i, ent in ipairs(SelectTable) do
			render.SetColorModulation(r, g, b) -- Make sure that nothing we rendered reseted our color!
			ent:DrawModel()
		end
		
		render.SetColorModulation(1, 1, 1)
	end)
	
	language.Add('Undo_NoCollideMulti', 'Undone Multi No-Collide')
else
	net.Receive(CURRENT_TOOL_MODE .. '.Apply', function(len, ply)
		local SelectTable = net.ReadTable()
		
		local toRemove = {}
		
		for i, ent in ipairs(SelectTable) do
			if not CanUse(ply, ent) then
				table.insert(toRemove, i)
			end
		end
		
		for i, v in ipairs(toRemove) do
			table.remove(SelectTable, v - i + 1)
		end
		
		local CreatedConstraints = {}
		local MEM = {}
		
		for i, ent in ipairs(SelectTable) do
			MEM[ent] = MEM[ent] or {}
			for i, ent2 in ipairs(SelectTable) do
				MEM[ent2] = MEM[ent2] or {}
				
				if MEM[ent2][ent] then continue end
				if MEM[ent][ent2] then continue end
				
				MEM[ent][ent2] = true
				MEM[ent2][ent] = true
				
				if ent == ent2 then continue end
				
				local new = constraint.NoCollide(ent, ent2, 0, 0)
				
				if new then
					table.insert(CreatedConstraints, new)
				end
			end
		end
		
		if #CreatedConstraints > 0 then
			undo.Create('NoCollideMulti')
			undo.SetPlayer(ply)
			
			for i, ent in ipairs(CreatedConstraints) do
				undo.AddEntity(ent)
				ply:AddCleanup('nocollide', ent)
			end
			
			undo.Finish()
		end
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.MultiClear', function(len, ply)
		local SelectTable = net.ReadTable()
		
		for i, ent in ipairs(SelectTable) do
			if not CanUse(ply, ent) then continue end
		end
	end)
end

function TOOL:Reload(tr)
	if SERVER then
		if not self:GetOwner():KeyDown(IN_USE) then
			net.Start(CURRENT_TOOL_MODE .. '.Clear')
			net.Send(self:GetOwner())
		else
			net.Start(CURRENT_TOOL_MODE .. '.MultiClear')
			net.Send(self:GetOwner())
		end
	end
	
	return true
end

function TOOL:RightClick(tr)
	if SERVER then
		net.Start(CURRENT_TOOL_MODE .. '.Apply')
		net.Send(self:GetOwner())
	end
	
	return true
end

function TOOL:LeftClick(tr)
	local ent = tr.Entity
	local ply = self:GetOwner()
	if not ply:KeyDown(IN_USE) and not CanUse(ply, ent) then return end
	
	if SERVER then
		if not ply:KeyDown(IN_USE) then
			net.Start(CURRENT_TOOL_MODE .. '.Select')
			net.WriteEntity(ent)
			net.Send(self:GetOwner())
		else
			local new = GTools.GenericAutoSelect(self, tr)
			
			net.Start(CURRENT_TOOL_MODE .. '.MultiSelect')
			GTools.WriteEntityList(new)
			net.Send(self:GetOwner())
		end
	end
	
	return true
end

TOOL.BuildCPanel = RebuildPanel
