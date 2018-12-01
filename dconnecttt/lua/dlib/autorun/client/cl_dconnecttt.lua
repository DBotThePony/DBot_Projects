
-- Copyright (C) 2016-2018 DBot

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


DLib.RegisterAddonName('DConnecttt')

local HUD_POSITION = DLib.HUDCommons.DefinePosition('dconnecttt', 0, 0)
local COLOR_TO_USE = DLib.HUDCommons.CreateColor('dconnecttt_bg', 'DConnecttt Background', 0, 0, 0, 150)
local COLOR_TO_USE_TEXT = DLib.HUDCommons.CreateColor('dconnecttt', 'DConnecttt Background', 255, 255, 255)
local DRAW_NOT_RESPONDING = CreateConVar('cl_dconn_draw', '1', {FCVAR_ARCHIVE}, 'Draw visual effect when player loses connection')
local DRAW_TIME = CreateConVar('cl_dconn_drawtime', '1', {FCVAR_ARCHIVE}, 'Draw time played on server')
local DRAW_TIME_AT_ALL = CreateConVar('sv_dconn_drawtime', '1', {FCVAR_REPLICATED}, 'Draw time played on server')
local DISPLAY_NICKS = CreateConVar('sv_dconn_hoverdisplay', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Display players nicks on hovering')

local messaging = DLib.chat.registerWithMessages({}, 'DConnecttt')

surface.CreateFont('DConnecttt.HUD', {
	font = 'Roboto',
	size = 12,
	weight = 500,
	extended = true
})

local function HUDPaint()
	if not DRAW_TIME:GetBool() or not DRAW_TIME_AT_ALL:GetBool() then return end

	local stime = LocalPlayer():SessionTime()
	local ttime = LocalPlayer():TotalTimeConnected()

	local ent = LocalPlayer():GetEyeTrace().Entity
	local add = ''

	if DISPLAY_NICKS:GetBool() and IsValid(ent) and ent:IsPlayer() then
		local pstime = ent:SessionTime()
		local pttime = ent:TotalTimeConnected()
		local nick = ent:Nick()

		add = DLib.i18n.localize('gui.dconn.session.playerinfo', nick, DLib.string.tformat(pstime), nick, DLib.string.tformat(pttime))
	end

	local text = DLib.i18n.localize('gui.dconn.session.info', DLib.string.tformat(stime), DLib.string.tformat(ttime) .. add)
	surface.SetFont('DConnecttt.HUD')
	local w, h = surface.GetTextSize(text)
	local x, y = HUD_POSITION()

	surface.SetDrawColor(COLOR_TO_USE())
	surface.DrawRect(x - 4, y - 2, w + 8, h + 4)

	draw.DrawText(text, 'DConnecttt.HUD', x, y, COLOR_TO_USE_TEXT())
end

local function Populate(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()

	local lab = Label('DConnecttt options')
	Panel:AddItem(lab)
	lab:SetDark(true)

	Panel:CheckBox('gui.dconn.settings.cl_dconn_draw', 'cl_dconn_draw')
	Panel:CheckBox('gui.dconn.settings.cl_dconn_drawtime', 'cl_dconn_drawtime')

	Panel:NumSlider('gui.dconn.settings.cl_dconn_x', 'cl_dconn_x', 0, ScrWL(), 1)
	Panel:NumSlider('gui.dconn.settings.cl_dconn_y', 'cl_dconn_y', 0, ScrHL(), 1)

	local lab = Label('Text color')
	Panel:AddItem(lab)
	lab:SetDark(true)

	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR('cl_dconn_r')
	mixer:SetConVarG('cl_dconn_g')
	mixer:SetConVarB('cl_dconn_b')
	mixer:SetConVarA('cl_dconn_a')

	local lab = Label('Background color')
	Panel:AddItem(lab)
	lab:SetDark(true)

	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR('cl_dconn_bg_r')
	mixer:SetConVarG('cl_dconn_bg_g')
	mixer:SetConVarB('cl_dconn_bg_b')
	mixer:SetConVarA('cl_dconn_bg_a')
end

local disconnect = Material('icon16/disconnect.png')
local connect = Material('icon16/connect.png')
local currentmat = disconnect
local current = false
local lastchange = RealTimeL()

surface.CreateFont('DConnecttt.Disconnect', {
	font = 'Roboto',
	size = 72,
	weight = 800,
	extended = true
})

local function Draw(ply)
	local eyes = ply:EyePos()
	eyes.z = eyes.z + 20

	local add = Vector(-25, 0, 0)
	local delta = EyePos() - eyes
	local ang = delta:Angle()

	ang.p = 0
	ang.r = 0

	ang:RotateAroundAxis(ang:Right(), -90)
	ang:RotateAroundAxis(ang:Up(), 90)

	add:Rotate(ang)
	cam.Start3D2D(eyes + add, ang, 0.1)

	surface.DrawTexturedRect(0, 16, 32, 32)
	surface.DrawText(DLib.i18n.localize('info.dconn.connection_lost'))
	surface.SetTextPos(0, 0)

	cam.End3D2D()
end

local fail = false

local function PrePlayerDraw(ply)
	if ply.DConnecttt_Clip then
		ply.DConnecttt_Clip = false
		render.PopCustomClipPlane()
		render.EnableClipping(ply.DConnecttt_oldClipping)
		fail = true
	end

	if fail then return end

	local delta = CurTimeL() - ply:GetNW2Float('DConnecttt.JoinTime', 0)

	if delta < 0 or delta >= 20 then return end
	local defaultMult = delta / 20
	local fast = ply:GetNW2Float('DConnecttt.FastInit', 0)

	local multToUse = 0

	if fast ~= 0 then
		local fastMult = (CurTimeL() - fast) / 4

		if fastMult > defaultMult then
			multToUse = fastMult
		else
			multToUse = defaultMult
		end
	else
		multToUse = defaultMult
	end

	if multToUse > 1 or multToUse < 0 then return end

	ply.DConnecttt_oldClipping = render.EnableClipping(true)
	ply.DConnecttt_Clip = true
	local getPos, eyePos = ply:GetPos(), ply:EyePos()
	local deltaZ = (eyePos.z - getPos.z) * 1.2

	local normal = Vector(0, 0, -1)
	local newPos = Vector(getPos.x, getPos.y, getPos.z + deltaZ * multToUse)
	local dot = normal:Dot(newPos)

	render.PushCustomClipPlane(normal, dot)

	local mins, maxs = ply:OBBMins(), ply:OBBMaxs()
	ply.DConnecttt_EffectEmmiter = ply.DConnecttt_EffectEmmiter or ParticleEmitter(newPos)
	local emitter = ply.DConnecttt_EffectEmmiter

	ply.DConnecttt_lastParticle = ply.DConnecttt_lastParticle or 0

	if ply.DConnecttt_lastParticle < RealTimeL() then
		ply.DConnecttt_lastParticle = RealTimeL() + 0.05
		local new = newPos + Vector(math.random(mins.x, maxs.x), math.random(mins.y, maxs.y), 0)

		local particle = emitter:Add('particle/fire', new)
		particle:SetColor(math.random(1, 255), math.random(1, 255), math.random(1, 255))
		particle:SetVelocity(Vector(math.random(mins.x, maxs.x), math.random(mins.y, maxs.y), math.random(mins.x, maxs.x)))
		particle:SetDieTime(3)
		particle:SetStartSize(math.random(1, 3))
		particle:SetEndSize(0)
		particle:SetGravity(Vector(0, 0, -10))
	end
end

local function PostPlayerDraw(ply)
	if ply.DConnecttt_Clip then
		ply.DConnecttt_Clip = false
		render.PopCustomClipPlane()
		render.EnableClipping(ply.DConnecttt_oldClipping)
	end
end

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not DRAW_NOT_RESPONDING:GetBool() then return end

	if lastchange < RealTimeL() then
		current = not current
		lastchange = RealTimeL() + 2
		currentmat = current and connect or disconnect
	end

	surface.SetDrawColor(255, 255, 255)
	surface.SetTextColor(255, 0, 0)
	surface.SetTextPos(0, 0)
	surface.SetMaterial(currentmat)
	surface.SetFont('DConnecttt.Disconnect')

	for k, v in pairs(player.GetAll()) do
		if v:GetNWBool('DConnecttt_Dead') then
			Draw(v)
		end
	end
end

hook.Add('PostDrawTranslucentRenderables', 'DConnecttt.Draw', PostDrawTranslucentRenderables)
hook.Add('HUDPaint', 'DConnecttt.Draw', HUDPaint)
hook.Add('PrePlayerDraw', 'DConnecttt.Draw', PrePlayerDraw, 4)
hook.Add('PostPlayerDraw', 'DConnecttt.Draw', PostPlayerDraw)

timer.Create('DConnecttt.PlayerTick', 1, 0, function()
	net.Start('DConnecttt.PlayerTick')
	net.SendToServer()
end)

local LastTick = RealTimeL()
local LastTick2 = RealTimeL()
local lastOrigin = Vector()
local lastViewAngle = Angle()
local lastThink = RealTimeL()
local lastAdmin = false
local lastlag = false
local connectionRestored = true
local connectionRestored2 = RealTimeL()

local calcposEnable = false
local calcpos = Vector()
local calcang = Angle()

net.receive('DConnecttt.PlayerTick', function()
	local ply = LocalPlayer()

	LastTick2 = RealTimeL()

	if connectionRestored and (not lastAdmin or connectionRestored2 > RealTimeL()) then
		if lastlag then
			if lastAdmin then
				messaging.LMessage('message.dconn.connection.restored_real')
			else
				messaging.LMessage('message.dconn.connection.restored')
			end
		end

		LastTick = LastTick2
		lastViewAngle = ply:EyeAngles()
		lastOrigin = ply:GetPos()
		lastAdmin = ply:IsAdmin()
		calcpos = ply:EyePos()
		calcang = Angle(lastViewAngle)

		calcposEnable = false
		lastlag = false
	else
		connectionRestored2 = RealTimeL() + 2.5
		connectionRestored = true

		if lastlag then
			messaging.LMessage('message.dconn.connection.restored_wait')
		end
	end
end)

local IN_ALT1 = IN_ALT1
local IN_ALT2 = IN_ALT2
local IN_ATTACK = IN_ATTACK
local IN_ATTACK2 = IN_ATTACK2
local IN_BACK = IN_BACK
local IN_BULLRUSH = IN_BULLRUSH
local IN_CANCEL = IN_CANCEL
local IN_DUCK = IN_DUCK
local IN_FORWARD = IN_FORWARD
local IN_GRENADE1 = IN_GRENADE1
local IN_GRENADE2 = IN_GRENADE2
local IN_JUMP = IN_JUMP
local IN_LEFT = IN_LEFT
local IN_MOVELEFT = IN_MOVELEFT
local IN_MOVERIGHT = IN_MOVERIGHT
local IN_RELOAD = IN_RELOAD
local IN_RIGHT = IN_RIGHT
local IN_RUN = IN_RUN
local IN_SCORE = IN_SCORE
local IN_SPEED = IN_SPEED
local IN_USE = IN_USE
local IN_WALK = IN_WALK
local IN_WEAPON1 = IN_WEAPON1
local IN_WEAPON2 = IN_WEAPON2
local IN_ZOOM = IN_ZOOM

hook.Add('CreateMove', 'DConnecttt.PreventMove', function(cmd)
	local ctime = RealTimeL()
	local delta = ctime - lastThink
	lastThink = ctime
	if RealTimeL() - LastTick < 3 then return end

	local plag = lastlag

	if not lastlag then
		messaging.LMessage('message.dconn.connection.froze')
		lastlag = true
	end

	if not lastAdmin then
		cmd:ClearButtons()
		cmd:ClearMovement()
		cmd:SetMouseX(0)
		cmd:SetMouseY(0)
		cmd:SetMouseWheel(0)
		cmd:SetViewAngles(lastViewAngle)

		if not plag then
			messaging.LMessage('message.dconn.connection.denied')
		end

		if RealTimeL() - LastTick2 > 3 then
			connectionRestored = true
		end
	else
		if RealTimeL() - LastTick2 > 3 then
			connectionRestored = false
			connectionRestored2 = 0
		end

		local ply = LocalPlayer()

		if not plag then
			messaging.LMessage('message.dconn.connection.granted')
			calcpos = ply:EyePos()
		end

		calcposEnable = true
		local up = 0
		local left = 0
		local fwd = 0

		if cmd:KeyDown(IN_JUMP) then
			up = 1600
		end

		if cmd:KeyDown(IN_MOVERIGHT) then
			left = -1600
		end

		if cmd:KeyDown(IN_MOVELEFT) then
			left = 1600
		end

		if cmd:KeyDown(IN_FORWARD) then
			fwd = 1600
		end

		if cmd:KeyDown(IN_BACK) then
			fwd = -1600
		end

		if cmd:KeyDown(IN_SPEED) then
			fwd = fwd * 3
			up = up * 3
			left = left * 3
		end

		local newang = cmd:GetViewAngles()
		local diff = newang - lastViewAngle
		calcang = calcang + diff

		cmd:ClearButtons()
		cmd:ClearMovement()
		cmd:SetMouseX(0)
		cmd:SetMouseY(0)
		cmd:SetMouseWheel(0)
		cmd:SetViewAngles(lastViewAngle)

		local mv = Vector(fwd, left, up) * delta * 0.5
		mv:Rotate(calcang)

		calcpos = calcpos + mv
	end
end)

hook.Add('CalcView', 'DConnecttt.FakeMove', function(ply, origin, angles, fov, znear, zfar)
	if not calcposEnable then return end

	return {
		origin = calcpos,
		fov = fov,
		angles = calcang,
		--znear = znear,
		--zfar = zfar,
		drawviewer = true
	}
end, -5)

hook.Add('PopulateToolMenu', 'DConnecttt.Menus', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DConnecttt.CVars', 'DConnecttt', '', '', Populate)
end)
