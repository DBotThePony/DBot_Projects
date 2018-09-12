
--
-- Copyright (C) 2017-2018 DBot

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


-- Target color - 237, 233, 70

CriticalHitLabel = CreateMaterial('effects/minicrit_unlit', 'UnlitGeneric', {
	'$basetexture': 'effects/minicrit'
	'$ignorez': 1
	'$vertexcolor': 1
	'$vertexalpha': 1
	'$nolod': 1
})

EFFECT.Init = (effData) =>
	@realpos = Vector(effData\GetOrigin())
	@pos = Vector(effData\GetOrigin())
	@size = 2
	@r = 255
	@g = 255
	@b = 255
	@a = 255
	@shift = 0

EFFECT.Think = =>
	@size -= FrameTime() * 2 if @size > 1
	@shift += FrameTime() * 60 if @size <= 1
	delta = math.max(@size - 1, 0)
	@r = 237 + 18 * delta
	@g = 233 + 22 * delta
	@b = 70 + 185 * delta
	@pos.z = @realpos.z + @shift
	return @shift < 200

EFFECT.Render = =>
	render.SetMaterial(CriticalHitLabel)
	render.DrawSprite(@pos, 24 * @size, 24 * @size, Color(@r, @g, @b, @a))
