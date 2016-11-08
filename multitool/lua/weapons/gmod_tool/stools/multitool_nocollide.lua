
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

TOOL.AddToMenu = true
TOOL.Command = nil
TOOL.ConfigName = nil

TOOL.ClientConVar = {
	select_red = 0,
	select_green = 255,
	select_blue = 255,
	
	select_by_model = 0,
	select_mode = 0,
	select_sort = 2,
	select_range = 512,
}

TOOL.ServerConVar = {}

local PANEL
local RebuildPanel

local function ClearSelectedItems()
	local toRemove = {}
	
	for k, v in ipairs(SelectTable) do
		if not v:IsValid() then
			table.insert(toRemove, k)
		end
	end
	
	for k = 1, #toRemove - 1 do
		SelectTable[toRemove[k]] = nil
	end
	
	if #toRemove > 0 then
		RebuildPanel(PANEL)
		table.remove(SelectTable, toRemove[#toRemove])
	end
end

function RebuildPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	PANEL = Panel
	
	local Lab = Label(HALP)
	Lab:SizeToContents()
	Lab:SetTooltip(HALP)
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local Lab = Label('Auto-select settings')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local Lab = Label('To do auto select - Hold +use while left click')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	Panel:NumSlider('Auto Select Range', CURRENT_TOOL_MODE .. '_select_range', 1, 1024, 0)
	Panel:CheckBox('Auto Select by Model', CURRENT_TOOL_MODE .. '_select_by_model')
	Panel:CheckBox('False - Sphere, True - Box', CURRENT_TOOL_MODE .. '_select_mode')
	
	local combo = Panel:ComboBox('Select Sort Mode', CURRENT_TOOL_MODE .. '_select_sort')
	
	MultiTool_AddSorterChoices(combo)
	
	local Lab = Label('Select color')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE .. '_select_red')
	mixer:SetConVarG(CURRENT_TOOL_MODE .. '_select_green')
	mixer:SetConVarB(CURRENT_TOOL_MODE .. '_select_blue')
	mixer:SetAlphaBar(false)
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

function TOOL:DrawHUD()
	if #SelectTable == 0 then return end
	
	surface.SetTextColor(200, 50, 50)
	surface.SetFont('MultiTool.ScreenHeader')
	
	local w = surface.GetTextSize('Unsaved changes')
	
	surface.SetTextPos(ScrW() / 2 - w / 2, 180)
	surface.DrawText('Unsaved changes')
end

if CLIENT then
	local CVars = {}
	
	for k, v in pairs(TOOL.ClientConVar) do
		CVars[k] = CreateConVar(CURRENT_TOOL_MODE .. '_' .. k, tostring(v), {FCVAR_ARCHIVE, FCVAR_USERINFO}, '')
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
		chat.AddText('Selection Cleared!')
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.Apply', function()
		net.Start(CURRENT_TOOL_MODE .. '.Apply')
		net.WriteTable(SelectTable)
		net.SendToServer()
		
		SelectTable = {}
		chat.AddText('Selection is about to be Applied!')
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.MultiClear', function()
		net.Start(CURRENT_TOOL_MODE .. '.MultiClear')
		net.WriteTable(SelectTable)
		net.SendToServer()
		
		SelectTable = {}
		chat.AddText('Clearing all no-collide constraints and select table')
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.MultiSelect', function()
		local count = net.ReadUInt(12)
		local read = {}
		
		for i = 1, count do
			local new = net.ReadEntity()
			
			if IsValid(new) then
				table.insert(read, new)
			end
		end
		
		for i, newEnt in ipairs(read) do
			local hit = false
			
			for k, v in ipairs(SelectTable) do
				if v == newEnt then
					table.remove(SelectTable, k)
					hit = true
					break
				end
			end
			
			if not hit then
				table.insert(SelectTable, newEnt)
			end
		end
		
		chat.AddText('Auto-Selected ' .. count .. ' entities')
	end)
	
	hook.Add('PostDrawWorldToolgun', CURRENT_TOOL_MODE, function(ply, weapon, mode)
		if mode ~= CURRENT_TOOL_MODE then return end
		
		ClearSelectedItems()
		
		local select_red = CVars.select_red:GetInt() / 255
		local select_green = CVars.select_green:GetInt() / 255
		local select_blue = CVars.select_blue:GetInt() / 255
		
		for i, ent in ipairs(SelectTable) do
			render.SetColorModulation(select_red, select_green, select_blue) -- Make sure that nothing we rendered reseted our color!
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
			local select_by_model = false
			local MDL
			
			if IsValid(ent) then
				select_by_model = ply:GetInfo(CURRENT_TOOL_MODE .. '_select_by_model') == '1'
				MDL = ent:GetModel()
			end
			
			local mode = ply:GetInfo(CURRENT_TOOL_MODE .. '_select_mode') == '1'
			local smode = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_select_sort')) or 1
			local dist = math.Clamp(tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_select_range')) or 512, 1, 1024)
			local Find
			
			if mode then
				Find = ents.FindInBox(tr.HitPos, dist)
			else
				Find = ents.FindInSphere(tr.HitPos, dist)
			end
			
			local new = {}
			
			for i, ent in ipairs(Find) do
				if not CanUse(ply, ent) then continue end
				
				if select_by_model then
					if ent:GetModel() ~= MDL then continue end
				end
				
				table.insert(new, ent)
			end
			
			MultiTool_Sort(smode, tr.HitPos, new)
			
			net.Start(CURRENT_TOOL_MODE .. '.MultiSelect')
			net.WriteUInt(#new, 12)
			
			for i = 1, #new do
				net.WriteEntity(new[i])
			end
			
			net.Send(self:GetOwner())
		end
	end
	
	return true
end

TOOL.BuildCPanel = RebuildPanel
