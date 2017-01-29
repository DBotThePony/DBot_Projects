
--Entity hightlighting

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

local SHOULD_DRAW = CreateConVar('dhud_highlight', '1', FCVAR_ARCHIVE, 'Highlight items on ground near you')
DHUD2.AddConVar('dhud_highlight', 'Enable highlight', SHOULD_DRAW)

surface.CreateFont('DHUD2.Highlight', {
	size = 72,
	font = 'Roboto',
	extended = true,
	weight = 600,
})

DHUD2.CreateColor('entitytitle', 'Entity titles', 200, 200, 200, 255)

local MAX_DIST = 300

local ENTS = {}

local function GetPrintText(ent)
	if ent.PrintName then return ent.PrintName end
	if ent.GetPrintName then return ent:GetPrintName() end
end

local function Check(ent, pos)
	if not GetPrintText(ent) then return false end
	if ent:GetPos():Distance(pos) > MAX_DIST then return false end
	if ent:IsWeapon() and IsValid(ent:GetOwner()) then return false end
	
	return true
end

timer.Create('DHUD2.HightlightEntUpdate', 1, 0, function()
	if not DHUD2.IsEnabled() then return end
	if not SHOULD_DRAW:GetBool() then return end
	if not DHUD2.ServerConVar('highlight') then return end
	
	ENTS = ents.GetAll()
	if not IsValid(DHUD2.SelectPlayer()) then return end
	local pos = DHUD2.SelectPlayer():EyePos()
	local p = DHUD2.SelectPlayer()
	
	for k, v in pairs(ENTS) do
		if v == p or v:GetClass() == 'gmod_hands' or not Check(v, pos) then
			ENTS[k] = nil
		end
	end
end)

local function Draw(ent, lpos, lang, epos)
	local name = GetPrintText(ent)
	if not name then return end
	local pos = ent:GetPos()
	local delta = epos - pos
	local dang = delta:Angle()
	dang:RotateAroundAxis(dang:Right(), -90)
	dang:RotateAroundAxis(dang:Up(), 90)
	
	local center = ent:OBBCenter()
	
	local w, h = surface.GetTextSize(name)
	
	local add = Vector(-w * 0.05)
	add:Rotate(dang)
	local drawpos = center + pos + add
	drawpos.z = drawpos.z + 8
	
	local dist = pos:Distance(epos)
	local fademult = 1 - ((dist * 0.7) / MAX_DIST)
	
	local col = DHUD2.GetColor 'entitytitle'
	
	local alpha = fademult * 255 * (col.a / 255)
	
	col = Color(col.r, col.g, col.b, alpha)
	
	cam.Start3D2D(drawpos, dang, 0.05)
	DHUD2.SimpleText(name, nil, DHUD2.GetDamageShift(), DHUD2.GetDamageShift(), col)
	cam.End3D2D()
end

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not DHUD2.IsEnabled() then return end
	if not SHOULD_DRAW:GetBool() then return end
	if not DHUD2.ServerConVar('highlight') then return end
	
	if not DHUD2.IsHudDrawing then return end
	
	local ply = DHUD2.SelectPlayer()
	if not IsValid(ply) then return end
	if ply:InVehicle() then return end
	local pos = ply:GetPos()
	local ang = ply:EyeAngles()
	local epos = ply:EyePos()
	
	surface.SetFont('DHUD2.Highlight')
	
	for k, ent in pairs(ENTS) do
		if not IsValid(ent) then continue end
		Draw(ent, pos, ang, epos)
	end
end

hook.Add('PostDrawTranslucentRenderables', 'DHUD2.Highlight', PostDrawTranslucentRenderables)
