
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

local ENABLE = CreateConVar('cl_csgoping', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Enable CS:GO Pinging')
local ENABLE_SV = CreateConVar('sv_csgoping', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable CS:GO Pinging')

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
		table.remove(CSGOPinging.Pings, toremove)
	end
end

local function ping_position(ply, position)
	clear_ply(ply)

	local icon = hook.Run('CSGOPinging_ChoosePositionPingIcon', ply, position) or CSGOPinging.Materials.info

	local w, h

	if istable(icon) then
		w, h = get_size(icon[2], icon[3])
		icon = icon[1]
	else
		w, h = get_size(icon:Width(), icon:Height())
	end

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
		should_lerp = true,
		next_lerp = false,
	})

	surface.PlaySound(hook.Run('CSGOPinging_ChoosePositionPingSound', ply, position) or CSGOPinging.Sound)
end

net.receive('csgoping_ping_position', function()
	if not ENABLE:GetBool() or not ENABLE_SV:GetBool() then return end
	local ply = net.ReadPlayer()
	if not IsValid(ply) then return end
	ping_position(ply, net.ReadVectorDouble())
end)

net.receive('csgoping_ping_entity', function()
	if not ENABLE:GetBool() or not ENABLE_SV:GetBool() then return end
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
		shouldPutArrow = goup or addPos ~= nil
	end

	local arrow_target

	if goup2 then
		local center = ent:OBBCenter()
		center:Rotate(ent:EyeAngles())
		local mins, maxs = ent:WorldSpaceAABB()
		local epos = ent:GetPos()
		position = epos + center
		position.z = math.max(position.z + center.z:abs() + 10, maxs.z + 3)
		arrow_target = position + center
	end

	local flip_arrow = false

	if addPos then
		position = position + addPos
	end

	if not arrow_target and shouldPutArrow then
		local center = ent:OBBCenter()
		center:Rotate(ent:EyeAngles())
		arrow_target = position + center
	end

	if arrow_target then
		flip_arrow = arrow_target.z < position.z
	end

	local w, h

	if istable(icon) then
		w, h = get_size(icon[2], icon[3])
		icon = icon[1]
	else
		w, h = get_size(icon:Width(), icon:Height())
	end

	local dist = DLib.HUDCommons.SelectPlayer():EyePos():Distance(position)
	local size = get_mult(dist)

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
		should_lerp = true,
		next_lerp = false,
		arrow_target = arrow_target,
		flip_arrow = flip_arrow,
		dist = dist,
	})

	surface.PlaySound(hook.Run('CSGOPinging_ChoosePositionPingSound', ply, position) or CSGOPinging.Sound)
end)

