
-- Copyright (C) 2018 DBot

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
-- AND EVEN IF I INCLUDED VLL2 INTO THE ADDON ITSELF IT STILL HAD **DOZENS**
-- OF RUNSTRINGS AND COMPILESTRINGS FROM HTTPS (WHICH ALSO COME FROM MY WEB SERVER)
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

	-- You can manually download vll2.lua and place it onto lua/autorun/
	-- on the server, so it would not load from my web server
	-- but one request will still be made - it would load avaliable bundles
	-- list for load using vll2_load "addoname"
	-- those bundles are the most latest (directly from my vscode) builds of my addons
	-- also all of my addons are 100% hotload compatible
	-- but dlib has some hacks to hotload after gmod already started
	-- but it still can hotload

	-- notice that manually placing vll2 into server's autorun is not supported
	-- and since vll2 is not bundled with dtoybox it can break because of latest vll2
	-- changes, and dtoybox will update but vll2 will stay outdated, hence the issues.
	-- actully, you should not rely on dtoybox IN ANY WAY, since it is just a toy
	-- which you can play with
	-- and also look up at license.
	if VLL2 then return end

	http.Fetch('https://dbot.serealia.ca/vll/vll2.lua', function(b)
		if VLL2 then return end
		RunString(b, 'VLL2')
	end)
end)

if SERVER then
	AddCSLuaFile('dtoybox/cl_logic.lua')
	AddCSLuaFile('dtoybox/cl_menu.lua')
	AddCSLuaFile('dtoybox/sh_logic.lua')
	AddCSLuaFile('dtoybox/sh_util.lua')
	include('dtoybox/sh_logic.lua')
	include('dtoybox/sh_util.lua')
	include('dtoybox/sv_logic.lua')
else
	include('dtoybox/sh_logic.lua')
	include('dtoybox/sh_util.lua')
	include('dtoybox/cl_logic.lua')
	include('dtoybox/cl_menu.lua')
end
