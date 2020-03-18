
-- Copyright (C) 2017-2019 DBotThePony

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


local ALLOW_ON_ME = CreateConVar('cl_dsit_allow_on_me', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Allow to sit on me')
local ALLOW_FRIENDS_ONLY = CreateConVar('cl_dsit_friendsonly', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Allow to sit on me')
local SEND_MESSAGE = CreateConVar('cl_dsit_message', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'React to "get off" in chat')
local MAXIMUM_ON_ME = CreateConVar('cl_dsit_maxonme', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Maximum players on you. 0 to disable')
local HIDE_ON_ME = CreateConVar('cl_dsit_hide', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Hide players sitting on top of you')
local INTERACTIVE_ENABLE = CreateConVar('cl_dsit_interactive', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Enable interactive sit angle choose')
local INTERACTIVE_WAIT = CreateConVar('cl_dsit_interactive_wait', '0.2', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Interactive mode wait time on single spot in seconds')

DLib.RegisterAddonName('DSit')

local messaging = DLib.chat.registerWithMessages({}, 'DSit')
local DSIT_TRACKED_VEHICLES = _G.DSIT_TRACKED_VEHICLES
local NULL = NULL

net.receive('DSit.VehicleTick', function()
	local vehicle = net.ReadEntity()

	if IsValid(vehicle) then
		table.insert(DSIT_TRACKED_VEHICLES, vehicle)

		timer.Create('DSit.Recalc', 1, 1, DSit_RECALCULATE)
	end
end)

local pressed = false
local onpress, onrelease

local function CreateMove(cmd)
	if input.IsKeyDown(KEY_LALT) and cmd:KeyDown(IN_USE) and not pressed then
		onpress()
	elseif pressed and not cmd:KeyDown(IN_USE) then
		onrelease()
	end

	if pressed then
		cmd:RemoveKey(IN_USE)
	end
end

local function PlayerBindPress(ply, bind, isPressed)
	if not isPressed then return end
	if bind ~= 'use' and bind ~= '+use' then return end
	if not input.IsKeyDown(KEY_LALT) then return end

	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:GetAimVector() * DSitConVars:getFloat('distance'),
		filter = ply
	})

	if tr.Hit and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) then
		RunConsoleCommand('dsit')
		return true
	end

	if INTERACTIVE_ENABLE:GetBool() then return end

	RunConsoleCommand('dsit')
	return true
end

local function Populate(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()

	local lab = Label('gui.dsit.menu.author')
	Panel:AddItem(lab)
	lab:SetDark(true)

	DSitConVars:checkboxes(Panel)

	local button = Panel:Button('Discord')
	button.DoClick = function()
		gui.OpenURL('https://discord.gg/HG9eS79')
	end
end

local function PopulateClient(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()

	local lab = Label('gui.dsit.menu.author')
	Panel:AddItem(lab)
	lab:SetDark(true)

	Panel:CheckBox('gui.dsit.menu.interactive', 'cl_dsit_interactive')
	Panel:CheckBox('gui.dsit.menu.sitonme', 'cl_dsit_allow_on_me')
	Panel:CheckBox('gui.dsit.menu.friendsonly', 'cl_dsit_friendsonly')
	Panel:CheckBox('gui.dsit.menu.getoff_check', 'cl_dsit_message')
	Panel:CheckBox('gui.dsit.menu.hide', 'cl_dsit_hide')
	Panel:NumSlider('gui.dsit.menu.max', 'cl_dsit_maxonme', 0, 32, 0)
	Panel:Button('gui.dsit.menu.getoff', 'dsit_getoff')

	local button = Panel:Button('Discord')

	function button:DoClick()
		gui.OpenURL('https://discord.gg/HG9eS79')
	end

	lab = Label('gui.dsit.menu.getoff_e')
	Panel:AddItem(lab)
	lab:SetDark(true)

	local buttons = {}

	function DSit_CURRENT_PLAYER_MENU()
		if not IsValid(Panel) then return end

		for i, pnl in ipairs(buttons) do
			if pnl:IsValid() then
				pnl:Remove()
			end
		end

		buttons = {}

		local lply = LocalPlayer()

		for i, vehicle in ipairs(DSIT_TRACKED_VEHICLES) do
			if vehicle:GetNWEntity('dsit_player_root', NULL) == lply then
				local ply = vehicle:GetDriver()

				if ply:IsValid() then
					local button = Panel:Button(ply:Nick())
					table.insert(buttons, button)

					function button:DoClick()
						if ply:IsValid() then
							RunConsoleCommand('dsit_getoff', ply:EntIndex())
							timer.Simple(0.5, DSit_CURRENT_PLAYER_MENU)
						end
					end
				end
			end
		end
	end

	DSit_CURRENT_PLAYER_MENU()
end

local function PopulateToolMenu()
	spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'DSit.SVars', 'DSit', '', '', Populate)
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DSit.CVars', 'DSit', '', '', PopulateClient)
end

local ents = ents
local IsValid = IsValid
local player = player
local ipairs = ipairs

function DSit_RECALCULATE()
	for i = 1, #DSIT_TRACKED_VEHICLES do
		DSIT_TRACKED_VEHICLES[i] = nil
	end

	for i, ent in ipairs(ents.FindByClass('prop_vehicle_prisoner_pod')) do
		if ent:GetNWBool('dsit_flag') then
			table.insert(DSIT_TRACKED_VEHICLES, ent)
		end
	end

	for i, ply in ipairs(player.GetAll()) do
		if ply.dsit_hide then
			ply:SetNoDraw(ply.dsit_hide_prev)
			ply.dsit_hide = false
			ply.dsit_hide_prev = nil
		end
	end

	local lply = LocalPlayer()

	if HIDE_ON_ME:GetBool() then
		for i, vehicle in ipairs(DSIT_TRACKED_VEHICLES) do
			if vehicle:GetNWEntity('dsit_player_root', NULL) == lply then
				local ply = vehicle:GetDriver()

				if ply:IsValid() then
					ply.dsit_hide = true
					ply.dsit_hide_prev = ply:GetNoDraw()
					ply:SetNoDraw(true)
				end
			end
		end
	end

	if DSit_CURRENT_PLAYER_MENU then
		DSit_CURRENT_PLAYER_MENU()
	end
end

local prevTrace, fixedTrace, prevFrames, chosenAngle

function onpress()
	if not INTERACTIVE_ENABLE:GetBool() then
		return
	end

	pressed = true
	prevTrace = nil
	fixedTrace = nil
	prevFrames = 0
	chosenAngle = nil
end

function onrelease()
	pressed = false

	if not fixedTrace then
		RunConsoleCommand('dsit')
		return
	end

	local build = {'pos:' .. fixedTrace.HitPos.x .. ',' .. fixedTrace.HitPos.y .. ',' .. fixedTrace.HitPos.z}

	if chosenAngle then
		table.insert(build, 'angle:' .. (chosenAngle.y - 90))
	end

	RunConsoleCommand('dsit', unpack(build))
end

local ARROW_WIDTH = 24
local ARROW_BODY_WIDTH = 6

local function PostDrawHUD()
	if not pressed then return end

	local ply = LocalPlayer()
	local mins, maxs = ply:GetHull()
	local eyes = ply:EyePos()
	local spos = ply:GetPos()
	local ppos = spos + ply:OBBCenter()
	local fwd = ply:GetAimVector()

	local trDataLine = {
		start = eyes,
		endpos = eyes + fwd * DSitConVars:getFloat('distance'),
		filter = ply
	}

	local trDataHull = {
		start = ppos,
		endpos = trDataLine.endpos,
		filter = ply,
		mins = mins,
		maxs = maxs,
	}

	local tr = util.TraceLine(trDataLine)
	local trh = util.TraceHull(trDataHull)

	if not fixedTrace then
		if not tr.Hit then
			return
		end

		if tr.Entity ~= trh.Entity then
			return
		end

		if IsValid(tr.Entity) then
			if tr.Entity:GetClass():startsWith('func_door') then return end
			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then return end
		end
	end

	local chosenSnap

	if not fixedTrace then
		if prevTrace then
			if prevTrace:Distance(tr.HitPos) < 2 then
				prevFrames = prevFrames + RealFrameTime()

				if prevFrames >= INTERACTIVE_WAIT:GetFloat() then
					fixedTrace = tr
				end
			else
				prevFrames = 0
				prevTrace = tr.HitPos
			end
		else
			prevTrace = tr.HitPos
		end
	end

	local dist = 0

	if fixedTrace then
		local angle = (tr.HitPos - fixedTrace.HitPos):Angle()
		dist = tr.HitPos:Distance(fixedTrace.HitPos)
		angle.p = 0
		angle.r = 0

		local foundSnappy, snappyNormal, snappyTrace = DSit_FindSnappyAngle(ply, fixedTrace, angle)

		if foundSnappy then
			local angle2 = snappyNormal:Angle()

			if math.abs(angle2.y - angle.y) < 10 then
				chosenAngle = angle2
				chosenSnap = true
			else
				chosenAngle = angle
				chosenSnap = false
			end
		else
			chosenAngle = angle
			chosenSnap = false
		end

		if not chosenSnap and not IsValid(tr.Entity) then
			chosenAngle.y = (chosenAngle.y / 6):round() * 6
		end
	end

	local dot

	if chosenAngle then
		dot = fixedTrace.HitPos:Angle():Up():Dot(EyeAngles():Forward())
	end

	cam.Start3D()

	if chosenAngle then
		local x, y = 0, 0
		local tipheight = 12
		local height = math.max(dist - tipheight, 0)

		local renderpos = fixedTrace.HitPos + chosenAngle:Forward() * math.sqrt(math.pow(fixedTrace.HitPos.x - tr.HitPos.x, 2) + math.pow(fixedTrace.HitPos.y - tr.HitPos.y, 2)) / 2
		local renderang = Angle(0, chosenAngle.y - 90, 0)

		if dot > -0.4 and dot < 0.6 then
			renderang.p = 90
		end

		local add = Vector(-ARROW_WIDTH / 2, 0, 0)
		add:Rotate(renderang)
		renderpos:Add(add)

		local arrow = {
			{x = x + ARROW_WIDTH / 2, y = y},
			{x = x + ARROW_WIDTH, y = y + tipheight},
			{x = x + ARROW_WIDTH / 2 + ARROW_BODY_WIDTH / 2, y = y + tipheight},
			{x = x + ARROW_WIDTH / 2 + ARROW_BODY_WIDTH / 2, y = y + height + tipheight},
			{x = x + ARROW_WIDTH / 2 - ARROW_BODY_WIDTH / 2, y = y + height + tipheight},
			{x = x + ARROW_WIDTH / 2 - ARROW_BODY_WIDTH / 2, y = y + tipheight},
			{x = x, y = y + tipheight},
		}

		draw.NoTexture()
		surface.SetDrawColor(chosenSnap and color_yellow or color_blue)

		cam.Start3D2D(renderpos, renderang, 1)
		surface.DrawPoly(arrow)
		cam.End3D2D()

		renderang:RotateAroundAxis(renderang:Forward(), 180)
		renderang:RotateAroundAxis(renderang:Up(), 180)
		renderpos:Sub(add)
		renderpos:Sub(add)

		cam.Start3D2D(renderpos, renderang, 1)
		surface.DrawPoly(arrow)
		cam.End3D2D()
	end

	if fixedTrace then
		render.DrawLine(fixedTrace.HitPos, fixedTrace.HitPos + fixedTrace.HitNormal * 10, color_red)
	else
		render.DrawLine(tr.HitPos, tr.HitPos + tr.HitNormal * 10)
	end

	--[[if chosenAngle then
		local start, endpos = Vector(fixedTrace.HitPos), fixedTrace.HitPos + fixedTrace.HitNormal * 10
		local add = Vector(0, -ARROW_BODY_WIDTH / 2, 0)
		add:Rotate(chosenAngle)
		start:Add(add)
		endpos:Add(add)
		render.DrawLine(start, endpos, color_red)

		start:Sub(add)
		start:Sub(add)
		endpos:Sub(add)
		endpos:Sub(add)
		render.DrawLine(start, endpos, color_red)

		render.DrawLine(fixedTrace.HitPos + fixedTrace.HitNormal * 10, fixedTrace.HitPos + fixedTrace.HitNormal * 10 + chosenAngle:Forward() * math.sqrt(math.pow(fixedTrace.HitPos.x - tr.HitPos.x, 2) + math.pow(fixedTrace.HitPos.y - tr.HitPos.y, 2)), chosenSnap and color_yellow or color_blue)
	end]]

	cam.End3D()
end

cvars.AddChangeCallback('cl_dsit_hide', DSit_RECALCULATE, 'DSit.Recalc')

hook.Add('PlayerBindPress', 'DSit', PlayerBindPress)
hook.Add('PopulateToolMenu', 'DSit', PopulateToolMenu)
hook.Add('PostDrawHUD', 'DSit', PostDrawHUD)
hook.Add('CreateMove', 'DSit', CreateMove)
