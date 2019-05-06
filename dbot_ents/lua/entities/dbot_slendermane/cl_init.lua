
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

include('shared.lua')

language.Add('dbot_slendermane', 'Slendermane')

local debugwtite = Material('models/debug/debugwhite')

function ENT:Draw()
	if not self.GetIsVisible then return end
	if LocalPlayer() ~= DBot_GetDBot() and not self:GetIsVisible() then return end
	render.SuppressEngineLighting(true)
	render.ModelMaterialOverride(debugwtite)
	render.ResetModelLighting(1, 1, 1)
	render.SetColorModulation(0, 0, 0)

	self:DrawModel()

	render.ModelMaterialOverride()
	render.SuppressEngineLighting(false)
end

function ENT:Think()
	self.LastFrame = self.LastFrame or CurTimeL()
	self:FrameAdvance(CurTimeL() - self.LastFrame)
	self.LastFrame = CurTimeL()
end

local oldStatus = false

local stages = {
	'https://dbot.serealia.ca/custom/content/sound/onetwo.ogg',
	'https://dbot.serealia.ca/custom/content/sound/threefour.ogg',
	'https://dbot.serealia.ca/custom/content/sound/fivesix.ogg',
	'https://dbot.serealia.ca/custom/content/sound/seven.ogg',
}

local Phrases = {
	'What was that noise? Something is behind you.',
	'Something is behind you.',
	'Something is behind you. Might it is time to stop.',
	'Might it is time to stop.',
	'Strange whispers are around you.',
}

local DisplayUntil = 0
local LastPlay = 0

local ColorModifier = {
	['$pp_colour_addr'] = 0,
	['$pp_colour_addg'] = 0,
	['$pp_colour_addb'] = 0,
	['$pp_colour_brightness'] = 0,
	['$pp_colour_contrast'] = 0.9,
	['$pp_colour_colour'] = 0,
	['$pp_colour_mulr'] = 0,
	['$pp_colour_mulg'] = 0,
	['$pp_colour_mulb'] = 0
}

local function Headache()
	sound.PlayURL('https://dbot.serealia.ca/custom/content/sound/thaumcraft/heartbeat.ogg', '', function()
		chat.AddText(table.Random(Phrases), '')
		DisplayUntil = CurTimeL() + 7
	end)
end

local function RenderScreenspaceEffects()
	if DisplayUntil + 3 < CurTimeL() then return end

	local multipler = math.min(1, (DisplayUntil - CurTimeL() + 3) / 3)

	if multipler == 1 then
		ColorModifier['$pp_colour_colour'] = math.abs(math.sin(CurTimeL() * 4) * .5)
	else
		ColorModifier['$pp_colour_colour'] = Lerp(.8, ColorModifier['$pp_colour_colour'], 1 - multipler)
	end

	DrawColorModify(ColorModifier)
end

local Current = 1
DBot_SlenderStreams = DBot_SlenderStreams or {}

for k, v in ipairs(DBot_SlenderStreams) do
	if IsValid(v) then
		v:Stop()
	end
end

DBot_SlenderStreams = {}

local function Stop()
	for k, stream in pairs(DBot_SlenderStreams) do
		if IsValid(stream) then
			stream:Stop()
		end
	end

	timer.Stop('DBot_SlenderStreams_Headache')
	timer.Stop('DBot_SlenderStreams')
end

Stop()

local function Begin()
	Current = 1

	DBot_SlenderStreams[Current]:Play()
	DBot_SlenderStreams[Current]:EnableLooping(true)

	timer.Create('DBot_SlenderStreams_Headache', 1, 0, function()
		if math.random(1, 100) <= 5 and LastPlay + 30 < CurTimeL() then
			LastPlay = CurTimeL()
			Headache()
		end
	end)

	timer.Create('DBot_SlenderStreams', 20, 4, function()
		Current = Current + 1

		if Current < #stages then
			local prev = DBot_SlenderStreams[Current - 1]

			if prev and IsValid(prev) then
				prev:Stop()
			end

			DBot_SlenderStreams[Current]:Play()
			DBot_SlenderStreams[Current]:EnableLooping(true)
		end
	end)
end

for k, v in ipairs(stages) do
	sound.PlayURL(v, 'noplay noblock', function(stream)
		table.insert(DBot_SlenderStreams, stream)
	end)
end

hook.Add('RenderScreenspaceEffects', 'Headache', RenderScreenspaceEffects)

local NoiseStream

sound.PlayURL('https://dbot.serealia.ca/custom/content/sound/camera_static/closeup_short.ogg', 'noplay noblock', function(stream)
	NoiseStream = stream
end)

net.Receive('Slendermane.StatusChanges', function()
	local status = net.ReadBool()

	if status then
		chat.AddText(color_white, 'SLENDERMANE IS CHASING Y.O.U')
		Begin()
	else
		chat.AddText(color_white, 'Slendermane no longer chasing you')
		Stop()
	end
end)

net.Receive('Slendermane.DEAD', function()
	if IsValid(NoiseStream) then
		NoiseStream:Play()
	end
end)
