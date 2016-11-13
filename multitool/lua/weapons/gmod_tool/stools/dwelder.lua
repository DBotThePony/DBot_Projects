
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

local CURRENT_TOOL_MODE = 'dwelder'
local CURRENT_TOOL_MODE_VARS = CURRENT_TOOL_MODE .. '_'

TOOL.Name = 'DWelder'
TOOL.Category = 'Constraints'

if CLIENT then
	language.Add('Undone_DWeld', 'Undone DWeld')
	
	language.Add('tool.dwelder.name', 'DWelder')
	language.Add('tool.dwelder.desc', 'Welds multiple entities at once')
	language.Add('tool.dwelder.0', '')
	
	language.Add('tool.dwelder.left', 'Select/deselect')
	language.Add('tool.dwelder.left_use', 'Multiselect')
	language.Add('tool.dwelder.right', 'Weld')
	language.Add('tool.dwelder.reload', 'Clear selection')
else
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.select')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.mselect')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.apply')
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.clear')
end

TOOL.Information = {
	{name = 'left'},
	{name = 'left_use'},
	{name = 'right'},
	{name = 'reload'},
}

TOOL.ClientConVar = {
	forcelimit = 0,
	nocollide = 1,
	nocollide_dist = 200,
	max_nocollide = 3,
	max_weld = 3,
	should_freeze = 0,
	
	select_r = 0,
	select_g = 200,
	select_b = 0,
}

local ClientConVar = TOOL.ClientConVar
GTools.AddAutoSelectConVars(TOOL.ClientConVar)

TOOL.ClientConVar.select_only_constrained = 0

function TOOL.BuildCPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	Panel:CheckBox('Freeze before weld', 'dwelder_should_freeze')
	Panel:CheckBox('No Collide', 'dwelder_nocollide')
	Panel:NumSlider('No Collide max distance', 'dwelder_nocollide_dist', 1, 600)
	Panel:NumSlider('No Collide max count', 'dwelder_max_nocollide', 1, 10, 0)
	Panel:NumSlider('Weld max count', 'dwelder_max_weld', 1, 10, 0)
	Panel:NumSlider('Force limit', 'dwelder_forcelimit', 0, 4000)
	
	GTools.AutoSelectOptions(Panel, CURRENT_TOOL_MODE)
	
	local lab = Label('Entity select color', Panel)
	lab:SetDark(true)
	Panel:AddItem(lab)
	
	local pick = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(pick)
	pick:SetConVarR('dwelder_select_r')
	pick:SetConVarG('dwelder_select_g')
	pick:SetConVarB('dwelder_select_b')
	pick:SetAlphaBar(false)
end

local function CanUse(ply, ent)
	if not IsValid(ent) then return false end
	if ent:GetSolid() ~= SOLID_VPHYSICS and ent:GetSolid() ~= SOLID_BBOX then return false end
	if ent:IsPlayer() then return false end
	if ent:IsNPC() then return false end
	if ent:IsRagdoll() then return false end
	if ent:IsWeapon() then return false end
	if IsValid(ent:GetOwner()) then return false end --Nuh uh. Don't weld parented entities.
	if ent.CPPICanTool and not ent:CPPICanTool(ply, 'dwelder') then return false end
	return true
end

local SELECTED = {}

function TOOL:CanUseEntity(ent)
	return CanUse(self:GetOwner(), ent)
end

function TOOL:GetCounts()
	return #SELECTED
end

function TOOL:MuliSelect(tr)
	net.Start(CURRENT_TOOL_MODE .. '.mselect')
	GTools.WriteEntityList(GTools.GenericAutoSelect(self, tr))
	net.Send(self:GetOwner())
end

if CLIENT then
	surface.CreateFont('DWelder.Screen', {
		font = 'Roboto',
		size = 50,
		weight = 600,
	})
	
	local cvar = {}
	
	for k, v in pairs(TOOL.ClientConVar) do
		cvar[k] = CreateConVar(CURRENT_TOOL_MODE_VARS .. k, tostring(v), {FCVAR_ARCHIVE, FCVAR_USERINFO}, '')
	end
	
	net.Receive(CURRENT_TOOL_MODE .. '.apply', function()
		GTools.GenericTableClear(SELECTED)
		
		net.Start(CURRENT_TOOL_MODE .. '.apply')
		GTools.WriteEntityList(SELECTED)
		net.SendToServer()
		
		SELECTED = {}
		
		GTools.ChatPrint('Selection is about to be processed!')
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.clear', function()
		SELECTED = {}
		
		GTools.ChatPrint('Selection cleared')
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.select', function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		
		for k, v in ipairs(SELECTED) do
			if v == ent then
				table.remove(SELECTED, k)
				return
			end
		end
		
		table.insert(SELECTED, ent)
	end)
	
	net.Receive(CURRENT_TOOL_MODE .. '.mselect', function()
		GTools.GenericMultiselectReceive(SELECTED, cvar)
	end)
	
	hook.Add('PostDrawWorldToolgun', CURRENT_TOOL_MODE, function(ply, weapon, mode)
		if mode ~= CURRENT_TOOL_MODE then return end
		
		GTools.GenericTableClear(SELECTED)
		
		local r = cvar.select_r:GetInt() / 255
		local g = cvar.select_g:GetInt() / 255
		local b = cvar.select_b:GetInt() / 255
		
		for i, ent in ipairs(SELECTED) do
			render.SetColorModulation(r, g, b)
			ent:DrawModel()
		end
		
		render.SetColorModulation(1, 1, 1)
	end)
