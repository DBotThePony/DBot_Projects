
-- Copyright (C) 2015-2017 DBot

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

local BLACK = Color(0, 0, 0)

local function Start()
	if IsValid(BloodMoonSound) then
		BloodMoonSound:Stop()
	end

	sound.PlayURL("http://80.83.200.79/music_repository/terraria_ost_flac_1408392145/Terraria%20Original%20Soundtrack/Eerie.ogg", "", function(channel)
		BloodMoonSound = channel
	end)

	chat.AddText(Color(119, 205, 106), "The Blood Moon is rising...")
end

local function StartEclipse()
	if IsValid(BloodMoonSound) then
		BloodMoonSound:Stop()
	end

	sound.PlayURL("http://80.83.200.79/music_repository/terraria_volumetwo_flac_1408392145/Terraria%20Original%20Soundtrack%20Vol.%202/Eclipse.ogg", "", function(channel)
		BloodMoonSound = channel
	end)

	chat.AddText(Color(119, 205, 106), "A solar eclipse is happening!")
end

local function End()
	if IsValid(BloodMoonSound) then
		BloodMoonSound:Stop()
	end

	chat.AddText(Color(119, 205, 106), "Blood Moon has ended!")
end

local function EndEclipse()
	if IsValid(BloodMoonSound) then
		BloodMoonSound:Stop()
	end

	chat.AddText(Color(119, 205, 106), "A solar eclipse has ended!")
end

net.Receive("DBot.BloodMoon", function()
	local action = net.ReadBool()
	if action then Start() else End() end
end)

net.Receive("DBot.Eclipse", function()
	local action = net.ReadBool()
	if action then StartEclipse() else EndEclipse() end
end)

local fogstart = 100
local fogend = 750

local function SetupSkyboxFog(scale)
	if not GetGlobalBool("DBot.BloodMoon") then return end
	render.FogMode(1)
	render.FogStart(fogstart*scale)
	render.FogEnd(fogend*scale)
	render.FogMaxDensity(1)
	render.FogColor(20, 0, 0)
	return true
end

local function SetupWorldFog(scale)
	if not GetGlobalBool("DBot.BloodMoon") then return end
	render.FogMode(1)
	render.FogStart(fogstart)
	render.FogEnd(fogend)
	render.FogMaxDensity(1)
	render.FogColor(20, 0, 0)
	return true
end

local function PostDraw2DSkyBox()
	if not GetGlobalBool("DBot.BloodMoon") and not GetGlobalBool("DBot.Eclipse") then return end

	render.OverrideDepthEnable(true, false)

	cam.Start3D(Vector(0, 0, 0), EyeAngles())
	render.DrawQuadEasy(Vector(0, 0, 10), Vector(0, 0, -1), 512, 512, BLACK, 0)
	render.DrawQuadEasy(Vector(64, 64, 0), Vector(-1, 0, 0), 512, 512, BLACK, 0)
	render.DrawQuadEasy(Vector(-64, 64, 0), Vector(0, -1, 0), 512, 512, BLACK, 0)
	render.DrawQuadEasy(Vector(-64, -64, 0), Vector(1, 0, -1), 512, 512, BLACK, 0)
	render.DrawQuadEasy(Vector(64, -64, 0), Vector(0, 1, 0), 512, 512, BLACK, 0)
	cam.End3D()

	render.OverrideDepthEnable(false, false)
end

hook.Add("SetupSkyboxFog", "DBot.BloodMoon", SetupSkyboxFog)
hook.Add("SetupWorldFog", "DBot.BloodMoon", SetupWorldFog)
hook.Add("PostDraw2DSkyBox", "BloodMoon", PostDraw2DSkyBox)

local fogstart = 100
local fogend = 500

local function SetupWorldFog(scale)
	if not GetGlobalBool("DBot.Eclipse") then return end
	render.FogMode(1)
	render.FogStart(fogstart)
	render.FogEnd(fogend)
	render.FogMaxDensity(1)
	render.FogColor(0, 0, 0)
	return true
end

local function SetupSkyboxFog(scale)
	if not GetGlobalBool("DBot.Eclipse") then return end
	render.FogMode(1)
	render.FogStart(fogstart*scale)
	render.FogEnd(fogend*scale)
	render.FogMaxDensity(1)
	render.FogColor(0, 0, 0)
	return true
end

hook.Add("SetupSkyboxFog", "DBot.Eclipse", SetupSkyboxFog)
hook.Add("SetupWorldFog", "DBot.Eclipse", SetupWorldFog)
