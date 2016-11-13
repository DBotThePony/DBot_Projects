
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

TOOL.Name = 'DWelder'
TOOL.Category = 'Constraints'
TOOL.Name = 'DWelder'

TOOL.ClientConVar = {
	forcelimit = 0,
	nocollide = 1,
	nocollide_dist = 200,
	max_nocollide = 3,
	max_weld = 3,
	autoselect_radius = 400,
	should_freeze = 0,
	select_mode = 0,
	select_r = 0,
	select_g = 200,
	select_b = 0,
}

local function CanTool(ent, ply)
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

function TOOL:UpdateCounts()
	self:GetWeapon():SetNWInt('DWelder.Count', table.Count(self.OBJECTS))
end

function TOOL:GetSelectColor()
	return Color(self:GetClientNumber('select_r', 0), self:GetClientNumber('select_g', 200), self:GetClientNumber('select_b', 0))
end

function TOOL:GetCounts()
	return self:GetWeapon():GetNWInt('DWelder.Count')
end

function TOOL:UnselectObject(ent)
	self.OBJECTS = self.OBJECTS or {}
	self.OBJECTS[ent] = nil
	
	if ent.DWelder_OldColor then
		ent:SetColor(ent.DWelder_OldColor)
		ent.DWelder_OldColor = nil
	end
end

function TOOL:IsSelcted(ent)
	self.OBJECTS = self.OBJECTS or {}
	return self.OBJECTS[ent] ~= nil
end

function TOOL:SelectObject(ent)
	self.OBJECTS = self.OBJECTS or {}
	
	self.OBJECTS[ent] = ent
	ent.DWelder_OldColor = ent.DWelder_OldColor or ent:GetColor()
	ent:SetColor(self:GetSelectColor())
end

function TOOL:MuliSelect(tr)
	local dist = self:GetClientNumber('autoselect_radius', 400)
	
	local Ents
	
	if not tobool(self:GetClientNumber('select_mode', 0)) then
		Ents = ents.FindInSphere(tr.HitPos, dist)
	else
		Ents = ents.FindInBox(tr.HitPos, dist)
	end
	
	local ply = self:GetOwner()
	
	local count = 0
	
	for k, v in pairs(Ents) do
		if self:IsSelcted(v) then continue end
		if CanTool(v, ply) then
			self:SelectObject(v)
			count = count + 1
		end
	end
	
	self:UpdateCounts()
	self:GetOwner():ChatPrint('Selected ' .. count .. ' entities')
end

if CLIENT then
	surface.CreateFont('DWelder.Screen', {
		font = 'Roboto',
		size = 50,
		weight = 600,
	})
end

function TOOL:DrawToolScreen(w, h)
	local count = self:GetCounts()
	
	draw.NoTexture()
	surface.SetDrawColor(0, 0, 0)
	surface.DrawRect(0, 0, w, h)
	
	draw.DrawText('DWelder\n\nSelected\nentities:\n' .. count, 'DWelder.Screen', w / 2, 0, color_white, TEXT_ALIGN_CENTER )
end

function TOOL:LeftClick(tr)
	self.OBJECTS = self.OBJECTS or {}
	local ent = tr.Entity
	if not CanTool(ent, self:GetOwner()) then return false end
	
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	
	if ply:KeyDown(IN_USE) then self:MuliSelect(tr) return true end
	
	local isSelected = self:IsSelcted(ent)
	
	if not isSelected then
		self:SelectObject(ent)
	else
		self:UnselectObject(ent)
	end
	
	self:RefreshObjects()
	
	return true
end

function TOOL:RefreshObjects()
	self.OBJECTS = self.OBJECTS or {}
	
	for k, v in pairs(self.OBJECTS) do
		if not IsValid(v) then
			self.OBJECTS[k] = nil
		end
	end
	
	self:UpdateCounts()
end

local POS_MEM = {}

local function CustomSorter(tab, pos)
	for i = 1, #tab - 1 do
		local a = tab[i]
		local b = tab[i + 1]
		
		local posa = POS_MEM[a] or a:GetPos()
		local posb = POS_MEM[b] or b:GetPos()
		POS_MEM[a] = posa
		POS_MEM[b] = posb
		
		if posa:DistToSqr(pos) > posb:DistToSqr(pos) then
			tab[i] = b
			tab[i + 1] = a
		end
	end
