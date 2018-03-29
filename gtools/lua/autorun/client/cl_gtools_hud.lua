
--[[
Copyright (C) 2016-2018 DBot

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

GTools = GTools or {}

module('GToolsHUD', package.seeall)

_G.GTools.HUD = _G.GToolsHUD

ENABLED = CreateConVar('gtool_draw', '1', {FCVAR_ARCHIVE}, 'Draw stuff')
DRAW_COORDINATES = CreateConVar('gtool_draw_coordinates', '1', {FCVAR_ARCHIVE}, 'Draw directions near world borders')
DRAW_COORDINATES_NEAR_OBB_CENTER = CreateConVar('gtool_draw_coordinates_obb', '1', {FCVAR_ARCHIVE}, 'Draw directions near model center')
DRAW_ANGLES = CreateConVar('gtool_draw_angles', '1', {FCVAR_ARCHIVE}, 'Draw model angles near center')
DRAW_COORDINATES_DONT_DRAW = CreateConVar('gtool_draw_coordinates_obb_d', '1', {FCVAR_ARCHIVE}, 'Don\'t draw directions if it would be too close to mins')
DRAW_LINES_WORLD = CreateConVar('gtool_draw_world_aabb', '1', {FCVAR_ARCHIVE}, 'Draw world space AABB borders')
DRAW_LINES_MODEL = CreateConVar('gtool_draw_obb', '1', {FCVAR_ARCHIVE}, 'Draw model AABB borders')
MAXIMAL_DRAW_DISTANCE = CreateConVar('gtool_draw_dist', '256', {FCVAR_ARCHIVE}, 'Maximal draw distance of angles and centered coordinates')
MAXIMAL_DRAW_DISTANCE_OBB = CreateConVar('gtool_draw_dist_obb', '400', {FCVAR_ARCHIVE}, 'Maximal draw distance of OBB box')
MAXIMAL_DRAW_DISTANCE_WORLD_BORDERS = CreateConVar('gtool_draw_dist_bb', '1024', {FCVAR_ARCHIVE}, 'Maximal draw distance of world borders box')
DIST_COORD_MINIMAL = CreateConVar('gtool_draw_dist_cmin', '40', {FCVAR_ARCHIVE}, 'Minimal allowed distance between coordinates display')

ENABLED_SV = CreateConVar('gtool_draw_sv', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Tell clients to draw stuff')
OBEY_SV = CreateConVar('gtool_draw_obey', '1', {FCVAR_ARCHIVE}, 'Obey server politics about drawing')

LINE_COLOR_DEFAULT_RED = CreateConVar('gtool_line_r', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_DEFAULT_GREEN = CreateConVar('gtool_line_g', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_DEFAULT_BLUE = CreateConVar('gtool_line_b', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_DEFAULT_ALPHA = CreateConVar('gtool_line_a', '255', {FCVAR_ARCHIVE}, '')

LINE_COLOR_ROTATED_RED = CreateConVar('gtool_line_r_r', '60', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ROTATED_GREEN = CreateConVar('gtool_line_r_g', '60', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ROTATED_BLUE = CreateConVar('gtool_line_r_b', '60', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ROTATED_ALPHA = CreateConVar('gtool_line_r_a', '255', {FCVAR_ARCHIVE}, '')

LINE_COLOR_COORDINATES_Z_RED = CreateConVar('gtool_coord_z_r', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_Z_GREEN = CreateConVar('gtool_coord_z_g', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_Z_BLUE = CreateConVar('gtool_coord_z_b', '255', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_Z_ALPHA = CreateConVar('gtool_coord_z_a', '255', {FCVAR_ARCHIVE}, '')

LINE_COLOR_COORDINATES_Y_RED = CreateConVar('gtool_coord_y_r', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_Y_GREEN = CreateConVar('gtool_coord_y_g', '255', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_Y_BLUE = CreateConVar('gtool_coord_y_b', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_Y_ALPHA = CreateConVar('gtool_coord_y_a', '255', {FCVAR_ARCHIVE}, '')

LINE_COLOR_COORDINATES_X_RED = CreateConVar('gtool_coord_x_r', '255', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_X_GREEN = CreateConVar('gtool_coord_x_g', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_X_BLUE = CreateConVar('gtool_coord_x_b', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_COORDINATES_X_ALPHA = CreateConVar('gtool_coord_x_a', '255', {FCVAR_ARCHIVE}, '')

LINE_COLOR_ANGLES_P_RED = CreateConVar('gtool_ang_p_r', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_P_GREEN = CreateConVar('gtool_ang_p_g', '128', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_P_BLUE = CreateConVar('gtool_ang_p_b', '0', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_P_ALPHA = CreateConVar('gtool_ang_p_a', '255', {FCVAR_ARCHIVE}, '')

LINE_COLOR_ANGLES_Y_RED = CreateConVar('gtool_ang_y_r', '166', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_Y_GREEN = CreateConVar('gtool_ang_y_g', '216', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_Y_BLUE = CreateConVar('gtool_ang_y_b', '82', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_Y_ALPHA = CreateConVar('gtool_ang_y_a', '255', {FCVAR_ARCHIVE}, '')

LINE_COLOR_ANGLES_R_RED = CreateConVar('gtool_ang_r_r', '209', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_R_GREEN = CreateConVar('gtool_ang_r_g', '139', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_R_BLUE = CreateConVar('gtool_ang_r_b', '69', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_R_ALPHA = CreateConVar('gtool_ang_r_a', '255', {FCVAR_ARCHIVE}, '')

LINE_COLOR_ANGLES_RED = CreateConVar('gtool_ang_r', '30', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_GREEN = CreateConVar('gtool_ang_g', '255', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_BLUE = CreateConVar('gtool_ang_b', '255', {FCVAR_ARCHIVE}, '')
LINE_COLOR_ANGLES_ALPHA = CreateConVar('gtool_ang_a', '255', {FCVAR_ARCHIVE}, '')

-- BOX OF HUGS
function CreateABox(mins, maxs)
	local data = {}

	table.insert(data, {Vector(mins.x, mins.y, mins.z), Vector(maxs.x, mins.y, mins.z)})
	table.insert(data, {Vector(maxs.x, mins.y, mins.z), Vector(maxs.x, maxs.y, mins.z)})
	table.insert(data, {Vector(mins.x, mins.y, mins.z), Vector(mins.x, maxs.y, mins.z)})
	table.insert(data, {Vector(mins.x, maxs.y, mins.z), Vector(maxs.x, maxs.y, mins.z)})

	table.insert(data, {Vector(mins.x, mins.y, maxs.z), Vector(maxs.x, mins.y, maxs.z)})
	table.insert(data, {Vector(maxs.x, mins.y, maxs.z), Vector(maxs.x, maxs.y, maxs.z)})
	table.insert(data, {Vector(mins.x, mins.y, maxs.z), Vector(mins.x, maxs.y, maxs.z)})
	table.insert(data, {Vector(mins.x, maxs.y, maxs.z), Vector(maxs.x, maxs.y, maxs.z)})

	table.insert(data, {Vector(maxs.x, maxs.y, maxs.z), Vector(maxs.x, maxs.y, mins.z)})
	table.insert(data, {Vector(maxs.x, mins.y, maxs.z), Vector(maxs.x, mins.y, mins.z)})
	table.insert(data, {Vector(mins.x, mins.y, maxs.z), Vector(mins.x, mins.y, mins.z)})
	table.insert(data, {Vector(mins.x, maxs.y, maxs.z), Vector(mins.x, maxs.y, mins.z)})

	return data
end

function RotateBox(data, ang)
	for k, v in ipairs(data) do
		v[1]:Rotate(ang)
		v[2]:Rotate(ang)
	end
end

function BringBoxToWorld(data, pos)
	for k, v in ipairs(data) do
		v[1] = v[1] + pos
		v[2] = v[2] + pos
	end
end

VECTOR_Z = Vector(0, 0, 20)
VECTOR_Y = Vector(0, 20, 0)
VECTOR_X = Vector(20, 0, 0)
SLIGHTLY_UP = Vector(0, 0, 5)
SLIGHTLY_DOWN = Vector(0, 0, -2)

DELTA_ROLL_VECTOR = Vector(10, 0, 0)
DELTA_PITH_VECTOR = Vector(0, 10, 0)
DELTA_YAW_VECTOR = Vector(0, 0, 10)

SHOULD_DRAW_DIRECTIONS_TEXT = false
DRAW_DIRECTION_TEXT_X, DRAW_DIRECTION_TEXT_Y, DRAW_DIRECTION_TEXT_Z = {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}

SHOULD_DRAW_DIRECTIONS_TEXT2 = false
DRAW_DIRECTION_TEXT_X2, DRAW_DIRECTION_TEXT_Y2, DRAW_DIRECTION_TEXT_Z2 = {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}

SHOULD_DRAW_DIRECTIONS_TEXT3 = false
DRAW_DIRECTION_TEXT_X3, DRAW_DIRECTION_TEXT_Y3, DRAW_DIRECTION_TEXT_Z3, DRAW_DIRECTION_TEXT_T3 = {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}

function HUDPaint()
	if not ENABLED:GetBool() then return end
	if OBEY_SV:GetBool() and not ENABLED_SV:GetBool() then return end

	surface.SetFont('Default')

	if SHOULD_DRAW_DIRECTIONS_TEXT then
		SHOULD_DRAW_DIRECTIONS_TEXT = false

		surface.SetTextColor(LINE_COLOR_COORDINATES_X_RED:GetInt(), LINE_COLOR_COORDINATES_X_GREEN:GetInt(), LINE_COLOR_COORDINATES_X_BLUE:GetInt(), LINE_COLOR_COORDINATES_X_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_X.x, DRAW_DIRECTION_TEXT_X.y)
		surface.DrawText('X')

		surface.SetTextColor(LINE_COLOR_COORDINATES_Y_RED:GetInt(), LINE_COLOR_COORDINATES_Y_GREEN:GetInt(), LINE_COLOR_COORDINATES_Y_BLUE:GetInt(), LINE_COLOR_COORDINATES_Y_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_Y.x, DRAW_DIRECTION_TEXT_Y.y)
		surface.DrawText('Y')

		surface.SetTextColor(LINE_COLOR_COORDINATES_Z_RED:GetInt(), LINE_COLOR_COORDINATES_Z_GREEN:GetInt(), LINE_COLOR_COORDINATES_Z_BLUE:GetInt(), LINE_COLOR_COORDINATES_Z_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_Z.x, DRAW_DIRECTION_TEXT_Z.y)
		surface.DrawText('Z')
	end

	if SHOULD_DRAW_DIRECTIONS_TEXT2 then
		SHOULD_DRAW_DIRECTIONS_TEXT2 = false

		surface.SetTextColor(LINE_COLOR_COORDINATES_X_RED:GetInt(), LINE_COLOR_COORDINATES_X_GREEN:GetInt(), LINE_COLOR_COORDINATES_X_BLUE:GetInt(), LINE_COLOR_COORDINATES_X_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_X2.x, DRAW_DIRECTION_TEXT_X2.y)
		surface.DrawText('X')

		surface.SetTextColor(LINE_COLOR_COORDINATES_Y_RED:GetInt(), LINE_COLOR_COORDINATES_Y_GREEN:GetInt(), LINE_COLOR_COORDINATES_Y_BLUE:GetInt(), LINE_COLOR_COORDINATES_Y_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_Y2.x, DRAW_DIRECTION_TEXT_Y2.y)
		surface.DrawText('Y')

		surface.SetTextColor(LINE_COLOR_COORDINATES_Z_RED:GetInt(), LINE_COLOR_COORDINATES_Z_GREEN:GetInt(), LINE_COLOR_COORDINATES_Z_BLUE:GetInt(), LINE_COLOR_COORDINATES_Z_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_Z2.x, DRAW_DIRECTION_TEXT_Z2.y)
		surface.DrawText('Z')
	end

	if SHOULD_DRAW_DIRECTIONS_TEXT3 then
		SHOULD_DRAW_DIRECTIONS_TEXT3 = false

		surface.SetTextColor(LINE_COLOR_ANGLES_P_RED:GetInt(), LINE_COLOR_ANGLES_P_GREEN:GetInt(), LINE_COLOR_ANGLES_P_BLUE:GetInt(), LINE_COLOR_ANGLES_P_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_X3.x, DRAW_DIRECTION_TEXT_X3.y)
		surface.DrawText('P')

		surface.SetTextColor(LINE_COLOR_ANGLES_Y_RED:GetInt(), LINE_COLOR_ANGLES_Y_GREEN:GetInt(), LINE_COLOR_ANGLES_Y_BLUE:GetInt(), LINE_COLOR_ANGLES_Y_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_Y3.x, DRAW_DIRECTION_TEXT_Y3.y)
		surface.DrawText('Y')

		surface.SetTextColor(LINE_COLOR_ANGLES_R_RED:GetInt(), LINE_COLOR_ANGLES_R_GREEN:GetInt(), LINE_COLOR_ANGLES_R_BLUE:GetInt(), LINE_COLOR_ANGLES_R_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_Z3.x, DRAW_DIRECTION_TEXT_Z3.y)
		surface.DrawText('R')

		surface.SetTextColor(LINE_COLOR_ANGLES_RED:GetInt(), LINE_COLOR_ANGLES_GREEN:GetInt(), LINE_COLOR_ANGLES_BLUE:GetInt(), LINE_COLOR_ANGLES_ALPHA:GetInt())
		surface.SetTextPos(DRAW_DIRECTION_TEXT_T3.x, DRAW_DIRECTION_TEXT_T3.y)
		surface.DrawText('T')
	end
end

function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not ENABLED:GetBool() then return end
	if OBEY_SV:GetBool() and not ENABLED_SV:GetBool() then return end

	if not IsValid(LocalPlayer()) then return end
	if LocalPlayer():InVehicle() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if not IsValid(wep) then return end

	local class = wep:GetClass()

	if class ~= 'gmod_tool' and class ~= 'weapon_physgun' then return end
	local tr = LocalPlayer():GetEyeTrace()

	if not IsValid(tr.Entity) then return end

	local lpos = EyePos()

	local ent = tr.Entity
	if ent:IsPlayer() then return end
	local mins, maxs = ent:WorldSpaceAABB()
	local pos, ang = ent:GetPos(), ent:GetAngles()

	local pDist = math.min(
		tr.HitPos:Distance(lpos),
		pos:Distance(lpos),

		mins:Distance(lpos),
		Vector(mins.x, mins.y, maxs.z):Distance(lpos),
		Vector(mins.x, maxs.y, mins.z):Distance(lpos),
		Vector(mins.x, maxs.y, maxs.z):Distance(lpos),
		Vector(maxs.x, mins.y, mins.z):Distance(lpos),
		Vector(maxs.x, mins.y, maxs.z):Distance(lpos),
		Vector(maxs.x, maxs.y, mins.z):Distance(lpos),
		maxs:Distance(lpos)
	)

	local dMins, dMaxs, dCenter = ent:OBBMins(), ent:OBBMaxs(), ent:OBBCenter()

	if DRAW_LINES_WORLD:GetBool() and pDist < MAXIMAL_DRAW_DISTANCE_WORLD_BORDERS:GetInt() then
		local defColor = Color(LINE_COLOR_DEFAULT_RED:GetInt(), LINE_COLOR_DEFAULT_GREEN:GetInt(), LINE_COLOR_DEFAULT_BLUE:GetInt(), LINE_COLOR_DEFAULT_ALPHA:GetInt())
		local vertexes = CreateABox(mins, maxs)

		for i, data in ipairs(vertexes) do
			render.DrawLine(data[1], data[2], defColor, false)
		end
	end

	if DRAW_LINES_MODEL:GetBool() and pDist < MAXIMAL_DRAW_DISTANCE_OBB:GetInt() then
		local rotatedColor = Color(LINE_COLOR_ROTATED_RED:GetInt(), LINE_COLOR_ROTATED_GREEN:GetInt(), LINE_COLOR_ROTATED_BLUE:GetInt(), LINE_COLOR_ROTATED_ALPHA:GetInt())
		local vertexesLocal = CreateABox(dMins, dMaxs)
		RotateBox(vertexesLocal, ang)
		BringBoxToWorld(vertexesLocal, pos)

		for i, data in ipairs(vertexesLocal) do
			render.DrawLine(data[1], data[2], rotatedColor, false)
		end
	end

	if DRAW_COORDINATES:GetBool() and pDist < MAXIMAL_DRAW_DISTANCE_OBB:GetInt() then
		local xColor = Color(LINE_COLOR_COORDINATES_X_RED:GetInt(), LINE_COLOR_COORDINATES_X_GREEN:GetInt(), LINE_COLOR_COORDINATES_X_BLUE:GetInt(), LINE_COLOR_COORDINATES_X_ALPHA:GetInt())
		local yColor = Color(LINE_COLOR_COORDINATES_Y_RED:GetInt(), LINE_COLOR_COORDINATES_Y_GREEN:GetInt(), LINE_COLOR_COORDINATES_Y_BLUE:GetInt(), LINE_COLOR_COORDINATES_Y_ALPHA:GetInt())
		local zColor = Color(LINE_COLOR_COORDINATES_Z_RED:GetInt(), LINE_COLOR_COORDINATES_Z_GREEN:GetInt(), LINE_COLOR_COORDINATES_Z_BLUE:GetInt(), LINE_COLOR_COORDINATES_Z_ALPHA:GetInt())

		render.DrawLine(mins, mins + VECTOR_X, xColor, false)
		render.DrawLine(mins, mins + VECTOR_Y, yColor, false)
		render.DrawLine(mins, mins + VECTOR_Z, zColor, false)

		cam.Start3D()
		cam.End3D()

		local toScreen = mins:ToScreen()

		local W, H = ScrWL(), ScrHL()
		local Wh, Hh = W / 2, H / 2
		local x, y = toScreen.x, toScreen.y

		if x > Wh - 200 and x < Wh + 200 and y > Hh - 200 and y < Hh + 200 then
			DRAW_DIRECTION_TEXT_X = (mins + VECTOR_X + SLIGHTLY_UP):ToScreen()
			DRAW_DIRECTION_TEXT_Y = (mins + VECTOR_Y + SLIGHTLY_UP):ToScreen()
			DRAW_DIRECTION_TEXT_Z = (mins + VECTOR_Z + SLIGHTLY_UP):ToScreen()
			SHOULD_DRAW_DIRECTIONS_TEXT = true
		end
	end

	if DRAW_COORDINATES_NEAR_OBB_CENTER:GetBool() and pDist < MAXIMAL_DRAW_DISTANCE:GetInt() then
		local xColor = Color(LINE_COLOR_COORDINATES_X_RED:GetInt(), LINE_COLOR_COORDINATES_X_GREEN:GetInt(), LINE_COLOR_COORDINATES_X_BLUE:GetInt(), LINE_COLOR_COORDINATES_X_ALPHA:GetInt())
		local yColor = Color(LINE_COLOR_COORDINATES_Y_RED:GetInt(), LINE_COLOR_COORDINATES_Y_GREEN:GetInt(), LINE_COLOR_COORDINATES_Y_BLUE:GetInt(), LINE_COLOR_COORDINATES_Y_ALPHA:GetInt())
		local zColor = Color(LINE_COLOR_COORDINATES_Z_RED:GetInt(), LINE_COLOR_COORDINATES_Z_GREEN:GetInt(), LINE_COLOR_COORDINATES_Z_BLUE:GetInt(), LINE_COLOR_COORDINATES_Z_ALPHA:GetInt())

		local center = Vector(dCenter)
		center:Rotate(ang)
		center = center + pos

		if not DRAW_COORDINATES:GetBool() or not DRAW_COORDINATES_DONT_DRAW:GetBool() or center:Distance(mins) > DIST_COORD_MINIMAL:GetInt() then
			render.DrawLine(center, center + VECTOR_X, xColor, false)
			render.DrawLine(center, center + VECTOR_Y, yColor, false)
			render.DrawLine(center, center + VECTOR_Z, zColor, false)

			cam.Start3D()
			cam.End3D()

			local toScreen = center:ToScreen()

			local W, H = ScrWL(), ScrHL()
			local Wh, Hh = W / 2, H / 2
			local x, y = toScreen.x, toScreen.y

			if x > Wh - 100 and x < Wh + 100 and y > Hh - 100 and y < Hh + 100 then
				DRAW_DIRECTION_TEXT_X2 = (center + VECTOR_X + SLIGHTLY_UP):ToScreen()
				DRAW_DIRECTION_TEXT_Y2 = (center + VECTOR_Y + SLIGHTLY_UP):ToScreen()
				DRAW_DIRECTION_TEXT_Z2 = (center + VECTOR_Z + SLIGHTLY_UP):ToScreen()
				SHOULD_DRAW_DIRECTIONS_TEXT2 = true
			end
		end
	end

	if DRAW_ANGLES:GetBool() and pDist < MAXIMAL_DRAW_DISTANCE:GetInt() then
		local pith = Angle(ang.p, 0, 0)
		local yaw = Angle(0, ang.y, 0)
		local roll = Angle(0, ang.y, ang.r)

		local pColor = Color(LINE_COLOR_ANGLES_P_RED:GetInt(), LINE_COLOR_ANGLES_P_GREEN:GetInt(), LINE_COLOR_ANGLES_P_BLUE:GetInt(), LINE_COLOR_ANGLES_P_ALPHA:GetInt())
		local yColor = Color(LINE_COLOR_ANGLES_Y_RED:GetInt(), LINE_COLOR_ANGLES_Y_GREEN:GetInt(), LINE_COLOR_ANGLES_Y_BLUE:GetInt(), LINE_COLOR_ANGLES_Y_ALPHA:GetInt())
		local rColor = Color(LINE_COLOR_ANGLES_R_RED:GetInt(), LINE_COLOR_ANGLES_R_GREEN:GetInt(), LINE_COLOR_ANGLES_R_BLUE:GetInt(), LINE_COLOR_ANGLES_R_ALPHA:GetInt())
		local dColor = Color(LINE_COLOR_ANGLES_RED:GetInt(), LINE_COLOR_ANGLES_GREEN:GetInt(), LINE_COLOR_ANGLES_BLUE:GetInt(), LINE_COLOR_ANGLES_ALPHA:GetInt())

		local center = Vector(dCenter)
		center:Rotate(ang)
		center = center + pos

		render.DrawLine(center - DELTA_PITH_VECTOR, center + DELTA_PITH_VECTOR, pColor, false)
		render.DrawLine(center - DELTA_YAW_VECTOR, center + DELTA_YAW_VECTOR, yColor, false)
		render.DrawLine(center - DELTA_ROLL_VECTOR, center + DELTA_ROLL_VECTOR, rColor, false)
		render.DrawLine(center, center + ang:Forward() * 20, dColor, false)

		cam.Start3D()
		cam.End3D()

		local toScreen = center:ToScreen()

		local W, H = ScrWL(), ScrHL()
		local Wh, Hh = W / 2, H / 2
		local x, y = toScreen.x, toScreen.y

		if x > Wh - 100 and x < Wh + 100 and y > Hh - 100 and y < Hh + 100 then
			DRAW_DIRECTION_TEXT_X3 = (center + DELTA_PITH_VECTOR + SLIGHTLY_DOWN):ToScreen()
			DRAW_DIRECTION_TEXT_Y3 = (center + DELTA_YAW_VECTOR + SLIGHTLY_DOWN):ToScreen()
			DRAW_DIRECTION_TEXT_Z3 = (center + DELTA_ROLL_VECTOR + SLIGHTLY_DOWN):ToScreen()
			DRAW_DIRECTION_TEXT_T3 = (center + ang:Forward() * 20 + SLIGHTLY_DOWN):ToScreen()
			SHOULD_DRAW_DIRECTIONS_TEXT3 = true
		end
	end
end

local function SimpleMixer(Panel, name, cvar)
	local collapse = vgui.Create('DCollapsibleCategory', Panel)
	Panel:AddItem(collapse)
	collapse:SetExpanded(false)
	collapse:SetLabel(name)

	local mixer = vgui.Create('DColorMixer', Panel)
	collapse:SetContents(mixer)
	mixer:SetConVarR(cvar .. '_r')
	mixer:SetConVarG(cvar .. '_g')
	mixer:SetConVarB(cvar .. '_b')
	mixer:SetConVarA(cvar .. '_a')
	mixer:SetAlphaBar(true)

	mixer:Dock(TOP)
	mixer:SetHeight(200)

	return collapse, mixer
end

function BuildMenu(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()

	local lab = Label('If you are an server owner and want to disable GTools draws\nyou need to set gtool_draw_sv to 0 in server console.', Panel)
	lab:SetDark(true)
	lab:SetTooltip(lab:GetText())
	lab:SizeToContents()
	Panel:AddItem(lab)

	Panel:CheckBox('Enable', 'gtool_draw')
	Panel:CheckBox('Disable HUD if server tells so', 'gtool_draw_obey')
	Panel:CheckBox('Draw coordinates near model world borders', 'gtool_draw_coordinates')
	Panel:CheckBox('Draw coordinates near model center', 'gtool_draw_coordinates_obb')
	Panel:CheckBox('Draw angles directions', 'gtool_draw_angles')
	Panel:CheckBox('Don\'t draw coordinates too close', 'gtool_draw_coordinates_obb_d')
	Panel:CheckBox('Draw model world space borders', 'gtool_draw_world_aabb')
	Panel:CheckBox('Draw model OBB borders', 'gtool_draw_obb')

	Panel:NumSlider('Maximal draw distance of angles display', 'gtool_draw_dist', 0, 4000, 0):SizeToContents()
	Panel:NumSlider('Maximal draw distance OBB box', 'gtool_draw_dist_obb', 0, 4000, 0):SizeToContents()
	Panel:NumSlider('Maximal draw distance world space AABB box', 'gtool_draw_dist_bb', 0, 4000, 0):SizeToContents()
	Panel:NumSlider('Minimal distance between coordinates lines', 'gtool_draw_dist_cmin', 0, 256, 0):SizeToContents()

	SimpleMixer(Panel, 'Colors for mins-maxs borders', 'gtool_line')
	SimpleMixer(Panel, 'Colors for model borders', 'gtool_line_r')
	SimpleMixer(Panel, 'X-Coordinate color', 'gtool_coord_x')
	SimpleMixer(Panel, 'Y-Coordinate color', 'gtool_coord_y')
	SimpleMixer(Panel, 'Z-Coordinate color', 'gtool_coord_z')

	SimpleMixer(Panel, 'Pith Line color', 'gtool_ang_p')
	SimpleMixer(Panel, 'Yaw Line color', 'gtool_ang_y')
	SimpleMixer(Panel, 'Roll Line color', 'gtool_ang_r')
	SimpleMixer(Panel, 'Prop angle color', 'gtool_ang')
end

hook.Add('PostDrawTranslucentRenderables', 'GTools.ScreenHelpers', PostDrawTranslucentRenderables)
hook.Add('HUDPaint', 'GTools.ScreenHelpers', HUDPaint)
hook.Add('PopulateToolMenu', 'GTools.ScreenHelpers', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'GTool.HUDMenu', 'GTool Draws', '', '', BuildMenu)
end)
