
--[[
Copyright (C) 2016-2018 DBot

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

local CURRENT_TOOL_MODE = 'multitool_parent'

local HALP = 'Controls:\nLeft Click - select-unselect\nRight Click - apply\nReload - clear selection\nReload + USE - clear parents and unselect them.\nLeft Click + USE - auto-select'

if SERVER then
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Select')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.MultiSelect')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Clear')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.MultiClear')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.Apply')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.reload_shift')
else
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', 'Multi-Parent or Unparent')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'Sets Source Engine parents of entities')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.0', '')

	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left', 'Left Click - select-unselect')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left_use', 'USE + Left Click - auto-select')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right', 'Right Click - apply')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload', 'Reload - clear selection')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload_use', 'USE + Reload - clear parents and unselect them')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload_shift', 'SHIFT + Reload - unparent all childs')
end

TOOL.Information = {
	{name = 'left'},
	{name = 'right'},
	{name = 'left_use'},
	{name = 'reload'},
	{name = 'reload_use'},
	{name = 'reload_shift'},
}

local SelectTable = {}

TOOL.Name = 'Multi-Parent or Unparent'
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
	if ent:IsVehicle() then return false end
	if ent:IsNPC() then return false end
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

	surface.SetTextPos(ScrWL() / 2 - w / 2, 180)
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
		net.WriteEntity(net.ReadEntity())
		net.SendToServer()

		SelectTable = {}
		GTools.ChatPrint('Selection is about to be Applied!')
	end)

	net.Receive(CURRENT_TOOL_MODE .. '.MultiClear', function()
		GTools.GenericTableClear(SelectTable)

		net.Start(CURRENT_TOOL_MODE .. '.MultiClear')
		net.WriteTable(SelectTable)
		net.SendToServer()

		SelectTable = {}
		GTools.ChatPrint('Clearing all no-collide constraints and select table')
	end)

	net.Receive(CURRENT_TOOL_MODE .. '.MultiSelect', function()
		GTools.GenericMultiselectReceive(SelectTable, cvar)
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
		local parentTo = net.ReadEntity()

		if not IsValid(parentTo) then return end

		for i, ent in ipairs(SelectTable) do
			if ent ~= parentTo and CanUse(ply, ent) then
				ent:SetParent(parentTo)
			end
		end
	end)

	net.Receive(CURRENT_TOOL_MODE .. '.MultiClear', function(len, ply)
		local SelectTable = net.ReadTable()

		for i, ent in ipairs(SelectTable) do
			if not CanUse(ply, ent) then continue end
			ent:SetParent(NULL)
		end
	end)
end

function TOOL:Reload(tr)
	local ply = self:GetOwner()

	if ply:KeyDown(IN_SPEED) then
		if not CanUse(ply, tr.Entity) then return false end

		if SERVER then
			local get = tr.Entity:GetChildren()

			for k, ent in pairs(get) do
				ent:SetParent(NULL)
			end

			ply:ChatPrint('All children unparented')
		end

		return true
	end

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
	if not IsValid(tr.Entity) then return false end
	if tr.Entity:IsPlayer() then return false end
	if tr.Entity:IsVehicle() then return false end
	if tr.Entity:IsNPC() then return false end

	if SERVER then
		net.Start(CURRENT_TOOL_MODE .. '.Apply')
		net.WriteEntity(tr.Entity)
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
