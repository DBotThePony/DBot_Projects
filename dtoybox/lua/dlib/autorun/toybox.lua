
-- Copyright (C) 2018-2019 DBot

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

-- WARNING WARNING WARNING!
-- THIS IS CORE FUNCTIONALITY OF
-- TOYBOX! IF YOU CAME HERE JUST BY
-- REGEXP MATCH FOR RUNSTRING AND THINK THIS IS A BACKDOOR -
-- YOU ARE THINKING INCORRECT
-- TOYBOX IS BUILT ON TOP OF VLL2 (the Virtual Lua Loader v2)
-- IF YOU ARE GOING TO REPORT THIS ADDON JUST FOR THAT - YOU ARE A VERY BAD PERSON
-- WARNING WARNING WARNING!

_G.DToyBox = DToyBox or {}

DLib.MessageMaker(DToyBox, 'DToyBox')

local http = http
local RunString = RunString

timer.Simple(0, function()
	if net.Receivers then
		for key, value in pairs(net.Receivers) do
			if key:startsWith('\xe2\x81\xac\xe2\x80\xad\xe2\x81\xac\xe2\x81\xad\xe2\x81') then
				MsgC('------------------------------------------\n')
				MsgC('------------ CAKE ANTICHEAT DETECTED\n')
				MsgC('------------ TOYBOX WILL NOT LOAD!\n')
				MsgC('------------ Get rid of CakeAnticheat in order to use Toybox!\n')
				MsgC('------------ (or get rid of Toybox to use CakeAnticheat)\n')
				MsgC('------------ DO NOT DISABLE PROTECTION MODULES IN CAKE ANTICHEAT\n')
				MsgC('------------ THIS IS NOT A BUG/ISSUE IN EITHER ADDONS!\n')
				MsgC('------------ JUST THEY CONFLICT AT VERY LOW LEVEL (CSLUA DETECTION)\n')
				MsgC('------------ THIS IS NOT FIXABLE ON BOTH SIDES\n')
				MsgC('------------ SO **DO NOT** REPORT THIS TO EITHER DBOT OR !CAKE\n')
				MsgC('------------------------------------------\n')
				return
			end
		end
	end

	if VLL2 and VLL2.IS_WEB_LOADED then return end

	-- auto update to latest build avaliable
	http.Fetch('https://dbotthepony.ru/vll/vll2.lua', function(b, size, headers, code)
		if code == 200 then
			DToyBox.Message('Got VLL2 from the server')
			RunString(b, 'VLL2')
		else
			DToyBox.Message('VLL2 auto update failed, server replied: ', code)
			include('dtoybox/vll2.lua')
		end
	end, function(reason)
		DToyBox.Message('VLL2 auto update failed, reason: ', reason)
		include('dtoybox/vll2.lua')
	end)
end)

if SERVER then
	AddCSLuaFile('dtoybox/cl_logic.lua')
	AddCSLuaFile('dtoybox/cl_menu.lua')
	AddCSLuaFile('dtoybox/sh_logic.lua')
	AddCSLuaFile('dtoybox/sh_util.lua')
	AddCSLuaFile('dtoybox/vll2.lua')
	include('dtoybox/sh_logic.lua')
	include('dtoybox/sh_util.lua')
	include('dtoybox/sv_logic.lua')
else
	include('dtoybox/sh_logic.lua')
	include('dtoybox/sh_util.lua')
	include('dtoybox/cl_logic.lua')
	include('dtoybox/cl_menu.lua')
end
