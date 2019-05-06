
--TEH Minimap

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

local ENABLE = CreateConVar('dhud_minimap', '1', FCVAR_ARCHIVE, 'Enable Minimap')
DHUD2.AddConVar('dhud_minimap', 'Enable Minimap', ENABLE)

local DRAW_ENTS = CreateConVar('dhud_minimap_ents', '1', FCVAR_ARCHIVE, 'Draw Entities on Minimap')
DHUD2.AddConVar('dhud_minimap_ents', 'Draw Entities on Minimap', DRAW_ENTS)

local DRAW_ENTS_MODELS = CreateConVar('dhud_minimap_ents_models', '0', FCVAR_ARCHIVE, 'Draw Entities on Minimap as Models')
DHUD2.AddConVar('dhud_minimap_ents_models', 'Draw Entities on Minimap as Models\nNeeds beefy PC!', DRAW_ENTS)

local WIDTH = 200
local HEIGHT = 200
local MaxDist = 1000

DHUD2.DefinePosition('minimap', ScrWL() - WIDTH - 30, ScrHL() - HEIGHT - 30)

local ENTS = {}

local Whitelist = {
	prop_physics = true,
	prop_door_rotating = true,
}

timer.Create('DHUD2.UpdateMinimap', 1, 0, function()
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('minimap') then return end
	if not IsValid(DHUD2.SelectPlayer()) then return end
	ENTS = ents.GetAll()
	local lpos = EyePos()

	for k, v in pairs(ENTS) do
		local cond = not IsValid(v) or
			(v:IsWeapon() and IsValid(v:GetOwner())) or
			v:IsPlayer() or
			v:GetPos():Distance(lpos) > MaxDist or
			v:GetClass() == 'gmod_hands' or
			(not Whitelist[v:GetClass()] and not v.PrintName and not v:IsNPC())

		if cond then
			ENTS[k] = nil
			continue
		end
	end
end)

local ToDraw = {}

local function Tick()
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('minimap') then return end
	ToDraw = {}

	local ply = DHUD2.SelectPlayer()
	local lpos = EyePos()
	local eyes = EyePos()

	local ShouldDrawEnts = DRAW_ENTS:GetBool()

	for k, v in pairs(ENTS) do
		if not IsValid(v) then continue end

		local pos = v:GetPos()
		if pos:Distance(lpos) > MaxDist then continue end

		local isnpc = v:IsNPC()
		local ang = v:GetAngles()

		if not ShouldDrawEnts and not isnpc then continue end

		if isnpc then
			ang.p = 0
			ang.r = 0
			ang.y = ang.y - 90
		end

		local data = {}

		data.ent = v
		data.pos = pos
		data.ang = ang
		data.mins = v:OBBMins()
		data.maxs = v:OBBMaxs()
		data.isnpc = isnpc
		data.ent = v

		if isnpc then
			local p = v:EyePos()
			p.z = p.z - (p.z - pos.z) * .5
			data.eyes = p
		end

		table.insert(ToDraw, data)
	end
end

DHUD2.VarHook('Minimap', Tick)

local PlayerArrow = {
	{x = 20, y = 90},
	{x = 50, y = 0},
	{x = 80, y = 90},
}

DHUD2.CreateColor('minimap_lply', 'Local Player', 150, 255, 255, 200)
DHUD2.CreateColor('minimap_ply', 'Players on Minimap', 150, 200, 255, 200)
DHUD2.CreateColor('minimap_npc', 'NPC on Minimap', 150, 150, 150, 200)
DHUD2.CreateColor('minimap_entity', 'Entities on Minimap', 156, 200, 226, 150)

surface.CreateFont('DHUD2.MinimapNames', {
	font = 'Roboto',
	size = 30,
	extended = true,
	weight = 800,
})

local function DrawPly(v, lpos)
	local ang = v:EyeAngles()
	ang.p = 0
	ang.r = 0
	ang.y = ang.y - 90

	local pos = v:EyePos()
	pos.z = pos.z - 20
	local Add = Vector(-35, 20, 0)
	Add:Rotate(ang)

	local Name = v:Nick()

	local DrawP = pos + Add

	cam.Start3D2D(DrawP, ang, 0.7)
		surface.SetDrawColor(DHUD2.GetColor('minimap_ply'))
		surface.DrawPoly(PlayerArrow)
	cam.End3D2D()

	DrawP.z = DrawP.z + 30

	surface.SetFont('DHUD2.MinimapNames')
	local w, h = surface.GetTextSize(Name)

	local delta = lpos - DrawP

	cam.Start3D2D(pos - Vector(40, 0, 0), Angle(0, -90, 0), 1.3)
		DHUD2.DrawBox(0, 0, w + 6, h + 4, DHUD2.GetColor('bg'))
		DHUD2.SimpleText(Name, nil, 3, 2, team.GetColor(v:Team()))
	cam.End3D2D()
end

local function DrawNPC(v, ang, pos)
	local Add = Vector(-20, 13, 0)
	Add:Rotate(ang)

	cam.Start3D2D(pos + Add, ang, 0.4)
		surface.SetDrawColor(DHUD2.GetColor('minimap_npc'))
		surface.DrawPoly(PlayerArrow)
	cam.End3D2D()
end

local whitemat = Material("models/debug/debugwhite")

