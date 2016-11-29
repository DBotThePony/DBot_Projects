
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

local ALLOW_ON_ME = CreateClientConVar('cl_dsit_allow_on_me', '1', true, true, 'Allow to sit on me')
local SEND_MESSAGE = CreateClientConVar('cl_dsit_message', '1', true, true, 'React to "get off" in chat')

CreateConVar('sv_dsit_distance', '128', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Max distance (in Hammer Units)')

local DSit = {}

DSit.SVars = {
	'enable',
	'allow_weapons',
	'players',
	'players_legs',
	'wallcheck',
	'allow_ceiling',
	'nosurf_admins',
	'nosurf',
	'parent',
	'hull',
	'flat',
	'anyangle',
	'disablephysgun',
}

DSit.SVarsObjects = {
	CreateConVar('sv_dsit_enable', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable'),
	CreateConVar('sv_dsit_allow_weapons', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow weapons in seat'),
	CreateConVar('sv_dsit_players', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on players (heads)'),
	CreateConVar('sv_dsit_players_legs', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on players (legs/sit on sitting players)'),
	CreateConVar('sv_dsit_wallcheck', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Check whatever player go through wall or not'),
	CreateConVar('sv_dsit_allow_ceiling', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow players to sit on ceiling'),
	CreateConVar('sv_dsit_nosurf_admins', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Anti surf enable for admins'),
	CreateConVar('sv_dsit_nosurf', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Anti surf when players are sitting on entities'),
	CreateConVar('sv_dsit_parent', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Should vehicles be parented to players. If enabled, unexpected things may happen'),
	CreateConVar('sv_dsit_hull', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Make hull checks'),
	CreateConVar('sv_dsit_flat', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Force players sit angle "pitch" to be zero'),
	CreateConVar('sv_dsit_anyangle', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Letting players have fun'),
	CreateConVar('sv_dsit_disablephysgun', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Disable physgun usage in seat'),
}

local DISABLE_PHYSGUN = GetConVar('sv_dsit_disablephysgun')

DSit.SVarsHelp = {
	'Enable DSit',
	'Allow weapons in seat',
	'Allow to sit on players (heads)',
	'Allow to sit on players (legs/sit on sitting players)',
	'Check whatever player go through wall or not',
	'Allow players to sit on ceiling',
	'Anti surf enable for admins',
	'Anti surf when players are sitting on entities',
	'Should vehicles be parented to players. If enabled, unexpected things may happen',
	'Make hull checks',
	'Force players sit angle "pitch" have zero value',
	'Unrestricted sit angles',
	'Disable physgun usage in seat',
}

local KeyMap = {
	[KEY_FIRST] = 'FIRST',
	[KEY_NONE] = 'NONE',
	[KEY_0] = '0',
	[KEY_1] = '1',
	[KEY_2] = '2',
	[KEY_3] = '3',
	[KEY_4] = '4',
	[KEY_5] = '5',
	[KEY_6] = '6',
	[KEY_7] = '7',
	[KEY_8] = '8',
	[KEY_9] = '9',
	[KEY_A] = 'A',
	[KEY_B] = 'B',
	[KEY_C] = 'C',
	[KEY_D] = 'D',
	[KEY_E] = 'E',
	[KEY_F] = 'F',
	[KEY_G] = 'G',
	[KEY_H] = 'H',
	[KEY_I] = 'I',
	[KEY_J] = 'J',
	[KEY_K] = 'K',
	[KEY_L] = 'L',
	[KEY_M] = 'M',
	[KEY_N] = 'N',
	[KEY_O] = 'O',
	[KEY_P] = 'P',
	[KEY_Q] = 'Q',
	[KEY_R] = 'R',
	[KEY_S] = 'S',
	[KEY_T] = 'T',
	[KEY_U] = 'U',
	[KEY_V] = 'V',
	[KEY_W] = 'W',
	[KEY_X] = 'X',
	[KEY_Y] = 'Y',
	[KEY_Z] = 'Z',
	[KEY_PAD_0] = 'PAD_0',
	[KEY_PAD_1] = 'PAD_1',
	[KEY_PAD_2] = 'PAD_2',
	[KEY_PAD_3] = 'PAD_3',
	[KEY_PAD_4] = 'PAD_4',
	[KEY_PAD_5] = 'PAD_5',
	[KEY_PAD_6] = 'PAD_6',
	[KEY_PAD_7] = 'PAD_7',
	[KEY_PAD_8] = 'PAD_8',
	[KEY_PAD_9] = 'PAD_9',
	[KEY_PAD_DIVIDE] = 'PAD_DIVIDE',
	[KEY_PAD_MULTIPLY] = 'PAD_MULTIPLY',
	[KEY_PAD_MINUS] = 'PAD_MINUS',
	[KEY_PAD_PLUS] = 'PAD_PLUS',
	[KEY_PAD_ENTER] = 'PAD_ENTER',
	[KEY_PAD_DECIMAL] = 'PAD_DECIMAL',
	[KEY_LBRACKET] = 'LBRACKET',
	[KEY_RBRACKET] = 'RBRACKET',
	[KEY_SEMICOLON] = 'SEMICOLON',
	[KEY_APOSTROPHE] = 'APOSTROPHE',
	[KEY_BACKQUOTE] = 'BACKQUOTE',
	[KEY_COMMA] = 'COMMA',
	[KEY_PERIOD] = 'PERIOD',
	[KEY_SLASH] = 'SLASH',
	[KEY_BACKSLASH] = 'BACKSLASH',
	[KEY_MINUS] = 'MINUS',
	[KEY_EQUAL] = 'EQUAL',
	[KEY_ENTER] = 'ENTER',
	[KEY_SPACE] = 'SPACE',
	[KEY_BACKSPACE] = 'BACKSPACE',
	[KEY_TAB] = 'TAB',
	[KEY_CAPSLOCK] = 'CAPSLOCK',
	[KEY_NUMLOCK] = 'NUMLOCK',
	[KEY_ESCAPE] = 'ESCAPE',
	[KEY_SCROLLLOCK] = 'SCROLLLOCK',
	[KEY_INSERT] = 'INSERT',
	[KEY_DELETE] = 'DELETE',
	[KEY_HOME] = 'HOME',
	[KEY_END] = 'END',
	[KEY_PAGEUP] = 'PAGEUP',
	[KEY_PAGEDOWN] = 'PAGEDOWN',
	[KEY_BREAK] = 'BREAK',
	[KEY_LSHIFT] = 'LSHIFT',
	[KEY_RSHIFT] = 'RSHIFT',
	[KEY_LALT] = 'LALT',
	[KEY_RALT] = 'RALT',
	[KEY_LCONTROL] = 'LCONTROL',
	[KEY_RCONTROL] = 'RCONTROL',
	[KEY_LWIN] = 'LWIN',
	[KEY_RWIN] = 'RWIN',
	[KEY_APP] = 'APP',
	[KEY_UP] = 'UP',
	[KEY_LEFT] = 'LEFT',
	[KEY_DOWN] = 'DOWN',
	[KEY_RIGHT] = 'RIGHT',
	[KEY_F1] = 'F1',
	[KEY_F2] = 'F2',
	[KEY_F3] = 'F3',
	[KEY_F4] = 'F4',
	[KEY_F5] = 'F5',
	[KEY_F6] = 'F6',
	[KEY_F7] = 'F7',
	[KEY_F8] = 'F8',
	[KEY_F9] = 'F9',
	[KEY_F10] = 'F10',
	[KEY_F11] = 'F11',
	[KEY_F12] = 'F12',
	[KEY_CAPSLOCKTOGGLE] = 'CAPSLOCKTOGGLE',
	[KEY_NUMLOCKTOGGLE] = 'NUMLOCKTOGGLE',
	[KEY_LAST] = 'LAST',
	[KEY_SCROLLLOCKTOGGLE] = 'SCROLLLOCKTOGGLE',
	[KEY_COUNT] = 'COUNT',
	[KEY_XBUTTON_A] = 'XBUTTON_A',
	[KEY_XBUTTON_B] = 'XBUTTON_B',
	[KEY_XBUTTON_X] = 'XBUTTON_X',
	[KEY_XBUTTON_Y] = 'XBUTTON_Y',
	[KEY_XBUTTON_LEFT_SHOULDER] = 'XBUTTON_LEFT_SHOULDER',
	[KEY_XBUTTON_RIGHT_SHOULDER] = 'XBUTTON_RIGHT_SHOULDER',
	[KEY_XBUTTON_BACK] = 'XBUTTON_BACK',
	[KEY_XBUTTON_START] = 'XBUTTON_START',
	[KEY_XBUTTON_STICK1] = 'XBUTTON_STICK1',
	[KEY_XBUTTON_STICK2] = 'XBUTTON_STICK2',
	[KEY_XBUTTON_UP] = 'XBUTTON_UP',
	[KEY_XBUTTON_RIGHT] = 'XBUTTON_RIGHT',
	[KEY_XBUTTON_DOWN] = 'XBUTTON_DOWN',
	[KEY_XBUTTON_LEFT] = 'XBUTTON_LEFT',
	[KEY_XSTICK1_RIGHT] = 'XSTICK1_RIGHT',
	[KEY_XSTICK1_LEFT] = 'XSTICK1_LEFT',
	[KEY_XSTICK1_DOWN] = 'XSTICK1_DOWN',
	[KEY_XSTICK1_UP] = 'XSTICK1_UP',
	[KEY_XBUTTON_LTRIGGER] = 'XBUTTON_LTRIGGER',
	[KEY_XBUTTON_RTRIGGER] = 'XBUTTON_RTRIGGER',
	[KEY_XSTICK2_RIGHT] = 'XSTICK2_RIGHT',
	[KEY_XSTICK2_LEFT] = 'XSTICK2_LEFT',
	[KEY_XSTICK2_DOWN] = 'XSTICK2_DOWN',
	[KEY_XSTICK2_UP] = 'XSTICK2_UP',
}

local KeyMapReverse = {}

for k,v in pairs(KeyMap) do
	KeyMapReverse[v] = k
end

function DSit.GetKeyID(str)
	str = string.upper(str)
	
	return KeyMapReverse[str]
end

local function PhysgunPickup(ply, ent)
	local ply = LocalPlayer()
	if DISABLE_PHYSGUN:GetBool() and ply:InVehicle() and ply:GetVehicle():GetNWBool('IsSittingVehicle') then return false end
	if ent:GetNWBool('DSit_IsConstrained') then return false end
	
	if ent.IsSittingVehicle then return false end
	
	if ent == ply:GetNWEntity('DSit_Vehicle') then return false end
	if ent == ply:GetNWEntity('DSit_Vehicle_Parent') then return false end
	
	if IsValid(ent:GetNWEntity('DSit_Vehicle')) then return false end
	if not ply:IsAdmin() and IsValid(ent:GetNWEntity('DSit_Vehicle_Parented')) then return false end
end

local function VehicleTick(ent)
	if not IsValid(ent) then return end
	if not ent:GetNWBool('IsSittingVehicle') then return end
	if not IsValid(ent:GetNWEntity('ParentedToPlayer')) then return end
	
	local ply = ent:GetNWEntity('ParentedToPlayer')
	
	if IsValid(ent:GetParent()) then return end
	
	local eAng = ply:EyeAngles()
	local ePos = ply:EyePos()
	
	if ply == LocalPlayer() and ply:InVehicle() then
		eAng = eAng + ply:GetVehicle():GetAngles()
	end
	
	if not ply:InVehicle() then
		eAng.p = 0
		eAng.r = 0
	end
	
	local deltaZ = ply:GetPos():Distance(ply:EyePos())
	local localPos, localAng = WorldToLocal(ent:GetPos(), ent:GetAngles(), ePos, eAng)
	localPos.x = 0
	localPos.y = 0
	localPos.z = 20
	
	localAng.p = 0
	localAng.y = -90
	localAng.r = 0
	
	local nPos, nAng = LocalToWorld(localPos, localAng, ePos, eAng)
	
	ent:SetRenderAngles(nAng)
	ent:SetRenderOrigin(nPos)
	ent:SetPos(nPos)
end

local KeyName, KeyID

local function Think()
	for k, ent in pairs(ents.FindByClass('prop_vehicle_prisoner_pod')) do
		VehicleTick(ent)
	end
	
	if input.IsKeyDown(KEY_LALT) then
		if not KeyID then 
			KeyName = input.LookupBinding('+use')
			KeyID = DSit.GetKeyID(KeyName)
		end
		
		if not KeyID then
			hook.Remove('Think', 'DSit.Hooks')
			Error('[DSit] FATAL: +use bind is MISSING!')
		end
		
		if LocalPlayer():KeyDown(IN_USE) or input.IsKeyDown(KeyID) then RunConsoleCommand('dsit') end
	end
end

local function CheckboxFunc(self)
	RunConsoleCommand('dsit_var', self.var, self:GetChecked() and '0' or '1')
end

local function CheckboxThink(self)
	self:SetChecked(self.CVar:GetBool())
end

local function Populate(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	local lab = Label('DSit was maded by DBot')
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	for k, v in ipairs(DSit.SVars) do
		local checkbox = Panel:CheckBox(DSit.SVarsHelp[k])
		checkbox.Button.var = v
		checkbox.Button.CVar = DSit.SVarsObjects[k]
		checkbox.Button.DoClick = CheckboxFunc
		checkbox.Button.Think = CheckboxThink
	end
	
	local button = Panel:Button('Steam Workshop')
	button.DoClick = function()
		gui.OpenURL('http://steamcommunity.com/sharedfiles/filedetails/?id=673317324')
	end
	
	local button = Panel:Button('BitBucket')
	button.DoClick = function()
		gui.OpenURL('https://bitbucket.org/DBotThePony/dsit')
	end
	
	local button = Panel:Button('Github')
	button.DoClick = function()
		gui.OpenURL('https://github.com/roboderpy/dsit')
	end
end

local function PopulateClient(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	local lab = Label('DSit was maded by DBot')
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	Panel:CheckBox('Allow to sit on me', 'cl_dsit_allow_on_me')
	Panel:CheckBox('React to "get off" message in chat', 'cl_dsit_message')
	Panel:Button('Get off player on you', 'dsit_getoff')
	
	local button = Panel:Button('Steam Workshop')
	button.DoClick = function()
		gui.OpenURL('http://steamcommunity.com/sharedfiles/filedetails/?id=673317324')
	end
	
	local button = Panel:Button('GitLab')
	button.DoClick = function()
		gui.OpenURL('https://git.dbot.serealia.ca/dbot/dbot_projects')
	end
	
	local button = Panel:Button('Questions? Join Discord!')
	button.DoClick = function()
		gui.OpenURL('https://discord.gg/HG9eS79')
	end
end

local function PopulateToolMenu()
	spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'DSit.SVars', 'DSit', '', '', Populate)
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DSit.CVars', 'DSit', '', '', PopulateClient)
end

hook.Add('Think', 'DSit.Hooks', Think)
hook.Add('PopulateToolMenu', 'DSit.Hooks', PopulateToolMenu)
hook.Add('PhysgunPickup', 'DSit.Hooks', PhysgunPickup, -1)
net.Receive('DSit.ChatMessage', function() chat.AddText(unpack(net.ReadTable())) end)

concommand.Add('dsit_about', function()
	MsgC([[
DSit - Sit Everywhere!
Maded by DBot

Licensed under Apache License 2
http://www.apache.org/licenses/LICENSE-2.0

DSit distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

]])
	MsgC([[
Steam Workshop:
http://steamcommunity.com/sharedfiles/filedetails/?id=673317324
Github:
https://github.com/roboderpy/dsit
]])
end)
