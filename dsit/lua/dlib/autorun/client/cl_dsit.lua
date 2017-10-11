
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local ALLOW_ON_ME = CreateConVar('cl_dsit_allow_on_me', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Allow to sit on me')
local ALLOW_FRIENDS_ONLY = CreateConVar('cl_dsit_friendsonly', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Allow to sit on me')
local SEND_MESSAGE = CreateConVar('cl_dsit_message', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'React to "get off" in chat')
local MAXIMUM_ON_ME = CreateConVar('cl_dsit_maxonme', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Maximum players on you. 0 to disable')

local messaging = DLib.chat.registerWithMessages({}, 'DSit')
local DSIT_TRACKED_VEHICLES = _G.DSIT_TRACKED_VEHICLES

net.receive('DSit.VehicleTick', function()
	local vehicle = net.ReadEntity()
	if IsValid(vehicle) then DSIT_TRACKED_VEHICLES:insert(vehicle) end
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

	local lab = Label('DSit made by DBotThePony')
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

	local lab = Label('DSit made by DBotThePony')
	Panel:AddItem(lab)
	lab:SetDark(true)

	Panel:CheckBox('Allow to sit on me', 'cl_dsit_allow_on_me')
	Panel:CheckBox('Allow only for friends', 'cl_dsit_friendsonly')
	Panel:CheckBox('Check for "get off" message in chat', 'cl_dsit_message')
	Panel:NumSlider('Max players on you', 'cl_dsit_maxonme', 0, 32, 0)
	Panel:Button('Get off player on you', 'dsit_getoff')

	local button = Panel:Button('Discord')
	button.DoClick = function()
		gui.OpenURL('https://discord.gg/HG9eS79')
	end
end

local function PopulateToolMenu()
	spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'DSit.SVars', 'DSit', '', '', Populate)
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DSit.CVars', 'DSit', '', '', PopulateClient)
end

hook.Add('PlayerBindPress', 'DSit', PlayerBindPress)
hook.Add('PopulateToolMenu', 'DSit', PopulateToolMenu)
