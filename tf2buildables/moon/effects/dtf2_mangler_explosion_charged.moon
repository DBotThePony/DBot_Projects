
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


EFFECT.Init = (effData) =>
	pos = effData\GetOrigin()
	ang = effData\GetNormal()\Angle()
	ParticleEffect('drg_cow_explosion_coreflash', pos, ang)
	ParticleEffect('drg_cow_explosion_flashup', pos, ang)
	ParticleEffect('drg_cow_explosion_flash_1', pos, ang)
	ParticleEffect('drg_cow_explosion_smoke', pos, ang)
	ParticleEffect('drg_cow_explosion_sparkles', pos, ang)
	ParticleEffect('drg_cow_explosion_sparkles_charged', pos, ang)
	ParticleEffect('drg_cow_explosion_sparks', pos, ang)
	ParticleEffect('Explosion_CoreFlash', pos, ang)
	ParticleEffect('Explosion_Dustup', pos, ang)
	ParticleEffect('Explosion_Dustup_2', pos, ang)
	ParticleEffect('Explosion_Smoke_1', pos, ang)
	ParticleEffect('Explosion_Flashup', pos, ang)
	util.Decal('DTF2_RocketExplosion', effData\GetOrigin() + effData\GetNormal(), effData\GetOrigin() - effData\GetNormal())

EFFECT.Think = => false
EFFECT.Render = =>
