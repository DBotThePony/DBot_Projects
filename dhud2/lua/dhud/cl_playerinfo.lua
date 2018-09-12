
--Player Infos

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


local MAX_DIST_NEAR = 150
local MAX_DIST = 800

local Var = DHUD2.GetVar
local SVar = DHUD2.SetVar
local Col = DHUD2.GetColor
local SimpleUpdate = DHUD2.SimpleUpdate

local function Percent(var1, var2)
	return function()
		if var2 == 0 then return 1 end
		local div = Var(var1) / Var(var2)
		if div ~= div then return 1 end --nan
		return math.Clamp(div, 0, 1)
	end
end

DHUD2.RegisterVar('drawplyinfo_closer', false)
DHUD2.RegisterVar('plyname')
DHUD2.RegisterVar('plyweapon', false)
DHUD2.RegisterVar('plyent', NULL)
DHUD2.RegisterVar('plyhp', 0)
DHUD2.RegisterVar('plymhp', 0)
DHUD2.RegisterVar('plyarmor', 0)
DHUD2.RegisterVar('plymaxarmor', 100)
DHUD2.RegisterVar('plyarmorpercent', 1, Percent('plyarmor', 'plymaxarmor'))
DHUD2.RegisterVar('plyhppercent', 1, Percent('plyhp', 'plymhp'))
DHUD2.RegisterVar('plyteam_name', nil, function() return team.GetName(Var 'plyteam') end)
DHUD2.RegisterVar('plyteam_color', Color(200, 200, 200), function() return team.GetColor(Var 'plyteam') end)
DHUD2.RegisterVar('plyteam', 0)

local function UpdateVars(self, ply, ent, isValid, isPly)
	if not isPly then
		SVar('drawplyinfo_closer', false)
		return false
	end

	local dist = ply:GetPos():Distance(ent:GetPos())

	if dist > MAX_DIST then
		SVar('drawplyinfo_closer', false)
		return false
	end

	SVar('plyname', ent:Nick())
	SVar('plyarmor', ent:Armor())
	SVar('plyhp', ent:Health())
	SVar('plymhp', ent:GetMaxHealth())
	SVar('plyteam', ent:Team())
	SVar('plyent', ent)
	SVar('drawplyinfo_closer', dist <= MAX_DIST_NEAR)

	local wep = ent:GetActiveWeapon()

	if not IsValid(wep) then
		SVar('plyweapon', false)
	else
		SVar('plyweapon', wep:GetPrintName())
	end

	return true
end

DHUD2.EntityVar('drawplyinfo', false, UpdateVars)

DHUD2.DefinePosition('playerinfo', ScrWL() / 2, ScrHL() / 2 + 40)
DHUD2.CreateColor('plytext', 'Player name', 255, 255, 255, 255)

local function Draw()
	if not Var 'drawplyinfo' then return end
	local x, y = DHUD2.GetPosition('playerinfo')

	surface.SetFont('DHUD2.Default')

	local fullnickname = Var 'plyname'

	local team = Var 'plyteam_name'

	if team ~= 'Unassigned' then
		fullnickname = fullnickname .. ' ' .. team
	end

	local w, h = surface.GetTextSize(fullnickname)

	x = x - w / 2
	DHUD2.DrawBox(x - 5, y - 2, w + 10, h + 4, Col 'bg')
	DHUD2.SimpleText(Var 'plyname', nil, x, y, Col 'plytext')

	if team ~= 'Unassigned' then
		DHUD2.SimpleText(team, nil, x + 5 + surface.GetTextSize(Var 'plyname'), y, Var 'plyteam_color')
	end
end

DHUD2.DrawHook('default_plyinfo', Draw)

DHUD2.CreateColor('plyhpbar', 'Player HP bar', 230, 70, 70, 255)
DHUD2.CreateColor('plyhptext', 'Player HP Counter', 255, 200, 200, 255)
DHUD2.CreateColor('plyarmortext', 'Player Armor Counter', 185, 235, 255, 255)
DHUD2.CreateColor('plyarmorbar', 'Player Armor Bar', 64, 130, 230, 255)

local LastHeight = 65

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not Var 'drawplyinfo_closer' then return end
	if not IsValid(Var 'plyent') then return end

	if not DHUD2.IsHudDrawing then return end

	local ply = DHUD2.SelectPlayer()
	local pos = ply:GetPos()
	local eyes = ply:EyePos()

	local tply = Var 'plyent'
	local tpos = tply:GetPos()
	local EyePos = tply:EyePos()

	local head_attach = tply:LookupAttachment('head')
	local eyes_attach = tply:LookupAttachment('eyes')

	if head_attach and head_attach ~= 0 then
		EyePos = tply:GetAttachment(head_attach).Pos
	elseif eyes_attach and eyes_attach ~= 0 then
		EyePos = tply:GetAttachment(eyes_attach).Pos
	end

	local delta = eyes - EyePos
	local dang = delta:Angle()

	dang:RotateAroundAxis(dang:Right(), -90)
	dang:RotateAroundAxis(dang:Up(), 90)

	local add = Vector(5, 2, 0)
	add:Rotate(dang)

	cam.Start3D2D(EyePos + add, dang, 0.15)

	local x, y = 5, 18

	DHUD2.DrawBox(0, 0, 310, LastHeight, Col 'bg')
	LastHeight = 65
	DHUD2.DrawBox(x, y, 300, 15, Col 'empty_bar')
	DHUD2.DrawBox(x, y, 300 * Var 'plyhppercent', 15, Col 'plyhpbar')

	local hptext = Var 'plyhp'

	surface.SetFont('DHUD2.Default')
	DHUD2.SimpleText(hptext, nil, x + 300 - surface.GetTextSize(hptext), 2, Col 'plyhptext')

	local armor = Var 'plyarmor'

	if armor > 0 then
		DHUD2.DrawBox(x, y + 9, 300 * Var 'plyarmorpercent', 6, Col 'plyarmorbar')
		DHUD2.SimpleText(armor, nil, x, y + 15, Col 'plyarmortext')
	end

	local wep = Var 'plyweapon'

	if wep then
		DHUD2.SimpleText(wep, nil, x, y + 28, Col 'plytext')
	end

	local hooks = hook.GetTable().DHUD2_PostDrawPlayerInfo

	if hooks then
		for k, v in pairs(hooks) do
			LastHeight = LastHeight + (v(LastHeight) or 0)
		end
	end

	cam.End3D2D()
end

hook.Add('HUDDrawTargetID', 'DHUD2.HUDDrawTargetID', function()
	if not DHUD2.IsEnabled() then return end
	return false
end)

hook.Add('PostDrawTranslucentRenderables', 'DHUD2.HUDDrawTargetID', PostDrawTranslucentRenderables)
