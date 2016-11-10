
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

local CURRENT_TOOL_MODE = 'multicolour_gradient'

local HALP = 'Controls:\nLeft Click - select-unselect\nRight Click - apply\nReload - clear selection\nReload + USE - clear colors or selected entities and unselect them.\nLeft Click + USE - auto-select'

if SERVER then
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Select')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.MultiSelect')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Clear')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.ClearColors')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Apply')
else
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', 'Multi-Color Gradient Mode')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'COLORS MAKE ME CRY!')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.0', '')
	
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left', 'Left Click - select-unselect')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left_use', 'USE + Left Click - auto-select')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right', 'Right Click - apply')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload', 'Reload - clear selection')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload_use', 'USE + Reload - clear colors or selected entities and unselect them')
end

TOOL.Information = {
	{name = 'left'},
	{name = 'right'},
	{name = 'left_use'},
	{name = 'reload'},
	{name = 'reload_use'},
}

local SelectTable = {}

TOOL.Name = 'Multi-Color - Gradient'
TOOL.Category = 'Multitool'

TOOL.AddToMenu = true
TOOL.Command = nil
TOOL.ConfigName = nil

TOOL.ClientConVar = {
	first_red = 0,
	first_green = 255,
	first_blue = 255,
	first_alpha = 255,
	
	last_red = 200,
	last_green = 0,
	last_blue = 255,
	last_alpha = 255,
	
	select_mode = 0,
	select_by_model = 0,
	select_colored = 0,
	select_sort = 2,
	select_range = 512,
	
	color_fx = 0,
	color_mode = 0,
}

TOOL.ServerConVar = {}

local PANEL
local RebuildPanel
local RebuildListFunc = function() end

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
		table.remove(SelectTable, toRemove[#toRemove])
		RebuildPanel(PANEL)
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
	
	Panel:CheckBox('False - Sphere, True - Box', CURRENT_TOOL_MODE .. '_select_mode')
	Panel:CheckBox('False - select non-colored, True - select all', CURRENT_TOOL_MODE .. '_select_colored')
	Panel:CheckBox('Auto Select by Model', CURRENT_TOOL_MODE .. '_select_by_model')
	
	local Lab = Label('Auto-Selecting an colored entity will\nwhen "Select Colored" is false will\nselect all colored entities instead')
	Lab:SizeToContents()
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local color_mode = Panel:ComboBox('Render Mode', CURRENT_TOOL_MODE .. '_color_mode')
	local color_fx = Panel:ComboBox('Render FX', CURRENT_TOOL_MODE .. '_color_fx')
	
	for k, v in pairs(list.Get('RenderModes')) do
		color_mode:AddChoice(k, v.colour_mode)
	end
	
	for k, v in pairs(list.Get('RenderFX')) do
		color_fx:AddChoice(k, v.colour_fx)
	end
	
	local combo = Panel:ComboBox('Select Sort Mode', CURRENT_TOOL_MODE .. '_select_sort')
	
	MultiTool_AddSorterChoices(combo)
	
	local Lab = Label('First Color')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE .. '_first_red')
	mixer:SetConVarG(CURRENT_TOOL_MODE .. '_first_green')
	mixer:SetConVarB(CURRENT_TOOL_MODE .. '_first_blue')
	mixer:SetConVarA(CURRENT_TOOL_MODE .. '_first_alpha')
	
	local Lab = Label('Last Color')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE .. '_last_red')
	mixer:SetConVarG(CURRENT_TOOL_MODE .. '_last_green')
	mixer:SetConVarB(CURRENT_TOOL_MODE .. '_last_blue')
	mixer:SetConVarA(CURRENT_TOOL_MODE .. '_last_alpha')
	
	local newPnl = vgui.Create('EditablePanel', Panel)
	
	newPnl:SetHeight(500)
	Panel:AddItem(newPnl)
	
	local List = newPnl:Add('DListView')
	List:Dock(TOP)
	List:SetHeight(475)
	List:AddColumn('ID')
	List:AddColumn('Entity')
	
	local function Rebuild()
		ClearSelectedItems()
		List:Clear()
		
		for i, ent in ipairs(SelectTable) do
			List:AddLine(tostring(i), tostring(ent))
		end
	end
	
	RebuildListFunc = Rebuild
	Rebuild()
	
	local MoveUp = newPnl:Add('DButton')
	local Unselect = newPnl:Add('DButton')
	local MoveDown = newPnl:Add('DButton')
	
	MoveUp:SetText('Move Up')
	Unselect:SetText('Unselect')
	MoveDown:SetText('Move Down')
	
	function MoveUp:DoClick()
		local selected = List:GetLine(List:GetSelectedLine())
		
		if not IsValid(selected) then return end
		
		local i = tonumber(selected:GetValue(1))
		if i < 2 then return end
		
		local firstVal, lastVal = SelectTable[i - 1], SelectTable[i]
		
		SelectTable[i] = firstVal
		SelectTable[i - 1] = lastVal
		
		Rebuild()
		
		List:SelectItem(List:GetLine(i - 1))
	end
	
	function MoveDown:DoClick()
		local selected = List:GetLine(List:GetSelectedLine())
		
		if not IsValid(selected) then return end
		
		local i = tonumber(selected:GetValue(1))
		if i == #SelectTable then return end
		
		local firstVal, lastVal = SelectTable[i + 1], SelectTable[i]
		
		SelectTable[i] = firstVal
		SelectTable[i + 1] = lastVal
		
		Rebuild()
		
		List:SelectItem(List:GetLine(i + 1))
	end
	
	function Unselect:DoClick()
		local selected = List:GetLine(List:GetSelectedLine())
		
		if not IsValid(selected) then return end
		
		local i = tonumber(selected:GetValue(1))
		table.remove(SelectTable, i)
		Rebuild()
		
		if #SelectTable ~= 0 then
			List:SelectItem(List:GetLine(i))
		end
	end
	
	MoveUp:Dock(LEFT)
	Unselect:Dock(LEFT)
	MoveDown:Dock(LEFT)
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
	surface.SetFont('MultiColorGradient.ScreenHeader')
	
	local w = surface.GetTextSize('Unsaved changes')
	
	surface.SetTextPos(ScrW() / 2 - w / 2, 180)
	surface.DrawText('Unsaved changes')
