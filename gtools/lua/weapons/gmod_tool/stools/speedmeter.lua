
--[[
Copyright (C) 2016-2018 DBot


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

]]

local CURRENT_TOOL_MODE = 'speedmeter'
local CURRENT_TOOL_MODE_VARS = 'speedmeter_'

TOOL.Name = 'Speedometer'
TOOL.Category = 'Construction'

if CLIENT then
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', 'Speedometer')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'Creates a Speedometer!')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.0', '')

	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left', 'Create or update a Speedometer')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right', 'Copy Speedometer\'s properties')

	language.Add('Undone_Speedmeter', 'Undone Speedometer')
else
	util.AddNetworkString(CURRENT_TOOL_MODE .. '.copy')
end

TOOL.Information = {
	{name = 'left'},
	{name = 'right'},
}

TOOL.ClientConVar = {
	smooth = 1,

	weld_to_world = 0,
	weld_to_prop = 1,

	font = 0,
	size = 0.3,

	r = 255,
	g = 255,
	b = 255,
	a = 255,

	br = 0,
	bg = 0,
	bb = 0,
	ba = 255,
}

local Units = {
	{'Hammer units', 'hu', 'DisplayHu'},
	{'Meters', 'meters', 'DisplayMeters'},
	{'Kilometers', 'km', 'DisplayKM'},
	{'Traditional Feet', 'feet', 'DisplayFeet'},
	{'Traditional Mile', 'miles', 'DisplayMiles'},
}

for k, data in ipairs(Units) do
	TOOL.ClientConVar[data[2]] = 0
	TOOL.ClientConVar[data[2] .. '_m'] = 0
	TOOL.ClientConVar[data[2] .. '_h'] = 0
end

TOOL.ClientConVar.hu = 1
TOOL.ClientConVar.km_h = 1

function TOOL:SetupVars(ent)
	local vars = {}
	local bools = {}

	for k, v in pairs(self.ClientConVar) do
		vars[k] = self:GetClientNumber(k, v)
		bools[k] = tobool(vars[k])
	end

	for k, data in ipairs(Units) do
		ent['Set' .. data[3] .. 'S'](ent, bools[data[2]])
		ent['Set' .. data[3] .. 'M'](ent, bools[data[2] .. '_m'])
		ent['Set' .. data[3] .. 'H'](ent, bools[data[2] .. '_h'])
	end

	ent:SetShouldSmooth(bools.smooth)

	ent:SetTextRed(math.Clamp(vars.r, 0, 255))
	ent:SetTextGreen(math.Clamp(vars.g, 0, 255))
	ent:SetTextBlue(math.Clamp(vars.b, 0, 255))
	ent:SetTextAlpha(math.Clamp(vars.a, 0, 255))

	ent:SetBackgroundRed(math.Clamp(vars.br, 0, 255))
	ent:SetBackgroundGreen(math.Clamp(vars.bg, 0, 255))
	ent:SetBackgroundBlue(math.Clamp(vars.bb, 0, 255))
	ent:SetBackgroundAlpha(math.Clamp(vars.ba, 0, 255))

	ent:SetDisplaySize(math.Clamp(vars.size, 0, 1))
end

if CLIENT then
	net.Receive(CURRENT_TOOL_MODE .. '.copy', function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end

		for k, data in ipairs(Units) do
			RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. data[2], ent['Get' .. data[3] .. 'S'](ent) and '1' or '0')
			RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. data[2] .. '_m', ent['Get' .. data[3] .. 'M'](ent) and '1' or '0')
			RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. data[2] .. '_h', ent['Get' .. data[3] .. 'H'](ent) and '1' or '0')
		end

		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'r', ent:GetTextRed())
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'g', ent:GetTextGreen())
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'b', ent:GetTextBlue())
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'a', ent:GetTextAlpha())

		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'br', ent:GetBackgroundRed())
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'bg', ent:GetBackgroundGreen())
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'bb', ent:GetBackgroundBlue())
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'ba', ent:GetBackgroundAlpha())

		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'size', ent:GetDisplaySize())

		GTools.ChatPrint('Settings copied')
	end)
end

local LAST_PANEL

