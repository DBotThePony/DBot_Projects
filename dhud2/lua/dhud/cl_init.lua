
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

local ENABLE = CreateConVar('dhud_enable', '1', FCVAR_ARCHIVE, 'Enable DHUD2')
local ENABLE_SHIFT = CreateConVar('dhud_shift', '1', FCVAR_ARCHIVE, 'Enable Shifting')

DHUD2.ShouldDraw = DHUD2.ShouldDraw or {}
DHUD2.Vars = DHUD2.Vars or {}
DHUD2.EVars = DHUD2.EVars or {}
DHUD2.VarHooks = DHUD2.VarHooks or {}
DHUD2.DrawHooks = DHUD2.DrawHooks or {}
DHUD2.Positions_original = DHUD2.Positions_original or {}
DHUD2.Positions = DHUD2.Positions or {}
DHUD2.WarningTracks = DHUD2.WarningTracks or {}
DHUD2.CVars = DHUD2.CVars or {}

DHUD2.Positions_X = DHUD2.Positions_X or {}
DHUD2.Positions_Y = DHUD2.Positions_Y or {}

DHUD2.ShiftX = 0
DHUD2.ShiftY = 0

DHUD2.DamageShift = false

DHUD2.DamageShiftData = {}

function DHUD2.GetDamageShift(level)
	if not DHUD2.DamageShift then
		return 0
	end

	local data = debug.getinfo(level or 2, 'Sln')
	local name = data.short_src .. data.currentline

	if DHUD2.DamageShiftData[name] == nil then
		DHUD2.DamageShiftData[name] = math.random(-30, 30) / 5
	end

	return DHUD2.DamageShiftData[name]
end

function DHUD2.GetVar(name)
	if DHUD2.Vars[name] then return DHUD2.Vars[name].value end
	if DHUD2.EVars[name] then return DHUD2.EVars[name].value end
end

function DHUD2.SetVar(name, new)
	DHUD2.Vars[name].value = new
end

function DHUD2.CreateWarning(id, name1, name2, help, percentLow, percentCritical)
	DHUD2.WarningTracks[id] = {
		low = percentLow,
		critical = percentCritical,
		islow = false,
		iscrit = false,
		draw = 0,
		help = help,
		name1 = name1,
		name2 = name2,
	}
end

function DHUD2.CreateWarningCustom(varid, help, percentLow, percentCritical, check)
	DHUD2.WarningTracks[varid] = {
		low = percentLow,
		critical = percentCritical,
		islow = false,
		iscrit = false,
		draw = 0,
		help = help,
		iscustom = true,
		check = check,
	}
end

function DHUD2.AddConVar(name, help, obj)
	DHUD2.CVars[name] = {
		help = help,
		obj = obj or GetConVar(name)
	}
end

DHUD2.SelectPlayer = DLib.HUDCommons.SelectPlayer

function DHUD2.CreateColor(class, name, r, g, b, a)
	return DLib.HUDCommons.CreateColor('dhud2_' .. class, 'DHUD2 ' .. name, r, g, b, a)
end

function DHUD2.GetColor(class)
	return DLib.HUDCommons.GetColor('dhud2_' .. class)
end

function DHUD2.DefinePosition(name, x, y)
	return DLib.HUDCommons.DefinePosition('dhud2_' .. name, x, y)
end

function DHUD2.GetPosition(name)
	return DLib.HUDCommons.GetPosition('dhud2_' .. name)
end

function DHUD2.RegisterVar(name, value, updateFunc)
	if not value then value = '%' .. name .. '%' end
	DHUD2.Vars[name] = {
		value = value,
		func = updateFunc,
		self = {}
	}

	return DHUD2.Vars[name].self
end

function DHUD2.EntityVar(name, value, updateFunc)
	DHUD2.EVars[name] = {
		value = value,
		func = updateFunc,
		self = {}
	}

	return DHUD2.EVars[name].self
end

function DHUD2.VarHook(name, func)
	DHUD2.VarHooks[name] = {
		func = func,
		self = {}
	}
end

function DHUD2.DrawHook(name, func)
	DHUD2.DrawHooks[name] = {
		func = func,
		self = {}
	}
end

DHUD2.IsHudDrawing = false

