
--[[
Copyright (C) 2016-2019 DBotThePony


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

local CURRENT_TOOL_MODE = 'multifreeze'

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
	select_r = 0,
	select_g = 255,
	select_b = 255,
}

GTools.AddAutoSelectConVars(TOOL.ClientConVar)

function TOOL.BuildCPanel(Panel)
	GTools.AutoSelectOptions(Panel, CURRENT_TOOL_MODE)
	GTools.GenericSelectPicker(Panel, CURRENT_TOOL_MODE, 'Highlight color')
end

function TOOL:CanUseEntity(ent)
	return IsValid(ent) and
		not ent:IsPlayer() and
		not ent:IsNPC() and
		not ent:IsVehicle() and
		ent:GetPhysicsObject():IsValid() and
		(not ent.CPPICanTool or ent:CPPICanTool(self:GetOwner(), CURRENT_TOOL_MODE))
end

function TOOL:LeftClick(tr)
	if CLIENT then return true end

	local get = GTools.GenericAutoSelect(self, tr)

	for i, v in ipairs(get) do
		v:GetPhysicsObject():EnableMotion(false)
		local data = EffectData()
		data:SetOrigin(v:GetPos())
		data:SetEntity(v)
		util.Effect('entity_remove', data, true, true)
	end

	GTools.PChatPrint(self:GetOwner(), 'Freezed ' .. #get .. ' physics objects')

	return true
end

function TOOL:RightClick(tr)
	if CLIENT then return true end

	local get = GTools.GenericAutoSelect(self, tr)

	for i, v in ipairs(get) do
		v:GetPhysicsObject():EnableMotion(true)
		v:GetPhysicsObject():Wake()
		local data = EffectData()
		data:SetOrigin(v:GetPos())
		data:SetEntity(v)
		util.Effect('entity_remove', data, true, true)
	end

	GTools.PChatPrint(self:GetOwner(), 'Unfreezed ' .. #get .. ' physics objects')

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
		display = RealTimeL() + 2
		DisplayTable = {}

		local max = net.ReadUInt(12)

		for i = 1, max do
			local new = net.ReadEntity()

			if IsValid(new) then
				table.insert(DisplayTable, new)

				if vars.select_print:GetBool() then
					GTools.PrintEntity(new)
				end
			end
		end

		GTools.ChatPrint('Counted ' .. #DisplayTable .. ' physics objects')

		if vars.select_print:GetBool() then
			GTools.ChatPrint('Look into console for list')
		end
	end)

	hook.Add('PostDrawWorldToolgun', 'multifreeze', function(ply, weapon, mode)
		if mode ~= 'multifreeze' then return end
		if display < RealTimeL() then return end

		if RealTimeL() % 0.5 < .25 then return end

		local r, g, b = vars.select_r:GetInt() / 255, vars.select_g:GetInt() / 255, vars.select_b:GetInt() / 255

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

	local get = GTools.GenericAutoSelect(self, tr)

	net.Start('MultiFreezeTool.ShowUp')
	net.WriteUInt(#get, 12)

	for i, v in ipairs(get) do
		net.WriteEntity(v)
	end

	net.Send(self:GetOwner())

	return true
end
