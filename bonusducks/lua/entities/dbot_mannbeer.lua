
-- Copyright (C) 2016-2019 DBot

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

local BEER_DISSAPEAR = CreateConVar('sv_beer_time', '60', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'How long beer exists')
DBOT_ACTIVE_BEER = DBOT_ACTIVE_BEER or {}

DEFINE_BASECLASS('dbot_duck')

ENT.Type = 'anim'
ENT.Author = 'DBotThePony'
ENT.Base = 'dbot_duck'
ENT.Spawnable = false
ENT.PrintName = 'Mann Bear'

local Mins, Maxs = Vector(-5, -5, 0), Vector(5, 5, 5)

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetModel('models/props_watergate/bottle_pickup.mdl')

	self.Expires = CurTimeL() + BEER_DISSAPEAR:GetInt()
	self.Fade = CurTimeL() + BEER_DISSAPEAR:GetInt() - 4

	if CLIENT then
		if IsValid(self.ClientsideModel) then self.ClientsideModel:Remove() end
		self.ClientsideModel = ClientsideModel('models/props_watergate/bottle_pickup.mdl')
		self.ClientsideModel:SetNoDraw(true)
		return
	end

	table.insert(DBOT_ACTIVE_BEER, self)
end

function ENT:Collect(ply)
	hook.Run('PreCollectBeer', self, ply)

	self:EmitSound('vo/watergate/pickup_beer.mp3', 75)
	self:Remove()

	hook.Run('PostCollectBeer', self, ply)
end
