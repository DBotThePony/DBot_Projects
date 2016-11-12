
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

local CURRENT_TOOL_MODE = 'admin_remover'
local CURRENT_TOOL_MODE_VARS = 'admin_remover_'

TOOL.Name = 'Admin Remover'
TOOL.Category = 'Construction'

if CLIENT then
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', 'Admin remover')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'Total dissolve tool (admin only)')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.0', '')
	
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left', 'Dissolve stuff')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right', 'Check stuff')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload', 'Check and print stuff')
end

TOOL.Information = {
	{name = 'left'},
	{name = 'right'},
	{name = 'reload'},
}

TOOL.ClientConVar = {
	select_r = 0,
	select_g = 255,
	select_b = 255,
	
	range = 64,
	mode = 0,
	safe = 1,
	protected = 1,
	only_owned = 0,
	
	vehicles = 1,
	props = 1,
	ragdolls = 1,
	funcs = 0,
	map_ents = 0,
	weapons = 1,
	npcs = 1,
	constraints = 1,
}

local ClientConVar = TOOL.ClientConVar

function TOOL:GrabCVars()
	local vars = {}
	local bools = {}
	
	for k, v in pairs(self.ClientConVar) do
		vars[k] = self:GetClientNumber(k, v)
		bools[k] = tobool(self:GetClientNumber(k, v))
	end
	
	if not bools.safe then
		bools.protected = false
	end
	
	return vars, bools
end

function TOOL:SelectEntities(tr)
	local ply = self:GetOwner()
	if not ply:IsAdmin() then return {} end
	local sadmin = ply:IsSuperAdmin()
	
	local vars, bools = self:GrabCVars()
	
	local output = {}
	
	local find = ents.FindInSphere(tr.HitPos, vars.range)
	
	for i, ent in ipairs(find) do
		if ent ~= ply and (not bools.safe or (ent:IsValid() or sadmin) and (not ent:IsPlayer() or sadmin)) and not ent:GetNWBool('REMOVING') then
			local class = ent:GetClass()
			
			local cond = (bools.vehicles or not ent:IsVehicle()) and
				(not bools.safe or not class:StartWith('predicted_')) and
				(bools.ragdolls or not ent:IsRagdoll()) and
				(CLIENT or bools.map_ents or not ent.CreatedByMap or not ent:CreatedByMap()) and
				(not bools.protected or not ent:IsWeapon() or not ent:GetOwner():IsValid()) and
				(not bools.only_owned or not ent.CPPIGetOwner or not IsValid(ent:CPPIGetOwner())) and
				(bools.funcs or not class:StartWith('func_')) and
				(bools.props or not class:StartWith('prop_phys')) and
				(bools.weapons or not ent:IsWeapon()) and
				(CLIENT or bools.constraints or not ent.IsConstraint or not ent:IsConstraint()) and
				(bools.npcs or not ent:IsNPC())
			
			local onlySAdmin = class:StartWith('predicted_')
			
			if not sadmin then
				cond = cond and not onlySAdmin
			end
			
			if cond then
				table.insert(output, ent)
			end
		end
	end
	
	return output
end

local VarsBools = {
	{'safe', 'Safe remove (don\'t touch players, etc.)'},
	{'protected', 'Protected remove (don\'t touch owned weapons, etc)'},
	{'only_owned', 'Remove only owned entities (Needs Prop Protection with CPPI)'},
	{'vehicles', 'Remove vehicles'},
	{'props', 'Remove props'},
	{'ragdolls', 'Remove ragdolls'},
	{'funcs', 'Remove func entities (map entities)'},
	{'weapons', 'Remove weapons'},
	{'npcs', 'Remove NPCs'},
	{'constraints', 'Remove Constraints'},
}

function TOOL.BuildCPanel(Panel)
	Panel:NumSlider('Range', CURRENT_TOOL_MODE_VARS .. 'range', 0, 512, 0)
	
	for k, v in ipairs(VarsBools) do
		Panel:CheckBox(v[2], CURRENT_TOOL_MODE_VARS .. v[1]):SetTooltip(v[2])
	end
	
	local button = Panel:Button('Reset settings')
	
	function button:DoClick()
		for k, v in pairs(ClientConVar) do
			RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. k, v)
		end
	end
	
	local Lab = Label('Highlight color')
	Lab:SetDark(true)
	Panel:AddItem(Lab)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE_VARS .. 'select_r')
	mixer:SetConVarG(CURRENT_TOOL_MODE_VARS .. 'select_g')
	mixer:SetConVarB(CURRENT_TOOL_MODE_VARS .. 'select_b')
	mixer:SetAlphaBar(false)
end

local MAT

function TOOL:DrawHUD()
	if not LocalPlayer():IsAdmin() then return end
	MAT = MAT or Material('models/wireframe')
	local tr = LocalPlayer():GetEyeTrace()
	local select = self:SelectEntities(tr)
	
	local vars = self:GrabCVars()
	
	local r, g, b = vars.select_r, vars.select_g, vars.select_b
	
	cam.Start3D()
	render.SetMaterial(MAT)
	
	local detail = math.Clamp(math.ceil(vars.range / 8), 15, 150)
	
	render.DrawSphere(tr.HitPos, vars.range, detail, detail, Color(r, g, b))
	
	for i, ent in ipairs(select) do
		render.SetColorModulation(r / 255, g / 255, b / 255)
		ent:DrawModel()
	end
	
	render.SetColorModulation(1, 1, 1)
	cam.End3D()
end

function TOOL:LeftClick(tr)
	if not self:GetOwner():IsAdmin() then return false end
	if CLIENT then return true end
	
	local select = self:SelectEntities(tr)
	
	for i, ent in ipairs(select) do
		local data = EffectData()
		data:SetOrigin(ent:GetPos())
		data:SetEntity(ent)
		util.Effect('entity_remove', data, true, true)
		
		ent:SetSolid(SOLID_NONE)
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetNoDraw(true)
		ent:SetNWBool('REMOVING', true)
	end
	
	timer.Simple(1, function()
		for i, ent in ipairs(select) do
			if IsValid(ent) then
				ent:Remove()
			end
		end
	end)
	
	GTools.PChatPrint(self:GetOwner(), 'Removed ' .. #select .. ' entities')
	
	return true
end

function TOOL:RightClick(tr)
	if not self:GetOwner():IsAdmin() then return false end
	if CLIENT then return true end
	
	local select = self:SelectEntities(tr)
	
	GTools.PChatPrint(self:GetOwner(), 'Counted ' .. #select .. ' entities to be removed!')
	
	return true
end

function TOOL:Reload(tr)
	local ply = self:GetOwner()
	if not ply:IsAdmin() then return false end
	if CLIENT then return true end
	
	local select = self:SelectEntities(tr)
	
	GTools.PChatPrint(ply, 'Counted ' .. #select .. ' entities to be removed! Look into console for the list')
	
	for i, ent in ipairs(select) do
		GTools.PConsolePrint(ply, 'Entity #' .. i .. '. Data: ' .. tostring(ent) .. ', class: ' .. ent:GetClass())
	end
	
	return true
end