local function Tick()
	local ply = DHUD2.SelectPlayer()

	if not IsValid(ply) then return end

	DHUD2.Multipler = FrameTime() * 66

	local ent = ply:GetEyeTrace().Entity
	local isValid = IsValid(ent)
	local isPlayer = isValid and ent:IsPlayer()
	local dist = isValid and ent:GetPos():Distance(ply:GetPos()) or -1

	for k, v in pairs(DHUD2.Vars) do
		if not v.func then continue end
		local newVal = v.func(v.self, ply)

		if newVal ~= nil then
			v.value = newVal
		end
	end

	for k, v in pairs(DHUD2.EVars) do
		if not v.func then continue end
		local newVal = v.func(v.self, ply, ent, isValid, isPlayer, dist)

		if newVal ~= nil then
			v.value = newVal
		end
	end

	for k, v in pairs(DHUD2.VarHooks) do
		v.func(v.self, ply, ent, isValid, isPlayer, dist)
	end

	for k, v in pairs(DHUD2.WarningTracks) do
		local islow, iscrit

		if v.check then
			if not v.check(ply) then continue end
		end

		if not v.iscustom then
			local current = DHUD2.GetVar(v.name1)
			if not isnumber(current) then continue end
			local max = DHUD2.GetVar(v.name2)
			if not isnumber(max) then continue end

			local div
			if max ~= 0 then
				div = current / max
			else
				div = 1
			end

			local perc = math.Clamp(div, 0, 1)

			islow = v.low and perc <= v.low
			iscrit = v.critical and perc <= v.critical
		else
			local var = DHUD2.GetVar(k)
			islow = v.low and var <= v.low
			iscrit = v.critical and var <= v.critical
		end

		if iscrit then
			if not v.iscrit then
				v.draw = CurTimeL() + 4
				v.iscrit = true
				v.islow = true
			end
		elseif islow then
			if not v.islow then
				v.draw = CurTimeL() + 4
				v.islow = false
				v.islow = true
			end
		else
			v.draw = 0
			v.iscrit = false
			v.islow = false
		end
	end
end

function DHUD2.IsEnabled()
	if DHUD2.ServerConVar('allowdisable') then
		return ENABLE:GetBool()
	else
		return true
	end
end

local function HUDPaint()
	local ply = DHUD2.SelectPlayer()

	if DHUD2.IsEnabled() then
		DHUD2.IsHudDrawing = true

		for k, v in pairs(DHUD2.DrawHooks) do
			local can = hook.Run('CanDrawDHUD2', k)
			if can == false then continue end
			v.func(v.self, ply)
		end
	else
		DHUD2.IsHudDrawing = false
	end

	local c = CurTimeL()

	local x, y = DHUD2.GetPosition('warning')
	local col = DHUD2.GetColor('warning')
	local bg = DHUD2.GetColor('bg')

	local next = 0
	surface.SetFont('DHUD2.Default')

	if DHUD2.IsEnabled() then
		for k, v in pairs(DHUD2.WarningTracks) do
			if v.draw < c then continue end

			if v.iscrit then
				local str
				if not istable(v.help) then
					str = v.help .. ' is critical'
				else
					str = v.help[2]
				end

				local w, h = surface.GetTextSize(str)
				DHUD2.DrawBox(x - 4 - w / 2, y - 2 + next, w + 8, h + 4, bg)
				DHUD2.SimpleText(str, nil, x - w / 2, y + next, col)

				next = next + h + 5
			elseif v.islow then
				local str
				if not istable(v.help) then
					str = v.help .. ' is low'
				else
					str = v.help[1]
				end

				local w, h = surface.GetTextSize(str)
				DHUD2.DrawBox(x - 4 - w / 2, y - 2 + next, w + 8, h + 4, bg)
				DHUD2.SimpleText(str, nil, x - w / 2, y + next, col)

				next = next + h + 5
			end
		end
	end
end

DHUD2.CreateColor('warning', 'Warning text', 255, 150, 150, 255)
DHUD2.DefinePosition('warning', ScrWL() / 2, ScrHL() / 2 - 90)
DHUD2.DefinePosition('printmessage', ScrWL() / 2, ScrHL() / 2 - 160)

function DHUD2.IsShiftEnabled()
	if DHUD2.ServerConVar('shift') then
		return ENABLE_SHIFT:GetBool()
	else
		return false
	end
end

hook.Add('Tick', 'DHUD2.UpdateVars', Tick)
hook.Add('HUDPaint', 'DHUD2.Draw', HUDPaint)

hook.Add('PreDrawHUD', 'DHUD.PreDrawHUD', function()
	DHUD2.IsHudDrawing = false
end)

