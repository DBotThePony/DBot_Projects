
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

if CLIENT then
	language.Add('tool.fullbright.name', 'Fullbright')
	language.Add('tool.fullbright.desc', 'Makes entities fullbright')
	language.Add('tool.fullbright.0', '')

	language.Add('tool.fullbright.left', 'Left Click - make fullbright')
	language.Add('tool.fullbright.left_use', 'USE + Left Click - make fullbright all constrained entities')
	language.Add('tool.fullbright.right', 'Right Click - remove fullbright')
	language.Add('tool.fullbright.right_use', 'USE + Right Click - remove fullbright from all constrained entities')
	language.Add('tool.fullbright.shit', 'Due to gmod functionality, it uses a slow and quite broken hack')
else
	util.AddNetworkString('FullBrightTool.EntityStatusChanges')
end

local VALID_ENTS_TRANSLUCENT = {}
local VALID_ENTS_OPAQUE = {}

local function UpdateEntities()
	VALID_ENTS_TRANSLUCENT = {}
	VALID_ENTS_OPAQUE = {}

	for k, v in ipairs(ents.GetAll()) do
		if not v:GetNoDraw() and v:GetNWBool('FullBrightTool') then
			if v:GetRenderGroup() == RENDERGROUP_OPAQUE then
				table.insert(VALID_ENTS_OPAQUE, v)
			else
				table.insert(VALID_ENTS_TRANSLUCENT, v)
			end
		end
	end
end

if CLIENT then
	net.Receive('FullBrightTool.EntityStatusChanges', function()
		if net.ReadEntity() == LocalPlayer() then return end
		timer.Simple(0.5, UpdateEntities)
	end)

	timer.Create('FullBrightTool', 5.5, 0, UpdateEntities)

	local function PostDrawTranslucentRenderables(a, b)
		if a or b then return end

		render.SuppressEngineLighting(true)

		for i, ent in ipairs(VALID_ENTS_TRANSLUCENT) do
			if IsValid(ent) then
				ent:DrawModel()
			end
		end

		render.SuppressEngineLighting(false)
	end

	local function PostDrawOpaqueRenderables(a, b)
		if a or b then return end

		render.SuppressEngineLighting(true)

		for i, ent in ipairs(VALID_ENTS_OPAQUE) do
			if IsValid(ent) then
				ent:DrawModel()
			end
		end

		render.SuppressEngineLighting(false)
	end

	hook.Add('PostDrawTranslucentRenderables', 'FullBrightTool', PostDrawTranslucentRenderables)
	hook.Add('PostDrawOpaqueRenderables', 'FullBrightTool', PostDrawOpaqueRenderables)
end

TOOL.Name = 'Fullbright'
TOOL.Category = 'Poser'

TOOL.Information = {
	{name = 'left'},
	{name = 'left_use'},
	{name = 'right'},
	{name = 'right_use'},
	{name = 'shit'}
}

TOOL.AddToMenu = true
TOOL.Command = nil
TOOL.ConfigName = nil

TOOL.ClientConVar = {}
TOOL.ServerConVar = {}

function TOOL:LeftClick(tr)
	local ent, ply = tr.Entity, self:GetOwner()
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return end

	if SERVER then
		ent:SetNWBool('FullBrightTool', true)
		net.Start('FullBrightTool.EntityStatusChanges')
		net.WriteEntity(ply)
		net.Broadcast()

		if ply:KeyDown(IN_USE) then
			local get = constraint.GetAllConstrainedEntities(ent)

			for i, ent in pairs(get) do
				ent:SetNWBool('FullBrightTool', true)
			end

			net.Start('FullBrightTool.EntityStatusChanges')
			net.WriteEntity(Entity(0))
			net.Broadcast()
		end
	else
		ent:SetNWBool('FullBrightTool', true)
		UpdateEntities()
	end

	return true
end

function TOOL:RightClick(tr)
	local ent, ply = tr.Entity, self:GetOwner()
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return end

	if SERVER then
		ent:SetNWBool('FullBrightTool', false)
		net.Start('FullBrightTool.EntityStatusChanges')
		net.WriteEntity(ply)
		net.Broadcast()

		if ply:KeyDown(IN_USE) then
			local get = constraint.GetAllConstrainedEntities(ent)

			for i, ent in pairs(get) do
				ent:SetNWBool('FullBrightTool', false)
			end

			net.Start('FullBrightTool.EntityStatusChanges')
			net.WriteEntity(Entity(0))
			net.Broadcast()
		end
	else
		ent:SetNWBool('FullBrightTool', false)
		UpdateEntities()
	end

	return true
end

TOOL.Reload = TOOL.RightClick

