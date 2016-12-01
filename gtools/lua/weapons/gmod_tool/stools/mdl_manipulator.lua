
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

local CURRENT_TOOL_MODE = 'mdl_manipulator'
local CURRENT_TOOL_MODE_VARS = CURRENT_TOOL_MODE .. '_'

TOOL.Name = 'Model Manipulator'
TOOL.Category = 'Construction'

if CLIENT then
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', TOOL.Name)
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'Manipulate with models')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.0', '')
	
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left', 'Apply a model')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right', 'Select a model')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload', '(Try to) Reset entity model')
end

TOOL.ClientConVar = {
	phys = 1,
	awake = 1,
	keep_mass = 1,
	freeze = 0,
	force_phys = 0,
	model = '',
}

TOOL.Information = {
	{name = 'left'},
	{name = 'right'},
	{name = 'reload'},
}

function TOOL.BuildCPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	Panel:CheckBox('Re-init physics object', 'mdl_manipulator_phys')
	Panel:CheckBox('Wake up physics object', 'mdl_manipulator_awake')
	Panel:CheckBox('Freeze physics object', 'mdl_manipulator_freeze')
	Panel:CheckBox('Keep original mass', 'mdl_manipulator_keep_mass')
	
	local lab = Label('Next needs admin rights', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)
	Panel:CheckBox('Force Re-init physics object', 'mdl_manipulator_force_phys')
	
	Panel:TextEntry('Model path', 'mdl_manipulator_model')
end

local SCREEN_MODEL
local LAST_DRAW = 0

if CLIENT then
	hook.Add('Think', CURRENT_TOOL_MODE, function()
		if not IsValid(SCREEN_MODEL) then return end
		
		if LAST_DRAW < RealTime() then
			SCREEN_MODEL:Remove()
		end
	end)
	
	surface.CreateFont('MDL_Manip', {
		font = 'Roboto',
		size = 24,
		weight = 800,
	})
end

function TOOL:DrawHUD()
	local sw, sh = ScrW(), ScrH()
	local w, h = 192, 192
	
	surface.SetDrawColor(0, 0, 0)
	surface.DrawRect(sw - w, 0, w, h)
	
	local mdl = self:GetModel()
	
	if mdl == '' then
		draw.DrawText('No model selected', 'MDL_Manip', sw - w / 2, h / 2 - 10, color_white, TEXT_ALIGN_CENTER)
	elseif not util.IsValidModel(mdl) then
		draw.DrawText('Invalid model', 'MDL_Manip', sw - w / 2, h / 2 - 10, color_white, TEXT_ALIGN_CENTER)
	else
		LAST_DRAW = RealTime() + 1
		
		if not IsValid(SCREEN_MODEL) then
			SCREEN_MODEL = ClientsideModel(mdl, RENDERGROUP_BOTH)
			SCREEN_MODEL:SetNoDraw(true)
		end
		
		local lAng = EyeAngles()
		
		local oAng = SCREEN_MODEL:GetAngles()
		oAng.y = oAng.y + FrameTime() * 20
		
		oAng.p = Lerp(0.03, oAng.p, lAng.p)
		
		SCREEN_MODEL:SetModel(mdl)
		SCREEN_MODEL:SetAngles(oAng)
		
		cam.Start3D(Vector(-70 + math.sin(RealTime()) * 10), Angle(0, 0, 0), 90, sw - w, 0, w, h)
		SCREEN_MODEL:DrawModel()
		cam.End3D()
	end
end

function TOOL:GetModel()
	return self:GetClientInfo('model', '')
end

function TOOL:SetModel(var)
	if CLIENT then
		RunConsoleCommand('mdl_manipulator_model', var)
	else
		self:GetOwner():ConCommand('mdl_manipulator_model ' .. var)
	end
end

function TOOL:RightClick(tr)
	local ent = tr.Entity
	if not IsValid(ent) then return false end
	if ent:IsRagdoll() then return false end
	self:SetModel(ent:GetModel())
	
	if SERVER then
		GTools.PChatPrint(self:GetOwner(), 'Model selected!')
	end
	
	return true
end

function TOOL:GetVars()
	local vars, bools = {}, {}
	
	for k, v in pairs(self.ClientConVar) do
		vars[k] = self:GetClientNumber(k, v)
		bools[k] = tobool(vars[k])
	end
	
	return vars, bools
end

function TOOL:CanManipulate(ent)
	if not IsValid(ent) then return false end
	if ent:IsPlayer() then return false end
	if ent:IsRagdoll() then return false end
	if ent:GetSolid() == SOLID_NONE then return false end
	if IsValid(ent:GetParent()) then return false end
	if not CLIENT and ent:CreatedByMap() then return false end
	return true
end

local function OnDupePost(ply, ent, data)
	ent.__MDL_Manipulator_oldModel = data.OriginalModel
	ent.__MDL_Manipulator_newModel = data.Model
	
	ent:SetModel(data.Model)
	
	local oldPhys = ent:GetPhysicsObject()
	
	if oldPhys:IsValid() and (data.phys and ent:GetSolid() == SOLID_VPHYSICS or ply:IsAdmin() and data.force_phys) then
		local oldMass = data.mass or oldPhys:IsValid() and oldPhys:GetMass() or 1
		
		ent:PhysicsInit(SOLID_VPHYSICS)
		local phys = ent:GetPhysicsObject()
		
		if phys:IsValid() then
			if data.keep_mass then
				phys:SetMass(oldMass)
			end
		end
	end
