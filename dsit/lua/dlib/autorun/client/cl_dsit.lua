
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
	if not input.IsKeyDown(KEY_LSHIFT) then return end

	RunConsoleCommand('dsit')

	return true
end

hook.Add('PlayerBindPress', 'DSit', PlayerBindPress)
