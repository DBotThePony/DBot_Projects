
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

TOOL.Name = 'Physics Manipulator'
TOOL.Category = 'Construction'

TOOL.Information = {
	{name = 'left'},
	{name = 'left_use'},
	{name = 'right'},
	{name = 'right_use'},
	{name = 'reload'},
}

function TOOL.BuildCPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	local lab = vgui.Create('DLabel', Panel)
	Panel:AddItem(lab)
	lab:SetText('Tool is unfinished, it does nothing')
	lab:SetDark(true)
end

if true then return end

local CURRENT_TOOL_MODE = 'physics_manipulator'

if CLIENT then
	language.Add('tool.physics_manipulator.name', 'Physics Manipulator')
	language.Add('tool.physics_manipulator.desc', 'ALBERT EINSTEIN')
	language.Add('tool.physics_manipulator.0', '')
	
	language.Add('tool.physics_manipulator.left', 'Select a entity (DOESN\'T COPY IT\'S PROPERTIES!)')
	language.Add('tool.physics_manipulator.left_use', 'Apply physics properties on entity and don\'t select it')
	language.Add('tool.physics_manipulator.right', 'Copy properties')
	language.Add('tool.physics_manipulator.right_use', 'Copy properties and paste them on currently selected entity')
	language.Add('tool.physics_manipulator.reload', 'Deselect')
else
	util.AddNetworkString('PhysicsManipulatorTool.SelectEntity')
	util.AddNetworkString('PhysicsManipulatorTool.SelectProperties')
end

TOOL.ClientConVar = {
	select_red = 0,
	select_green = 255,
	select_blue = 255,
	
	buoyancy_ratio = 1,
	drag = 1,
	mass = 100,
	
	motion = 1,
	collisions = 1,
	gravity = 1,
}

local PANEL

function TOOL.BuildCPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	PANEL = Panel
	
	Panel:NumSlider('Drag cofficient', 'physics_manipulator_drag', -10000, 10000, 0)
	Panel:NumSlider('Buoyancy ratio', 'physics_manipulator_drag', -10000, 10000, 0)
	
	Panel:CheckBox('Enable motion', 'physics_manipulator_motion')
	Panel:CheckBox('Enable collisions', 'physics_manipulator_collisions')
	Panel:CheckBox('Enable gravity', 'physics_manipulator_gravity')
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE .. '_select_red')
	mixer:SetConVarG(CURRENT_TOOL_MODE .. '_select_green')
	mixer:SetConVarB(CURRENT_TOOL_MODE .. '_select_blue')
	mixer:SetAlphaBar(false)
end

local Rebuild = TOOL.BuildCPanel

local function CanUse(ply, ent)
	return ply:IsAdmin() and
		IsValid(ent) and
		ent:GetPhysicsObject():IsValid() and
		ent:GetPhysicsObject() ~= Entity(0):GetPhysicsObject() and
		(not ent.CPPICanTool or ent:CPPICanTool(ply, 'physics_manipulator'))
end

if CLIENT then
	local SELECTED_ENTITY
	local IGNORE_CHANGE = false
	
	local vars = {}
	local changeFuncs = {}
	
	for k, v in pairs(TOOL.ClientConVar) do
		vars[k] = CreateConVar('physics_manipulator_' .. k, tostring(v), {FCVAR_ARCHIVE, FCVAR_USERINFO}, '')
		
		changeFuncs[k] = function()
			if IGNORE_CHANGE then return end
			if not IsValid(SELECTED_ENTITY) then return end
			RunConsoleCommand('physics_manipulator_command', SELECTED_ENTITY:EntIndex(), k, vars[k]:GetString())
		end
		
		cvars.AddChangeCallback('physics_manipulator_' .. k, changeFuncs[k], 'physics_manipulator')
	end
	
	hook.Add('PostDrawWorldToolgun', CURRENT_TOOL_MODE, function(ply, weapon, mode)
		if mode ~= CURRENT_TOOL_MODE then return end
		if not IsValid(SELECTED_ENTITY) then return end
		
		local select_red = CVars.select_red:GetInt() / 255
		local select_green = CVars.select_green:GetInt() / 255
		local select_blue = CVars.select_blue:GetInt() / 255
		
		render.SetColorModulation(select_red, select_green, select_blue)
		SELECTED_ENTITY:DrawModel()
		render.SetColorModulation(1, 1, 1)
	end)
	
	net.Receive('PhysicsManipulatorTool.SelectEntity', function()
		local status = net.ReadBool()
		
		if not status then
			SELECTED_ENTITY = nil
		else
			local new = net.ReadEntity()
			local shouldApply = net.ReadBool()
			
			if not IsValid(new) then return end
			
			if shouldApply then
				local old = SELECTED_ENTITY
				SELECTED_ENTITY = new
				
				for k, v in pairs(changeFuncs) do
					v()
				end
				
				SELECTED_ENTITY = old
			else
				SELECTED_ENTITY = new
			end
		end
	end)

	net.Receive('PhysicsManipulatorTool.SelectProperties', function()
		local get = net.ReadTable()
		IGNORE_CHANGE = net.ReadBool()
		
		for k, v in pairs(get) do
			if type(v) == 'boolean' then
				RunConsoleCommand('physics_manipulator_' .. k, v and '1' or '0')
			else
				RunConsoleCommand('physics_manipulator_' .. k, v)
			end
		end
		
		if IGNORE_CHANGE then
			chat.AddText('Properties copied')
		else
			chat.AddText('Properties copied and applied to selected entity')
		end
		
		IGNORE_CHANGE = false
	end)
end

function TOOL:RightClick(tr)
	if not CanUse(tr.Entity, self:GetOwner()) then return false end
	
	if SERVER then
		local phys = tr.Entity:GetPhysicsObject()
		
		local data = {
			buoyancy_ratio = 1,
			drag = 1,
			mass = phys:GetMass(),
			motion = phys:IsMotionEnabled(),
			collisions = phys:IsCollisionEnabled(),
			gravity = phys:IsGravityEnabled(),
		}
		
		net.Start('PhysicsManipulatorTool.SelectProperties')
		
		net.WriteTable(data)
		net.WriteBool(not self:GetOwner():KeyDown(IN_USE))
		
		net.Send(self:GetOwner())
	end
	
	return true
end

function TOOL:LeftClick(tr)
	if not CanUse(tr.Entity, self:GetOwner()) then return false end
	
	if SERVER then
		net.Start('PhysicsManipulatorTool.SelectEntity')
		net.WriteBool(true)
		net.WriteEntity(tr.Entity)
		net.WriteBool(self:GetOwner():KeyDown(IN_USE))
		net.Send(self:GetOwner())
	end
	
	return true
end

function TOOL:Reload(tr)
	if SERVER then
		net.Start('PhysicsManipulatorTool.SelectEntity')
		net.WriteBool(false)
		net.Send(self:GetOwner())
	end
	
	return true
end

local function ConsoleCommand(ply, cmd, args)
	if not IsValid(ply) then
		print('Why do you need this from server terminal?')
		return
	end
	
	if not ply:IsAdmin() then return end
	
	local Ent = tonumber(args[1])
	local mode = args[2]
	local value = args[3]
	
	local value_num = tonumber(value)
	local value_bool = tobool(value)
	
	if not Ent then return end
	if not mode then return end
	if not value then return end
	
	local ent = Entity(Ent)
	
	if not CanUse(ply, ent) then return end
	
	
end

if SERVER then
	concommand.Add('physics_manipulator_command', ConsoleCommand)
end
