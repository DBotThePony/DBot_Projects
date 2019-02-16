
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

import util, math, table, IMagic from _G

class IMagic.VisMap
	@X_CELLS = 40
	@Y_CELLS = 40
	@MIN_VIS_LEVEL = 40
	@MIN_FLUX_LEVEL = 0
	@MAX_VIS_LEVEL = 600
	@MAX_FLUX_LEVEL = 30

	@WIDE_X = 0x7FFF
	@WIDE_Y = 0x7FFF

	@CELL_STEP_X = @WIDE_X / @X_CELLS
	@CELL_STEP_Y = @WIDE_Y / @Y_CELLS

	@TOTAL_CELLS = @X_CELLS * @Y_CELLS

	@X_SHIFT = @Y_CELLS + 1

	new: (map = game.GetMap()) =>
		@empty = true
		@map = map
		@dirty = false

	MapToVis: (pos) =>
		return if @empty
		x, y = pos.x, pos.y
		return if x > @@WIDE_X or x < -@@WIDE_X
		return if y > @@WIDE_Y or y < -@@WIDE_Y
		cellx = math.floor(x / @@CELL_STEP_X)
		celly = math.floor(y / @@CELL_STEP_Y)
		return @heap[(cellx * @@X_SHIFT) + celly]

	Generate: (consoleMessages = true) =>
		@heap = {}
		@iterable = {}
		@dirty = true

		IMagic.Message('Generating raw values and building heap...')

		start = -@@X_CELLS / 2
		ends = @@X_CELLS / 2

		for x = start, ends
			IMagic.Message((x - start) * @@Y_CELLS .. '/' .. @@TOTAL_CELLS) if x % 10 == 0

			for y = -@@Y_CELLS / 2, @@Y_CELLS / 2
				vis = util.SharedRandom(@map, @@MIN_VIS_LEVEL, @@MAX_VIS_LEVEL, (x * @@X_SHIFT) + y)
				flux = util.SharedRandom(@map, @@MIN_FLUX_LEVEL, @@MAX_FLUX_LEVEL, (x * @@X_SHIFT) + y + 0xFF33)
				@heap[(x * @@X_SHIFT) + y] = IMagic.VisCell(x, y, vis, flux, vis, @)
				table.insert(@iterable, @heap[(x * @@X_SHIFT) + y])

		IMagic.Message('Distributing...')

		for _, cell in pairs(@heap)
			cell\Distribute()

		IMagic.Message('Smoothing...')

		for _, cell in pairs(@heap)
			cell\Smooth()

		@empty = false

import Vector from _G

class IMagic.VisCell
	new: (x, y, vis, flux, limit, map) =>
		@x = x
		@y = y
		@vis = vis
		@flux = flux
		@limit = limit
		@map = map
		@heap = map.heap
		@key = x\lshift(16) + y

	GetUp: => @heap[(@x * IMagic.VisMap.X_SHIFT) + @y + 1]
	GetLeft: => @heap[(@x - 1) * IMagic.VisMap.X_SHIFT + @y]
	GetRight: => @heap[(@x + 1) * IMagic.VisMap.X_SHIFT + @y]
	GetDown: => @heap[(@x * IMagic.VisMap.X_SHIFT) + @y - 1]

	GetVisForLimit: =>
		return @vis if @flux < 30
		return @vis + @flux
	GetVis: => @vis
	SetVis: (vis) => @vis = vis
	AddVis: (vis) => @vis += vis
	GetVisLimit: => @limit
	SetVisLimit: (vis) => @limit = vis
	AddVisLimit: (vis) => @limit += vis
	GetFlux: => @flux
	SetFlux: (flux) => @flux = flux
	AddFlux: (flux) => @flux += flux

	WorldCenter: => Vector(@x * IMagic.VisMap.CELL_STEP_X + IMagic.VisMap.CELL_STEP_X / 2, @y * IMagic.VisMap.CELL_STEP_Y + IMagic.VisMap.CELL_STEP_Y / 2, 0)
	LocalAABB: (zmin = -0x7FFF, zmax = 0x7FFF) => Vector(IMagic.VisMap.CELL_STEP_X, IMagic.VisMap.CELL_STEP_Y, zmin), Vector(IMagic.VisMap.CELL_STEP_X * 2 - 1, IMagic.VisMap.CELL_STEP_Y * 2 - 1, zmax)

	Replenish: =>
		if @GetVisForLimit() * 1.1 > @limit
			return if @GetVisForLimit() > @limit
			if math.random() > 0.6
				@map.dirty = true
				@vis += math.random(20, 50) / 17
			return

		@map.dirty = true
		@vis += math.random(20, 50) / 17

	Distribute: =>
		left, right, up, down = @GetLeft(), @GetRight(), @GetUp(), @GetDown()
		return if not left or not right or not up or not down
		average = (left.vis + right.vis + up.vis + down.vis) / 4
		div = (average - @vis) / @vis

		if div > 0.25 or div < -0.25
			lost = @GetVis() * 0.3
			@vis -= lost
			left\AddVis(lost / 4)
			right\AddVis(lost / 4)
			up\AddVis(lost / 4)
			down\AddVis(lost / 4)

	Smooth: =>
		left, right, up, down = @GetLeft(), @GetRight(), @GetUp(), @GetDown()
		return if not left or not right or not up or not down
		gainLeft = (@vis - left.vis) * 0.07
		gainRight = (@vis - right.vis) * 0.07
		gainUp = (@vis - up.vis) * 0.11
		gainDown = (@vis - down.vis) * 0.11

		@AddVis(-gainLeft - gainRight - gainUp - gainDown)
		left\AddVis(gainLeft)
		right\AddVis(gainRight)
		up\AddVis(gainUp)
		down\AddVis(gainDown)

IMagic.CURRENT_MAP = IMagic.VisMap()
IMagic.CURRENT_MAP\Generate()
