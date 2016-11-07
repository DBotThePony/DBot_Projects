
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

if CLIENT then
	language.Add('tool.multifreeze.name', 'Multifreeze')
	language.Add('tool.multifreeze.desc', 'Freeze-unfreeze entities')
	language.Add('tool.multifreeze.0', '')
	
	language.Add('tool.multifreeze.left', 'Freeze selected entities')
	language.Add('tool.multifreeze.right', 'Unfreeze selected entities')
	language.Add('tool.multifreeze.reload', 'Highlight selected entities')
end

TOOL.Name = 'Multi-Freeze'
TOOL.Category = 'Construction'

TOOL.Information = {
	{name = 'left'},
	{name = 'right'},
	{name = 'reload'},
}

TOOL.ClientConVar = {
	select_by_model = 0,
	select_only_constrained = 1,
	select_mode = 0,
	select_by_material = 0,
	select_size = 512,
	
	display_red = 0,
	display_green = 255,
	display_blue = 255,
}

function TOOL.BuildCPanel(Panel)
	Panel:CheckBox('Auto Select only constrained', 'multifreeze_select_only_constrained')
	Panel:CheckBox('Auto Select by Model', 'multifreeze_select_by_model')
	Panel:CheckBox('Auto Select by Material', 'multifreeze_select_by_material')
	Panel:NumSlider('Auto Select Range', 'multifreeze_select_size', 1, 1024, 0)
	Panel:CheckBox('False - Sphere, True - Box', 'multifreeze_select_mode')
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR('multifreeze_display_red')
	mixer:SetConVarG('multifreeze_display_green')
	mixer:SetConVarB('multifreeze_display_blue')
	mixer:SetAlphaBar(false)
end

function TOOL:SelectEntities(tr)
	local vars = {}
	
	for k, v in pairs(self.ClientConVar) do
		vars[k] = self:GetClientNumber(k, v)
	end
	
	vars.select_size = math.Clamp(vars.select_size, 1, 1024)
	
	local bools = {}
	
	for k, v in pairs(vars) do
		bools[k] = tobool(vars[k])
	end
	
	local MEM = {}
	
	if IsValid(tr.Entity) then
		for k, v in pairs(constraint.GetAllConstrainedEntities(tr.Entity)) do
			MEM[v] = v
		end
	end
	
	if not bools.select_only_constrained then
		local MDL, MTRL
		
		if IsValid(tr.Entity) then
			MDL = tr.Entity:GetModel()
			MTRL = tr.Entity:GetMaterial()
		end
		
		for i, ent in ipairs(bools.select_mode and ents.FindInBox(tr.HitPos, vars.select_size) or ents.FindInSphere(tr.HitPos, vars.select_size)) do
			if bools.select_by_material then
				if MTRL ~= ent:GetMaterial() then continue end
			end
			
			if bools.select_by_model then
				if MDL ~= ent:GetModel() then continue end
			end
			
			MEM[ent] = ent
		end
	end
	
	local reply = {}
	
	for k, v in pairs(MEM) do
		local phys = v:GetPhysicsObject()
		
		if phys:IsValid() then
			table.insert(reply, {v, phys})
		end
	end
	
	return reply
end

function TOOL:RightClick(tr)
	if CLIENT then return true end
	
	local get = self:SelectEntities(tr)
	
	for i, v in ipairs(get) do
		v[2]:EnableMotion(true)
		v[2]:Wake()
	end
	
	self:GetOwner():ChatPrint('Unfreezed ' .. #get .. ' physics objects')
	
	return true
end

function TOOL:LeftClick(tr)
	if CLIENT then return true end
	
	local get = self:SelectEntities(tr)
	
	for i, v in ipairs(get) do
		v[2]:EnableMotion(false)
	end
	
	self:GetOwner():ChatPrint('Freezed ' .. #get .. ' physics objects')
	
	return true
end

if SERVER then
	util.AddNetworkString('MultiFreezeTool.ShowUp')
else
	local vars = {}
	
	for k, v in pairs(TOOL.ClientConVar) do
		vars[k] = CreateConVar('multifreeze_' .. k, tostring(v), {FCVAR_USERINFO, FCVAR_ARCHIVE}, '')
	end
	
	local display = 0
	local DisplayTable = {}
	
	net.Receive('MultiFreezeTool.ShowUp', function()
		display = RealTime() + 2
		DisplayTable = {}
		
		local max = net.ReadUInt(12)
		
		for i = 1, max do
			table.insert(DisplayTable, net.ReadEntity())
		end
		
		chat.AddText('Counted ' .. #DisplayTable .. ' physics objects')
	end)
	
	hook.Add('PostDrawWorldToolgun', 'multifreeze', function(ply, weapon, mode)
		if mode ~= 'multifreeze' then return end
		if display < RealTime() then return end
		
		if RealTime() % 0.5 < .25 then return end
		
		local r, g, b = vars.display_red:GetInt() / 255, vars.display_green:GetInt() / 255, vars.display_blue:GetInt() / 255
		
		for i, ent in ipairs(DisplayTable) do
			if not IsValid(ent) then continue end
			render.SetColorModulation(r, g, b)
			ent:DrawModel()
		end
		
		render.SetColorModulation(1, 1, 1)
	end)
end

function TOOL:Reload(tr)
	if CLIENT then return true end
	
	local get = self:SelectEntities(tr)
	
	net.Start('MultiFreezeTool.ShowUp')
	net.WriteUInt(#get, 12)
	
	for i, v in ipairs(get) do
		net.WriteEntity(v[1])
	end
	
	net.Send(self:GetOwner())
	
	return true
end
