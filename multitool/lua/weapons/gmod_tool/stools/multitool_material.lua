
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

local CURRENT_TOOL_MODE = 'multitool_material'

if SERVER then
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Select')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.MultiSelect')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Clear')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.MultiClear')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Apply')
else
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', 'Multi-Material')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'Select && Apply materials at once')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.0', '')
	
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left', 'Left Click - select-unselect')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left_use', 'USE + Left Click - auto-select')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right', 'Right Click - apply')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload', 'Reload - clear selection')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload_use', 'USE + Reload - clear all materials on selected entities and unselect them')
end

TOOL.Information = {
	{name = 'left'},
	{name = 'right'},
	{name = 'left_use'},
	{name = 'reload'},
	{name = 'reload_use'},
}

local SelectTable = {}

TOOL.Name = 'Multi-Material'
TOOL.Category = 'Multitool'

TOOL.AddToMenu = true
TOOL.Command = nil
TOOL.ConfigName = nil

TOOL.ClientConVar = {
	override = 'debug/env_cubemap_model',
	select_by_model = 0,
	select_by_material = 0,
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
	
	local Lab = Label('Auto-select settings')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local Lab = Label('To do auto select - Hold +use while left click')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	Panel:NumSlider('Auto Select Range', CURRENT_TOOL_MODE .. '_select_range', 1, 1024, 0)
	Panel:CheckBox('Auto Select by Model', CURRENT_TOOL_MODE .. '_select_by_model')
	Panel:CheckBox('Auto Select by Material', CURRENT_TOOL_MODE .. '_select_by_material')
	
	local Lab = Label('Note: It is strict lookup. Material mismatch - don\'t select')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	Panel:CheckBox('False - Sphere, True - Box', CURRENT_TOOL_MODE .. '_select_mode')
	
	local combo = Panel:ComboBox('Select Sort Mode', CURRENT_TOOL_MODE .. '_select_sort')
	
	MultiTool_AddSorterChoices(combo)
	
	local Lab = Label('Quick search')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local SearchFunc
	
	local Search = vgui.Create('DTextEntry', Panel)
	Panel:AddItem(Search)
	
	function Search:OnKeyCodeTyped(KEY)
		if KEY == KEY_ESCAPE then return true end
		if KEY == KEY_BACKSLASH then return true end
		
		SearchFunc()
		
		return false
	end
	
	local MatContainer
	
	local function Rebuild()
		if IsValid(MatContainer) then
			MatContainer:Remove()
		end
		
		MatContainer = vgui.Create('MatSelect', Panel)
		Panel:AddItem(MatContainer)
		
		MatContainer:SetConVar(CURRENT_TOOL_MODE .. '_override')
		MatContainer:SetAutoHeight(true)
		MatContainer:SetItemWidth(.25)
		MatContainer:SetItemHeight(.25)
	end
	
	function SearchFunc()
		Rebuild()
		local MEM = {} -- WTF gmod
		
		local strToFind = Search:GetText():lower()
		
		if strToFind and strToFind ~= '' then
			for k, v in pairs(list.Get('OverrideMaterials')) do
				if MEM[v] then continue end
				MEM[v] = true
				
				if v:lower():find(strToFind, 1, false) then
					MatContainer:AddMaterial(v, v)
				end
			end
		else
			for k, v in pairs(list.Get('OverrideMaterials')) do
				if MEM[v] then continue end
				MEM[v] = true
				
				MatContainer:AddMaterial(v, v)
			end
		end
		
		return true
	end
	
	SearchFunc()
	
	Search.OnValueChange = SearchFunc
end

local function CanUse(ply, ent)
	if not IsValid(ent) then return false end
	if ent:IsPlayer() then return false end -- Srry, but no material shit on players!
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
		chat.AddText('Clearing all materials and select table')
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
	
	local MatCache = {}
	local DRAW_MEM = {}
	
	hook.Add('PreDrawAnythingToolgun', CURRENT_TOOL_MODE, function(ply, weapon, mode)
		if mode ~= CURRENT_TOOL_MODE then return end
		
		ClearSelectedItems()
		
		for i, ent in ipairs(SelectTable) do
			DRAW_MEM[ent] = ent:GetNoDraw()
			ent:SetNoDraw(true)
		end
	end)
	
	hook.Add('PostDrawWorldToolgun', CURRENT_TOOL_MODE, function(ply, weapon, mode)
		if mode ~= CURRENT_TOOL_MODE then return end
		
		MatCache[CVars.override:GetString()] = MatCache[CVars.override:GetString()] or Material(CVars.override:GetString())
		
		for i, ent in ipairs(SelectTable) do
			render.ModelMaterialOverride(MatCache[CVars.override:GetString()])
			ent:DrawModel()
			ent:SetNoDraw(DRAW_MEM[ent])
		end
		
		render.ModelMaterialOverride()
		
		DRAW_MEM = {}
	end)
	
	language.Add('Undo_NoCollideMulti', 'Undone Multi No-Collide')
else
	net.Receive(CURRENT_TOOL_MODE .. '.Apply', function(len, ply)
		local SelectTable = net.ReadTable()
		
		local mat = ply:GetInfo(CURRENT_TOOL_MODE .. '_override')
		
		if not game.SinglePlayer() and not list.Contains('OverrideMaterials', mat) and mat ~= '' then return end
		
		for i, ent in ipairs(SelectTable) do
			if not CanUse(ply, ent) then continue end
			ent:SetMaterial(mat)
		end
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.MultiClear', function(len, ply)
		local SelectTable = net.ReadTable()
		
		for i, ent in ipairs(SelectTable) do
			if not CanUse(ply, ent) then continue end
			ent:SetMaterial('')
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
			local select_by_material = false
			local MDL
			local MATERIAL
			
			if IsValid(ent) then
				select_by_model = ply:GetInfo(CURRENT_TOOL_MODE .. '_select_by_model') == '1'
				select_by_material = ply:GetInfo(CURRENT_TOOL_MODE .. '_select_by_material') == '1'
				
				MDL = ent:GetModel()
				MATERIAL = ent:GetMaterial()
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
				
				if select_by_material then
					if ent:GetMaterial() ~= MATERIAL then continue end
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