hook.Add('Think', 'CSGOPinging.Think', function()
	if not ENABLE:GetBool() or not ENABLE_SV:GetBool() then return end

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

		entry.dist = entry.pos:Distance(pos)
		entry.size = _Lerp(entry.size, get_mult(entry.dist), ftime)
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
local ARROW_WIDE = 4
local ARROW_POINTER_WIDE = 16
local ARROW_POINTER_HIGH = 8

hook.Add('HUDPaint', 'CSGOPinging.Draw', function()
	if not ENABLE:GetBool() or not ENABLE_SV:GetBool() then return end

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)

	draw.NoTexture()

	local ftime = RealFrameTime() * 22

	local w, h = ScrW(), ScrH()
	local wide, high = w / 2.1, h / 2.1
	local w2, h2 = w / 2, h / 2

	for i, entry in ipairs(CSGOPinging.Pings) do
		local pos = entry.pos:ToScreen()
		local x, y = pos.x, pos.y
		local arrow

		local aX, aY = w2 - x, h2 - y
		local deg = (aX / (aX:pow(2) + aY:pow(2)):sqrt()):acos()
		local len = math.sqrt(math.pow(aX, 2) + math.pow(aY, 2))
		local normalizeX = aX / len
		local normalizeY = aY / len

		local px = w2 - normalizeX * wide
		local py = h2 - normalizeY * high
		local offscreen = x < w2 - wide or y < h2 - high or x > w2 + wide or y > h2 + high

		if offscreen then
			x, y = px, py

			local size = entry.w2:min(entry.h2) / 2
			local sizeh = size * 1.35

			arrow = {
				{x = 0, y = -sizeh / 2},
				{x = size / 2, y = sizeh / 1.4},
				{x = 0, y = sizeh / 2},
				{x = -size / 2, y = sizeh / 1.4},
				{x = 0, y = sizeh / 1.4 + entry.w2:max(entry.h2)},
			}

			local deg = deg:deg()

			if aY < 0 then
				deg = -deg
			end

			DLib.HUDCommons.RotatePolyMatrix(arrow, deg - 90)
			--entry.should_lerp = true
		end

		--if entry.should_lerp then
			entry.p_x = Lerp(ftime, entry.p_x or x, x)
			entry.p_y = Lerp(ftime, entry.p_y or y, y)
			--entry.should_lerp = math.floor(entry.p_x * 1000) ~= math.floor(x * 1000) or  math.floor(entry.p_y * 1000) ~=  math.floor(y * 1000)
		--[[else
			entry.p_x = x
			entry.p_y = y
		end]]

		x, y = entry.p_x, entry.p_y

		if arrow then
			DLib.HUDCommons.TranslatePolyMatrix(arrow, x, y)
			local last = table.remove(arrow)
			x, y = last.x, last.y

			draw.NoTexture()

			surface.SetDrawColor(0, 0, 0, entry.alpha / 2)
			surface.DrawPoly(arrow)
			DLib.HUDCommons.TranslatePolyMatrix(arrow, -2, -2)
			surface.SetDrawColor(entry.color.r, entry.color.g, entry.color.b, entry.alpha)
			surface.DrawPoly(arrow)
		end

		surface.SetMaterial(entry.icon)

		surface.SetDrawColor(0, 0, 0, entry.alpha / 2)
		surface.DrawTexturedRect(x - entry.w2 / 2 + 2, y - entry.h2 / 2 + 2, entry.w2, entry.h2)

		surface.SetDrawColor(entry.color.r, entry.color.g, entry.color.b, entry.alpha)
		surface.DrawTexturedRect(x - entry.w2 / 2, y - entry.h2 / 2, entry.w2, entry.h2)

		--[[if entry.arrow and entry.arrow_target and not offscreen then
			y = entry.flip_arrow and (y + entry.h2 * 0.77) or (y + entry.h2 / 2)
			local pos = entry.arrow_target:ToScreen()
			local x2, y2 = pos.x, pos.y
			local arrow_len = entry.flip_arrow and (y2 - y):abs() or (y - y2)

			if arrow_len > 1 then
				draw.NoTexture()
				surface.SetDrawColor(0, 0, 0, entry.alpha / 2)
				local _h = arrow_len - ARROW_POINTER_HIGH

				if entry.flip_arrow then

					local arrow = {
						{x = x + ARROW_POINTER_WIDE / 2 * entry.size - 2, y = y - (arrow_len * 2 - ARROW_POINTER_HIGH)},
						{x = x - ARROW_POINTER_WIDE / 2 * entry.size - 2, y = y - (arrow_len * 2 - ARROW_POINTER_HIGH)},
						{x = x - 2, y = y - arrow_len * 2},
					}

					surface.SetDrawColor(entry.color.r, entry.color.g, entry.color.b, entry.alpha)
					surface.DrawPoly(arrow)
					surface.DrawRect(x - (ARROW_WIDE / 2) * entry.size - 2, y - 2 - _h * 2 - 8, ARROW_WIDE * entry.size, _h + 4)
				else
					local arrow = {
						{x = x + ARROW_POINTER_WIDE / 2 * entry.size, y = y + _h},
						{x = x - 1, y = y + arrow_len},
						{x = x - ARROW_POINTER_WIDE / 2 * entry.size - 1, y = y + _h},
					}

					surface.DrawPoly(arrow)
					surface.DrawRect(x - (ARROW_WIDE / 2) * entry.size, y, ARROW_WIDE * entry.size, (_h + 4))
					DLib.HUDCommons.TranslatePolyMatrix(arrow, -2, -2)
					surface.SetDrawColor(entry.color.r, entry.color.g, entry.color.b, entry.alpha)
					surface.DrawPoly(arrow)
					surface.DrawRect(x - (ARROW_WIDE / 2) * entry.size - 2, y - 2, ARROW_WIDE * entry.size, (_h + 4))
				end
			end
		end]]
	end

	render.PopFilterMag()
	render.PopFilterMin()
end)

concommand.Add('csgo_ping', function(ply)
	if not ENABLE:GetBool() or not ENABLE_SV:GetBool() then return end

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
