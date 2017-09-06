
--[[
Copyright (C) 2016-2017 DBot

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

local ALLOW_ON_ME = CreateConVar('cl_dsit_allow_on_me', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Allow to sit on me')
local ALLOW_FRIENDS_ONLY = CreateConVar('cl_dsit_friendsonly', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Allow to sit on me')
local SEND_MESSAGE = CreateConVar('cl_dsit_message', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'React to "get off" in chat')
local MAXIMUM_ON_ME = CreateConVar('cl_dsit_maxonme', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Maximum players on you. 0 to disable')
CreateConVar('__dsit_friends', '', {FCVAR_USERINFO}, 'Internal variable to storge online steam friends')
CreateConVar('__dsit_blocked', '', {FCVAR_USERINFO}, 'Internal variable to storge online steam blocked users')

CreateConVar('sv_dsit_distance', '128', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Max distance (in Hammer Units)')

local DSit = {}

DSit.SVars = {
	'enable',
	'speed',
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
	'entities',
	'entities_owner',
	'entities_world',
}

DSit.SVarsObjects = {
	CreateConVar('sv_dsit_enable', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable'),
	CreateConVar('sv_dsit_speed', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable speed check'),
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
	CreateConVar('sv_dsit_entities', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on entities'),
	CreateConVar('sv_dsit_entities_owner', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on entities owned only by that player'),
	CreateConVar('sv_dsit_entities_world', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on non-owned entities only'),
}

local DISABLE_PHYSGUN = GetConVar('sv_dsit_disablephysgun')

DSit.SVarsHelp = {
	'Enable DSit',
	'Enable speed check',
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
	'Allow to sit on entities',
	'Allow to sit on entities owned only by that player',
	'Allow to sit on non-owned entities only',
}

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
end

local function PlayerBindPress(ply, bind, isPressed)
	if not isPressed then return end
	if not bind:find('use') then return end
	if not input.IsKeyDown(KEY_LALT) then return end
	RunConsoleCommand('dsit')
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
	Panel:CheckBox('Sit on me for friends only', 'cl_dsit_friendsonly')
	Panel:CheckBox('React to "get off" message in chat', 'cl_dsit_message')
	Panel:NumSlider('Max players on you', 'cl_dsit_maxonme', 0, 32, 0)
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

local function __dsit_friends_think()
	local build = {}
	local buildB = {}
	
	-- Fuck off about pairs. Pairs follows hash-table,
	-- so it's run time is O(n) while ipairs has O(const)
	-- but this const is much bigger than pairs(table) with table
	-- that has only <400 rows
	for i, ply in pairs(player.GetAll()) do
		local rel = ply:GetFriendStatus()
		
		if rel == 'friend' or rel == 'requested' then
			table.insert(build, ply:UserID())
		elseif rel == 'blocked' then
			table.insert(buildB, ply:UserID())
		end
	end
	
	RunConsoleCommand('__dsit_friends', table.concat(build, ','))
	RunConsoleCommand('__dsit_blocked', table.concat(buildB, ','))
end

timer.Create('__dsit_friends_think', 1, 0, __dsit_friends_think)
hook.Add('Think', 'DSit.Hooks', Think)
hook.Add('PlayerBindPress', 'DSit.Hooks', PlayerBindPress)
hook.Add('PopulateToolMenu', 'DSit.Hooks', PopulateToolMenu)
hook.Add('PhysgunPickup', 'DSit.Hooks', PhysgunPickup, -1)
net.Receive('DSit.ChatMessage', function() chat.AddText(Color(0, 200, 0), '[DSit] ', Color(200, 200, 200), unpack(net.ReadTable())) end)

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
