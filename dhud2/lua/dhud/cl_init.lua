
--[[
Copyright (C) 2016 DBot

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
DHUD2.BarData = DHUD2.BarData or {}
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

DHUD2.Multipler = 1

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

function DHUD2.SelectPlayer()
	local ply = LocalPlayer()
	if not IsValid(ply) then return ply end
	local obs = ply:GetObserverTarget()
	
	if IsValid(obs) and obs:IsPlayer() then
		return obs
	else
		return ply
	end
end

DHUD2.Colors = DHUD2.Colors or {}
DHUD2.ColorsVars = DHUD2.ColorsVars or {}

function DHUD2.CreateColor(class, name, r, g, b, a)
	local help_r = 'Changes Red Channel of ' .. name .. ' DHUD2 element'
	local help_g = 'Changes Green Channel of ' .. name .. ' DHUD2 element'
	local help_b = 'Changes Blue Channel of ' .. name .. ' DHUD2 element'
	local help_a = 'Changes Alpha Channel of ' .. name .. ' DHUD2 element'
	
	local rn = 'dhud_color_' .. class .. '_r'
	local gn = 'dhud_color_' .. class .. '_g'
	local bn = 'dhud_color_' .. class .. '_b'
	local an = 'dhud_color_' .. class .. '_a'
	
	DHUD2.ColorsVars[class] = {
		name = name,
		rdef = r,
		bdef = b,
		gdef = g,
		adef = a,
		r = CreateConVar(rn, r, {FCVAR_ARCHIVE}, help_r),
		g = CreateConVar(gn, g, {FCVAR_ARCHIVE}, help_g),
		b = CreateConVar(bn, b, {FCVAR_ARCHIVE}, help_b),
		a = CreateConVar(an, a, {FCVAR_ARCHIVE}, help_a),
	}
	
	local t = DHUD2.ColorsVars[class]
	
	local function colorUpdated()
		DHUD2.Colors[class] = Color(t.r:GetInt() or r, t.g:GetInt() or g, t.b:GetInt() or b, t.a:GetInt() or a)
	end
	
	colorUpdated()
	
	cvars.AddChangeCallback(rn, colorUpdated, 'DHUD2.Colors')
	cvars.AddChangeCallback(gn, colorUpdated, 'DHUD2.Colors')
	cvars.AddChangeCallback(bn, colorUpdated, 'DHUD2.Colors')
	cvars.AddChangeCallback(an, colorUpdated, 'DHUD2.Colors')
end

function DHUD2.GetColor(class)
	return DHUD2.Colors[class]
end

function DHUD2.DefinePosition(name, x, y)
	DHUD2.Positions_original[name .. '_x'] = x
	DHUD2.Positions_original[name .. '_y'] = y
	
	DHUD2.Positions[name .. '_x'] = x
	DHUD2.Positions[name .. '_y'] = y
	
	DHUD2.Positions_X[name] = name .. '_x'
	DHUD2.Positions_Y[name] = name .. '_y'
end

function DHUD2.GetPosition(name)
	return DHUD2.Positions[name .. '_x'], DHUD2.Positions[name .. '_y']
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
				v.draw = CurTime() + 4
				v.iscrit = true
				v.islow = true
			end
		elseif islow then
			if not v.islow then
				v.draw = CurTime() + 4
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

local MessageDraw = 0
local Message = ''
net.Receive('DHUD2.PrintMessage', function()
	local mode = net.ReadUInt(4)
	local mes = net.ReadString()
	
	if mode == HUD_PRINTCENTER then
		MessageDraw = CurTime() + 6
		Message = mes
	end
	
	if mode == HUD_PRINTTALK then
		print(mes)
		chat.AddText(mes)
	end
	
	if mode == HUD_PRINTCONSOLE or mode == HUD_PRINTNOTIFY then
		print(mes)
	end
end)

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
	
	local c = CurTime()
	
	local x, y = DHUD2.GetPosition('warning')
	local col = DHUD2.GetColor('warning')
	local bg = DHUD2.GetColor('bg')
	
	if MessageDraw > CurTime() then
		surface.SetFont('DHUD2.PrintMessage')
		local x, y = DHUD2.GetPosition('printmessage')
		local w, h = surface.GetTextSize(Message)
		
		x = x - w / 2
		y = y - h
		
		DHUD2.DrawBox(x - 4, y - 2, w + 8, h + 4, bg)
		draw.DrawText(Message, 'DHUD2.PrintMessage', x, y, DHUD2.GetColor('generic'))
	end
	
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
DHUD2.DefinePosition('warning', ScrW() / 2, ScrH() / 2 - 90)
DHUD2.DefinePosition('printmessage', ScrW() / 2, ScrH() / 2 - 160)

function DHUD2.IsShiftEnabled()
	if DHUD2.ServerConVar('shift') then
		return ENABLE_SHIFT:GetBool()
	else
		return false
	end
end

local function Think()
	if not DHUD2.IsEnabled() then return end
	
	if DHUD2.IsShiftEnabled() then
		for k, v in pairs(DHUD2.Positions_X) do
			DHUD2.Positions[v] = DHUD2.Positions_original[v] + DHUD2.ShiftX
		end
		
		for k, v in pairs(DHUD2.Positions_Y) do
			DHUD2.Positions[v] = DHUD2.Positions_original[v] + DHUD2.ShiftY
		end
	else
		for k, v in pairs(DHUD2.Positions_X) do
			DHUD2.Positions[v] = DHUD2.Positions_original[v]
		end
		
		for k, v in pairs(DHUD2.Positions_Y) do
			DHUD2.Positions[v] = DHUD2.Positions_original[v]
		end
	end
end

hook.Add('Think', 'DHUD2.Shake', Think)
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

function DHUD2.DrawBox(x, y, w, h, color)
	if color then
		surface.SetDrawColor(color)
	end
	
	surface.DrawRect(x, y, w, h)
end

function DHUD2.SimpleText(text, font, x, y, col)
	if col then 
		surface.SetTextColor(col)
	end
	
	if font then
		surface.SetFont(font)
	end
	
	surface.SetTextPos(x, y)
	surface.DrawText(text)
end

local function InInterval(val, min, max)
	return val > min and val < max
end

function DHUD2.SoftBar(x, y, w, h, color, name)
	DHUD2.BarData[name] = DHUD2.BarData[name] or w
	
	local delta = w - DHUD2.BarData[name]
	
	if not InInterval(delta, -0.3, 0.3) then
		DHUD2.BarData[name] = DHUD2.BarData[name] + delta * .1 * DHUD2.Multipler
	else
		DHUD2.BarData[name] = DHUD2.BarData[name] + delta
	end
	
	DHUD2.DrawBox(x, y, DHUD2.BarData[name], h, color)
end

function DHUD2.SkyrimBar(x, y, w, h, color)
	DHUD2.DrawBox(x - w / 2, y, w, h, color)
end

function DHUD2.SoftSkyrimBar(x, y, w, h, color, name, speed)
	speed = speed or .1
	DHUD2.BarData[name] = DHUD2.BarData[name] or w
	
	local delta = w - DHUD2.BarData[name]
	
	if not InInterval(delta, -0.3, 0.3) then
		DHUD2.BarData[name] = DHUD2.BarData[name] + delta * speed * DHUD2.Multipler
	else
		DHUD2.BarData[name] = DHUD2.BarData[name] + delta
	end
	
	DHUD2.DrawBox(x - DHUD2.BarData[name] / 2, y, DHUD2.BarData[name], h, color)
end

function DHUD2.WordBox(text, font, x, y, col, colBox, center)
	if font then
		surface.SetFont(font)
	end
	
	if col then
		surface.SetTextColor(col)
	end
	
	local w, h = surface.GetTextSize(text)
	
	if center then
		x = x - w / 2
	end
	
	DHUD2.DrawBox(x - 4, y - 2, w + 8, h + 4, colBox)
	surface.SetTextPos(x, y)
	surface.DrawText(text)
end

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

DHUD2.LastAngle = Angle()

local function UpdateShift()
	if not DHUD2.IsEnabled() then return end
	if not DHUD2.IsShiftEnabled() then return end
	
	local ply = DHUD2.SelectPlayer()
	local ang = ply:EyeAngles()
	
	local changePitch = math.AngleDifference(ang.p, DHUD2.LastAngle.p)
	local changeYaw = math.AngleDifference(ang.y, DHUD2.LastAngle.y)
	
	DHUD2.LastAngle = ang
	
	DHUD2.ShiftX = math.Clamp(DHUD2.ShiftX + changeYaw * 1.8, -150, 150)
	DHUD2.ShiftY = math.Clamp(DHUD2.ShiftY - changePitch * 1.8, -80, 80)
	
	DHUD2.ShiftX = DHUD2.ShiftX - DHUD2.ShiftX * 0.05 * DHUD2.Multipler
	DHUD2.ShiftY = DHUD2.ShiftY - DHUD2.ShiftY * 0.05 * DHUD2.Multipler
end

DHUD2.CreateColor('generic', 'Generic', 255, 255, 255, 255)

hook.Add('Think', 'DHUD2.Shift', UpdateShift)

local function Populate(Panel)
	if not IsValid(Panel) then return end --spawnmenu_reload
	
	for k, v in pairs(DHUD2.CVars) do
		local checkbox = Panel:CheckBox(v.help, k)
		checkbox:SetTooltip(v.help)
	end
	
	for k, v in SortedPairsByMemberValue(DHUD2.ColorsVars, 'name') do
		local collapse = vgui.Create('DCollapsibleCategory', Panel)
		Panel:AddItem(collapse)
		collapse:SetExpanded(false)
		collapse:SetLabel(v.name .. ' (' .. k .. ')')
		
		local picker = vgui.Create('DColorMixer', collapse)
		collapse:SetContents(picker)
		picker:SetConVarR('dhud_color_' .. k .. '_r')
		picker:SetConVarG('dhud_color_' .. k .. '_g')
		picker:SetConVarB('dhud_color_' .. k .. '_b')
		picker:SetConVarA('dhud_color_' .. k .. '_a')
		
		picker:Dock(TOP)
		picker:SetHeight(200)
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
	include(fil)
end

local function Load()
	Init = true
	hook.Call('PreDHUD2Init')
	LoadIfCan('dhud/cl_default.lua')
	LoadIfCan('dhud/cl_highlight.lua')
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
