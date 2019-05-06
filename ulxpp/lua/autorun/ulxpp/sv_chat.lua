
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

local ENABLED = CreateConVar('sv_ulxpp_slash', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Enable / command prefix')

local function sayCmdCheck(ply, strText, bTeam)
	if not ENABLED:GetBool() then return end
	if string.sub(strText, 1, 1) ~= '/' then return end
	strText = '!' .. string.sub(strText, 2)

	local match

	for str, data in pairs(ULib.sayCmds) do
		local str2 = str

		if strText:len() < str:len() then
			str2 = string.Trim(str)
		end

		if strText:sub(1, str2:len()):lower() == str2 then
			if not match or match:len() <= str:len() then
				match = str
			end
		end
	end

	if not match then return end

	local data = ULib.sayCmds[match]

	local args = string.Trim(strText:sub(match:len() + 1))
	local argv = ULib.splitArgs(args)

	if data.__cmd then
		local return_value = hook.Call(ULib.HOOK_COMMAND_CALLED, _, ply, data.__cmd, argv)
		if return_value == false then return end
	end

	if not ULib.ucl.query(ply, data.access) then
		ULib.tsay(ply, "You do not have access to this command, " .. ply:Nick() .. ".")
		return ""
	end

	local fn = data.fn
	local hide = data.hide

	ULib.pcallError(fn, ply, match:Trim(), argv, args)
	return ''
end

hook.Add("PlayerSay", "ULib_saycmdslash", sayCmdCheck, HOOK_HIGH)