function DHUD2.SimpleUpdate(name, value, funcName, ...)
	local Args = {...}

	DHUD2.RegisterVar(name, value, function(self, ply)
		return ply[funcName](ply, unpack(Args))
	end)
end

DHUD2.DrawBox = DLib.HUDCommons.DrawBox
DHUD2.SimpleText = DLib.HUDCommons.SimpleText
DHUD2.SoftBar = DLib.HUDCommons.SoftBar
DHUD2.SkyrimBar = DLib.HUDCommons.SkyrimBar
DHUD2.SoftSkyrimBar = DLib.HUDCommons.SoftSkyrimBar
DHUD2.WordBox = DLib.HUDCommons.WordBox

DHUD2.CreateColor('bg', 'Background', 0, 0, 0, 150)
DHUD2.CreateColor('empty_bar', 'Empty Bar', 200, 200, 200, 255)

surface.CreateFont('DHUD2.Default', {
	size = 16,
	font = 'Roboto',
	extended = true,
	weight = 500,
})

surface.CreateFont('DHUD2.PrintMessage', {
	size = 20,
	font = 'Roboto',
	extended = true,
	weight = 500,
})

DHUD2.CreateColor('generic', 'Generic', 255, 255, 255, 255)

local function Populate(Panel)
	if not IsValid(Panel) then return end --spawnmenu_reload
	Panel:Clear()

	local lab = Label('DHUD/2 - Resurrection of DHUD Legacy', Panel)
	lab:SetDark(true)
	Panel:AddItem(lab)

	local button = Panel:Button('Questions or ideas? Join Discord!')

	function button:DoClick()
		gui.OpenURL('https://discord.gg/HG9eS79')
	end

	for k, v in pairs(DHUD2.CVars) do
		local checkbox = Panel:CheckBox(v.help, k)
		checkbox:SetTooltip(v.help)
	end
end

local function PopulateServer(Panel)
	if not IsValid(Panel) then return end --spawnmenu_reload

	for k, v in pairs(DHUD2.Config) do
		local checkbox = Panel:CheckBox(v.help)
		checkbox:SetTooltip(v.help)

		checkbox.Button.DoClick = function()
			RunConsoleCommand('dhud_setvar', k, checkbox.Button:GetChecked() and '0' or '1')
		end

		checkbox.Button.Think = function()
			checkbox.Button:SetChecked(DHUD2.ServerConVar(k))
		end
	end
end

DHUD2.AddConVar('dhud_enable', 'Enable DHUD2', ENABLE)
DHUD2.AddConVar('dhud_shift', 'Enable Shifting', ENABLE_SHIFT)

local Init = false

local function LoadIfCan(fil)
	local can = hook.Run('DHUD2CanLoad', fil)
	if can == false then return end

	local can = hook.Run('DHUD2CanLoad', string.Explode('/', fil)[2])
	if can == false then return end

	local can = hook.Run('DHUD2CanLoad', string.Explode('.', string.Explode('/', fil)[2])[1])
	if can == false then return end

	include(fil)
end

local function Load()
	Init = true
	hook.Call('PreDHUD2Init')
	LoadIfCan('dhud/cl_default.lua')
	LoadIfCan('dhud/cl_playerinfo.lua')
	LoadIfCan('dhud/cl_radar.lua')
	LoadIfCan('dhud/cl_playericon.lua')
	LoadIfCan('dhud/cl_minimap.lua')
	LoadIfCan('dhud/cl_view.lua')
	LoadIfCan('dhud/cl_crosshair.lua')
	LoadIfCan('dhud/cl_history.lua')
	LoadIfCan('dhud/cl_freecam.lua')
	LoadIfCan('dhud/cl_killfeed.lua')
	LoadIfCan('dhud/cl_speedmeter.lua')
	LoadIfCan('dhud/cl_damage.lua')
	LoadIfCan('dhud/cl_voice.lua')

	if DarkRP then
		LoadIfCan('dhud/cl_darkrp.lua')
	end

	hook.Call('PostDHUD2Init')
end

hook.Add('PopulateToolMenu', 'DHUD2.Populate', function()
	if not Init then Load() end --AGH! We are running sandbox and SpawnMenu initialized... We must load DHUD2 now!
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DHUD2.Populate', 'DHUD2 Variables', '', '', Populate)
	spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'DHUD2.PopulateServer', 'DHUD2 Server', '', '', PopulateServer)
end)

hook.Call('DHUD2Initialize')

timer.Simple(0, function() if not Init then Load() end end) --Give Addons chance to load before DHUD2 and then, load it's DHUD2 modules
