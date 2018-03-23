
--[[
Copyright (C) 2016-2018 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'Speedmeter'
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Author = 'DBot'

ENT.OutputsToTrigger = {
	-- Second
	{'Speed', 'HammerUnits_Second'},
	{'Meters', 'Meters_Second'},
	{'Kilometers', 'KM_Second'},
	{'Feet', 'Feet_Second'},
	{'Miles', 'Miles_Second'},

	-- Minute
	{'Speed_M', 'HammerUnits_Minute'},
	{'Meters_M', 'Meters_Minute'},
	{'Kilometers_M', 'KM_Minute'},
	{'Feet_M', 'Feet_Minute'},
	{'Miles_M', 'Miles_Minute'},

	-- Hour
	{'Speed_H', 'HammerUnits_Hour'},
	{'Meters_H', 'Meters_Hour'},
	{'Kilometers_H', 'KM_Hour'},
	{'Feet_H', 'Feet_Hour'},
	{'Miles_H', 'Miles_Hour'},
}

ENT.DisplayUnits = {
	-- Second
	{'Speed', 'GetDisplayHuS', ' Hu/s'},
	{'Meters', 'GetDisplayMetersS', ' M/s'},
	{'Kilometers', 'GetDisplayKMS', ' KM/s'},
	{'Feet', 'GetDisplayFeetS', ' Feet/s'},
	{'Miles', 'GetDisplayMilesS', ' Miles/s'},

	-- Minute
	{'Speed_M', 'GetDisplayHuM', ' Hu/min'},
	{'Meters_M', 'GetDisplayMetersM', ' M/min'},
	{'Kilometers_M', 'GetDisplayKMM', ' KM/min'},
	{'Feet_M', 'GetDisplayFeetM', ' Feet/min'},
	{'Miles_M', 'GetDisplayMilesM', ' Miles/min'},

	-- Hour
	{'Speed_H', 'GetDisplayHuH', ' Hu/h'},
	{'Meters_H', 'GetDisplayMetersH', ' M/h'},
	{'Kilometers_H', 'GetDisplayKMH', ' KM/h'},
	{'Feet_H', 'GetDisplayFeetH', ' Feet/h'},
	{'Miles_H', 'GetDisplayMilesH', ' Miles/h'},
}

ENT.OutputsToTriggerComp = {}

for k, v in ipairs(ENT.OutputsToTrigger) do
	table.insert(ENT.OutputsToTriggerComp, v[2])
end

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 0, 'DisplayKMS')
	self:NetworkVar('Bool', 1, 'DisplayMilesS')
	self:NetworkVar('Bool', 2, 'DisplayHuS')

	self:NetworkVar('Bool', 4, 'DisplayKMH')
	self:NetworkVar('Bool', 5, 'DisplayMilesH')
	self:NetworkVar('Bool', 6, 'DisplayHuH')

	self:NetworkVar('Bool', 7, 'DisplayKMM')
	self:NetworkVar('Bool', 8, 'DisplayMilesM')
	self:NetworkVar('Bool', 9, 'DisplayHuM')

	self:NetworkVar('Bool', 10, 'DisplayFeetS')
	self:NetworkVar('Bool', 11, 'DisplayFeetM')
	self:NetworkVar('Bool', 12, 'DisplayFeetH')

	self:NetworkVar('Bool', 13, 'DisplayMetersS')
	self:NetworkVar('Bool', 14, 'DisplayMetersM')
	self:NetworkVar('Bool', 15, 'DisplayMetersH')

	self:NetworkVar('Bool', 3, 'ShouldSmooth')

	self:NetworkVar('Float', 0, 'DisplaySize')
	self:NetworkVar('Int', 0, 'Font')
	self:NetworkVar('Entity', 0, 'NWOwner')

	self:NetworkVar('Int', 1, 'TextRed')
	self:NetworkVar('Int', 2, 'TextGreen')
	self:NetworkVar('Int', 3, 'TextBlue')
	self:NetworkVar('Int', 4, 'TextAlpha')

	self:NetworkVar('Int', 5, 'BackgroundRed')
	self:NetworkVar('Int', 6, 'BackgroundGreen')
	self:NetworkVar('Int', 7, 'BackgroundBlue')
	self:NetworkVar('Int', 8, 'BackgroundAlpha')
end

function ENT:Initialize()
	self:SetModel('models/hunter/blocks/cube025x025x025.mdl')

	self.LastPos = nil
	self.LastThink = nil

	if CLIENT then return end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	self:PhysWake()

	self.Outputs = GTools.CreateOutputs(self, self.OutputsToTriggerComp)
end

function ENT:UpdateVars()
	local speed = self.Speed or 0

	self.Speed_M = speed * 60
	self.Speed_H = speed * 3600

	self.MilliMeters = speed * 19.05
	self.Meters = self.MilliMeters / 1000
	self.Kilometers = self.Meters / 1000

	self.Feet = self.Meters * 3.2
	self.Miles = self.Kilometers * 0.62

	self.MilliMeters_M = self.MilliMeters * 60
	self.MilliMeters_H = self.MilliMeters * 3600

	self.Meters_M = self.Meters * 60
	self.Meters_H = self.Meters * 3600

	self.Kilometers_M = self.Kilometers * 60
	self.Kilometers_H = self.Kilometers * 3600

	self.Miles_M = self.Miles * 60
	self.Miles_H = self.Miles * 3600

	self.Feet_M = self.Feet * 60
	self.Feet_H = self.Feet * 3600
end

function ENT:TriggerWireOutputs()
	for k, v in ipairs(self.OutputsToTrigger) do
		WireLib.TriggerOutput(self, v[2], v[1])
	end
end

function ENT:Think()
	self.LastThink = self.LastThink or CurTime()
	local delta = CurTime() - self.LastThink
	self.LastThink = CurTime()

	if delta <= 0 then return end -- ???

	local mult = 1 / delta

	local pos = self:GetPos()
	self.LastPos = self.LastPos or pos

	local dist = self.LastPos:Distance(pos) * mult
	self.LastPos = pos

	self.Speed = self.Speed or 0

	if self:GetShouldSmooth() then
		self.Speed = Lerp(0.03, self.Speed, dist)
	else
		self.Speed = dist
	end

	self:UpdateVars()

	if SERVER and WireLib then
		self:TriggerWireOutputs()
	end
end

DBot_Speedmeter_Fonts = {
	{
		Name = 'Default',
		Data = {
			font = 'Roboto',
			size = 48,
			weight = 500,
		}
	}
}


for k, v in ipairs(DBot_Speedmeter_Fonts) do
	v.SName = 'DBot.Speedmeter.' .. v.Name
	if CLIENT then surface.CreateFont(v.SName, v.Data) end
end

function ENT:GetFontName()
	local f = self:GetFont()
	if not f then return 'DBot.Speedmeter.Default' end
	local get = DBot_Speedmeter_Fonts[f]
	return get and get.SName or 'DBot.Speedmeter.Default'
end

function ENT:Draw()
	self:DrawModel()

	if not self.Speed then return end

	local pos, ang = self:GetPos(), self:GetAngles()
	local lpos = EyePos()

	local delta = pos - lpos
	local deltaAng = delta:Angle()
	local finalAngle = Angle(0, deltaAng.y, 0)

	finalAngle:RotateAroundAxis(finalAngle:Forward(), 90)
	finalAngle:RotateAroundAxis(finalAngle:Right(), 90)

	local f = self:GetFontName()
	surface.SetFont(f)
	local mult = self:GetDisplaySize()
	local build = {}

	for i, data in ipairs(self.DisplayUnits) do
		if self[data[2]](self) then
			table.insert(build, math.floor(self[data[1]] * 10) / 10 .. data[3])
		end
	end

	local maxs = self:OBBMaxs()

	local buildString = table.concat(build, '\n')
	local w, h = surface.GetTextSize(buildString)
	local toAdd = Vector(-w / 2 - 4, h + maxs.z / mult + 10, 0) * mult
	toAdd:Rotate(finalAngle)

	cam.Start3D2D(pos + toAdd, finalAngle, mult)

	surface.SetDrawColor(self:GetBackgroundRed() or 255, self:GetBackgroundGreen() or 255, self:GetBackgroundBlue() or 255, self:GetBackgroundAlpha() or 255)
	surface.DrawRect(0, 0, w + 8, h + 8)
	draw.DrawText(buildString, f, 4, 4, Color(self:GetTextRed() or 255, self:GetTextGreen() or 255, self:GetTextBlue() or 255, self:GetTextAlpha() or 255))

	cam.End3D2D()
end
