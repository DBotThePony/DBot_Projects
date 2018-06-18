
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
