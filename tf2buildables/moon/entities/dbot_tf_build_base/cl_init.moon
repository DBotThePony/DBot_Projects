
--
-- Copyright (C) 2017-2019 DBot

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


include 'shared.lua'

ENT.Initialize = =>
	@DrawShadow(false)
	-- @SetModel(@IdleModel1)

	@UpdateSequenceList()
	@lastSeqModel = @IdleModel1
	@lastAnimTick = CurTime()

ENT.Think = =>

ENT.Draw = =>
	@DrawShadow(false)
	@DrawModel()

ENT.DrawHUD = => DTF2.DrawBuildingInfo(@)
ENT.GetHUDText = => ''

hook.Add 'PlayerBindPress', 'DTF2.PickupBuildable', (bind, pressed) =>
	return if not pressed
	return if not bind\find('attack2')
	tr = @GetEyeTrace()
	return if not IsValid(tr.Entity) or not tr.Entity.IsTF2Building
	return if not tr.Entity\CanBeMoved(@)
	net.Start('dtf2.movebuildable')
	net.WriteEntity(tr.Entity)
	net.SendToServer()
