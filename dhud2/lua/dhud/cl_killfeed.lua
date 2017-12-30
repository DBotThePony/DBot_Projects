
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

local ENABLE = CreateConVar('dhud_killfeed', '1', FCVAR_ARCHIVE, 'Enable Killfeed')
DHUD2.AddConVar('dhud_killfeed', 'Enable Killfeed', ENABLE)

DHUD2.Killfeed = DHUD2.Killfeed or {}
local Feed = DHUD2.Killfeed

Feed.History = Feed.History or {}

local Suicide = 'gone from this world'
local Fall = 'done his last flight'

DHUD2.CreateColor('feed_npc', 'Death Feed NPC Color', 255, 230, 105, 255)
DHUD2.CreateColor('feed_suicide', 'Death Feed Suicide Color', 255, 255, 255, 255)

DHUD2.DefinePosition('killfeed', ScrW() - 100, 100)

function DHUD2.AddDeathNotice(attacker, aTeam, weapon, victim, vTeam)
	if not DHUD2.IsEnabled() then return end
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('killfeed') then return end

	local data = {}

	data.weapon = weapon ~= nil and weapon or 'suicide'
	data.isSuicide = attacker == victim or attacker == nil
	data.isFall = attacker == '#world'
	data.attacker = attacker
	data.victim = victim
	data.aTeam = aTeam
	data.vTeam = vTeam
	data.icon = weapon
	data.weapon = weapon
	data.weapont = '#' .. weapon

	data.weaponcolor = Color(255, 0, 0)

	if aTeam == -1 or aTeam == 0 or not aTeam then
		data.acolor = table.Copy(DHUD2.GetColor('feed_npc'))
	else
		data.acolor = team.GetColor(aTeam)
	end

	if vTeam == -1 or vTeam == 0 or not vTeam then
		data.vcolor = table.Copy(DHUD2.GetColor('feed_npc'))
	else
		data.vcolor = table.Copy(team.GetColor(vTeam))
	end

	data.atext = attacker
	data.vtext = victim

	if data.isFall then
		data.atext = victim
		data.vtext = Fall
		data.icon = 'suicide'
		data.acolor = data.vcolor
		data.vcolor = table.Copy(DHUD2.GetColor('feed_suicide'))
	end

	if data.isSuicide then
		data.atext = victim
		data.vtext = Suicide
		data.icon = 'suicide'
		data.acolor = data.vcolor
		data.vcolor = table.Copy(DHUD2.GetColor('feed_suicide'))
	end

	data.start = CurTime()
	data.endtime = CurTime() + 8
	data.time = 8
	data.startfade = CurTime() + 7
	data.alpha = 255

	data.width = 0

	table.insert(Feed.History, data)
end

surface.SetFont('DHUD2.Default')
local Bracket = surface.GetTextSize('[')

local function Draw()
	if not DHUD2.IsEnabled() then return end
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('killfeed') then return end

	local x, y = DHUD2.GetPosition('killfeed')
	local bg = DHUD2.GetColor('bg')

	surface.SetFont('DHUD2.Default')

	for k, data in pairs(Feed.History) do
		local X = x + 3 - data.width

		local bg = Color(bg.r, bg.g, bg.b, data.alpha)
		DHUD2.DrawBox(X - 3, y - 2, data.width, 25, bg)

		local ha = surface.GetTextSize(data.atext)

		DHUD2.SimpleText(data.atext, nil, X, y, data.acolor)

		X = X + ha + 3

		local kw = surface.GetTextSize(data.weapont)
		--killicon.Draw(X + kw, y, data.icon, data.alpha)
		DHUD2.SimpleText('[', nil, X, y, data.weaponcolor)
		X = X + Bracket
		DHUD2.SimpleText(data.weapont, nil, X, y, data.weaponcolor)
		X = X + kw + 1
		DHUD2.SimpleText(']', nil, X, y, data.weaponcolor)

		X = X + Bracket + 3

		local hv = surface.GetTextSize(data.vtext)
		DHUD2.SimpleText(data.vtext, nil, X, y, data.vcolor)

		X = X + hv + 3

		data.width = X - x + data.width

		y = y + 30
	end
end

local function Think()
	if not DHUD2.IsEnabled() then return end
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('killfeed') then return end

	local ctime = CurTime()
	for k, data in pairs(Feed.History) do
		if data.endtime < ctime then
			Feed.History[k] = nil
			continue
		end

		if data.startfade < ctime then
			data.alpha = (data.endtime - CurTime()) * 255
			data.vcolor.a = data.alpha
			data.acolor.a = data.alpha
			data.weaponcolor.a = data.alpha
		end
	end
end

DHUD2.DrawHook('DeathFeed', Draw)
DHUD2.VarHook('DeathFeed', Think)

local function Override()
	local function DrawDeathNotice(x, y)
		if not DHUD2.IsEnabled() then return end
		if not ENABLE:GetBool() then return end
		if not DHUD2.ServerConVar('killfeed') then return end

		--Don't do anything here
		return true
	end

	local function AddDeathNotice(...)
		if not DHUD2.IsEnabled() then return end
		if not ENABLE:GetBool() then return end
		if not DHUD2.ServerConVar('killfeed') then return end

		DHUD2.AddDeathNotice(...)
		return true
	end

	hook.Add('DrawDeathNotice', 'DHUD2.DrawDeathNotice', DrawDeathNotice)
	hook.Add('AddDeathNotice', 'DHUD2.AddDeathNotice', AddDeathNotice)

	Feed.oldDrawFunc = Feed.oldDrawFunc or GAMEMODE.AddDeathNotice

	function GAMEMODE:AddDeathNotice(...)
		if not DHUD2.IsEnabled() or not ENABLE:GetBool() or not DHUD2.ServerConVar('killfeed') then
			if isfunction(Feed.oldDrawFunc) then Feed.oldDrawFunc(self, ...) end
			return
		end

		DHUD2.AddDeathNotice(...)
	end
end

timer.Simple(0, Override)
