
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

local mc = MCSWEP2

local function SimpleBlock(pos, ply, id, spawned, ignorenonopaque, skin)
	local update = mc.UpdateVector(pos)
	if not mc.IsPosFreeFromBlock(update, ignorenonopaque) then return end
	mc.ClearPositionFromBlocks(update)

	skin = skin or 0

	local ent = ents.Create('dbot_mcblock')

	ent:SetPos(update)
	ent:SetupOwner(ply)
	ent:Spawn()
	ent:Activate()
	ent:InitializeBlockID(id)
	ent:FixedMove()
	ent:SetSkin(skin)

	table.insert(spawned, ent)
	return ent
end

local function OakSappling(self)
	local log = mc.GetBlockByName('wood')
	local leaves = mc.GetBlockByName('leaves')

	local pos = self:GetPos()
	local ply = self:GetNWOwner()

	local tpos = mc.TranslateVector(pos)

	local spawned = {}

	local height = math.random(3, 5)

	for i = 1, height do
		local rpos = Vector(tpos.x, tpos.y, tpos.z + i - 1)
		SimpleBlock(rpos, ply, log, spawned, true)
	end

	local top = Vector(tpos.x, tpos.y, tpos.z + height)

	for i = 1, 2 do
		local rpos = Vector(top.x, top.y, top.z + i - 1)
		SimpleBlock(rpos, ply, leaves, spawned)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD), ply, leaves, spawned)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD), ply, leaves, spawned)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned)
	end

	do
		local rpos = Vector(top.x, top.y, top.z)

		if math.random(1, 2) == 1 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD) + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD) + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD) + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD) + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned)
		end
	end

	local brushradius = 2

	local blevel = top - Vector(0, 0, 1)
	for z = -1, 0 do
		for x = -brushradius, brushradius do
			for y = -brushradius, brushradius do
				local cond = ((x == brushradius and y == brushradius) or
					(x == -brushradius and y == -brushradius) or
					(x == brushradius and y == -brushradius) or
					(x == -brushradius and y == brushradius)) and
					(z == -1)

				if cond then
					if math.random(1, 2) ~= 1 then continue end
				end

				SimpleBlock(blevel + Vector(x, y, z), ply, leaves, spawned)
			end
		end
	end

	if IsValid(ply) then
		undo.Create('MCTree')
		undo.SetPlayer(ply)
		for k, v in ipairs(spawned) do
			undo.AddEntity(v)
		end
		undo.Finish()
	end
end

local function BirchSappling(self)
	local log = mc.GetBlockByName('wood')
	local leaves = mc.GetBlockByName('leaves')

	local pos = self:GetPos()
	local ply = self:GetNWOwner()

	local tpos = mc.TranslateVector(pos)

	local spawned = {}

	local height = math.random(4, 6)

	for i = 1, height do
		local rpos = Vector(tpos.x, tpos.y, tpos.z + i - 1)
		SimpleBlock(rpos, ply, log, spawned, true, 1)
	end

	local top = Vector(tpos.x, tpos.y, tpos.z + height)

	SimpleBlock(top, ply, log, spawned, true, 1)

	for i = 1, 2 do
		local rpos = Vector(top.x, top.y, top.z + i - 1)
		SimpleBlock(rpos, ply, leaves, spawned, nil, 2)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD), ply, leaves, spawned, nil, 2)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD), ply, leaves, spawned, nil, 2)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned, nil, 2)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned, nil, 2)
	end

	do
		local rpos = Vector(top.x, top.y, top.z)

		if math.random(1, 2) == 1 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD) + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned, nil, 2)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD) + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned, nil, 2)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD) + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned, nil, 2)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD) + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned, nil, 2)
		end
	end

	local brushradius = 2

	local blevel = top - Vector(0, 0, 1)
	for z = -1, 0 do
		for x = -brushradius, brushradius do
			for y = -brushradius, brushradius do
				local cond = ((x == brushradius and y == brushradius) or
					(x == -brushradius and y == -brushradius) or
					(x == brushradius and y == -brushradius) or
					(x == -brushradius and y == brushradius)) and
					(z == -1)

				if cond then
					if math.random(1, 2) ~= 1 then continue end
				end

				SimpleBlock(blevel + Vector(x, y, z), ply, leaves, spawned, nil, 2)
			end
		end
	end

	if IsValid(ply) then
		undo.Create('MCTree')
		undo.SetPlayer(ply)
		for k, v in ipairs(spawned) do
			undo.AddEntity(v)
		end
		undo.Finish()
	end
end