end

local function OnDupe(ply, ent, data)
	if not data then return end
	if not data.valid then return end
	
	if not util.IsValidModel(data.Model) or not util.IsValidProp(data.Model) then
		GTools.PChatPrint(ply, 'Model of entity you pasted is not valid on serverside!')
		return
	end
	
	local can = hook.Run('PlayerSpawnObject', ply, data.Model, 0)
	
	if can == false then
		GTools.PChatPrint(ply, 'Server is not allowing to use model of entity you pasted!')
		return
	end
	
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		if not IsValid(ply) then return end
		OnDupePost(ply, ent, data)
	end)
end

duplicator.RegisterEntityModifier('mdl_manipulator', OnDupe)

function TOOL:LeftClick(tr)
	local ent = tr.Entity
	if not self:CanManipulate(ent) then return false end
	if self:GetModel() == '' then return false end
	if CLIENT then return true end
	
	if not util.IsValidModel(self:GetModel()) then
		GTools.PChatPrint(self:GetOwner(), 'Model you specified is not valid on serverside!')
		return false
	end
	
	if not util.IsValidProp(self:GetModel()) then
		GTools.PChatPrint(self:GetOwner(), 'Model is not a valid prop on serverside!')
		return false
	end
	
	local vars, bools = self:GetVars()
	
	local can = hook.Run('PlayerSpawnObject', self:GetOwner(), self:GetModel(), 0)
	
	if can == false then
		GTools.PChatPrint(self:GetOwner(), 'Server is not allowing to use this model!')
		return false
	end
	
	ent.__MDL_Manipulator_oldModel = ent.__MDL_Manipulator_oldModel or ent:GetModel()
	ent.__MDL_Manipulator_newModel = self:GetModel()
	ent:SetModel(self:GetModel())
	
	local dataToStore = {
		valid = true,
		Model = self:GetModel(),
		OriginalModel = ent.__MDL_Manipulator_oldModel,
		awake = bools.awake,
		keep_mass = bools.keep_mass,
		phys = bools.phys,
		force_phys = bools.force_phys,
	}
	
	local oldPhys = ent:GetPhysicsObject()
	
	if oldPhys:IsValid() and (bools.phys and ent:GetSolid() == SOLID_VPHYSICS or self:GetOwner():IsAdmin() and bools.force_phys) then
		local oldMotion = oldPhys:IsValid() and oldPhys:IsMotionEnabled() or false
		local oldMass = oldPhys:IsValid() and oldPhys:GetMass() or 1
		
		ent:PhysicsInit(SOLID_VPHYSICS)
		local phys = ent:GetPhysicsObject()
		
		if oldPhys:IsValid() then
			dataToStore.mass = oldMass
		else
			dataToStore.mass = phys:IsValid() and phys:GetMass() or 1
		end
		
		if phys:IsValid() then
			if bools.awake then
				phys:Wake()
			end
			
			if bools.keep_mass then
				phys:SetMass(oldMass)
			end
			
			if bools.freeze then
				phys:EnableMotion(false)
			else
				phys:EnableMotion(oldMotion)
			end
		end
	end
	
	duplicator.StoreEntityModifier(ent, 'mdl_manipulator', dataToStore)
	
	return true
end

function TOOL:Reload(tr)
	local ent = tr.Entity
	if not self:CanManipulate(ent) then return false end
	if CLIENT then return true end
	if not ent.__MDL_Manipulator_oldModel then return true end
	if ent.__MDL_Manipulator_newModel ~= ent:GetModel() then
		ent.__MDL_Manipulator_newModel = ent:GetModel()
		ent.__MDL_Manipulator_oldModel = ent:GetModel()
		return true
	end
	
	local vars, bools = self:GetVars()
	
	ent:SetModel(ent.__MDL_Manipulator_oldModel)
	ent.__MDL_Manipulator_newModel = nil
	ent.__MDL_Manipulator_oldModel = nil
	
	local oldphys = ent:GetPhysicsObject()
	
	if oldphys:IsValid() and (bools.phys and ent:GetSolid() == SOLID_VPHYSICS or self:GetOwner():IsAdmin() and bools.force_phys) then
		local oldMotion = oldphys:IsMotionEnabled()
		local oldMass = oldphys:GetMass() or 1
		
		ent:PhysicsInit(SOLID_VPHYSICS)
		local phys = ent:GetPhysicsObject()
		
		if phys:IsValid() then
			if bools.awake then
				phys:Wake()
			end
			
			if bools.keep_mass then
				phys:SetMass(oldMass)
			end
			
			if bools.freeze then
				phys:EnableMotion(false)
			else
				phys:EnableMotion(oldMotion)
			end
		end
	end
	
	duplicator.StoreEntityModifier(ent, 'mdl_manipulator', {})
	
	return true
end