end

if CLIENT then
	local CVars = {}
	
	for k, v in pairs(TOOL.ClientConVar) do
		CVars[k] = CreateConVar(CURRENT_TOOL_MODE .. '_' .. k, tostring(v), {FCVAR_ARCHIVE, FCVAR_USERINFO}, '')
	end
	
	surface.CreateFont('MultiColorGradient.ScreenHeader', {
		font = 'Roboto',
		size = 48,
		weight = 800,
	})
	
	net.Receive(CURRENT_TOOL_MODE .. '.Select', function()
		local newEnt = net.ReadEntity()
		
		for k, v in ipairs(SelectTable) do
			if v == newEnt then
				table.remove(SelectTable, k)
				RebuildListFunc()
				return
			end
		end
		
		table.insert(SelectTable, newEnt)
		
		RebuildListFunc()
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.Clear', function()
		SelectTable = {}
		
		chat.AddText('Selection Cleared!')
		
		RebuildListFunc()
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.Apply', function()
		net.Start(CURRENT_TOOL_MODE .. '.Apply')
		net.WriteTable(SelectTable)
		net.SendToServer()
		
		SelectTable = {}
		
		chat.AddText('Selection is about to be Applied!')
		
		RebuildListFunc()
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.ClearColors', function()
		net.Start(CURRENT_TOOL_MODE .. '.ClearColors')
		net.WriteTable(SelectTable)
		net.SendToServer()
		
		SelectTable = {}
		
		chat.AddText('Clearing colors and select table')
		
		RebuildListFunc()
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
		
		RebuildListFunc()
		
		chat.AddText('Auto-Selected ' .. count .. ' entities')
	end)
	
	hook.Add('PostDrawWorldToolgun', CURRENT_TOOL_MODE, function(ply, weapon, mode)
		if mode ~= CURRENT_TOOL_MODE then return end
		
		ClearSelectedItems()
		
		local max = #SelectTable
		
		local first_red = CVars.first_red:GetInt()
		local first_green = CVars.first_green:GetInt()
		local first_blue = CVars.first_blue:GetInt()
		local first_alpha = CVars.first_alpha:GetInt()
		
		local last_red = CVars.last_red:GetInt()
		local last_green = CVars.last_green:GetInt()
		local last_blue = CVars.last_blue:GetInt()
		local last_alpha = CVars.last_alpha:GetInt()
		
		local delta_red = last_red - first_red
		local delta_green = last_green - first_green
		local delta_blue = last_blue - first_blue
		local delta_alpha = last_alpha - first_alpha
		
		for i, ent in ipairs(SelectTable) do
			local red = first_red + delta_red * (i / max)
			local green = first_green + delta_green * (i / max)
			local blue = first_blue + delta_blue * (i / max)
			local alpha = first_alpha + delta_alpha * (i / max)
			
			render.SetColorModulation(red / 255, green / 255, blue / 255, alpha / 255)
			ent:DrawModel()
		end
		
		render.SetColorModulation(1, 1, 1)
	end)
