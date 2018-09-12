
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

ENT.PrintName = 'Pule Rifle Bullet'
ENT.Author = 'DBot'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Type = 'anim'
ENT.IS_BULLET = true
ENT.Base = 'dbot_physbullet'

DEFINE_BASECLASS('dbot_physbullet')

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetSkin(2)
end

function ENT:GetPenetrationStrength()
	return self:CalculateForce() / 24
end

function ENT:GetFinalDamage()
	return BaseClass.GetFinalDamage(self) * 2
end

function ENT:CalculateForce()
	return BaseClass.CalculateForce(self) * 1.5
end