else
	local POS_MEM = {}

	local function CustomSorter(tab, pos)
		for i = #tab, 2, -1 do
			local a = tab[i - 1]
			local b = tab[i]
			
			local posa = POS_MEM[a] or a:GetPos()
			local posb = POS_MEM[b] or b:GetPos()
			POS_MEM[a] = posa
			POS_MEM[b] = posb
			
			if posa:DistToSqr(pos) > posb:DistToSqr(pos) then
				tab[i - 1] = b
				tab[i] = a
			end
		end
	end

	local function CreateSortedTable(tab, pos, filter)
		local sorted = {}
		
		for k = 1, #tab do
			if tab[k] ~= filter then
				table.insert(sorted, tab[k])
			end
		end
		
		CustomSorter(sorted, pos)
		
		return sorted
	end
	
	net.Receive(CURRENT_TOOL_MODE .. '.apply', function(len, ply)
		local T = SysTime()
		
		local vars = {}
		local bools = {}
		
		for k, v in pairs(ClientConVar) do
			local get = ply:GetInfo(CURRENT_TOOL_MODE_VARS .. k)
			
			if not get then
				vars[k] = v
			else
				vars[k] = tonumber(get) or v
			end
			
			bools[k] = tobool(vars[k])
		end
		
		local read = GTools.ReadEntityList()
		local objects = {}
		
		for i, ent in ipairs(read) do
			if CanUse(ply, ent) then
				table.insert(objects, ent)
			end
		end
		
		POS_MEM = {}
		
		undo.Create('DWeld')
		
		local welds = {}
		local collides = {}
		
		local ENT_MEM_WELD = {}
		local ENT_MEM_COLLIDE = {}
		
		if bools.should_freeze then
			for k = 1, #objects do
				local ent = objects[k]
				local phys = ent:GetPhysicsObject()
				if not IsValid(phys) then continue end
				phys:EnableMotion(false)
			end
		end
		
		for k = 1, #objects do
			local ent = objects[k]
			local sorted = CreateSortedTable(objects, ent:GetPos(), ent)
			
			local Index = ent:EntIndex()
			
			local hits = 0
			
			for i = 1, #sorted do
				local v = sorted[i]
				if ENT_MEM_WELD[Index .. ' ' .. v:EntIndex()] then continue end
				if ENT_MEM_WELD[v:EntIndex() .. ' ' .. Index] then continue end
				
				if hits >= vars.max_weld then break end
				local weld = constraint.Weld(ent, v, 0, 0, vars.forcelimit, vars.nocollide)
				
				ENT_MEM_WELD[Index .. ' ' .. v:EntIndex()] = true
				ENT_MEM_WELD[v:EntIndex() .. ' ' .. Index] = true
				
				if weld then
					table.insert(welds, weld)
					undo.AddEntity(weld)
					hits = hits + 1
				end
			end
			
			if bools.nocollide then
				local hits = 0
				
				local lpos = ent:GetPos()
				
				for i = 1, #sorted do
					local v = sorted[i]
					if ENT_MEM_COLLIDE[Index .. ' ' .. v:EntIndex()] then continue end
					if ENT_MEM_COLLIDE[v:EntIndex() .. ' ' .. Index] then continue end
					
					if v:GetPos():Distance(lpos) > vars.nocollide_dist then break end
					if hits >= vars.max_nocollide then break end
					
					local collide = constraint.NoCollide(ent, v, 0, 0)
					
					ENT_MEM_COLLIDE[Index .. ' ' .. v:EntIndex()] = true
					ENT_MEM_COLLIDE[v:EntIndex() .. ' ' .. Index] = true
					
					if collide then
						table.insert(collides, collide)
						undo.AddEntity(collide)
						hits = hits + 1
					end
				end
			end
		end
		
		undo.SetPlayer(ply)
		undo.Finish()
		
		local total = (SysTime() - T) * 1000
		local ms = math.floor(total * 100) / 100
		
		GTools.PChatPrint(ply, 'Total weld constraints created: ' .. #welds)
		GTools.PChatPrint(ply, 'Total no-collide constraints created: ' .. #collides)
		GTools.PChatPrint(ply, 'Done in ' .. ms .. ' milliseconds')
	end)
end

function TOOL:DrawToolScreen(w, h)
	local count = self:GetCounts()
	
	draw.NoTexture()
	surface.SetDrawColor(0, 0, 0)
	surface.DrawRect(0, 0, w, h)
	
	draw.DrawText('DWelder\n\nSelected\nentities:\n' .. count, 'DWelder.Screen', w / 2, 0, color_white, TEXT_ALIGN_CENTER )
end

function TOOL:LeftClick(tr)
	local ply = self:GetOwner()
	local use = ply:KeyDown(IN_USE)
	
	local ent = tr.Entity
	if not use and not self:CanUseEntity(ent) then return false end
	
	if CLIENT then return true end
	
	if use then
		self:MuliSelect(tr)
		return true
	end
	
	net.Start(CURRENT_TOOL_MODE .. '.select')
	net.WriteEntity(ent)
	net.Send(ply)
	
	return true
end

function TOOL:RightClick(tr)
	if CLIENT then return true end
	
	net.Start(CURRENT_TOOL_MODE .. '.apply')
	net.Send(self:GetOwner())
	
	return true
end

function TOOL:Reload()
	if CLIENT then return true end
	
	net.Start(CURRENT_TOOL_MODE .. '.clear')
	net.Send(self:GetOwner())
	
	return true
end
