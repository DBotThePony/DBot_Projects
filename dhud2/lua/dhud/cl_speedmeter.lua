
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

local ENABLE = CreateConVar('dhud_speedmeter', '1', FCVAR_ARCHIVE, 'Enable speedmeter')
DHUD2.AddConVar('dhud_speedmeter', 'Enable speedmeter', ENABLE)

DHUD2.DefinePosition('speedmeter', ScrWL() - 200, ScrHL() / 2 + 50)
DHUD2.CreateColor('speedmeter_text', 'Speedmeter Text', 255, 255, 255, 255)

local HU_IN_METER = 40

local BarsColor = {
	--[[Color(0, 255, 255),
	Color(0, 255, 235),
	Color(0, 255, 200),
	Color(30, 235, 170),
	Color(60, 200, 140),
	Color(100, 200, 100),
	Color(130, 170, 40),
	Color(160, 140, 0),
	Color(200, 80, 0),
	Color(255, 0, 0),
	Color(0, 0, 0), --dead]]
}

for i = 0, 255, 40 do
	table.insert(BarsColor, Color(i, 255 - i, 255 - i))
end

--You are going to be dead
for i = 0, 255, 40 do
	table.insert(BarsColor, Color(255 - i, 0, 0))
end

local ColorCount = #BarsColor

local function Enabled(ply)
	if not DHUD2.IsEnabled() then return false end
	if not ENABLE:GetBool() then return false end
	if not DHUD2.ServerConVar('speedmeter') then return false end

	if not ply:InVehicle() then return false end
	if not IsValid(ply:GetVehicle()) then return false end

	return true
end

local LastPos = Vector()
local CurrSpeed = 0
local LastFrame = 0

local function Think(self, ply)
	if not Enabled(ply) then return end

	if CurrSpeed ~= CurrSpeed then CurrSpeed = 0 end --NaN

	local pos = ply:GetVehicle():GetPos()

	local dist = pos:Distance(LastPos) / (CurTimeL() - LastFrame) --Hu per second i think
	if dist ~= dist then dist = 0 end --Divided by zero
	CurrSpeed = Lerp(0.1 * FrameTime() * 10, CurrSpeed, dist)
	LastPos = pos
	LastFrame = CurTimeL()
end

local function Draw(self, ply)
	if not Enabled(ply) then return end

	local x, y = DHUD2.GetPosition('speedmeter')
	local speed = CurrSpeed
	local KMH = (speed / HU_IN_METER) * 3600 / 1000

	DHUD2.SimpleText('KMH: ' .. math.floor(KMH), 'DHUD2.Default', x, y, DHUD2.GetColor('speedmeter_text'))

	local colors = 0
	y = y + 25
	for k, v in pairs(BarsColor) do
		local i = k - 1
		local w = math.Clamp((KMH - i * 8) * 20, 0, 150)
		if w == 0 then continue end
		colors = colors + 1
		DHUD2.DrawBox(x, y, w, 5, v)
		y = y + 5
	end

	if colors >= ColorCount - 1 then
		DHUD2.SimpleText('DANGER', nil, x, y, DHUD2.GetColor('speedmeter_text'))
	end
end

DHUD2.VarHook('speedmeter', Think)
DHUD2.DrawHook('speedmeter', Draw)