local function PineSappling(self)
	local log = mc.GetBlockByName('wood')
	local leaves = mc.GetBlockByName('leaves')

	local pos = self:GetPos()
	local ply = self:GetNWOwner()

	local tpos = mc.TranslateVector(pos)

	local spawned = {}

	local height = math.random(7, 10)

	for i = 1, height do
		local rpos = Vector(tpos.x, tpos.y, tpos.z + i - 1)
		SimpleBlock(rpos, ply, log, spawned, true, 2)

		if i == 3 then
			local brushradius = math.random(2, 3) + 1

			local bpos = rpos - Vector(0, 0, 1)

			while brushradius > 0 do
				brushradius = brushradius - 1
				bpos = bpos + Vector(0, 0, 1)

				for x = -brushradius, brushradius do
					for y = -brushradius, brushradius do
						local cond = (x == brushradius and y == brushradius) or
							(x == -brushradius and y == -brushradius) or
							(x == brushradius and y == -brushradius) or
							(x == -brushradius and y == brushradius)

						if cond then
							continue
						end

						SimpleBlock(bpos + Vector(x, y, z), ply, leaves, spawned, nil, 4)
					end
				end
			end

			if math.random(1, 2) == 1 then
				brushradius = 2
				bpos = bpos + Vector(0, 0, 1)

				for x = -brushradius, brushradius do
					for y = -brushradius, brushradius do
						local cond = (x == brushradius and y == brushradius) or
							(x == -brushradius and y == -brushradius) or
							(x == brushradius and y == -brushradius) or
							(x == -brushradius and y == brushradius)

						if cond then
							continue
						end

						SimpleBlock(bpos + Vector(x, y, z), ply, leaves, spawned, nil, 4)
					end
				end

				brushradius = 1
				bpos = bpos + Vector(0, 0, 1)

				for x = -brushradius, brushradius do
					for y = -brushradius, brushradius do
						local cond = (x == brushradius and y == brushradius) or
							(x == -brushradius and y == -brushradius) or
							(x == brushradius and y == -brushradius) or
							(x == -brushradius and y == brushradius)

						if cond then
							continue
						end

						SimpleBlock(bpos + Vector(x, y, z), ply, leaves, spawned, nil, 4)
					end
				end
			end
		end
	end

	local top = Vector(tpos.x, tpos.y, tpos.z + height)

	for i = -1, 1 do
		local rpos = Vector(top.x, top.y, top.z + i - 1)

		SimpleBlock(rpos, ply, leaves, spawned, nil, 4)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD), ply, leaves, spawned, nil, 4)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD), ply, leaves, spawned, nil, 4)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned, nil, 4)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned, nil, 4)

		if i == 0 then
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD) * 2, ply, leaves, spawned, nil, 4)
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD) * 2, ply, leaves, spawned, nil, 4)
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_LEFT) * 2, ply, leaves, spawned, nil, 4)
			SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_RIGHT) * 2, ply, leaves, spawned, nil, 4)
		end
	end

	SimpleBlock(Vector(top.x, top.y, top.z), ply, leaves, spawned, nil, 4)
	SimpleBlock(Vector(top.x, top.y, top.z + 1), ply, leaves, spawned, nil, 4)


	if IsValid(ply) then
		undo.Create('MCTree')
		undo.SetPlayer(ply)
		for k, v in ipairs(spawned) do
			undo.AddEntity(v)
		end
		undo.Finish()
	end
end

local function RandomValue(...)
	local args = {...}
	return args[math.random(1, #args)]
end

local AvaliableDirections = {
	[mc.SIDE_FORWARD] = {
		mc.SIDE_LEFT,
		mc.SIDE_RIGHT,
	},

	[mc.SIDE_BACKWARD] = {
		mc.SIDE_LEFT,
		mc.SIDE_RIGHT,
	},

	[mc.SIDE_LEFT] = {
		mc.SIDE_FORWARD,
		mc.SIDE_BACKWARD,
	},

	[mc.SIDE_RIGHT] = {
		mc.SIDE_FORWARD,
		mc.SIDE_BACKWARD,
	},
}

local function JungleSappling(self)
	local log = mc.GetBlockByName('wood')
	local leaves = mc.GetBlockByName('leaves')

	local pos = self:GetPos()
	local ply = self:GetNWOwner()

	local tpos = mc.TranslateVector(pos)

	local spawned = {}

	local height = math.random(6, 10)

	for i = 1, height do
		local rpos = Vector(tpos.x, tpos.y, tpos.z + i - 1)
		SimpleBlock(rpos, ply, log, spawned, true, 3)
	end

	local top = Vector(tpos.x, tpos.y, tpos.z + height)

	SimpleBlock(top, ply, log, spawned, true, 3)

	for i = 1, 2 do
		local rpos = Vector(top.x, top.y, top.z + i - 1)
		SimpleBlock(rpos, ply, leaves, spawned, nil, 7)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_FORWARD), ply, leaves, spawned, nil, 7)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_BACKWARD), ply, leaves, spawned, nil, 7)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned, nil, 7)
		SimpleBlock(rpos + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned, nil, 7)
	end

	do
		if math.random(1, 2) == 1 then
			SimpleBlock(top + mc.GetSideVector(mc.SIDE_FORWARD) + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned, nil, 7)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(top + mc.GetSideVector(mc.SIDE_FORWARD) + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned, nil, 7)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(top + mc.GetSideVector(mc.SIDE_BACKWARD) + mc.GetSideVector(mc.SIDE_LEFT), ply, leaves, spawned, nil, 7)
		end

		if math.random(1, 2) == 1 then
			SimpleBlock(top + mc.GetSideVector(mc.SIDE_BACKWARD) + mc.GetSideVector(mc.SIDE_RIGHT), ply, leaves, spawned, nil, 7)
		end
	end

	local brushradius = 2
	local blevel = top - Vector(0, 0, 1)

	for z = -1, 0 do
		for x = -brushradius, brushradius do
			for y = -brushradius, brushradius do
				local cond = ((x == brushradius and y == brushradius) or
					(x == -brushradius and y == -brushradius) or
					(x == brushradius and y == -brushradius) or
					(x == -brushradius and y == brushradius))

				if cond then
					if math.random(1, 2) == 1 then continue end
				end

				SimpleBlock(blevel + Vector(x, y, z), ply, leaves, spawned, nil, 7)
			end
		end
	end

	if IsValid(ply) then
		undo.Create('MCTree')
		undo.SetPlayer(ply)
		for k, v in ipairs(spawned) do
			undo.AddEntity(v)
		end
		undo.Finish()
	end
end

mc.RegisterTree(808, OakSappling, .001)
mc.RegisterTree(809, BirchSappling, .001)
mc.RegisterTree(810, PineSappling, .001)
mc.RegisterTree(813, JungleSappling, .001)
