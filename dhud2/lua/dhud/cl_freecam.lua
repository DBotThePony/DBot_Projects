
--Freecam

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

local ENABLE = CreateConVar('dhud_freecam', '1', FCVAR_ARCHIVE, 'Enable freecam (IDLE cam)')
DHUD2.AddConVar('dhud_freecam', 'Enable freecam (IDLE cam)', ENABLE)

DHUD2.Freecam = DHUD2.Freecam or {}
local Cam = DHUD2.Freecam

local self = {}
Cam.self = self

Cam.Funcs = {
	{
		render = function(ply, ang, pos)
			return ang, pos - ang:Forward() * DHUD2.Multipler
		end,

		setup = function(ply, ang, pos)
			return ang, pos
		end,

		time = 1,
		pause = 3,
	},
	{
		render = function(ply, ang, pos)
			return ang, pos
		end,

		setup = function(ply, ang, pos)
			local nang = Angle(0, ang.y + 90, 0)
			local add = Vector(120, 0, 0)
			add:Rotate(nang)

			nang.y = nang.y - 180
			return nang, util.TraceHull({
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 4),
				start = pos,
				filter = ply,
				endpos = pos + add
			}).HitPos
		end,

		time = 0,
		pause = 3,
	},
	{
		render = function(ply, ang, pos)
			local eyes = ply:LookupAttachment('eyes')

			if eyes and eyes ~= 0 then
				local d = ply:GetAttachment(eyes)
				d.Pos = d.Pos + d.Ang:Forward() * 3

				return d.Ang, d.Pos
			end

			return ang, pos
		end,

		setup = function(ply, ang, pos)
			return ang, pos
		end,

		time = 3,
		pause = 0,
	},
	{
		render = function(ply, ang, pos)
			self.AngleShift = self.AngleShift + 1 * DHUD2.Multipler
			local nang = Angle(0, self.RealAng.y + 90 + self.AngleShift, 0)
			local add = Vector(120, 0, 0)
			add:Rotate(nang)

			local npos = self.RealPos + add
			local delta = (self.RealPos - npos):Angle()

			return delta, util.TraceHull({
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 4),
				start = self.RealPos,
				filter = ply,
				endpos = npos
			}).HitPos
		end,

		setup = function(ply, ang, pos)
			self.RealAng = ang
			self.RealPos = pos
			self.AngleShift = 0

			return ang, pos
		end,

		time = 6,
		pause = 0,
	},
	{
		render = function(ply, ang, pos)
			return delta, npos
		end,

		setup = function(ply, ang, pos)
			local tr = ply:GetEyeTrace()
			local delta = (pos - tr.HitPos):Angle()
			return delta, tr.HitPos + tr.HitNormal
		end,

		time = 0,
		pause = 4,
	},
	{
		render = function(ply, ang, pos)
			return delta, npos
		end,

		setup = function(ply, ang, pos)
			local nang = Angle(0, ang.y, 0)
			local add = Vector(0, 10, 10)
			local npos = pos + add

			return ang, npos
		end,

		time = 0,
		pause = 4,
	},
	{
		render = function(ply, ang, pos)
			return delta, npos
		end,

		setup = function(ply, ang, pos)
			return Angle(90, 0, 0), util.TraceHull({
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 4),
				start = pos,
				filter = ply,
				endpos = pos + Vector(0, 0, 120)
			}).HitPos
		end,

		time = 0,
		pause = 3,
	},
}

local TOTAL = #Cam.Funcs
local CURRENT = 6

local DELAY = 120
local NextView = CurTimeL() + DELAY
local Active = false

local function Reset()
	CURRENT = 1
	Active = false
	NextView = CurTimeL() + DELAY
end

local function KeyPress(ply)
	if ply ~= DHUD2.SelectPlayer() then return end
	Reset()
end

local CalcData = {}

local function CalcView(ply, pos, ang, fov, z1, z2)
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('freecam') then return end
	if not DHUD2.IsEnabled() then return end
	if not Active then return end

	CalcData.fov = fov
	CalcData.znear = z1
	CalcData.zfar = z2
	CalcData.drawviewer = true

	return CalcData
end

local NextPause = 0
local NextRender = 0

local function Think()
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('freecam') then return end
	if not DHUD2.IsEnabled() then return end

	local ply = DHUD2.SelectPlayer()
	if not IsValid(ply) then return end
	if ply ~= LocalPlayer() then return end --Spectating
	if LocalPlayer():ShouldDrawLocalPlayer() then return end

	local ang = ply:EyeAngles()
	local epos = ply:EyePos()

	if NextView < CurTimeL() and not Active then
		local get1 = ply:EyeAngles()
		local get2 = EyePos()

		if get2 ~= get1 then
			Active = false
			NextView = CurTimeL() + DELAY
		end

		CalcData.origin = epos
		CalcData.angles = ang
		Active = true
	end

	if not Active then return end

	if ply:InVehicle() then
		Reset()
		return
	end

	local data = Cam.Funcs[CURRENT]

	if NextRender > CurTimeL() then
		local nang, npos = data.render(ply, CalcData.angles, CalcData.origin)
		CalcData.angles = nang
		CalcData.origin = npos
	end

	if NextPause < CurTimeL() then
		CURRENT = CURRENT + 1

		if CURRENT > TOTAL then
			CURRENT = 1
		end

		local ndata = Cam.Funcs[CURRENT]
		local nang, npos = ndata.setup(ply, ang, epos)
		CalcData.angles = nang
		CalcData.origin = npos

		NextRender = ndata.time + CurTimeL()
		NextPause = ndata.time + CurTimeL() + ndata.pause
	end
end

local function Draw()
	if not Active then return end

	local x, y = DHUD2.GetPosition('freecam_notify')

	DHUD2.WordBox('Freecam Mode. Press any key to stop freecam mode.', 'DHUD2.Default', x, y, DHUD2.GetColor('generic'), DHUD2.GetColor('bg'), true)
end

DHUD2.DefinePosition('freecam_notify', ScrWL() / 2, ScrHL() / 2 - 40)

DHUD2.DrawHook('Freecam', Draw)

hook.Add('KeyPress', 'DHUD2.Freecam', KeyPress)
hook.Add('Think', 'DHUD2.Freecam', Think)
hook.Add('CalcView', '!DHUD2.Freecam', CalcView, -1) --Freecam must override all calc views, for example SharpEYE
