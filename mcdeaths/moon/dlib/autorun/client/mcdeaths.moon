
-- Copyright (C) 2019 DBotThePony

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

import net, DLib, LocalPlayer, RealTimeL, os from _G
import i18n from DLib

DISPLAY_PLAYER_DEATHS = CreateConVar('cl_mcdeaths_player', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Display player death messages if enabled by server')
DISPLAY_NPC_DEATHS = CreateConVar('cl_mcdeaths_npc', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Display NPC death messages if enabled by server')
DISPLAY_DRAW = CreateConVar('cl_mcdeaths_draw', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw death reason of local player on screen')

PLAYER_CHAT = CreateConVar('sv_mcdeaths_player_chat', '0', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Write player death messages to chat when others are close enough')
PLAYER_CHAT_RANGE = CreateConVar('sv_mcdeaths_player_range', '1512', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'How far from death point should death message appear in chat when a player dies')
NPC_CHAT = CreateConVar('sv_mcdeaths_npc_chat', '0', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Write NPC death messages to chat when others are close enough')
NPC_CHAT_RANGE = CreateConVar('sv_mcdeaths_npc_range', '786', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'How far from death point should death message appear in chat when a NPC dies')

color_npc = Color(200, 200, 200)

net.receive 'mcdeaths_npcdeath', ->
	return if not DISPLAY_NPC_DEATHS\GetBool()
	point = net.ReadVector()
	text = net.ReadStringArray()

	rebuild = i18n.rebuildTable(text, color_npc, true)

	if NPC_CHAT\GetBool() and LocalPos()\Distance(point) <= NPC_CHAT_RANGE\GetFloat()
		chat.AddText(color_npc, unpack(rebuild, 1, #rebuild))
	else
		MsgC(color_npc, unpack(rebuild, 1, #rebuild))
		MsgC('\n')

local DEATH_REASON, DIED_AT, DIED_AT_STAMP, ALIVE_FOR

ALIVE_FROM = 0
DEATH_REASON = 'lol'

net.receive 'mcdeaths_death', ->
	return if not DISPLAY_PLAYER_DEATHS\GetBool()
	point = net.ReadVector()
	ply = net.ReadEntity()
	text = net.ReadStringArray()

	rebuild = i18n.rebuildTable(text, color_white, true)

	if PLAYER_CHAT\GetBool() and LocalPos()\Distance(point) <= PLAYER_CHAT_RANGE\GetFloat()
		chat.AddText(color_white, unpack(rebuild, 1, #rebuild))
	else
		MsgC(color_white, unpack(rebuild, 1, #rebuild))
		MsgC('\n')

	if DISPLAY_DRAW\GetBool() and ply == LocalPlayer()
		DIED_AT = i18n.localize('gui.mcdeaths.at', os.date('%H:%M:%S - %d/%m/%Y'))
		ALIVE_FOR = i18n.localize('gui.mcdeaths.alivefor', i18n.tformat(RealTimeL() - ALIVE_FROM))
		DIED_AT_STAMP = RealTimeL()
		timer.Simple 0.5, -> DEATH_REASON = table.concat(rebuild, ' ')

surface.DLibCreateFont('MCDeaths_YouDied', {
	font: 'PT Sans'
	extended: true
	size: 18
})

surface.DLibCreateFont('MCDeaths_YouDied_Small', {
	font: 'PT Sans'
	extended: true
	size: 14
})

POS = DLib.HUDCommons.DefinePosition('mcdeaths', 0.5, 0.23, false)
COLOR = DLib.HUDCommons.CreateColor('mcdeaths', 'MCDeaths Text', 255, 255, 255)

import draw, surface, color_black, TEXT_ALIGN_CENTER from _G

HUDPaint = ->
	return if not DEATH_REASON

	if LocalPlayer()\Alive()
		DEATH_REASON = nil
		ALIVE_FROM = RealTimeL()
		return

	x, y = POS()

	youdied = i18n.localize('gui.mcdeaths.youdied')

	draw.DrawText(youdied, 'MCDeaths_YouDied', x + 2, y + 2, color_black, TEXT_ALIGN_CENTER)
	draw.DrawText(youdied, 'MCDeaths_YouDied', x, y, COLOR(), TEXT_ALIGN_CENTER)

	w, h = surface.GetTextSize(youdied)
	y += h * 1.1

	draw.DrawText(DEATH_REASON, 'MCDeaths_YouDied', x + 2, y + 2, color_black, TEXT_ALIGN_CENTER)
	draw.DrawText(DEATH_REASON, 'MCDeaths_YouDied', x, y, COLOR(), TEXT_ALIGN_CENTER)

	w, h = surface.GetTextSize(DEATH_REASON)
	y += h * 1.1

	draw.DrawText(DIED_AT, 'MCDeaths_YouDied_Small', x + 2, y + 2, color_black, TEXT_ALIGN_CENTER)
	draw.DrawText(DIED_AT, 'MCDeaths_YouDied_Small', x, y, COLOR(), TEXT_ALIGN_CENTER)

	w, h = surface.GetTextSize(DIED_AT)
	y += h * 1.1

	stamp = i18n.tformat(RealTimeL() - DIED_AT_STAMP, true)

	draw.DrawText(stamp, 'MCDeaths_YouDied_Small', x + 2, y + 2, color_black, TEXT_ALIGN_CENTER)
	draw.DrawText(stamp, 'MCDeaths_YouDied_Small', x, y, COLOR(), TEXT_ALIGN_CENTER)

	w, h = surface.GetTextSize(stamp)
	y += h * 1.1

	draw.DrawText(ALIVE_FOR, 'MCDeaths_YouDied_Small', x + 2, y + 2, color_black, TEXT_ALIGN_CENTER)
	draw.DrawText(ALIVE_FOR, 'MCDeaths_YouDied_Small', x, y, COLOR(), TEXT_ALIGN_CENTER)

hook.Add 'HUDPaint', 'MCDeaths.HUDPaint', HUDPaint, 6

hook.Add 'PopulateToolMenu', 'MCDeaths.Settings', ->
	spawnmenu.AddToolMenuOption 'Utilities', 'Admin', 'MCDeaths.Settings', 'MC Deaths', '', '', =>
		@CheckBox('gui.mcdeaths.settings.sv_mcdeaths', 'sv_mcdeaths')
		@CheckBox('gui.mcdeaths.settings.sv_mcdeaths_mute', 'sv_mcdeaths_mute')
		@CheckBox('gui.mcdeaths.settings.sv_mcdeaths_player', 'sv_mcdeaths_player')
		@CheckBox('gui.mcdeaths.settings.sv_mcdeaths_npc', 'sv_mcdeaths_npc')
		@CheckBox('gui.mcdeaths.settings.sv_mcdeaths_send', 'sv_mcdeaths_send')
		@CheckBox('gui.mcdeaths.settings.sv_mcdeaths_player_chat', 'sv_mcdeaths_player_chat')
		@NumSlider('gui.mcdeaths.settings.sv_mcdeaths_player_range', 'sv_mcdeaths_player_range', 0, 0x2000, 0)
		@CheckBox('gui.mcdeaths.settings.sv_mcdeaths_npc_chat', 'sv_mcdeaths_npc_chat')
		@NumSlider('gui.mcdeaths.settings.sv_mcdeaths_npc_range', 'sv_mcdeaths_npc_range', 0, 0x2000, 0)

	spawnmenu.AddToolMenuOption 'Utilities', 'User', 'MCDeaths.UserSettings', 'MC Deaths', '', '', =>
		@CheckBox('gui.mcdeaths.settings.cl_mcdeaths_draw', 'cl_mcdeaths_draw')
		@CheckBox('gui.mcdeaths.settings.cl_mcdeaths_player', 'cl_mcdeaths_player')
		@CheckBox('gui.mcdeaths.settings.cl_mcdeaths_npc', 'cl_mcdeaths_npc')

return
