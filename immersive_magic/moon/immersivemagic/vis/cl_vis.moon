
-- Copyright (C) 2018-2019 DBot

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

VISUALIZATE = CreateConVar('cl_im_visualizate', 0, {FCVAR_ARCHIVE}, 'Visualizate Vis map')

import render, surface, IMagic, DLib, math from _G
import ScrWL, ScrHL from _G
import HUDCommons from DLib

ANG = Angle()
VIS_COLOR = Color(247, 126, 255, 80)
FLUX_COLOR = Color(106, 6, 255, 80)
VIS_LIMIT_COLOR = Color(18, 255, 0, 180)
VIS_COLOR_RENDER = Color(255, 157, 245, 60)
FLUX_COLOR_RENDER = Color(104, 42, 207, 130)
DRAW_BOX = Color(255, 209, 150, 80)

HUDPaint = ->
	return if not IMagic.CURRENT_MAP
	x = 0
	y = ScrHL() * 0.08
	height = ScrHL() * 0.18
	height2 = ScrHL() * 0.17
	paddingY = (height - height2) / 2
	width = ScrWL() * 0.017
	width2 = ScrWL() * 0.015
	paddingX = (width - width2) / 2

	cell = IMagic.CURRENT_MAP\MapToVis(LocalPlayer()\GetPos())
	return if not cell

	surface.SetDrawColor(DRAW_BOX)
	surface.DrawRect(x, y, width, height)

	total = cell\GetVis() + cell\GetFlux()
	visMult = (math.log10(cell\GetVis()) / 5)\clamp(0, 1)
	visLimitMult = (math.log10(cell\GetVisLimit()) / 5)\clamp(0, 1)
	fluxMult = (math.log10(cell\GetFlux()) / 12)\clamp(0, 1)

	surface.SetDrawColor(VIS_COLOR)
	surface.DrawRect(x + paddingX, y + height2 - height2 * visMult, width2, height2 * visMult)

	surface.SetDrawColor(FLUX_COLOR)
	surface.DrawRect(x + paddingX, y + height2 - height2 * (visMult + fluxMult), width2, height2 * fluxMult)

	surface.SetDrawColor(VIS_LIMIT_COLOR)
	surface.DrawLine(x, y + height2 - height2 * visLimitMult, x + width, y + height2 - height2 * visLimitMult)


PostDrawTranslucentRenderables = (a, b) ->
	return if a or b
	return if not VISUALIZATE\GetBool()
	return if not IMagic.CURRENT_MAP

	render.SetColorMaterial()
	for _, cell in pairs(IMagic.CURRENT_MAP.heap)
		center = cell\WorldCenter()
		mins, maxs = cell\LocalAABB(0, 400)
		maxs.z = cell\GetVis() * 2
		render.DrawBox(center, ANG, mins, maxs, VIS_COLOR_RENDER, true)
		mins, maxs = cell\LocalAABB(cell\GetVis() * 2, 500)
		maxs.z = cell\GetVis() * 2 + cell\GetFlux() * 2
		render.DrawBox(center, ANG, mins, maxs, FLUX_COLOR_RENDER, true)

hook.Add 'PostDrawTranslucentRenderables', 'ImmersiveMagic.VisualizateVis', PostDrawTranslucentRenderables
hook.Add 'HUDPaint', 'ImmersiveMagic.VisualizateVis', HUDPaint
