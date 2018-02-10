
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local surface = surface
local hook = hook
local system = system
local cam = cam
local render = render
local RealTime = RealTime
local draw = draw

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
local borderGapSize = 40
local borderUnshift = 20 * borderGapSize
local borderRepeatValue = 0.2 * borderGapSize

local function RenderScene()
	if not system.IsLinux() and not system.HasFocus() then return end
	init()

	local ctime = RealTime()
	lastThink = lastThink or ctime
	borderAnimShift = (borderAnimShift + (ctime - lastThink) * 4) % borderRepeatValue
	lastThink = ctime

	local xShift = borderAnimShift * 10

	render.PushRenderTarget(renderTarget)
	render.Clear(0, 0, 0, 0)
	cam.Start2D()

	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255)

	for i = -4, 6 do
		local start = i * borderGapSize * 2 + xShift

		if start >= 512 then
			start = start - borderUnshift
		end

		local shape = {
			{x = start, y = 0},
			{x = start + borderGapSize, y = 0},
			{x = start + borderGapSize * 8, y = 512},
			{x = start + borderGapSize * 7, y = 512},
		}

		surface.DrawPoly(shape)
	end

	cam.End2D()
	render.PopRenderTarget()
end

hook.Add('RenderScene', 'func_border_visuals', RenderScene, -10)
