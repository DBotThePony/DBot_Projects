
-- Copyright (C) 2017-2019 DBot

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

local DDayNight = DDayNight
local DLib = DLib
local self = DDayNight
local IsValid = IsValid
local unpack = unpack

local perms = DLib.CAMIWatchdog('ddaynight_perms', nil,
	'ddaynight_setseed',
	'ddaynight_fastforward',
	'ddaynight_fastforward12h',
	'ddaynight_fastforward1',
	'ddaynight_fastforward7',
	'ddaynight_fastforward30',
	'ddaynight_fastforward90',
	'ddaynight_fastforward180'
)

local fwd = {43200, '12h', 86400, '1', 86400 * 7, '7', 86400 * 30, '30',  86400 * 90, '90', 86400 * 180, '180'}

for i = 1, #fwd - 1, 2 do
	local time = fwd[i]
	local suffix = fwd[i + 1]
	if not suffix or not time then break end

	concommand.Add('ddaynight_fwd' .. suffix, function(ply, cmd, args)
		if IsValid(ply) and not perms:HasPermission(ply, 'ddaynight_fastforward' .. suffix) then
			DDayNight.LChatPlayer(ply, 'message.daynight.command.no_perms')
			return
		end

		if DDayNight.TIME_FAST_FORWARD_SEQ or DDayNight.TIME_FAST_FORWARD then
			DayNight.LChatPlayer(ply, 'message.daynight.command.already_sequence')
			return
		end

		DDayNight.LMessageAll(ply, 'message.daynight.command.fastforward', unpack(DLib.i18n.tformatRawTable(time)))
		DDayNight.FastForwardSequence(time)
	end)
end

concommand.Add('ddaynight_fwd', function(ply, cmd, args)
	if IsValid(ply) and not perms:HasPermission(ply, 'ddaynight_fastforward') then
		DDayNight.LChatPlayer(ply, 'message.daynight.command.no_perms')
		return
	end

	if DDayNight.TIME_FAST_FORWARD_SEQ or DDayNight.TIME_FAST_FORWARD then
		DayNight.LChatPlayer(ply, 'message.daynight.command.already_sequence')
		return
	end

	local time = tonumber((args[1] or ''):trim())

	if not time then
		DayNight.LChatPlayer(ply, 'message.daynight.command.missing_time')
		return
	end

	if time <= 21600 then
		DayNight.LChatPlayer(ply, 'message.daynight.command.invalid_time')
		return
	end

	DDayNight.LMessageAll(ply, 'message.daynight.command.fastforward', unpack(DLib.i18n.tformatRawTable(time)))
	DDayNight.FastForwardSequence(time)
end)

concommand.Add('ddaynight_setseed', function(ply, cmd, args)
	if IsValid(ply) and not perms:HasPermission(ply, 'ddaynight_setseed') then
		DDayNight.LChatPlayer(ply, 'message.daynight.command.no_perms')
		return
	end

	local seed = tonumber((args[1] or ''):trim())

	if not seed then
		DayNight.LChatPlayer(ply, 'message.daynight.command.invalid_seed')
		return
	end

	seed = seed:floor():abs() % 0x1000000000

	DDayNight.LMessageAll(ply, 'message.daynight.command.fastforward', unpack(DLib.i18n.tformatRawTable(time)))
	DDayNight.FastForwardSequence(time)
end)
