
--[[
Copyright (C) 2016-2019 DBotThePony


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

]]

DAFK_SHOWNOTIFICATIONS = CreateConVar('sv_dafk_chat', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Display chat notifications')
DAFK_MINTIMER = CreateConVar('sv_dafk_timer', '180', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Timer before mark player as AFK')
DAFK_NOTIFYRADIUS = CreateConVar('sv_dafk_radius', '2048', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Radius of chat notify about player gone AFK or back')
DAFK_USEANGLES = CreateConVar('sv_dafk_angles', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Moving mouse causes player to be not longer marked as afk')

local plyMeta = FindMetaTable('Player')

function plyMeta:IsAFK()
	return self:GetNWBool('DAFK.IsAFK')
end

function plyMeta:SetIsAFK(status)
	if self:IsBot() then return end
	if status then self:SetAFKTime(DAFK_MINTIMER:GetInt()) end
	self:SetNWBool('DAFK.IsAFK', status)
end

function plyMeta:SetAFKTime(time)
	if self:IsBot() then return end
	self:SetNWInt('DAFK.TimerStart', math.floor(CurTimeL() - time))
end

function plyMeta:GetAFKTime()
	if self:IsBot() then return 0 end
	return math.floor(CurTimeL() - self:GetNWInt('DAFK.TimerStart'))
end

function plyMeta:IsEvenAFK()
	return not self:IsBot() and (self:IsAFK() or self:IsTabbedOut())
end

function plyMeta:IsTabbedOut()
	return self.__DAFK_TabbedOut or false
end

function plyMeta:HasWindowFocus()
	return not self.__DAFK_TabbedOut
end

plyMeta.IsClientInGame = plyMeta.HasWindowFocus
plyMeta.IsGameWindowFocused = plyMeta.HasWindowFocus

local _, generator = DLib.CMessage({}, 'DAFK')

local RED = Color(200, 100, 100)
local GREEN = Color(50, 200, 50)

function plyMeta:GenerateAFKMessage(status, time)
	local message

	if not status then
		message = generator.LFormatMessage('message.dafk.status.player_back', self, GREEN, generator.textcolor, DLib.NUMBER_COLOR, DLib.i18n.tformat(time))
	else
		message = generator.LFormatMessage('message.dafk.status.player_away', self, RED, generator.textcolor)
	end

	return message
end
