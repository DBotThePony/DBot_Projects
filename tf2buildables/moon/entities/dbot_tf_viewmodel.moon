
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


AddCSLuaFile()

ENT.PrintName = 'TF2 dumb model'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Type = 'anim'
ENT.RenderGroup = RENDERGROUP_OTHER

ENT.Initialize = =>
	@SetNotSolid(true)
	@DrawShadow(false)
	@SetTransmitWithParent(true)
	@SetNoDraw(true)
	@SetMoveType(MOVETYPE_NONE)
	@AddEffects(EF_BONEMERGE)

ENT.Think = =>
	if CLIENT
		@SetNotSolid(true)
		@SetNoDraw(true)

ENT.DoSetup = (wep) =>
	ply = wep\GetOwner()
	viewmodel = ply\GetViewModel()
	@SetParent(viewmodel)
	@SetPos(viewmodel\GetPos())
	@SetAngles(Angle(0, 0, 0))
	wep\DeleteOnRemove(@)
	ply\DeleteOnRemove(@)
	viewmodel\DeleteOnRemove(@)
