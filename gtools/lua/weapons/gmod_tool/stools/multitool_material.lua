
--[[
Copyright (C) 2016-2018 DBot


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

TOOL.ClientConVar = {
	override = 'debug/env_cubemap_model',
}

GTools.AddAutoSelectConVars(TOOL.ClientConVar)

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

	GTools.AutoSelectOptions(Panel, CURRENT_TOOL_MODE)

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
		GTools.ChatPrint('Clearing all materials and select table')
	end)

	net.Receive(CURRENT_TOOL_MODE .. '.MultiSelect', function()
		GTools.GenericMultiselectReceive(SelectTable, cvar)
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

		MatCache[cvar.override:GetString()] = MatCache[cvar.override:GetString()] or Material(cvar.override:GetString())

		for i, ent in ipairs(SelectTable) do
			render.ModelMaterialOverride(MatCache[cvar.override:GetString()])
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
			duplicator.StoreEntityModifier(ent, 'material', {MaterialOverride = mat})
		end
	end)

	net.Receive(CURRENT_TOOL_MODE .. '.MultiClear', function(len, ply)
		local SelectTable = net.ReadTable()

		for i, ent in ipairs(SelectTable) do
			if not CanUse(ply, ent) then continue end
			ent:SetMaterial('')
			duplicator.StoreEntityModifier(ent, 'material', {MaterialOverride = ''})
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
