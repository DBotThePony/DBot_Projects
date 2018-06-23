
--
-- Copyright (C) 2017-2018 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

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