else
	net.Receive(CURRENT_TOOL_MODE .. '.Apply', function(len, ply)
		local SelectTable = net.ReadTable()
		
		local max = #SelectTable
		
		local first_red = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_first_red') or 0) or 0
		local first_green = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_first_green') or 0) or 0
		local first_blue = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_first_blue') or 0) or 0
		local first_alpha = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_first_alpha') or 0) or 0
		
		local last_red = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_last_red') or 0) or 0
		local last_green = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_last_green') or 0) or 0
		local last_blue = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_last_blue') or 0) or 0
		local last_alpha = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_last_alpha') or 0) or 0
		
		local color_fx = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_color_fx') or 0) or 0
		local color_mode = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_color_mode') or 0) or 0
		
		local delta_red = last_red - first_red
		local delta_green = last_green - first_green
		local delta_blue = last_blue - first_blue
		local delta_alpha = last_alpha - first_alpha
		
		for i, ent in ipairs(SelectTable) do
			if not IsValid(ent) then continue end
			
			if not CanUse(ply, ent) then continue end
			
			local red = first_red + delta_red * (i / max)
			local green = first_green + delta_green * (i / max)
			local blue = first_blue + delta_blue * (i / max)
			local alpha = first_alpha + delta_alpha * (i / max)
			
			local new = Color(red, green, blue, alpha)
			ent:SetColor(new)
			ent:SetRenderMode(color_mode)
			ent:SetKeyValue('renderfx', color_fx)
			
			duplicator.StoreEntityModifier(ent, 'colour', {
				Color = new,
				RenderMode = color_mode,
				RenderFX = color_fx,
			})
		end
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.ClearColors', function(len, ply)
		local SelectTable = net.ReadTable()
		
		for i, ent in ipairs(SelectTable) do
			if not CanUse(ply, ent) then continue end
			ent:SetColor(color_white)
			ent:SetRenderMode(0)
			ent:SetKeyValue('renderfx', 0)
			
			duplicator.StoreEntityModifier(ent, 'colour', {
				Color = color_white,
				RenderMode = 0,
				RenderFX = 0,
			})
		end
	end)
end

function TOOL:Reload(tr)
	if SERVER then
		if not self:GetOwner():KeyDown(IN_USE) then
			net.Start(CURRENT_TOOL_MODE .. '.Clear')
			net.Send(self:GetOwner())
		else
			net.Start(CURRENT_TOOL_MODE .. '.ClearColors')
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
		local hitEntityHaveColor = false
		
		if IsValid(ent) then
			local col = ent:GetColor()
			hitEntityHaveColor = col.r ~= 255 or col.g ~= 255 or col.b ~= 255
		end
		
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
			local select_colored = ply:GetInfo(CURRENT_TOOL_MODE .. '_select_colored') == '1'
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
				if not select_colored then
					local col = ent:GetColor()
					
					local status = col.r ~= 255 or col.g ~= 255 or col.b ~= 255
					
					if hitEntityHaveColor then
						status = not status
					end
					
					if status then continue end
				end
				
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
