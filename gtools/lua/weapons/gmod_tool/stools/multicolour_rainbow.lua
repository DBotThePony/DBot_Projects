
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

local CURRENT_TOOL_MODE = 'multicolour_rainbow'

local HALP = 'Controls:\nLeft Click - select-unselect\nRight Click - apply\nReload - clear selection\nReload + USE - clear colors or selected entities and unselect them.\nLeft Click + USE - auto-select'

if SERVER then
	util.AddNetworkString('MultiColorRainbow.Select')
	util.AddNetworkString('MultiColorRainbow.MultiSelect')
	util.AddNetworkString('MultiColorRainbow.Clear')
	util.AddNetworkString('MultiColorRainbow.ClearColors')
	util.AddNetworkString('MultiColorRainbow.Apply')
else
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', 'Multi-Color Rainbow Mode')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'RAINBOWS MAKE ME CRY!')
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

TOOL.Name = 'Multi-Color - Rainbow'
TOOL.Category = 'Multitool'

TOOL.ClientConVar = {
	step = 2,
	step_mult = 0.6,
	select_mode = 0,
	select_by_model = 0,
	select_colored = 0,
	select_sort = 2,
	select_range = 512,
	
	color_fx = 0,
	color_mode = 0,
}

GTools.AddAutoSelectConVars(TOOL.ClientConVar)

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
	
	Panel:NumSlider('Step of rainbow', CURRENT_TOOL_MODE .. '_step', 0, 4, 2)
	Panel:NumSlider('Multiplier of rainbow', CURRENT_TOOL_MODE .. '_step_mult', 0, 4, 2)
	
	GTools.AutoSelectOptions(Panel, CURRENT_TOOL_MODE)
	
	local color_mode = Panel:ComboBox('Render Mode', CURRENT_TOOL_MODE .. '_color_mode')
	local color_fx = Panel:ComboBox('Render FX', CURRENT_TOOL_MODE .. '_color_fx')
	
	for k, v in pairs(list.Get('RenderModes')) do
		color_mode:AddChoice(k, v.colour_mode)
	end
	
	for k, v in pairs(list.Get('RenderFX')) do
		color_fx:AddChoice(k, v.colour_fx)
	end
	
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

function TOOL:CanUseEntity(ent)
	return CanUse(self:GetOwner(), ent)
end

function TOOL:DrawHUD()
	if #SelectTable == 0 then return end
	
	surface.SetTextColor(200, 50, 50)
	surface.SetFont('MultiColorRainbow.ScreenHeader')
	
	local w = surface.GetTextSize('Unsaved changes')
	
	surface.SetTextPos(ScrW() / 2 - w / 2, 180)
	surface.DrawText('Unsaved changes')
end

if CLIENT then
	local cvar = {}
	
	for k, v in pairs(TOOL.ClientConVar) do
		cvar[k] = CreateConVar('multicolour_rainbow_' .. k, tostring(v), {FCVAR_ARCHIVE, FCVAR_USERINFO}, '')
	end
	
	surface.CreateFont('MultiColorRainbow.ScreenHeader', {
		font = 'Roboto',
		size = 48,
		weight = 800,
	})
	
	net.Receive('MultiColorRainbow.Select', function()
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
	
	net.Receive('MultiColorRainbow.Clear', function()
		SelectTable = {}
		
		GTools.ChatPrint('Selection Cleared!')
		
		RebuildListFunc()
	end)
	
	net.Receive('MultiColorRainbow.Apply', function()
		net.Start('MultiColorRainbow.Apply')
		GTools.WriteEntityList(SelectTable)
		net.SendToServer()
		
		SelectTable = {}
		
		GTools.ChatPrint('Selection is about to be Applied!')
		
		RebuildListFunc()
	end)
	
	net.Receive('MultiColorRainbow.ClearColors', function()
		net.Start('MultiColorRainbow.ClearColors')
		GTools.WriteEntityList(SelectTable)
		net.SendToServer()
		
		SelectTable = {}
		
		GTools.ChatPrint('Clearing colors and select table')
		
		RebuildListFunc()
	end)
	
	net.Receive('MultiColorRainbow.MultiSelect', function()
		GTools.GenericMultiselectReceive(SelectTable, cvar)
		RebuildListFunc()
	end)
	
	hook.Add('PostDrawWorldToolgun', 'MultiColorDraw', function(ply, weapon, mode)
		if mode ~= 'multicolour_rainbow' then return end
		
		ClearSelectedItems()
		
		local STEP = cvar.step:GetFloat()
		local MULTIP = cvar.step_mult:GetFloat()
		
		for i, ent in ipairs(SelectTable) do
			render.SetColorModulation(math.sin(i * MULTIP) * .5 + .5, math.sin((i + STEP) * MULTIP) * .5 + .5, math.sin((i + STEP * 2) * MULTIP) * .5 + .5)
			ent:DrawModel()
		end
		
		render.SetColorModulation(1, 1, 1)
	end)
else
	net.Receive('MultiColorRainbow.Apply', function(len, ply)
		local SelectTable = GTools.ReadEntityList()
		
		local STEP = tonumber(ply:GetInfo('multicolour_rainbow_step')) or 2
		local MULTIP = tonumber(ply:GetInfo('multicolour_rainbow_step_mult')) or 1
		
		local color_fx = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_color_fx') or 0) or 0
		local color_mode = tonumber(ply:GetInfo(CURRENT_TOOL_MODE .. '_color_mode') or 0) or 0
		
		for i, ent in ipairs(SelectTable) do
			if not IsValid(ent) then continue end
			
			if not CanUse(ply, ent) then continue end
			local new = Color(math.sin(i * MULTIP) * 127 + 128, math.sin((i + STEP) * MULTIP) * 127 + 128, math.sin((i + STEP * 2) * MULTIP) * 127 + 128)
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
	
	net.Receive('MultiColorRainbow.ClearColors', function(len, ply)
		local SelectTable = GTools.ReadEntityList()
		
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
			net.Start('MultiColorRainbow.Clear')
			net.Send(self:GetOwner())
		else
			net.Start('MultiColorRainbow.ClearColors')
			net.Send(self:GetOwner())
		end
	end
	
	return true
end

function TOOL:RightClick(tr)
	if SERVER then
		net.Start('MultiColorRainbow.Apply')
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
			net.Start('MultiColorRainbow.Select')
			net.WriteEntity(ent)
			net.Send(self:GetOwner())
		else
			local new = GTools.GenericAutoSelect(self, tr)
			
			net.Start('MultiColorRainbow.MultiSelect')
			GTools.WriteEntityList(new)
			net.Send(self:GetOwner())
		end
	end
	
	return true
end

TOOL.BuildCPanel = RebuildPanel