end

local function CreateSortedTable(tab, pos, filter)
	local sorted = {}
	
	for k, v in pairs(tab) do
		if v == filter then continue end
		table.insert(sorted, v)
	end
	
	CustomSorter(sorted, pos)
	
	return sorted
end

function TOOL:GetAllVars()
	local reply = {}
	
	for k, v in pairs(self.ClientConVar) do
		reply[k] = self:GetClientNumber(k, v)
	end
	
	return reply
end

function TOOL:DoWeld()
	self:RefreshObjects()
	
	local T = SysTime()
	
	POS_MEM = {}
	
	undo.Create('DWeld')
	
	local welds = {}
	local collides = {}
	
	local ENT_MEM_WELD = {}
	local ENT_MEM_COLLIDE = {}
	
	local vars = self:GetAllVars()
	
	if tobool(vars.should_freeze) then
		for k, ent in pairs(self.OBJECTS) do
			local phys = ent:GetPhysicsObject()
			if not IsValid(phys) then continue end
			phys:EnableMotion(false)
		end
	end
	
	for k, ent in pairs(self.OBJECTS) do
		local sorted = CreateSortedTable(self.OBJECTS, ent:GetPos(), ent)
		
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
		
		if tobool(vars.nocollide) then
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
	
	undo.SetPlayer(self:GetOwner())
	undo.Finish()
	
	return welds, collides, T
end

function TOOL:UnselectAll()
	self.OBJECTS = self.OBJECTS or {}
	
	for k, v in pairs(self.OBJECTS) do
		self:UnselectObject(v)
	end
	
	self:UpdateCounts()
end

function TOOL:RightClick(tr)
	self.OBJECTS = self.OBJECTS or {}
	if CLIENT then return false end
	
	self:RefreshObjects()
	
	local c = table.Count(self.OBJECTS)
	
	if c == 0 then
		self:GetOwner():ChatPrint('No entities to weld!')
	elseif c == 1 then
		self:GetOwner():ChatPrint('Only one entitiy is selected.')
	else
		local welds, collides, time = self:DoWeld()
		local donein = math.floor((SysTime() - time) * 100000) / 100
		self:GetOwner():ChatPrint('Welded ' .. table.Count(self.OBJECTS) .. ' entities.')
		self:GetOwner():ChatPrint('Total weld constraints: ' .. #welds)
		self:GetOwner():ChatPrint('Total nocollide constraints: ' .. #collides)
		self:GetOwner():ChatPrint('Done in: ' .. donein .. ' ms')
		self:UnselectAll()
	end
	
	return false
end

function TOOL:Reload()
	if SERVER then
		self:UnselectAll()
		self:GetOwner():ChatPrint('Selection cleared')
	end
	
	return true
end

function TOOL.BuildCPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	Panel:CheckBox('Freeze before weld', 'dwelder_should_freeze')
	Panel:CheckBox('No Collide', 'dwelder_nocollide')
	Panel:NumSlider('No Collide max distance', 'dwelder_nocollide_dist', 1, 600)
	Panel:NumSlider('No Collide max count', 'dwelder_max_nocollide', 1, 10, 0)
	Panel:NumSlider('Weld max count', 'dwelder_max_weld', 1, 10, 0)
	Panel:NumSlider('Force limit', 'dwelder_forcelimit', 0, 4000)
	Panel:NumSlider('Autoselect radius', 'dwelder_autoselect_radius', 1, 1500)
	Panel:CheckBox('Autoselect mode', 'dwelder_select_mode')
	
	local lab = Label('Autoselect Mode: false - sphere, true - box', Panel)
	Panel:AddItem(lab)
	
	local lab = Label('Entity select color', Panel)
	Panel:AddItem(lab)
	
	local pick = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(pick)
	pick:SetConVarR('dwelder_select_r')
	pick:SetConVarG('dwelder_select_g')
	pick:SetConVarB('dwelder_select_b')
	pick:SetAlphaBar(false)
end

if CLIENT then
	language.Add('Undone_DWeld', 'Undone DWeld')
	language.Add('tool.dwelder.name', 'DWelder')
	language.Add('tool.dwelder.desc', 'Welds multiple entities at once')
	language.Add('tool.dwelder.0', 'Left click to select, Right to weld, hold USE and left click to do multi select. Reload to clear selection.')
end
