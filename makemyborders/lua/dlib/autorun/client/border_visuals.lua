
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


local surface = surface
local hook = hook
local system = system
local cam = cam
local render = render
local RealTimeL = RealTimeL
local draw = draw

local ENABLE_VISUALS = CreateConVar('cl_border_animation', '1', {FCVAR_ARCHIVE}, 'Animate the border')

local renderTarget

local workingMaterial = CreateMaterial('func_border_visual_mat2', 'UnlitGeneric', {
	['$basetexture'] = 'models/debug/debugwhite',
	['$translucent'] = '1',
	['$halflambert'] = '1',
})

local white = Material('models/debug/debugwhite')

_G.FUNC_BORDER_TEXTURE = workingMaterial

local function init()
	if renderTarget then return end

	renderTarget = GetRenderTarget('func_border_visual2', 512, 512)
	workingMaterial:SetTexture('$basetexture', renderTarget)
end

local borderAnimShift = 0
local lastThink
local borderGapSize = 51.17
local borderUnshift = 20 * borderGapSize
local borderRepeatValue = 0.2 * borderGapSize
local ready = false

local function RenderScene()
	if not system.IsLinux() and not system.HasFocus() then return end
	init()
	if ready and not ENABLE_VISUALS:GetBool() then return end

	local ctime = RealTimeL()
	lastThink = lastThink or ctime
	borderAnimShift = (borderAnimShift + (ctime - lastThink) * 4) % borderRepeatValue
	lastThink = ctime

	local xShift = borderAnimShift * 10

	render.PushRenderTarget(renderTarget)
	render.Clear(0, 0, 0, 0)
	cam.Start2D()

	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255)

	for i = -5, 7 do
		local start = i * borderGapSize * 2 + xShift

		if start >= 512 then
			start = start - borderUnshift
		end

		local shape = {
			{x = start, y = 0},
			{x = start + borderGapSize, y = 0},
			{x = start + borderGapSize * 7, y = 512},
			{x = start + borderGapSize * 6, y = 512},
		}

		surface.DrawPoly(shape)
	end

	cam.End2D()
	render.PopRenderTarget()
	ready = true
end

hook.Add('RenderScene', 'func_border_visuals', RenderScene, -10)
