
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

DAFK_SHOWNOTIFICATIONS = CreateConVar('sv_dafk_chat', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Display chat notifications')
DAFK_MINTIMER = CreateConVar('sv_dafk_timer', '180', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Timer before mark player as AFK')
DAFK_NOTIFYRADIUS = CreateConVar('sv_dafk_radius', '2048', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Radius of chat notify about player gone AFK or back')
local plyMeta = FindMetaTable('Player')

function plyMeta:IsAFK()
	return self:GetNWBool('DAFK.IsAFK')
end

function plyMeta:SetIsAFK(status)
	if status then self:SetAFKTime(DAFK_MINTIMER:GetInt()) end
	self:SetNWBool('DAFK.IsAFK', status)
end

function plyMeta:SetAFKTime(time)
	self:SetNWInt('DAFK.TimerStart', math.floor(CurTime() - time))
end

function plyMeta:GetAFKTime()
	return math.floor(CurTime() - self:GetNWInt('DAFK.TimerStart'))
end

function plyMeta:IsEvenAFK()
	return self:IsAFK() or self:IsTabbedOut()
end

function plyMeta:IsTabbedOut()
	return self.__DAFK_TabbedOut
end

function plyMeta:HasWindowFocus()
	return not self.__DAFK_TabbedOut
end

plyMeta.IsClientInGame = plyMeta.HasWindowFocus
plyMeta.IsGameWindowFocused = plyMeta.HasWindowFocus

function DAFK_NiceTime(time)
	local str = ''
	
	local hours = (time - time % 3600) / 3600
	time = time - hours * 3600
	local minutes = (time - time % 60) / 60
	time = time - minutes * 60
	local seconds = time
	
	if seconds ~= 0 then
		str = seconds .. ' seconds'
	end
	
	if minutes ~= 0 then
		str = minutes .. ' minutes ' .. str
	end
	
	if hours ~= 0 then
		str = hours .. ' hours ' .. str
	end
	
	return str
end

local Prefix = Color(0, 255, 0)
local Grey = Color(200, 200, 200)
local RED = Color(200, 100, 100)
local GREEN = Color(50, 200, 50)

function plyMeta:GenerateAFKMessage(status, time)
	local message
	
	if not status then
		message = {Prefix, '[DAFK] ', team.GetColor(self:Team()), self:Nick(), Grey, ' is now ', GREEN, 'BACK', Grey, ' to his keyboard! Was AFK for ' .. DAFK_NiceTime(time)}
	else
		message = {Prefix, '[DAFK] ', team.GetColor(self:Team()), self:Nick(), Grey, ' is now ', RED, 'AWAY', Grey, ' from his keyboard!'}
	end
	
	return message
end