local function ProceedDraw(ply, DrawPos, DrawAngle)
	local lpos = ply:GetPos()
	local add = Vector(80, 20, 35)
	add:Rotate(DrawAngle)

	local LocalAngle = ply:EyeAngles()
	LocalAngle.p = 0
	LocalAngle.y = LocalAngle.y - 90
	LocalAngle.r = 0

	if ply:InVehicle() and IsValid(ply:GetVehicle()) then
		LocalAngle.y = LocalAngle.y + ply:GetVehicle():GetAngles().y
	end

	local color = DHUD2.GetColor('minimap_entity')

	local RED = color.r / 255
	local GREEN = color.g / 255
	local BLUE = color.b / 255

	whitemat:SetVector('$color', Vector(RED, GREEN, BLUE))

	render.SetColorModulation(RED, GREEN, BLUE)

	if DRAW_ENTS_MODELS:GetBool() then
		for k, data in ipairs(ToDraw) do
			if IsValid(data.ent) then
				if data.isnpc then
					DrawNPC(data.ent, data.ang, data.eyes)
				else
					--Fix some addons that calls render.ModelMaterialOverride() on draw too
					--Also reset surface material
					data.ent:DrawModel()
					draw.NoTexture()
					render.ModelMaterialOverride(whitemat)
					render.SetColorModulation(RED, GREEN, BLUE)
				end
			else
				render.DrawBox(data.pos, data.ang, data.mins, data.maxs, color, false)
			end
		end
	else
		for k, data in ipairs(ToDraw) do
			if not data.isnpc then
				render.DrawBox(data.pos, data.ang, data.mins, data.maxs, color, false)
			else
				DrawNPC(data.ent, data.ang, data.eyes)
			end
		end
	end

	for k, v in pairs(player.GetAll()) do
		if v == ply then continue end
		if v:GetPos():Distance(lpos) > MaxDist then continue end
		DrawPly(v, lpos)
	end

	local addToPly = Vector(-45, 50, 0)
	addToPly:Rotate(LocalAngle)

	cam.IgnoreZ(true)
	cam.Start3D2D(lpos + addToPly, LocalAngle, 1)
		surface.SetDrawColor(DHUD2.GetColor('minimap_lply'))
		surface.DrawPoly(PlayerArrow)
	cam.End3D2D()
	cam.IgnoreZ(false)
end

local Records = {}
local LastPos = Vector()
local Mult = 1
local ipos = 1
local max = 100

local function UpdateMinimapZoom()
	ipos = ipos + 1
	if ipos > max then
		ipos = 1
	end

	local pos = DHUD2.SelectPlayer():GetPos()
	Records[ipos] = pos:Distance(LastPos) / DHUD2.Multipler
	LastPos = pos

	local total = 1
	local all = 0

	for k, v in ipairs(Records) do
		all = all + v
		total = total + 1
	end

	Mult = math.Clamp(all / total * .5, 1, 5)
end

DHUD2.VarHook('minimap_zoom', UpdateMinimapZoom)

local function DrawMap(x, y, Width, Height, Mult)
	local ply = DHUD2.SelectPlayer()
	local DrawX, DrawY = x, y
	local FoV = 90
	local DrawPos = EyePos()
	local DrawAngle = EyeAngles()
	DrawAngle.p = 0
	DrawAngle.r = 0

	DrawAngle = Angle(90, 0, 0)

	local add = Vector(-10, 0, 0)
	add:Rotate(DrawAngle)

	DHUD2.SimpleText('Zoom: ' ..  math.floor((1 / Mult) * 100) / 100,'DHUD2.Default', x + DHUD2.GetDamageShift(), y - 20 + DHUD2.GetDamageShift(), DHUD2.GetColor('generic'))

	DrawPos.z = DrawPos.z + 280 * Mult
	DrawPos = DrawPos + add

	DHUD2.DrawBox(x + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), Width, Height, DHUD2.GetColor('bg'))

	cam.Start3D(DrawPos, DrawAngle, FoV, DrawX, DrawY, Width, Height)
		render.SuppressEngineLighting(true)
		render.SetMaterial(whitemat)
		render.ModelMaterialOverride(whitemat)
		draw.NoTexture()
		render.ResetModelLighting(1, 1, 1)
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)

		ProceedDraw(ply, DrawPos, DrawAngle)
		render.SuppressEngineLighting(false)
		render.SetColorModulation(1, 1, 1)
		render.ModelMaterialOverride()
	cam.End3D()

	--Fix Vector:ToScreen()
	--Actually this is not a bug - when you call cam.Start3D, you can use Vector:ToScreen() to get real vector position on screen
	--based on your current drawing scene
	cam.Start3D()
	cam.End3D()
end

local IsPressed = false
local DrawBigMap = false

local function Draw()
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('minimap') then return end

	local ply = DHUD2.SelectPlayer()
	local x, y = DHUD2.GetPosition('minimap')

	local keyDown = input.IsKeyDown(KEY_M)
	local panel = vgui.GetKeyboardFocus()
	if not IsPressed and keyDown and not panel then
		IsPressed = true
		DrawBigMap = not DrawBigMap
	elseif IsPressed and not keyDown and not panel then
		IsPressed = false
	end

	if not DrawBigMap then
		DrawMap(x, y, WIDTH, HEIGHT, Mult)
	else
		DrawMap(100, 100, ScrWL() - 200, ScrHL() - 200, 5)
	end
end

DHUD2.DrawHook('minimap', Draw)
