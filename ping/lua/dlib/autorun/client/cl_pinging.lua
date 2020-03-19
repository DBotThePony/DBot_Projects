
-- Copyright (C) 2020 DBotThePony

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

local CSGOPinging = CSGOPinging
local DLib = DLib
local surface = surface
local net = net
local RealTime = RealTimeL
local math = math
local ipairs = ipairs
local table = table
local ScrW = ScrWL
local ScrH = ScrHL

surface.DLibCreateFont('CSGOPing_Distance', {
	font = 'Roboto',
	weight = 700,
	size = 14,
	extended = true
})

CSGOPinging.Pings = {}
CSGOPinging.TYPE_POSITION = 0
CSGOPinging.TYPE_ENTITY = 1
local MAX_SIZE = 160

local function get_size(w, h)
	if w > MAX_SIZE then
		h = (h / w) * MAX_SIZE
		w = MAX_SIZE
	end

	if h > MAX_SIZE then
		w = (w / h) * MAX_SIZE
		h = MAX_SIZE
	end

	if w / h > 0.5 and h / w > 0.5 then
		w = w * 0.5
		h = h * 0.5
	end

	return w:round(), h:round()
end

local function get_mult(dist)
	return 1 - math.clamp(dist:sqrt() / 60, 0, 0.8)
end

local function _Lerp(from, to, by)
	if from == to then return to end

	if from < to then
		return math.min(to, from + by)
	end

	return math.max(to, from - by)
end

local function clear_ply(ply)
	local toremove

	for i, entry in ipairs(CSGOPinging.Pings) do
		if entry.ply == ply then
			toremove = i
			break
		end
	end

	if toremove then
		table.remove(CSGOPinging.Pings, i)
	end
end

local function ping_position(ply, position)
	clear_ply(ply)

	local icon = hook.Run('CSGOPinging_ChoosePositionPingIcon', ply, position) or CSGOPinging.Materials.info
	local w, h = get_size(icon:Width(), icon:Height())
	local size = get_mult(DLib.HUDCommons.SelectPlayer():EyePos():Distance(position))

	table.insert(CSGOPinging.Pings, {
		type = CSGOPinging.TYPE_POSITION,
		color = ply:GetPlayerColor():ToColor(),
		ply = ply,
		pos = position,
		start = RealTime(),
		start_end_fade = RealTime() + 0.25,
		start_fade = RealTime() + 4,
		end_fade = RealTime() + 4.75,
		alpha = 0,
		w = w,
		w2 = w * size,
		h = h,
		h2 = h * size,
		size = size,
		icon = icon,
	})

	surface.PlaySound(hook.Run('CSGOPinging_ChoosePositionPingSound', ply, position) or CSGOPinging.Sound)
end

net.receive('csgoping_ping_position', function()
	local ply = net.ReadPlayer()
	if not IsValid(ply) then return end
	ping_position(ply, net.ReadVectorDouble())
end)

net.receive('csgoping_ping_entity', function()
	local ply = net.ReadPlayer()
	if not IsValid(ply) then return end
	local position = net.ReadVectorDouble()
	local ent = net.ReadEntity()
	local goup = net.ReadBool()

	if not IsValid(ent) then
		ping_position(ply, position)
		return
	end

	clear_ply(ply)

	local icon, goup2, addPos, shouldPutArrow = hook.Run('CSGOPing_HandleEntity', ply, position, ent, ent:GetClass())

	if icon == nil then
		icon = CSGOPinging.Materials.info
	end

	if goup2 == nil then
		goup2 = goup
	end

	if shouldPutArrow == nil then
		shouldPutArrow = goup
	end

	if goup2 then
		local center = ent:OBBCenter()
		local mins, maxs = ent:WorldSpaceAABB()
		position = ent:GetPos() + center
		position.z = math.max(position.z + center.z:abs() + 10, maxs.z + 3)
	end

	if addPos then
		position = position + addPos
	end

	local w, h = get_size(icon:Width(), icon:Height())
	local size = get_mult(DLib.HUDCommons.SelectPlayer():EyePos():Distance(position))

	table.insert(CSGOPinging.Pings, {
		type = CSGOPinging.TYPE_ENTITY,
		ent = ent,
		color = ply:GetPlayerColor():ToColor(),
		ply = ply,
		pos = position,
		arrow = shouldPutArrow,
		start = RealTime(),
		start_end_fade = RealTime() + 0.25,
		start_fade = RealTime() + 4,
		end_fade = RealTime() + 4.75,
		alpha = 0,
		w = w,
		w2 = w * size,
		h = h,
		h2 = h * size,
		size = size,
		icon = icon,
	})

	surface.PlaySound(hook.Run('CSGOPinging_ChoosePositionPingSound', ply, position) or CSGOPinging.Sound)
end)

hook.Add('Think', 'CSGOPinging.Think', function()
	local toremove
	local rtime = RealTime()
	local ply = DLib.HUDCommons.SelectPlayer()
	local pos = ply:EyePos()
	local ftime = RealFrameTime() * 66
	local w, h = ScrW(), ScrH()

	for i, entry in ipairs(CSGOPinging.Pings) do
		if entry.start_end_fade > rtime then
			entry.alpha = math.floor(rtime:progression(entry.start, entry.start_end_fade) * 255)
		elseif entry.end_fade > rtime then
			entry.alpha = math.floor(255 - rtime:progression(entry.start_fade, entry.end_fade) * 255)
		else
			toremove = toremove or {}
			table.insert(toremove, i)
			goto CONTINUE
		end

		--[[if entry.arrow then
			entry.arrow_poly = {
				{}
			}
		end]]

		entry.size = _Lerp(entry.size, get_mult(entry.pos:Distance(pos)), ftime)
		entry.w2 = entry.w * entry.size
		entry.h2 = entry.h * entry.size
		::CONTINUE::
	end

	if toremove then
		table.removeValues(CSGOPinging.Pings, toremove)
	end
end)

local render = render
local TEXFILTER = TEXFILTER

hook.Add('HUDPaint', 'CSGOPinging.Draw', function()
	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)

	draw.NoTexture()

	for i, entry in ipairs(CSGOPinging.Pings) do
		surface.SetMaterial(entry.icon)
		local pos = entry.pos:ToScreen()

		surface.SetDrawColor(0, 0, 0, entry.alpha / 2)
		surface.DrawTexturedRect(pos.x - entry.w2 / 2 + 2, pos.y - entry.h2 / 2 + 2, entry.w2, entry.h2)

		surface.SetDrawColor(entry.color.r, entry.color.g, entry.color.b, entry.alpha)
		surface.DrawTexturedRect(pos.x - entry.w2 / 2, pos.y - entry.h2 / 2, entry.w2, entry.h2)

		if entry.arrow_poly then

		end
	end

	render.PopFilterMag()
	render.PopFilterMin()
end)

concommand.Add('csgo_ping', function(ply)
	local tr = ply:GetEyeTrace()

	if not IsValid(tr.Entity) then
		net.Start('csgoping_ping_position')
		net.WriteVectorDouble(tr.HitPos)
		net.WriteVectorDouble(tr.StartPos)
		net.WriteVectorDouble(tr.HitPos - tr.HitNormal * 10)
		net.SendToServer()
	else
		net.Start('csgoping_ping_entity')
		net.WriteVectorDouble(tr.HitPos)
		net.WriteEntity(tr.Entity)
		net.SendToServer()
	end
end)

include('csgo_ping/cl_registry.lua')
