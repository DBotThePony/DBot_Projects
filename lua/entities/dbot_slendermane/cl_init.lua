
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

local debugwtite = Material('models/debug/debugwhite')

function ENT:Draw()
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
	self:FrameAdvance(CurTime() - self.LastFrame)
	self.LastFrame = CurTime()
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
		DisplayUntil = CurTime() + 7
	end)
end

local function RenderScreenspaceEffects()
	if DisplayUntil + 3 < CurTime() then return end
	
	local multipler = math.min(1, (DisplayUntil - CurTime() + 3) / 3)
	
	if multipler == 1 then
		ColorModifier['$pp_colour_colour'] = math.abs(math.sin(CurTime() * 4) * .5)
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

local function Begin()
	Current = 1
	
	DBot_SlenderStreams[Current]:Play()
	DBot_SlenderStreams[Current]:EnableLooping(true)
	
	timer.Create('DBot_SlenderStreams_Headache', 1, 0, function()
		if math.random(1, 100) <= 5 and LastPlay + 30 < CurTime() then
			LastPlay = CurTime()
			Headache()
		end
	end)
	
	timer.Create('DBot_SlenderStreams', 60, 4, function()
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
	local ent = net.ReadEntity()
	local status = net.ReadBool()
	if status == oldStatus then return end
	
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