function TOOL.BuildCPanel(Panel)
	if not IsValid(Panel) then return end
	LAST_PANEL = Panel
	Panel:Clear()

	Panel:CheckBox('Smooth the speed change', CURRENT_TOOL_MODE_VARS .. 'smooth')
	Panel:CheckBox('Weld Speedometer to world', CURRENT_TOOL_MODE_VARS .. 'weld_to_world')
	Panel:CheckBox('Weld Speedometer to prop', CURRENT_TOOL_MODE_VARS .. 'weld_to_prop')
	Panel:NumSlider('Screen size', CURRENT_TOOL_MODE_VARS .. 'size', 0, 1, 2)

	local lab = Label('Per second', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)

	for i, data in ipairs(Units) do
		Panel:CheckBox('Display ' .. data[1] .. ' per second', CURRENT_TOOL_MODE_VARS .. data[2])
	end

	local lab = Label('Per minute', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)

	for i, data in ipairs(Units) do
		Panel:CheckBox('Display ' .. data[1] .. ' per minute', CURRENT_TOOL_MODE_VARS .. data[2] .. '_m')
	end

	local lab = Label('Per hour', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)

	for i, data in ipairs(Units) do
		Panel:CheckBox('Display ' .. data[1] .. ' per hour', CURRENT_TOOL_MODE_VARS .. data[2] .. '_h')
	end

	local lab = Label('Text color', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)

	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE_VARS .. 'r')
	mixer:SetConVarG(CURRENT_TOOL_MODE_VARS .. 'g')
	mixer:SetConVarB(CURRENT_TOOL_MODE_VARS .. 'b')
	mixer:SetConVarA(CURRENT_TOOL_MODE_VARS .. 'a')
	mixer:SetAlphaBar(true)

	local lab = Label('Background color', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)

	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE_VARS .. 'br')
	mixer:SetConVarG(CURRENT_TOOL_MODE_VARS .. 'bg')
	mixer:SetConVarB(CURRENT_TOOL_MODE_VARS .. 'bb')
	mixer:SetConVarA(CURRENT_TOOL_MODE_VARS .. 'ba')
	mixer:SetAlphaBar(true)
end

function TOOL:CreateEntityAt(tr)
	local ply = self:GetOwner()
	local new = ents.Create('dbot_speedmeter')
	new:SetNWOwner(ply)
	new:SetPos(tr.HitPos + tr.HitNormal * 5)

	local ang = (ply:EyePos() - tr.HitPos):Angle()
	ang.p = 0
	ang.r = 0
	new:SetAngles(ang)

	new:Spawn()
	new:Activate()

	self:SetupVars(new)

	if new.CPPISetOwner then
		new:CPPISetOwner(ply)
	end

	return new
end

function TOOL:LeftClick(tr)
	local ent = tr.Entity
	local ply = self:GetOwner()

	if IsValid(ent) then
		if ent:IsPlayer() then return false end
		if CLIENT then return true end

		if ent:GetClass() == 'dbot_speedmeter' then
			self:SetupVars(ent)
		else
			local nent = self:CreateEntityAt(tr)
			local const

			if tobool(self:GetClientNumber('weld_to_prop', 1)) then
				const = constraint.Weld(ent, nent, 0, 0, 0, false)
			end

			undo.Create('Speedmeter')
			undo.SetPlayer(ply)
			undo.AddEntity(nent)

			if const then
				undo.AddEntity(const)
			end

			undo.Finish()
		end
	else
		if CLIENT then return true end
		local nent = self:CreateEntityAt(tr)
		local const

		if tobool(self:GetClientNumber('weld_to_world', 0)) and ent ~= NULL then
			const = constraint.Weld(ent, nent, 0, 0, 0, false)
		end

		undo.Create('Speedmeter')
		undo.SetPlayer(ply)
		undo.AddEntity(nent)

		if const then
			undo.AddEntity(const)
		end

		undo.Finish()
	end

	return true
end

function TOOL:RightClick(tr)
	local ent = tr.Entity
	if not IsValid(ent) then return false end
	if ent:GetClass() ~= 'dbot_speedmeter' then return false end
	if CLIENT then return true end

	net.Start(CURRENT_TOOL_MODE .. '.copy')
	net.WriteEntity(tr.Entity)
	net.Send(self:GetOwner())

	return true
end
