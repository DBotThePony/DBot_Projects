
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

local function PlayerBindPress(ply, bind, isPressed)
	if not isPressed then return end
	if bind ~= 'use' and bind ~= '+use' then return end
	if not input.IsKeyDown(KEY_LALT) then return end

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

cvars.AddChangeCallback('cl_dsit_hide', DSit_RECALCULATE, 'DSit.Recalc')

hook.Add('PlayerBindPress', 'DSit', PlayerBindPress)
hook.Add('PopulateToolMenu', 'DSit', PopulateToolMenu)
