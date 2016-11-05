
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

if SERVER then
	util.AddNetworkString('MultiColor.RainbowSelect')
end

local SelectTable = {}

TOOL.Name = 'Multi-Color - Rainbow'
TOOL.Category = 'Multitool'

TOOL.AddToMenu = true
TOOL.Command = nil
TOOL.ConfigName = nil

TOOL.ClientConVar = {
	step = 2,
	mode = 1,
}

--[[
Modes:
1 - Default. Recolor by order what props was selected.
2 - Recolor by left to right (small X - large X)
3 - Recolor by right to left (large X - small X)
4 - Recolor by up to down (large Y - small Y)
5 - Recolor by down to up (small Y - large Y)
]]

TOOL.ServerConVar = {}

local Sorters = {
	function(a, b)
		return true
	end,
	
	function(a, b)
		return a:GetPos().x < b:GetPos().x
	end,
	
	function(a, b)
		return a:GetPos().x > b:GetPos().x
	end,
	
	function(a, b)
		return a:GetPos().y > b:GetPos().y
	end,
	
	function(a, b)
		return a:GetPos().y < b:GetPos().y
	end,
}

local function SortTable(tab, mode)
	if mode == 1 then
		return tab
	else
		return table.Copy(table.sort(tab, Sorters[mode]))
	end
end

if CLIENT then
	local COLOR_R = CreateConVar('multicolour_select_r', '105', {FCVAR_ARCHIVE}, 'Prop Select visual color')
	local COLOR_G = CreateConVar('multicolour_select_g', '205', {FCVAR_ARCHIVE}, 'Prop Select visual color')
	local COLOR_B = CreateConVar('multicolour_select_b', '239', {FCVAR_ARCHIVE}, 'Prop Select visual color')
	local STEP = CreateConVar('multicolour_rainbow_step', '2', {FCVAR_ARCHIVE}, 'Rainbow recolor step')
	local MODE = CreateConVar('multicolour_rainbow_mode', '1', {FCVAR_ARCHIVE}, 'Rainbow recolor mode')

	net.Receive('MultiColor.RainbowSelect', function()
		local newEnt = net.ReadEntity()
		
		for k, v in ipairs(SelectTable) do
			if v == newEnt then
				table.remove(SelectTable, k)
				return
			end
		end
		
		table.insert(SelectTable, newEnt)
	end)
	
	hook.Add('PostDrawTranslucentRenderables', 'MultiColorDraw', function()
		if not LocalPlayer():IsValid() then return end
		local wep = LocalPlayer():GetActiveWeapon()
		if not wep:IsValid() then return end
		
		if wep:GetClass() ~= 'gmod_tool' then return end
		if wep:GetMode() ~= 'multicolour_rainbow' then return end
		
		local toRemove = {}
		
		for k, v in ipairs(SelectTable) do
			if not v:IsValid() then
				table.insert(toRemove, k)
			end
		end
		
		for k, v in ipairs(toRemove) do
			SelectTable[v] = nil
		end
		
		table.remove(SelectTable, 0)
		
		for i, ent in ipairs(SortTable(SelectTable, MODE:GetInt())) do
			render.SetColorModulation(math.sin(i) * .5 + .5, math.sin(i + STEP:GetInt()) * .5 + .5, math.sin(i + STEP:GetInt() * 2) * .5 + .5)
			ent:DrawModel()
		end
		
		render.SetColorModulation(1, 1, 1)
	end)
end

function TOOL:RightClick(tr)

end

function TOOL:LeftClick(tr)
	local ent = tr.Entity
	if not IsValid(ent) then return false end
	if ent:IsPlayer() then return false end
	
	if SERVER then
		net.Start('MultiColor.RainbowSelect')
		net.WriteEntity(ent)
		net.Send(self:GetOwner())
	end
	
	return true
end

function TOOL.BuildCPanel(Panel)
	if not IsValid(Panel) then return end
end

